//
//  DocumentComponents.swift
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

protocol DocumentComponent {
	init(delegate:ConfigurationProtocol)
	
	func addStatement(_ statementModel:StatementModel)
	func addStatements(_ statementModelArray:[AnyObject])
	func configurationForKey(_ key:String, index:Int) -> String
	
	var componentString:String {get}
	weak var configurationDelegate:ConfigurationProtocol? {get set}
}

protocol BaseModelProtocol {

	func autoMethodName() -> String
	func statementString() -> String
	func documentationString() -> String
	func funcString() -> String
}

protocol ConfigurationProtocol : class{
	
	func configurationFor(_ object:AnyObject, key:String, index:Int) -> String
}

class BasicDocumentComponent : DocumentComponent, CustomStringConvertible {
	
	var statementArray = [StatementModel]()
	weak var configurationDelegate:ConfigurationProtocol?
	
	required init(delegate:ConfigurationProtocol) {
		self.configurationDelegate = delegate
	}
	
	func configurationForKey(_ key:String, index:Int) -> String {
		return configurationDelegate?.configurationFor(self, key: key, index: index) ?? ""
	}
	
	func stringFromStatement(_ statementModel:StatementModel) -> String {
		// Override this method
		return ""
	}
	
	func addStatement(_ statementModel:StatementModel) {
		statementArray.append(statementModel)
	}
	
	func addStatements(_ statementModelArray:[AnyObject]) {
		for o in statementModelArray {
			if let s = o as? StatementModel {
				addStatement(s)
			}
		}
	}
	
	func prepareStatements() {
		
	}
	
	var componentString:String {
		var string = ""
		
		prepareStatements()
		
		for statementModel in statementArray {
			string = string + stringFromStatement(statementModel)
		}
		
		return string
	}
	
	var description:String {
		
		return "\nComponent = <\(statementArray)>"
	}
}

class ColorAndFontComponent : BasicDocumentComponent {
	
	var modelDictionary = [String:StatementModel]()
	
	var fontMethodsString:String {
		var fontString = ""
		
		for statementModel in statementArray {
			// statementModel.numbers --- fontSizeString
			// statementModel.names --- fontNameString
			
			// Can produce "font of size" func string or "full" func string
			if let fontName = statementModel.names.first {
				if let identifier = statementModel.identifiers.first {
				
					var fontSizeString:String? = statementModel.numbers.first
					
					let prefix = configurationForKey(ParamKey.Prefix, index: statementModel.index)
					
					var documentationString = "Font name: \(fontName)"
					if let fontSizeString = fontSizeString {
						documentationString += ", font size: \(fontSizeString)"
					}
					
					let firstParameter:Argument = Argument(object: fontName as AnyObject, formattingStrategy: .stringLiteral )
					var secondParameter:AnyObject = fontSizeString as AnyObject? ?? "size" as AnyObject
					
					let statementString = String.initString(className:Global.fontClassName, initMethodSignature: Global.fontNameAndSizeInitSignatureString, arguments: [firstParameter, secondParameter])
					
					let funcString = "class func " + prefix + identifier +
						(identifier.isMeantToBeFont ? "" : StringConst.FontSuffix) +
						(fontSizeString == nil ? "OfSize(size:CGFloat)" : "()") + " -> \(Global.fontClassName) {\n" +
						"\t" + "return \(statementString)!\n" +
						"}"
						
					fontString +=
						documentationString.stringInSwiftDocumentationStyle() +
						funcString + StringConst.NewLine + StringConst.NewLine
				}
			}
		}
		
		return fontString
	}
	
	var colorMethodsString:String {
		var colorString = ""
		
		for statementModel in statementArray {
			
			// statementModel.colorCodes --- colorCodeString
			if let colorCodeString = statementModel.colorCodes.first {
				if let identifier = statementModel.identifiers.first {
					
					let prefix = configurationForKey(ParamKey.Prefix, index: statementModel.index)
					
					let documentationString = "Color code: \(colorCodeString)"
					
					let colorComponentArray = ColorFormatter.componentArrayFrom(colorCodeString)
					let statementString = String.initString(className: Global.colorClassName, initMethodSignature: Global.colorRGBAInitSignatureString, arguments: colorComponentArray as [AnyObject])
					
					let funcString = "class func " + prefix + identifier +
						(identifier.isMeantToBeColor ? "" : StringConst.ColorSuffix) +
						"() -> \(Global.colorClassName) {\n" +
						"\t" + "return \(statementString)\n" +
					"}"
					
					colorString +=
						documentationString.stringInSwiftDocumentationStyle() +
						funcString + StringConst.NewLine + StringConst.NewLine
					
				}
			}
		}
		
		return colorString
	}
	
