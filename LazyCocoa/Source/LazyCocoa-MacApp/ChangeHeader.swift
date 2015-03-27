//
//  ChangeHeader.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 24/03/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation
import AppKit

class DirectoryWalker {
	class func allFiles(#baseURL:NSURL) -> [NSURL] {
		
		var directories = [NSURL]()
		let fileManager = NSFileManager()
		let keys = [NSURLIsDirectoryKey]
		let acceptableSuffixes = [".h", ".m", ".swift"]
		
		let enumerator = fileManager.enumeratorAtURL(baseURL, includingPropertiesForKeys: keys, options: NSDirectoryEnumerationOptions.allZeros, errorHandler: { (url:NSURL!, err:NSError!) -> Bool in
			
			// Handle the error.
			// Return true if the enumeration should continue after the error.
			return true
		})
		
		while let element = enumerator?.nextObject() as? NSURL {
			var error:NSError?
			var isDirectory:AnyObject?
			
			if !element.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey, error: &error) {
				
			}
			
			for suffix in acceptableSuffixes {
				if element.absoluteString!.hasSuffix(suffix) { // checks the extension
					directories.append(element)
				}
			}
		}
		
		return directories
	}
	
	class func allFiles(#baseDirectory:String) -> [NSURL]? {
		
		if let baseURL = NSURL(string: baseDirectory) {
			return allFiles(baseURL: baseURL)
		}
		
		return nil
	}
}

extension NSMutableAttributedString {

	func addBasicAttributesForHeaderChangerTextView() {
		self.addAttributes([NSFontAttributeName: NSFont(name: "Monaco", size: 12)!], range: (self.string as NSString).rangeOfString(self.string))
	}
}

class HeaderChanger {
	
	var originalString:NSString!
	lazy var originalCommentRange:NSRange = {
		return self.rangeOfHeaderCommentIn(fileString: self.originalString)
		}()
	var newFileString:NSString!
	
	var newComment:NSString!
	
	let singleLineCommentPrefix = SINGLE_LINE_COMMENT
	let multilineCommentPrefix = MULTI_LINE_COMMENT_START
	let multilineCommentSuffix = MULTI_LINE_COMMENT_END
	
	var originalAttributedString:NSAttributedString {
		var attributedString = NSMutableAttributedString(string: originalString)
		attributedString.addBasicAttributesForHeaderChangerTextView()
		attributedString.addAttributes([
			NSBackgroundColorAttributeName: NSColor.redColor(),
			], range: originalCommentRange)
		return attributedString
	}
	var newAttributedString:NSAttributedString {
		var attributedString = NSMutableAttributedString(string: newFileString)
		attributedString.addBasicAttributesForHeaderChangerTextView()
		attributedString.addAttributes([
			NSBackgroundColorAttributeName: NSColor.greenColor(),
			
			], range: rangeOfHeaderCommentIn(fileString:newFileString))
		return attributedString
	}
	
	init(string:NSString, newComment:NSString) {
		
		originalString = string
		self.newComment = newComment
		
		if originalCommentRange.location != NSNotFound {
			newFileString = originalString.stringByReplacingCharactersInRange(originalCommentRange, withString: self.newComment)
		}
	}
	
	func rangeOfHeaderCommentIn(#fileString:NSString) -> NSRange {
		
		if fileString.hasPrefix(multilineCommentPrefix) {
			
			let commentEndRange = fileString.rangeOfString(multilineCommentSuffix)
			
			if commentEndRange.location != NSNotFound {
				
				return NSMakeRange(0, NSMaxRange(commentEndRange))
			}
		} else if fileString.hasPrefix(singleLineCommentPrefix) {
			
			var commentLength = 0
			var rangeOfNewLine:NSRange = fileString.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet())
			
			while rangeOfNewLine.location != NSNotFound {
				
				let rangeOfCommentPrefix = NSMakeRange(NSMaxRange(rangeOfNewLine), singleLineCommentPrefix.length)
				
				if fileString.length >= NSMaxRange(rangeOfCommentPrefix) {
					
					if fileString.substringWithRange(rangeOfCommentPrefix) != singleLineCommentPrefix {
						// The line does not start with single line comment prefix
						commentLength = rangeOfNewLine.location
						break
					}
				} else {
					// The last line is shorter than single line comment prefix
					commentLength = NSMaxRange(rangeOfNewLine)
					break
				}
				
				rangeOfNewLine = fileString.rangeOfCharacterFromSet(NSCharacterSet.newlineCharacterSet(),
					options: .allZeros,
					range: NSMakeRange(
						NSMaxRange(rangeOfNewLine),
						fileString.length - NSMaxRange(rangeOfNewLine)
					)
				)
			}
			
			if rangeOfNewLine.location == NSNotFound {
				// Handle the case when the single line comment ends with EOF instead of \n
				commentLength = fileString.length
			}
			
			return NSMakeRange(0, commentLength)
		}
		
		return NSMakeRange(0, 0)
	}
	
}