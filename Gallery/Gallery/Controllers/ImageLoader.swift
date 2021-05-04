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
    
    var webDAVController: WebDAVController
    var account: Account
    let thumbnail: Bool
    
    @Published var image: UIImage?
    @Published var files: [File]?
    @Published var done = false
    
    private var loaded = false
    private var task: URLSessionDataTask?
    
    init(webDAVController: WebDAVController, account: Account, thumbnail: Bool) {
        self.webDAVController = webDAVController
        self.account = account
        self.thumbnail = thumbnail
    }
    
    func load(file: File) {
        loaded = true
        if file.isDirectory {
            task = webDAVController.listSupportedFiles(atPath: file.path, account: account) { [weak self] _ in
                if let account = self?.account,
                   let files = self?.webDAVController.files(for: account, at: file.path)?.prefix(4) {
                    self?.files = Array(files)
                    self?.done = true
                }
            }
        } else if thumbnail {
            task = webDAVController.getThumbnail(for: file, account: account) { [weak self] image, _ in
                self?.image = image
                self?.done = true
            }
        } else {
            task = webDAVController.getImage(for: file, account: account) { [weak self] image, error in
                switch error {
                // Cached thumbnail returned
                case .placeholder:
                    if self?.image == nil {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                    
                // Full-size image fetched
                case .none:
                    if let image = image {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
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
    
    func load(album: Album) {
        loaded = true
        files = album.images?.prefix(4).compactMap { $0 as? ImageItem }
        done = true
    }
    
    deinit {
        task?.cancel()
    }
}