	func objectForKey(_ key:String) -> StatementModel? {
		
		return modelDictionary[key]
	}
	
	func removeAllObjects() {
		
		statementArray.removeAll(keepingCapacity: true)
		modelDictionary.removeAll(keepingCapacity: true)
	}
	
	override func prepareStatements() {
		
		for model in statementArray {
			var count = 0
			for name in model.identifiers {
				if count >= 1 {
					
					// Populate with other statement model
					if let otherModel = objectForKey(name){
						
						// colorCodeString
						if model.colorCodes.isEmpty {
							if let otherFirst = otherModel.colorCodes.first{
								model.colorCodes.append(otherFirst)
							}
						}
						// fontNameString
						if model.names.isEmpty {
							if let otherFirst = otherModel.names.first{
								model.names.append(otherFirst)
							}
						}
						// fontSizeString
						if model.numbers.isEmpty {
							if let otherFirst = otherModel.numbers.first{
								model.numbers.append(otherFirst)
							}
						}
					}
				}
				count += 1
			}
		}
		
	}
	
	// MARK: DocumentComponent
	override func addStatement(_ statementModel:StatementModel) {
		
		if let identifier = statementModel.identifiers.first {
			let s = statementModel.copy()
			
			statementArray.append(s)
			modelDictionary[identifier] = s
		}
	}
	
	override var componentString:String {
		prepareStatements()
		
		let fontFileString = String.extensionString(className: Global.fontClassName, content: fontMethodsString)
		let colorFileString = String.extensionString(className: Global.colorClassName, content: colorMethodsString)
		
		return "\(fontFileString)\(colorFileString)"
	}
	
}

class StringConstComponent : BasicDocumentComponent {
	
	/*
	constantsObjcHeaderString = constantsObjcHeaderString + "FOUNDATION_EXPORT NSString *const \( name );\n"
	
	constantsObjcImplementationString = constantsObjcImplementationString + "NSString *const \( name ) = @\(arg.formattedString);\n"
	*/
	override func stringFromStatement(_ statementModel:StatementModel) -> String {
		if let identifier = statementModel.identifiers.first {
			
			let name = configurationForKey(ParamKey.Prefix, index: statementModel.index) + identifier
			let arg = Argument(object: identifier as AnyObject, formattingStrategy: ArgumentFormattingStrategy.stringLiteral)
			
			return "let \( name ) = \(arg.formattedString)\n"
			
		} else {
			
			return ""
		}
	}
}

class UserDefaultsComponent : BasicDocumentComponent {
	
	override func stringFromStatement(_ statementModel:StatementModel) -> String {
		if let identifier = statementModel.identifiers.first {
			
			let name = configurationForKey(ParamKey.Prefix, index: statementModel.index) + identifier
			var returnType = "AnyObject"
			if statementModel.identifiers.count > 1 {
				returnType = statementModel.identifiers[1]
			}
			
			let keyArg = Argument(object: name as AnyObject, formattingStrategy: ArgumentFormattingStrategy.stringLiteral)
			
      let format =
        "set {\n" +
          "\t" + "if let newValue = newValue {\n" +
          "\t" + "\t" + "NSUserDefaults.standardUserDefaults().%@(newValue, forKey: %@)\n" +
          "\t" + "}\n" +
        "}"
      
			var setterString = NSString(
				format: format as NSString,
				UserDefaultsGenerationManager.setMethodNameFor(type: returnType),
				keyArg.formattedString
				) as String
			
			var getterString =
				"get {\n" +
					UserDefaultsGenerationManager.getMethodStringFor(type: returnType, keyArg: keyArg).stringByIndenting(numberOfTabs: 1) +
				"\n}"
			
			var funcString = "static var \(name):\(returnType)? { \n" +
				(setterString + "\n" + getterString).stringByIndenting(numberOfTabs: 1) +
			"\n} "
			
			return funcString.stringByIndenting(numberOfTabs: 1) + "\n\n"
		} else {
			
			return ""
		}
	}
	
	override var componentString:String {
		var string = "struct UserDefaults { \n"
		
		for statementModel in statementArray {
			string = string + stringFromStatement(statementModel)
		}
		
		string = string + "\n} \n"
		
		return string
	}
}
