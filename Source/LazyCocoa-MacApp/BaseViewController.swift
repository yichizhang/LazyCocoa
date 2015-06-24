//
//  BaseViewController.swift
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

class BaseViewController: NSViewController {
	
	var viewVisible = false
	var oldBasePath:String = ""
	var basePath:String = "" {
		willSet {
			oldBasePath = basePath
		}
		didSet {
			if self.viewVisible {
				if oldBasePath != basePath {
					self.cancelLoading()
					self.loadData()
					oldBasePath = basePath
				}
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	// MARK: View life cycle
	override func viewWillAppear() {
		super.viewWillAppear()
		viewVisible = true
		
		if oldBasePath != basePath {
			self.loadData()
			oldBasePath = basePath
		}
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
		viewVisible = false
	}
	
	// MARK: Load data; cancel loading
	func loadData() {
		
	}
	
	func cancelLoading() {
		
	}
}
