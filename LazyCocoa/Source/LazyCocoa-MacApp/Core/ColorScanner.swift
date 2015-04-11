//
//  ColorScanner.swift
//  gocrazy
//
//  Created by Yichi on 7/01/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation

class ColorScanner: NSObject {
	
	class func resultStringFrom(text:String) -> String{
		
		let scanner = NSScanner(string: text)
		var resultString:NSString?
		var resultFloat:Float = 0.0
		
		let decDigitSet = NSCharacterSet.decimalDigitCharacterSet()
		let set1 = NSCharacterSet(charactersInString: " :*-=()[]{};")
		
		var currentColorName:String?
		var currentColorComponents = [CGFloat]()
		
		var returnString:String = ""
		
		// Scan the input string
		while ( scanner.scanLocation < count(scanner.string) ) {
			
			// Get the character at the current scan location as a String.
			let charString = (scanner.string as NSString).substringWithRange(
				NSMakeRange(scanner.scanLocation, 1)
			)
			
			if charString.containsCharactersInSet(decDigitSet) {
				// The character is a digit.
				// It means that there is a color component.
				// Get its value by using `scanFloat`
				scanner.scanFloat(&resultFloat)
				
				// Put the color component in the array
				currentColorComponents.append( CGFloat(resultFloat) )
				
			} else if charString.containsCharactersInSet(NSCharacterSet.newlineCharacterSet()) {
				// The character is a new line character.
				
				if currentColorComponents.count >= 3 {
					// We get a new line and there are already 3 color components in the array;
					// it looks like we got all the color components for the current color already.
					// So we out put the current color to `returnString` and delete it from memory
					// to make room for the next color.
					let hexString = ColorFormatter.hexStringFrom(componentArray: currentColorComponents)
					if let colorName = currentColorName {
						// Out put the color
						returnString = returnString + "\(colorName) \(hexString)\n"
					}
					
					// Clear current color components array and current color name.
					currentColorComponents.removeAll()
					currentColorName = nil
				}
				
				// Increment scan location, because we haven't scanned anything.
				scanner.scanLocation++
				
			} else if scanner.scanUpToCharactersFromSet(set1, intoString: &resultString) {
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
				scanner.scanLocation++
			}
			
		}
		
		return returnString
		
	}
}
