//
//  ChangeHeader.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 24/03/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation

class ChangeHeader {
	class func allFiles(#baseDirectory:String) -> [String] {
		var directories = [String]()
		
		let fileManager = NSFileManager()
		if let directoryURL = NSURL(string: baseDirectory) {
			let keys = [NSURLIsDirectoryKey]
			
			let enumerator = fileManager.enumeratorAtURL(directoryURL, includingPropertiesForKeys: keys, options: NSDirectoryEnumerationOptions.allZeros, errorHandler: { (url:NSURL!, err:NSError!) -> Bool in
				
				// Handle the error.
				// Return true if the enumeration should continue after the error.
				return true
			})
			
			while let element = enumerator?.nextObject() as? NSURL {
				var error:NSError?
				var isDirectory:AnyObject?
				
				if !element.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey, error: &error) {
					
				}
				
				if element.absoluteString!.hasSuffix(".swift") { // checks the extension
					directories.append(element.absoluteString!)
				}
			}
			
		}
		
		return directories
	}
}