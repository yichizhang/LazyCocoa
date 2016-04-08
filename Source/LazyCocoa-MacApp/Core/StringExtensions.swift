//
//  StringExtensions.swift
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

extension String {
	func hasMatchesFor(regexString regexString:String) -> Bool {
		var result = false
		let selfString = self as NSString
		// TODO: Would NSMakeRange(0, countElements(self)) work?
		
		if let regex = try? NSRegularExpression(pattern: regexString, options: NSRegularExpressionOptions()) {
			if let firstMatch = regex.firstMatchInString(selfString as String, options: NSMatchingOptions(), range: NSMakeRange(0, selfString.length)) {
				result = true
			}
		}
		
		return result
	}
	
	static func stringInBundle(name name:String, ofType type: String = "txt", encoding: UInt = NSUTF8StringEncoding) -> String? {
		if let path = NSBundle.mainBundle().pathForResource(name, ofType: type, inDirectory: nil) {
			if let data = NSData(contentsOfFile: path) {
				return NSString(data: data, encoding: encoding) as? String
			}
		}
		return nil
	}
}