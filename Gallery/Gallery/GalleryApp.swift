//
//  GalleryApp.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI

@main
struct GalleryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
