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
            let filePath = NSBundle(forClass: ZipTests.self).URLForResource("bb8", withExtension: "zip")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
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
            let filePath = NSURL(string:"\(filePathURL!)/bb9.zip")
            let destinationURL = try Zip.quickUnzipFile(filePath!)
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTAssert(true)
        }
    }

    func testQuickUnzipNonZipPath() {
        do {
            let filePath = NSBundle(forClass: ZipTests.self).URLForResource("3crBXeO", withExtension: "gif")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testQuickUnzipProgress() {
        do {
            let filePath = NSBundle(forClass: ZipTests.self).URLForResource("bb8", withExtension: "zip")!
            try Zip.quickUnzipFile(filePath, progress: { (progress) -> () in
                XCTAssert(true)
            })
        }
        catch {
            XCTFail()
        }
    }
    
    func testQuickUnzipOnlineURL() {
        do {
            let filePath = NSURL(string: "http://www.google.com/google.zip")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = NSFileManager.defaultManager()
            XCTAssertFalse(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testUnzip() {
        do {
            let filePath = NSBundle(forClass: ZipTests.self).URLForResource("bb8", withExtension: "zip")!
            let documentsFolder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
            try Zip.unzipFile(filePath, destination: documentsFolder, overwrite: true, password: "password", progress: { (progress) -> () in
                print(progress)
            })
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(documentsFolder.path!))
        }
        catch {
            XCTFail()
        }
    }
    
    func testQuickZip() {
        do {
            let imageURL1 = NSBundle(forClass: ZipTests.self).URLForResource("3crBXeO", withExtension: "gif")!
            let imageURL2 = NSBundle(forClass: ZipTests.self).URLForResource("kYkLkPf", withExtension: "gif")!
            let destinationURL = try Zip.quickZipFiles([imageURL1, imageURL2], fileName: "archive")
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(destinationURL.path!))
        }
        catch {
            XCTFail()
        }
    }
    
    func testZip() {
        do {
            let imageURL1 = NSBundle(forClass: ZipTests.self).URLForResource("3crBXeO", withExtension: "gif")!
            let imageURL2 = NSBundle(forClass: ZipTests.self).URLForResource("kYkLkPf", withExtension: "gif")!
            let documentsFolder = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
            let zipFilePath = documentsFolder.URLByAppendingPathComponent("archive.zip")
            try Zip.zipFiles([imageURL1, imageURL2], zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            let fileManager = NSFileManager.defaultManager()
            XCTAssertTrue(fileManager.fileExistsAtPath(zipFilePath.path!))
        }
        catch {
            XCTFail()
        }
    }


}
