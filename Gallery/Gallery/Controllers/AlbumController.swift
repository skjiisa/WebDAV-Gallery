//
//  AlbumController.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import CoreData
import WebDAV

class AlbumController: ObservableObject {
    
    //MARK: Properties
    
    @Published var newAlbum: Album?
    @Published var selection: Album? {
        didSet {
            loadImages()
        }
    }
    @Published var imagePaths: Set<String>?
    
    //MARK: Public
    
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
            updateIndices(context: moc)
        } else if let webDAVFile = file as? WebDAVFile,
                  let count = imagePaths?.count {
            // Add new image
            let image = ImageItem(file: webDAVFile, index: Int16(count + 1), account: account, album: album, context: moc)
            imagePaths?.insert(image.path)
        }
        PersistenceController.save(context: moc)
    }
    
    //MARK: Private
    
    private func loadImages() {
        if let selection = selection,
           let images = selection.images?.compactMap({ ($0 as? ImageItem)?.path }) {
            self.imagePaths = Set(images)
            print("Loaded images for \(selection.name ??? "Album").")
        } else {
            imagePaths = nil
        }
    }
    
    private func updateIndices(context moc: NSManagedObjectContext) {
        guard let album = selection, let images = try? moc.fetch(album.imagesFetchRequest()) else { return }
        for (index, item) in images.enumerated() where index != item.index {
            item.index = Int16(index)
        }
    }
    
}
