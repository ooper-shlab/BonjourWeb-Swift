//
//  SimpleEditViewController.swift
//  BonjourWeb
//
//  Created by 開発 on 2015/5/4.
//
//
///*
//    File: SimpleEditViewController.h
//    File: SimpleEditViewController.m
//Abstract: View controller which allows the user to enter a small amount of text.
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
//*/
//
//#import <UIKit/UIKit.h>
import UIKit
//
//@class SimpleEditViewController;
//
//@protocol SimpleEditViewControllerDelegate <NSObject>
@objc(SimpleEditViewControllerDelegate)
protocol SimpleEditViewControllerDelegate: NSObjectProtocol {
//@required
//// This method will be invoked when the user taps the 'Done' or 'Cancel' buttons.
//// The text parameter will be nil if the user taps the 'Cancel' button.
//- (void) simpleEditViewController:(SimpleEditViewController*)sevc didGetText:(NSString*)text;
    func simpleEditViewController(sevc: SimpleEditViewController, didGetText text: String?)
//@end
}
//
@objc(SimpleEditViewController)
class SimpleEditViewController: UIViewController, UITextFieldDelegate {
//@interface SimpleEditViewController : UIViewController <UITextFieldDelegate> {
//	id<SimpleEditViewControllerDelegate> _delegate;
//	UITextField* _textField;
//	BOOL cancelling;
    var cancelling: Bool = false
//}
//
//@property(nonatomic, assign) id<SimpleEditViewControllerDelegate> delegate;
    var delegate: SimpleEditViewControllerDelegate?
//
//- (id)initWithTitle:(NSString*)title currentText:(NSString*)current;
//
//@end
//
//#import "SimpleEditViewController.h"
//
//@interface SimpleEditViewController ()
//@property(nonatomic, retain) UITextField* textField;
    private var textField: UITextField!
//@end
//
//@implementation SimpleEditViewController
//
//@synthesize delegate = _delegate;
//@synthesize textField = _textField;
//
//- (id)initWithTitle:(NSString*)title currentText:(NSString*)current {
    convenience init(title: String?, currentText current: String?) {
//
//	if ((self = [super init])) {
        self.init()
//		self.title = title;
        self.title = title
//		self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        self.view.backgroundColor = UIColor.groupTableViewBackgroundColor()
//
//		// Add the "cancel" button to the navigation bar
//		UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: #selector(SimpleEditViewController.cancelAction))
//									   initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction)];
//
//		self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.leftBarButtonItem = cancelButton
//		[cancelButton release];
//
//		CGSize size = self.view.frame.size;
        let size = self.view.frame.size
//		CGRect rect = CGRectMake(5, 5, size.width-10, 30);
        let rect = CGRectMake(5, 70, size.width-10, 30)
//
//		_textField = [[UITextField alloc] initWithFrame:rect];
        textField = UITextField(frame: rect)
//
//		_textField.text = current;
        textField.text = current
//		_textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.autocorrectionType = UITextAutocorrectionType.No
//		_textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocapitalizationType = UITextAutocapitalizationType.None
//		_textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.borderStyle = UITextBorderStyle.RoundedRect
//		_textField.textColor = [UIColor blackColor];
        textField.textColor = UIColor.blackColor()
//		_textField.font = [UIFont systemFontOfSize:17.0];
        textField.font = UIFont.systemFontOfSize(17.0)
//		_textField.backgroundColor = [UIColor clearColor];
        textField.backgroundColor = UIColor.clearColor()
//		_textField.keyboardType = UIKeyboardTypeURL;
        textField.keyboardType = UIKeyboardType.URL
//		_textField.returnKeyType = UIReturnKeyDone;
        textField.returnKeyType = UIReturnKeyType.Done
//		_textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.clearButtonMode = UITextFieldViewMode.WhileEditing
//
//		_textField.delegate = self;
        textField.delegate = self
//
//		[self.view addSubview:_textField];
        self.view.addSubview(textField)
//
//		[_textField becomeFirstResponder];
        textField.becomeFirstResponder()
//
//		cancelling = NO;
        cancelling = false
//	}
//
//	return self;
//}
    }
//
//
//- (IBAction)cancelAction {
    @IBAction func cancelAction() {
//	cancelling = YES;
        cancelling = true
//	[self.textField resignFirstResponder];
        self.textField.resignFirstResponder()
//}
    }
//
//
//- (void)textFieldDidEndEditing:(UITextField *)textField {
    func textFieldDidEndEditing(textField: UITextField) {
//	if (textField == self.textField) {
        if textField === self.textField {
//		[self.delegate simpleEditViewController:self didGetText:cancelling ? nil : self.textField.text];
            self.delegate?.simpleEditViewController(self, didGetText: cancelling ? nil : self.textField.text)
//	}
        }
//}
    }
//
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
//	if (textField == self.textField) {
        if textField === self.textField {
//		[self.textField resignFirstResponder];
            self.textField.resignFirstResponder()
//	}
        }
//	return YES;
        return true
//}
    }
//
//
//- (void)dealloc {
//	[_textField release];
//	[super dealloc];
//}
//
//
//@end
//
}