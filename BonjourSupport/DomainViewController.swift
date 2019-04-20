//
//  DomainViewController.swift
//  BonjourWeb
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/5/4.
//
//
/*

    File: DomainViewController.h
    File: DomainViewController.m
Abstract:  View controller for the domain list.
 This object manages a NSNetServiceBrowser configured to look for Bonjour
domains.
 It has two arrays of NSString objects that are displayed in two sections of a
table view.
 When the service browser reports that it has discovered a domain, that domain
is added to the first array.
 When a domain goes away it is removed from the first array.
 It allows the user to add/remove their own domains from the second array, which
is displayed in the second section of the table.
 When an item in the table view is selected, the delegate is called with the
corresponding domain.

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

@objc(DomainViewControllerDelegate)
protocol DomainViewControllerDelegate: NSObjectProtocol {
    // This method will be invoked when the user selects one of the domains from the list.
    // The domain parameter will be the selected domain or nil if the user taps the 'Cancel' button (if shown)
    func domainViewController(_ dvc: DomainViewController, didSelectDomain domain: String?)
}

extension UInt8 {
    var isdigit: Bool {
        return Darwin.isdigit(Int32(self)) != 0
    }
}

@objc(DomainViewController)
class DomainViewController: UITableViewController,SimpleEditViewControllerDelegate, NetServiceBrowserDelegate {
    
    var delegate: DomainViewControllerDelegate?
    
    private var showDisclosureIndicators: Bool = false
    private var domains: [String] = []
    private var customs: [String] = []
    private var customTitle: String!
    private var addDomainTitle: String!
    private var netServiceBrowser: NetServiceBrowser? {
        willSet {
            willSetNetServiceBrowser(newValue)
        }
    }
    private var showCancelButton: Bool = false
    
    // Initialization. BonjourBrowser invokes this during its initialization.
    init(title: String, showDisclosureIndicators show: Bool, customsTitle: String, customs: [String]?,addDomainTitle: String, showCancelButton: Bool) {
        super.init(style: .plain)
        self.title = title
        self.showDisclosureIndicators = show
        self.customTitle = customsTitle
        self.customs = customs ?? []
        self.addDomainTitle = addDomainTitle
        self.showCancelButton = showCancelButton
        self.addButtons(self.tableView.isEditing)
        
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Stores newBrowser in the _netServiceBrowser instance variable. If _netServiceBrowser has already been set,
    // this first sends it a -stop message before releasing it.
    private func willSetNetServiceBrowser(_ newBrowser: NetServiceBrowser?) {
        netServiceBrowser?.stop()
    }
    
    
    private func addAddButton(_ right: Bool) {
        // add + button as the nav bar's custom right view
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction(_:)))
        if right {self.navigationItem.rightBarButtonItem = addButton}
        else {self.navigationItem.leftBarButtonItem = addButton}
    }
    
    private func addButtons(_ editing: Bool) {
        if editing {
            // Add the "done" button to the navigation bar
            let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneAction(_:)))
            
            self.navigationItem.leftBarButtonItem = doneButton
            
            self.addAddButton(true)
        } else {
            if !self.customs.isEmpty {
                // Add the "edit" button to the navigation bar
                let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction(_:)))
                
                self.navigationItem.leftBarButtonItem = editButton
            } else {
                self.addAddButton(false)
            }
            
            if self.showCancelButton {
                // add Cancel button as the nav bar's custom right view
                let addButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(DomainViewController.cancelAction))
                self.navigationItem.rightBarButtonItem = addButton
            } else {
                self.navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    private func commonSetup() -> Bool {
        self.netServiceBrowser = NetServiceBrowser()
        if self.netServiceBrowser == nil {
            return false
        }
        
        self.netServiceBrowser!.delegate = self
        return true
    }
    
    // A cover method to -[NSNetServiceBrowser searchForBrowsableDomains].
    @discardableResult func searchForBrowsableDomains() -> Bool {
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForBrowsableDomains()
        return true
    }
    
    // A cover method to -[NSNetServiceBrowser searchForRegistrationDomains].
    func searchForRegistrationDomains() -> Bool {
        if !self.commonSetup() {return false}
        self.netServiceBrowser!.searchForRegistrationDomains()
        return true
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + (!self.customs.isEmpty ? 1 : 0)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section != 0 ? self.customs : self.domains).count
    }
    
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section != 0 ? self.customTitle : "Bonjour" // Note that "Bonjour" is the proper name of the technology, therefore should not be localized
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        }
        
        // Set up the text for the cell
        cell!.textLabel!.text = (indexPath.section != 0 ? self.customs : self.domains)[indexPath.row]
        cell!.textLabel!.textColor = UIColor.black
        cell!.accessoryType = self.showDisclosureIndicators ? .disclosureIndicator : .none
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0 && tableView.isEditing
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.domainViewController(self, didSelectDomain: (indexPath.section != 0 ? self.customs : self.domains)[indexPath.row])
    }
    
    
    private func updateUI() {
        // Sort the domains by name, then modify the selection, as it may have moved
        self.domains.sort {$0.localizedCaseInsensitiveCompare($1) == .orderedAscending}
        self.tableView.reloadData()
    }
    
    /*
     The 'domain' parameter passed to netServiceBrowser:didRemoveDomain:moreComing: and netServiceBrowser:didFindDomain:moreComing: may contain escaped characters. This function unescapes them before they are added to or removed from the list that is displayed to the user.
     */
    private func transmogrify(_ aString: String) -> String {
        
        let buflen = aString.utf8.count + 1
        let ostr: UnsafeMutablePointer<CChar> = aString.withCString {tmp in
            let ostr = UnsafeMutablePointer<CChar>.allocate(capacity: buflen)
            var cstr = UnsafeRawPointer(tmp).assumingMemoryBound(to: UInt8.self)
            var ptr = UnsafeMutableRawPointer(ostr).assumingMemoryBound(to: UInt8.self)
            
            while cstr.pointee != 0 {
                var c = cstr.pointee
                cstr += 1
                if c == UInt8(ascii: "\\") {
                    c = cstr.pointee
                    cstr += 1
                    if cstr[-1].isdigit && cstr[0].isdigit && cstr[1].isdigit {
                        let v0 = cstr[-1] - UInt8(ascii: "0")						// then interpret as three-digit decimal
                        let v1 = cstr[ 0] - UInt8(ascii: "0")
                        let v2 = cstr[ 1] - UInt8(ascii: "0")
                        let val = v0 * 100 + v1 * 10 + v2
                        if (val <= 255) { c = UInt8(val); cstr += 2; }	// If valid three-digit decimal value, use it
                    }
                }
                ptr.pointee = c
                ptr += 1
            }
            ptr -= 1
            ptr.pointee = 0
            return ostr
        }
        let result = String(cString: ostr)
        ostr.deallocate()
        return result
    }
    
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didRemoveDomain domain: String, moreComing: Bool) {
        self.domains.remove(at: self.domains.firstIndex(of: transmogrify(domain))!)
        
        // moreComing really means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
        // When moreComing is set, we don't update the UI so that it doesn't 'flash'.
        if !moreComing {
            self.updateUI()
        }
    }
    
    
    func netServiceBrowser(_ aNetServiceBrowser: NetServiceBrowser, didFindDomain domain: String, moreComing: Bool) {
        let tmp = self.transmogrify(domain)
        if !self.domains.contains(tmp) {self.domains.append(tmp)}
        
        // moreComing really means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
        // When moreComing is set, we don't update the UI so that it doesn't 'flash'.
        if !moreComing {
            self.updateUI()
        }
    }
    
    
    @objc func doneAction(_: AnyObject) {
        self.tableView.setEditing(false, animated: true)
        self.addButtons(self.tableView.isEditing)
    }
    
    
    @objc func editAction(_: AnyObject) {
        self.tableView.setEditing(true, animated: true)
        self.addButtons(self.tableView.isEditing)
    }
    
    
    @IBAction func cancelAction() {
        self.delegate?.domainViewController(self, didSelectDomain: nil)
    }
    
    
    @objc func addAction(_: AnyObject) {
        let sevc = SimpleEditViewController(title: self.addDomainTitle, currentText: nil)
        sevc.delegate = self
        let nc = UINavigationController(rootViewController: sevc)
        self.navigationController!.present(nc, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        assert(editingStyle == .delete)
        assert(indexPath.section == 1)
        self.customs.remove(at: indexPath.row)
        if self.customs.isEmpty {
            self.tableView.deleteSections(IndexSet(integer: 1), with: .right)
        } else {
            self.tableView.deleteRows(at: [indexPath], with: .right)
        }
        self.addButtons(self.tableView.isEditing)
    }
    
    
    func simpleEditViewController(_ sevc: SimpleEditViewController, didGetText text: String?) {
        self.navigationController!.dismiss(animated: true, completion: nil)
        
        if text?.isEmpty ?? true {
            return
        }
        
        if !self.customs.contains(text!) {
            self.customs.append(text!)
            self.customs.sort {$0.localizedCaseInsensitiveCompare($1) == .orderedAscending}
        }
        
        self.addButtons(self.tableView.isEditing)
        self.tableView.reloadData()
        let ints = [1, self.customs.firstIndex(of: text!)!]
        let indexPath = IndexPath(indexes: ints)
        self.tableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
    
    
}
