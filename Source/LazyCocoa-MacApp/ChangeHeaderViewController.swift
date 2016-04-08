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

class ChangeHeaderViewController : BaseViewController {
	
	var dataArray:[PlainTextFile]?
	
	var loadingView:LoadingView?
	
	@IBOutlet var originalFileTextView: NSTextView!
	@IBOutlet var newFileTextView: NSTextView!
	@IBOutlet var newHeaderCommentTextView: NSTextView!
	
	@IBOutlet weak var fileTableView: NSTableView!
	
	@IBOutlet weak var filePathRegexCheckBox: NSButton!
	@IBOutlet weak var filePathRegexTextField: NSTextField!
	@IBOutlet weak var originalHeaderRegexCheckBox: NSButton!
	@IBOutlet weak var originalHeaderRegexTextField: NSTextField!
	
	@IBOutlet weak var applyChangesButton: NSButton!
	@IBOutlet weak var updatePreviewButton: NSButton!
	@IBOutlet weak var updateFilesButton: NSButton!
	
	// MARK: Load and update data
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
				
				textFile.updateInclusiveness(filePathRegexString, originalHeaderRegexString: originalHeaderRegexString)
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
			
			if let string = textFile.fileString {
				let headerChanger = HeaderChanger(string: string, newComment: newHeaderCommentTextView.string!, filename: textFile.filename)
				
				originalFileTextView.textStorage?.setAttributedString(headerChanger.originalAttributedString)
				newFileTextView.textStorage?.setAttributedString(headerChanger.newAttributedString)
				
				originalFileTextView.scrollRectToVisible(NSRect(origin: CGPointZero, size: CGSizeZero))
				newFileTextView.scrollRectToVisible(NSRect(origin: CGPointZero, size: CGSizeZero))
			}
		}
	}
	
	// MARK: Update views
	func updateControlSettings(enabled enabled:Bool) {
		newHeaderCommentTextView.userInteractionEnabled = enabled
		
		fileTableView.userInteractionEnabled = enabled
		
		filePathRegexCheckBox.userInteractionEnabled = enabled
		filePathRegexTextField.userInteractionEnabled = enabled
		
		originalHeaderRegexCheckBox.userInteractionEnabled = enabled
		originalHeaderRegexTextField.userInteractionEnabled = enabled
		
		applyChangesButton.userInteractionEnabled = enabled
		updatePreviewButton.userInteractionEnabled = enabled
		updateFilesButton.userInteractionEnabled = enabled
		
		originalFileTextView.selectable = enabled
		newFileTextView.selectable = enabled
	}
	
	// MARK: Base View Controller
	override func loadData() {
		let baseURL = NSURL(fileURLWithPath: basePath)
			
        loadingView?.removeFromSuperview()
        loadingView = nil
        
        loadingView = LoadingView.newViewWithNibName("LoadingView")
        
        if let v = loadingView {
            v.delegate = self
            
            let layer = CALayer()
            layer.backgroundColor = NSColor.windowBackgroundColor().CGColor
            
            v.wantsLayer = true
            v.layer = layer
            v.frame = NSRect(origin: CGPointZero, size: self.view.frame.size)
            
            // Add loading view
            self.view.addSubview(v, positioned: NSWindowOrderingMode.Above, relativeTo: nil)
            v.progressIndicator.startAnimation(self)
            v.setupConstraintsMakingViewAdhereToEdgesOfSuperview()
            
            // Set up view
            updateControlSettings(enabled: false)
            
            // Set up variables
            self.loadingCancelled = false
            self.dataArray = [PlainTextFile]()
            self.fileTableView.reloadData()
            
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_UTILITY.rawValue), 0)) {
                
                let acceptableSuffixArray = [".h", ".m", ".swift"]
                let fileManager = NSFileManager()
                let keys = [NSURLIsDirectoryKey]
                
                let enumerator = fileManager.enumeratorAtURL(baseURL, includingPropertiesForKeys: keys, options: NSDirectoryEnumerationOptions(), errorHandler: { (url:NSURL, err:NSError) -> Bool in
                    
                    // Handle the error.
                    // Return true if the enumeration should continue after the error.
                    return true
                })
                
                while let element = enumerator?.nextObject() as? NSURL {
                    if self.loadingCancelled == true {
                        break
                    }
                    
                    var error:NSError?
                    var isDirectory:AnyObject?
                    
                    do {
                        try element.getResourceValue(&isDirectory, forKey: NSURLIsDirectoryKey)
                    } catch var error1 as NSError {
                        error = error1
                        
                    } catch {
                        fatalError()
                    }
                    
                    for suffix in acceptableSuffixArray {
                        if element.absoluteString.hasSuffix(suffix) {
                            
                            // check the extension
                            dispatch_async(dispatch_get_main_queue()) {
                                self.loadingView?.messageTextField.stringValue = "\(self.relativePathFrom(fullPath: element.absoluteString))"
                            }
                            
                            self.dataArray?.append(PlainTextFile(fileURL: element))
                            
                        }
                    }
                }
                
                if self.loadingCancelled == false {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.fileTableView.reloadData()
                        
                        self.loadingView?.removeFromSuperview()
                        self.loadingView = nil
                        
                        self.updateControlSettings(enabled: true)
                        
                        self.updateFiles()
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.loadingView?.removeFromSuperview()
                        self.loadingView = nil
                    }
                }
            }
        }
	}
	
	override func cancelLoading() {
		loadingCancelled = true
		
		self.dataArray?.removeAll(keepCapacity: true)
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
		
		applyChangesButton.action = "applyChangesButtonTapped:"
		updatePreviewButton.action = "updatePreviewButtonTapped:"
		updateFilesButton.action = "updateFilesButtonTapped:"
	}
	
	// MARK: UI actions
	func applyChangesButtonTapped(sender: NSButton) {
		
		updateFiles()
		
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
	
	func updatePreviewButtonTapped(sender: AnyObject) {
		
		updateTextViews()
	}
	
	func updateFilesButtonTapped(sender: AnyObject) {
		
		updateFiles()
	}
	
}

extension ChangeHeaderViewController : LoadingViewDelegate {
	
	func loadingViewCancelButtonTapped(vc: LoadingView) {
		self.cancelLoading()
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
	
	func relativePathFrom(fullPath fullPath:String) -> String {
		
		if let range = fullPath.rangeOfString(basePath) {
			var relPath = fullPath.substringFromIndex(range.endIndex)
			
			if relPath.characters.count>0 && relPath.characterAtIndex(0) == Character("/") {
				relPath = relPath.substringFromIndex( relPath.startIndex.advancedBy(1) )
			}
			
			return relPath
		} else {
			return fullPath
		}
	}
}
