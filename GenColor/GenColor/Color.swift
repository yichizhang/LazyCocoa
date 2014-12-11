//
//  Color.swift
//  GenColor
//
//  Created by Yichi on 12/12/2014.
//  Copyright (c) 2014 Yichi Zhang. All rights reserved.
//

import Cocoa

class Color: NSObject {
	
	var name: String!
	var valueString: String!
	
	let objcMode = 0
	let swiftMode = 1
	
	func objcHeaderStringWithoutSemicolon() ->String {
		return "+ (UIColor *)\(self.name)"
	}

	func objcHeaderString() ->String {
		return self.objcHeaderStringWithoutSemicolon() + ";"
	}
	
	func objcImplementationString() ->String {
		return self.objcHeaderStringWithoutSemicolon() + " {\n" + "\treturn \(self.uicolorString(objcMode));" + "\n}"
	}
	
	func swiftString() ->String {
		return "class func \(self.name)() ->UIColor {\n" + "\treturn \(self.uicolorString(swiftMode));" + "\n}"
	}
	
	func uicolorString(mode:Int) ->String {
		
		if (self.valueString.hasPrefix("#")){
			
			var red:CGFloat = 1.0
			var green:CGFloat = 1.0
			var blue:CGFloat = 1.0
			var alpha:CGFloat = 1.0
			var rgba:String = self.valueString
			
			let index   = advance(rgba.startIndex, 1)
			let hex     = rgba.substringFromIndex(index)
			let scanner = NSScanner(string: hex)
			var hexValue: CUnsignedLongLong = 0
			
			if scanner.scanHexLongLong(&hexValue) {
				if countElements(hex) == 3 {
					red   = CGFloat((hexValue & 0xF00) >> 8)  / 15.0
					green = CGFloat((hexValue & 0x0F0) >> 4)  / 15.0
					blue  = CGFloat(hexValue & 0x00F) / 15.0
				} else if countElements(hex) == 4 {
					red   = CGFloat((hexValue & 0xF000) >> 12) / 15.0
					green = CGFloat((hexValue & 0x0F00) >> 8)  / 15.0
					blue  = CGFloat((hexValue & 0x00F0) >> 4)  / 15.0
					alpha = CGFloat(hexValue & 0x000F)         / 15.0
				} else if countElements(hex) == 6 {
					red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
					green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
					blue  = CGFloat(hexValue & 0x0000FF) / 255.0
				} else if countElements(hex) == 8 {
					red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
					green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
					blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
					alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
				} else {
					print("error")
				}
			} else {
				println("scan hex error")
			}
			
			
			if (mode == objcMode) {
				return "[UIColor colorWithRed:\(red) green:\(green) blue:\(blue) alpha:\(alpha)]";
			} else if (mode == swiftMode) {
				return "UIColor(red:\(red), green:\(green), blue:\(blue), alpha:\(alpha))"
			}
			
		}else {
			if (mode == objcMode) {
				return "[UIColor \(self.valueString)]"
			} else if (mode == swiftMode) {
				return "UIColor.\(self.valueString)()"
			}
		}
		return ""
	}

}
