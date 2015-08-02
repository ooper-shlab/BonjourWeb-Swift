//
//  DomainViewController.swift
//  BonjourWeb
//
//  Created by 開発 on 2015/5/4.
//
//
///*
//
//    File: DomainViewController.h
//    File: DomainViewController.m
//Abstract:  View controller for the domain list.
// This object manages a NSNetServiceBrowser configured to look for Bonjour
//domains.
// It has two arrays of NSString objects that are displayed in two sections of a
//table view.
// When the service browser reports that it has discovered a domain, that domain
//is added to the first array.
// When a domain goes away it is removed from the first array.
// It allows the user to add/remove their own domains from the second array, which
//is displayed in the second section of the table.
// When an item in the table view is selected, the delegate is called with the
//corresponding domain.
//
// Version: 2.9
//
//Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//Inc. ("Apple") in consideration of your agreement to the following
//terms, and your use, installation, modification or redistribution of
//this Apple software constitutes acceptance of these terms.  If you do
//not agree with these terms, please do not use, install, modify or
//redistribute this Apple software.
//
//In consideration of your agreement to abide by the following terms, and
//subject to these terms, Apple grants you a personal, non-exclusive
//license, under Apple's copyrights in this original Apple software (the
//"Apple Software"), to use, reproduce, modify and redistribute the Apple
//Software, with or without modifications, in source and/or binary forms;
//provided that if you redistribute the Apple Software in its entirety and
//without modifications, you must retain this notice and the following
//text and disclaimers in all such redistributions of the Apple Software.
//Neither the name, trademarks, service marks or logos of Apple Inc. may
//be used to endorse or promote products derived from the Apple Software
//without specific prior written permission from Apple.  Except as
//expressly stated in this notice, no other rights or licenses, express or
//implied, are granted by Apple herein, including but not limited to any
//patent rights that may be infringed by your derivative works or by other
//works in which the Apple Software may be incorporated.
//
//The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//POSSIBILITY OF SUCH DAMAGE.
//
//Copyright (C) 2010 Apple Inc. All Rights Reserved.
//
//
//*/
//
//#import <UIKit/UIKit.h>
import UIKit
//#import <Foundation/NSNetServices.h>
//#import "SimpleEditViewController.h"
//
//@class DomainViewController;
//
//@protocol DomainViewControllerDelegate <NSObject>
@objc(DomainViewControllerDelegate)
protocol DomainViewControllerDelegate: NSObjectProtocol {
//@required
//// This method will be invoked when the user selects one of the domains from the list.
//// The domain parameter will be the selected domain or nil if the user taps the 'Cancel' button (if shown)
//- (void) domainViewController:(DomainViewController*)dvc didSelectDomain:(NSString*)domain;
    func domainViewController(dvc: DomainViewController, didSelectDomain domain: String?)
//@end
}

