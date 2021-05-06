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
    
    @State private var selection: Album?
    @State private var newAlbum: Album?
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(albums) { album in
                    Button {
                        newAlbum = album
                    } label: {
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
                    newAlbum = Album(context: moc)
                } label: {
                    Label("New Album", systemImage: "plus")
                }
            }
        }
        .sheet(item: $newAlbum) { album in
            NavigationView {
                AlbumDetailView(album: album, selection: $newAlbum)
            }
            .environment(\.managedObjectContext, moc)
        }
    }
}

struct AlbumDetailView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @ObservedObject var album: Album
    @Binding var selection: Album?
    
    var body: some View {
        Form {
            TextField("Name", text: $album.wrappedName)
            
            Section {
                Button {
                    selection = nil
                    //TODO: Delete ImageItems
                    moc.delete(album)
                    PersistenceController.save(context: moc)
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
