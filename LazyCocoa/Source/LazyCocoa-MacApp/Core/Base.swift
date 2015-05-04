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

let HASH_STRING = "#"
let EXCLAMATION_MARK_STRING = "!"
let EXCLAMATION_MARK_CHAR = Character(EXCLAMATION_MARK_STRING)
let DOUBLE_QUOTE_STRING = "\""
let DOUBLE_QUOTE_CHAR = Character(DOUBLE_QUOTE_STRING)
let SPACE_STRING = " "
let NEW_LINE_STRING = "\n"
let NEW_LINE_CHAR = Character(NEW_LINE_STRING)
let FONT_SUFFIX = "Font"
let COLOR_SUFFIX = "Color"
let COMMENT_PREFIX = "//"

let SINGLE_LINE_COMMENT = "//"
let MULTI_LINE_COMMENT_START = "/*"
let MULTI_LINE_COMMENT_END = "*/"

/*

!!prefix paramKey_
exportTo; prefix; windowFontSize; userName; organizationName

*/
let paramKey_exportTo = "exportTo"
let paramKey_prefix = "prefix"
let paramKey_windowFontSize = "windowFontSize"
let paramKey_userName = "userName"
let paramKey_organizationName = "organizationName"

let fileKey_mainSource = "mainSource"	

let Settings = SettingsManager.sharedInstance

enum Platform : Int {
	case iOS = 0
	case MacOS
}

protocol BaseModelProtocol {
	
	func autoMethodName() -> String
	func statementString() -> String
	func documentationString() -> String
	func funcString() -> String
}

class BaseModel : NSObject {
	
	var identifier = "someIdentifier"

}

enum ArgumentFormattingStrategy : Int {
	case CGFloatNumber = 0
	case StringLiteral
	case Name
}

class Argument : NSObject {
	var object:AnyObject!
	var formattingStrategy:ArgumentFormattingStrategy!
	
	init(object:AnyObject, formattingStrategy:ArgumentFormattingStrategy) {
		self.object = object
		self.formattingStrategy = formattingStrategy
		super.init()
	}
	
	var formattedString:String {
		switch formattingStrategy.rawValue {
		case ArgumentFormattingStrategy.CGFloatNumber.rawValue:
			return NSString(format: "%.3f", object.floatValue) as String
		case ArgumentFormattingStrategy.StringLiteral.rawValue:
			let str = object as! String
			return "\"" + str + "\""
		case ArgumentFormattingStrategy.Name.rawValue:
			return "\(object)"
		default:
			return "__ERROR__"
		}
	}
}

class SettingsManager : NSObject {
	
	var platform : Platform {
		didSet {
			updateStrings()
		}
	}
	
	var colorClassName:String!
	var colorRGBAInitSignatureString:String!
	
	var fontClassName:String!
	var fontNameAndSizeInitSignatureString:String!
	
	private var parameters:[String: String] = Dictionary()
	
	var userName:String {
		if let value = Settings.parameterForKey(paramKey_userName){
			return value
		} else {
			return "User"
		}
	}
	var companyName:String {
		if let value = Settings.parameterForKey(paramKey_organizationName){
			return value
		} else {
			return "The Lazy Cocoa Project"
		}
	}
	var fileName:String {
		if let exportPath = self.parameterForKey(paramKey_exportTo) {
			return exportPath.lastPathComponent
		} else {
			return ""
		}
	}
	var messageString:String {
		return "Generated by Lazy Cocoa"
	}
	
	var currentDocumentRealPath : String? {
		didSet{
			
		}
	}
	
	class var sharedInstance : SettingsManager {
		struct _SettingsStruct {
			static let instance = SettingsManager()
		}
		return _SettingsStruct.instance
	}
	
	override init() {
		platform = .iOS
		super.init()
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
	
	func settingsChanged() {
		
	}
	
	func setParameter(#value:String, forKey parameterKey:String) {
		parameters[parameterKey] = value
	}
	
	func parameterForKey(key:String) -> String? {
		return parameters[key]
	}
	
	func unwrappedParameterForKey(key:String) -> String {
		if let val = parameterForKey(key) {
			return val
		} else {
			return ""
		}
	}
	
	func resetParameters() {
		parameters = Dictionary()
	}
}
