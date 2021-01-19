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
    
    var account: Account
    var path: String
    
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
                    Text(file.name)
                }
            }
        }
        .navigationTitle("Gallery")
        .onAppear {
            if !fetchingImages,
               webDAVController.files(for: account, at: path) == nil {
                fetchingImages = true
                webDAVController.listFiles(atPath: path, account: account) { error in
                    DispatchQueue.main.async {
                        fetchingImages = false
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
            FileBrowserView(account: Account(context: moc), path: "/")
        }
        .environment(\.managedObjectContext, moc)
    }
}
