//
//  AlbumsView.swift
//  Gallery
//
//  Created by Isaac Lyons on 3/30/21.
//

import SwiftUI

struct AlbumsView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        entity: Album.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Album.name, ascending: true)],
        animation: .default)
    private var albums: FetchedResults<Album>
    
    @EnvironmentObject private var albumController: AlbumController
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(albums) { album in
                    NavigationLink(
                        destination: AlbumView(album),
                        tag: album,
                        selection: $albumController.selection) {
                        FileCell(album: album)
                    }
                }
            }
        }
        .fixFlickering()
        .navigationTitle("Albums")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    albumController.newAlbum = Album(context: moc)
                } label: {
                    Label("New Album", systemImage: "plus")
                }
            }
        }
        .sheet(item: $albumController.newAlbum) { album in
            NavigationView {
                AlbumDetailView(album: album, selection: $albumController.newAlbum)
            }
            .environment(\.managedObjectContext, moc)
        }
    }
}

struct AlbumDetailView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var albumController: AlbumController
    
    @ObservedObject var album: Album
    @Binding var selection: Album?
    
    var body: some View {
        Form {
            TextField("Name", text: $album.wrappedName)
            
            Section {
                Button {
                    albumController.delete(album, context: moc)
                } label: {
                    HStack {
                        Spacer()
                        Text("Delete")
                        Spacer()
                    }
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle(album.name ??? "New album")
        .toolbar {
            Button("Done") {
                selection = nil
            }
        }
    }
}

struct AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlbumsView()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
