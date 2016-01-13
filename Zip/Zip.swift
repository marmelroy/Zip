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
    case UnzipError // Unzip error

    /// Description variable
    public var description: String {
        switch self {
        case .FileNotFound: return NSLocalizedString("File not found.", comment: "")
        case .UnzipError: return NSLocalizedString("Failed to unzip zip file.", comment: "")
        }
    }
}


public class Zip {
    
    /**
     Init
     
     - returns: Zip object
     */
    public init () {
    }
    
    /**
     Quick unzip file. Unzips to the app's documents folder.
     
     - parameter path: Path of zipped file. NSURL.
     
     - throws: Error if unzipping fails or if fail is not found. Can be printed with a description variable.
     */
    public func unzipFile(path: NSURL) throws {
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as NSURL
        try self.unzipFile(path, destination: documentsUrl, overwrite: true, password: nil)
    }
    
    /**
     Unzip file
     
     - parameter path:        Path of zipped file. NSURL.
     - parameter destination: Path to unzip to. NSURL.
     - parameter overwrite:   Overwrite bool.
     - parameter password:    Optional password if file is protected.
     
     - throws: Error if unzipping fails or if fail is not found. Can be printed with a description variable.
     */
    public func unzipFile(path: NSURL, destination: NSURL, overwrite: Bool, password: String?) throws {
        // Check file exists at path.
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path.absoluteString) == false {
            throw ZipError.FileNotFound
        }
        // Unzip set up
        var ret: Int32 = 0
        var crc_ret: Int32 = 0
        let bufferSize: UInt32 = 4096
        var buffer = Array<CUnsignedChar>(count: Int(bufferSize), repeatedValue: 0)
        // Begin unzipping
        let zip = unzOpen64(path.absoluteString)
        if unzGoToFirstFile(zip) != UNZ_OK {
            throw ZipError.UnzipError
        }
        repeat {
            if let cPassword = password?.cStringUsingEncoding(NSASCIIStringEncoding) {
                ret = unzOpenCurrentFilePassword(zip, cPassword)
            }
            else {
                ret = unzOpenCurrentFile(zip);
            }
            if ret != UNZ_OK {
                throw ZipError.UnzipError
            }
            var fileInfo = unz_file_info64()
            memset(&fileInfo, 0, sizeof(unz_file_info))
            ret = unzGetCurrentFileInfo64(zip, &fileInfo, nil, 0, nil, 0, nil, 0)
            if ret != UNZ_OK {
                unzCloseCurrentFile(zip)
                throw ZipError.UnzipError
            }
            let fileNameSize = Int(fileInfo.size_filename) + 1
            let fileName = UnsafeMutablePointer<CChar>.alloc(fileNameSize)
            if fileName == nil {
                throw ZipError.UnzipError
            }
            unzGetCurrentFileInfo64(zip, &fileInfo, fileName, UInt(fileNameSize), nil, 0, nil, 0)
            fileName[Int(fileInfo.size_filename)] = 0
            guard var pathString = String(CString: fileName, encoding: NSUTF8StringEncoding) else {
                throw ZipError.UnzipError
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
                throw ZipError.UnzipError
            }
            let creationDate = NSDate()
            let directoryAttributes = [NSFileCreationDate: creationDate, NSFileModificationDate: creationDate]
            if isDirectory {
                try fileManager.createDirectoryAtPath(fullPath, withIntermediateDirectories: true, attributes: directoryAttributes)
            }
            else {
                try fileManager.createDirectoryAtPath(destination.path!, withIntermediateDirectories: true, attributes: directoryAttributes)
            }
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
                throw ZipError.UnzipError
            }
            ret = unzGoToNextFile(zip)
        } while (ret == UNZ_OK && ret != UNZ_END_OF_LIST_OF_FILE)
    }

}