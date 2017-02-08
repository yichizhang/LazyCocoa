//
//  MainProgram.swift
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
import Foundation

class MainProgram {
	var fileName = "Lazyfile"
	
	func fileExistsNotDirectory(filePath path:String) throws {
		
		let fileManager = FileManager.default
		
		var isDir:ObjCBool = false
		var errorMessage:String?
		var code:Int = 0
		
		if fileManager.fileExists(atPath: path, isDirectory: &isDir) {
			if isDir.boolValue {
				errorMessage = "\(fileName) is a directory, not a file."
				code = ErrorCode.FileIsDir
			} else {
				
			}
		} else {
			errorMessage = "\(fileName) does not exist."
			code = ErrorCode.FileNotExist
		}
		
		if errorMessage == nil {
			
			return
		} else {
			throw NSError(domain: "File", code: code, userInfo: [NSLocalizedDescriptionKey:errorMessage!])
		}
	}
	
	func lazyfileString(basePath:String) throws -> String {
		let path = (basePath as NSString).appendingPathComponent(fileName)
		
		try fileExistsNotDirectory(filePath: path)

		return try! NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
	}
	
	func saveLazyfileString(_ fileString:String, basePath:String, error errorPointer:NSErrorPointer) {
		
		let path = (basePath as NSString).appendingPathComponent(fileName)
		do {
			try fileString.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
		} catch let error as NSError {
			errorPointer?.pointee = error
		}
	}
	
	func initLazyfile(basePath:String, error errorPointer:NSErrorPointer) {
		
		let template = LZYDataManager.lazyFileTemplate()
		saveLazyfileString(template!, basePath: basePath, error: errorPointer)
	}
}
