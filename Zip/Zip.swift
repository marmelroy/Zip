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
    case FileNotFound // File not found
    case UnzipFail // Unzip error
    case ZipFail // Zip error

    /// Description variable
    public var description: String {
        switch self {
        case .FileNotFound: return NSLocalizedString("File not found.", comment: "")
        case .UnzipFail: return NSLocalizedString("Failed to unzip zip file.", comment: "")
        case .ZipFail: return NSLocalizedString("Failed to zip file.", comment: "")
        }
    }
}


public class Zip {
    
    // Documents folder
    let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
    
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
     
     - parameter path:        Path of zipped file. NSURL.
     - parameter destination: Path to unzip to. NSURL.
     - parameter overwrite:   Overwrite bool.
     - parameter password:    Optional password if file is protected.
     - parameter progress: A progress closure called after unzipping each file in the archive. Double value betweem 0 and 1.

     - throws: Error if unzipping fails or if fail is not found. Can be printed with a description variable.
     */
    public func unzipFile(path: NSURL, destination: NSURL, overwrite: Bool, password: String?, progress: ((progress: Double) -> ())?) throws {
        // Check whether a zip file exists at path.
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path.absoluteString) == false || path.pathExtension != ".zip" {
            throw ZipError.FileNotFound
        }
        // Unzip set up
        var ret: Int32 = 0
        var crc_ret: Int32 = 0
        let bufferSize: UInt32 = 4096
        var buffer = Array<CUnsignedChar>(count: Int(bufferSize), repeatedValue: 0)
        // Begin unzipping
        let zip = unzOpen64(path.absoluteString)
        
        let fileAttributes = try fileManager.attributesOfItemAtPath(path.absoluteString)
        let totalSize = fileAttributes[NSFileSize] as? Double
        var currentPosition: Double = 0.0
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
            if (fileName[fileInfoSizeFileName] == "/".cStringUsingEncoding(NSUTF8StringEncoding)!.first! || fileName[fileInfoSizeFileName] == "\\".cStringUsingEncoding(NSUTF8StringEncoding)!.first!) {
                isDirectory = true;
            }
            free(fileName)
            if pathString.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "/\\")) != nil {
                pathString = pathString.stringByReplacingOccurrencesOfString("\\", withString: "/")
            }
            guard let fullPath = destination.URLByAppendingPathComponent(pathString).path else {
                throw ZipError.UnzipFail
            }
            let creationDate = NSDate()
            let directoryAttributes = [NSFileCreationDate: creationDate, NSFileModificationDate: creationDate]
            do {
                if isDirectory {
                    try fileManager.createDirectoryAtPath(fullPath, withIntermediateDirectories: true, attributes: directoryAttributes)
                }
                else {
                    try fileManager.createDirectoryAtPath(destination.path!, withIntermediateDirectories: true, attributes: directoryAttributes)
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
            if let progressHandler = progress, let totalSize = totalSize{
                progressHandler(progress: (currentPosition/totalSize))
            }
            ret = unzGoToNextFile(zip)
        } while (ret == UNZ_OK && ret != UNZ_END_OF_LIST_OF_FILE)
        if let progressHandler = progress{
            progressHandler(progress: 1.0)
        }

    }
    
    // MARK: Zip
    
    /**
    Zip files.
    
    - parameter paths:       Array of NSURL filepaths.
    - parameter destination: Destination NSURL, should lead to a .zip filepath.
    - parameter password:    Password string. Optional.
    - parameter progress: A progress closure called after unzipping each file in the archive. Double value betweem 0 and 1.

    - throws: Error if zipping fails.
    */
    public func zipFiles(paths: [NSURL], destination: NSURL, password: String?, progress: ((progress: Double) -> ())?) throws {
        let chunkSize: Int = 16384
        let fileManager = NSFileManager.defaultManager()
        var currentPosition: Double = 0.0
        var totalSize: Double = 0.0
        // Check if paths exist and get totalSize for progress handler
        for path in paths {
            if fileManager.fileExistsAtPath(path.absoluteString) == false {
                throw ZipError.FileNotFound
            }
            do {
                let fileAttributes = try fileManager.attributesOfItemAtPath(path.path!)
                let fileSize = fileAttributes[NSFileSize] as? Double
                if let fileSize = fileSize {
                    totalSize += fileSize
                }
            }
            catch {}
        }
        let zip = zipOpen(destination.path!, APPEND_STATUS_CREATE)
        for path in paths {
            let input = fopen(path.path!, "r")
            if input == nil {
                throw ZipError.ZipFail
            }
            let fileName = path.lastPathComponent
            var zipInfo: zip_fileinfo = zip_fileinfo(tmz_date: tm_zip(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0), dosDate: 0, internal_fa: 0, external_fa: 0)
            do {
                let fileAttributes = try fileManager.attributesOfItemAtPath(path.path!)
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
            if let progressHandler = progress{
                progressHandler(progress: (currentPosition/totalSize))
            }
            zipCloseFileInZip(zip)
            free(buffer)
            fclose(input)
        }
        zipClose(zip, nil);
    }
    

}