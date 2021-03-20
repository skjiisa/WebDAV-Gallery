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
    
    @Namespace private var namespace
    
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
                                withAnimation {
                                    webDAVController.parents[file] = directory
                                    directory = file
                                    load()
                                }
                            } label: {
                                FileCell(file: file, ns: namespace)
                            }
                        } else {
                            FileCell(file: file, ns : namespace)
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
                    Button("Back", action: back)
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
    
    private func back() {
        withAnimation {
            if let directory = self.directory {
                self.directory = webDAVController.parents[directory]
            } else {
                self.directory = nil
            }
        }
        load()
    }
    
}

struct FileCell: View {
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var account: Account
    
    var file: WebDAVFile
    var compact = false
    var ns: Namespace.ID
    
    @State private var requestID: String?
    @State private var fetchingFiles = false
    @State private var finishedFetch = false
    @State private var image: UIImage?
    
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
                                    FileCell(file: images[index], compact: true, ns: ns)
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
    
    var body: some View {
        VStack {
            Rectangle()
                .opacity(0)
                .aspectRatio(1, contentMode: .fill)
                .overlay(imageOverlay)
                .cornerRadius(compact ? 4 : 8)
                .clipped()
                .matchedGeometryEffect(id: file.id, in: ns)
            
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
            if let requestID = requestID {
                webDAVController.webDAV.cancelRequest(id: requestID, account: account)
                self.requestID = nil
            }
        }
    }
    
    private func fetchImage() {
        guard requestID == nil,
              image == nil,
              // These are simply previews and don't need to bother
              // updating if there's already cached content.
              webDAVController.images(for: account, at: file.path) == nil else { return }
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
