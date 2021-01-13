//
//  Gallery+Convenience.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/12/21.
//

import CoreData

extension Account {
    convenience init(username: String?, baseURL: String?, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = UUID()
        self.username = username
        self.baseURL = baseURL
    }
}
