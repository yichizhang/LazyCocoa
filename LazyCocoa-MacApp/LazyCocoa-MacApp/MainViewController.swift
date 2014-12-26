/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

class MainViewController: NSViewController {
	
	@IBOutlet var sourceFileTextView: NSTextView!
	
	@IBOutlet private var objcHeaderFileResultTextView: NSTextView!
	
	@IBOutlet private var objcImplementationFileResultTextView: NSTextView!
	
	@IBOutlet private var swiftFileResultTextView: NSTextView!
	
	var analyzer: DocumentAnalyzer = DocumentAnalyzer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.objcHeaderFileResultTextView.continuousSpellCheckingEnabled = false;
		self.objcImplementationFileResultTextView.continuousSpellCheckingEnabled = false;
		self.swiftFileResultTextView.continuousSpellCheckingEnabled = false;
		
		self.objcHeaderFileResultTextView.editable = false;
		self.objcImplementationFileResultTextView.editable = false;
		self.swiftFileResultTextView.editable = false;
		
		let myFont:NSFont = NSFont(name: "Monaco", size: 12)!;
		
		self.sourceFileTextView.font = myFont;
		self.objcHeaderFileResultTextView.font = myFont;
		self.objcImplementationFileResultTextView.font = myFont;
		self.swiftFileResultTextView.font = myFont;
		
		self.sourceFileTextView.automaticQuoteSubstitutionEnabled = false
		self.sourceFileTextView.enabledTextCheckingTypes = 0
		
		self.sourceFileTextView.richText = false
		
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	@IBAction func updateButtonActionPerformed(sender: AnyObject) {
		
		println("Action")
		
		self.analyzer.inputString = self.sourceFileTextView.string;
		
		self.analyzer.process()
		
		self.objcHeaderFileResultTextView.string = self.analyzer.objcHeaderFileString;
		self.objcImplementationFileResultTextView.string = self.analyzer.objcImplementationFileString;
		self.swiftFileResultTextView.string = self.analyzer.swiftFileString;
	}
	
}

