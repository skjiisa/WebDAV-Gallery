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
    
    @ObservedObject var album: Album
    
    @State private var editing = false
    
    init(_ album: Album) {
        self.album = album
        imagesFetchRequest = FetchRequest(
            entity: ImageItem.entity(),
            sortDescriptors: [],
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
            Button(editing ? "Done" : "Edit") {
                withAnimation {
                    editing.toggle()
                }
            }
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
