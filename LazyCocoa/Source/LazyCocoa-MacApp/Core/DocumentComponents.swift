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
	func addStatement(statementModel:StatementModel)
	var componentString:String {get}
}

class BasicDocumentComponent : DocumentComponent, Printable {
	var statementArray = [StatementModel]()
	
	func stringFromStatement(statementModel:StatementModel) -> String {
		// Override this method
		return ""
	}
	
	func addStatement(statementModel:StatementModel) {
		statementArray.append(statementModel)
	}
	
	var componentString:String {
		var string = ""
		
		for statementModel in statementArray {
			string = string + stringFromStatement(statementModel)
		}
		
		return string
	}
	
	var description:String {
		
		return "\nComponent = <\(statementArray)>"
	}
}

class ColorAndFontComponent : DocumentComponent {
	
	class LineModel: Printable {
		
		var identifier:String = ""
		var otherNames:[String] = []
		var colorCodeString:String = ""
		var fontNameString:String = ""
		var fontSizeString:String = ""
		
		var description:String {
			let y = join(", ", self.otherNames)
			
			return "\(identifier), {\(y)}, \(colorCodeString), \(fontNameString), \(fontSizeString)"
		}
		
		convenience init(newStatementModel:StatementModel){
			self.init()
			
			if let first = newStatementModel.identifiers.first {
				identifier = first
				
				otherNames = newStatementModel.identifiers
				otherNames.removeAtIndex(0)
				
			}
			
			if let first = newStatementModel.colorCodes.first {
				colorCodeString = first
			}
			
			if let first = newStatementModel.numbers.first {
				fontSizeString = first
			}
			
			if let first = newStatementModel.names.first {
				fontNameString = first
			}
		}
		
		func populateWithOtherLineModel(model:LineModel) {
			
			if(colorCodeString.isEmpty){
				colorCodeString = model.colorCodeString
			}
			if(fontNameString.isEmpty){
				fontNameString = model.fontNameString
			}
			if(fontSizeString.isEmpty){
				fontSizeString = model.fontSizeString
			}
		}
		
		var canProduceColorFuncString:Bool{
			
			return !colorCodeString.isEmpty
		}
		
		var canProduceFontFuncString:Bool{
			
			return canProduceFontOfSizeFuncString
		}
		
		var canProduceFullFontFuncString:Bool{
			
			return !fontSizeString.isEmpty && !fontNameString.isEmpty
		}
		
		var canProduceFontOfSizeFuncString:Bool{
			
			return !fontNameString.isEmpty
		}
		
		func fontFuncString() ->String {
			if !canProduceFontFuncString {
				return ""
			}
			var model:FontModel
			
			if canProduceFullFontFuncString {
				model = FontModel(identifier: identifier, fontName: fontNameString, sizeString: fontSizeString)
			} else {
				model = FontModel(identifier: identifier, fontName: fontNameString)
			}
			return model.documentationString().stringInSwiftDocumentationStyle() + model.funcString()
		}
		
		func colorFuncString() ->String {
			if( !canProduceColorFuncString ){
				return ""
			}
			let model = ColorModel(identifier: identifier, colorHexString: colorCodeString)
			return model.documentationString().stringInSwiftDocumentationStyle() + model.funcString()
		}
	}

	
	var modelArray: Array<LineModel> = Array()
	var modelDictionary: Dictionary<String, LineModel> = Dictionary()
	
	var fontMethodsString:String {
		var fontString = ""
		
		for model in modelArray {
			if (model.canProduceFontFuncString){
				
				fontString = fontString + model.fontFuncString() + NEW_LINE_STRING + NEW_LINE_STRING
			}
		}
		
		return fontString
	}
	
	var colorMethodsString:String {
		var colorString = ""
		
		for model in modelArray {
			if (model.canProduceColorFuncString){
				
				colorString = colorString + model.colorFuncString() + NEW_LINE_STRING + NEW_LINE_STRING
			}
		}
		
		return colorString
	}
	
	func objectForKey(key:String) -> LineModel? {
		
		return modelDictionary[key]
	}
	
	func removeAllObjects() {
		
		modelArray.removeAll(keepCapacity: true)
		modelDictionary.removeAll(keepCapacity: true)
	}
	
	func prepareLineModels() {
		
		for model in modelArray {
			for name in model.otherNames {
				if let otherModel = objectForKey(name){
					model.populateWithOtherLineModel( otherModel )
				}
			}
		}
		
	}
	
	// MARK: DocumentComponent
	func addStatement(statementModel:StatementModel) {
		
		let model = LineModel(newStatementModel: statementModel)
		
		if (model.identifier.isEmpty == false) {
			modelArray.append(model)
			modelDictionary[model.identifier] = model
		}
	}
	
	var componentString:String {
		prepareLineModels()
		
		let fontFileString = String.extensionString(className: Settings.fontClassName, content: fontMethodsString)
		let colorFileString = String.extensionString(className: Settings.colorClassName, content: colorMethodsString)
		
		return "\(fontFileString)\(colorFileString)"
	}
	
}

class StringConstComponent : BasicDocumentComponent {
	
	override func stringFromStatement(statementModel:StatementModel) -> String {
		if let identifier = statementModel.identifiers.first {
			
			let name = Settings.unwrappedParameterForKey(paramKey_prefix) + identifier
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