//
//  UIE.swift
//  LazyCocoa-MacApp
//
//  Created by YICHI ZHANG on 9/02/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Cocoa

extension NSTextView {
    
    func setUpForDisplayingSourceCode() {
        let myFont:NSFont = NSFont(name: "Monaco", size: 12)!
        continuousSpellCheckingEnabled = false
        automaticQuoteSubstitutionEnabled = false
        enabledTextCheckingTypes = 0
        richText = false
        font = myFont
    }
}