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
	var dataArray:[PlainTextFile]?
	
	@IBOutlet weak var filePathRegexCheckBox: NSButton!
	@IBOutlet weak var filePathRegexTextField: NSTextField!
	
	@IBOutlet weak var originalHeaderRegexCheckBox: NSButton!
	@IBOutlet weak var originalHeaderRegexTextField: NSTextField!
	
	func reloadFiles() {
		if let baseURL = NSURL(fileURLWithPath: basePathTextField.stringValue) {
			
			dataArray = PlainTextFile.sourceCodeFileArray(baseURL: baseURL)
			updateFiles()
		}
		
		fileTableView.reloadData()
	}
	
	func updateFiles() {
		if dataArray != nil {
			for textFile in dataArray! {
				
				var filePathRegexString:String? = nil
				if filePathRegexCheckBox.state == NSOnState {
					filePathRegexString = filePathRegexTextField.stringValue
				}
				
				var originalHeaderRegexString:String? = nil
				if originalHeaderRegexCheckBox.state == NSOnState {
					originalHeaderRegexString = originalHeaderRegexTextField.stringValue
				}
				
				textFile.updateInclusiveness(filePathRegexString: filePathRegexString, originalHeaderRegexString: originalHeaderRegexString)
			}
		}
		
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
		updateFiles()
	}
	
	@IBAction func chooseBasePathButtonTapped(sender: AnyObject) {
		let openDialog = NSOpenPanel()
		
		openDialog.canChooseFiles = false
		openDialog.canChooseDirectories = true
		openDialog.canCreateDirectories = true
		openDialog.allowsMultipleSelection = false
		
		if openDialog.runModal() == NSOKButton {
			if let url = openDialog.URLs.first as? NSURL {
				basePathTextField.stringValue = url.path!
			}
		}
		
		reloadFiles()
	}
}

extension ChangeHeaderViewController : NSTextFieldDelegate {
	
	override func controlTextDidChange(obj: NSNotification) {
		if let textField = obj.object as? NSTextField {
			switch textField {
			case basePathTextField:
				reloadFiles()
				break
			default:
				updateFiles()
				break
			}
		}
	}
}

extension ChangeHeaderViewController : NSTableViewDelegate {

	func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		let textFile = dataArray![row]
		
		if tableView.selectedRow != row {
			
			if let string = textFile.fileString {
				
				let headerChanger = HeaderChanger(string: string, newComment: newHeaderCommentTextView.string!)
				self.originalFileTextView.textStorage?.setAttributedString(headerChanger.originalAttributedString)
				self.newFileTextView.textStorage?.setAttributedString(headerChanger.newAttributedString)
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
				
				let currentFile = dataArray![row]
				
				switch tableColumn.title {
				case "File":
					
					let basePath = basePathTextField.stringValue
					var currentFilePath = currentFile.path
					
					if let range = currentFilePath.rangeOfString(basePath) {
						currentFilePath = currentFilePath.substringFromIndex(range.endIndex)
					}
					
					cellView.textField?.stringValue = currentFilePath
				case "Included":
					
					cellView.textField?.stringValue = currentFile.included ? "Yes" : "No"
					break
				default:
					break
				}
				
				
				return cellView
			}
		}
		return nil
	}
}
