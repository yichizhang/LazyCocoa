//
//  LineNumberRulerView.swift
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

import AppKit
import Foundation

class LineNumberRulerView: NSRulerView {
	
	var font: NSFont! {
		didSet {
			self.needsDisplay = true
		}
	}
	
	init(textView: NSTextView) {
		super.init(scrollView: textView.enclosingScrollView!, orientation: NSRulerOrientation.VerticalRuler)
		self.font = textView.font ?? NSFont.systemFontOfSize(NSFont.smallSystemFontSize())
		self.clientView = textView
	}

	required init?(coder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	override func drawHashMarksAndLabelsInRect(rect: NSRect) {
	
		for lineNumber in 1..<25 {
			let attString = NSAttributedString(string: "\(lineNumber)")
			attString.drawAtPoint(NSPoint(x: 0, y: CGFloat((lineNumber-1) * 16)))
		}
	}
}
