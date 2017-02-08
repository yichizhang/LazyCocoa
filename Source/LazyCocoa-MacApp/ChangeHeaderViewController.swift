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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


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
				let headerChanger = HeaderChanger(string: string, newComment: newHeaderCommentTextView.string! as NSString, filename: textFile.filename)
				
				originalFileTextView.textStorage?.setAttributedString(headerChanger.originalAttributedString)
				newFileTextView.textStorage?.setAttributedString(headerChanger.newAttributedString)
				
				originalFileTextView.scrollToVisible(NSRect(origin: CGPoint.zero, size: CGSize.zero))
				newFileTextView.scrollToVisible(NSRect(origin: CGPoint.zero, size: CGSize.zero))
			}
		}
	}
	
	// MARK: Update views
	func updateControlSettings(enabled:Bool) {
		newHeaderCommentTextView.userInteractionEnabled = enabled
		
		fileTableView.userInteractionEnabled = enabled
		
		filePathRegexCheckBox.userInteractionEnabled = enabled
		filePathRegexTextField.userInteractionEnabled = enabled
		
		originalHeaderRegexCheckBox.userInteractionEnabled = enabled
		originalHeaderRegexTextField.userInteractionEnabled = enabled
		
		applyChangesButton.userInteractionEnabled = enabled
		updatePreviewButton.userInteractionEnabled = enabled
		updateFilesButton.userInteractionEnabled = enabled
		
		originalFileTextView.isSelectable = enabled
		newFileTextView.isSelectable = enabled
	}
	
	// MARK: Base View Controller
	override func loadData() {
		let baseURL = URL(fileURLWithPath: basePath)
			
        loadingView?.removeFromSuperview()
        loadingView = nil
        
        loadingView = LoadingView.newView(withNibName: "LoadingView")
        
        if let v = loadingView {
            v.delegate = self
            
            let layer = CALayer()
            layer.backgroundColor = NSColor.windowBackgroundColor.cgColor
            
            v.wantsLayer = true
            v.layer = layer
            v.frame = NSRect(origin: CGPoint.zero, size: self.view.frame.size)
            
            // Add loading view
            self.view.addSubview(v, positioned: NSWindowOrderingMode.above, relativeTo: nil)
            v.progressIndicator.startAnimation(self)
            v.setupConstraintsMakingViewAdhereToEdgesOfSuperview()
            
            // Set up view
            updateControlSettings(enabled: false)
            
            // Set up variables
            self.loadingCancelled = false
            self.dataArray = [PlainTextFile]()
            self.fileTableView.reloadData()
          
            DispatchQueue.global().async {
            
                let acceptableSuffixArray = [".h", ".m", ".swift"]
                let fileManager = FileManager()
                let keys = [URLResourceKey.isDirectoryKey]
                
                let enumerator = fileManager.enumerator(at: baseURL, includingPropertiesForKeys: keys, options: FileManager.DirectoryEnumerationOptions(), errorHandler: { (url:URL, err:Error) -> Bool in
                    
                    // Handle the error.
                    // Return true if the enumeration should continue after the error.
                    return true
                })
                
                while let element = enumerator?.nextObject() as? URL {
                    if self.loadingCancelled == true {
                        break
                    }
                    
                    var error:NSError?
                    var isDirectory:AnyObject?
                    
                    do {
                        try (element as NSURL).getResourceValue(&isDirectory, forKey: URLResourceKey.isDirectoryKey)
                    } catch var error1 as NSError {
                        error = error1
                        
                    } catch {
                        fatalError()
                    }
                    
                    for suffix in acceptableSuffixArray {
                        if element.absoluteString.hasSuffix(suffix) {
                            
                            // check the extension
                            DispatchQueue.main.async {
                                self.loadingView?.messageTextField.stringValue = "\(self.relativePathFrom(fullPath: element.absoluteString))"
                            }
                            
                            self.dataArray?.append(PlainTextFile(fileURL: element))
                            
                        }
                    }
                }
                
                if self.loadingCancelled == false {
                    
                    DispatchQueue.main.async {
                        
                        self.fileTableView.reloadData()
                        
                        self.loadingView?.removeFromSuperview()
                        self.loadingView = nil
                        
                        self.updateControlSettings(enabled: true)
                        
                        self.updateFiles()
                    }
                } else {
                    DispatchQueue.main.async {
                        
                        self.loadingView?.removeFromSuperview()
                        self.loadingView = nil
                    }
                }
            }
        }
	}
	
	override func cancelLoading() {
		loadingCancelled = true
		
		self.dataArray?.removeAll(keepingCapacity: true)
	}
	
	// MARK: View life cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		
		originalFileTextView.setUpTextStyleWith(size: 12)
		originalFileTextView.isEditable = false
		
		newFileTextView.setUpTextStyleWith(size: 12)
		newFileTextView.isEditable = false
		
		newHeaderCommentTextView.setUpTextStyleWith(size: 12)
		newHeaderCommentTextView.string = String.stringInBundle(name:"MIT_template")
		
		fileTableView.dataSource = self
		fileTableView.delegate = self
		fileTableView.reloadData()
		
		applyChangesButton.action = #selector(ChangeHeaderViewController.applyChangesButtonTapped(_:))
		updatePreviewButton.action = #selector(ChangeHeaderViewController.updatePreviewButtonTapped(_:))
		updateFilesButton.action = #selector(ChangeHeaderViewController.updateFilesButtonTapped(_:))
	}
	
	// MARK: UI actions
	func applyChangesButtonTapped(_ sender: NSButton) {
		
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
					
					count += 1
				}
			}
			
			if count > 0 {
				let alert = NSAlert()
				let fileString = count>1 ? "files" : "file"
				
				alert.alertStyle = NSAlertStyle.informational
				alert.messageText = "You are about to change \(count) \(fileString). You might want to back up first to prevent possible data loss. Do you wish to proceed? Files to be changed: "
				alert.informativeText = fileListString
				alert.addButton(withTitle: "OK")
				alert.addButton(withTitle: "Cancel")
				if alert.runModal() == NSAlertFirstButtonReturn {
					let newHeaderComment = newHeaderCommentTextView.string!
					
					for file in dataArray! {
						
						if file.included {
							if let string = file.fileString {
								
								let headerChanger = HeaderChanger(string: string, newComment: newHeaderComment as NSString, filename: file.filename)
								file.updateFileWith(newFileString: headerChanger.newFileString as String)
							}
						}
					}
				}
			}
		}
		
		updateTextViews()
	}
	
	func updatePreviewButtonTapped(_ sender: AnyObject) {
		
		updateTextViews()
	}
	
	func updateFilesButtonTapped(_ sender: AnyObject) {
		
		updateFiles()
	}
	
}

extension ChangeHeaderViewController : LoadingViewDelegate {
	
	func loadingViewCancelButtonTapped(_ vc: LoadingView) {
		self.cancelLoading()
	}
}

extension ChangeHeaderViewController : NSTableViewDelegate {

	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		
		if tableView.selectedRow != row {
			updateTextViewsWith(textFileAtRow: row)
		}
		
		return true
	}
}

extension ChangeHeaderViewController : NSTableViewDataSource {
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		if let dataArray = dataArray {
			return dataArray.count
		}
		return 0
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		if let tableColumn = tableColumn {
			if let cellView = tableView.make(withIdentifier: "Cell", owner: self) as? NSTableCellView {
				
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
	
	func relativePathFrom(fullPath:String) -> String {
		
		if let range = fullPath.range(of: basePath) {
			var relPath = fullPath.substring(from: range.upperBound)
			
			if relPath.characters.count>0 && relPath.characterAtIndex(0) == Character("/") {
				relPath = relPath.substring( from: relPath.characters.index(relPath.startIndex, offsetBy: 1) )
			}
			
			return relPath
		} else {
			return fullPath
		}
	}
}
