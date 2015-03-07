//
//  UserDefaults.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 8/03/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation

struct UserDefaultsGenerationManager {
	static func setMethodNameFor(#type: String) -> String {
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
	static func getMethodNameFor(#type: String) -> String {
		var methodName = "objectForKey"
		switch type {
		case "Int":
			methodName = "integerKey"
		case "Double":
			fallthrough
		case "Float":
			fallthrough
		case "Bool":
			methodName = type.lowercaseString + "ForKey"
		case "NSURL":
			methodName = "URLForKey"
		default:
			break
		}
		return methodName
	}
}