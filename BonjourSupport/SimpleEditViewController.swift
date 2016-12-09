//
//  SimpleEditViewController.swift
//  BonjourWeb
//
//  Translated by OOPer in cooperation with shlab.jp, on 2015/5/4.
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

import UIKit

@objc(SimpleEditViewControllerDelegate)
protocol SimpleEditViewControllerDelegate: NSObjectProtocol {
    // This method will be invoked when the user taps the 'Done' or 'Cancel' buttons.
    // The text parameter will be nil if the user taps the 'Cancel' button.
    func simpleEditViewController(_ sevc: SimpleEditViewController, didGetText text: String?)
}

@objc(SimpleEditViewController)
class SimpleEditViewController: UIViewController, UITextFieldDelegate {
    var cancelling: Bool = false
    
    var delegate: SimpleEditViewControllerDelegate?
    
    private var textField: UITextField!
    
    convenience init(title: String?, currentText current: String?) {
        
        self.init()
        self.title = title
        self.view.backgroundColor = UIColor.groupTableViewBackground
        
        // Add the "cancel" button to the navigation bar
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SimpleEditViewController.cancelAction))
        
        self.navigationItem.leftBarButtonItem = cancelButton
        
        let size = self.view.frame.size
        let rect = CGRect(x: 5, y: 70, width: size.width-10, height: 30)
        
        textField = UITextField(frame: rect)
        
        textField.text = current
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.textColor = UIColor.black
        textField.font = UIFont.systemFont(ofSize: 17.0)
        textField.backgroundColor = UIColor.clear
        textField.keyboardType = UIKeyboardType.URL
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextFieldViewMode.whileEditing
        
        textField.delegate = self
        
        self.view.addSubview(textField)
        
        textField.becomeFirstResponder()
        
        cancelling = false
        
    }
    
    
    @IBAction func cancelAction() {
        cancelling = true
        self.textField.resignFirstResponder()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === self.textField {
            self.delegate?.simpleEditViewController(self, didGetText: cancelling ? nil : self.textField.text)
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.textField {
            self.textField.resignFirstResponder()
        }
        return true
    }
    
    
}
