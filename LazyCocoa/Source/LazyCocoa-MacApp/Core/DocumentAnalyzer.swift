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

class ConfigurationsManager {
	
	private var configurationsDictionary = [String: String]()
	
	func removeAll() {
		configurationsDictionary.removeAll(keepCapacity: true)
	}
	
	func setValue(value:String, forKey key:String) {
		configurationsDictionary[key] = value
	}
	
	func valueForKey(key:String) -> String? {
		return configurationsDictionary[key]
	}
	
	func unwrappedValueForKey(key:String) -> String {
		if let val = self.valueForKey(key) {
			return val
		} else {
			return ""
		}
	}
}

class NewConfigurationsManager {
	
	class Configuration : Printable {
		var key : String!
		var value : String!
		var startIndex : Int!
		var endIndex : Int!
		
		init(key:String, value:String, startIndex:Int, endIndex:Int) {
			self.key = key
			self.value = value
			self.startIndex = startIndex
			self.endIndex = endIndex
		}
		
		var description:String {
			return "\n<key = \(key), value = \(value), pos = (\(startIndex) ~ \(endIndex))>"
		}
	}
	
	private var values = [Configuration]()
	
	func removeAll() {
		values.removeAll(keepCapacity: true)
	}
	
	func setValue(value:String, forKey key:String, startIndex:Int) {
		var i = values.count - 1
		
		if let configuration = valueForKey(key) {
			configuration.endIndex = startIndex - 1
		}
		
		values.append(
			Configuration(
				key: key,
				value: value,
				startIndex: startIndex,
				endIndex: Int.max
			)
		)
	}
	
	func valueForKey(key:String, forIndex index:Int? = nil) -> Configuration? {
		var i = values.count - 1
		
		while (i>=0) {
			let configuration = values[i]
			
			if key == configuration.key {
				
				if let index = index {
					
					if index >= configuration.startIndex &&
						 index <= configuration.endIndex {
							return configuration
					}
				} else {
					return configuration
				}
			}
			
			i--
		}
		
		return nil
	}
}

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
		
		var userName = Global.configurations.valueForKey(ParamKey.UserName) ?? "User"
		var companyName = Global.configurations.valueForKey(ParamKey.OrganizationName) ?? "The Lazy Cocoa Project"
		
		return
			"//  \n" +
			"//  \(self.exportTo.lastPathComponent) \n" +
			"//  \(Global.messageString) \n" +
			"// \n//  Created by \(userName) on \(dateString). \n" +
			"//  Copyright (c) \(yearString) \(companyName). All rights reserved. \n" +
			"// \n\n"
	}
	
	var documentString:String {
		var string = headerComment
		
		string +=
			String.importStatementString("Foundation") +
			( String.importStatementString(Global.platform == .iOS ? "UIKit" : "AppKit") ) +
			StringConst.NewLine
		
		for component in components {
			string = string + component.componentString
		}
		
		return string
	}
	
	var description:String {
		
		return "\n\(components)"
	}
}

class DocumentAnalyzer : ConfigurationProtocol {
	
	var inputString = ""
	var platform:Platform!
	
	var sourceCodeDocuments = [SourceCodeDocument]()
	let sourceScanner = SourceCodeScanner()
	
	var newConfigurations = NewConfigurationsManager()
	
	func process(){

		sourceScanner.processSourceString(inputString)
		
		Global.configurations.removeAll()
		newConfigurations.removeAll()
		
		sourceCodeDocuments.removeAll(keepCapacity: true)
		
		var currentProcessMode = ""
		
		for (index, s) in enumerate(sourceScanner.statementArray) {
			
			if let processMode = s as? String {
				// A String representing the current process mode
				currentProcessMode = processMode
				
			} else if let configurationModel = s as? ConfigurationModel {
			
				if configurationModel.key == ParamKey.ExportTo {
					
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
				
				// Set global parameters
				Global.configurations.setValue(configurationModel.value, forKey: configurationModel.key)
				
				newConfigurations.setValue(configurationModel.value, forKey: configurationModel.key, startIndex: index)
				
			} else if let statementModel = s as? StatementModel {
				
				// It is a StatementModel
				statementModel.index = index
				
				var currentDocument:SourceCodeDocument!
				
				if sourceCodeDocuments.last == nil {
					// "sourceCodeDocuments" does not have any documents.
					// Add an empty one.
					currentDocument = SourceCodeDocument()
					sourceCodeDocuments.append(currentDocument)
				} else {
					currentDocument = sourceCodeDocuments.last!
				}
				
				// Current Document does not have any components
				var component:DocumentComponent!
				
				if currentDocument.components.count < 1 {
					
					switch currentProcessMode {
					case ProcessMode.ColorAndFont:
						component = ColorAndFontComponent()
						break
					case ProcessMode.StringConst:
						component = StringConstComponent()
						break
					case ProcessMode.UserDefaults:
						component = UserDefaultsComponent()
						break
					default:
						
						break
					}
					
					currentDocument.components.append(component)
					component.cofigurationDelegate = self
				}
				
				if let last = currentDocument.components.last {
					if !statementModel.isEmpty {
						last.addStatement(statementModel)
					}
				}
			}
		}
		
		println(newConfigurations.values)
	}
	
	// Configuration Protocol
	func configurationFor(object: AnyObject, key: String, index: Int) -> String {
		return newConfigurations.valueForKey(key, forIndex: index)?.value ?? ""
	}
}
