/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

class ColorModel : BaseModel, BaseModelProtocol{
	
	var red:Float = 1.0
	var green:Float = 1.0
	var blue:Float = 1.0
	var alpha:Float = 1.0
	
	convenience init(identifier:String, colorHexString:String){
		
		self.init()
		
		self.identifier = identifier
		
		let index   = advance(colorHexString.startIndex, 1)
		let hex     = colorHexString.substringFromIndex(index)
		let scanner = NSScanner(string: hex)
		var hexValue: CUnsignedLongLong = 0
		
		if scanner.scanHexLongLong(&hexValue) {
			if countElements(hex) == 3 {
				red   = Float((hexValue & 0xF00) >> 8)  / 15.0
				green = Float((hexValue & 0x0F0) >> 4)  / 15.0
				blue  = Float(hexValue & 0x00F) / 15.0
			} else if countElements(hex) == 4 {
				red   = Float((hexValue & 0xF000) >> 12) / 15.0
				green = Float((hexValue & 0x0F00) >> 8)  / 15.0
				blue  = Float((hexValue & 0x00F0) >> 4)  / 15.0
				alpha = Float(hexValue & 0x000F)         / 15.0
			} else if countElements(hex) == 6 {
				red   = Float((hexValue & 0xFF0000) >> 16) / 255.0
				green = Float((hexValue & 0x00FF00) >> 8)  / 255.0
				blue  = Float(hexValue & 0x0000FF) / 255.0
			} else if countElements(hex) == 8 {
				red   = Float((hexValue & 0xFF000000) >> 24) / 255.0
				green = Float((hexValue & 0x00FF0000) >> 16) / 255.0
				blue  = Float((hexValue & 0x0000FF00) >> 8)  / 255.0
				alpha = Float(hexValue & 0x000000FF)         / 255.0
			} else {
				print("error")
			}
		} else {
			println("scan hex error")
		}
		
	}
	
	func autoMethodName() -> String {
	
		let base = Settings.unwrappedParameterForKey(paramKey_classFuncPrefix)
		if (identifier as NSString).isMeantToBeColor {
			return base + identifier
		}else{
			return base + identifier + COLOR_SUFFIX
		}
	}
	
	func statementString() -> String {
		
		return String.initString(className: Settings.colorClassName, initMethodSignature: Settings.colorRGBAInitSignatureString, arguments: [red, green, blue, alpha])
	}
	
	func funcString() -> String {
		
		let formatString:NSString =
		"class func %@() -> %@ {\n" +
			"\t" + "return %@\n" +
		"}"
		
		return NSString(format: formatString, autoMethodName(), Settings.colorClassName, statementString() ) as String
	}
	
}