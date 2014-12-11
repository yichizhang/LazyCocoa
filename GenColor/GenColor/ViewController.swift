//
//  ViewController.swift
//  GenColor
//
//  Created by Yichi on 11/12/2014.
//  Copyright (c) 2014 Yichi Zhang. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

	@IBOutlet var sourceColorSettingsTextView: NSTextView!
	
	@IBOutlet var objcHeaderFileResultTextView: NSTextView!
	
	@IBOutlet var objcImplementationFileResultTextView: NSTextView!
	
	@IBOutlet var swiftFileResultTextView: NSTextView!
	
	var genColorEngine: GenColorEngine = GenColorEngine()
	
	override func viewDidLoad() {
		super.viewDidLoad()

		// Do any additional setup after loading the view.
		
	}

	override var representedObject: AnyObject? {
		didSet {
		// Update the view, if already loaded.
		}
	}

	@IBAction func updateButtonActionPerformed(sender: AnyObject) {
		
		println("Action")
		
		self.genColorEngine.inputString = self.sourceColorSettingsTextView.string;
		
		self.genColorEngine.process()
		
		self.objcHeaderFileResultTextView.string = self.genColorEngine.objcHeaderFileString;
		self.objcImplementationFileResultTextView.string = self.genColorEngine.objcImplementationFileString;
		self.swiftFileResultTextView.string = self.genColorEngine.swiftFileString;
	}

}

