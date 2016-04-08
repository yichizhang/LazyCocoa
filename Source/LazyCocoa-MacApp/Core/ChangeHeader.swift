//
//  ChangeHeader.swift
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

class PlainTextFile {
	var fileURL:NSURL!
	var filename:String {
		return (path as NSString).lastPathComponent
	}
	var path:String {
		return fileURL.path!
	}
	var relativePath:String {
		return fileURL.relativePath!
	}
	
	var included = true
	
	var fileString:NSString? {
		if let data = NSData(contentsOfURL: fileURL) {
			return NSString(data:data, encoding: NSUTF8StringEncoding)
		}
		return nil
	}
	
	func updateFileWith(newFileString newFileString:String) {
		if let data = newFileString.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
			data.writeToURL(fileURL, atomically: true)
		}
	}
	
	func updateInclusiveness(filePathRegexString:String? = nil, originalHeaderRegexString:String? = nil) {
		
		var filePathCheckResult = true
		if let filePathRegexString = filePathRegexString {
			
			filePathCheckResult = path.hasMatchesFor(regexString: filePathRegexString)
		}
		
		var originalHeaderCheckResult = true
		if let originalHeaderRegexString = originalHeaderRegexString {
			
			if let fileString = fileString {
				let originalHeaderComment = fileString.substringWithRange(fileString.rangeOfHeaderComment)
				
				
				originalHeaderCheckResult = originalHeaderComment.hasMatchesFor(regexString: originalHeaderRegexString)
			} else {
				originalHeaderCheckResult = false
			}
		}
		
		included = filePathCheckResult && originalHeaderCheckResult
	}
	
	init(fileURL:NSURL) {
		
		self.fileURL = fileURL
		
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
		return self.originalString.rangeOfHeaderComment
		}()
	var newFileString:NSString!
	
	var preparedNewComment:NSString!
	
	var originalAttributedString:NSAttributedString {
		let attributedString = NSMutableAttributedString(string: originalString as String)
		attributedString.addBasicAttributesForHeaderChangerTextView()
		attributedString.addAttributes([
			NSBackgroundColorAttributeName: NSColor.redColor(),
			], range: originalCommentRange)
		return attributedString
	}
	var newAttributedString:NSAttributedString {
		let attributedString = NSMutableAttributedString(string: newFileString as String)
		attributedString.addBasicAttributesForHeaderChangerTextView()
		attributedString.addAttributes([
			NSBackgroundColorAttributeName: NSColor.greenColor(),
			
			], range: newFileString.rangeOfHeaderComment)
		return attributedString
	}
	
	init(string:NSString, newComment:NSString, filename:String? = nil) {
		
		originalString = string
		
		let tempCommentString = newComment.mutableCopy() as! NSMutableString
		
		let currentDate = NSDate()
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy"
		let yearString = dateFormatter.stringFromDate(currentDate)
		
		dateFormatter.dateStyle = .ShortStyle
		dateFormatter.timeStyle = .NoStyle
		let dateString = dateFormatter.stringFromDate(currentDate)
		
		tempCommentString.replaceOccurrencesOfString("___FULLUSERNAME___",
			withString: NSFullUserName(),
			options: [],
			range: tempCommentString.fullRange
		)
		
		tempCommentString.replaceOccurrencesOfString("___YEAR___",
			withString: yearString,
			options: [],
			range: tempCommentString.fullRange
		)
		
		if let filename = filename {
			
			tempCommentString.replaceOccurrencesOfString("___FILENAME___",
				withString: filename,
				options: [],
				range: tempCommentString.fullRange
			)
		}
		
		// TODO:
		tempCommentString.replaceOccurrencesOfString("___PROJECTNAME___",
			withString: "Project",
			options: [], range:
			tempCommentString.fullRange
		)
		
		tempCommentString.replaceOccurrencesOfString("___DATE___",
			withString: dateString,
			options: [],
			range: tempCommentString.fullRange
		)
		
		preparedNewComment = tempCommentString
		
		if originalCommentRange.location != NSNotFound {
			
			/* Add an extra new line, in case there is something after the header comment.
			 * For example:
			 *                     X  --- Check if this character is a new line character.
			 *        /* Comment */ #define AAA BBB
			 *        #define CCC DDD
			 */
			if originalString.length > NSMaxRange(originalCommentRange)
				&&
				originalString.substringWithRange(NSRange(location: NSMaxRange(originalCommentRange), length: 1)).containsCharactersInSet(NSCharacterSet.newlineCharacterSet()) == false {
				tempCommentString.appendString("\n")
			}
			
			newFileString = originalString.stringByReplacingCharactersInRange(originalCommentRange, withString: preparedNewComment as String)
		}
	}
}

extension NSString {
	var rangeOfHeaderComment:NSRange {
		
		let singleLineCommentPrefix = StringConst.SigleLineComment
		let multilineCommentPrefix = StringConst.MultiLineCommentStart
		let multilineCommentSuffix = StringConst.MultiLineCommentEnd
		
		let fileString = self
		
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
					options: [],
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