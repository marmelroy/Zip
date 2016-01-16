//
//  QuickZip.swift
//  Zip
//
//  Created by Roy Marmelstein on 16/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

extension Zip {
    
    //MARK: Quick Unzip

    /**
     Quick unzip a file. Unzips to a new folder inside the app's documents folder with the zip file's name.
     
     - parameter path: Path of zipped file. NSURL.
     
     - throws: Error if unzipping fails or if file is not found. Can be printed with a description variable.
     
     - returns: NSURL of the destination folder.
     */
    public func quickUnzipFile(path: NSURL) throws -> NSURL {
        return try quickUnzipFile(path, progress: nil)
    }
    
    /**
     Quick unzip a file. Unzips to a new folder inside the app's documents folder with the zip file's name.
     
     - parameter path: Path of zipped file. NSURL.
     - parameter progress: A progress closure called after unzipping each file in the archive. Double value betweem 0 and 1.
     
     - throws: Error if unzipping fails or if file is not found. Can be printed with a description variable.
     
     - returns: NSURL of the destination folder.
     */
    public func quickUnzipFile(path: NSURL, progress: ((progress: Double) -> ())?) throws -> NSURL {
        guard let fileExtension = path.pathExtension, let fileName = path.lastPathComponent else {
            throw ZipError.UnzipError
        }
        let directoryName = fileName.stringByReplacingOccurrencesOfString(fileExtension, withString: "")
        let destinationUrl = documentsUrl.URLByAppendingPathComponent(directoryName, isDirectory: true)
        try self.unzipFile(path, destination: destinationUrl, overwrite: true, password: nil, progress: progress)
        return destinationUrl
    }
    
    //MARK: Quick Zip
    
    /**
    Quick zip files.
    
    - parameter paths: Array of NSURL filepaths.
    - parameter fileName: File name for the resulting zip file.
    
    - throws: rror if zipping fails.
    
    - returns: NSURL of the destination folder.
    */
    public func quickZipFiles(paths: [NSURL], fileName: String) throws -> NSURL {
        return try quickZipFiles(paths, fileName: fileName, progress: nil)
    }

    /**
    Quick zip files.
    
    - parameter paths: Array of NSURL filepaths.
    - parameter fileName: File name for the resulting zip file.
    - parameter progress: A progress closure called after unzipping each file in the archive. Double value betweem 0 and 1.

    - throws: rror if zipping fails.
    
    - returns: NSURL of the destination folder.
    */
    public func quickZipFiles(paths: [NSURL], fileName: String, progress: ((progress: Double) -> ())?) throws -> NSURL {
        let destinationUrl = documentsUrl.URLByAppendingPathComponent("\(fileName).zip")
        try self.zipFiles(paths, destination: destinationUrl, password: nil, progress: progress)
        return destinationUrl
    }
    

}