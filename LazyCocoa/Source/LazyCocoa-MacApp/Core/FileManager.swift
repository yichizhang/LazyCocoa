//
//  FileManager.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 6/02/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation
import AppKit

class FileManager {
	
	class func write(#string:String, currentDocumentRealPath:String?, exportPath:String?) {
		
		var alertTitle = ""
		var error:NSError?
		
		if let exportPath = exportPath?.stringByTrimmingWhiteSpaceAndNewLineCharacters() {
			
			if let currentDocumentRealPath = currentDocumentRealPath {
				
				let fullExportPath = currentDocumentRealPath.stringByDeletingLastPathComponent.stringByAppendingPathComponent(exportPath)
				
				println(fullExportPath)
				
				string.writeToFile(fullExportPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
				
			} else {
				
				alertTitle = "The path to current document is unknown. Press ⌘ + S to set it. "
			}
			
		} else {
			
			alertTitle = "The export path is not set. Add '!exportTo path-to-file' to your document, then click update. "
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