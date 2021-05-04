//
//  File.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/4/21.
//

import Foundation
import WebDAV

protocol File {
    var path: String { get }
    var isDirectory: Bool { get }
    var size: Int { get }
    var `extension`: String { get }
    var fileName: String { get }
}

extension WebDAVFile: File {}
extension ImageItem: File {
    var path: String {
        imagePath ?? "/"
    }
    
    var isDirectory: Bool {
        false
    }
    
    var size: Int {
        Int(imageSize)
    }
    
    var fileURL: URL {
        URL(fileURLWithPath: path)
    }
    
    var `extension`: String {
        fileURL.pathExtension
    }
    
    var fileName: String {
        fileURL.lastPathComponent
    }
}
