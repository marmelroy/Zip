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
    
    func testQuickUnzipNonExistingPath() {
        do {
            let filePathURL = NSBundle(forClass: ZipTests.self).resourcePath
            let fileAbsoluteURL = NSURL(string:"\(filePathURL!)/bb9.zip")
            let destinationURL = try Zip().quickUnzipFile(fileAbsoluteURL!)
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTAssert(true)
        }
    }

    func testQuickUnzipNonZipPath() {
        do {
            let fileAbsoluteURL = NSBundle(forClass: ZipTests.self).URLForResource("3crBXeO", withExtension: "gif")!
            let destinationURL = try Zip().quickUnzipFile(fileAbsoluteURL)
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testQuickUnzipProgress() {
        do {
            let fileAbsoluteURL = NSBundle(forClass: ZipTests.self).URLForResource("bb8", withExtension: "zip")!
            try Zip().quickUnzipFile(fileAbsoluteURL, progress: { (progress) -> () in
                XCTAssert(true)
            })
        }
        catch {
            XCTFail()
        }
    }
    
    func testUnzipOnlineURL() {
        do {
            let fileAbsoluteURL = NSURL(string: "http://www.google.com/google.zip")!
            let destinationURL = try Zip().quickUnzipFile(fileAbsoluteURL)
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTAssert(true)
        }
    }

    
    func testQuickZip() {
        do {
            let imageURL1 = NSBundle(forClass: ZipTests.self).URLForResource("3crBXeO", withExtension: "gif")!
            let imageURL2 = NSBundle(forClass: ZipTests.self).URLForResource("kYkLkPf", withExtension: "gif")!
            let destinationURL = try Zip().quickZipFiles([imageURL1, imageURL2], fileName: "archive")
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTFail()
        }
    }

}
