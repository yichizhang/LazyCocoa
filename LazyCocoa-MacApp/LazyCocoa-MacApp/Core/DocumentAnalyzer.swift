/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Cocoa

class DocumentAnalyzer {
	
	var inputString: String!
	var objcHeaderFileString: String!
	var objcImplementationFileString: String!
	var swiftFileString: String!
	
	var colorArray: Array<Color>!
	
	init (){
		self.colorArray = Array()
	}
	
	func process(){
		
		let allLines = self.inputString.componentsSeparatedByString("\n")

		self.colorArray.removeAll(keepCapacity: true)
		
		for string:String in allLines {
			let items = string.componentsSeparatedByString(" ")
			
			var color: Color = Color()
			
			if (items.count > 0){
				
				color.name = items[0]
				
				if (items.count > 1){
					
					color.valueString = items[1]
					self.colorArray.append(color);
					
				}
			}
			
		}
		
		var objcHString = String();
		var objcMString = String();
		var swiftString = String();
		
		for color:Color in self.colorArray {
			
			objcHString += color.objcHeaderString()
			objcMString += color.objcImplementationString()
			swiftString += color.swiftString()
			
			objcHString += "\n\n"
			objcMString += "\n\n"
			swiftString += "\n\n"
			
		}
		
		self.objcHeaderFileString = objcHString;
		self.objcImplementationFileString = objcMString;
		self.swiftFileString = swiftString
		;
		
		
	}
	
}