extension UInt8 {
    var isdigit: Bool {
        return Darwin.isdigit(Int32(self)) != 0
    }
}
//
//@interface DomainViewController : UITableViewController <SimpleEditViewControllerDelegate, NSNetServiceBrowserDelegate> {
@objc(DomainViewController)
class DomainViewController: UITableViewController,SimpleEditViewControllerDelegate, NSNetServiceBrowserDelegate {
//	id<DomainViewControllerDelegate> _delegate;
//	BOOL _showDisclosureIndicators;
//	NSMutableArray* _domains;
//	NSMutableArray* _customs;
//	NSString* _customTitle;
//	NSString* _addDomainTitle;
//	NSNetServiceBrowser* _netServiceBrowser;
//	BOOL _showCancelButton;
//}
//
//@property(nonatomic, assign) id<DomainViewControllerDelegate> delegate;
    var delegate: DomainViewControllerDelegate?
//
//- (id)initWithTitle:(NSString *)title showDisclosureIndicators:(BOOL)showDisclosureIndicators customsTitle:(NSString*)customsTitle customs:(NSMutableArray*)customs addDomainTitle:(NSString*)addDomainTitle showCancelButton:(BOOL)showCancelButton;
//- (BOOL)searchForBrowsableDomains;
//- (BOOL)searchForRegistrationDomains;
//
//@end
//
//#import "DomainViewController.h"
//
//#define kProgressIndicatorSize 20.0
//
//@interface DomainViewController ()
//@property(nonatomic, assign) BOOL showDisclosureIndicators;
    private var showDisclosureIndicators: Bool = false
//@property(nonatomic, retain) NSMutableArray* domains;
    private var domains: [String] = []
//@property(nonatomic, retain) NSMutableArray* customs;
    private var customs: [String] = []
//@property(nonatomic, retain) NSString* customTitle;
    private var customTitle: String!
//@property(nonatomic, retain) NSString* addDomainTitle;
    private var addDomainTitle: String!
//@property(nonatomic, retain) NSNetServiceBrowser* netServiceBrowser;
    private var netServiceBrowser: NSNetServiceBrowser? {
        willSet {
            willSetNetServiceBrowser(newValue)
        }
    }
//@property(nonatomic, assign) BOOL showCancelButton;
    private var showCancelButton: Bool = false
//
//- (void)addButtons:(BOOL)editing;
//- (void)addAction:(id)sender;
//- (void)editAction:(id)sender;
//@end
//
//@implementation DomainViewController
//
//@synthesize delegate = _delegate;
//@synthesize showDisclosureIndicators = _showDisclosureIndicators;
//@synthesize domains = _domains;
//@synthesize customs = _customs;
//@synthesize customTitle = _customTitle;
//@synthesize addDomainTitle = _addDomainTitle;
//@dynamic netServiceBrowser;
//@synthesize showCancelButton = _showCancelButton;
//
//// Initialization. BonjourBrowser invokes this during its initialization.
//- (id)initWithTitle:(NSString*)title showDisclosureIndicators:(BOOL)show customsTitle:(NSString*)customsTitle customs:(NSMutableArray*)customs addDomainTitle:(NSString*)addDomainTitle showCancelButton:(BOOL)showCancelButton {
    init(title: String, showDisclosureIndicators show: Bool, customsTitle: String, customs: [String]?,addDomainTitle: String, showCancelButton: Bool) {
//	if ((self = [super initWithStyle:UITableViewStylePlain])) {
        super.init(style: .Plain)
//		self.title = title;
        self.title = title
//		self.domains = [[[NSMutableArray alloc] init] autorelease];
//		self.showDisclosureIndicators = show;
        self.showDisclosureIndicators = show
//		self.customTitle = customsTitle;
        self.customTitle = customsTitle
//		self.customs = customs ? customs : [NSMutableArray array];
        self.customs = customs ?? []
//		self.addDomainTitle = addDomainTitle;
        self.addDomainTitle = addDomainTitle
//		self.showCancelButton = showCancelButton;
        self.showCancelButton = showCancelButton
//		[self addButtons:self.tableView.editing];
        self.addButtons(self.tableView.editing)
//	}
//
//	return self;
//}
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init!(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
//
//// Stores newBrowser in the _netServiceBrowser instance variable. If _netServiceBrowser has already been set,
//// this first sends it a -stop message before releasing it.
//- (void)setNetServiceBrowser:(NSNetServiceBrowser*)newBrowser {
    private func willSetNetServiceBrowser(newBrowser: NSNetServiceBrowser?) {
//	[_netServiceBrowser stop];
        netServiceBrowser?.stop()
//	[newBrowser retain];
//	[_netServiceBrowser release];
//	_netServiceBrowser = newBrowser;
//}
    }
//
//
//- (NSNetServiceBrowser*)netServiceBrowser {
//	return _netServiceBrowser;
//}
//
//
//- (void)addAddButton:(BOOL)right {
    private func addAddButton(right: Bool) {
//	// add + button as the nav bar's custom right view
//	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addAction:")
//								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction:)];
//	if (right) self.navigationItem.rightBarButtonItem = addButton;
        if right {self.navigationItem.rightBarButtonItem = addButton}
//	else self.navigationItem.leftBarButtonItem = addButton;
        else {self.navigationItem.leftBarButtonItem = addButton}
//	[addButton release];
//}
    }
//
//- (void)addButtons:(BOOL)editing {
    private func addButtons(editing: Bool) {
//	if (editing) {
        if editing {
//		// Add the "done" button to the navigation bar
//		UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneAction:")
//									   initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
//
//		self.navigationItem.leftBarButtonItem = doneButton;
            self.navigationItem.leftBarButtonItem = doneButton
//		[doneButton release];
//
//		[self addAddButton:YES];
            self.addAddButton(true)
//	} else {
        } else {
//		if ([self.customs count]) {
            if !self.customs.isEmpty {
//			// Add the "edit" button to the navigation bar
//			UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
                let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editAction:")
//										   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editAction:)];
//
//			self.navigationItem.leftBarButtonItem = editButton;
                self.navigationItem.leftBarButtonItem = editButton
//			[editButton release];
//		} else {
            } else {
//			[self addAddButton:NO];
                self.addAddButton(false)
//		}
            }
//
//		if (self.showCancelButton) {
            if self.showCancelButton {
//			// add Cancel button as the nav bar's custom right view
//			UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                let addButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAction")
//										  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
//			self.navigationItem.rightBarButtonItem = addButton;
                self.navigationItem.rightBarButtonItem = addButton
//			[addButton release];
//		} else {
            } else {
//			self.navigationItem.rightBarButtonItem = nil;
                self.navigationItem.rightBarButtonItem = nil
//		}
            }
//	}
        }
//}
    }
//
//- (BOOL)commonSetup {
    private func commonSetup() -> Bool {
//	self.netServiceBrowser = [[[NSNetServiceBrowser alloc] init] autorelease];
        self.netServiceBrowser = NSNetServiceBrowser()
//	if(!self.netServiceBrowser) {
        if self.netServiceBrowser == nil {
//		return NO;
            return false
//	}
        }
//
//	[self.netServiceBrowser setDelegate:self];
        self.netServiceBrowser!.delegate = self
//	return YES;
        return true
//}
    }
//
//// A cover method to -[NSNetServiceBrowser searchForBrowsableDomains].
//- (BOOL)searchForBrowsableDomains {
    func searchForBrowsableDomains() -> Bool {
//	if (![self commonSetup]) return NO;
        if !self.commonSetup() {return false}
//	[self.netServiceBrowser searchForBrowsableDomains];
        self.netServiceBrowser!.searchForBrowsableDomains()
//	return YES;
        return true
//}
    }
//
//// A cover method to -[NSNetServiceBrowser searchForRegistrationDomains].
//- (BOOL)searchForRegistrationDomains {
    func searchForRegistrationDomains() -> Bool {
//	if (![self commonSetup]) return NO;
        if !self.commonSetup() {return false}
//	[self.netServiceBrowser searchForRegistrationDomains];
        self.netServiceBrowser!.searchForRegistrationDomains()
//	return YES;
        return true
//}
    }
//
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//	return 1 + ([self.customs count] ? 1 : 0);
        return 1 + (!self.customs.isEmpty ? 1 : 0)
//}
    }
//
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//	return [(section ? self.customs : self.domains) count];
        return (section != 0 ? self.customs : self.domains).count
//}
    }
//
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//	return section ? self.customTitle : @"Bonjour"; // Note that "Bonjour" is the proper name of the technology, therefore should not be localized
        return section != 0 ? self.customTitle : "Bonjour" // Note that "Bonjour" is the proper name of the technology, therefore should not be localized
//}
    }
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//	UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
        var cell = tableView.dequeueReusableCellWithIdentifier("UITableViewCell") 
