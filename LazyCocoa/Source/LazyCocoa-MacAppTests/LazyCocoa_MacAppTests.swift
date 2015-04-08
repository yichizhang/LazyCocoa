//
//  LazyCocoa_MacAppTests.swift
//  LazyCocoa-MacAppTests
//
//  Created by Yichi on 25/12/2014.
//  Copyright (c) 2014 Yichi Zhang. All rights reserved.
//

import Cocoa
import XCTest

class LazyCocoa_MacAppTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testColorFormatter() {
		XCTAssertEqual(
			ColorFormatter.hexStringFrom(componentArray: [0.098, 0.149, 0.176, 1.00]),
			"#19262DFF"
		)
		
		XCTAssertEqual(
			ColorFormatter.hexStringFrom(componentArray: [0.098, 0.149, 0.176]),
			"#19262D"
		)
		
		XCTAssertEqual(
			ColorFormatter.hexStringFrom(componentArray: [0.098, 0.149]),
			"#192600"
		)
		
		XCTAssertEqual(
			ColorFormatter.hexStringFrom(componentArray: [0.098]),
			"#190000"
		)
		
		XCTAssertEqual(
			ColorFormatter.hexStringFrom(componentArray: []),
			"#000000"
		)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
