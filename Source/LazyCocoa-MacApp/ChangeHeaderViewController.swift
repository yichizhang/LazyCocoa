//
//  ChangeHeaderViewController.swift
//  The Lazy Cocoa Project
//
//  Copyright (c) 2015 Yichi Zhang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import Foundation
import AppKit

class ChangeHeaderViewController : NSViewController {
	
	var basePath = "" {
		didSet {
			if viewLoaded {
				reloadFiles()
			}
		}
	}
	
	@IBOutlet var originalFileTextView: NSTextView!
	@IBOutlet var newFileTextView: NSTextView!
	@IBOutlet var newHeaderCommentTextView: NSTextView!
	
	@IBOutlet weak var fileTableView: NSTableView!
	var dataArray:[PlainTextFile]?
	
	@IBOutlet weak var filePathRegexCheckBox: NSButton!
	@IBOutlet weak var filePathRegexTextField: NSTextField!
	
	@IBOutlet weak var originalHeaderRegexCheckBox: NSButton!
	@IBOutlet weak var originalHeaderRegexTextField: NSTextField!
	
	@IBOutlet weak var applyChangesButton: NSButton!
	
	// MARK: Load and update data
	func reloadFiles() {
		if let baseURL = NSURL(fileURLWithPath: basePath) {
			
			let vc = storyboard?.instantiateControllerWithIdentifier("LoadingViewController") as? LoadingViewController
			vc!.delegate = self
			
			presentViewControllerAsSheet(vc!)
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
				// do some task
				self.dataArray = PlainTextFile.sourceCodeFileArray(baseURL: baseURL)
				
				dispatch_async(dispatch_get_main_queue()) {
					// update some UI
					self.fileTableView.reloadData()
					
					vc!.dismissController(nil)
					self.updateFiles()
				}
			}
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
			let headerChanger = HeaderChanger(string: string, newComment: newHeaderCommentTextView.string!, filename: textFile.filename)
			
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
		originalFileTextView.editable = false
		
		newFileTextView.setUpTextStyleWith(size: 12)
		newFileTextView.editable = false
		
		newHeaderCommentTextView.setUpTextStyleWith(size: 12)
		newHeaderCommentTextView.string = String.stringInBundle(name:"MIT_template")
		
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
						fileListString = fileListString + relativePathFrom(fullPath: file.path) + StringConst.NewLine
					} else if count == listMax {
						fileListString = fileListString + "..." + StringConst.NewLine
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
								
								let headerChanger = HeaderChanger(string: string, newComment: newHeaderComment, filename: file.filename)
								file.updateFileWith(newFileString: headerChanger.newFileString as String)
							}
						}
					}
				}
			}
		}
		
		updateTextViews()
	}
	
}

extension ChangeHeaderViewController : LoadingViewControllerDelegate {
	
	func loadingViewControllerCancelButtonTapped(vc: LoadingViewController) {
		println("XX")
	}
}

extension ChangeHeaderViewController : NSTextFieldDelegate {
	
	override func controlTextDidChange(obj: NSNotification) {
		
		updateFiles()
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
		
		if let range = fullPath.rangeOfString(basePath) {
			return fullPath.substringFromIndex(range.endIndex)
		} else {
			return fullPath
		}
	}
}
