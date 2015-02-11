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
        
        if let source = sourceTextView.string {
            var array = source.componentsSeparatedByString("\n")
            
            var xa:[String] = Array()
            
            for s in array {
                
                let ss = s as NSString
                if ((s as String).isEmpty == false) {
                    xa.append(ColorScanner.scanText(ss))
                }
            }
            
            resultTextView.string = (xa as NSArray).componentsJoinedByString("\n")
        }
    }
    
    @IBAction func generateConstantsButtonTapped(sender: AnyObject) {
        
        if let source = sourceTextView.string {
            
            let arr = source.componentsSeparatedByCharactersInSet( NSCharacterSet(charactersInString: ",\n") )
            //let arr = source.componentsSeparatedByString(",")
            var result = ""
            
            for (i, s) in enumerate(arr) {
                let str = s.stringByTrimmingWhiteSpaceAndNewLineCharacters()
                let arg = Argument(object: str, formattingStrategy: ArgumentFormattingStrategy.StringLiteral)
                result = result + "let k\(str.capitalizedString) = \(arg.formattedString)\n"
            }
            
            resultTextView.string = result
        }
    }
    
}