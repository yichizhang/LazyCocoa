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
	
	var inputString: String!
	var fontFileString: String!
	var colorFileString: String!
	
	var platform:Platform!
	
	var lines: LineModelContainer = LineModelContainer()
	
	func process(){

		let linesSeparatedByNewLine = self.inputString.componentsSeparatedByString("\n").filter(isNonEmpty)

		var statementStringArray:NSMutableArray = NSMutableArray(capacity: countElements(linesSeparatedByNewLine) * 2 )
		
		for string:String in linesSeparatedByNewLine {
			
			statementStringArray.addObjectsFromArray(
				string.componentsSeparatedByString(";").filter(isNonEmpty)
			)
		}

		self.lines.removeAllObjects()
		
		for object : AnyObject in statementStringArray {
			
			let currentStatement = LineModel(lineString: object as String)
			
			self.lines.addObject(currentStatement)
		}
		
		#if DEBUG
		printAll()
		#endif
		
		for model : LineModel in self.lines.modelArray {
			
			for name in model.otherNames {
				if let otherModel = self.lines.objectForKey(name){
					model.populateWithOtherLineModel( otherModel )
				}
			}
			
		}
		
		#if DEBUG
			printAll()
		#endif
		
		self.fontFileString = ""
		self.colorFileString = ""
		
		for model : LineModel in self.lines.modelArray {
			if (model.canProduceColorFuncString){
				
				self.colorFileString = self.colorFileString + model.colorFuncString() + NEW_LINE_SRING + NEW_LINE_SRING
			}
			if (model.canProduceFontFuncString){
				
				self.fontFileString = self.fontFileString + model.fontFuncString() + NEW_LINE_SRING + NEW_LINE_SRING
			}
		}
	}

	func printAll() {
		
		for model : LineModel in self.lines.modelArray {
			
			println(model)
			
		}
		
	}
}
