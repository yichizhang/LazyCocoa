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
		var colorComponents = [CGFloat]()
		
		let decDigitSet = NSCharacterSet.decimalDigitCharacterSet()
		let set1 = NSCharacterSet(charactersInString: " :*-=()[]{};")
		
		while ( scanner.scanLocation < countElements(scanner.string) ) {
			
			let charString = (scanner.string as NSString).substringWithRange(
				NSMakeRange(scanner.scanLocation, 1)
			)
			
			if charString.containsCharactersInSet(decDigitSet) {
				scanner.scanFloat(&resultFloat)
				println(resultFloat)
			} else if charString.containsCharactersInSet(NSCharacterSet.newlineCharacterSet()) {
				println("---NEW LINE!---")
				scanner.scanLocation++
			} else if scanner.scanUpToCharactersFromSet(set1, intoString: &resultString) {
				println(resultString!)
			} else {
				scanner.scanLocation++
			}
			
		}
		
		return ""
		
	}
}
