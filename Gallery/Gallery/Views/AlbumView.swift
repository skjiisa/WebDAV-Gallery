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
                }
            }
        }
        .fixFlickering()
        .navigationTitle(album.name ??? "Album")
    }
}

/*
struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}
*/
