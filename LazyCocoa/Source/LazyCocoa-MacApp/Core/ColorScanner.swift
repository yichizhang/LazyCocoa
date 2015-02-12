//
//  ColorScanner.swift
//  gocrazy
//
//  Created by Yichi on 7/01/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation

class ColorScanner: NSObject {
	
	class func scanText(text:String) -> String{
		
		var array:Array<String> = Array()
		let aa:NSArray = (text as NSString).componentsSeparatedByString(" ")
		
		let k:NSString = ((aa.count > 1) ? (aa[1] as! NSString) : (""))
		
		let scanner = NSScanner(string: text)
		var resultString:NSString?
		var resultFloat:Float = 0.0
		var a: [Float] = [1.0, 1.0, 1.0, 1.0]
		var i = 0
		
		let numberAndDot = NSCharacterSet.decimalDigitCharacterSet().mutableCopy() as! NSMutableCharacterSet
		numberAndDot.addCharactersInString(".")
		
		let fuckYouSet = NSCharacterSet(charactersInString: text).mutableCopy() as! NSMutableCharacterSet
		fuckYouSet.removeCharactersInString("1234567890.")
		//scanner.charactersToBeSkipped = fuckYouSet
		//scanner.charactersToBeSkipped = numberAndDot
		
		println(text)
		
		while ( scanner.scanLocation < count(scanner.string) ) {
			
			let character = (scanner.string as NSString).characterAtIndex(scanner.scanLocation)
			
//			println( NSString(format: "%c", character) )
			
			
			scanner.scanUpToString(":", intoString: &resultString)


//			println(resultString)
			
			if (scanner.scanLocation < count(scanner.string)) {
				scanner.scanLocation++
				
				
				scanner.scanFloat(&resultFloat)
				a[i] = resultFloat
				i++
				
				println(resultFloat)
			}
			
		}
		
		for f in a {
			let s = NSString(format: "%02x", Int(f*255) )
			println( s )
			array.append(s.uppercaseString)
		}
		
		let joined = "".join(array)
		return "\(k) #\(joined)"
		
	}
}
