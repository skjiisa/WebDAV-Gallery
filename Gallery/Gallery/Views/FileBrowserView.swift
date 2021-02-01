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
    
    var body: some View {
        List {
            if fetchingImages {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            if let files = webDAVController.files(for: account, at: path) {
                ForEach(files) { file in
                    if file.isDirectory {
                        NavigationLink(destination:
                                        FileBrowserView(path: file.path, title: file.name)
                                        .environmentObject(account)
                        ) {
                            FileCell(file: file)
                        }
                    } else {
                        FileCell(file: file)
                    }
                }
            }
        }
        .navigationTitle(title ?? "Gallery")
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
    @State private var image: UIImage?
    
    var body: some View {
        HStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64,
                           height: 64 * min(1, image.size.height / image.size.width))
            }
            
            Text(file.fileName)
        }
        .onAppear {
            guard !file.isDirectory else { return }
            
            if !startedFetch,
               image == nil {
                startedFetch = true
                webDAVController.getImage(atPath: file.path, account: account) { image, _, error in
                    if let error = error {
                        print(error)
                    }
                    DispatchQueue.main.async {
                        startedFetch = false
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
