//
//  NewScanningMechanism.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 12/02/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation

let processMode_colorAndFont = "colorAndFont"
let processMode_stringConst = "stringConst"
let processMode_userDefaults = "userDefaults"

let acceptedProcessModes = [processMode_colorAndFont, processMode_stringConst, processMode_userDefaults]

class StatementModel: NSObject, Printable {
	
	var identifiers:[String] = [] //
	var names:[String] = [] // Strings within double quotation marks; "strings that contains white spaces"
	var colorCodes:[String] = []
	var numbers:[String] = []
	
	var isEmpty:Bool {
		if identifiers.count + names.count + colorCodes.count + numbers.count > 0 {
			return false
		} else {
			return true
		}
	}
	
	override var description:String {
		var desc = "\n"
		if !identifiers.isEmpty {
			desc = desc + "IDS: " + join(", ", identifiers) + "; "
		}
		if !names.isEmpty {
			desc = desc + "names: " + join(", ", names) + "; "
		}
		if !colorCodes.isEmpty {
			desc = desc + "colorCodes: " + join(", ", colorCodes) + "; "
		}
		if !numbers.isEmpty {
			desc = desc + "numbers: " + join(", ", numbers) + "; "
		}
		
		return desc
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
	
	var statementDict:[String:[StatementModel]] = Dictionary()
	var parameterDict:[String:[String:String]] = Dictionary()
	
	private func makeNewStatementModelForProcessMode(key:String) {
		if statementDict[key] == nil {
			statementDict[key] = []
		}
		
		if let last = statementDict[key]!.last {
			if last.isEmpty == true {
				return
			}
		}
		statementDict[key]!.append( StatementModel() )
	}

	private func add(#statementItem:String, forProcessMode key:String) {
		if statementDict[key] == nil {
			makeNewStatementModelForProcessMode(key)
		} else if statementDict[key]!.isEmpty{
			makeNewStatementModelForProcessMode(key)
		}
		
		statementDict[key]!.last!.add(statementItem: statementItem)
	}
	
	private func addAsName(#statementItem:String, forProcessMode key:String) {
		if statementDict[key] == nil {
			makeNewStatementModelForProcessMode(key)
		} else if statementDict[key]!.isEmpty{
			makeNewStatementModelForProcessMode(key)
		}
		
		statementDict[key]!.last!.addAsName(statementItem: statementItem)
	}
	
	private func addParameter(#parameterKey:String, parameterValue:String, forProcessMode key:String) {
		if parameterDict[key] == nil {
			parameterDict[key] = Dictionary()
		}
		parameterDict[key]![parameterKey] = parameterValue
	}
	
	func processSourceString(string:String) {
		
		parameterDict.removeAll(keepCapacity: true)
		statementDict.removeAll(keepCapacity: true)
		
		let scanner = NSScanner(string: string)
		
		
		let whitespaceAndNewline = NSCharacterSet.whitespaceAndNewlineCharacterSet()
		let whitespace = NSCharacterSet.whitespaceCharacterSet()
		let newline = NSCharacterSet.newlineCharacterSet()
		
		let whitespaceNewlineAndSemicolon = whitespaceAndNewline.mutableCopy() as NSMutableCharacterSet
		whitespaceNewlineAndSemicolon.addCharactersInString(";")
		
		let newlineAndSemicolon = newline.mutableCopy() as NSMutableCharacterSet
		newlineAndSemicolon.addCharactersInString(";")
		
		var currentProcessModeString:String!
		var resultString:NSString?
		
		while scanner.scanLocation < countElements(scanner.string) {
			
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
				
			} else if twoCharString == SINGLE_LINE_COMMENT {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToCharactersFromSet(newline, intoString: &resultString)
				
			} else if twoCharString == MULTI_LINE_COMMENT_START {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToString(MULTI_LINE_COMMENT_END, intoString: &resultString)
				scanner.scanLocation += MULTI_LINE_COMMENT_END.length
				
			} else if twoCharString == "!!" {
				
				//This is a parameter
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToCharactersFromSet(whitespace, intoString: &resultString)
				let parameterKey = resultString
				scanner.scanUpToCharactersFromSet(newline, intoString: &resultString)
				let parameterValue = resultString
				
				if parameterKey != nil && parameterValue != nil {
					let processedParameterValue = (parameterValue as String).stringByRemovingSingleLineComment()
					self.addParameter(parameterKey: parameterKey as String, parameterValue: processedParameterValue, forProcessMode: currentProcessModeString)
				}
				
			} else {
				
				if currentChar == DOUBLE_QUOTE_CHAR {
					
					scanner.scanLocation++
					scanner.scanUpToString(DOUBLE_QUOTE_STRING, intoString: &resultString)
					scanner.scanLocation += DOUBLE_QUOTE_STRING.length
					
//					SourceCodeScanner.pln("!!!")
//					SourceCodeScanner.NSPln(resultString)
					
					addAsName(statementItem: resultString as String, forProcessMode: currentProcessModeString)
					
				} else {
					scanner.scanUpToCharactersFromSet(whitespaceNewlineAndSemicolon, intoString: &resultString)
					
//					SourceCodeScanner.pln("XXX")
//					SourceCodeScanner.NSPln(resultString)
					
					
					add(statementItem: resultString as String, forProcessMode: currentProcessModeString)
				}
				
			}
			
			var oneCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 1)
			
			if oneCharString.containsCharactersInSet(newlineAndSemicolon) {
				makeNewStatementModelForProcessMode(currentProcessModeString)
			}
			
			while scanner.scanLocation < countElements(scanner.string)
			&& oneCharString.containsCharactersInSet(whitespaceNewlineAndSemicolon)
			{
				scanner.scanLocation++
				oneCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 1)
			}
		}
		
		
		println("--\n\n\n--")
		println(self.parameterDict)
		
		println("--\n\n\n--")
		println(self.statementDict)
	}
	
	class func pln(string:String) {
		
		println("---\(string)---")
	}
	class func NSPln(string:NSString?) {
		if let string = string {
			
			println("---\(string)---")
		} else {
			println("!!!nil!!!")
		}
	}
}