//	if (cell == nil) {
        if cell == nil {
//		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"] autorelease];
            cell = UITableViewCell(style: .Default, reuseIdentifier: "UITableViewCell")
//	}
        }
//
//	// Set up the text for the cell
//	cell.textLabel.text = [(indexPath.section ? self.customs : self.domains) objectAtIndex:indexPath.row];
        cell!.textLabel!.text = (indexPath.section != 0 ? self.customs : self.domains)[indexPath.row]
//	cell.textLabel.textColor = [UIColor blackColor];
        cell!.textLabel!.textColor = UIColor.blackColor()
//	cell.accessoryType = self.showDisclosureIndicators ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        cell!.accessoryType = self.showDisclosureIndicators ? .DisclosureIndicator : .None
//	return cell;
        return cell!
//}
    }
//
//
//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//	return indexPath.section && tableView.editing;
        return indexPath.section != 0 && tableView.editing
//}
    }
//
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//	[self.delegate domainViewController:self didSelectDomain:[(indexPath.section ? self.customs : self.domains) objectAtIndex:indexPath.row]];
        self.delegate?.domainViewController(self, didSelectDomain: (indexPath.section != 0 ? self.customs : self.domains)[indexPath.row])
//}
    }
//
//
//- (void)updateUI {
    private func updateUI() {
//	// Sort the domains by name, then modify the selection, as it may have moved
//	[self.domains sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        self.domains.sortInPlace {$0.localizedCaseInsensitiveCompare($1) == .OrderedAscending}
//	[self.tableView reloadData];
        self.tableView.reloadData()
//}
    }
