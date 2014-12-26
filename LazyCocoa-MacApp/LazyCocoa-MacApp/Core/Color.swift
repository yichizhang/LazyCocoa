/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

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
		
		let formatString:NSString =
		"%@() {\n" +
			"\t" + "return %@;" +
		"\n}"
		
		return NSString(format: formatString, self.objcHeaderStringWithoutSemicolon(), self.uicolorString(objcMode)) as String
	}
	
	func swiftString() ->String {
		
		let formatString:NSString =
		"class func %@() -> UIColor {\n" +
		"\t" + "return %@;" +
		"\n}"
		
		return NSString(format: formatString, self.name, self.uicolorString(swiftMode)) as String
	}
	
	func uicolorString(mode:Int) -> String {
		
		if (self.valueString.hasPrefix("#")){
			
			let colorModel = ColorModel(colorHexString: self.valueString)
			
			var formatString:NSString!
			
			// How to achieve something like 1.000 -> 1.0; 1.123456789 -> 1.123 ?
			if (mode == objcMode) {
				formatString = "[UIColor colorWithRed:%.3f green:%.3f blue:%.3f alpha:%.3f]"
			} else if (mode == swiftMode) {
				formatString = "UIColor(red:%.3f, green:%.3f, blue:%.3f, alpha:%.3f)"
			}
			
			return colorModel.statementWithFormatString(formatString)
			
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
