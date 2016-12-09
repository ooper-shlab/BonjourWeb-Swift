//
//  BonjourBrowser.swift
//  BonjourWeb
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/5/5.
//
//
/*

    File: BonjourBrowser.h
    File: BonjourBrowser.m
Abstract:  A subclass of UINavigationController that handles the UI needed for a user to
browse for Bonjour services.
 It contains list view controllers for domains and service instances.
 It allows the user to add their own domains.

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

@objc(BonjourBrowserDelegate)
protocol BonjourBrowserDelegate: UINavigationControllerDelegate {
    // This method will be invoked when the user selects one of the service instances from the list.
    // The ref parameter will be the selected (already resolved) instance or nil if the user taps the 'Cancel' button (if shown).
    func bonjourBrowser(_ browser: BonjourBrowser, didResolveInstance ref: NetService?)
}

@objc(BonjourBrowser)
class BonjourBrowser: UINavigationController, BrowserViewControllerDelegate, DomainViewControllerDelegate {
    
    override var delegate: UINavigationControllerDelegate? {
        willSet {assert(newValue! is BonjourBrowserDelegate)} // because UINavigationContoller also has a _delegate
    }
    var searchingForServicesString: String? // The string to show when there are no services currently found (but updates are still ongoing)
        {
        didSet {didSetSearchingForServicesString(oldValue)}
    }
    var showTitleInNavigationBar: Bool = false // If YES, the title of this object will be shown in the navigation bar
        {
        didSet{didSetShowTitleInNavigationBar(oldValue)}
    }
    
    
    private var bvc: BrowserViewController?
    private var dvc: DomainViewController!
    private var type: String!
    private var domain: String?
    private var showDisclosureIndicators: Bool = false
    private var showCancelButton: Bool = false
    
    
    @objc(initForType:inDomain:customDomains:showDisclosureIndicators:showCancelButton:)
    init(forType type: String,          // The Bonjour service type to browse for, e.g. @"_http._tcp"
        inDomain domain: String,        // The initial domain to browse in (pass nil to start in domains list)
        customDomains: [String]?,        // An array of domains specified by the user
        showDisclosureIndicators: Bool, // Whether to show discolsure indicators on service instance table cells
        showCancelButton: Bool          // Whether to show a cancel button as the right navigation item
        // Pass YES if you are modally showing this BonjourBrowser
        ) {
        
        // Create some strings that will be used in the DomainViewController.
        let domainsTitle = NSLocalizedString("Domains", comment: "Domains title")
        let domainLabel = NSLocalizedString("Added Domains", comment: "Added Domains label")
        let addDomainTitle = NSLocalizedString("Add Domain", comment: "Add Domain title")
        let searchingForServicesString = NSLocalizedString("Searching for services", comment: "Searching for services string")
        
        // Initialize the DomainViewController, which uses a NSNetServiceBrowser to look for Bonjour domains.
        let dvc = DomainViewController(title: domainsTitle, showDisclosureIndicators: true, customsTitle: domainLabel, customs: customDomains, addDomainTitle: addDomainTitle, showCancelButton: showCancelButton)
        
        super.init(rootViewController: dvc)
        self.type = type
        self.showDisclosureIndicators = showDisclosureIndicators
        self.showCancelButton = showCancelButton
        self.searchingForServicesString	= searchingForServicesString
        self.dvc = dvc
        self.dvc.delegate = self
        self.dvc.searchForBrowsableDomains() // Tells the DomainViewController's NSNetServiceBrowser to start a search for domains that are browsable via Bonjour and the computer's network configuration.
        
        if !domain.isEmpty {
            self.domain = domain
            self.setupBrowser()
            self.pushViewController(self.bvc!, animated: false)
        }
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // This property holds a string that displays the status of the service search to the user.
    private func didSetSearchingForServicesString(_ searchingForServicesString: String?) {
        if self.searchingForServicesString != searchingForServicesString {
            
            if self.bvc != nil {
                self.bvc!.searchingForServicesString = self.searchingForServicesString
            }
        }
    }
    
    
    private func didSetShowTitleInNavigationBar(_ show: Bool) {
        if self.showTitleInNavigationBar {
            self.bvc?.navigationItem.prompt = self.title
            self.dvc.navigationItem.prompt = self.title
        } else {
            self.bvc?.navigationItem.prompt = nil
            self.dvc.navigationItem.prompt = nil
        }
    }
    
    
    func browserViewController(_ bvc: BrowserViewController, didResolveInstance service: NetService?) {
        assert(bvc === self.bvc)
        (self.delegate as! BonjourBrowserDelegate?)?.bonjourBrowser(self, didResolveInstance: service)
    }
    
    // Create a BrowserViewController, which manages a NSNetServiceBrowser configured to look for Bonjour services.
    private func setupBrowser() {
        let aBvc = BrowserViewController(title: self.domain!, showDisclosureIndicators: self.showDisclosureIndicators, showCancelButton: self.showCancelButton)
        aBvc.searchingForServicesString = self.searchingForServicesString
        aBvc.delegate = self
        // Calls -[NSNetServiceBrowser searchForServicesOfType:inDomain:].
        aBvc.searchForServicesOfType(self.type, inDomain: self.domain!)
        
        // Store the BrowerViewController in an instance variable.
        self.bvc = aBvc
        if self.showTitleInNavigationBar {
            self.bvc!.navigationItem.prompt = self.title
        }
    }
    
    // This method will be invoked when the user selects one of the domains from the list.
    // The domain parameter will be the selected domain or nil if the user taps the 'Cancel' button (if shown).
    func domainViewController(_ dvc: DomainViewController, didSelectDomain domain: String?) {
        if domain == nil {
            // Cancel
            (self.delegate as! BonjourBrowserDelegate?)?.bonjourBrowser(self, didResolveInstance: nil)
            return
        }
        
        self.domain = domain
        self.setupBrowser()
        self.pushViewController(self.bvc!, animated: true)
    }
    
    
}
