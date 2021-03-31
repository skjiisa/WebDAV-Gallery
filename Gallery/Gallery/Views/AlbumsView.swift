//
//  AlbumsView.swift
//  Gallery
//
//  Created by Isaac Lyons on 3/30/21.
//

import SwiftUI

struct AlbumsView: View {
    @FetchRequest(
        entity: Album.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Album.name, ascending: true)],
        animation: .default)
    private var albums: FetchedResults<Album>
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(albums) { album in
                    
                }
            }
        }
        .navigationTitle("Albums")
    }
}

struct AlbumsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlbumsView()
        }
    }
}
