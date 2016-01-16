//
//  ZipTests.swift
//  ZipTests
//
//  Created by Roy Marmelstein on 13/12/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import XCTest
@testable import Zip

class ZipTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testQuickUnzip() {
        do {
            let fileAbsoluteURL = NSBundle(forClass: ZipTests.self).URLForResource("bb8", withExtension: "zip")!
            let destinationURL = try Zip().quickUnzipFile(fileAbsoluteURL)
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTFail()
        }

    }
    
    
}
