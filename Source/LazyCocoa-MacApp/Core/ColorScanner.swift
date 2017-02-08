//
//  ColorScanner.swift
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

class ColorScanner: NSObject {
	
	class func resultStringFrom(_ text:String) -> String{
		
		let scanner = Scanner(string: text)
		var resultString:NSString?
		var resultFloat:Float = 0.0
		
		let decDigitSet = CharacterSet.decimalDigits
		let set1 = CharacterSet(charactersIn: " :*-=()[]{};")
		
		var currentColorName:String?
		var currentColorComponents = [CGFloat]()
		
		var returnString:String = ""
		
		// Scan the input string
		while ( scanner.scanLocation < scanner.string.characters.count ) {
			
			// Get the character at the current scan location as a String.
			let charString = (scanner.string as NSString).substring(
				with: NSMakeRange(scanner.scanLocation, 1)
			)
			
			if charString.containsCharactersInSet(decDigitSet) {
				// The character is a digit.
				// It means that there is a color component.
				// Get its value by using `scanFloat`
				scanner.scanFloat(&resultFloat)
				
				// Put the color component in the array
				currentColorComponents.append( CGFloat(resultFloat) )
				
			} else if charString.containsCharactersInSet(CharacterSet.newlines) {
				// The character is a new line character.
				
				if currentColorComponents.count >= 3 {
					// We get a new line and there are already 3 color components in the array;
					// it looks like we got all the color components for the current color already.
					// So we out put the current color to `returnString` and delete it from memory
					// to make room for the next color.
					let hexString = ColorFormatter.hexStringFrom(currentColorComponents)
					if let colorName = currentColorName {
						// Out put the color
						returnString = returnString + "\(colorName) \(hexString)\n"
					}
					
					// Clear current color components array and current color name.
					currentColorComponents.removeAll()
					currentColorName = nil
				}
				
				// Increment scan location, because we haven't scanned anything.
				scanner.scanLocation += 1
				
			} else if scanner.scanUpToCharacters(from: set1, into: &resultString) {
				// The character is neither a digit or a new line character.
				// Scan up to an Objective-C special character (at the moment, `set1`)
				
				if let resultString = resultString {
					
					// Check the string scanned and see if it is a color name.
					// At the moment, the criteria is that it ends with `Color` 
					// but not `UIColor` or `NSColor`
					if resultString.hasSuffix("Color") &&
					resultString != "UIColor" &&
					resultString != "NSColor" {
						currentColorName = resultString as String
						currentColorComponents.removeAll()
					}
				}
				
			} else {
				// Keep scanning
				scanner.scanLocation += 1
			}
			
		}
		
		return returnString
		
	}
}