//
///*
//    The 'domain' parameter passed to netServiceBrowser:didRemoveDomain:moreComing: and netServiceBrowser:didFindDomain:moreComing: may contain escaped characters. This function unescapes them before they are added to or removed from the list that is displayed to the user.
//*/
//- (NSString*) transmogrify:(NSString*)aString {
    private func transmogrify(aString: String) -> String {
//
//	NSString* tmp = [NSString stringWithString:aString];
        let buflen = aString.utf8.count + 1
        let ostr: UnsafeMutablePointer<CChar> = aString.withCString {tmp in
//	const char *ostr = [tmp UTF8String];
            let ostr = UnsafeMutablePointer<CChar>.alloc(buflen)
//	const char *cstr = ostr;
            var cstr = UnsafePointer<UInt8>(tmp)
//	char *ptr = (char*) ostr;
            var ptr = UnsafeMutablePointer<UInt8>(ostr)
//
//	while (*cstr) {
            while cstr.memory != 0 {
//		char c = *cstr++;
                var c = (cstr++).memory
//		if (c == '\\')
//		{
                if c == UInt8(ascii: "\\") {
//			c = *cstr++;
                    c = (cstr++).memory
//			if (isdigit(cstr[-1]) && isdigit(cstr[0]) && isdigit(cstr[1]))
//			{
                    if cstr[-1].isdigit && cstr[0].isdigit && cstr[1].isdigit {
//				NSInteger v0 = cstr[-1] - '0';						// then interpret as three-digit decimal
                        let v0 = cstr[-1] - UInt8(ascii: "0")						// then interpret as three-digit decimal
//				NSInteger v1 = cstr[ 0] - '0';
                        let v1 = cstr[ 0] - UInt8(ascii: "0")
//				NSInteger v2 = cstr[ 1] - '0';
                        let v2 = cstr[ 1] - UInt8(ascii: "0")
//				NSInteger val = v0 * 100 + v1 * 10 + v2;
                        let val = v0 * 100 + v1 * 10 + v2
//				if (val <= 255) { c = (char)val; cstr += 2; }	// If valid three-digit decimal value, use it
                        if (val <= 255) { c = UInt8(val); cstr += 2; }	// If valid three-digit decimal value, use it
//			}
                    }
//		}
                }
//		*ptr++ = c;
                (ptr++).memory = c
//	}
            }
//	ptr--;
            ptr--
//	*ptr = 0;
            ptr.memory = 0
            return ostr
        }
//	return [NSString stringWithUTF8String:ostr];
        let result = String.fromCString(ostr)!
        ostr.dealloc(buflen)
        return result
//}
    }
//
//
//- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didRemoveDomain:(NSString*)domain moreComing:(BOOL)moreComing {
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didRemoveDomain domain: String, moreComing: Bool) {
//	[self.domains removeObject:[self transmogrify:domain]];
        self.domains.removeAtIndex(self.domains.indexOf(transmogrify(domain))!)
//
//	// moreComing really means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
//	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
//	if (!moreComing)
        if !moreComing {
//		[self updateUI];
            self.updateUI()
        }
//}
    }
