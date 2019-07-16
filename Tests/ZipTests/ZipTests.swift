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
    
    func resourcePath(_ filename: String) -> URL {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Resources", isDirectory: true)
            .appendingPathComponent(filename)
    }
    
    func testQuickUnzip() {
        do {
            let filePath = resourcePath("bb8.zip")
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
            let filePath = resourcePath("bb9.zip")
            let destinationURL = try Zip.quickUnzipFile(filePath)
            let fileManager = FileManager.default
            XCTAssertFalse(fileManager.fileExists(atPath:destinationURL.path))
        }
        catch {
            XCTAssert(true)
        }
    }
    
    func testQuickUnzipNonZipPath() {
        do {
            let filePath = resourcePath("3crBXeO.gif")
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
            let filePath = resourcePath("bb8.zip")
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
            let filePath = resourcePath("bb8.zip")
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
            let progress = Progress(totalUnitCount: 1)
            
            let filePath = resourcePath("bb8.zip")
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
            let progress = Progress(totalUnitCount:1)
            
            let imageURL1 = resourcePath("3crBXeO.gif")
            let imageURL2 = resourcePath("kYkLkPf.gif")
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
            let imageURL1 = resourcePath("3crBXeO.gif")
            let imageURL2 = resourcePath("kYkLkPf.gif")
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
            let imageURL1 = resourcePath("3crBXeO.gif")
            let imageURL2 = resourcePath("kYkLkPf.gif")
            let folderURL = resourcePath("Directory")
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
            let imageURL1 = resourcePath("3crBXeO.gif")
            let imageURL2 = resourcePath("kYkLkPf.gif")
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
            let imageURL1 = resourcePath("3crBXeO.gif")
            let imageURL2 = resourcePath("kYkLkPf.gif")
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

    func testUnzipWithUnsupportedPermissions() {
        do {
            let permissionsURL = resourcePath("unsupported_permissions.zip")
            let unzipDestination = try Zip.quickUnzipFile(permissionsURL)
            print(unzipDestination)
            let fileManager = FileManager.default
            let permission644 = unzipDestination.appendingPathComponent("unsupported_permission").appendingPathExtension("txt")
            do {
                let attributes644 = try fileManager.attributesOfItem(atPath: permission644.path)
                XCTAssertEqual(attributes644[.posixPermissions] as? Int, 0o644)
            } catch {
                XCTFail("Failed to get file attributes \(error)")
            }
        } catch {
            XCTFail("Failed extract unsupported_permissions.zip")
        }
    }

    func testUnzipPermissions() {
        do {
            let permissionsURL = resourcePath("permissions.zip")
            let unzipDestination = try Zip.quickUnzipFile(permissionsURL)
            let fileManager = FileManager.default
            let permission777 = unzipDestination.appendingPathComponent("permission_777").appendingPathExtension("txt")
            let permission600 = unzipDestination.appendingPathComponent("permission_600").appendingPathExtension("txt")
            let permission604 = unzipDestination.appendingPathComponent("permission_604").appendingPathExtension("txt")
            
            do {
                let attributes777 = try fileManager.attributesOfItem(atPath: permission777.path)
                let attributes600 = try fileManager.attributesOfItem(atPath: permission600.path)
                let attributes604 = try fileManager.attributesOfItem(atPath: permission604.path)
                XCTAssertEqual(attributes777[.posixPermissions] as? Int, 0o777)
                XCTAssertEqual(attributes600[.posixPermissions] as? Int, 0o600)
                XCTAssertEqual(attributes604[.posixPermissions] as? Int, 0o604)
            } catch {
                XCTFail("Failed to get file attributes \(error)")
            }
        } catch {
            XCTFail("Failed extract permissions.zip")
        }
    }
    
    func testQuickUnzipSubDir() {
        do {
            let bookURL = resourcePath("bb8.zip")
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

    static var allTests : [(String, (ZipTests) -> () throws -> Void)] {
        return [
            ("testQuickUnzip", testQuickUnzip),
            ("testQuickUnzipNonExistingPath", testQuickUnzipNonExistingPath),
            ("testQuickUnzipNonZipPath", testQuickUnzipNonZipPath),
            ("testQuickUnzipProgress", testQuickUnzipProgress),
            ("testQuickUnzipOnlineURL", testQuickUnzipOnlineURL),
            ("testUnzip", testUnzip),
            ("testImplicitProgressUnzip", testImplicitProgressUnzip),
            ("testImplicitProgressZip", testImplicitProgressZip),
            ("testQuickZip", testQuickZip),
            ("testQuickZipFolder", testQuickZipFolder),
            ("testZip", testZip),
            ("testZipUnzipPassword", testZipUnzipPassword),
            ("testUnzipWithUnsupportedPermissions", testUnzipWithUnsupportedPermissions),
            ("testUnzipPermissions", testUnzipPermissions),
            ("testQuickUnzipSubDir", testQuickUnzipSubDir),
            ("testFileExtensionIsNotInvalidForValidUrl", testFileExtensionIsNotInvalidForValidUrl),
            ("testFileExtensionIsInvalidForInvalidUrl", testFileExtensionIsInvalidForInvalidUrl),
            ("testAddedCustomFileExtensionIsValid", testAddedCustomFileExtensionIsValid),
            ("testRemovedCustomFileExtensionIsInvalid", testRemovedCustomFileExtensionIsInvalid),
            ("testDefaultFileExtensionsIsValid", testDefaultFileExtensionsIsValid),
            ("testDefaultFileExtensionsIsNotRemoved", testDefaultFileExtensionsIsNotRemoved),
        ]
    }
    
}
