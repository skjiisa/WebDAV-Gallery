//
//  ImageLoader.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/4/21.
//

import UIKit
import CoreData
import WebDAV

class ImageLoader: ObservableObject {
    
    @Published var image: UIImage?
    @Published var files: [File]?
    @Published var done = false
    
    private var loaded = false
    private var task: URLSessionDataTask?
    
    func load(file: File, webDAVController: WebDAVController, account: Account, thumbnail: Bool) {
        guard !loaded else { return }
        loaded = true
        if file.isDirectory {
            task = webDAVController.listSupportedFiles(atPath: file.path, account: account) { [weak self] _ in
                DispatchQueue.main.async {
                if let files = webDAVController.images(for: account, at: file.path)?.prefix(4) {
                        self?.files = Array(files)
                        self?.done = true
                    }
                }
            }
        } else if thumbnail {
            task = webDAVController.getThumbnail(for: file, account: account) { [weak self] image, _ in
                DispatchQueue.main.async {
                    self?.image = image
                    self?.done = true
                }
            }
        } else {
            task = webDAVController.getImage(for: file, account: account) { [weak self] image, error in
                DispatchQueue.main.async {
                    switch error {
                    // Cached thumbnail returned
                    case .placeholder:
                        if self?.image == nil {
                            self?.image = image
                        }
                        
                    // Full-size image fetched
                    case .none:
                        if let image = image {
                            self?.image = image
                        }
                        self?.done = true
                        
                    // Log the error
                    case .some(let unexpectedError):
                        NSLog(unexpectedError.localizedDescription)
                        self?.done = true
                    }
                }
            }
        }
    }
    
    func load(album: Album, webDAVController: WebDAVController) {
        guard !loaded else { return }
        loaded = true
        files = album.images?.prefix(4).compactMap { $0 as? ImageItem }
        done = true
    }
    
    func cancel() {
        task?.cancel()
        task = nil
        if !done {
            loaded = false
        }
    }
    
    deinit {
        task?.cancel()
    }
}
