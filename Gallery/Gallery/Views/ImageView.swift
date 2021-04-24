//
//  ImageView.swift
//  Gallery
//
//  Created by Isaac Lyons on 2/5/21.
//

import SwiftUI
import WebDAV

struct ImageView: View {
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var account: Account
    
    var file: WebDAVFile
    
    @State private var startedFetch = false
    @State private var finishedFetch = false
    @State private var image: UIImage?
    
    var body: some View {
        ZStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            if startedFetch && !finishedFetch {
                ProgressView()
            }
        }
        .navigationTitle(file.name)
        .onAppear {
            if !startedFetch {
                startedFetch = true
                
                webDAVController.getThumbnail(for: file, account: account) { image, error in
                    if let error = error {
                        NSLog(error.localizedDescription)
                    }
                    // Don't set the thumbnail as the image if
                    // the full-size image has already been set.
                    if self.image == nil {
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                }
                webDAVController.getImage(for: file, account: account) { image, error in
                    if let error = error {
                        NSLog(error.localizedDescription)
                    }
                    // Don't override the thumbnail if
                    // the full-size image didn't fetch.
                    if let image = image {
                        DispatchQueue.main.async {
                            self.image = image
                            self.finishedFetch = true
                        }
                    }
                }
            }
        }
    }
}
