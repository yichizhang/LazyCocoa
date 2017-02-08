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

class ConfigurationModel: CustomStringConvertible {
	
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

class StatementModel: CustomStringConvertible {
	
	var added = false
	
	var index:Int = -1
	var identifiers:[String] = []
	// Strings within double quotation marks; "strings that contains white spaces"
	var names:[String] = []
	var colorCodes:[String] = []
	var numbers:[String] = []
	
	func copy() -> StatementModel {
		let s = StatementModel()
		s.index = self.index
		s.identifiers = self.identifiers
		s.names = self.names
		s.colorCodes = self.colorCodes
		s.numbers = self.numbers
		
		return s
	}
	
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
				return "(" + array.joined(separator: ", ") + ")"
			}
		}
		
		return "\n<Statement #\(index): IDS = \(arrayToString(identifiers)), names = \(arrayToString(names)), colorCodes = \(arrayToString(colorCodes)), numbers = \(arrayToString(numbers))>"
	}

	func add(statementItem:String) {
		
		if statementItem.isValidNumber {
			numbers.append(statementItem)
		} else if statementItem.isValidColorCode {
			colorCodes.append(statementItem)
		} else {
			identifiers.append(statementItem)
		}
	}
	
	func addAsName(statementItem:String) {
		names.append(statementItem)
	}
}

class SourceCodeScanner {
	
	// statementArray contains StatementModel, ConfigurationModel and String objects
	var statementArray = [AnyObject]()
	
	var statementCounter = 0
	var currentStatementModel:StatementModel!
	
	fileprivate func addProcessMode(_ processMode:String) {
		statementArray.append(processMode as AnyObject)
	}
	
	fileprivate func createNewStatementModel() {
		currentStatementModel = StatementModel()
	}
	
	fileprivate func addCurrentStatementModel() {
		if !currentStatementModel.added && !currentStatementModel.isEmpty {
			statementArray.append(currentStatementModel)
      statementCounter += 1
			currentStatementModel.index = statementCounter
			currentStatementModel.added = true
		}
	}

	fileprivate func add(statementItem:String) {
		currentStatementModel.add(statementItem: statementItem)
	}
	
	fileprivate func addAsName(statementItem:String) {
		currentStatementModel.addAsName(statementItem: statementItem)
	}
	
	fileprivate func addParameter(parameterKey:String, parameterValue:String) {
		
		statementArray.append(ConfigurationModel(key: parameterKey, value: parameterValue))
	}
	
	func processSourceString(_ string:String) {
		
		statementArray.removeAll(keepingCapacity: true)
		
		statementCounter = 0
		currentStatementModel = StatementModel()
		
		let scanner = Scanner(string: string)
		
		let whitespaceAndNewline = CharacterSet.whitespacesAndNewlines
		let whitespace = CharacterSet.whitespaces
		let newline = CharacterSet.newlines
		
		let whitespaceNewlineAndSemicolon = (whitespaceAndNewline as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
		whitespaceNewlineAndSemicolon.addCharacters(in: ";")
		
		let newlineAndSemicolon = (newline as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
		newlineAndSemicolon.addCharacters(in: ";")
		
		var resultString:NSString?
		
		while scanner.scanLocation < scanner.string.characters.count {
			
			let currentChar = scanner.string.characterAtIndex(scanner.scanLocation)
			let twoCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 2)
			let threeCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 3)
			
			if threeCharString == "!!!" {
				//This is the string after !!!, before any white space or new line characters.
				scanner.scanLocation += threeCharString.length
				scanner.scanUpToCharacters(from: whitespaceAndNewline, into: &resultString)
				if let resultString = resultString {
					addProcessMode(resultString as String)
				}
				
			} else if twoCharString == StringConst.SigleLineComment {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToCharacters(from: newline, into: &resultString)
				
			} else if twoCharString == StringConst.MultiLineCommentStart {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpTo(StringConst.MultiLineCommentEnd, into: &resultString)
				scanner.scanLocation += StringConst.MultiLineCommentEnd.length
				
			} else if twoCharString == "!!" {
				
				//This is a parameter
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToCharacters(from: whitespace, into: &resultString)
				let parameterKey = resultString
				scanner.scanUpToCharacters(from: newline, into: &resultString)
				let parameterValue = resultString
				
				if parameterKey != nil && parameterValue != nil {
					let processedParameterValue = (parameterValue as! String).stringByRemovingSingleLineComment()
					self.addParameter(parameterKey: parameterKey as! String, parameterValue: processedParameterValue)
				}
				
			} else {
				
				if currentChar == Character(StringConst.DoubleQuote) {
					
					scanner.scanLocation += 1
					scanner.scanUpTo(StringConst.DoubleQuote, into: &resultString)
					scanner.scanLocation += StringConst.DoubleQuote.length
					
					addAsName(statementItem: resultString as! String)
					
				} else
        {
					scanner.scanUpToCharacters(from: whitespaceNewlineAndSemicolon as CharacterSet, into: &resultString)
					
					add(statementItem: resultString as! String)
				}
				
			}
			
			var oneCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 1)
			
			if oneCharString.containsCharactersInSet(newlineAndSemicolon as CharacterSet) {
				addCurrentStatementModel()
				createNewStatementModel()
			}
			
			while scanner.scanLocation < scanner.string.characters.count
			&& oneCharString.containsCharactersInSet(whitespaceNewlineAndSemicolon as CharacterSet)
			{
				scanner.scanLocation += 1
				oneCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 1)
			}
		}
		
		addCurrentStatementModel()
		
		// println("--\n\n\n--")
		// println(self.statementArray)
	}
}
