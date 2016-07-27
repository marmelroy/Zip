//
//  Zip.swift
//  Zip
//
//  Created by Roy Marmelstein on 13/12/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import minizip

/// Zip error type
public enum ZipError: ErrorType {
    /// File not found
    case FileNotFound
    /// Unzip fail
    case UnzipFail
    /// Zip fail
    case ZipFail
    
    /// User readable description
    public var description: String {
        switch self {
        case .FileNotFound: return NSLocalizedString("File not found.", comment: "")
        case .UnzipFail: return NSLocalizedString("Failed to unzip file.", comment: "")
        case .ZipFail: return NSLocalizedString("Failed to zip file.", comment: "")
        }
    }
}

/// Zip class
public class Zip {
    
    /**
     Set of vaild file extensions
     */
    internal static var customFileExtensions: Set<String> = []
    
    // MARK: Lifecycle
    
    /**
     Init
     
     - returns: Zip object
     */
    public init () {
    }
    
    // MARK: Unzip
    
    /**
     Unzip file
     
     - parameter zipFilePath: Local file path of zipped file. NSURL.
     - parameter destination: Local file path to unzip to. NSURL.
     - parameter overwrite:   Overwrite bool.
     - parameter password:    Optional password if file is protected.
     - parameter progress: A progress closure called after unzipping each file in the archive. Double value betweem 0 and 1.
     
     - throws: Error if unzipping fails or if fail is not found. Can be printed with a description variable.
     
     - notes: Supports implicit progress composition
     */
    
    public class func unzipFile(zipFilePath: NSURL, destination: NSURL, overwrite: Bool, password: String?, progress: ((progress: Double) -> ())?) throws {
        
        // File manager
        let fileManager = NSFileManager.defaultManager()
        
        // Check whether a zip file exists at path.
        guard let path = zipFilePath.path where destination.path != nil else {
            throw ZipError.FileNotFound
        }
        if fileManager.fileExistsAtPath(path) == false || fileExtensionIsInvalid(zipFilePath.pathExtension) {
            throw ZipError.FileNotFound
        }
        
        // Unzip set up
        var ret: Int32 = 0
        var crc_ret: Int32 = 0
        let bufferSize: UInt32 = 4096
        var buffer = Array<CUnsignedChar>(count: Int(bufferSize), repeatedValue: 0)
        
        // Progress handler set up
        var totalSize: Double = 0.0
        var currentPosition: Double = 0.0
        let fileAttributes = try fileManager.attributesOfItemAtPath(path)
        if let attributeFileSize = fileAttributes[NSFileSize] as? Double {
            totalSize += attributeFileSize
        }
        
        let progressTracker = NSProgress(totalUnitCount: Int64(totalSize))
        progressTracker.cancellable = false
        progressTracker.pausable = false
        progressTracker.kind = NSProgressKindFile
        
