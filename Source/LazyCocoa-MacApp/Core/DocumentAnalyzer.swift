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
			configuration.endIndex = startIndex
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
	
	func valueForKey(key:String, startIndex:Int, endIndex:Int) -> Configuration? {
		var i = 0
		
		while ( i < values.count ) {
			let configuration = values[i]
			
			if configuration.key == key {
				
				if startIndex == configuration.startIndex &&
					( (endIndex == configuration.endIndex) || endIndex < configuration.endIndex ){
						return configuration
				}
			}
			
			i++
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
		
		string += String.importStatementString("Foundation")
		string += String.importStatementString(Global.configurations.unwrappedValueForKey(ParamKey.Platform) == "MacOS" ? "AppKit" : "UIKit")
		string += StringConst.NewLine
		
		for component in components {
			string = string + component.componentString + StringConst.NewLine + StringConst.NewLine
		}
		
		return string
	}
	
	var description:String {
		
		return "\n\(components)"
	}
	
	func export(#basePath:String) -> String {
		if exportTo.isEmpty == false {
			
			var error:NSError?
			let exportPath = exportTo.stringByTrimmingWhiteSpaceAndNewLineCharacters()
			
			let fullExportPath = basePath.stringByAppendingPathComponent(exportPath)
			
			documentString.writeToFile(fullExportPath, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
			
			if let error = error {
				return "Failed to export:  \(fullExportPath)"
			} else {
				return "Exported successfully:  \(fullExportPath)"
			}
		} else {
			return "Failed to export, export path is not set. Use `!!exportPath` to set it.\nExample:\n\n!!!stringConst\n!!exportTo StringConst.swift\nweb_id; name; email; contact_details; location; position; work_unit"
		}
	}
}

class DocumentAnalyzer : ConfigurationProtocol {
	
	var inputString = ""
	
	var sourceCodeDocuments = [SourceCodeDocument]()
	let sourceScanner = SourceCodeScanner()
	
	var newConfigurations = NewConfigurationsManager()
	
	func process(){
		
		var lastStatementModelIndex = -1
		
		sourceScanner.processSourceString(inputString)
		
		Global.configurations.removeAll()
		newConfigurations.removeAll()
		
		sourceCodeDocuments.removeAll(keepCapacity: true)
		
		for s in sourceScanner.statementArray {
			
			if let processMode = s as? String {
				
				// A String representing the current process mode
				newConfigurations.setValue(processMode, forKey: ParamKey.ProcessMode, startIndex: lastStatementModelIndex+1)
				
			} else if let configurationModel = s as? ConfigurationModel {
			
				Global.configurations.setValue(configurationModel.value, forKey: configurationModel.key)
				newConfigurations.setValue(configurationModel.value, forKey: configurationModel.key, startIndex: lastStatementModelIndex+1)
				
			} else if let statementModel = s as? StatementModel {
				
				// It is a StatementModel
				// FIXME: Remove this
				lastStatementModelIndex = statementModel.index
				
			}
		}
		
		if Global.configurations.unwrappedValueForKey(ParamKey.Platform) == "MacOS" {
			Global.fontClassName = "NSFont"
			Global.colorClassName = "NSColor"
			
			Global.colorRGBAInitSignatureString = "calibratedRed:green:blue:alpha:"
		} else {
			Global.fontClassName = "UIFont"
			Global.colorClassName = "UIColor"
			
			Global.colorRGBAInitSignatureString = "red:green:blue:alpha:"
		}
		
		Global.fontNameAndSizeInitSignatureString = "name:size:"
		
		// FIXME
		sourceScanner.statementArray = sourceScanner.statementArray.filter { (o) -> Bool in
			return o.isKindOfClass(StatementModel.self)
		}
		//
		
		var currentDocument = SourceCodeDocument()
		sourceCodeDocuments.append(currentDocument)
		
		var i = 0
		
		while (i < newConfigurations.values.count) {
			let configuration = newConfigurations.values[i]
			
			if configuration.key == ParamKey.ProcessMode {
				
				var component:DocumentComponent!
				
				switch configuration.value {
				case ProcessMode.ColorAndFont:
					component = ColorAndFontComponent(delegate: self)
					break
				case ProcessMode.StringConst:
					component = StringConstComponent(delegate: self)
					break
				case ProcessMode.UserDefaults:
					component = UserDefaultsComponent(delegate: self)
					break
				default:
					i++
					continue
				}
				
				var startIndex = configuration.startIndex
				
				if i == 0 {
					startIndex = 0
				}
				
				var endIndex = configuration.endIndex
				
				if endIndex > sourceScanner.statementArray.count {
					endIndex = sourceScanner.statementArray.count
				}
				
				let a = Array(sourceScanner.statementArray[startIndex..<endIndex])
				component.addStatements(a)
				
				if let c = newConfigurations.valueForKey(ParamKey.ExportTo, startIndex: startIndex, endIndex: endIndex) {
					
					if currentDocument.exportTo == "" {
						currentDocument.exportTo = c.value
						
					} else if currentDocument.exportTo != c.value {
						
						currentDocument = SourceCodeDocument()
						currentDocument.exportTo = c.value
						sourceCodeDocuments.append(currentDocument)
					}
				}
				
				currentDocument.components.append(component)
			}
			
			i++
		}
		
		// println(newConfigurations.values)
	}
	
	// Configuration Protocol
	func configurationFor(object: AnyObject, key: String, index: Int) -> String {
		return newConfigurations.valueForKey(key, forIndex: index)?.value ?? ""
	}
}
