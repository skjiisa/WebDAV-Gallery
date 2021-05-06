//
//  AlbumController.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import CoreData

class AlbumController: ObservableObject {
    
    @Published var newAlbum: Album?
    @Published var selection: Album?
    
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
    
}
