//
//  CodeGeneration.swift
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