//
//  ChangeHeaderViewController.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 22/03/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation
import AppKit

class ChangeHeaderViewController : NSViewController, NSTableViewDelegate, NSTableViewDataSource {
	
	@IBOutlet weak var fileTableView: NSTableView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fileTableView.setDataSource(self)
		fileTableView.setDelegate(self)
		
		fileTableView.reloadData()
	}
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return 10
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		if let tableColumn = tableColumn {
			if let cellView = tableView.makeViewWithIdentifier("Cell", owner: self) as? NSTableCellView {
				cellView.textField?.stringValue = "\(row)\(tableColumn.title)"
				
				return cellView
			}
		}
		return nil
	}
}

