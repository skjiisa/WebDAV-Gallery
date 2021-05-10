//
//  FileCell.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/4/21.
//

import SwiftUI
import WebDAV

//MARK: FileCell

struct FileCell: View {
    
    //MARK: Properties
    
    @EnvironmentObject private var webDAVController: WebDAVController
    
    var file: File?
    var account: Account?
    var album: Album?
    var compact = false
    
    @StateObject private var imageLoader = ImageLoader()
    
    init(_ file: File, account: Account?, compact: Bool = false) {
        self.file = file
        if let image = file as? ImageItem {
            self.account = image.account
        } else {
            self.account = account
        }
        self.compact = compact
    }
    
    init(_ file: ImageItem) {
        self.file = file
        self.account = file.account
    }
    
    init(album: Album) {
        self.album = album
    }
    
    var grid: Bool {
        (file?.isDirectory ?? false) || album != nil
    }
    
    //MARK: Views
    
    var imageOverlay: some View {
        Group {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if grid {
                ZStack {
                    // Thumbnail grid
                    if let images = imageLoader.files,
                       images.count > 0 {
                        LazyVGrid(columns: [GridItem(), GridItem()]) {
                            ForEach(0..<4) { index in
                                if index < images.count {
                                    FileCell(images[index], account: account, compact: true)
                                }
                            }
                        }
                    }
                    
                    // Folder icon overlay
                    let count = imageLoader.files?.count ?? 0
                    Image(systemName: "folder\(count == 0 ? "" : ".fill")")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(count == 0 ? .accentColor : .gray)
                        .opacity(count == 0 ? 1 : 0.8)
                        .padding(20)
                }
            } else if imageLoader.done {
                // Show a photo icon for an item that
                // fetched but could not be rendered.
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(compact ? 10 : 20)
            }
        }
    }
    
    //MARK: Body
    
    var body: some View {
        VStack {
            Rectangle()
                .opacity(0)
                .aspectRatio(1, contentMode: .fill)
                .overlay(imageOverlay)
                .cornerRadius(compact ? 4 : 8)
                .clipped()
            
            if !compact {
                if let album = album {
                    AlbumNameView(album: album)
                } else {
                    Text(file?.fileName ?? "")
                        .lineLimit(1)
                }
            }
        }
        .padding(compact ? 4 : 8)
        .onAppear {
            if let file = file,
               let account = account {
                imageLoader.load(file: file, webDAVController: webDAVController, account: account, thumbnail: true)
            } else if let album = album {
                imageLoader.load(album: album, webDAVController: webDAVController)
            }
        }
        .onDisappear {
            imageLoader.cancel()
        }
    }
}

//MARK: AlbumNameView

/// This exists because if Album isn't observed, the name won't
/// update when the user changes it until the cell is reloaded.
/// Because `album` is optional in `FileCell`, it can't be an `ObservedObject`.
fileprivate struct AlbumNameView: View {
    @ObservedObject var album: Album
    
    var body: some View {
        Text(album.wrappedName)
            .lineLimit(1)
    }
}

//MARK: Previews

/*
struct FileCell_Previews: PreviewProvider {
    static var previews: some View {
        FileCell()
    }
}
*/
