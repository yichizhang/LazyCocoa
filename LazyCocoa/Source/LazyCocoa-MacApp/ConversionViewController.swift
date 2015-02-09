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
        
        sourceTextView.setUpForDisplayingSourceCode()
        resultTextView.setUpForDisplayingSourceCode()
        
        resultTextView.editable = false
    }
    
    @IBAction func convertButtonTapped(sender: AnyObject) {
        
        if let source = sourceTextView.string {
            var error:NSError?
            let regex = NSRegularExpression(pattern: "@property \\((.*)\\) (.*) \\*?(.*);", options: NSRegularExpressionOptions.CaseInsensitive, error: &error)
            let modifiedString = regex?.stringByReplacingMatchesInString(source, options: NSMatchingOptions.allZeros, range: NSMakeRange(0, countElements(source)), withTemplate: "var $3:$2?")
            
            resultTextView.string = modifiedString
        }
        
    }
    
    @IBAction func parseColorButtonTapped(sender: AnyObject) {
        
    }
    
    @IBAction func generateConstantsButtonTapped(sender: AnyObject) {
        
    }
    
}