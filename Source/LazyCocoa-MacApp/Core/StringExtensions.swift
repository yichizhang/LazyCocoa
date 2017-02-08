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
	func hasMatchesFor(regexString:String) -> Bool {
		var result = false
		let selfString = self as NSString
		// TODO: Would NSMakeRange(0, countElements(self)) work?
		
		if let regex = try? NSRegularExpression(pattern: regexString, options: NSRegularExpression.Options()) {
			if regex.firstMatch(in: selfString as String, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, selfString.length)) != nil {
				result = true
			}
		}
		
		return result
	}
	
	static func stringInBundle(name:String, ofType type: String = "txt", encoding: String.Encoding = String.Encoding.utf8) -> String? {
		if let path = Bundle.main.path(forResource: name, ofType: type, inDirectory: nil) {
      if let string = try? String(contentsOfFile: path, encoding: encoding) {
        return string
			}
		}
		return nil
	}
}
