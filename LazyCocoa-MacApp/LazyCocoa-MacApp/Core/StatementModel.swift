/*

Copyright (c) 2014 Yichi Zhang
https://github.com/yichizhang
zhang-yi-chi@hotmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import Foundation

class StatementModel: NSObject {
	
	var identifier:String!
	var statementString:String!
	var color:BaseColorModel?
	var font:BaseFontModel?
	
	convenience init(string:String){
		self.init()
		
		var lineModel:LineModel = StatementParser.lineModelForLineString(string)
		
		var firstNameString:String? = lineModel.firstNameString
		var secondNameString:String? = lineModel.secondNameString
		var colorCodeString:String? = lineModel.colorCodeString
		var fontNameString:String? = lineModel.fontNameString
		var fontSizeString:String? = lineModel.fontSizeString
		
		self.identifier = firstNameString!
		
		if ( firstNameString != nil && colorCodeString != nil ) {
			
			self.color = DetailSpecifiedColorModel(identifier:firstNameString!, colorHexString:colorCodeString!)
			
		}else if ( firstNameString != nil && secondNameString != nil ) {
			
			self.color = ReferToOtherColorModel(identifier:firstNameString!, otherIdentifier:secondNameString!)
			
		}
		
		if ( firstNameString != nil && fontNameString != nil && fontSizeString != nil ) {
			
			self.font = DetailSpecifiedFontModel(identifier:firstNameString!, fontName:fontNameString!, size:(fontSizeString! as NSString).floatValue)
			
		}else if ( firstNameString != nil && secondNameString != nil ) {
			
			self.font = ReferToOtherFontModel(identifier:firstNameString!, otherIdentifier:secondNameString!)
			
		}
	}
	
}