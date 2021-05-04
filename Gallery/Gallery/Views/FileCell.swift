//
//  FileCell.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/4/21.
//

import SwiftUI
import WebDAV

struct FileCell: View {
    
    //MARK: Properties
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var account: Account
    
    var file: WebDAVFile
    var compact = false
    
    @State private var request: URLSessionDataTask?
    @State private var fetchingFiles = false
    @State private var finishedFetch = false
    @State private var image: UIImage?
    
    //MARK: Views
    
    var imageOverlay: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if file.isDirectory {
                ZStack {
                    if let images = webDAVController.images(for: account, at: file.path),
                       images.count > 0 {
                        LazyVGrid(columns: [GridItem(), GridItem()]) {
                            ForEach(0..<4) { index in
                                if index < images.count {
                                    FileCell(file: images[index], compact: true/*, ns: ns*/)
                                }
                            }
                        }
                    }
                    let count = webDAVController.images(for: account, at: file.path)?.count ?? 0
                    Image(systemName: "folder\(count == 0 ? "" : ".fill")")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(count == 0 ? .accentColor : .gray)
                        .opacity(count == 0 ? 1 : 0.8)
                        .padding(20)
                }
            } else if finishedFetch {
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
                Text(file.fileName)
                    .lineLimit(1)
            }
        }
        .padding(compact ? 4 : 8)
        .onAppear {
            if file.isDirectory {
                fetchFiles()
            } else {
                fetchImage()
            }
        }
        .onDisappear {
            if let request = request {
                request.cancel()
                self.request = nil
            }
        }
    }
    
    //MARK: Functions
    
    private func fetchImage() {
        guard request == nil,
              image == nil,
              // These are simply previews and don't need to bother
              // updating if there's already cached content.
              webDAVController.images(for: account, at: file.path) == nil else { return }
        request = webDAVController.getThumbnail(for: file, account: account) { image, error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
            DispatchQueue.main.async {
                request = nil
                finishedFetch = true
                self.image = image
            }
        }
    }
    
    private func fetchFiles() {
        guard !fetchingFiles else { return }
        fetchingFiles = true
        webDAVController.listSupportedFiles(atPath: file.path, account: account) { error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
            DispatchQueue.main.async {
                fetchingFiles = false
                finishedFetch = true
            }
        }
    }
}

/*
struct FileCell_Previews: PreviewProvider {
    static var previews: some View {
        FileCell()
    }
}
*/
