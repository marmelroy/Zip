//
//  Zip.swift
//  Zip
//
//  Created by Roy Marmelstein on 13/12/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import minizip
import Darwin

public enum ZipError: ErrorType {
    case UnzipError
    case FileError

    public var description: String {
        switch self {
        case .UnzipError: return NSLocalizedString("Failed to open zip file.", comment: "")
        case .FileError: return NSLocalizedString("File error.", comment: "")
        }
    }
}


public class Zip {
    
    public func unzipFile(path: String, destination: String, overwrite: Bool, password: String?) throws {
        guard let zip: zipFile = unzOpen(path) else {
            throw ZipError.UnzipError
        }
        var currentPosition = 0.0
        var globalInfo: unz_global_info = unz_global_info(number_entry: 0, number_disk_with_CD: 0, size_comment: 0)
        unzGetGlobalInfo(zip, &globalInfo)
        // Begin unzipping
        if unzGoToFirstFile(zip) != UNZ_OK {
            throw ZipError.UnzipError
        }
        var ret: Int32 = 0
        var crc_ret: Int32 = 0
        
        let bufferSize = 4096
        var buffer = Array<CUnsignedChar>(count: bufferSize, repeatedValue: 0)
        let fileManager = NSFileManager.defaultManager()
        if let password = password where password.characters.count > 0 {
            ret = unzOpenCurrentFilePassword(zip, password.cStringUsingEncoding(NSASCIIStringEncoding)!)
        }
        else {
            ret = unzOpenCurrentFile(zip)
        }
        if ret != UNZ_OK {
            throw ZipError.UnzipError
        }
        var fileInfo = unz_file_info()
        memset(&fileInfo, 0, sizeof(unz_file_info))
        
        ret = unzGetCurrentFileInfo(zip, &fileInfo, nil, 0, nil, 0, nil, 0)
        if ret != UNZ_OK {
            unzCloseCurrentFile(zip)
            throw ZipError.UnzipError
        }
        
        currentPosition = currentPosition + Double(fileInfo.compressed_size)
        let fileNameSize = Int(fileInfo.size_filename) + 1
        let fileName = UnsafeMutablePointer<CChar>.alloc(fileNameSize)
        if fileName == nil {
            throw ZipError.UnzipError
        }
        unzGetCurrentFileInfo(zip, &fileInfo, fileName, UInt(fileNameSize), nil, 0, nil, 0)
        fileName[Int(fileInfo.size_filename)] = 0

        var strPath = String.fromCString(fileName)! as NSString
        var isDirectory = false
        let fileInfoSizeFileName = Int(fileInfo.size_filename-1)
        if (fileName[fileInfoSizeFileName] == "/".cStringUsingEncoding(NSUTF8StringEncoding)!.first! || fileName[fileInfoSizeFileName] == "\\".cStringUsingEncoding(NSUTF8StringEncoding)!.first!) {
            isDirectory = true;
        }
        free(fileName)
        
        if (strPath.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "/\\")).location != NSNotFound) {
            strPath = strPath.stringByReplacingOccurrencesOfString("\\", withString: "/")
        }
        let fullPath = (destination as NSString).stringByAppendingPathComponent(strPath as String)
        // TODO: GET DOS DATE FROM FILEINFO
        let modDate = NSDate()
        let directoryAttributes = [NSFileCreationDate: modDate, NSFileModificationDate: modDate]
        if isDirectory {
            try fileManager.createDirectoryAtPath(fullPath, withIntermediateDirectories: true, attributes: directoryAttributes)
        }
        else {
            try fileManager.createDirectoryAtPath((fullPath as NSString).stringByDeletingLastPathComponent, withIntermediateDirectories: true, attributes: directoryAttributes)
        }
        
        if fileManager.fileExistsAtPath(fullPath) && !isDirectory && !overwrite {
            unzCloseCurrentFile(zip)
            ret = unzGoToNextFile(zip)
        }
        
        var filePointer: UnsafeMutablePointer<FILE>
        filePointer = try ZIPFopen(fullPath)
        let readBytes = unzReadCurrentFile(zip, &buffer, 4096)
        fwrite(buffer, Int(readBytes), 1, filePointer)
        if filePointer != nil {
            if ((fullPath as NSString).pathExtension.lowercaseString == "zip") {
                // nested zip
                try unzipFile(fullPath, destination: (fullPath as NSString).stringByDeletingLastPathComponent, overwrite: overwrite, password: password)
            }
        }
        fclose(filePointer)
        crc_ret = unzCloseCurrentFile(zip)
        if crc_ret == UNZ_CRCERROR {
            throw ZipError.UnzipError
        }
        ret = unzGoToNextFile(zip)
        currentPosition++
        
    }

}