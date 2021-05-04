//
//  FileBrowserView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import WebDAV

//MARK: FileBrowserView

struct FileBrowserView: View {
    
    //MARK: Properties
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var pathController: PathController
    
    @Namespace private var namespace
    
    @Binding var showingSettings: Bool
    
    @State private var numColumns: Int = 2
    
    @State private var offset: CGFloat = 0.0
    @State private var x: CGFloat = 0.0
    
    //MARK: Views
    
    let width = UIScreen.main.bounds.width
    
    private var backGesture: some Gesture {
        DragGesture().onChanged{ value in
            guard pathController.path.count > 1 else { return }
            if x == 0 && offset == 0 && value.location.x < 100 {
                withAnimation(.interactiveSpring()) {
                    offset = 100
                    print(offset)
                }
            } else {
                x = min(value.translation.width, width/2 - offset)
            }
        }.onEnded { value in
            // -8 to add some leniency
            if x + offset > width/2 - 8 {
                withAnimation(.push) {
                    pathController.back()
                }
            }
            withAnimation(.spring()) {
                x = 0
                offset = 0
            }
        }
    }
    
    private var backArrow: some View {
        Circle()
            .foregroundColor(Color(.separator))
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "arrow.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: 25)
                    .frame(width: 40)
                    .foregroundColor(.white)
            )
    }
    
    //MARK: Body
    
    var body: some View {
        ZStack {
            // This exists because otherwise the .transition doesn't play on the way out
            // See https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
            Text("A")
                .opacity(0)
                .zIndex(1)
            
            ForEach(Array(pathController.path.enumerated()), id: \.offset) { index, dir in
                DirectoryView(directory: pathController.paths[index], title: dir == "/" ? "Gallery" : dir, numColumns: $numColumns, showingSettings: $showingSettings)
                    .transition(.move(edge: .trailing))
            }
        }
        .gesture(backGesture)
        .overlay(backArrow.offset(x: x - width + offset))
    }
    
}

//MARK: DirectoryView

struct DirectoryView: View {
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var pathController: PathController
    @EnvironmentObject private var account: Account
    
    var directory: String
    var title: String
    @Binding var numColumns: Int
    @Binding var showingSettings: Bool
    
    @State private var fetchingFiles = false
    
    private var columns: [GridItem] {
        (0..<numColumns).map { _ in GridItem(spacing: 0) }
    }
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                if let files = webDAVController.files(for: account, at: directory) {
                    LazyVGrid(columns: columns) {
                        ForEach(files) { file in
                            FileCell(file: file)
                                .onTapGesture {
                                    if file.isDirectory {
                                        withAnimation(.push) {
                                            pathController.push(dir: file.fileName)
                                        }
                                    }
                                }
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
            .fixFlickering()
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        ZoomButtons(numColumns: $numColumns)
                            .padding(.trailing)
                        Button {
                            showingSettings = true
                        } label: {
                            Image(systemName: "gear")
                                .imageScale(.large)
                        }
                    }
                }
                ToolbarItem(placement: .navigation) {
                    if directory != "/" {
                        Button("Back") {
                            withAnimation(.push) {
                                pathController.back()
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: load)
    }
    
    //MARK: Functions
    
    private func load() {
        if !fetchingFiles {
            fetchingFiles = true
            webDAVController.listSupportedFiles(atPath: directory, account: account) { error in
                DispatchQueue.main.async {
                    fetchingFiles = false
                }
            }
        }
    }
}

//MARK: FileCell

struct FileCell: View {
    
    //MARK: Properties
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var account: Account
    
    var file: WebDAVFile
    var compact = false
//    var ns: Namespace.ID
    
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
//                .matchedGeometryEffect(id: file.id, in: ns)
            
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

//MARK: Previews

struct FileBrowserView_Previews: PreviewProvider {
    static var moc = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            FileBrowserView(showingSettings: .constant(false))
        }
        .environment(\.managedObjectContext, moc)
        .environmentObject(WebDAVController())
        .environmentObject(Account(context: moc))
        .environmentObject(PathController())
    }
}
