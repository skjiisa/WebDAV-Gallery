//
//  AlbumDetailView.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/7/21.
//

import SwiftUI

struct AlbumDetailView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var albumController: AlbumController
    
    @ObservedObject var album: Album
    var selection: Binding<Album?>?
    var isPresented: Binding<Bool>?
    
    init(album: Album, selection: Binding<Album?>) {
        self.album = album
        self.selection = selection
    }
    
    init(album: Album, isPresented: Binding<Bool>) {
        self.album = album
        self.isPresented = isPresented
    }
    
    var body: some View {
        Form {
            TextField("Name", text: $album.wrappedName)
            
            Section {
                Button {
                    isPresented?.wrappedValue = false
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
                selection?.wrappedValue = nil
                isPresented?.wrappedValue = false
            }
        }
    }
}

/*
struct AlbumDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumDetailView()
    }
}
*/
