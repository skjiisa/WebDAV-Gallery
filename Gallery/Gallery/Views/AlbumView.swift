//
//  AlbumView.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import SwiftUI

struct AlbumView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    private var imagesFetchRequest: FetchRequest<ImageItem>
    private var images: FetchedResults<ImageItem> {
        imagesFetchRequest.wrappedValue
    }
    
    @EnvironmentObject private var albumController: AlbumController
    
    @ObservedObject var album: Album
    
    @State private var editing = false
    @State private var showingProperties = false
    
    init(_ album: Album) {
        self.album = album
        imagesFetchRequest = FetchRequest(
            entity: ImageItem.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ImageItem.index, ascending: true)],
            predicate: NSPredicate(format: "album == %@", album),
            animation: .default)
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(images) { image in
                    FileCell(image)
                        .addImageButton(image: image, numColumns: 2, enabled: editing)
                }
            }
        }
        .fixFlickering()
        .navigationTitle(album.name ??? "Album")
        .toolbar {
            HStack {
                if editing {
                    Button {
                        showingProperties = true
                    } label: {
                        Label("Album properties", systemImage: "pencil")
                    }
                    .imageScale(.large)
                    .padding(.trailing)
                }
                
                Button(editing ? "Done" : "Edit") {
                    withAnimation {
                        editing.toggle()
                    }
                }
            }
        }
        .sheet(isPresented: $showingProperties) {
            NavigationView {
                AlbumDetailView(album: album, isPresented: $showingProperties)
            }
            .environment(\.managedObjectContext, moc)
            .environmentObject(albumController)
        }
    }
}

/*
struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}
*/
