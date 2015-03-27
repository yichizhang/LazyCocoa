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
	@IBOutlet var newFileTextView: NSTextView!
	@IBOutlet var newHeaderCommentTextView: NSTextView!
	
	@IBOutlet weak var basePathTextField: NSTextField!
	@IBOutlet weak var fileTableView: NSTableView!
	var dataArray:[NSURL]?
	
	@IBOutlet weak var filePathRegexCheckBox: NSButton!
	@IBOutlet weak var filePathRegexTextField: NSTextField!
	
	@IBOutlet weak var originalHeaderRegexCheckBox: NSButton!
	@IBOutlet weak var originalHeaderRegexTextField: NSTextField!
	
	func updateFileTableView() {
		dataArray = DirectoryWalker.allFiles(baseDirectory: basePathTextField.stringValue)
		fileTableView.reloadData()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		originalFileTextView.setUpTextStyleWith(size: 12)
		
		newFileTextView.setUpTextStyleWith(size: 12)
		
		newHeaderCommentTextView.setUpTextStyleWith(size: 12)
		newHeaderCommentTextView.string = "/* \n\nNew Header\n\n */"
		
		basePathTextField.delegate = self
		
		fileTableView.setDataSource(self)
		fileTableView.setDelegate(self)
		fileTableView.reloadData()
		
		filePathRegexCheckBox.action = "checkBoxStateChanged:"
		filePathRegexTextField.delegate = self
		
		originalHeaderRegexCheckBox.action = "checkBoxStateChanged:"
		originalHeaderRegexTextField.delegate = self
	}
	
	func checkBoxStateChanged(sender: NSButton) {
		println(sender.state == NSOnState ? "On" : "Off")
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
		let fileURL = dataArray![row]
		
		if tableView.selectedRow != row {
			
			if let data = NSData(contentsOfURL: fileURL) {
				
				if let string = NSString(data:data, encoding: NSUTF8StringEncoding) {
					
					let headerChanger = HeaderChanger(string: string, newComment: newHeaderCommentTextView.string!)
					
					self.originalFileTextView.textStorage?.setAttributedString(headerChanger.originalAttributedString)
					self.newFileTextView.textStorage?.setAttributedString(headerChanger.newAttributedString)
					
				}
			}
		}
		
		return true
	}
}

extension ChangeHeaderViewController : NSTableViewDataSource {
	
	func numberOfRowsInTableView(tableView: NSTableView) -> Int {
		if let dataArray = dataArray {
			return dataArray.count
		}
		return 0
	}
	
	func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		if let tableColumn = tableColumn {
			if let cellView = tableView.makeViewWithIdentifier("Cell", owner: self) as? NSTableCellView {
				
				switch tableColumn.title {
				case "File":
					let basePath = basePathTextField.stringValue
					var currentFilePath = dataArray![row].absoluteString!
					
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
