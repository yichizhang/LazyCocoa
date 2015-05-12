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
	
	func addStatement(statementModel:StatementModel)
	func addStatements(statementModelArray:[AnyObject])
	func configurationForKey(key:String, index:Int) -> String
	
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
	
	func configurationFor(object:AnyObject, key:String, index:Int) -> String
}

class BasicDocumentComponent : DocumentComponent, Printable {
	
	var statementArray = [StatementModel]()
	weak var configurationDelegate:ConfigurationProtocol?
	
	required init(delegate:ConfigurationProtocol) {
		self.configurationDelegate = delegate
	}
	
	func configurationForKey(key:String, index:Int) -> String {
		return configurationDelegate?.configurationFor(self, key: key, index: index) ?? ""
	}
	
	func stringFromStatement(statementModel:StatementModel) -> String {
		// Override this method
		return ""
	}
	
	func addStatement(statementModel:StatementModel) {
		statementArray.append(statementModel)
	}
	
	func addStatements(statementModelArray:[AnyObject]) {
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
	
	class BaseModel {
		
		var identifier = "someIdentifier"
		var base = ""
	}

	class ColorModel : BaseModel, BaseModelProtocol{
		
		var colorHexString:String!
		var colorComponentArray:[CGFloat]!
		
		convenience init(identifier:String, colorHexString:String){
			self.init()
			
			self.identifier = identifier
			self.colorHexString = colorHexString
			self.colorComponentArray = ColorFormatter.componentArrayFrom(hexString: colorHexString)
		}
		
		func autoMethodName() -> String {
			if identifier.isMeantToBeColor {
				return base + identifier
			}else{
				return base + identifier + StringConst.ColorSuffix
			}
		}
		
		func statementString() -> String {
			return String.initString(className: Global.colorClassName, initMethodSignature: Global.colorRGBAInitSignatureString, arguments: colorComponentArray)
		}
		
		func documentationString() -> String {
			return "Color code: \(colorHexString)"
		}
		
		func funcString() -> String {
			
			let formatString:NSString =
			"class func %@() -> %@ {\n" +
				"\t" + "return %@\n" +
			"}"
			
			return NSString(format: formatString, autoMethodName(), Global.colorClassName, statementString() ) as String
		}
		
	}
	
	class FontModel : BaseModel, BaseModelProtocol{
		
		var typefaceName:String!
		var fontSize:Float?
		
		convenience init(identifier:String, fontName:String){
			self.init()
			self.identifier = identifier
			self.typefaceName = fontName
		}
		
		convenience init(identifier:String, fontName:String, sizeString:String){
			self.init()
			self.identifier = identifier
			self.typefaceName = fontName
			self.fontSize = (sizeString as NSString).floatValue
		}
		
		convenience init(identifier:String, fontName:String, sizeFloat:Float){
			self.init()
			self.identifier = identifier
			self.typefaceName = fontName
			self.fontSize = sizeFloat
		}
		
		func autoMethodName() -> String {
			if identifier.isMeantToBeFont {
				return base + identifier
			}else{
				return base + identifier + StringConst.FontSuffix
			}
		}
		
		func statementString() -> String {
			
			let firstParameter:Argument = Argument(object: typefaceName, formattingStrategy: .StringLiteral )
			var secondParameter:AnyObject!
			
			if let fontSize = fontSize {
				secondParameter = fontSize
			} else {
				secondParameter = "size"
			}
			
			let statementString = String.initString(className:Global.fontClassName, initMethodSignature: Global.fontNameAndSizeInitSignatureString, arguments: [firstParameter, secondParameter])
			
			return statementString
		}
		
		func documentationString() -> String {
			var string:String!
			if let fontSize = fontSize {
				string = "Font name: \(typefaceName), font size: \(fontSize)"
			} else {
				string = "Font name: \(typefaceName)"
			}
			return string
		}
		
		func funcString() -> String {
			
			var formatString:NSString
			
			if let fontSize = fontSize {
				
				formatString =
					"class func %@() -> %@ {\n" +
					"\t" + "return %@!\n" +
				"}"
				
			} else {
				
				// NO FONT SIZE PROVIDED
				formatString =
					"class func %@OfSize(size:CGFloat) -> %@ {\n" +
					"\t" + "return %@!\n" +
				"}"
				
			}
			
			return NSString(format: formatString, autoMethodName(), Global.fontClassName, statementString()) as String
		}
		
		
	}
	
	var modelDictionary = [String:StatementModel]()
	
	var fontMethodsString:String {
		var fontString = ""
		
		for statementModel in statementArray {
			// statementModel.numbers --- fontSizeString
			// statementModel.names --- fontNameString
			
			// Can produce "font of size" func string or "full" func string
			if let fontName = statementModel.names.first{
				var fontModel:FontModel!
				
				// Can produce "full" font func string
				if let fontSizeString = statementModel.numbers.first {
					fontModel = FontModel(
						identifier: statementModel.identifiers.first!,
						fontName: fontName,
						sizeString: fontSizeString
					)
				} else {
					fontModel = FontModel(
						identifier: statementModel.identifiers.first!,
						fontName: fontName
					)
				}
				
				fontModel.base = configurationForKey(ParamKey.Prefix, index: statementModel.index)
					
				fontString +=
					fontModel.documentationString().stringInSwiftDocumentationStyle() +
					fontModel.funcString() + StringConst.NewLine + StringConst.NewLine
			}
		}
		
		return fontString
	}
	
	var colorMethodsString:String {
		var colorString = ""
		
		for statementModel in statementArray {
			var colorModel:ColorModel!
			
			// statementModel.colorCodes --- colorCodeString
			if let colorCodeString = statementModel.colorCodes.first {
				
				colorModel = ColorModel(
					identifier: statementModel.identifiers.first!,
					colorHexString: colorCodeString
				)
				
				colorModel.base = configurationForKey(ParamKey.Prefix, index: statementModel.index)
				
				colorString +=
					colorModel.documentationString().stringInSwiftDocumentationStyle() +
					colorModel.funcString() + StringConst.NewLine + StringConst.NewLine
			}
		}
		
		return colorString
	}
	
	func objectForKey(key:String) -> StatementModel? {
		
		return modelDictionary[key]
	}
	
	func removeAllObjects() {
		
		statementArray.removeAll(keepCapacity: true)
		modelDictionary.removeAll(keepCapacity: true)
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
				count++
			}
		}
		
	}
	
	// MARK: DocumentComponent
	override func addStatement(statementModel:StatementModel) {
		
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
	override func stringFromStatement(statementModel:StatementModel) -> String {
		if let identifier = statementModel.identifiers.first {
			
			let name = configurationForKey(ParamKey.Prefix, index: statementModel.index) + identifier
			let arg = Argument(object: identifier, formattingStrategy: ArgumentFormattingStrategy.StringLiteral)
			
			return "let \( name ) = \(arg.formattedString)\n"
			
		} else {
			
			return ""
		}
	}
}

class UserDefaultsComponent : BasicDocumentComponent {
	
	override func stringFromStatement(statementModel:StatementModel) -> String {
		if let identifier = statementModel.identifiers.first {
			
			let name = configurationForKey(ParamKey.Prefix, index: statementModel.index) + identifier
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