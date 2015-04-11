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
		
		while ( scanner.scanLocation < count(scanner.string) ) {
			
			let charString = (scanner.string as NSString).substringWithRange(
				NSMakeRange(scanner.scanLocation, 1)
			)
			
			if charString.containsCharactersInSet(decDigitSet) {
				scanner.scanFloat(&resultFloat)
				
				currentColorComponents.append( CGFloat(resultFloat) )
				
			} else if charString.containsCharactersInSet(NSCharacterSet.newlineCharacterSet()) {
				// New line.
				
				if currentColorComponents.count >= 3 {
					let hexString = ColorFormatter.hexStringFrom(componentArray: currentColorComponents)
					if let colorName = currentColorName {
						returnString = returnString + "\(colorName) \(hexString)\n"
					}
					
					currentColorComponents.removeAll()
					currentColorName = nil
				}
				
				scanner.scanLocation++
				
			} else if scanner.scanUpToCharactersFromSet(set1, intoString: &resultString) {
				
				if let resultString = resultString {
					if resultString.hasSuffix("Color") &&
					resultString != "UIColor" &&
					resultString != "NSColor" {
						currentColorName = resultString as String
						currentColorComponents.removeAll()
					}
				}
				
			} else {
				scanner.scanLocation++
			}
			
		}
		
		return returnString
		
	}
}
