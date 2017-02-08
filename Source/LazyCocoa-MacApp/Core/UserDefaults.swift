//
//  UserDefaults.swift
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

import Foundation

struct UserDefaultsGenerationManager {
	static func setMethodNameFor(type: String) -> String {
		var methodName = "setObject"
		switch type {
		case "Int":
			methodName = "setInteger"
		case "Double":
			fallthrough
		case "Float":
			fallthrough
		case "Bool":
			methodName = "set" + type
		case "NSURL":
			methodName = "setURL"
		default:
			break
		}
		return methodName
	}

	static func getMethodStringFor(type: String, keyArg:Argument) -> String {
		var methodName = "objectForKey"
		switch type {
		case "Int":
			methodName = "integerForKey"
		case "Double":
			fallthrough
		case "Float":
			fallthrough
		case "Bool":
			methodName = type.lowercased() + "ForKey"
		case "NSURL":
			methodName = "URLForKey"
		default:
			break
		}
		
		var formatString = ""
		var numArgs = 2
		
		switch type {
		case "Int":
			fallthrough
		case "Double":
			fallthrough
		case "Float":
			fallthrough
		case "Bool":
			formatString =
			"return NSUserDefaults.standardUserDefaults().%@(%@)"
			break
		case "NSURL":
			formatString =
			"if let returnValue = NSUserDefaults.standardUserDefaults().%@(%@) {\n" +
				"\t" + "return returnValue\n" +
				"}\n" +
				"return nil"
			break
		default:
			formatString =
			"if let returnValue = NSUserDefaults.standardUserDefaults().%@(%@) as? %@ {\n" +
				"\t" + "return returnValue\n" +
				"}\n" +
			"return nil"
			numArgs = 3
			break
		}
		
		if numArgs == 2 {
			return
			NSString(format: formatString as NSString, methodName, keyArg.formattedString) as String
		} else {
			return
			NSString(format: formatString as NSString, methodName, keyArg.formattedString, type) as String
		}
	}
}
