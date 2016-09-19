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
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath: destinationURL.path))
        }
        catch {
            XCTFail()
        }
    }
    
    func testQuickUnzipNonExistingPath() {
        do {
            let filePathURL = Bundle(for: ZipTests.self).resourcePath
            let filePath = NSURL(string:"\(filePathURL!)/bb9.zip")
            let destinationURL = try Zip.quickUnzipFile(filePath! as URL)
            let fileManager = FileManager.default
            XCTAssertFalse(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testQuickUnzipNonZipPath() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = FileManager.default
            XCTAssertFalse(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testQuickUnzipProgress() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            _ = try Zip.quickUnzipFile(filePath, progress: { (progress) -> () in
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
            let destinationURL = try Zip.quickUnzipFile(filePath as URL)
            let fileManager = FileManager.default
            XCTAssertFalse(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testUnzip() {
        do {
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            
            try Zip.unzipFile(filePath, destination: documentsFolder as URL, overwrite: true, password: "password", progress: { (progress) -> () in
                print(progress)
            })
            
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:documentsFolder.path!))
        }
        catch {
            XCTFail()
        }
    }
    
    func testImplicitProgressUnzip() {
        do {
            let progress = Progress()
            progress.totalUnitCount = 1
            
            let filePath = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            
            progress.becomeCurrent(withPendingUnitCount: 1)
            try Zip.unzipFile(filePath, destination: documentsFolder as URL, overwrite: true, password: "password", progress: nil)
            progress.resignCurrent()
            
            XCTAssertTrue(progress.totalUnitCount == progress.completedUnitCount)
        }
        catch {
            XCTFail()
        }
        
    }
    
    func testImplicitProgressZip() {
        do {
            let progress = Progress()
            progress.totalUnitCount = 1
            
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
            
            progress.becomeCurrent(withPendingUnitCount: 1)
            try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath!, password: nil, progress: nil)
            progress.resignCurrent()
            
            XCTAssertTrue(progress.totalUnitCount == progress.completedUnitCount)
        }
        catch {
            XCTFail()
        }
    }
    
    
    func testQuickZip() {
        do {
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let destinationURL = try Zip.quickZipFiles([imageURL1, imageURL2], fileName: "archive")
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTFail()
        }
    }
    
    func testQuickZipFolder() {
        do {
            let fileManager = FileManager.default
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let folderURL = Bundle(for: ZipTests.self).bundleURL.appendingPathComponent("Directory")
            let targetImageURL1 = folderURL.appendingPathComponent("3crBXeO.gif")
            let targetImageURL2 = folderURL.appendingPathComponent("kYkLkPf.gif")
            if fileManager.fileExists(atPath:folderURL.path) {
                try fileManager.removeItem(at: folderURL)
            }
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: false, attributes: nil)
            try fileManager.copyItem(at: imageURL1, to: targetImageURL1)
            try fileManager.copyItem(at: imageURL2, to: targetImageURL2)
            let destinationURL = try Zip.quickZipFiles([folderURL], fileName: "directory")
            XCTAssertTrue(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTFail()
        }
    }
    
    
    func testZip() {
        do {
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
            try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath!, password: nil, progress: { (progress) -> () in
                print(progress)
            })
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:(zipFilePath?.path)!))
        }
        catch {
            XCTFail()
        }
    }
    
    func testZipUnzipPassword() {
        do {
            let imageURL1 = Bundle(for: ZipTests.self).url(forResource: "3crBXeO", withExtension: "gif")!
            let imageURL2 = Bundle(for: ZipTests.self).url(forResource: "kYkLkPf", withExtension: "gif")!
            let documentsFolder = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let zipFilePath = documentsFolder.appendingPathComponent("archive.zip")
            try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath!, password: "password", progress: { (progress) -> () in
                print(progress)
            })
            let fileManager = FileManager.default
            XCTAssertTrue(fileManager.fileExists(atPath:(zipFilePath?.path)!))
            guard let fileExtension = zipFilePath?.pathExtension, let fileName = zipFilePath?.lastPathComponent else {
                throw ZipError.unzipFail
            }
            let directoryName = fileName.replacingOccurrences(of: ".\(fileExtension)", with: "")
            let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0] as NSURL
            let destinationUrl = documentsUrl.appendingPathComponent(directoryName, isDirectory: true)
            try Zip.unzipFile(zipFilePath!, destination: destinationUrl!, overwrite: true, password: "password", progress: nil)
            XCTAssertTrue(fileManager.fileExists(atPath:(destinationUrl?.path)!))
        }
        catch {
            XCTFail()
        }
    }

    
    func testQuickUnzipSubDir() {
        do {
            let bookURL = Bundle(for: ZipTests.self).url(forResource: "bb8", withExtension: "zip")!
            let unzipDestination = try Zip.quickUnzipFile(bookURL)
            let fileManager = FileManager.default
            let subDir = unzipDestination.appendingPathComponent("subDir")
            let imageURL = subDir.appendingPathComponent("r2W9yu9").appendingPathExtension("gif")
            
            XCTAssertTrue(fileManager.fileExists(atPath:unzipDestination.path))
            XCTAssertTrue(fileManager.fileExists(atPath:subDir.path))
            XCTAssertTrue(fileManager.fileExists(atPath:imageURL.path))
        } catch {
            XCTFail()
        }
    }

    func testFileExtensionIsNotInvalidForValidUrl() {
        let fileUrl = NSURL(string: "file.cbz")
        let result = Zip.fileExtensionIsInvalid(fileUrl?.pathExtension)
        XCTAssertFalse(result)
    }
    
    func testFileExtensionIsInvalidForInvalidUrl() {
        let fileUrl = NSURL(string: "file.xyz")
        let result = Zip.fileExtensionIsInvalid(fileUrl?.pathExtension)
        XCTAssertTrue(result)
    }
    
    func testAddedCustomFileExtensionIsValid() {
        let fileExtension = "cstm"
        Zip.addCustomFileExtension(fileExtension)
        let result = Zip.isValidFileExtension(fileExtension)
        XCTAssertTrue(result)
        Zip.removeCustomFileExtension(fileExtension)
    }
    
    func testRemovedCustomFileExtensionIsInvalid() {
        let fileExtension = "cstm"
        Zip.addCustomFileExtension(fileExtension)
        Zip.removeCustomFileExtension(fileExtension)
        let result = Zip.isValidFileExtension(fileExtension)
        XCTAssertFalse(result)
    }
    
    func testDefaultFileExtensionsIsValid() {
        XCTAssertTrue(Zip.isValidFileExtension("zip"))
        XCTAssertTrue(Zip.isValidFileExtension("cbz"))
    }
    
    func testDefaultFileExtensionsIsNotRemoved() {
        Zip.removeCustomFileExtension("zip")
        Zip.removeCustomFileExtension("cbz")
        XCTAssertTrue(Zip.isValidFileExtension("zip"))
        XCTAssertTrue(Zip.isValidFileExtension("cbz"))
    }
    
}
