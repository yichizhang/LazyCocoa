/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Foundation

class LineModel: NSObject, Printable {

	var identifier:String = ""
	var otherNames:[String] = []
	var colorCodeString:String = ""
	var fontNameString:String = ""
	var fontSizeString:String = ""
	
	override var description:String {
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