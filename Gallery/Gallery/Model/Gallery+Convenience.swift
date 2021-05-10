//
//  Gallery+Convenience.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/12/21.
//

import CoreData
import WebDAV

//MARK: Account

extension Account {
    convenience init(username: String?, baseURL: String?, context moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.id = UUID()
        self.username = username
        self.baseURL = baseURL
    }
}

//MARK: Album

extension Album {
    func imagesFetchRequest() -> NSFetchRequest<ImageItem> {
        let fetchRequest: NSFetchRequest<ImageItem> = ImageItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "album == %@", self)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ImageItem.index, ascending: true)]
        return fetchRequest
    }
}

//MARK: ImageItem

extension ImageItem {
    convenience init(file: WebDAVFile, index: Int16, account: Account, album: Album, context moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.imagePath = file.path
        self.imageSize = Int64(file.size)
        self.index = index
        self.account = account
        self.album = album
    }
}
