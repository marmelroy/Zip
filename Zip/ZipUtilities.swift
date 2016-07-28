//
//  ZipUtilities.swift
//  Zip
//
//  Created by Roy Marmelstein on 26/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

internal class ZipUtilities {
    
    // File manager
    let fileManager = FileManager.default

    /**
     *  ProcessedFilePath struct
     */
    internal struct ProcessedFilePath {
        let filePathURL: URL
        let fileName: String?
        
        func filePath() -> String {
            if let filePath = filePathURL.path {
                return filePath
            }
            else {
                return String()
            }
        }
    }
    
    //MARK: Path processing
    
    /**
    Process zip paths
    
    - parameter paths: Paths as NSURL.
    
    - returns: Array of ProcessedFilePath structs.
    */
    internal func processZipPaths(_ paths: [URL]) -> [ProcessedFilePath]{
        var processedFilePaths = [ProcessedFilePath]()
        for path in paths {
            guard let filePath = path.path else {
                continue
            }
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
            if !isDirectory {
                let processedPath = ProcessedFilePath(filePathURL: path, fileName: path.lastPathComponent)
                processedFilePaths.append(processedPath)
            }
            else {
                let directoryContents = expandDirectoryFilePath(path)
                processedFilePaths.append(contentsOf: directoryContents)
            }
        }
        return processedFilePaths
    }
    
    
    /**
     Recursive function to expand directory contents and parse them into ProcessedFilePath structs.
     
     - parameter directory: Path of folder as NSURL.
     
     - returns: Array of ProcessedFilePath structs.
     */
    internal func expandDirectoryFilePath(_ directory: URL) -> [ProcessedFilePath] {
        var processedFilePaths = [ProcessedFilePath]()
        if let directoryPath = directory.path, let enumerator = fileManager.enumerator(atPath: directoryPath) {
            while let filePathComponent = enumerator.nextObject() as? String {
                let path = try! directory.appendingPathComponent(filePathComponent)
                guard let filePath = path.path, let directoryName = directory.lastPathComponent else {
                    continue
                }
                var isDirectory: ObjCBool = false
                fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
                if !isDirectory {
                    let fileName = (directoryName as NSString).appendingPathComponent(filePathComponent)
                    let processedPath = ProcessedFilePath(filePathURL: path, fileName: fileName)
                    processedFilePaths.append(processedPath)
                }
                else {
                    let directoryContents = expandDirectoryFilePath(path)
                    processedFilePaths.append(contentsOf: directoryContents)
                }
            }
        }
        return processedFilePaths
    }

}
