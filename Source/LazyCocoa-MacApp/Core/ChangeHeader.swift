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
	var fileURL:URL!
	var filename:String {
		return (path as NSString).lastPathComponent
	}
	var path:String {
		return fileURL.path
	}
	var relativePath:String {
		return fileURL.relativePath
	}
	
	var included = true
	
	var fileString:NSString? {
		if let data = try? Data(contentsOf: fileURL) {
			return NSString(data:data, encoding: String.Encoding.utf8.rawValue)
		}
		return nil
	}
	
	func updateFileWith(newFileString:String) {
		if let data = newFileString.data(using: String.Encoding.utf8, allowLossyConversion: true) {
			try? data.write(to: fileURL, options: [.atomic])
		}
	}
	
	func updateInclusiveness(_ filePathRegexString:String? = nil, originalHeaderRegexString:String? = nil) {
		
		var filePathCheckResult = true
		if let filePathRegexString = filePathRegexString {
			
			filePathCheckResult = path.hasMatchesFor(regexString: filePathRegexString)
		}
		
		var originalHeaderCheckResult = true
		if let originalHeaderRegexString = originalHeaderRegexString {
			
			if let fileString = fileString {
				let originalHeaderComment = fileString.substring(with: fileString.rangeOfHeaderComment)
				
				
				originalHeaderCheckResult = originalHeaderComment.hasMatchesFor(regexString: originalHeaderRegexString)
			} else {
				originalHeaderCheckResult = false
			}
		}
		
		included = filePathCheckResult && originalHeaderCheckResult
	}
	
	init(fileURL:URL) {
		
		self.fileURL = fileURL
		
	}
}

extension NSMutableAttributedString {

	func addBasicAttributesForHeaderChangerTextView() {
		self.addAttributes([NSFontAttributeName: NSFont(name: "Monaco", size: 12)!], range: (self.string as NSString).range(of: self.string))
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
			NSBackgroundColorAttributeName: NSColor.red,
			], range: originalCommentRange)
		return attributedString
	}
	var newAttributedString:NSAttributedString {
		let attributedString = NSMutableAttributedString(string: newFileString as String)
		attributedString.addBasicAttributesForHeaderChangerTextView()
		attributedString.addAttributes([
			NSBackgroundColorAttributeName: NSColor.green,
			
			], range: newFileString.rangeOfHeaderComment)
		return attributedString
	}
	
	init(string:NSString, newComment:NSString, filename:String? = nil) {
		
		originalString = string
		
		let tempCommentString = newComment.mutableCopy() as! NSMutableString
		
		let currentDate = Date()
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy"
		let yearString = dateFormatter.string(from: currentDate)
		
		dateFormatter.dateStyle = .short
		dateFormatter.timeStyle = .none
		let dateString = dateFormatter.string(from: currentDate)
		
		tempCommentString.replaceOccurrences(of: "___FULLUSERNAME___",
			with: NSFullUserName(),
			options: [],
			range: tempCommentString.fullRange
		)
		
		tempCommentString.replaceOccurrences(of: "___YEAR___",
			with: yearString,
			options: [],
			range: tempCommentString.fullRange
		)
		
		if let filename = filename {
			
			tempCommentString.replaceOccurrences(of: "___FILENAME___",
				with: filename,
				options: [],
				range: tempCommentString.fullRange
			)
		}
		
		// TODO:
		tempCommentString.replaceOccurrences(of: "___PROJECTNAME___",
			with: "Project",
			options: [], range:
			tempCommentString.fullRange
		)
		
		tempCommentString.replaceOccurrences(of: "___DATE___",
			with: dateString,
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
				originalString.substring(with: NSRange(location: NSMaxRange(originalCommentRange), length: 1)).containsCharactersInSet(CharacterSet.newlines) == false {
				tempCommentString.append("\n")
			}
			
			newFileString = originalString.replacingCharacters(in: originalCommentRange, with: preparedNewComment as String) as NSString!
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
			
			let commentEndRange = fileString.range(of: multilineCommentSuffix)
			
			if commentEndRange.location != NSNotFound {
				
				return NSMakeRange(0, NSMaxRange(commentEndRange))
			}
		} else if fileString.hasPrefix(singleLineCommentPrefix) {
			
			var commentLength = 0
			var rangeOfNewLine:NSRange = fileString.rangeOfCharacter(from: CharacterSet.newlines)
			
			while rangeOfNewLine.location != NSNotFound {
				
				let rangeOfCommentPrefix = NSMakeRange(NSMaxRange(rangeOfNewLine), singleLineCommentPrefix.length)
				
				if fileString.length >= NSMaxRange(rangeOfCommentPrefix) {
					
					if fileString.substring(with: rangeOfCommentPrefix) != singleLineCommentPrefix {
						// The line does not start with single line comment prefix
						commentLength = rangeOfNewLine.location
						break
					}
				} else {
					// The last line is shorter than single line comment prefix
					commentLength = NSMaxRange(rangeOfNewLine)
					break
				}
				
				rangeOfNewLine = fileString.rangeOfCharacter(from: CharacterSet.newlines,
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
