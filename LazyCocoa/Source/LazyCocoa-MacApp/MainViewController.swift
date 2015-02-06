/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa
import AppKit

class MainViewController: NSViewController {
	
	@IBOutlet var sourceFileTextView: NSTextView!
	
	@IBOutlet weak var platformSegControl: NSSegmentedControl!
	
	@IBOutlet private var fontResultTextView: NSTextView!
	@IBOutlet private var colorResultTextView: NSTextView!
	
	var analyzer: DocumentAnalyzer = DocumentAnalyzer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		
		fontResultTextView.continuousSpellCheckingEnabled = false
		colorResultTextView.continuousSpellCheckingEnabled = false
		
		
		fontResultTextView.editable = false
		colorResultTextView.editable = false
		
		
		let myFont:NSFont = NSFont(name: "Monaco", size: 12)!
		
		sourceFileTextView.font = myFont
		fontResultTextView.font = myFont
		colorResultTextView.font = myFont
		
		
		sourceFileTextView.automaticQuoteSubstitutionEnabled = false
		sourceFileTextView.enabledTextCheckingTypes = 0
		
		sourceFileTextView.richText = false
		
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
		
		fontResultTextView.string = analyzer.fontFileString
		colorResultTextView.string = analyzer.colorFileString
		
	}
	
	@IBAction func exportButtonActionPerformed(sender: AnyObject) {
		
		update()
		
		var str = Settings.headerComment
		str = str + String.importStatementString("Foundation")
		str = str + String.importStatementString("UIKit")
		str = str + NEW_LINE_STRING + NEW_LINE_STRING
		str = str + analyzer.fontFileString
		str = str + analyzer.colorFileString
		
			
		FileManager.write(string: str, currentDocumentRealPath: Settings.currentDocumentRealPath, exportPath: Settings.exportPath)
		
	}
	
	@IBAction func updateButtonActionPerformed(sender: AnyObject) {
		
		update()
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
}

