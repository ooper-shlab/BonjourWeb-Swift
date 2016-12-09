//
//  BonjourWebAppDelegate.swift
//  BonjourWeb
//
//  Created by 開発 on 2015/5/5.
//
//
/*

    File: BonjourWebAppDelegate.h
    File: BonjourWebAppDelegate.m
Abstract:  The application delegate.
 It creates the BonjourBrowser (a navigation controller) and is the delgate for
that BonjourBrowser.
 When it gets the delegate callback, it constructs a URL and launches that URL
in Safari.

 Version: 2.9

Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
Inc. ("Apple") in consideration of your agreement to the following
terms, and your use, installation, modification or redistribution of
this Apple software constitutes acceptance of these terms.  If you do
not agree with these terms, please do not use, install, modify or
redistribute this Apple software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following
text and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Inc. may
be used to endorse or promote products derived from the Apple Software
without specific prior written permission from Apple.  Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

Copyright (C) 2010 Apple Inc. All Rights Reserved.


*/

import UIKit

@UIApplicationMain
@objc(BonjourWebAppDelegate)
class BonjourWebAppDelegate: NSObject, UIApplicationDelegate, BonjourBrowserDelegate {
    
    @IBOutlet var window: UIWindow?
    
    var browser: BonjourBrowser!
    
    var server: BonjourServer!
    
    
    let kWebServiceType = "_http._tcp"
    let kInitialDomain = "local"
    
    
    func applicationDidFinishLaunching(_ application: UIApplication) {
        //### Internal Web Server for debugging
        server = BonjourServer()
        server.run()
        
        // Create the Bonjour Browser for Web services
        let aBrowser = BonjourBrowser(forType: kWebServiceType,
                                      inDomain: kInitialDomain,
                                      customDomains: nil, // we won't save any additional domains added by the user
            showDisclosureIndicators: false,
            showCancelButton: false)
        self.browser = aBrowser
        
        aBrowser.delegate = self
        
        // We want to let the user know that the services list is dynamic and always updating, even when there are no
        // services currently found.
        aBrowser.searchingForServicesString = NSLocalizedString("Searching for web services", comment: "Searching for web services string")
        
        // Add the controller's view as a subview of the window
        self.window?.rootViewController = aBrowser
    }
    
    
    private func copyStringFromTXTDict(_ dict: [NSObject: AnyObject]?, which: String) -> String? {
        // Helper for getting information from the TXT data
        var resultString: String? = nil
        if let data = dict?[which as NSObject] as! Data? {
            resultString = String(data: data, encoding: String.Encoding.utf8)!
        }
        return resultString
    }
    
    
    func bonjourBrowser(_ browser: BonjourBrowser, didResolveInstance service: NetService?) {
        assert(service != nil)
        // Construct the URL including the port number
        // Also use the path, username and password fields that can be in the TXT record
        let dict = NetService.dictionary(fromTXTRecord: service!.txtRecordData()!)
        let host = service!.hostName
        
        let user = self.copyStringFromTXTDict(dict as [NSObject : AnyObject]?, which: "u")
        let pass = self.copyStringFromTXTDict(dict as [NSObject : AnyObject]?, which: "p")
        
        var portStr = ""
        
        // Note that [NSNetService port:] returns an NSInteger in host byte order
        let port = service?.port ?? 0
        if port != 0 && port != 80 {
            portStr = ":\(port)"
        }
        
        var path = self.copyStringFromTXTDict(dict as [NSObject : AnyObject]?, which: "path")
        if path == nil || path!.isEmpty {
            path = "/"
        } else if !path!.hasPrefix("/") {
            path = "/\(path)"
        }
        
        let string = String(format: "http://%@%@%@%@%@%@%@",
                            user ?? "",
                            pass != nil ? ":" : "",
                            pass ?? "",
                            (user != nil || pass != nil) ? "@" : "",
                            host!,
                            portStr,
                            path!)
        
        let url = URL(string: string)!
        UIApplication.shared.openURL(url)
        
    }
    
}
