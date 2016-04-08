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

class SourceEditViewController: BaseViewController {
	
	var prog = MainProgram()
	var optionsView:OptionsView?
	
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
	
	// MARK: Base View Controller
	override func loadData() {
		openBasePath(basePath)
	}
	
	override func cancelLoading() {
		
	}
	
	// MARK: View life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		title = "Source Editor"
		sourceFileTextView.setUpForDisplayingSourceCode()
		
		sourceFileTextView.lnv_setUpLineNumberView()
		sourceFileTextView.delegate = self
		
		self.saveButton.enabled = false
		self.filePopUpButton.enabled = false
		self.updateControlSettings(enabled:false)
	}
	
	// MARK: Load file
	func openBasePath(basePath:String?) {
		var error:NSError?
		var success = false
		
		if let basePath = basePath {
			do {
				let string = try prog.lazyfileString(basePath: basePath)
				
				sourceFileTextView.string = string
				sourceFileTextView.lnv_updateLineNumberView(nil)
				updateDocumentsAndUserInterface()
			} catch var error1 as NSError {
				error = error1
			}
			
			if error != nil {
				
				optionsView?.removeFromSuperview()
				optionsView = nil
				
				optionsView = OptionsView.newViewWithNibName("OptionsView")
				
				if let v = optionsView {
					v.delegate = self
					
					let layer = CALayer()
					layer.backgroundColor = NSColor.windowBackgroundColor().CGColor
					
					v.wantsLayer = true
					v.layer = layer
					v.frame = NSRect(origin: CGPointZero, size: self.view.frame.size)
					
					self.view.addSubview(v, positioned: NSWindowOrderingMode.Above, relativeTo: nil)
					v.setupConstraintsMakingViewAdhereToEdgesOfSuperview()
					
					loadingCancelled = false
					if error!.code == ErrorCode.FileIsDir {
						v.messageField.stringValue = error!.localizedDescription
						v.okButton.enabled = false
					} else if error!.code == ErrorCode.FileNotExist {
						v.messageField.stringValue = "\(error!.localizedDescription)\nWould you like to create a new \(prog.fileName)?"
						v.okButton.stringValue = "Create a new \(prog.fileName)"
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
	
	// MARK: Update user interface
	func updateControlSettings(enabled enabled:Bool) {
		
		self.sourceFileTextView.editable = enabled
		self.mainGeneratedCodeTextView.editable = false
		self.showHelpButton.enabled = enabled
		self.showParseColorButton.enabled = enabled
		self.updateButton.enabled = enabled
		self.exportButton.enabled = enabled
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
		
		filePopUpButton.enabled = true
		
	}
	
	//MARK: User interaction - file pop up button
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
		var showExportPathNotSetMessage = false
		
		if analyzer.sourceCodeDocuments.isEmpty {
			
			message = "There are no documents. "
		} else {
			
			if basePath == "" {
				message = "The base path is empty. "
				
			} else {
				
				updateDocumentsAndUserInterface()
				
				for d in analyzer.sourceCodeDocuments {
					var error:NSError?
					message += d.export(basePath: basePath, error: &error)
					
					if let error = error {
						if error.code == ErrorCode.ExportPathNotSet {
							showExportPathNotSetMessage = true
						}
					}
					message += "\n"
				}
			}
		}
		
		if showExportPathNotSetMessage {
			message += "\nUse `!!exportPath` to set export path.\nExample:\n\n!!!stringConst\n!!exportTo StringConst.swift\nweb_id; name; email; contact_details; location; position; work_unit"
		}
		
		let alert = NSAlert()
		alert.messageText = message
		alert.runModal()
	}

	@IBAction func saveButtonTapped(sender: AnyObject) {
		if basePath != "" {
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

extension SourceEditViewController : OptionsViewDelegate {
	func optionsViewButtonTapped(vc: OptionsView, response: Int) {
		switch response {
		case NSModalResponseOK:
			if basePath != "" {
				var error:NSError?
				
				prog.initLazyfile(basePath: basePath, error: &error)
				
				if error != nil {
					// Fail to create a new file.
					let alert = NSAlert()
					alert.messageText = error!.localizedDescription
					alert.runModal()
				} else {
					// Successfully created a new file.
					self.loadData()
				}
			}
			break
		default:
			loadingCancelled = true
			break
		}
		
		self.optionsView?.removeFromSuperview()
		self.optionsView = nil
	}
}

extension SourceEditViewController : NSTextViewDelegate {
	func textDidChange(notification: NSNotification) {
		self.saveButton.enabled = true
	}
}
