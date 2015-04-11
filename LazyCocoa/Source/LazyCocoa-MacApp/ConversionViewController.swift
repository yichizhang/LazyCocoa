//
//  ConversionViewController.swift
//  LazyCocoa-MacApp
//
//  Created by YICHI ZHANG on 9/02/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Cocoa

class ConversionViewController: NSViewController {
    
    @IBOutlet var sourceTextView: NSTextView!
    @IBOutlet var resultTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		updateUserInterfaceSettings()
	}
	
	func updateUserInterfaceSettings() {
		
		sourceTextView.setUpForDisplayingSourceCode()
		resultTextView.setUpForDisplayingSourceCode()
		
		// Demo text
		sourceTextView.string = String.stringInBundle(name:"ColorScannerDemo")
		
		resultTextView.editable = false
	}
	
    @IBAction func convertButtonTapped(sender: AnyObject) {
        
        if let source = sourceTextView.string {
            var error:NSError?
            let regex = NSRegularExpression(pattern: "@property \\((.*)\\) (.*) \\*?(.*);", options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
            let modifiedString = regex?.stringByReplacingMatchesInString(source, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, count(source)), withTemplate: "var $3:$2?")
            
            resultTextView.string = modifiedString
        }
        
    }
    
    @IBAction func parseColorButtonTapped(sender: AnyObject) {
        
        if let source = sourceTextView.string {
			
            resultTextView.string = ColorScanner.resultStringFrom(source)
        }
    }
    
}