/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

let HASH_STRING = "#"
let DOUBLE_QUOTE_CHAR = Character("\"")
let DOUBLE_QUOTE_STRING = "\""
let SPACE_STRING = " "
let NEW_LINE_STRING = "\n"
let FONT_SUFFIX = "Font"
let COLOR_SUFFIX = "Color"
let COMMENT_PREFIX = "//"

enum Platform : Int {
	case iOS = 0
	case MacOS
}

protocol BaseModelProtocol {
	
	func autoMethodName() -> String;
	func statementString() -> String;
	func funcString() -> String;
}

class BaseModel : NSObject {
	
	var identifier = "someIdentifier"

}

extension NSString {
	
	var isValidNumber:Bool {
		var set: NSMutableCharacterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet.mutableCopy() as NSMutableCharacterSet
		set.removeCharactersInString(".")
		let range = (self as NSString).rangeOfCharacterFromSet(set)
		if(range.location == NSNotFound){
			return true
		}
		return false
		
	}
	var isValidColorCode:Bool {
		
		return self.hasPrefix(HASH_STRING)
	}
	var isMeantToBeComment:Bool {
		
		return self.hasPrefix(COMMENT_PREFIX)
	}
	var isMeantToBeFont:Bool {
		
		return self.hasSuffix(FONT_SUFFIX)
	}
	var isMeantToBeColor:Bool {
		
		return self.hasSuffix(COLOR_SUFFIX)
	}
	var isMeantToBeNeitherFontOrColor:Bool {
		
		return !(self.isMeantToBeFont && self.isMeantToBeColor);
	}
}

extension String {
	func characterAtIndex(index:Int) -> Character{
		
		return Array(self)[index]
	}
	var length:Int{
		
		return countElements(self)
	}
}