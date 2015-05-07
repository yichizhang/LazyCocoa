//
//  Base.swift
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

let fileKey_mainSource = "mainSource"
let Global = GlobalClass.sharedInstance

/*
!!prefix paramKey_
exportTo; prefix; windowFontSize; userName; organizationName
*/
struct ParamKey {
	static let ExportTo = "exportTo"
	static let Prefix = "prefix"
	static let WindowFontSize = "windowFontSize"
	static let UserName = "userName"
	static let OrganizationName = "organizationName"
}

struct ProcessMode {
	static let ColorAndFont = "colorAndFont"
	static let StringConst = "stringConst"
	static let UserDefaults = "userDefaults"
}

struct StringConst {
	static let Hash = "#"
	static let Exclamation = "!"
	static let DoubleQuote = "\""
	static let Space = " "
	static let NewLine = "\n"
	static let SigleLineComment = "//"
	static let MultiLineCommentStart = "/*"
	static let MultiLineCommentEnd = "*/"
	
	static let FontSuffix = "Font"
	static let ColorSuffix = "Color"
}

enum Platform : Int {
	case iOS = 0
	case MacOS
}

class GlobalClass {
	
	var platform : Platform {
		didSet {
			updateStrings()
		}
	}
	
	var colorClassName:String!
	var colorRGBAInitSignatureString:String!
	
	var configurations = ConfigurationsManager()
	
	var fontClassName:String!
	var fontNameAndSizeInitSignatureString:String!
	
	var messageString:String {
		return "Generated by Lazy Cocoa"
	}
	
	var currentDocumentRealPath : String? {
		didSet{
			
		}
	}
	
	class var sharedInstance : GlobalClass {
		struct GlobalStruct {
			static let instance = GlobalClass()
		}
		return GlobalStruct.instance
	}
	
	init() {
		platform = .iOS
		updateStrings()
	}
	
	func updateStrings() {

		switch platform {
		case .iOS:
			fontClassName = "UIFont"
			colorClassName = "UIColor"
			
			colorRGBAInitSignatureString = "red:green:blue:alpha:"
			
		case .MacOS:
			fontClassName = "NSFont"
			colorClassName = "NSColor"
			
			colorRGBAInitSignatureString = "calibratedRed:green:blue:alpha:"
		}
		
		fontNameAndSizeInitSignatureString = "name:size:"
	}
}