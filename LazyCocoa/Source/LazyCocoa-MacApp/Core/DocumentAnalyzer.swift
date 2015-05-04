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

class SourceCodeDocument : Printable {
	
	var exportTo = ""
	
	var components = [DocumentComponent]()
	
	var headerComment:String {
		let dateFormatter = NSDateFormatter()
		let date = NSDate()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		let dateString = dateFormatter.stringFromDate(date)
		dateFormatter.dateFormat = "yyyy"
		let yearString = dateFormatter.stringFromDate(date)
		
		return
			"//  \n" +
			"//  \(self.exportTo.lastPathComponent) \n" +
			"//  \(Settings.messageString) \n" +
			"// \n//  Created by \(Settings.userName) on \(dateString). \n" +
			"//  Copyright (c) \(yearString) \(Settings.companyName). All rights reserved. \n" +
			"// \n\n"
	}
	
	var documentString:String {
		var string = headerComment
		
		string = string + String.importStatementString("Foundation") + ( String.importStatementString("UIKit") ) + NEW_LINE_STRING
		
		for component in components {
			string = string + component.componentString
		}
		
		return string
	}
	
	var description:String {
		
		return "\n\(components)"
	}
}

class DocumentAnalyzer {
	
	var inputString = ""
	
	var platform:Platform!
	
	var lineContainer: ColorAndFontComponent = ColorAndFontComponent()
	
	var sourceCodeDocuments = [SourceCodeDocument]()
	let sourceScanner = SourceCodeScanner()
	
	func process(){

		sourceScanner.processSourceString(inputString)
		
		sourceCodeDocuments.removeAll(keepCapacity: true)
		
		var currentProcessMode = ""
		
		// Reset all parameters
		Settings.resetParameters()
		
		for s in sourceScanner.statementArray {
			
			if let processMode = s as? String {
				// A String representing the current process mode
				currentProcessMode = processMode
				
			} else if let configurationModel = s as? ConfigurationModel {
			
				// Set parameters
				Settings.setParameter(value: configurationModel.value, forKey: configurationModel.key)
				
				if configurationModel.key == paramKey_exportTo {
					
					var addNewDocument = false
					
					if let last = sourceCodeDocuments.last {
						if last.exportTo != "" && last.exportTo != configurationModel.value {
							addNewDocument = true
						}
					} else {
						addNewDocument = true
					}
					
					if addNewDocument {
						
						let document = SourceCodeDocument()
						sourceCodeDocuments.append(document)
						document.exportTo = configurationModel.value
					} else {
						
						sourceCodeDocuments.last!.exportTo = configurationModel.value
					}
				}
				
			} else if let statementModel = s as? StatementModel {
				
				// It is a StatementModel
				
				var currentDocument:SourceCodeDocument!
				
				if sourceCodeDocuments.last == nil {
					// "sourceCodeDocuments" does not have any documents.
					// Add an empty one.
					currentDocument = SourceCodeDocument()
					sourceCodeDocuments.append(currentDocument)
				} else {
					currentDocument = sourceCodeDocuments.last!
				}
				
				if currentDocument.components.count < 1 {
					// First StatementModel
					
					switch currentProcessMode {
					case processMode_colorAndFont:
						currentDocument.components.append(ColorAndFontComponent())
						break
					case processMode_stringConst:
						currentDocument.components.append(StringConstComponent())
						/*
						constantsObjcHeaderString = constantsObjcHeaderString + "FOUNDATION_EXPORT NSString *const \( name );\n"
						
						constantsObjcImplementationString = constantsObjcImplementationString + "NSString *const \( name ) = @\(arg.formattedString);\n"
						*/
						break
					case processMode_userDefaults:
						currentDocument.components.append(UserDefaultsComponent())
						break
					default:
						
						break
					}
				}
				
				if let last = currentDocument.components.last {
					if !statementModel.isEmpty {
						last.addStatement(statementModel)
					}
				}
			}
		}

	}
}