        // Begin unzipping
        let zip = unzOpen64(path)
        defer {
            unzClose(zip)
        }
        if unzGoToFirstFile(zip) != UNZ_OK {
            throw ZipError.UnzipFail
        }
        repeat {
            if let cPassword = password?.cStringUsingEncoding(NSASCIIStringEncoding) {
                ret = unzOpenCurrentFilePassword(zip, cPassword)
            }
            else {
                ret = unzOpenCurrentFile(zip);
            }
            if ret != UNZ_OK {
                throw ZipError.UnzipFail
            }
            var fileInfo = unz_file_info64()
            memset(&fileInfo, 0, sizeof(unz_file_info))
            ret = unzGetCurrentFileInfo64(zip, &fileInfo, nil, 0, nil, 0, nil, 0)
            if ret != UNZ_OK {
                unzCloseCurrentFile(zip)
                throw ZipError.UnzipFail
            }
            currentPosition += Double(fileInfo.compressed_size)
            let fileNameSize = Int(fileInfo.size_filename) + 1
            let fileName = UnsafeMutablePointer<CChar>.alloc(fileNameSize)
            if fileName == nil {
                throw ZipError.UnzipFail
            }
            unzGetCurrentFileInfo64(zip, &fileInfo, fileName, UInt(fileNameSize), nil, 0, nil, 0)
            fileName[Int(fileInfo.size_filename)] = 0
            guard var pathString = String(CString: fileName, encoding: NSUTF8StringEncoding) else {
                throw ZipError.UnzipFail
            }
            var isDirectory = false
            let fileInfoSizeFileName = Int(fileInfo.size_filename-1)
            if (fileName[fileInfoSizeFileName] == "/".cStringUsingEncoding(NSUTF8StringEncoding)?.first || fileName[fileInfoSizeFileName] == "\\".cStringUsingEncoding(NSUTF8StringEncoding)?.first) {
                isDirectory = true;
            }
            free(fileName)
            if pathString.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "/\\")) != nil {
                pathString = pathString.stringByReplacingOccurrencesOfString("\\", withString: "/")
            }
            guard let fullPath = destination.URLByAppendingPathComponent(pathString)!.path else {
                throw ZipError.UnzipFail
            }
            let creationDate = NSDate()
            let directoryAttributes = [NSFileCreationDate: creationDate, NSFileModificationDate: creationDate]
            do {
                if isDirectory {
                    try fileManager.createDirectoryAtPath(fullPath, withIntermediateDirectories: true, attributes: directoryAttributes)
                }
                else {
                    let parentDirectory = (fullPath as NSString).stringByDeletingLastPathComponent
                    try fileManager.createDirectoryAtPath(parentDirectory, withIntermediateDirectories: true, attributes: directoryAttributes)
                }
            } catch {}
            if fileManager.fileExistsAtPath(fullPath) && !isDirectory && !overwrite {
                unzCloseCurrentFile(zip)
                ret = unzGoToNextFile(zip)
            }
            var filePointer: UnsafeMutablePointer<FILE>
            filePointer = fopen(fullPath, "wb")
            while filePointer != nil {
                let readBytes = unzReadCurrentFile(zip, &buffer, bufferSize)
                if readBytes > 0 {
                    fwrite(buffer, Int(readBytes), 1, filePointer)
                }
                else {
                    break
                }
            }
            fclose(filePointer)
            crc_ret = unzCloseCurrentFile(zip)
            if crc_ret == UNZ_CRCERROR {
                throw ZipError.UnzipFail
            }
            ret = unzGoToNextFile(zip)
            
            // Update progress handler
            if let progressHandler = progress{
                progressHandler(progress: (currentPosition/totalSize))
            }
            