//
//
//- (void)netServiceBrowser:(NSNetServiceBrowser*)netServiceBrowser didFindDomain:(NSString*)domain moreComing:(BOOL)moreComing {
    func netServiceBrowser(aNetServiceBrowser: NSNetServiceBrowser, didFindDomain domain: String, moreComing: Bool) {
//	NSString* tmp = [self transmogrify:domain];
        let tmp = self.transmogrify(domain)
//	if (![self.domains containsObject:tmp]) [self.domains addObject:tmp];
        if !self.domains.contains(tmp) {self.domains.append(tmp)}
//
//	// moreComing really means that there are no more messages in the queue from the Bonjour daemon, so we should update the UI.
//	// When moreComing is set, we don't update the UI so that it doesn't 'flash'.
//	if (!moreComing)
        if !moreComing {
//		[self updateUI];
            self.updateUI()
        }
//}
    }
//
//
//- (void)doneAction:(id)sender {
    func doneAction(_: AnyObject) {
//	[self.tableView setEditing:NO animated:YES];
        self.tableView.setEditing(false, animated: true)
//	[self addButtons:self.tableView.editing];
        self.addButtons(self.tableView.editing)
//}
    }
//
//
//- (void)editAction:(id)sender {
    func editAction(_: AnyObject) {
//	[self.tableView setEditing:YES animated:YES];
        self.tableView.setEditing(true, animated: true)
//	[self addButtons:self.tableView.editing];
        self.addButtons(self.tableView.editing)
//}
    }
//
//
//- (IBAction)cancelAction {
    @IBAction func cancelAction() {
//	[self.delegate domainViewController:self didSelectDomain:nil];
        self.delegate?.domainViewController(self, didSelectDomain: nil)
//}
    }
//
//
//- (void)addAction:(id)sender {
    func addAction(_: AnyObject) {
//	SimpleEditViewController* sevc = [[SimpleEditViewController alloc] initWithTitle:self.addDomainTitle currentText:nil];
        let sevc = SimpleEditViewController(title: self.addDomainTitle, currentText: nil)
//	[sevc setDelegate:self];
        sevc.delegate = self
//	UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:sevc];
        let nc = UINavigationController(rootViewController: sevc)
//	[sevc release];
//	[self.navigationController presentModalViewController:nc animated:YES];
        self.navigationController!.presentViewController(nc, animated: true, completion: nil)
//	[nc release];
//}
    }
//
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//	assert(editingStyle == UITableViewCellEditingStyleDelete);
        assert(editingStyle == UITableViewCellEditingStyle.Delete)
//	assert(indexPath.section == 1);
        assert(indexPath.section == 1)
//	[self.customs removeObjectAtIndex:indexPath.row];
        self.customs.removeAtIndex(indexPath.row)
//	if (![self.customs count]) {
        if self.customs.isEmpty {
//		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationRight];
            self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Right)
//	} else {
        } else {
//		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
//	}
        }
//	[self addButtons:self.tableView.editing];
        self.addButtons(self.tableView.editing)
//}
    }
//
//
//- (void) simpleEditViewController:(SimpleEditViewController*)sevc didGetText:(NSString*)text {
    func simpleEditViewController(sevc: SimpleEditViewController, didGetText text: String?) {
//	[self.navigationController dismissModalViewControllerAnimated:YES];
        self.navigationController!.dismissViewControllerAnimated(true, completion: nil)
//
//	if (![text length])
        if text?.isEmpty ?? true {
//		return;
            return
        }
//
//	if (![self.customs containsObject:text]) {
        if !self.customs.contains((text!)) {
//		[self.customs addObject:text];
            self.customs.append(text!)
//		[self.customs sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            self.customs.sortInPlace {$0.localizedCaseInsensitiveCompare($1) == .OrderedAscending}
//	}
        }
//
//	[self addButtons:self.tableView.editing];
        self.addButtons(self.tableView.editing)
//	[self.tableView reloadData];
        self.tableView.reloadData()
//	NSUInteger ints[2] = {1,[self.customs indexOfObject:text]};
        let ints = [1, self.customs.indexOf((text!))!]
//	NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ints length:2];
        let indexPath = NSIndexPath(indexes: ints, length: 2)
//	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
        self.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .None, animated: true)
//}
    }
//
//
//- (void)dealloc {
//	[_domains release];
//	[_customs release];
//	[_customTitle release];
//	[_addDomainTitle release];
//	[_netServiceBrowser release];
//
//	[super dealloc];
//}
//
//@end
}