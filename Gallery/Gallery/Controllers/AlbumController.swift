//
//  AlbumController.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import CoreData

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
        //TODO: Delete ImageItems
        moc.delete(album)
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
