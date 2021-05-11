//
//  ContentView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Account.entity(), sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)])
    private var accounts: FetchedResults<Account>
    
    @StateObject private var webDAVController = WebDAVController()
    @StateObject private var pathController = PathController()
    @StateObject private var albumController = AlbumController()
    
    var body: some View {
        TabView {
            // File Browser
            Group {
                FileBrowserView()
                    .environmentObject(pathController)
            }
            .tabItem {
                Label("File Browser", systemImage: "folder.fill")
            }
            
            // Albums
            NavigationView {
                AlbumsView()
            }
            .tabItem {
                Label("Albums", systemImage: "photo.fill.on.rectangle.fill")
            }
            
            // Settings
            NavigationView {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
        .environmentObject(webDAVController)
        .environmentObject(albumController)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
