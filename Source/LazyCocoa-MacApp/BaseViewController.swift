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
	
	var loadingCancelled = false
	var needsReload = false
	
	var oldBasePath:String = ""
	var basePath:String = "" {
		willSet {
			oldBasePath = basePath
		}
		didSet {
			if self.viewVisible {
				loadDataIfNecessary()
			}
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
	
	// MARK: View life cycle
	override func viewDidAppear() {
		super.viewDidAppear()
		viewVisible = true
		
		loadDataIfNecessary()
	}
	
	override func viewDidDisappear() {
		super.viewDidDisappear()
		viewVisible = false
	}
	// MARK: Load data; cancel loading
	func loadDataIfNecessary() {
		if oldBasePath != basePath || self.needsReload == true {
			self.cancelLoading()
			self.loadData()
			
			oldBasePath = basePath
			self.needsReload == false
		}
	}
	
	func loadData() {
		
	}
	
	func cancelLoading() {
		
	}
}
