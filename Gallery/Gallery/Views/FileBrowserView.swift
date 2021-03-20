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
    
    var title: String?
    
    @State private var directory: WebDAVFile?
    @State private var fetchingFiles = false
    @State private var numColumns: Int = 2
    
    var contents: [WebDAVFile]? {
        webDAVController.files(for: account, at: directory?.path ?? "/")
    }
    
    private var columns: [GridItem] {
        (0..<(contents == nil ? 1 : numColumns)).map { _ in GridItem(spacing: 0) }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVGrid(columns: columns) {
                if let files = contents {
                    ForEach(files) { file in
                        if file.isDirectory {
                            Button {
                                webDAVController.parents[file] = directory
                                directory = file
                                load()
                            } label: {
                                FileCell(file: file)
                            }
                        } else {
                            FileCell(file: file)
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .fixFlickering()
        .navigationTitle(title ?? "Gallery")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ZoomButtons(numColumns: $numColumns)
            }
            ToolbarItem(placement: .navigation) {
                if directory != nil {
                    Button("Back") {
                        if let directory = self.directory {
                            self.directory = webDAVController.parents[directory]
                        } else {
                            self.directory = nil
                        }
                    }
                }
            }
        }
        .onAppear(perform: load)
    }
    
    private func load() {
        if !fetchingFiles {
            fetchingFiles = true
            webDAVController.listSupportedFiles(atPath: directory?.path ?? "/", account: account) { error in
                DispatchQueue.main.async {
                    fetchingFiles = false
                }
            }
        }
    }
    
}

struct FileCell: View {
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var account: Account
    
    var file: WebDAVFile
    
    @State private var requestID: String?
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
            
            if requestID == nil,
               image == nil {
                requestID = webDAVController.getThumbnail(for: file, account: account) { image, _, error in
                    if let error = error {
                        NSLog(error.localizedDescription)
                    }
                    DispatchQueue.main.async {
                        requestID = nil
                        finishedFetch = true
                        self.image = image
                    }
                }
            }
        }
        .onDisappear {
            if let requestID = requestID {
                webDAVController.webDAV.cancelRequest(id: requestID, account: account)
                self.requestID = nil
            }
        }
    }
}

struct FileBrowserView_Previews: PreviewProvider {
    static var moc = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            FileBrowserView()
        }
        .environment(\.managedObjectContext, moc)
        .environmentObject(Account(context: moc))
    }
}
