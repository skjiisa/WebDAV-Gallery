//
//  PathController.swift
//  Gallery
//
//  Created by Isaac Lyons on 3/29/21.
//

import Foundation

class PathController: ObservableObject {
    
    @Published var path: [String]
    @Published var paths: [String]
    
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
}
