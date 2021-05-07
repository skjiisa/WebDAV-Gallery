//
//  AlbumController.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import CoreData
import WebDAV

class AlbumController: ObservableObject {
    
    @Published var newAlbum: Album?
    @Published var selection: Album? {
        didSet {
            loadImages()
        }
    }
    @Published var imagePaths: Set<String>?
    
    func delete(_ album: Album, context moc: NSManagedObjectContext) {
        if newAlbum == album {
            newAlbum = nil
        }
        if selection == album {
            selection = nil
        }
        
        album.images?.compactMap { $0 as? NSManagedObject }.forEach(moc.delete)
        
        moc.delete(album)
        PersistenceController.save(context: moc)
    }
    
    func toggleInSelectedAlbum(file: File, account: Account, context moc: NSManagedObjectContext) {
        guard !file.isDirectory,
              let album = selection else { return }
        
        if let image = album.images?.first(where: { ($0 as? ImageItem)?.path == file.path }) as? ImageItem {
            // Remove existing image
            imagePaths?.remove(image.path)
            moc.delete(image)
        } else if let webDAVFile = file as? WebDAVFile {
            // Add new image
            let image = ImageItem(file: webDAVFile, account: account, album: album, context: moc)
            imagePaths?.insert(image.path)
        }
        // Uncomment this once there's a way to properly edit Albums
        PersistenceController.save(context: moc)
    }
    
    private func loadImages() {
        if let selection = selection,
           let images = selection.images?.compactMap({ ($0 as? ImageItem)?.path }) {
            self.imagePaths = Set(images)
            print("Loaded images for \(selection.name ??? "Album").")
        } else {
            imagePaths = nil
        }
    }
    
}
