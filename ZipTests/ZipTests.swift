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

    #if os(Linux)
    private let tearDownBlocksQueue = DispatchQueue(label: "XCTest.XCTestCase.tearDownBlocks.lock")
    private var tearDownBlocks: [() -> Void] = []
    func addTeardownBlock(_ block: @escaping () -> Void) {
        tearDownBlocksQueue.sync { tearDownBlocks.append(block) }
    }
    #endif

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
        #if os(Linux)
        var blocks = tearDownBlocksQueue.sync { tearDownBlocks }
        while let next = blocks.popLast() { next() }
        #endif
    }

    private func url(forResource resource: String, withExtension ext: String? = nil) -> URL? {
        #if Xcode
        return Bundle(for: ZipTests.self).url(forResource: resource, withExtension: ext)
        #else
        let testDirPath = URL(fileURLWithPath: String(#file)).deletingLastPathComponent()
        let resourcePath = testDirPath.appendingPathComponent("Resources").appendingPathComponent(resource)
        return ext.map { resourcePath.appendingPathExtension($0) } ?? resourcePath
        #endif
    }

    private func temporaryDirectory() -> URL {
        if #available(macOS 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
            return FileManager.default.temporaryDirectory
        } else {
            return URL(fileURLWithPath: NSTemporaryDirectory())
        }
    }

    private func autoRemovingSandbox() throws -> URL {
        let sandbox = temporaryDirectory().appendingPathComponent("ZipTests_" + UUID().uuidString, isDirectory: true)
        // We can always create it. UUID should be unique.
        try FileManager.default.createDirectory(at: sandbox, withIntermediateDirectories: true, attributes: nil)
        // Schedule the teardown block _after_ creating the directory has been created (so that if it fails, no teardown block is registered).
        addTeardownBlock {
            do {
                try FileManager.default.removeItem(at: sandbox)
            } catch {
                print("Could not remove test sandbox at '\(sandbox.path)': \(error)")
            }
        }
        return sandbox
    }

    func testQuickUnzip() throws {
        let filePath = url(forResource: "bb8", withExtension: "zip")!
        let destinationURL = try Zip.quickUnzipFile(filePath)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: destinationURL)
        }
        XCTAssertTrue(FileManager.default.fileExists(atPath: destinationURL.path))
    }
    
    func testQuickUnzipNonExistingPath() {
        let filePath = URL(fileURLWithPath: "/some/path/to/nowhere/bb9.zip")
        XCTAssertThrowsError(try Zip.quickUnzipFile(filePath))
    }
    
    func testQuickUnzipNonZipPath() {
        let filePath = url(forResource: "3crBXeO", withExtension: "gif")!
        XCTAssertThrowsError(try Zip.quickUnzipFile(filePath))
    }
    
    func testQuickUnzipProgress() throws {
        let filePath = url(forResource: "bb8", withExtension: "zip")!
        let destinationURL = try Zip.quickUnzipFile(filePath, progress: { progress in
            XCTAssertFalse(progress.isNaN)
        })
        addTeardownBlock {
            try? FileManager.default.removeItem(at: destinationURL)
        }
    }
    
    func testQuickUnzipOnlineURL() {
        let filePath = URL(string: "http://www.google.com/google.zip")!
        XCTAssertThrowsError(try Zip.quickUnzipFile(filePath))
    }
    
    func testUnzip() throws {
        let filePath = url(forResource: "bb8", withExtension: "zip")!
        let destinationPath = try autoRemovingSandbox()

        try Zip.unzipFile(filePath, destination: destinationPath, overwrite: true, password: "password", progress: nil)

        XCTAssertTrue(FileManager.default.fileExists(atPath: destinationPath.path))
    }
    
    func testImplicitProgressUnzip() throws {
        let progress = Progress(totalUnitCount: 1)

        let filePath = url(forResource: "bb8", withExtension: "zip")!
        let destinationPath = try autoRemovingSandbox()

        progress.becomeCurrent(withPendingUnitCount: 1)
        try Zip.unzipFile(filePath, destination: destinationPath, overwrite: true, password: "password", progress: nil)
        progress.resignCurrent()

        XCTAssertTrue(progress.totalUnitCount == progress.completedUnitCount)
    }
    
    func testImplicitProgressZip() throws {
        let progress = Progress(totalUnitCount: 1)

        let imageURL1 = url(forResource: "3crBXeO", withExtension: "gif")!
        let imageURL2 = url(forResource: "kYkLkPf", withExtension: "gif")!
        let sandboxFolder = try autoRemovingSandbox()
        let zipFilePath = sandboxFolder.appendingPathComponent("archive.zip")

        progress.becomeCurrent(withPendingUnitCount: 1)
        try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath, password: nil, progress: nil)
        progress.resignCurrent()

        XCTAssertTrue(progress.totalUnitCount == progress.completedUnitCount)
    }
    
    func testQuickZip() throws {
        let imageURL1 = url(forResource: "3crBXeO", withExtension: "gif")!
        let imageURL2 = url(forResource: "kYkLkPf", withExtension: "gif")!
        let destinationURL = try Zip.quickZipFiles([imageURL1, imageURL2], fileName: "archive")
        XCTAssertTrue(FileManager.default.fileExists(atPath:destinationURL.path))
        addTeardownBlock {
            try? FileManager.default.removeItem(at: destinationURL)
        }
    }
    
    func testQuickZipFolder() throws {
        let fileManager = FileManager.default
        let imageURL1 = url(forResource: "3crBXeO", withExtension: "gif")!
        let imageURL2 = url(forResource: "kYkLkPf", withExtension: "gif")!
        let folderURL = try autoRemovingSandbox()
        let targetImageURL1 = folderURL.appendingPathComponent("3crBXeO.gif")
        let targetImageURL2 = folderURL.appendingPathComponent("kYkLkPf.gif")
        try fileManager.copyItem(at: imageURL1, to: targetImageURL1)
        try fileManager.copyItem(at: imageURL2, to: targetImageURL2)
        let destinationURL = try Zip.quickZipFiles([folderURL], fileName: "directory")
        XCTAssertTrue(fileManager.fileExists(atPath: destinationURL.path))
        addTeardownBlock {
            try? FileManager.default.removeItem(at: destinationURL)
        }
    }

    func testZip() throws {
        let imageURL1 = url(forResource: "3crBXeO", withExtension: "gif")!
        let imageURL2 = url(forResource: "kYkLkPf", withExtension: "gif")!
        let sandboxFolder = try autoRemovingSandbox()
        let zipFilePath = sandboxFolder.appendingPathComponent("archive.zip")
        try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath, password: nil, progress: nil)
        XCTAssertTrue(FileManager.default.fileExists(atPath: zipFilePath.path))
    }
    
    func testZipUnzipPassword() throws {
        let imageURL1 = url(forResource: "3crBXeO", withExtension: "gif")!
        let imageURL2 = url(forResource: "kYkLkPf", withExtension: "gif")!
        let zipFilePath = try autoRemovingSandbox().appendingPathComponent("archive.zip")
        try Zip.zipFiles(paths: [imageURL1, imageURL2], zipFilePath: zipFilePath, password: "password", progress: nil)
        let fileManager = FileManager.default
        XCTAssertTrue(fileManager.fileExists(atPath: zipFilePath.path))
        let directoryName = zipFilePath.lastPathComponent.replacingOccurrences(of: ".\(zipFilePath.pathExtension)", with: "")
        let destinationUrl = try autoRemovingSandbox().appendingPathComponent(directoryName, isDirectory: true)
        try Zip.unzipFile(zipFilePath, destination: destinationUrl, overwrite: true, password: "password", progress: nil)
        XCTAssertTrue(fileManager.fileExists(atPath: destinationUrl.path))
    }

    func testUnzipWithUnsupportedPermissions() throws {
        let permissionsURL = url(forResource: "unsupported_permissions", withExtension: "zip")!
        let unzipDestination = try Zip.quickUnzipFile(permissionsURL)
        let permission644 = unzipDestination.appendingPathComponent("unsupported_permission").appendingPathExtension("txt")
        let foundPermissions = try FileManager.default.attributesOfItem(atPath: permission644.path)[.posixPermissions] as? Int
        #if os(Linux)
        let expectedPermissions = 0o664
        #else
        let expectedPermissions = 0o644
        #endif
        XCTAssertNotNil(foundPermissions)
        XCTAssertEqual(foundPermissions, expectedPermissions,
                       "\(foundPermissions.map { String($0, radix: 8) } ?? "nil") is not equal to \(String(expectedPermissions, radix: 8))")
    }

    func testUnzipPermissions() throws {
        let permissionsURL = url(forResource: "permissions", withExtension: "zip")!
        let unzipDestination = try Zip.quickUnzipFile(permissionsURL)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: unzipDestination)
        }
        let fileManager = FileManager.default
        let permission777 = unzipDestination.appendingPathComponent("permission_777").appendingPathExtension("txt")
        let permission600 = unzipDestination.appendingPathComponent("permission_600").appendingPathExtension("txt")
        let permission604 = unzipDestination.appendingPathComponent("permission_604").appendingPathExtension("txt")

        let attributes777 = try fileManager.attributesOfItem(atPath: permission777.path)
        let attributes600 = try fileManager.attributesOfItem(atPath: permission600.path)
        let attributes604 = try fileManager.attributesOfItem(atPath: permission604.path)
        XCTAssertEqual(attributes777[.posixPermissions] as? Int, 0o777)
        XCTAssertEqual(attributes600[.posixPermissions] as? Int, 0o600)
        XCTAssertEqual(attributes604[.posixPermissions] as? Int, 0o604)
    }
    
    func testQuickUnzipSubDir() throws {
        let bookURL = url(forResource: "bb8", withExtension: "zip")!
        let unzipDestination = try Zip.quickUnzipFile(bookURL)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: unzipDestination)
        }
        let fileManager = FileManager.default
        let subDir = unzipDestination.appendingPathComponent("subDir")
        let imageURL = subDir.appendingPathComponent("r2W9yu9").appendingPathExtension("gif")

        XCTAssertTrue(fileManager.fileExists(atPath: unzipDestination.path))
        XCTAssertTrue(fileManager.fileExists(atPath: subDir.path))
        XCTAssertTrue(fileManager.fileExists(atPath: imageURL.path))
    }

    func testFileExtensionIsNotInvalidForValidUrl() {
        let fileUrl = URL(string: "file.cbz")
        let result = Zip.fileExtensionIsInvalid(fileUrl?.pathExtension)
        XCTAssertFalse(result)
    }
    
    func testFileExtensionIsInvalidForInvalidUrl() {
        let fileUrl = URL(string: "file.xyz")
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
