//
//  OptionsView.swift
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

protocol OptionsViewDelegate : class {
	/**
	A button is tapped by the user.
	
	- parameter vc: The view controller.
	- parameter response: The response. Is equal to either NSModalResponseOK or NSModalResponseCancel.
	*/
	func optionsViewButtonTapped(_ v:OptionsView, response:Int)
}

class OptionsView : NSView {
	@IBOutlet weak var messageField: NSTextField!
	@IBOutlet weak var okButton: NSButton!
	@IBOutlet weak var cancelButton: NSButton!
	weak var delegate:OptionsViewDelegate?
	
	@IBAction func okButtonTapped(_ sender: AnyObject) {
		
		delegate?.optionsViewButtonTapped(self, response: NSModalResponseOK)
	}
	
	@IBAction func cancelButtonTapped(_ sender: AnyObject) {
		delegate?.optionsViewButtonTapped(self, response: NSModalResponseCancel)
	}
}
