/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

func isNonEmpty(item:String)->Bool {
	return !isEmpty(item)
}

class DocumentAnalyzer : NSObject {
	
	var inputString = ""
	var fontFileString = ""
	var colorFileString = ""
	
	var platform:Platform!
	
	var lines: LineModelContainer = LineModelContainer()
	
	func process(){

		let linesSeparatedByNewLine = inputString.componentsSeparatedByString("\n").filter(isNonEmpty)

		var statementStringArray:NSMutableArray = NSMutableArray(capacity: countElements(linesSeparatedByNewLine) * 2 )
		
		let exportToPrefix = "!exportTo "
		
		Settings.exportPath = nil
		
		for string:String in linesSeparatedByNewLine {
			
			if string.hasPrefix(exportToPrefix) {
				
				Settings.exportPath = (string as NSString).substringFromIndex( countElements(exportToPrefix) )
				
//				Settings.exportPath = string.substringFromIndex( countElements(exportToPrefix) )

			} else if string.hasPrefix(DOUBLE_QUOTE_STRING) {
				
				
				
			} else {
				statementStringArray.addObjectsFromArray(
					string.componentsSeparatedByString(";").filter(isNonEmpty)
				)
			}
		}

		lines.removeAllObjects()
		
		for object : AnyObject in statementStringArray {
			
			let currentStatement = LineModel(lineString: object as String)
			
			lines.addObject(currentStatement)
		}
		
		#if DEBUG
		printAll()
		#endif
		
		for model : LineModel in lines.modelArray {
			
			for name in model.otherNames {
				if let otherModel = lines.objectForKey(name){
					model.populateWithOtherLineModel( otherModel )
				}
			}
			
		}
		
		#if DEBUG
			printAll()
		#endif
		
		let baseFileFormatString = "extension %@ {\n\n%@}\n\n"
		var fontString = ""
		var colorString = ""
		
		for model : LineModel in lines.modelArray {
			if (model.canProduceColorFuncString){
				
				colorString = colorString + model.colorFuncString().stringByIndenting(numberOfTabs: 1) + NEW_LINE_STRING + NEW_LINE_STRING
			}
			if (model.canProduceFontFuncString){
				
				fontString = fontString + model.fontFuncString().stringByIndenting(numberOfTabs: 1) + NEW_LINE_STRING + NEW_LINE_STRING
			}
		}
		
		fontFileString = NSString(format: baseFileFormatString, Settings.fontClassName, fontString) as String
		colorFileString = NSString(format: baseFileFormatString, Settings.colorClassName, colorString) as String
	}

	func printAll() {
		
		for model : LineModel in lines.modelArray {
			
			println(model)
			
		}
		
	}
}
