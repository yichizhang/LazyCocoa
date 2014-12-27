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
	var objcHeaderFileString: String!
	var objcImplementationFileString: String!
	var swiftFileString: String!
	
	var statementsContainer: StatementsContainer = StatementsContainer()
	
	func process(){

		let linesSeparatedByNewLine = self.inputString.componentsSeparatedByString("\n").filter(isNonEmpty)

		var statementStringArray:NSMutableArray = NSMutableArray(capacity: countElements(linesSeparatedByNewLine) * 2 )
		
		for string:String in linesSeparatedByNewLine {
			
			statementStringArray.addObjectsFromArray(
				string.componentsSeparatedByString(";").filter(isNonEmpty)
			)
		}

		self.statementsContainer.removeAllObjects()
		
		for object : AnyObject in statementStringArray {
			
			let currentStatement = StatementModel(string: object as String)
			
			self.statementsContainer.addObject(currentStatement)
		}
		
		var objcHString = String();
		var objcMString = String();
		var swiftString = String();
		
		for statementModel : StatementModel in self.statementsContainer.modelArray {
			
			if ( statementModel.color != nil ){
		
				objcHString += statementModel.color!.objcHeaderString()
				objcMString += statementModel.color!.objcImplementationString()
				swiftString += statementModel.color!.swiftString()
				
				objcHString += "\n\n"
				objcMString += "\n\n"
				swiftString += "\n\n"
			}
			
			if ( statementModel.font != nil ) {
				
				objcHString += statementModel.font!.objcHeaderString()
				objcMString += statementModel.font!.objcImplementationString()
				swiftString += statementModel.font!.swiftString()
				
				objcHString += "\n\n"
				objcMString += "\n\n"
				swiftString += "\n\n"
			}
			
		}
		
		self.objcHeaderFileString = objcHString;
		self.objcImplementationFileString = objcMString;
		self.swiftFileString = swiftString
		;
		
		
	}
	
}
