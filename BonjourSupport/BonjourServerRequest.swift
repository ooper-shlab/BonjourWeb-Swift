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
    func bonjourServerRequestDidFinish(_ request: BonjourServerRequest)
    func bonjourServerRequestDidReceiveError(_ request: BonjourServerRequest)
}

@objc
class BonjourServerRequest: NSObject, StreamDelegate {
    
    var istr: InputStream
    var ostr: OutputStream
    var peerName: String
    weak var delegate: BonjourServerRequestDelegate?
    
    init(inputStream readStream: InputStream,
         outputStream writeStream: OutputStream,
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
        self.istr.schedule(in: .current, forMode: RunLoopMode.commonModes)
        self.istr.open()
        self.ostr.delegate = self
        self.ostr.schedule(in: .current, forMode: RunLoopMode.commonModes)
        self.ostr.open()
    }
    
    func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case Stream.Event.hasSpaceAvailable:
            if stream === self.ostr {
                if (stream as! OutputStream).hasSpaceAvailable {
                    // Send a simple no header response
                    self.sendResponse()
                }
            }
        case Stream.Event.hasBytesAvailable:
            if stream === self.istr {
                // Ignore whole request data
                self.istr.close()
            }
        case Stream.Event.errorOccurred:
            NSLog("stream: %@", stream)
            delegate?.bonjourServerRequestDidReceiveError(self)
        default:
            break
        }
    }
    
    func sendResponse() {
        let body = "Bonjour, le monde!"
        //### Seems the latest mobile Safari accepts only valid HTTP response...
        let header = "HTTP/1.1 200 OK\r\n" +
            "Content-Type: text/plain;\r\n" +
            "Content-Length: \(body.utf8.count)\r\n" +
        "\r\n"
        let response = (header+body).data(using: .utf8)!
        response.withUnsafeBytes {responseBytes in
            _ = self.ostr.write(responseBytes, maxLength: response.count)
        }
        self.ostr.close()
    }
    
    deinit {
        istr.remove(from: .current, forMode: .commonModes)
        
        ostr.remove(from: .current, forMode: .commonModes)
        
        
    }
    
}
