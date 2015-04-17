//
//  ColorFormatter.swift
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

class ColorFormatter {
	
	class func hexStringFrom(#componentArray:[CGFloat], useUpperCase:Bool = true) -> String {
		var hexString = ("#" as NSString).mutableCopy() as! NSMutableString
		
		for i in 0..<4 {
			// If there are less than 3 members in the component array
			// missing elements will be subtituted by `00` (0.0)
			
			// If there is no alpha (no component at index 3),
			// do not add alpha value to the hex string.
			var component:CGFloat = 0.0
			var hasValueAtCurrentIndex = false
			
			if i < componentArray.count {
				hasValueAtCurrentIndex = true
				component = componentArray[i]
			}
			
			if (i < 3)
				||
				(i == 3 && hasValueAtCurrentIndex) {
					
					let componentIntValue = Int( round( component*255.0 ) )
					hexString.appendFormat(NSString(format: "%02x", componentIntValue ))
			}
		}
		
		if useUpperCase {
			return hexString.uppercaseString
		} else {
			return hexString as String
		}
	}
}