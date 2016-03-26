//
//  BonjourServerRequest.swift
//  BonjourWeb
//
//  Created by OOPer in cooperation with shlab.jp, on 2015/8/1.
//
//
import UIKit

@objc
protocol BonjourServerRequestDelegate {
    func bonjourServerRequestDidFinish(request: BonjourServerRequest)
    func bonjourServerRequestDidReceiveError(request: BonjourServerRequest)
}

@objc
class BonjourServerRequest: NSObject, NSStreamDelegate {
    
    var istr: NSInputStream
    var ostr: NSOutputStream
    var peerName: String
    weak var delegate: BonjourServerRequestDelegate?
    
    init(inputStream readStream: NSInputStream,
        outputStream writeStream: NSOutputStream,
        peer peerAddress: String,
        delegate anObject: BonjourServerRequestDelegate)
    {
        self.istr = readStream
        self.ostr = writeStream
        self.peerName = peerAddress
        self.delegate = anObject
    }
    
    func runProtocol() {
        
        self.istr.delegate = self
        self.istr.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.istr.open()
        self.ostr.delegate = self
        self.ostr.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        self.ostr.open()
    }
    
    func stream(stream: NSStream, handleEvent eventCode: NSStreamEvent) {
        switch eventCode {
        case NSStreamEvent.HasSpaceAvailable:
            if stream === self.ostr {
                if (stream as! NSOutputStream).hasSpaceAvailable {
                    // Send a simple no header response
                    self.sendResponse()
                }
            }
        case NSStreamEvent.HasBytesAvailable:
            if stream === self.istr {
                // Ignore whole request data
                self.istr.close()
            }
        case NSStreamEvent.ErrorOccurred:
            NSLog("stream: %@", stream)
            delegate?.bonjourServerRequestDidReceiveError(self)
        default:
            break
        }
    }
    
    func sendResponse() {
        let response = ("\r\nBonjour, le monde!" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!
        self.ostr.write(UnsafePointer(response.bytes), maxLength: response.length)
        self.ostr.close()
    }
    
    deinit {
        istr.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        ostr.removeFromRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        
        
    }
    
}