//
//  UIE.swift
//  LazyCocoa-MacApp
//
//  Created by YICHI ZHANG on 9/02/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Cocoa

extension NSTextView {
	func setUpTextStyleWith(fontName:String = "Monaco", size:CGFloat = 12) {
		
		let myFont:NSFont = NSFont(name: fontName, size: size)!
		continuousSpellCheckingEnabled = false
		automaticQuoteSubstitutionEnabled = false
		enabledTextCheckingTypes = 0
		richText = false
		font = myFont
		
		textStorage?.font = myFont
	}
	
	func setUpForDisplayingSourceCode() {
		var size:CGFloat = 12
		
		if let sizeString = Settings.parameterForKey(paramKey_windowFontSize){
			size = CGFloat( (sizeString as NSString).floatValue )
		}
		
		self.setUpTextStyleWith(size: size)
    }
}


extension String {
	var isValidNumber:Bool {
		var setOfNonNumberCharacters = NSCharacterSet.decimalDigitCharacterSet().invertedSet.mutableCopy() as NSMutableCharacterSet
		setOfNonNumberCharacters.removeCharactersInString(".")
		
		if( self.containsCharactersInSet(setOfNonNumberCharacters) ){
			return false
		}
		return true
		
	}
	var isValidColorCode:Bool {
		
		return hasPrefix(HASH_STRING)
	}
	var isMeantToBeComment:Bool {
		
		return hasPrefix(COMMENT_PREFIX)
	}
	var isMeantToBeFont:Bool {
		
		return hasSuffix(FONT_SUFFIX)
	}
	var isMeantToBeColor:Bool {
		
		return hasSuffix(COLOR_SUFFIX)
	}
	var isMeantToBeNeitherFontOrColor:Bool {
		
		return !(isMeantToBeFont && isMeantToBeColor)
	}
	
	
	var length:Int{
		
		return countElements(self)
	}
	
	func containsCharactersInSet(set:NSCharacterSet) -> Bool {
		
		// FIXME: Use Swift native String
		let range = (self as NSString).rangeOfCharacterFromSet(set)
		if(range.location == NSNotFound){
			// Does not contain characters in set
			return false
		}
		return true
		
	}
	
	static func extensionString(#className:String, content:String) -> String {
		
		return "extension \(className) { \n\n\(content.stringByIndenting(numberOfTabs: 1))\n} \n\n"
		
		//		return "extension \(className) { " + NEW_LINE_STRING + NEW_LINE_STRING +
		//		content + "} " + NEW_LINE_STRING + NEW_LINE_STRING
	}
	
	static func importStatementString(string:String) -> String {
		return "import \(string)\n"
	}
	
	static func initString(#className:String, initMethodSignature:String, arguments:[Any?] ) -> String {
		// FIXME: ---
		var args:[Argument] = Array()
		
		for (i, n) in enumerate(arguments) {
			if let float = n as? Float {
				args.append( Argument(object: CGFloat(float), formattingStrategy: .CGFloatNumber) )
			} else if let float = n as? CGFloat {
				args.append( Argument(object: CGFloat(float), formattingStrategy: .CGFloatNumber) )
			} else if let str = n as? String {
				args.append( Argument(object: str, formattingStrategy: .Name) )
			} else if let a = n as? Argument {
				args.append( a )
			} else {
				args.append( Argument(object: "__ERROR__", formattingStrategy: .Name) )
			}
		}
		
		var string = "\(className)("
		
		let m = initMethodSignature.componentsSeparatedByString(":")
		
		for (i, n) in enumerate(m) {
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
	
	static func methodString(#methodSignature:String, parameters:[AnyObject], returnType:String, statements:String ) -> String {
		var string = ""
		return string
	}
	
	func characterAtIndex(index:Int) -> Character{
		
		return Array(self)[index]
	}
	
	func safeSubstring(#start:Int, length len:Int) -> String {
		//WORKS
		let nsstring = self as NSString
		let maxLength = min( len, nsstring.length - start )
		return (nsstring.substringWithRange(NSMakeRange(start, maxLength) ) as String)
		
		//DOES NOT WORK
		//		let range = Range(start: advance(self.startIndex, start),
		//			end: advance(self.startIndex, start + min(length, count(self) - start) )
		//			)
		//		return self.substringWithRange(range)
		
		//
		//		return self.substringWithRange(Range<String.Index>(start: advance(self.startIndex, startIndex), end: advance(self.startIndex, startIndex + min(length, count(self) - startIndex ) ) ) )
	}
	
	func stringByIndenting(#numberOfTabs:Int) -> String {
		
		let array = self.componentsSeparatedByString("\n")
		let newArray = array.map({ (string) -> String in
			var newString = ""
			for _ in 0..<numberOfTabs {
				newString += "\t"
			}
			newString += string
			
			return newString
		})
		
		return "\n".join(newArray)
	}
	
	func stringInSwiftDocumentationStyle() -> String {
		return "/** \n" + self.stringByIndenting(numberOfTabs:1) + "\n*/\n"
	}
	
	func stringByRemovingSingleLineComment() -> String {
		let nsstring = self as NSString
		
		let range = nsstring.rangeOfString(SINGLE_LINE_COMMENT)
		
		if range.location == NSNotFound {
			return self
		} else {
			return nsstring.substringToIndex(range.location) as String
		}
	}
	
	func stringByTrimmingWhiteSpaceAndNewLineCharacters() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
}

extension String {
	func hasMatchesFor(#regexString:String) -> Bool {
		var result = false
		let selfString = self as NSString
		// I'm a bit concerned with doing thing like NSMakeRange(0, countElements(self))
		
		if let regex = NSRegularExpression(pattern: regexString, options: NSRegularExpressionOptions.allZeros, error: nil) {
			if let firstMatch = regex.firstMatchInString(selfString, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, selfString.length)) {
				result = true
			}
		}
		
		return result
	}
	
	static func stringInBundle(#name:String, ofType type: String = "txt", encoding: UInt = NSUTF8StringEncoding) -> String? {
		if let path = NSBundle.mainBundle().pathForResource(name, ofType: type, inDirectory: nil) {
			if let data = NSData(contentsOfFile: path) {
				return NSString(data: data, encoding: encoding)
			}
		}
		return nil
	}
}