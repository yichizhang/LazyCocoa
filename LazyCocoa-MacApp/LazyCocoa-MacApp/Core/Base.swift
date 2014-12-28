/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

enum Language : String {
	case ObjC = "objc"
	case Swift = "swift"
}

enum Platform : Int {
	case iOS = 0
	case MacOS
}

enum GenerationOption : Int {
	case Color = 0
	case Font
}

protocol CanBeConvertedToObjC {
	func objcHeaderStringWithoutSemicolon() ->String;
	func objcHeaderString() ->String;
	func objcImplementationString() ->String;
}

protocol CanBeConvertedToSwift {
	func swiftString() ->String;
}

protocol BaseModelProtocol {
	
	func classFactoryMethodString(mode:Language) -> String;
}

protocol ReferToOtherProtocol {
	
	//var otherIdentifier:String { get }
}

class BaseModel : NSObject {
	
	var identifier = "someIdentifier"
	func autoMethodName() -> String {
		return self.autoMethodNameForIdentifier(self.identifier)
	}
	func autoMethodNameForIdentifier(id:String) -> String {
		return id + self.dynamicType.methodSuffix()
	}
	class func methodSuffix() -> String {
		
		fatalError("You must override this method")
		return "Suffix"
	}

}

