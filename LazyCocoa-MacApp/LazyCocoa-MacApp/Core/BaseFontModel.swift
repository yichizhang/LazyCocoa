/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

protocol FontModelProtocol : CanBeConvertedToObjC, CanBeConvertedToSwift {
	
	func uifontString(mode:GenerationMode) -> String;
	
}

class BaseFontModel : BaseModel, FontModelProtocol {
	
	var methodName = "someFont"
	
	func objcHeaderStringWithoutSemicolon() ->String {
		return "+ (UIFont *)\(self.methodName)"
	}
	
	func objcHeaderString() ->String {
		return self.objcHeaderStringWithoutSemicolon() + ";"
	}
	
	func objcImplementationString() ->String {
		
		let formatString:NSString =
		"%@() {\n" +
			"\t" + "return %@;" +
		"\n}"
		
		return NSString(format: formatString, self.objcHeaderStringWithoutSemicolon(), self.uifontString(GenerationMode.ObjC)) as String
	}
	
	func swiftString() ->String {
		
		let formatString:NSString =
		"class func %@() -> UIFont {\n" +
			"\t" + "return %@;" +
		"\n}"
		
		return NSString(format: formatString, self.methodName, self.uifontString(GenerationMode.Swift)) as String
	}
	
	func uifontString(mode:GenerationMode) -> String {
		
		fatalError("You must override this method")
		return "";
		
	}
	
}
