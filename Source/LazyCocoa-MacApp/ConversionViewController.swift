//
//  ConversionViewController.swift
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

import Cocoa

class ConversionViewController: NSViewController {
    
    @IBOutlet var sourceTextView: NSTextView!
    @IBOutlet var resultTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		updateUserInterfaceSettings()
	}
	
	func updateUserInterfaceSettings() {
		
		sourceTextView.setUpForDisplayingSourceCode()
		resultTextView.setUpForDisplayingSourceCode()
		
		resultTextView.editable = false
	}
	
    @IBAction func convertButtonTapped(sender: AnyObject) {
        
        if let source = sourceTextView.string {
			
            resultTextView.string = ColorScanner.resultStringFrom(source)
        }
    }
	
	@IBAction func questionButtonTapped(sender: AnyObject) {
		
		let alert = NSAlert()
		alert.messageText =
			"How to use this functionality? \n" +
			"It can convert code like: \n\n" +
			String.stringInBundle(name:"ColorScannerDemo")! +
			"\n\nTo:\n" +
			"awesomeColor #F28EB0FF\ncustomBlueColor #70A8CDFF"
		alert.runModal()
	}
	
	@IBAction func closeButtonTapped(sender: AnyObject) {
		dismissController(nil)
	}
}