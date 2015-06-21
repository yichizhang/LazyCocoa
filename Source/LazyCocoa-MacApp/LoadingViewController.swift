//
//  LoadingViewController.swift
//  The Lazy Cocoa Project
//
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation
import Cocoa

protocol LoadingViewControllerDelegate {
	func loadingViewControllerCancelButtonTapped(vc:LoadingViewController)
}

class LoadingViewController : NSViewController {
	
	@IBOutlet weak var progressIndicator: NSProgressIndicator!
	var delegate:LoadingViewControllerDelegate?
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
		progressIndicator.startAnimation(self)
	}
	
	@IBAction func cancelButtonTapped(sender: AnyObject) {
		delegate?.loadingViewControllerCancelButtonTapped(self)
	}
}

protocol OptionsViewControllerDelegate {
	/**
	A button is tapped by the user.
	
	:param: vc The view controller.
	:param: response The response. Is equal to either NSModalResponseOK or NSModalResponseCancel.
	*/
	func optionsViewControllerButtonTapped(vc:OptionsViewController, response:Int)
}

class OptionsViewController : NSViewController {
	@IBOutlet weak var messageField: NSTextField!
	@IBOutlet weak var okButton: NSButton!
	@IBOutlet weak var cancelButton: NSButton!
	var delegate:OptionsViewControllerDelegate?
	
	override func viewDidAppear() {
		super.viewDidAppear()
		
	}
	
	@IBAction func okButtonTapped(sender: AnyObject) {
		
		delegate?.optionsViewControllerButtonTapped(self, response: NSModalResponseOK)
	}
	
	@IBAction func cancelButtonTapped(sender: AnyObject) {
		delegate?.optionsViewControllerButtonTapped(self, response: NSModalResponseCancel)
	}
}