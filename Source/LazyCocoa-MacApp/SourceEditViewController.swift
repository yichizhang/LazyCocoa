//
//  SourceEditViewController.swift
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
import AppKit

class SourceEditViewController: NSViewController {
	
	var basePath:String? = nil {
		didSet {
			openBasePath(basePath)
		}
	}
	
	var prog = MainProgram()
	var optionsVC:OptionsViewController?
	
	@IBOutlet var sourceFileTextView: NSTextView!
	@IBOutlet private var mainGeneratedCodeTextView: NSTextView!
	
	@IBOutlet weak var filePopUpButton: NSPopUpButtonCell!
	var filePopUpLastSelectedIndex = Int(0)
	
	@IBOutlet weak var saveButton: NSButton!
	@IBOutlet weak var showHelpButton: NSButton!
	@IBOutlet weak var showParseColorButton: NSButton!
	@IBOutlet weak var updateButton: NSButton!
	@IBOutlet weak var exportButton: NSButton!
	
	var analyzer: DocumentAnalyzer = DocumentAnalyzer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		title = "Source Editor"
		sourceFileTextView.setUpForDisplayingSourceCode()
		
		sourceFileTextView.lnv_setUpLineNumberView()
		sourceFileTextView.delegate = self
		
		openBasePath(basePath)
	}
	
	func openBasePath(basePath:String?) {
		var error:NSError?
		var success = false
		
		if let basePath = basePath {
			if let string = prog.lazyfileString(basePath: basePath, error: &error) {
				
				sourceFileTextView.string = string
				sourceFileTextView.lnv_updateLineNumberView(nil)
				updateDocumentsAndUserInterface()
			}
			
			if error != nil {
				
				optionsVC?.view.removeFromSuperview()
				optionsVC = storyboard?.instantiateControllerWithIdentifier("OptionsViewController") as? OptionsViewController
				
				if let vc = optionsVC {
					
					vc.delegate = self
					
					let layer = CALayer()
					layer.backgroundColor = NSColor.windowBackgroundColor().CGColor
					
					vc.view.wantsLayer = true
					vc.view.layer = layer
					vc.view.frame = NSRect(origin: CGPointZero, size: self.view.frame.size)
					
					self.view.addSubview(vc.view, positioned: NSWindowOrderingMode.Above, relativeTo: nil)
					vc.view.viewDidMoveToWindow()
					vc.messageField.stringValue = "Would you like to create a new Lazyfile?"
				}

				
				if error!.code == ErrorCode.FileIsDir {
					let alert = NSAlert()
					alert.messageText = error!.localizedDescription
					alert.runModal()
					
				} else if error!.code == ErrorCode.FileNotExist {
					
					let alert = NSAlert()
					
					alert.alertStyle = NSAlertStyle.InformationalAlertStyle
					alert.messageText = error!.localizedDescription
					alert.informativeText = "Would you like to create a new Lazyfile?"
					
					alert.addButtonWithTitle("Create a new \(prog.fileName)")
					alert.addButtonWithTitle("Cancel")
					
					if alert.runModal() == NSAlertFirstButtonReturn {
						
						// User asks to create a new file.
						error = nil
						prog.initLazyfile(basePath: basePath, error: &error)
						
						if error != nil {
							// Fail to create a new file.
							let alert = NSAlert()
							alert.messageText = error!.localizedDescription
							alert.runModal()
						} else {
							// Successfully created a new file.
							openBasePath(basePath)
							return
						}
					}
				}
				
			} else {
				success = true
			}
		}
		
		self.saveButton.enabled = false
		if success {
			self.updateControlSettings(enabled:true)
		} else {
			
			sourceFileTextView.string = ""
			sourceFileTextView.lnv_updateLineNumberView(nil)
			updateDocumentsAndUserInterface()
			
			self.updateControlSettings(enabled:false)
		}
	}
	
	func updateControlSettings(#enabled:Bool) {
		
		self.sourceFileTextView.editable = enabled
		self.showHelpButton.enabled = enabled
		self.showParseColorButton.enabled = enabled
		self.updateButton.enabled = enabled
		self.exportButton.enabled = enabled
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	func updateDocumentsAndUserInterface() {
		
		updateDocuments()
		updateUserInterface()
	}
	
	func updateDocuments() {
		
		if let sourceString = sourceFileTextView.string {
			analyzer.inputString = sourceString
		}
		
		analyzer.process()
	}
	
	func updateUserInterface() {
		
		sourceFileTextView.setUpForDisplayingSourceCode()
		mainGeneratedCodeTextView.setUpForDisplayingSourceCode()
		
		mainGeneratedCodeTextView.editable = false
		
		// Update filePopUpButton
		filePopUpButton.removeAllItems()
		
		var count = Int(0)
		for sourceCodeDocument in analyzer.sourceCodeDocuments {
			let title = sourceCodeDocument.exportTo == "" ? "NONAME-\(count++).swift" : sourceCodeDocument.exportTo
			filePopUpButton.addItemWithTitle(title)
		}
		
		// If the new file changes and the number of files changes,
		// "last selected index" might be out of bounds.
		if filePopUpLastSelectedIndex >= analyzer.sourceCodeDocuments.count {
			// Set it to 0 if that occurs.
			filePopUpLastSelectedIndex = 0
		}
		
		// Display last selected file.
		if filePopUpLastSelectedIndex < analyzer.sourceCodeDocuments.count {
			// The number of files is not 0.
			filePopUpButton.selectItemAtIndex(filePopUpLastSelectedIndex)
			mainGeneratedCodeTextView.string = analyzer.sourceCodeDocuments[filePopUpLastSelectedIndex].documentString
		} else {
			// The number of files is 0.
			// Make mainGeneratedCodeTextView display an empty string.
			mainGeneratedCodeTextView.string = ""
		}
		
	}
	
	@IBAction func filePopUpButtonUpdated(sender: AnyObject) {
		
		filePopUpLastSelectedIndex = filePopUpButton.indexOfSelectedItem
		if filePopUpButton.indexOfSelectedItem < analyzer.sourceCodeDocuments.count {
			mainGeneratedCodeTextView.string = analyzer.sourceCodeDocuments[filePopUpButton.indexOfSelectedItem].documentString
		}
	}
	
	//MARK: Button Actions
	@IBAction func updateButtonTapped(sender: AnyObject) {
		
		updateDocumentsAndUserInterface()
	}
	
	@IBAction func exportButtonTapped(sender: AnyObject) {
		
		var message = ""
		
		if analyzer.sourceCodeDocuments.isEmpty {
			
			message = "There are no documents. "
		} else {
			
			if basePath == nil {
				message = "The base path is empty. "
				
			} else {
				
				updateDocumentsAndUserInterface()
				
				for d in analyzer.sourceCodeDocuments {
					message += d.export(basePath: basePath!)
					message += "\n"
				}
			}
		}
		
		let alert = NSAlert()
		alert.messageText = message
		alert.runModal()
	}

	@IBAction func saveButtonTapped(sender: AnyObject) {
		if let basePath = basePath {
			var error:NSError?
			prog.saveLazyfileString(sourceFileTextView.string!, basePath: basePath, error: &error)
			
			if let error = error {
				let alert = NSAlert()
				alert.messageText = error.localizedDescription
				alert.runModal()
			} else {
				self.saveButton.enabled = false
			}
		}
	}
	
	@IBAction func showParseColorButtonTapped(sender: AnyObject) {
		
		let vc = storyboard?.instantiateControllerWithIdentifier("ConversionViewController") as? ConversionViewController
		
		presentViewControllerAsSheet(vc!)
	}
	
	@IBAction func showHelpButtonTapped(sender: AnyObject) {
		let alert = NSAlert()
		
		alert.alertStyle = NSAlertStyle.InformationalAlertStyle
		alert.messageText = "Would you like to load sample source code?"
		alert.addButtonWithTitle("OK")
		alert.addButtonWithTitle("Cancel")
		
		if alert.runModal() == NSAlertFirstButtonReturn {
			sourceFileTextView.string = String.stringInBundle(name: "SourceDemo")
			updateDocumentsAndUserInterface()
		}
	}
}

extension SourceEditViewController : OptionsViewControllerDelegate {
	func optionsViewControllerButtonTapped(vc: OptionsViewController, response: Int) {
		
	}
}

extension SourceEditViewController : NSTextViewDelegate {
	func textDidChange(notification: NSNotification) {
		self.saveButton.enabled = true
	}
}
