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
class BonjourServer: NSObject, BonjourServerRequestDelegate, NetServiceDelegate {
    var connectionBag: Set<BonjourServerRequest> = []
    var netService: NetService?
    
    
    override init() {
        super.init()
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.teardown()
    }
    
    func netServiceWillPublish(_ sender: NetService) {
        print(#function)
    }
    func netServiceDidPublish(_ sender: NetService) {
        print(#function, sender)
        self.netService = sender
    }
    func netService(_ sender: NetService, didNotPublish errorDict: [String: NSNumber]) {
        //### We found sometimes `netService(_:didNotPublish:)` called without errors, so ignore it.
        //fatalError(errorDict.description)
        print(errorDict.description)
    }
    
    func netService(_ sender: NetService, didAcceptConnectionWith readStream: InputStream, outputStream writeStream: OutputStream) {
        //print(#function)
        OperationQueue.main.addOperation {
            //### We cannot get client peer info here?
            let peer: String? = "Generic Peer"
            
            CFReadStreamSetProperty(readStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket), kCFBooleanTrue)
            CFWriteStreamSetProperty(writeStream, CFStreamPropertyKey(kCFStreamPropertyShouldCloseNativeSocket), kCFBooleanTrue)
            self.handleConnection(peer, inputStream: readStream, outputStream: writeStream)
        }
    }
    
    func setupServer() throws {
        
        if self.netService != nil {
            // Calling [self run] more than once should be a NOP.
            return
        } else {
            
            self.netService = NetService(domain: "local", type: kBonjourServiceType, name: "Internal Web Server", port: 0)
            guard self.netService != nil else {
                self.teardown()
                throw NSError(domain: BonjourServerErrorDomain, code: kBonjourServerCouldNotBindOrEstablishNetService, userInfo: nil)
            }
            self.netService?.delegate = self
            
        }
    }
    
    func run() {
        do {
            try self.setupServer()
        } catch let thisError as NSError {
            fatalError(thisError.localizedDescription)
        }
        
        print(#function)
        self.netService!.publish(options: .listenForConnections)
    }
    
    func handleConnection(_ peerName: String?, inputStream readStream: InputStream, outputStream writeStream: OutputStream) {
        
        guard let peer = peerName else {
            fatalError("No peer name given for client.")
        }
        print("peer=",peer)
        let newPeer = BonjourServerRequest(inputStream: readStream,
            outputStream: writeStream,
            peer: peer,
            delegate: self)
        
        newPeer.runProtocol()
        self.connectionBag.insert(newPeer)
    }
    
    func bonjourServerRequestDidFinish(_ request: BonjourServerRequest) {
        self.connectionBag.remove(request)
    }
    
    func bonjourServerRequestDidReceiveError(_ request: BonjourServerRequest) {
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
