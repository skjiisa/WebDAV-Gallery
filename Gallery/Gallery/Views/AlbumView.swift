//
//  AlbumView.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import SwiftUI
import CoreData

//MARK: AlbumView

struct AlbumView: View {
    
    //MARK: Properties
    
    @Environment(\.managedObjectContext) private var moc
    
    private var imagesFetchRequest: FetchRequest<ImageItem>
    private var images: FetchedResults<ImageItem> {
        imagesFetchRequest.wrappedValue
    }
    
    @EnvironmentObject private var albumController: AlbumController
    
    @ObservedObject var album: Album
    
    @State private var editing = false
    @State private var showingProperties = false
    
    // Reordering
    @State private var dragging: ImageItem?
    @State private var changedView: Bool = false
    
    init(_ album: Album) {
        self.album = album
        imagesFetchRequest = FetchRequest(
            entity: ImageItem.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \ImageItem.index, ascending: true)],
            predicate: NSPredicate(format: "album == %@", album),
            animation: .default)
    }
    
    //MARK: Body
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: [GridItem(), GridItem()]) {
                ForEach(images) { image in
                    FileCell(image)
                        .addImageButton(image: image, numColumns: 2, enabled: editing)
                        // Reordering
                        .opacity(dragging == image && changedView ? 0 : 1)
                        .onDrag {
                            dragging = image
                            changedView = false
                            return NSItemProvider(object: String(image.path) as NSString)
                        }
                        .onDrop(of: [.text], delegate: DragRelocateDelegate(item: image, data: images, current: $dragging, changedView: $changedView, albumController: albumController))

                }
            }
        }
        .fixFlickering()
        .onDrop(of: [.text], delegate: DropOutsideDelegate(current: $dragging, changedView: $changedView, moc: moc))
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

//MARK: Drag Delegates
// Modified from https://www.reddit.com/r/SwiftUI/comments/kod5d5/how_to_reorder_in_a_lazyvgrid_or_lazyhgrid/

fileprivate struct DragRelocateDelegate: DropDelegate {
    let item: ImageItem
    var data: FetchedResults<ImageItem>
    @Binding var current: ImageItem?
    @Binding var changedView: Bool
    var albumController: AlbumController
    
    func dropEntered(info: DropInfo) {
        if let current = current,
           item != current,
           let currentIndex = data.firstIndex(of: current),
           let newOffset = data.firstIndex(of: item) {
            changedView = true
            if data[newOffset] != current {
                let indices = IndexSet(integer: currentIndex)
                albumController.move(images: data, fromOffsets: indices, toOffset: newOffset > currentIndex ? newOffset + 1 : newOffset)
            }
        } else {
            current = item
            changedView = true
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        changedView = false
        self.current = nil
        print("Dropped Inside")
        return true
    }
    
}

fileprivate struct DropOutsideDelegate: DropDelegate {
    @Binding var current: ImageItem?
    @Binding var changedView: Bool
    var moc: NSManagedObjectContext
    
    func dropEntered(info: DropInfo) {
        changedView = true
    }
    
    func performDrop(info: DropInfo) -> Bool {
        changedView = false
        current = nil
        PersistenceController.save(context: moc)
        print("Dropped Outside")
        return true
    }
}

//MARK: Previews

/*
struct AlbumView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumView()
    }
}
*/
