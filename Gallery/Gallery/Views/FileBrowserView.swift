//
//  FileBrowserView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import WebDAV

struct FileBrowserView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var account: Account
    
    var path: String
    var title: String?
    
    @State private var fetchingImages = false
    @State private var numColumns: Int = 2
    
    private var columns: [GridItem] {
        (0..<(fetchingImages ? 1 : numColumns)).map { _ in GridItem(spacing: 0) }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns) {
                if fetchingImages {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
                if let files = webDAVController.files(for: account, at: path) {
                    ForEach(files) { file in
                        NavigationLink(destination: file.isDirectory ?
                                        AnyView(FileBrowserView(path: file.path, title: file.name)
                                                    .environmentObject(account))
                                        :
                                        AnyView(ImageView(file: file)
                                                    .environmentObject(account))
                        ) {
                            FileCell(file: file)
                        }
                    }
                }
            }
        }
        .fixFlickering()
        .navigationTitle(title ?? "Gallery")
        .toolbar {
            ZoomButtons(numColumns: $numColumns)
        }
        .onAppear {
            if !fetchingImages,
               webDAVController.files(for: account, at: path) == nil {
                fetchingImages = true
                webDAVController.listSupportedFiles(atPath: path, account: account) { error in
                    DispatchQueue.main.async {
                        fetchingImages = false
                    }
                }
            }
        }
    }
    
}

struct FileCell: View {
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var account: Account
    
    var file: WebDAVFile
    
    @State private var startedFetch = false
    @State private var finishedFetch = false
    @State private var image: UIImage?
    
    var imageOverlay: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else if file.isDirectory || finishedFetch {
                // Show a folder icon for a folder.
                // Show a photo icon for an item that
                // fetched but could not be rendered.
                Image(systemName: file.isDirectory ? "folder" : "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
            }
        }
    }
    
    var body: some View {
        VStack {
            Rectangle()
                .opacity(0)
                .aspectRatio(1, contentMode: .fill)
                .overlay(imageOverlay)
                .cornerRadius(8)
                .clipped()
            
            Text(file.fileName)
                .lineLimit(1)
        }
        .padding(8)
        .onAppear {
            guard !file.isDirectory else { return }
            
            if !startedFetch,
               image == nil {
                startedFetch = true
                webDAVController.getThumbnail(for: file, account: account) { image, _, error in
                    if let error = error {
                        NSLog(error.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        startedFetch = false
                        finishedFetch = true
                        self.image = image
                    }
                }
            }
        }
    }
}

struct FileBrowserView_Previews: PreviewProvider {
    static var moc = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            FileBrowserView(path: "/")
        }
        .environment(\.managedObjectContext, moc)
        .environmentObject(Account(context: moc))
    }
}
