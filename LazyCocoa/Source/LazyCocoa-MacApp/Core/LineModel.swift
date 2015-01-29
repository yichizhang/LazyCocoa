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
	var otherNames:Array<String> = []
	var colorCodeString:String = ""
	var fontNameString:String = ""
	var fontSizeString:String = ""
	
	func description() -> String {
		
		let y = (self.otherNames as NSArray).componentsJoinedByString("; ")
		
		return NSString(format: "%@, {%@}, %@, %@, %@.", self.identifier, y, self.colorCodeString, self.fontNameString, self.fontSizeString)
	}
	
	convenience init(lineString:String){
		self.init()
		
		var processedString = lineString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
		
		if let range = processedString.rangeOfString(COMMENT_PREFIX) {
			processedString = processedString.substringToIndex(
			 range.startIndex
			)
		}
		
		let scanner = NSScanner(string: processedString)
		var resultString:NSString?
		
		while ( scanner.scanLocation < countElements(scanner.string) ) {
		
			let character = scanner.string.characterAtIndex(scanner.scanLocation)
			
			if (character == DOUBLE_QUOTE_CHAR) {
				
				scanner.scanLocation++
				scanner.scanUpToString(DOUBLE_QUOTE_STRING, intoString: &resultString)
				
				fontNameString = resultString!
				
			}else {
				
				scanner.scanUpToString(SPACE_STRING, intoString: &resultString)
				
				if ( resultString!.isValidNumber ) {
					fontSizeString = resultString!
				}else if ( resultString!.isValidColorCode ) {
					colorCodeString = resultString!
				}else {
					if ( identifier.isEmpty ) {
						identifier = resultString!;
					}else {
						otherNames.append(resultString!);
					}
				}
				
			}
			
			if (scanner.scanLocation < countElements(scanner.string)) {
				scanner.scanLocation++
			}
			
		}
		
	}
	
	func populateWithOtherLineModel(model:LineModel) {
		
		if(self.colorCodeString.isEmpty){
			self.colorCodeString = model.colorCodeString
		}
		if(self.fontNameString.isEmpty){
			self.fontNameString = model.fontNameString
		}
		if(self.fontSizeString.isEmpty){
			self.fontSizeString = model.fontSizeString
		}
	}
	
	var canProduceColorFuncString:Bool{
		
		return !self.colorCodeString.isEmpty
	}
	
	var canProduceFontFuncString:Bool{
		
		return canProduceFontOfSizeFuncString
	}
	
	var canProduceFullFontFuncString:Bool{
		
		return !self.fontSizeString.isEmpty && !self.fontNameString.isEmpty
	}
	
	var canProduceFontOfSizeFuncString:Bool{
		
		return !self.fontNameString.isEmpty
	}
	
	func fontFuncString() ->String {
		if !canProduceFontFuncString {
			return ""
		}
		var model:FontModel
		
		if canProduceFullFontFuncString {
			model = FontModel(identifier: self.identifier, fontName: self.fontNameString, sizeString: self.fontSizeString)
		} else {
			model = FontModel(identifier: self.identifier, fontName: self.fontNameString)
		}
		return model.funcString()
	}
	
	func colorFuncString() ->String {
		if( !self.canProduceColorFuncString ){
			return ""
		}
		let model = ColorModel(identifier: self.identifier, colorHexString: self.colorCodeString);
		return model.funcString()
	}
}