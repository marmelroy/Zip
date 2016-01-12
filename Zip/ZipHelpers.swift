//
//  ZipHelpers.swift
//  Zip
//
//  Created by Roy Marmelstein on 12/01/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

public enum FopenMode: String {
    case Read = "r"
    case Write = "w"
}

public func ZIPFopen(path: String..., mode: FopenMode = .Read) throws -> UnsafeMutablePointer<FILE> {
    let path = joinPathComponents(path)
    let f = fopen(path, mode.rawValue)
    guard f != nil else { throw ZipError.FileError }
    return f
}

/**
 Joins path components, unless a component is an absolute
 path, in which case it discards all previous path components.
 */
func joinPathComponents(join: [String]) -> String {
    guard join.count > 0 else { return "" }
    
    return join.dropFirst(1).reduce(join[0]) {
        if $1.hasPrefix("/") {
            return $1
        } else {
            return $0 + "/" + $1
        }
    }
}