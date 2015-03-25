//
//  ChangeHeaderViewController.swift
//  LazyCocoa-MacApp
//
//  Created by Yichi on 22/03/2015.
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//

import Foundation
import AppKit

class ChangeHeaderViewController : NSViewController {
	
	@IBOutlet var originalFileTextView: NSTextView!
	@IBOutlet var editedFileTextView: NSTextView!
	
	@IBOutlet weak var basePathTextField: NSTextField!
	@IBOutlet weak var fileTableView: NSTableView!
	var dataArray = [String]()
	
	func updateFileTableView() {
		dataArray = ChangeHeader.allFiles(baseDirectory: basePathTextField.stringValue)
		fileTableView.reloadData()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fileTableView.setDataSource(self)
		fileTableView.setDelegate(self)
		
		fileTableView.reloadData()
	
		basePathTextField.delegate = self
	}
	
	@IBAction func chooseBasePathButtonTapped(sender: AnyObject) {
		let openDialog = NSOpenPanel()
		
		openDialog.canChooseFiles = false
		openDialog.canChooseDirectories = true
		openDialog.canCreateDirectories = true
		openDialog.allowsMultipleSelection = false
		
		if openDialog.runModal() == NSOKButton {
			if let url = openDialog.URLs.first as? NSURL {
				basePathTextField.stringValue = url.absoluteString!
			}
		}
		
		updateFileTableView()
	}
}

extension ChangeHeaderViewController : NSTextFieldDelegate {
	
	override func controlTextDidChange(obj: NSNotification) {
		if let textField = obj.object as? NSTextField {
			switch textField {
			case basePathTextField:
				updateFileTableView()
				break
			default:
				
				break
			}
		}
	}
}

extension ChangeHeaderViewController : NSTableViewDelegate {

	func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let path = dataArray[row]
		
		if tableView.selectedRow != row {
			
			if let data = NSData(contentsOfURL: NSURL(string: path)! ) {
				
				if let string = NSString(data:data, encoding: NSUTF8StringEncoding) {
					
					
					self.originalFileTextView.string = string
				}
			}
		}
		
		return true
	}
}

extension ChangeHeaderViewController : NSTableViewDataSource {
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		return dataArray.count
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		if let tableColumn = tableColumn {
			if let cellView = tableView.makeViewWithIdentifier("Cell", owner: self) as? NSTableCellView {
				
				switch tableColumn.title {
				case "File":
					let basePath = basePathTextField.stringValue
					var currentFilePath = dataArray[row]
					
					if let range = currentFilePath.rangeOfString(basePath) {
						currentFilePath = currentFilePath.substringFromIndex(range.endIndex)
					}
					println(currentFilePath)
					
					cellView.textField?.stringValue = currentFilePath
				default:
					cellView.textField?.stringValue = "?"
				}
				
				
				return cellView
			}
		}
		return nil
	}
}
