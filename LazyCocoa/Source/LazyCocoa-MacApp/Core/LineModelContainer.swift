//
//  LineModelContainer.swift
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

import Cocoa

class LineModelContainer : NSObject {
	
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
	
	func addObject(model:LineModel) {
		
		if (model.identifier.isEmpty == false) {
			modelArray.append(model)
			modelDictionary[model.identifier] = model
		}
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
	
}

