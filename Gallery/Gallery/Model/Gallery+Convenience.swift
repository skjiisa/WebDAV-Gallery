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

//MARK: ImageItem

extension ImageItem {
    convenience init(file: WebDAVFile, account: Account, album: Album, context moc: NSManagedObjectContext) {
        self.init(context: moc)
        self.imagePath = file.path
        self.imageSize = Int64(file.size)
        self.account = account
        self.album = album
    }
}
