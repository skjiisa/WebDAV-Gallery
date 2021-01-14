//
//  GalleryView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import WebDAV

struct GalleryView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var webDAVController: WebDAVController
    
    var account: Account?
    var path: String
    
    @State private var showingSettings = false
    @State private var files: [WebDAVFile] = []
    @State private var fetchingImages = false
    
    var body: some View {
        List {
            if fetchingImages {
                ProgressView()
            }
            ForEach(files) { file in
                Text(file.path)
            }
        }
        .navigationTitle("Gallery")
        .toolbar {
            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gear")
            }
            .sheet(isPresented: $showingSettings) {
                NavigationView {
                    SettingsView()
                        .toolbar {
                            Button("Done") {
                                showingSettings = false
                            }
                        }
                }
                .environment(\.managedObjectContext, moc)
                .environmentObject(webDAVController)
            }
        }
        .onAppear {
            if !fetchingImages,
               files.isEmpty,
               let account = account {
                fetchingImages = true
                webDAVController.listFiles(atPath: path, account: account) { files, error in
                    DispatchQueue.main.async {
                        fetchingImages = false
                        if let files = files {
                            self.files = files
                        }
                    }
                }
            }
        }
    }
    
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GalleryView(account: nil, path: "/")
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
