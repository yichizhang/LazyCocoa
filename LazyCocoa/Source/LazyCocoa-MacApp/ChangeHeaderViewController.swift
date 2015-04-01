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
	
	@IBOutlet weak var applyChangesButton: NSButton!
	
	// MARK: Load and update data
	func reloadFiles() {
		if let baseURL = NSURL(fileURLWithPath: basePathTextField.stringValue) {
			
			dataArray = PlainTextFile.sourceCodeFileArray(baseURL: baseURL)
			
			fileTableView.reloadData()
			
			updateFiles()
		}
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
	
	func updateTextViews() {
		
		// NSTableView's selectedRow property
		// When multiple rows are selected, this property contains only the index of the last one in the selection.
		// If no row is selected, the value of this property is -1.
		updateTextViewsWith(textFileAtRow: fileTableView.selectedRow)
	}
	
	func updateTextViewsWith(textFileAtRow row:Int) {
		// "row < dataArray?.count" is false if dataArray is nil.
		if row >= 0 && row < dataArray?.count {
			let textFile = dataArray![row]
			updateTextViewsWith(textFile: textFile)
		}
	}
	
	func updateTextViewsWith(#textFile:PlainTextFile) {
		
		if let string = textFile.fileString {
			let headerChanger = HeaderChanger(string: string, newComment: newHeaderCommentTextView.string!)
			originalFileTextView.textStorage?.setAttributedString(headerChanger.originalAttributedString)
			newFileTextView.textStorage?.setAttributedString(headerChanger.newAttributedString)
			
			originalFileTextView.scrollRectToVisible(NSRect(origin: CGPointZero, size: CGSizeZero))
			newFileTextView.scrollRectToVisible(NSRect(origin: CGPointZero, size: CGSizeZero))
		}
	}
	
	// MARK: View life cycle
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
		
		applyChangesButton.action = "applyChangesButtonTapped:"
	}
	
	// MARK: UI actions
	func checkBoxStateChanged(sender: NSButton) {
		updateFiles()
	}
	
	func applyChangesButtonTapped(sender: NSButton) {
		
		if dataArray != nil {
			var count = 0
			
			let listMax = 10
			var fileListString = ""
			
			for file in dataArray! {
				
				if file.included {
					
					if count < listMax {
						fileListString = fileListString + relativePathFrom(fullPath: file.path) + NEW_LINE_STRING
					} else if count == listMax {
						fileListString = fileListString + "..." + NEW_LINE_STRING
					}
					
					count++
				}
			}
			
			if count > 0 {
				let alert = NSAlert()
				let fileString = count>1 ? "files" : "file"
				
				alert.alertStyle = NSAlertStyle.InformationalAlertStyle
				alert.messageText = "You are about to change \(count) \(fileString). You might want to back up first to prevent possible data loss. Do you wish to proceed? Files to be changed: "
				alert.informativeText = fileListString
				alert.addButtonWithTitle("OK")
				alert.addButtonWithTitle("Cancel")
				if alert.runModal() == NSAlertFirstButtonReturn {
					let newHeaderComment = newHeaderCommentTextView.string!
					
					for file in dataArray! {
						
						if file.included {
							if let string = file.fileString {
								
								let headerChanger = HeaderChanger(string: string, newComment: newHeaderComment)
								file.updateFileWith(newFileString: headerChanger.newFileString)
							}
						}
					}
				}
			}
		}
		
		updateTextViews()
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
		
		if tableView.selectedRow != row {
			updateTextViewsWith(textFileAtRow: row)
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
					
					cellView.textField?.stringValue = relativePathFrom(fullPath: currentFile.path)
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
	
	func relativePathFrom(#fullPath:String) -> String {
		let basePath = basePathTextField.stringValue
		
		if let range = fullPath.rangeOfString(basePath) {
			return fullPath.substringFromIndex(range.endIndex)
		} else {
			return fullPath
		}
	}
}