            progressTracker.completedUnitCount = Int64(currentPosition)
            
        } while (ret == UNZ_OK && ret != UNZ_END_OF_LIST_OF_FILE)
        
        // Completed. Update progress handler.
        if let progressHandler = progress{
            progressHandler(progress: 1.0)
        }
        
        progressTracker.completedUnitCount = Int64(totalSize)
        
    }
    
    // MARK: Zip
    
    /**
     Zip files.
     
     - parameter paths:       Array of NSURL filepaths.
     - parameter zipFilePath: Destination NSURL, should lead to a .zip filepath.
     - parameter password:    Password string. Optional.
     - parameter progress: A progress closure called after unzipping each file in the archive. Double value betweem 0 and 1.
     
     - throws: Error if zipping fails.
     
     - notes: Supports implicit progress composition
     */
    public class func zipFiles(paths: [NSURL], zipFilePath: NSURL, password: String?, progress: ((progress: Double) -> ())?) throws {
        
        // File manager
        let fileManager = NSFileManager.defaultManager()
        
        // Check whether a zip file exists at path.
        guard let destinationPath = zipFilePath.path else {
            throw ZipError.FileNotFound
        }
        
        // Process zip paths
        let processedPaths = ZipUtilities().processZipPaths(paths)
        
        // Zip set up
        let chunkSize: Int = 16384
        
        // Progress handler set up
        var currentPosition: Double = 0.0
        var totalSize: Double = 0.0
        // Get totalSize for progress handler
        for path in processedPaths {
            do {
                let filePath = path.filePath()
                let fileAttributes = try fileManager.attributesOfItemAtPath(filePath)
                let fileSize = fileAttributes[NSFileSize] as? Double
                if let fileSize = fileSize {
                    totalSize += fileSize
                }
            }
            catch {}
        }
        
        let progressTracker = NSProgress(totalUnitCount: Int64(totalSize))
        progressTracker.cancellable = false
        progressTracker.pausable = false
        progressTracker.kind = NSProgressKindFile
        
        // Begin Zipping
        let zip = zipOpen(destinationPath, APPEND_STATUS_CREATE)
        for path in processedPaths {
            let filePath = path.filePath()
            var isDirectory: ObjCBool = false
            fileManager.fileExistsAtPath(filePath, isDirectory: &isDirectory)
            if !isDirectory {
                let input = fopen(filePath, "r")
                if input == nil {
                    throw ZipError.ZipFail
                }
                let fileName = path.fileName
                var zipInfo: zip_fileinfo = zip_fileinfo(tmz_date: tm_zip(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0), dosDate: 0, internal_fa: 0, external_fa: 0)
                do {
                    let fileAttributes = try fileManager.attributesOfItemAtPath(filePath)
                    if let fileDate = fileAttributes[NSFileModificationDate] as? NSDate {
                        let components = NSCalendar.currentCalendar().components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: fileDate)
                        zipInfo.tmz_date.tm_sec = UInt32(components.second)
                        zipInfo.tmz_date.tm_min = UInt32(components.minute)
                        zipInfo.tmz_date.tm_hour = UInt32(components.hour)
                        zipInfo.tmz_date.tm_mday = UInt32(components.day)
                        zipInfo.tmz_date.tm_mon = UInt32(components.month) - 1
                        zipInfo.tmz_date.tm_year = UInt32(components.year)
                    }
                    if let fileSize = fileAttributes[NSFileSize] as? Double {
                        currentPosition += fileSize
                    }
                }
                catch {}
                let buffer = malloc(chunkSize)
                if let password = password, let fileName = fileName {
                    zipOpenNewFileInZip3(zip, fileName, &zipInfo, nil, 0, nil, 0, nil,Z_DEFLATED, Z_DEFAULT_COMPRESSION, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, password, 0)
                }
                else if let fileName = fileName {
                    zipOpenNewFileInZip3(zip, fileName, &zipInfo, nil, 0, nil, 0, nil,Z_DEFLATED, Z_DEFAULT_COMPRESSION, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, nil, 0)
                }
                else {
                    throw ZipError.ZipFail
                }
                var length: Int = 0
                while (feof(input) == 0) {
                    length = fread(buffer, 1, chunkSize, input)
                    zipWriteInFileInZip(zip, buffer, UInt32(length))
                }
                
                // Update progress handler
                if let progressHandler = progress{
                    progressHandler(progress: (currentPosition/totalSize))
                }
                
                progressTracker.completedUnitCount = Int64(currentPosition)
                
                zipCloseFileInZip(zip)
                free(buffer)
                fclose(input)
            }
        }
        zipClose(zip, nil)
        
        // Completed. Update progress handler.
        if let progressHandler = progress{
            progressHandler(progress: 1.0)
        }
        
        progressTracker.completedUnitCount = Int64(totalSize)
    }
    
    /**
     Check if file extension is invalid.
     
     - parameter fileExtension: A file extension.
     
     - returns: false if the extension is a valid file extension, otherwise true.
     */
    internal class func fileExtensionIsInvalid(fileExtension: String?) -> Bool {
        
        guard let fileExtension = fileExtension else { return true }
        
        return !isValidFileExtension(fileExtension)
    }
    
    /**
     Add a file extension to the set of custom file extensions
     
     - parameter fileExtension: A file extension.
     */
    public class func addCustomFileExtension(fileExtension: String) {
        customFileExtensions.insert(fileExtension)
    }
    
    /**
     Remove a file extension from the set of custom file extensions
     
     - parameter fileExtension: A file extension.
     */
    public class func removeCustomFileExtension(fileExtension: String) {
        customFileExtensions.remove(fileExtension)
    }
    
    /**
     Check if a specific file extension is valid
     
     - parameter fileExtension: A file extension.
     
     - returns: true if the extension valid, otherwise false.
     */
    public class func isValidFileExtension(fileExtension: String) -> Bool {
        
        let validFileExtensions: Set<String> = customFileExtensions.union(["zip", "cbz"])
        
        return validFileExtensions.contains(fileExtension)
    }
    
}
