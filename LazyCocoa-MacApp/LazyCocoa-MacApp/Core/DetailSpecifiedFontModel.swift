/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

class DetailSpecifiedFontModel : BaseFontModel {
	
	var typefaceName:String!
	var fontSize:Float!
	
	convenience init(methodName:String, fontName:String, size:Float){
		
		self.init()
		self.methodName = methodName
		self.typefaceName = fontName
		self.fontSize = size
	}
	
	func statementWithFormatString(formatString:String) -> String {
		
		return NSString(
			format: formatString as NSString,
			self.typefaceName,
			self.fontSize
			) as String
	}
	
	override func uifontString(mode:Language) -> String {
		
		var formatString:String!
		
		if (mode == Language.ObjC) {
			formatString = "[UIFont fontWithName:@\"%@\" size:%.2f]"
		} else if (mode == Language.Swift) {
			formatString = "UIFont(name:\"%@\", size:%.2f)"
		}

		return self.statementWithFormatString(formatString)
		
	}

}
