//
//  Zip+Helpers.swift
//  Create Zip with file filter
//
//  Created by CC Laan on 11/24/21.
//

import Foundation
import Minizip

extension Zip {
    
    public class func zipFiles(_ paths: [URL], zipUrl: URL, fileFilter: ( (_ filePath : String) -> Bool  )? = nil ) -> Bool {
        do {
            try Zip.zipFiles(paths: paths, zipFilePath: zipUrl, password: nil, progress: nil, fileFilter: fileFilter)
        } catch {
            return false
        }
        return true
    }
    
    
    
    public class func zipFiles(paths: [URL], zipFilePath: URL,
                               password: String?, compression: ZipCompression = .DefaultCompression,
                               progress: ((_ progress: Double) -> ())?,
                               fileFilter: ( (_ filePath : String) -> Bool  )?
    ) throws {
        
        // File manager
        let fileManager = FileManager.default
        
        // Check whether a zip file exists at path.
        let destinationPath = zipFilePath.path
        
        // Process zip paths
        var processedPaths = ZipUtilities().processZipPaths(paths)
        if let fileFilter = fileFilter {
//            processedPaths = processedPaths.filter({ processedPath in
//                return fileFilter(processedPath.filePath())
//            })
            
            processedPaths = processedPaths.filter {  fileFilter( $0.filePath() ) }
            
        }
        
        processedPaths.forEach({ print("Zipping:  \($0.filePathURL.lastPathComponent )") })
        
        
        // Zip set up
        let chunkSize: Int = 16384
        
        // Progress handler set up
        var currentPosition: Double = 0.0
        var totalSize: Double = 0.0
        // Get totalSize for progress handler
        for path in processedPaths {
            do {
                let filePath = path.filePath()
                let fileAttributes = try fileManager.attributesOfItem(atPath: filePath)
                let fileSize = fileAttributes[FileAttributeKey.size] as? Double
                if let fileSize = fileSize {
                    totalSize += fileSize
                }
            }
            catch {}
        }
        
        let progressTracker = Progress(totalUnitCount: Int64(totalSize))
        progressTracker.isCancellable = false
        progressTracker.isPausable = false
        progressTracker.kind = ProgressKind.file
        
        // Begin Zipping
        let zip = zipOpen(destinationPath, APPEND_STATUS_CREATE)
        for path in processedPaths {
            let filePath = path.filePath()
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory)
            if !isDirectory.boolValue {
                let input = fopen(filePath, "r")
                if input == nil {
                    throw ZipError.zipFail
                }
                let fileName = path.fileName
                var zipInfo: zip_fileinfo = zip_fileinfo(tmz_date: tm_zip(tm_sec: 0, tm_min: 0, tm_hour: 0, tm_mday: 0, tm_mon: 0, tm_year: 0), dosDate: 0, internal_fa: 0, external_fa: 0)
                do {
                    let fileAttributes = try fileManager.attributesOfItem(atPath: filePath)
                    if let fileDate = fileAttributes[FileAttributeKey.modificationDate] as? Date {
                        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fileDate)
                        zipInfo.tmz_date.tm_sec = UInt32(components.second!)
                        zipInfo.tmz_date.tm_min = UInt32(components.minute!)
                        zipInfo.tmz_date.tm_hour = UInt32(components.hour!)
                        zipInfo.tmz_date.tm_mday = UInt32(components.day!)
                        zipInfo.tmz_date.tm_mon = UInt32(components.month!) - 1
                        zipInfo.tmz_date.tm_year = UInt32(components.year!)
                    }
                    if let fileSize = fileAttributes[FileAttributeKey.size] as? Double {
                        currentPosition += fileSize
                    }
                }
                catch {}
                let buffer = malloc(chunkSize)
                if let password = password, let fileName = fileName {
                    zipOpenNewFileInZip3(zip, fileName, &zipInfo, nil, 0, nil, 0, nil,Z_DEFLATED, compression.minizipCompression, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, password, 0)
                }
                else if let fileName = fileName {
                    zipOpenNewFileInZip3(zip, fileName, &zipInfo, nil, 0, nil, 0, nil,Z_DEFLATED, compression.minizipCompression, 0, -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY, nil, 0)
                }
                else {
                    throw ZipError.zipFail
                }
                var length: Int = 0
                while (feof(input) == 0) {
                    length = fread(buffer, 1, chunkSize, input)
                    zipWriteInFileInZip(zip, buffer, UInt32(length))
                }
                
                // Update progress handler
                if let progressHandler = progress{
                    progressHandler((currentPosition/totalSize))
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
            progressHandler(1.0)
        }
        
        progressTracker.completedUnitCount = Int64(totalSize)
    }
    
}


