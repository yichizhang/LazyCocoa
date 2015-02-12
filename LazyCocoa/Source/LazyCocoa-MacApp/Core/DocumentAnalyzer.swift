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
	var mainResultString = ""
	var otherResultString = ""
	
	var platform:Platform!
	
	var lineContainer: LineModelContainer = LineModelContainer()
	
	let sourceScanner = SourceCodeScanner()
	
	func process(){

		sourceScanner.processSourceString(inputString)
		
		var fontFileString = ""
		var colorFileString = ""
		
		// Reset all parameters
		Settings.parameters = Dictionary()
		
		for processMode in acceptedProcessModes {
			
			// Set parameters
			if let parameters = sourceScanner.parameterDict[processMode] {
				for (k, v) in parameters {
					Settings.parameters[k] = v
				}
			}
			
			println(Settings.parameters)
			
			if processMode == processMode_colorAndFont {
				
				if let statementModelArray = sourceScanner.statementDict[processMode] {
					
					lineContainer.removeAllObjects()
					for statementModel in statementModelArray {
						
						let currentStatement = LineModel(newStatementModel: statementModel)
						lineContainer.addObject(currentStatement)
					}
					lineContainer.prepareLineModels()
					
					fontFileString = String.extensionString(className: Settings.fontClassName, content: lineContainer.fontMethodsString)
					colorFileString = String.extensionString(className: Settings.colorClassName, content: lineContainer.fontMethodsString)
					
				}
				
			} else if processMode == processMode_stringConst {
				
			}
			
		}
		
		mainResultString = Settings.headerComment
			+ String.importStatementString("Foundation")
			+ String.importStatementString("UIKit")
			+ NEW_LINE_STRING + NEW_LINE_STRING
			+ fontFileString
			+ colorFileString
	
		otherResultString = "HAHA"
	}
}
