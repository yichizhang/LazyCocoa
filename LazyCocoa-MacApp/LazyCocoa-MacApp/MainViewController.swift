//
//  ViewController.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 25/12/2014.
//  Copyright (c) 2014 Yichi Zhang. All rights reserved.
//

import Cocoa

class MainViewController: NSViewController {
	
	@IBOutlet var sourceFileTextView: NSTextView!
	
	@IBOutlet private var objcHeaderFileResultTextView: NSTextView!
	
	@IBOutlet private var objcImplementationFileResultTextView: NSTextView!
	
	@IBOutlet private var swiftFileResultTextView: NSTextView!
	
	var genColorEngine: GenColorEngine = GenColorEngine()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.objcHeaderFileResultTextView.continuousSpellCheckingEnabled = false;
		self.objcImplementationFileResultTextView.continuousSpellCheckingEnabled = false;
		self.swiftFileResultTextView.continuousSpellCheckingEnabled = false;
		
		self.objcHeaderFileResultTextView.editable = false;
		self.objcImplementationFileResultTextView.editable = false;
		self.swiftFileResultTextView.editable = false;
		
		let myFont:NSFont = NSFont(name: "Monaco", size: 12)!;
		
		self.sourceFileTextView.font = myFont;
		self.objcHeaderFileResultTextView.font = myFont;
		self.objcImplementationFileResultTextView.font = myFont;
		self.swiftFileResultTextView.font = myFont;
	}
	
	override var representedObject: AnyObject? {
		didSet {
			// Update the view, if already loaded.
		}
	}
	
	@IBAction func updateButtonActionPerformed(sender: AnyObject) {
		
		println("Action")
		
		self.genColorEngine.inputString = self.sourceFileTextView.string;
		
		self.genColorEngine.process()
		
		self.objcHeaderFileResultTextView.string = self.genColorEngine.objcHeaderFileString;
		self.objcImplementationFileResultTextView.string = self.genColorEngine.objcImplementationFileString;
		self.swiftFileResultTextView.string = self.genColorEngine.swiftFileString;
	}
	
}

