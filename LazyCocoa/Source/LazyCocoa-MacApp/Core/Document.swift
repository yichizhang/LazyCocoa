//
//  Document.swift
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

class Document: NSDocument {

	var fileContentString = ""
	var alwaysSaveAsPlainText = true
	var documentMainViewController:SourceEditViewController?
	
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
		let windowController = storyboard.instantiateControllerWithIdentifier("Document Window Controller") as! NSWindowController
		println(windowController.contentViewController.self)
		
		//let mainViewController:SourceEditViewController = windowController.contentViewController as SourceEditViewController
		//mainViewController.sourceFileTextView.string = fileContentString
		
		//documentMainViewController = windowController.contentViewController as? SourceEditViewController
        if let tabVC = windowController.contentViewController as? NSTabViewController {
            documentMainViewController = (tabVC.childViewControllers as! [NSViewController])[0] as? SourceEditViewController
        }
        
		if let documentMainViewController = documentMainViewController {
			documentMainViewController.sourceFileTextView.string = fileContentString
			documentMainViewController.update()
		}
		
		addWindowController(windowController)
		
	}

	override func dataOfType(typeName: String, error outError: NSErrorPointer) -> NSData? {
		// Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
		// You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
		
		if let string = documentMainViewController?.sourceFileTextView.string{
			fileContentString = string
		}
		
		var jsonError:NSError?
		let container = [fileKey_mainSource: fileContentString]
		
		var data:NSData?
		
		if alwaysSaveAsPlainText {
			data = fileContentString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
		} else {
			data = NSJSONSerialization.dataWithJSONObject(container, options: NSJSONWritingOptions.allZeros, error: &jsonError)
		}
		
		if data != nil {
			return data
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
		var jsonError:NSError?
		
		var tempObject: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &jsonError)
		
		if jsonError == nil {
			
			if let dataObject = tempObject as? NSDictionary{
				if let mainSource = dataObject[fileKey_mainSource] as? String {
					
					fileContentString = mainSource
					readSuccess = true
					
				} else {
					
				}
			} else {
				
			}
			
		}
		
		if !readSuccess {
			
			var tempString = NSString(data: data, encoding: NSUTF8StringEncoding)
			
			if tempString != nil {
				
				// Otherwise would crash when opening new files
				var str = tempString as! String
				let colorAndFontProcessingMode = "!!!colorAndFont"
				if str.rangeOfString(colorAndFontProcessingMode) == nil{
					
					str = colorAndFontProcessingMode + "\n\n" + str
				}
				
				fileContentString = str
				readSuccess = true
				
			}else {
				
				outError.memory = NSError(domain: NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
			}
		}
		
		return readSuccess
	
	}

	override func writeSafelyToURL(url: NSURL, ofType typeName: String, forSaveOperation saveOperation: NSSaveOperationType, error outError: NSErrorPointer) -> Bool {
		
		// http://stackoverflow.com/questions/3950971/nsdocument-get-real-save-path
		if let path = url.path {
			
			Settings.currentDocumentRealPath = path
			println(path)
		}
		return super.writeSafelyToURL(url, ofType: typeName, forSaveOperation: saveOperation, error: outError)
	}
}
