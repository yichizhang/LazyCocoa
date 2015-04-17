//
//  FileManager.swift
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

import Foundation
import AppKit

class FileManager {
	
	class func write(#string:String, currentDocumentRealPath:String?, exportPath:String?) {
		
		var alertTitle = ""
		var error:NSError?
		
		if let _exportPath = exportPath {
			
			let exportPath = _exportPath.stringByTrimmingWhiteSpaceAndNewLineCharacters()
			
			if let currentDocumentRealPath = currentDocumentRealPath {
				
				let fullExportPath = currentDocumentRealPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(exportPath)
				
				println(fullExportPath)
				
				string.writeToFile(fullExportPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
				
			} else {
				
				alertTitle = "The path to current document is unknown. Press ⌘ + S to set it. "
			}
			
		} else {
			
			alertTitle = "The export path is not set. Add '!!exportTo path-to-file' to your document, then click update. "
		}
		
		if let error = error {
			alertTitle = "Error: " + error.localizedDescription
		}
		
		if alertTitle.isEmpty {
			alertTitle = "The file has been successfully exported."
			
		} else {
			
		}
		
		let alert = NSAlert()
		alert.messageText = alertTitle
		alert.runModal()
	}
}