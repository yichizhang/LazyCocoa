/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

class Document: NSDocument {

	var fileContentString:String? = ""
	var documentMainViewController:MainViewController?
	
	override init() {
	    super.init()
		// Add your subclass-specific initialization here.
	}

	override func windowControllerDidLoadNib(aController: NSWindowController) {
		super.windowControllerDidLoadNib(aController)
		// Add any code here that needs to be executed once the windowController has loaded the document's window.
		
		
	}

	override class func autosavesInPlace() -> Bool {
		return true
	}

	override func makeWindowControllers() {
		// Returns the Storyboard that contains your Document window.

		let storyboard = NSStoryboard(name: "Main", bundle: nil)!
		let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as NSWindowController
		println(windowController.contentViewController?.self)
		
		//let mainViewController:MainViewController = windowController.contentViewController as MainViewController
		//mainViewController.sourceFileTextView.string = self.fileContentString
		
		self.documentMainViewController = windowController.contentViewController as? MainViewController
		self.documentMainViewController?.sourceFileTextView.string = self.fileContentString
		
		self.addWindowController(windowController)
		
	}

	override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		
		self.fileContentString = self.documentMainViewController?.sourceFileTextView.string
				
		var tempData = self.fileContentString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		
		if tempData != nil {
			
			return tempData
		}else {
			
			outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
			return nil
		}
	
	}

	override func readFromData(data: NSData, ofType typeName: String, error outError: NSErrorPointer) -> Bool {
		// Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
		// You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
		// If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
		var readSuccess = false
		
		var tempString = NSString(data: data, encoding: NSUTF8StringEncoding)
		
		if tempString != nil {
			
			self.fileContentString = tempString!
			readSuccess = true
		}else {
			
			outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
		}
		
		return readSuccess
	
	}


}

