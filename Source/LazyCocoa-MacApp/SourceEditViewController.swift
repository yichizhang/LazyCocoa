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
	
	var basePath = "" {
		didSet {
			
			var error:NSError?
			let prog = MainProgram()
			
			if let string = prog.lazyfileString(basePath: basePath, error: &error) {
				sourceFileTextView.string = string
				update()
			}
			
			if let error = error {
				sourceFileTextView.string = ""
				update()
				
				let alert = NSAlert()
				alert.messageText = error.localizedDescription
				alert.runModal()
			}
			
			
		}
	}
	
	@IBOutlet var sourceFileTextView: NSTextView!
	var rulerView:LineNumberRulerView!
	
	@IBOutlet weak var platformSegControl: NSSegmentedControl!
	
	@IBOutlet private var mainGeneratedCodeTextView: NSTextView!
	
	@IBOutlet weak var filePopUpButton: NSPopUpButtonCell!
	var filePopUpLastSelectedIndex = Int(0)
	
	var analyzer: DocumentAnalyzer = DocumentAnalyzer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		title = "Source Editor"
		
		// TODO: Temp solution for demo file
		sourceFileTextView.string = String.stringInBundle(name: "SourceDemo")
		
		update()
		
		if let scrollView = sourceFileTextView.enclosingScrollView {
			rulerView = LineNumberRulerView(textView: sourceFileTextView)
			
			scrollView.verticalRulerView = rulerView
			scrollView.hasVerticalRuler = true
			scrollView.rulersVisible = true
		}
		
		sourceFileTextView.delegate = self
	}
	
	func updateUserInterfaceSettings() {
		
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
		
		// println(analyzer.sourceCodeDocuments)
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	func update() {
		
		analyzer.platform = Platform(rawValue: platformSegControl.selectedSegment)
		
		if let sourceString = sourceFileTextView.string {
			analyzer.inputString = sourceString
		}
		
		analyzer.process()
		
		updateUserInterfaceSettings()
	}
	
	@IBAction func updateButtonActionPerformed(sender: AnyObject) {
		
		update()
		
	}
	
	@IBAction func exportButtonActionPerformed(sender: AnyObject) {
		
		if analyzer.sourceCodeDocuments.isEmpty {
			return
		}
		
		var message = ""
		
		if Global.currentDocumentRealPath == nil {
			message = "The path to current document is unknown. Press ⌘ + S to set it. "
			
			let alert = NSAlert()
			alert.messageText = message
			alert.runModal()
			
			return
		}
		
		update()
		
		var filesSuccessfullyExported = [String]()
		var filesFailedToExport = [String]()
		var error:NSError?
		
		for d in analyzer.sourceCodeDocuments {
			
			if d.exportTo.isEmpty == false {
				
				let exportPath = d.exportTo.stringByTrimmingWhiteSpaceAndNewLineCharacters()
				
				let fullExportPath = Global.currentDocumentRealPath!.stringByDeletingLastPathComponent.stringByAppendingPathComponent(exportPath)
				
				d.documentString.writeToFile(fullExportPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
				
				if let error = error {
					filesFailedToExport.append("\(fullExportPath) (\(error.localizedDescription))")
				} else {
					filesSuccessfullyExported.append(fullExportPath)
				}
			} else {
				filesFailedToExport.append("(Export path is not set)")
			}
		}
		
		if filesSuccessfullyExported.isEmpty == false {
			message += "Successfully exported: \n" + "\n".join(filesSuccessfullyExported) + "\n"
		}
		
		if filesFailedToExport.isEmpty == false {
			message += "Failed to export: \n" + "\n".join(filesFailedToExport) + "\n"
		}
		
		let alert = NSAlert()
		alert.messageText = message
		alert.runModal()
	}
	
	@IBAction func platformSegControlUpdated(sender: AnyObject) {
		switch platformSegControl.selectedSegment {
		case 1:
			Global.platform = .MacOS
		default:
			Global.platform = .iOS
		}
		update()
	}
	
	@IBAction func filePopUpButtonUpdated(sender: AnyObject) {
		
		filePopUpLastSelectedIndex = filePopUpButton.indexOfSelectedItem
		if filePopUpButton.indexOfSelectedItem < analyzer.sourceCodeDocuments.count {
			mainGeneratedCodeTextView.string = analyzer.sourceCodeDocuments[filePopUpButton.indexOfSelectedItem].documentString
		}
	}
	
	@IBAction func showParseColorButtonTapped(sender: AnyObject) {
		
		let vc = storyboard?.instantiateControllerWithIdentifier("ConversionViewController") as? ConversionViewController
		
		presentViewControllerAsSheet(vc!)
	}
}

extension SourceEditViewController : NSTextViewDelegate {
	func textDidChange(notification: NSNotification) {
		
		self.rulerView.needsDisplay = true
	}
}
