//
//  BrowserViewController.swift
//  BonjourWeb
//
//  Created by 開発 on 2015/5/4.
//
//
/*

    File: BrowserViewController.h
    File: BrowserViewController.m
Abstract:  View controller for the service instance list.
 This object manages a NSNetServiceBrowser configured to look for Bonjour
services.
 It has an array of NSNetService objects that are displayed in a table view.
 When the service browser reports that it has discovered a service, the
corresponding NSNetService is added to the array.
 When a service goes away, the corresponding NSNetService is removed from the
array.
 Selecting an item in the table view asynchronously resolves the corresponding
net service.
 When that resolution completes, the delegate is called with the corresponding
NSNetService.

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

@objc(BrowserViewControllerDelegate)
protocol BrowserViewControllerDelegate: NSObjectProtocol {
    // This method will be invoked when the user selects one of the service instances from the list.
    // The ref parameter will be the selected (already resolved) instance or nil if the user taps the 'Cancel' button (if shown).
    func browserViewController(bvc: BrowserViewController, didResolveInstance ref: NSNetService?)
}

private let kProgressIndicatorSize: CGFloat = 20.0

// A category on NSNetService that's used to sort NSNetService objects by their name.


@objc(BrowserViewController)
class BrowserViewController: UITableViewController, NSNetServiceBrowserDelegate, NSNetServiceDelegate {
    var delegate: BrowserViewControllerDelegate?
    var searchingForServicesString: String? {
        didSet {didSetSearchingForServicesString(oldValue)}
    }
    private var showDisclosureIndicators: Bool = false
    private var services: [NSNetService] = []
    private var netServiceBrowser: NSNetServiceBrowser?
    private var currentResolve: NSNetService?
    dynamic var timer: NSTimer? {
        willSet {willSetTimer(newValue)}
    }
    private var needsActivityIndicator: Bool = false
    private var initialWaitOver: Bool = false
    
    init(title: String, showDisclosureIndicators show: Bool, showCancelButton: Bool) {
        
        super.init(style: .Plain)
        self.title = title
        self.showDisclosureIndicators = show
        
        if showCancelButton {
            // add Cancel button as the nav bar's custom right view
            let addButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(BrowserViewController.cancelAction))
            self.navigationItem.rightBarButtonItem = addButton
        }
        
        // Make sure we have a chance to discover devices before showing the user that nothing was found (yet)
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(BrowserViewController.waitOver(_:)), userInfo: nil, repeats: false)
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Holds the string that's displayed in the table view during service discovery.
    private func didSetSearchingForServicesString(searchingForServicesString: String?) {
        if self.searchingForServicesString != searchingForServicesString {
            
            // If there are no services, reload the table to ensure that searchingForServicesString appears.
            if self.services.isEmpty {
                self.tableView.reloadData()
            }
        }
    }
    
    // Creates an NSNetServiceBrowser that searches for services of a particular type in a particular domain.
    // If a service is currently being resolved, stop resolving it and stop the service browser from
    // discovering other services.
    func searchForServicesOfType(type: String, inDomain domain: String) -> Bool {
        
        self.stopCurrentResolve()
        self.netServiceBrowser?.stop()
        self.services.removeAll()
        
        let aNetServiceBrowser = NSNetServiceBrowser()
        // The NSNetServiceBrowser couldn't be allocated and initialized.
        
        aNetServiceBrowser.delegate = self
        self.netServiceBrowser = aNetServiceBrowser
        self.netServiceBrowser!.searchForServicesOfType(type, inDomain: domain)
        
        self.tableView.reloadData()
        return true
    }
    
    
    // When this is called, invalidate the existing timer before releasing it.
    private func willSetTimer(newTimer: NSTimer?) {
        timer?.invalidate()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If there are no services and searchingForServicesString is set, show one row to tell the user.
        let count = self.services.count
        if count == 0 && self.searchingForServicesString != nil && self.initialWaitOver {
            return 1
        }
        
        return count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCellIdentifier = "UITableViewCell"
        var cell = tableView.dequeueReusableCellWithIdentifier(tableCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: tableCellIdentifier)
        }
        
        let count = self.services.count
        if count == 0 && self.searchingForServicesString != nil {
            // If there are no services and searchingForServicesString is set, show one row explaining that to the user.
            cell!.textLabel!.text = self.searchingForServicesString
            cell!.textLabel!.textColor = UIColor(white: 0.5, alpha: 0.5)
            cell!.accessoryType = UITableViewCellAccessoryType.None
            // Make sure to get rid of the activity indicator that may be showing if we were resolving cell zero but
            // then got didRemoveService callbacks for all services (e.g. the network connection went down).
            if cell!.accessoryView != nil {
                cell!.accessoryView = nil
            }
            return cell!
        }
        
        // Set up the text for the cell
        let service = self.services[indexPath.row]
        cell!.textLabel!.text = service.name
        cell!.textLabel!.textColor = UIColor.blackColor()
        cell!.accessoryType = self.showDisclosureIndicators ? .DisclosureIndicator : .None
        
        // Note that the underlying array could have changed, and we want to show the activity indicator on the correct cell
        if self.needsActivityIndicator && self.currentResolve === service {
            if cell!.accessoryView == nil {
                let frame = CGRectMake(0.0, 0.0, kProgressIndicatorSize, kProgressIndicatorSize)
                let spinner = UIActivityIndicatorView(frame: frame)
                spinner.startAnimating()
                spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
                spinner.sizeToFit()
                spinner.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin,
                    UIViewAutoresizing.FlexibleRightMargin,
                    UIViewAutoresizing.FlexibleTopMargin,
                    UIViewAutoresizing.FlexibleBottomMargin]
                cell!.accessoryView = spinner
            }
        } else if cell!.accessoryView != nil {
            cell!.accessoryView = nil
        }
        
        return cell!
    }
    
    
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        // Ignore the selection if there are no services as the searchingForServicesString cell
        // may be visible and tapping it would do nothing
        if self.services.isEmpty {
            return nil
        }
        
        return indexPath
    }
    
    
    private func stopCurrentResolve() {
        self.needsActivityIndicator = false
        self.timer = nil
        
        self.currentResolve?.stop()
        self.currentResolve = nil
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // If another resolve was running, stop it & remove the activity indicator from that cell
        if self.currentResolve != nil {
            // Get the indexPath for the active resolve cell
            
            // Stop the current resolve, which will also set self.needsActivityIndicator
            self.stopCurrentResolve()
            
            // If we found the indexPath for the row, reload that cell to remove the activity indicator
            if let indexRow = self.services.indexOf(self.currentResolve!) {
                let indexPath = NSIndexPath(forRow: indexRow, inSection: 0)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
        
        // Then set the current resolve to the service corresponding to the tapped cell
        self.currentResolve = self.services[indexPath.row]
        self.currentResolve!.delegate = self
        
        // Attempt to resolve the service. A value of 0.0 sets an unlimited time to resolve it. The user can
        // choose to cancel the resolve by selecting another service in the table view.
        self.currentResolve!.resolveWithTimeout(0.0)
        
        // Make sure we give the user some feedback that the resolve is happening.
        // We will be called back asynchronously, so we don't want the user to think we're just stuck.
        // We delay showing this activity indicator in case the service is resolved quickly.
        self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(BrowserViewController.showWaiting(_:)), userInfo: self.currentResolve, repeats: false)
    }
    
    
    // If necessary, sets up state to show an activity indicator to let the user know that a resolve is occuring.
    func showWaiting(timer: NSTimer) {
        if timer === self.timer {
            let service = self.timer!.userInfo as! NSNetService
            if self.currentResolve === service {
                self.needsActivityIndicator = true
                
                if let indexRow = self.services.indexOf(self.currentResolve!) {
                    let indexPath = NSIndexPath(forRow: indexRow, inSection: 0)
                    self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                    // Deselect the row since the activity indicator shows the user something is happening.
                    self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
                }
            }
        }
    }
    
    
    @objc(initialWaitOver:) func waitOver(timer: NSTimer) {
        self.initialWaitOver = true
        if self.services.isEmpty {
            self.tableView.reloadData()
        }
    }
    
    
    private func sortAndUpdateUI() {
        // Sort the services by name.
        self.services.sortInPlace {$0.name.localizedCaseInsensitiveCompare($1.name) == NSComparisonResult.OrderedAscending}
        self.tableView.reloadData()
    }
    
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveService service: NSNetService, moreComing: Bool) {
        // If a service went away, stop resolving it if it's currently being resolved,
        // remove it from the list and update the table view if no more events are queued.
        if self.currentResolve != nil && service == self.currentResolve! {
            self.stopCurrentResolve()
        }
        self.services.removeAtIndex(self.services.indexOf(service)!)
        
        // If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
        // When moreComing is set, we don't update the UI so that it doesn't 'flash'.
        if !moreComing {
            self.sortAndUpdateUI()
        }
    }
    
    
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindService service: NSNetService, moreComing: Bool) {
        // If a service came online, add it to the list and update the table view if no more events are queued.
        self.services.append(service)
        
        // If moreComing is NO, it means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
        // When moreComing is set, we don't update the UI so that it doesn't 'flash'.
        if !moreComing {
            self.sortAndUpdateUI()
        }
    }
    
    
    // This should never be called, since we resolve with a timeout of 0.0, which means indefinite
    func netService(sender: NSNetService, didNotResolve errorDict: [String : NSNumber]) {
        self.stopCurrentResolve()
        self.tableView.reloadData()
    }
    
    
    func netServiceDidResolveAddress(service: NSNetService) {
        assert(service === self.currentResolve)
        
        self.stopCurrentResolve()
        
        self.delegate?.browserViewController(self, didResolveInstance: service)
    }
    
    
    func cancelAction() {
        self.delegate?.browserViewController(self, didResolveInstance: nil)
    }
    
    
    deinit {
        // Cleanup any running resolve and free memory
        self.stopCurrentResolve()
        
        self.netServiceBrowser?.stop()
        
    }
    
    
}