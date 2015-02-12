//
//  NewScanningMechanism.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 12/02/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation

class StatementModel: NSObject, Printable {
	
	var identifiers:[String] = [] //
	var names:[String] = [] // Strings within double quotation marks
	var colorCodes:[String] = []
	var numbers:[String] = []
	
	override var description:String {
		let a = join(", ", self.identifiers)
		let b = join(", ", self.names)
		let c = join(", ", self.colorCodes)
		let d = join(", ", self.numbers)
		
		return "{\(a)}, {\(b)}, {\(c)}, {\(d)}."
	}

	func add(#statementItem:String) {
		
	}
}

class SourceCodeScanner {
	
	var statementDict:[String:[StatementModel]] = Dictionary()
	var parameterDict:[String:[String]] = Dictionary()
	
	private func makeNewStatementModelForProcessMode(key:String) {
		if statementDict[key] == nil {
			statementDict[key] = []
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
	
	private func add(#parameter:String, forProcessMode key:String) {
		if parameterDict[key] == nil {
			parameterDict[key] = []
		}
		parameterDict[key]!.append(parameter)
	}
	
	func processSourceString(string:String) {
		
		let scanner = NSScanner(string: string)
		
		var currentProcessModeString:String!
		while scanner.scanLocation < count(scanner.string) {
			
			let currentChar = scanner.string.characterAtIndex(scanner.scanLocation)
			let threeCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 3)
			let twoCharString = scanner.string.safeSubstring(start: scanner.scanLocation, length: 2)
			
			let whitespaceAndNewline = NSCharacterSet.whitespaceAndNewlineCharacterSet()
			let whitespace = NSCharacterSet.whitespaceCharacterSet()
			let newline = NSCharacterSet.newlineCharacterSet()
			let newlineAndSemicolon = newline.mutableCopy().addCharactersInString(";")
			
			var resultString:NSString?
			
			if threeCharString == "!!!" {
				//This is the string after !!!, before any white space or new line characters.
				scanner.scanLocation += threeCharString.length
				scanner.scanUpToCharactersFromSet(whitespaceAndNewline, intoString: &resultString)
				if let resultString = resultString {
					currentProcessModeString = resultString as! String
				}
				
			} else if twoCharString == SINGLE_LINE_COMMENT {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToCharactersFromSet(newline, intoString: &resultString)
				
			} else if twoCharString == MULTI_LINE_COMMENT_START {
				
				scanner.scanLocation += twoCharString.length
				scanner.scanUpToString(MULTI_LINE_COMMENT_END, intoString: &resultString)
				
			} else {
				
				if currentChar == EXCLAMATION_MARK_CHAR {
					//This is a parameter
					SourceCodeScanner.pln("parameter")
					scanner.scanLocation++
					scanner.scanUpToCharactersFromSet(whitespace, intoString: &resultString)
					SourceCodeScanner.NSPln(resultString)
					scanner.scanUpToCharactersFromSet(whitespaceAndNewline, intoString: &resultString)
					SourceCodeScanner.NSPln(resultString)
				}
				
			}
			
			
			if (scanner.scanLocation < count(scanner.string)) {
				scanner.scanLocation++
			}
			
		}
		
	}
	
	class func pln(string:String) {
		
		println("---\(string)---")
	}
	class func NSPln(string:NSString?) {
		
		println("---\(string)---")
	}
}