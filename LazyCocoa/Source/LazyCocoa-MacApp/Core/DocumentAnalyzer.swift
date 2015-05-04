//
//  DocumentAnalyzer.swift
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

class DocumentAnalyzer : NSObject {
	
	var inputString = ""
	var mainResultString = ""
	var otherResultString = ""
	
	var platform:Platform!
	
	var lineContainer: LineModelContainer = LineModelContainer()
	
	let sourceScanner = SourceCodeScanner()
	
	func process(){

		sourceScanner.processSourceString(inputString)
		
		var fontFileString = ""
		var colorFileString = ""
		var constantsSwiftString = ""
		var constantsObjcHeaderString = ""
		var constantsObjcImplementationString = ""
		
		var userDefaultsString = ""
		
		var currentProcessMode = ""
		var count = Int(0)
		
		// Reset all parameters
		Settings.resetParameters()
		
		for s in sourceScanner.statementArray {
			
			if let processMode = s as? String {
				// A String representing the current process mode
				currentProcessMode = processMode
				
				count = 0;
				
			} else if let configurationModel = s as? ConfigurationModel {
			
				// Set parameters
				Settings.setParameter(value: configurationModel.value, forKey: configurationModel.key)
					
				
			} else if let statementModel = s as? StatementModel {
				// It is a StatementModel
				switch currentProcessMode {
				case processMode_colorAndFont:
					
					if count == 0 {
						// First StatementModel
						lineContainer.removeAllObjects()
						
					} else {
						
						let currentStatement = LineModel(newStatementModel: statementModel)
						lineContainer.addObject(currentStatement)
					}
					
					break
				case processMode_stringConst:
					
					if let identifier = statementModel.identifiers.first {
						
						let name = Settings.unwrappedParameterForKey(paramKey_prefix) + identifier
						let arg = Argument(object: identifier, formattingStrategy: ArgumentFormattingStrategy.StringLiteral)
						constantsSwiftString = constantsSwiftString + "let \( name ) = \(arg.formattedString)\n"
						
						constantsObjcHeaderString = constantsObjcHeaderString + "FOUNDATION_EXPORT NSString *const \( name );\n"
						
						constantsObjcImplementationString = constantsObjcImplementationString + "NSString *const \( name ) = @\(arg.formattedString);\n"
					}
					
					break
				case processMode_userDefaults:
					
					if count == 0 {
						// First StatementModel
						userDefaultsString = "struct UserDefaults { \n"
						
					} else {
						
						if let identifier = statementModel.identifiers.first {
							
							let name = Settings.unwrappedParameterForKey(paramKey_prefix) + identifier
							var returnType = "AnyObject"
							if statementModel.identifiers.count > 1 {
								returnType = statementModel.identifiers[1]
							}
							
							let keyArg = Argument(object: name, formattingStrategy: ArgumentFormattingStrategy.StringLiteral)
							
							var setterString = "set { \n" +
								"NSUserDefaults.standardUserDefaults().\( UserDefaultsGenerationManager.setMethodNameFor(type: returnType) )(newValue, forKey: \(keyArg.formattedString))".stringByIndenting(numberOfTabs: 1) +
							"\n} "
							
							var getterString = "get { \n" +
								"return NSUserDefaults.standardUserDefaults().\( UserDefaultsGenerationManager.getMethodNameFor(type: returnType) )(\(keyArg.formattedString))".stringByIndenting(numberOfTabs: 1) +
							"\n} "
							
							var funcString = "static var \(name):\(returnType) { \n" +
								(setterString + "\n" + getterString).stringByIndenting(numberOfTabs: 1) +
							"\n} "
							
							userDefaultsString = userDefaultsString + funcString.stringByIndenting(numberOfTabs: 1) + "\n\n"
						}
					}
					
					break
				default:
					
					break
				}
				
				count++
			}
		}
		
		// processMode_colorAndFont
		
		lineContainer.prepareLineModels()
		
		fontFileString = String.extensionString(className: Settings.fontClassName, content: lineContainer.fontMethodsString)
		colorFileString = String.extensionString(className: Settings.colorClassName, content: lineContainer.colorMethodsString)
		
		// processMode_userDefaults
		
		userDefaultsString = userDefaultsString + "\n} \n"
		
		//
		
		let importStatements = String.importStatementString("Foundation") + ( String.importStatementString("UIKit") )
		mainResultString = "\(Settings.headerComment)\( importStatements )\n\(constantsSwiftString)\n\(userDefaultsString)\n\(fontFileString)\(colorFileString)"

		otherResultString = "\(constantsObjcHeaderString)\n\n\(constantsObjcImplementationString)"

	}
}
