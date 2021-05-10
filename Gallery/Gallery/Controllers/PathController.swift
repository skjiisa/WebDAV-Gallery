//
//  PathController.swift
//  Gallery
//
//  Created by Isaac Lyons on 3/29/21.
//

import Foundation
import WebDAV

class PathController: ObservableObject {
    
    @Published var path: [String]
    @Published var paths: [String]
    @Published var file: WebDAVFile?
    
    init() {
        path = ["/"]
        paths = ["/"]
    }
    
    func push(dir: String) {
        if path.isEmpty {
            path.append("/")
            paths.append("/")
        }
        
        path.append(dir)
        paths.append(path.dropFirst().joined(separator: "/"))
    }
    
    func back() {
        guard !path.isEmpty else { return }
        path.removeLast()
        paths.removeLast()
    }
    
    func select(file: WebDAVFile) {
        self.file = file
    }
    
    func close() {
        file = nil
    }
}
