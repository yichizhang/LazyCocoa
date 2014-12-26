//
//  GenColorEngine.swift
//  GenColor
//
//  Created by Yichi on 11/12/2014.
//  Copyright (c) 2014 Yichi Zhang. All rights reserved.
//

import Cocoa

class GenColorEngine {
	
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
