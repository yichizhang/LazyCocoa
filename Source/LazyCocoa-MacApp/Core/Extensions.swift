//
//  Extensions.swift
//  The Lazy Cocoa Project
//
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Cocoa

extension NSTextView {
	func setUpTextStyleWith(_ fontName:String = "Monaco", size:CGFloat = 12) {
		
		let myFont:NSFont = NSFont(name: fontName, size: size)!
		isContinuousSpellCheckingEnabled = false
		isAutomaticQuoteSubstitutionEnabled = false
		enabledTextCheckingTypes = 0
		isRichText = false
		font = myFont
		
		textStorage?.font = myFont
	}
	
	func setUpForDisplayingSourceCode() {
		var size:CGFloat = 12
		
		if let sizeString = Global.configurations.valueForKey(ParamKey.WindowFontSize){
			size = CGFloat( (sizeString as NSString).floatValue )
		}
		
		self.setUpTextStyleWith(size: size)
    }
}


extension String {
	var isValidNumber:Bool {
		let setOfNonNumberCharacters = (CharacterSet.decimalDigits.inverted as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
		setOfNonNumberCharacters.removeCharacters(in: ".")
		
		if( self.containsCharactersInSet(setOfNonNumberCharacters as CharacterSet) ){
			return false
		}
		return true
		
	}
	var isValidColorCode:Bool {
		
		return hasPrefix(StringConst.Hash)
	}
	var isMeantToBeComment:Bool {
		
		return hasPrefix(StringConst.SigleLineComment)
	}
	var isMeantToBeFont:Bool {
		
		return hasSuffix(StringConst.FontSuffix)
	}
	var isMeantToBeColor:Bool {
		
		return hasSuffix(StringConst.ColorSuffix)
	}
	
	var length:Int{
		
		return self.characters.count
	}
	
	func containsCharactersInSet(_ set:CharacterSet) -> Bool {
		
		if let range = self.rangeOfCharacter(from: set) {
			return true
		}
		return false
		
	}
	
	static func extensionString(className:String, content:String) -> String {
		return "extension \(className) { \n\n\(content.stringByIndenting(numberOfTabs: 1))\n} \n\n"
	}
	
	static func importStatementString(_ string:String) -> String {
		return "import \(string)\n"
	}
	
	static func initString(className:String, initMethodSignature:String, arguments:[AnyObject] ) -> String {
		// FIXME: ---
		var args:[Argument] = Array()
		
		for n in arguments {
			if let float = n as? Float {
				args.append( Argument(object: CGFloat(float) as AnyObject, formattingStrategy: .cgFloatNumber) )
			} else if let float = n as? CGFloat {
				args.append( Argument(object: CGFloat(float) as AnyObject, formattingStrategy: .cgFloatNumber) )
			} else if let str = n as? String {
				args.append( Argument(object: str as AnyObject, formattingStrategy: .name) )
			} else if let a = n as? Argument {
				args.append( a )
			} else {
				args.append( Argument(object: "__ERROR__" as AnyObject, formattingStrategy: .name) )
			}
		}
		
		var string = "\(className)("
		
		let m = initMethodSignature.components(separatedBy: ":")
		
		for (i, n) in m.enumerated() {
			if i < args.count {
				string = string + n + ":" + args[i].formattedString
			}
			if i < args.count - 1 {
				string = string + ", "
			}
		}
		
		string = string + ")"
		
		return string
	}
	
	static func methodString(methodSignature:String, parameters:[AnyObject], returnType:String, statements:String ) -> String {
		let string = ""
		return string
	}
	
	func characterAtIndex(_ index:Int) -> Character{
		
		return Array(self.characters)[index]
	}
	
	func safeSubstring(start:Int, length len:Int) -> String {
		//WORKS
		let nsstring = self as NSString
		let maxLength = min( len, nsstring.length - start )
		return (nsstring.substring(with: NSMakeRange(start, maxLength) ) as String)
		
		//DOES NOT WORK
		//		let range = Range(start: advance(self.startIndex, start),
		//			end: advance(self.startIndex, start + min(length, count(self) - start) )
		//			)
		//		return self.substringWithRange(range)
		
		//
		//		return self.substringWithRange(Range<String.Index>(start: advance(self.startIndex, startIndex), end: advance(self.startIndex, startIndex + min(length, count(self) - startIndex ) ) ) )
	}
	
	func stringByIndenting(numberOfTabs:Int) -> String {
		
		let array = self.components(separatedBy: "\n")
		let newArray = array.map({ (string) -> String in
			var newString = ""
			for _ in 0..<numberOfTabs {
				newString += "\t"
			}
			newString += string
			
			return newString
		})
		
		return newArray.joined(separator: "\n")
	}
	
	func stringInSwiftDocumentationStyle() -> String {
		return "/** \n" + self.stringByIndenting(numberOfTabs:1) + "\n*/\n"
	}
	
	func stringByRemovingSingleLineComment() -> String {
		let nsstring = self as NSString
		
		let range = nsstring.range(of: StringConst.SigleLineComment)
		
		if range.location == NSNotFound {
			return self
		} else {
			return nsstring.substring(to: range.location) as String
		}
	}
	
	func stringByTrimmingWhiteSpaceAndNewLineCharacters() -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
}

extension NSString {
	var fullRange:NSRange {
		return NSMakeRange(0, self.length)
	}
}
