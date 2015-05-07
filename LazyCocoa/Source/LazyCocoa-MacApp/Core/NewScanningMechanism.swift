//
//  NewScanningMechanism.swift
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

import Foundation

class ConfigurationModel: Printable {
	
	var key = ""
	var value = ""
	
	init(key:String, value:String) {
		self.key = key
		self.value = value
	}
	
	var description:String {
		
		return "\n<Configuration: Key = \(key), Value = \(value)>"
	}
}

class StatementModel: Printable {
	
	var identifiers:[String] = []
	// Strings within double quotation marks; "strings that contains white spaces"
	var names:[String] = []
	var colorCodes:[String] = []
	var numbers:[String] = []
	
	var isEmpty:Bool {
		if identifiers.count + names.count + colorCodes.count + numbers.count > 0 {
			return false
		} else {
			return true
		}
	}
	
	var description:String {
		
		let arrayToString = { (array:[String]) -> String in
			if array.isEmpty {
				return "NONE"
			} else {
				return "(" + join(", ", array) + ")"
			}
		}
		
		return "\n<Statement: IDS = \(arrayToString(identifiers)), names = \(arrayToString(names)), colorCodes = \(arrayToString(colorCodes)), numbers = \(arrayToString(numbers))>"
	}

	func add(#statementItem:String) {
		
		if statementItem.isValidNumber {
			numbers.append(statementItem)
		} else if statementItem.isValidColorCode {
			colorCodes.append(statementItem)
		} else {
			identifiers.append(statementItem)
		}
	}
	
	func addAsName(#statementItem:String) {
		names.append(statementItem)
	}
}

class SourceCodeScanner {
	
	var currentProcessMode = ""
	// statementArray contains StatementModel, ConfigurationModel and String objects
	var statementArray = [AnyObject]()
	
	private func appendNewStatementModelForProcessMode(processMode:String) {
		
		if currentProcessMode != processMode {
			statementArray.append(processMode)
			currentProcessMode = processMode
		}
		
		if let last = statementArray.last as? StatementModel {
			if last.isEmpty == true {
				return
			}
		}
		statementArray.append( StatementModel() )
	}

	private func add(#statementItem:String, forProcessMode key:String) {
		
		if let last = statementArray.last as? StatementModel {
			
		} else {
			appendNewStatementModelForProcessMode(key)
		}
		
		if let last = statementArray.last as? StatementModel {
			last.add(statementItem: statementItem)
		}
	}
	
	private func addAsName(#statementItem:String, forProcessMode key:String) {
		
		if let last = statementArray.last as? StatementModel {
			
		} else {
			appendNewStatementModelForProcessMode(key)
		}
		
		if let last = statementArray.last as? StatementModel {
			last.addAsName(statementItem: statementItem)
		}
	}
	
	private func addParameter(#parameterKey:String, parameterValue:String, forProcessMode key:String) {
		
		statementArray.append(ConfigurationModel(key: parameterKey, value: parameterValue))
	}
	
	func processSourceString(string:String) {
		
		statementArray.removeAll(keepCapacity: true)
		
		let scanner = NSScanner(string: string)
		
		let whitespaceAndNewline = NSCharacterSet.whitespaceAndNewlineCharacterSet()
		let whitespace = NSCharacterSet.whitespaceCharacterSet()
		let newline = NSCharacterSet.newlineCharacterSet()
		
		let whitespaceNewlineAndSemicolon = whitespaceAndNewline.mutableCopy() as! NSMutableCharacterSet
		whitespaceNewlineAndSemicolon.addCharactersInString(";")
		
		let newlineAndSemicolon = newline.mutableCopy() as! NSMutableCharacterSet
		newlineAndSemicolon.addCharactersInString(";")
		
		var currentProcessModeString:String!
		var resultString:NSString?
		
		while scanner.scanLocation < count(scanner.string) {
			
			let currentChar = scanner.string.characterAtIndex(scanner.scanLocation)
			let threeCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 3)
			let twoCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 2)
			
			if threeCharString == "!!!" {
				//This is the string after !!!, before any white space or new line characters.
				scanner.scanLocation += threeCharString.length
				scanner.scanUpToCharactersFromSet(whitespaceAndNewline, intoString: &resultString)
				if let resultString = resultString {
					currentProcessModeString = resultString as String
				}
				
			} else if twoCharString == StringConst.SigleLineComment {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToCharactersFromSet(newline, intoString: &resultString)
				
			} else if twoCharString == StringConst.MultiLineCommentStart {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToString(StringConst.MultiLineCommentEnd, intoString: &resultString)
				scanner.scanLocation += StringConst.MultiLineCommentEnd.length
				
			} else if twoCharString == "!!" {
				
				//This is a parameter
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToCharactersFromSet(whitespace, intoString: &resultString)
				let parameterKey = resultString
				scanner.scanUpToCharactersFromSet(newline, intoString: &resultString)
				let parameterValue = resultString
				
				if parameterKey != nil && parameterValue != nil {
					let processedParameterValue = (parameterValue as! String).stringByRemovingSingleLineComment()
					self.addParameter(parameterKey: parameterKey as! String, parameterValue: processedParameterValue, forProcessMode: currentProcessModeString)
				}
				
			} else {
				
				if currentChar == Character(StringConst.DoubleQuote) {
					
					scanner.scanLocation++
					scanner.scanUpToString(StringConst.DoubleQuote, intoString: &resultString)
					scanner.scanLocation += StringConst.DoubleQuote.length
					
					addAsName(statementItem: resultString as! String, forProcessMode: currentProcessModeString)
					
				} else {
					scanner.scanUpToCharactersFromSet(whitespaceNewlineAndSemicolon, intoString: &resultString)
					
					add(statementItem: resultString as! String, forProcessMode: currentProcessModeString)
				}
				
			}
			
			var oneCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 1)
			
			if oneCharString.containsCharactersInSet(newlineAndSemicolon) {
				appendNewStatementModelForProcessMode(currentProcessModeString)
			}
			
			while scanner.scanLocation < count(scanner.string)
			&& oneCharString.containsCharactersInSet(whitespaceNewlineAndSemicolon)
			{
				scanner.scanLocation++
				oneCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 1)
			}
		}
		
		println("--\n\n\n--")
		println(self.statementArray)
	}
}