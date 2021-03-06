//
//  main.swift
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
import Cocoa

func printUsage() {
	
	println()
	println("Usage:")
	println("\t$ lzyc COMMAND")
	println("Commands:")
	println("\t+ init    Generate a Lazyfile for the current directory.")
	println("\t+ update  Export source code files required in the Lazyfile.")
	println()
}

if ( Process.arguments.count < 2) {
	
	printUsage()
} else {
	
	let command = Process.arguments[1]
	let prog = MainProgram()
	let fileManager = NSFileManager.defaultManager()
	var error:NSError?
	
	switch command {
	case "init":
		
		if prog.fileExistsNotDirectory(
			filePath: fileManager.currentDirectoryPath.stringByAppendingPathComponent(prog.fileName),
			error: &error
			) {
			
			println("\(prog.fileName) already exists")
		} else {
			
			var error:NSError?
			prog.initLazyfile(basePath: fileManager.currentDirectoryPath, error: &error)
			
			if let error = error {
				println(error.localizedDescription)
			}
		}
		
		break
	case "update":
		
		var analyzer = DocumentAnalyzer()

		error = nil
		if let sourceString = prog.lazyfileString(basePath: fileManager.currentDirectoryPath, error: &error) {
			
			analyzer.inputString = sourceString as String
			analyzer.process()
			
			for d in analyzer.sourceCodeDocuments {
				var error:NSError?
				let message = d.export(basePath: fileManager.currentDirectoryPath, error: &error)
				
				println(message)
				/*
				if let error = error {
					println(error.localizedDescription)
				}
				*/
			}
		} else {
			
			println(error?.localizedDescription)
		}
		
		break
	default:
		println("Invalid command!")
		printUsage()
		
		break
	}
	
}