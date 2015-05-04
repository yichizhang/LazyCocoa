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
	
	@IBOutlet var sourceFileTextView: NSTextView!
	
	@IBOutlet weak var platformSegControl: NSSegmentedControl!
	
	@IBOutlet private var otherGeneratedCodeTextView: NSTextView!
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
	}
	
	func updateUserInterfaceSettings() {
		
		sourceFileTextView.setUpForDisplayingSourceCode()
		otherGeneratedCodeTextView.setUpForDisplayingSourceCode()
		mainGeneratedCodeTextView.setUpForDisplayingSourceCode()
		
		otherGeneratedCodeTextView.editable = false
		mainGeneratedCodeTextView.editable = false
		
		// Update filePopUpButton
		filePopUpButton.removeAllItems()
		
		var count = Int(0)
		for sourceCodeDocument in analyzer.sourceCodeDocuments {
			let title = sourceCodeDocument.exportTo == "" ? "NONAME-\(count++).swift" : sourceCodeDocument.exportTo
			filePopUpButton.addItemWithTitle(title)
		}
		
		if analyzer.sourceCodeDocuments.count > filePopUpLastSelectedIndex {
			filePopUpLastSelectedIndex = 0
		}
		
		// Display last selected file
		if analyzer.sourceCodeDocuments.count > filePopUpLastSelectedIndex {
			filePopUpButton.selectItemAtIndex(filePopUpLastSelectedIndex)
			mainGeneratedCodeTextView.string = analyzer.sourceCodeDocuments[filePopUpLastSelectedIndex].documentString
		} else {
			mainGeneratedCodeTextView.string = ""
		}
		
		println(analyzer.sourceCodeDocuments)
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
		
		//otherGeneratedCodeTextView.string = analyzer.otherResultString
		//mainGeneratedCodeTextView.string = analyzer.mainResultString
		
		updateUserInterfaceSettings()
	}
	
	@IBAction func updateButtonActionPerformed(sender: AnyObject) {
		
		update()
		
	}
	
	@IBAction func exportButtonActionPerformed(sender: AnyObject) {
		
		update()
			
		//FileManager.write(string: analyzer.mainResultString, currentDocumentRealPath: Settings.currentDocumentRealPath, exportPath: Settings.parameterForKey(paramKey_exportTo) )
		
	}
	
	@IBAction func platformSegControlUpdated(sender: AnyObject) {
		switch platformSegControl.selectedSegment {
		case 1:
			Settings.platform = .MacOS
		default:
			Settings.platform = .iOS
		}
		update()
	}
	
	@IBAction func filePopUpButtonUpdated(sender: AnyObject) {
		
		filePopUpLastSelectedIndex = filePopUpButton.indexOfSelectedItem
		if filePopUpButton.indexOfSelectedItem < analyzer.sourceCodeDocuments.count {
			mainGeneratedCodeTextView.string = analyzer.sourceCodeDocuments[filePopUpButton.indexOfSelectedItem].documentString
		}
	}
}

