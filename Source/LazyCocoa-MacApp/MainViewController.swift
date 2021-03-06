//
//  MainViewController.swift
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

class MainViewController: NSViewController {
	
	@IBOutlet weak var basePathTextField: NSTextField!
	
	@IBOutlet var tabView: NSTabView!
	
	var sourceEditVC:SourceEditViewController!
	var changeHeaderVC:ChangeHeaderViewController!
	
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		
		basePathTextField.enabled = false
		basePathTextField.delegate = self
		
		sourceEditVC = storyboard?.instantiateControllerWithIdentifier("SourceEditViewController") as? SourceEditViewController
		changeHeaderVC = storyboard?.instantiateControllerWithIdentifier("ChangeHeaderViewController") as? ChangeHeaderViewController
		
		for vc in [sourceEditVC, changeHeaderVC] {
			let item = NSTabViewItem(viewController: vc)
			tabView.insertTabViewItem(item, atIndex: tabView.numberOfTabViewItems)
		}
    }
	
	@IBAction func chooseBasePathButtonTapped(sender: AnyObject) {
		let openDialog = NSOpenPanel()
		
		openDialog.canChooseFiles = false
		openDialog.canChooseDirectories = true
		openDialog.canCreateDirectories = true
		openDialog.allowsMultipleSelection = false
		
		if openDialog.runModal() == NSModalResponseOK {
			if let url = openDialog.URLs.first as? NSURL {
				
				basePathTextField.stringValue = url.path!
				
				// Set the base path and force it to reload
				sourceEditVC.basePath = url.path!
				sourceEditVC.needsReload = true
				changeHeaderVC.basePath = url.path!
				changeHeaderVC.needsReload = true
			}
		}
	}
}

extension MainViewController : NSTextFieldDelegate {
	
	override func controlTextDidChange(obj: NSNotification) {
		
		changeHeaderVC.basePath = basePathTextField.stringValue
	}
}
