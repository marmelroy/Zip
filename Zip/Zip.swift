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
        let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(path)
        let fileSize = fileAttributes[NSFileSize]
        var currentPosition = 0.0
        var globalInfo: unz_global_info = unz_global_info(number_entry: 0, number_disk_with_CD: 0, size_comment: 0)
        unzGetGlobalInfo(zip, &globalInfo)
        // Begin unzipping
        if unzGoToFirstFile(zip) != UNZ_OK {
            throw ZipError.UnzipError
        }
        let canceled = false
        var ret: Int32 = 0
        var crc_ret: Int32 = 0
        
        let bufferSize = 4096
        var buffer = Array<CUnsignedChar>(count: bufferSize, repeatedValue: 0)
        let fileManager = NSFileManager.defaultManager()
        var directoriesModificationDates = NSMutableSet()
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
        //        crc_ret = unzCloseCurrentFile( zip );
        //        if (crc_ret == UNZ_CRCERROR) {
        //            //CRC ERROR
        //            return NO;
        //        }
        //        ret = unzGoToNextFile( zip );
        //
        //        // Message delegate
        //        if ([delegate respondsToSelector:@selector(zipArchiveDidUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
        //            [delegate zipArchiveDidUnzipFileAtIndex:currentFileNumber totalFiles:(NSInteger)globalInfo.number_entry
        //                archivePath:path fileInfo:fileInfo];
        //        } else if ([delegate respondsToSelector: @selector(zipArchiveDidUnzipFileAtIndex:totalFiles:archivePath:unzippedFilePath:)]) {
        //            [delegate zipArchiveDidUnzipFileAtIndex: currentFileNumber totalFiles: (NSInteger)globalInfo.number_entry
        //                archivePath:path unzippedFilePath: fullPath];
        //        }
        //
        //        currentFileNumber++;
        //        if (progressHandler)
        //        {
        //            progressHandler(strPath, fileInfo, currentFileNumber, globalInfo.number_entry);
        //        }

//
//                // Set the original datetime property
//                if (fileInfo.dosDate != 0) {
//                    NSDate *orgDate = [[self class] _dateWithMSDOSFormat:(UInt32)fileInfo.dosDate];
//                    NSDictionary *attr = @{NSFileModificationDate: orgDate};
//                    
//                    if (attr) {
//                        if ([fileManager setAttributes:attr ofItemAtPath:fullPath error:nil] == NO) {
//                            // Can't set attributes
//                            NSLog(@"[SSZipArchive] Failed to set attributes - whilst setting modification date");
//                        }
//                    }
//                }
//                
//                // Set the original permissions on the file
//                uLong permissions = fileInfo.external_fa >> 16;
//                if (permissions != 0) {
//                    // Store it into a NSNumber
//                    NSNumber *permissionsValue = @(permissions);
//                    
//                    // Retrieve any existing attributes
//                    NSMutableDictionary *attrs = [[NSMutableDictionary alloc] initWithDictionary:[fileManager attributesOfItemAtPath:fullPath error:nil]];
//                    
//                    // Set the value in the attributes dict
//                    attrs[NSFilePosixPermissions] = permissionsValue;
//                    
//                    // Update attributes
//                    if ([fileManager setAttributes:attrs ofItemAtPath:fullPath error:nil] == NO) {
//                        // Unable to set the permissions attribute
//                        NSLog(@"[SSZipArchive] Failed to set attributes - whilst setting permissions");
//                    }
//                    
//                    #if !__has_feature(objc_arc)
//                        [attrs release];
//                    #endif
//                }
//            }
//        }
//        else
//        {
//            // Assemble the path for the symbolic link
//            NSMutableString* destinationPath = [NSMutableString string];
//            int bytesRead = 0;
//            while((bytesRead = unzReadCurrentFile(zip, buffer, 4096)) > 0)
//            {
//                buffer[bytesRead] = (int)0;
//                [destinationPath appendString:@((const char*)buffer)];
//            }
//            
//            // Create the symbolic link (making sure it stays relative if it was relative before)
//            int symlinkError = symlink([destinationPath cStringUsingEncoding:NSUTF8StringEncoding],
//                [fullPath cStringUsingEncoding:NSUTF8StringEncoding]);
//            
//            if(symlinkError != 0)
//            {
//                NSLog(@"Failed to create symbolic link at \"%@\" to \"%@\". symlink() error code: %d", fullPath, destinationPath, errno);
//            }
//        }
//        
//        crc_ret = unzCloseCurrentFile( zip );
//        if (crc_ret == UNZ_CRCERROR) {
//            //CRC ERROR
//            return NO;
//        }
//        ret = unzGoToNextFile( zip );
//        
//        // Message delegate
//        if ([delegate respondsToSelector:@selector(zipArchiveDidUnzipFileAtIndex:totalFiles:archivePath:fileInfo:)]) {
//            [delegate zipArchiveDidUnzipFileAtIndex:currentFileNumber totalFiles:(NSInteger)globalInfo.number_entry
//                archivePath:path fileInfo:fileInfo];
//        } else if ([delegate respondsToSelector: @selector(zipArchiveDidUnzipFileAtIndex:totalFiles:archivePath:unzippedFilePath:)]) {
//            [delegate zipArchiveDidUnzipFileAtIndex: currentFileNumber totalFiles: (NSInteger)globalInfo.number_entry
//                archivePath:path unzippedFilePath: fullPath];
//        }
//        
//        currentFileNumber++;
//        if (progressHandler)
//        {
//            progressHandler(strPath, fileInfo, currentFileNumber, globalInfo.number_entry);
//        }
//    }
//} while(ret == UNZ_OK && ret != UNZ_END_OF_LIST_OF_FILE);
//
//// Close
//unzClose(zip);
//
//// The process of decompressing the .zip archive causes the modification times on the folders
//// to be set to the present time. So, when we are done, they need to be explicitly set.
//// set the modification date on all of the directories.
//NSError * err = nil;
//for (NSDictionary * d in directoriesModificationDates) {
//    if (![[NSFileManager defaultManager] setAttributes:@{NSFileModificationDate: d[@"modDate"]} ofItemAtPath:d[@"path"] error:&err]) {
//        NSLog(@"[SSZipArchive] Set attributes failed for directory: %@.", d[@"path"]);
//    }
//    if (err) {
//        NSLog(@"[SSZipArchive] Error setting directory file modification date attribute: %@",err.localizedDescription);
//    }
//}
//
//#if !__has_feature(objc_arc)
//[directoriesModificationDates release];
//#endif
//
//// Message delegate
//}

}