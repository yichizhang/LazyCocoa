/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

class FontModel : BaseModel, BaseModelProtocol{
	
	var typefaceName:String!
	var fontSize:Float!
	
	convenience init(identifier:String, fontName:String, sizeString:String){
		self.init()
		self.identifier = identifier
		self.typefaceName = fontName
		self.fontSize = (sizeString as NSString).floatValue
	}
	
	convenience init(identifier:String, fontName:String, sizeFloat:Float){
		self.init()
		self.identifier = identifier
		self.typefaceName = fontName
		self.fontSize = sizeFloat
	}
	
	func autoMethodName() -> String {
		
		if (self.identifier as NSString).isMeantToBeFont {
			return self.identifier
		}else{
			return self.identifier + FONT_SUFFIX
		}
	}
	
	func statementString() -> String {
		
		return NSString(
			format: "UIFont(name:\"%@\", size:%.1f)",
			self.typefaceName,
			self.fontSize
			) as String
	}
	
	func funcString() -> String {
		
		let formatString:NSString =
		"class func %@() -> UIFont {\n" +
			"\t" + "return %@;" +
		"\n}"
		
		return NSString(format: formatString, self.autoMethodName(), self.statementString()) as String
	}

	
}
