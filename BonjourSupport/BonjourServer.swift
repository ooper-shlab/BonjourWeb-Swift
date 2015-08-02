//
//  BonjourServer.swift
//  BonjourWeb
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/1.
//
//

import UIKit

let kBonjourServiceType = "_http._tcp"

let BonjourServerErrorDomain = "BonjourServerErrorDomain"
let kBonjourServerCouldNotBindToIPv4Address = 1
let kBonjourServerCouldNotBindToIPv6Address = 2
let kBonjourServerNoSocketsAvailable = 3
let kBonjourServerCouldNotBindOrEstablishNetService = 4

@objc
class BonjourServer: NSObject, BonjourServerRequestDelegate, NSNetServiceDelegate {
    var connectionBag: Set<BonjourServerRequest> = []
    var netService: NSNetService?
    
    
    override init() {
        super.init()
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        self.teardown()
    }
    
    func netServiceDidPublish(sender: NSNetService) {
        self.netService = sender
    }
    func netService(sender: NSNetService, didNotPublish errorDict: [String: NSNumber]) {
        fatalError(errorDict.description)
    }
    
    func netService(sender: NSNetService, didAcceptConnectionWithInputStream readStream: NSInputStream, outputStream writeStream: NSOutputStream) {
        NSOperationQueue.mainQueue().addOperationWithBlock {
            //### We cannot get client peer info here?
            let peer: String? = "Generic Peer"
            
            CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
            CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue)
            self.handleConnection(peer, inputStream: readStream, outputStream: writeStream)
        }
    }
    
    func setupServer() throws {
        
        if self.netService != nil {
            // Calling [self run] more than once should be a NOP.
            return
        } else {
            
            if self.netService == nil {
                self.netService = NSNetService(domain: "local", type: kBonjourServiceType, name: UIDevice.currentDevice().name, port: 0)
                self.netService?.delegate = self
            }
            
            if self.netService == nil {
                self.teardown()
                throw NSError(domain: BonjourServerErrorDomain, code: kBonjourServerCouldNotBindOrEstablishNetService, userInfo: nil)
            }
        }
    }
    
    func run() {
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
        
        self.netService!.publishWithOptions(.ListenForConnections)
    }
    
    func handleConnection(peerName: String?, inputStream readStream: NSInputStream, outputStream writeStream: NSOutputStream) {
        
        assert(peerName != nil, "No peer name given for client.")
        
        if let peer = peerName  {
            let newPeer = BonjourServerRequest(inputStream: readStream,
                outputStream: writeStream,
                peer: peer,
                delegate: self)
            
            newPeer.runProtocol()
            self.connectionBag.insert(newPeer)
            
        }
    }
    
    func bonjourServerRequestDidFinish(request: BonjourServerRequest) {
        self.connectionBag.remove(request)
    }
    
    func bonjourServerRequestDidReceiveError(request: BonjourServerRequest) {
        self.connectionBag.remove(request)
    }
    
    func teardown() {
        if self.netService != nil {
            self.netService!.stop()
            self.netService = nil
        }
    }
    
    deinit {
        self.teardown()
    }
    
}