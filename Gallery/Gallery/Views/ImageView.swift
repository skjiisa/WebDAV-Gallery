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
    @State private var image: UIImage?
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
        .navigationTitle(file.name)
        .onAppear {
            if !startedFetch {
                startedFetch = true
                
                webDAVController.getThumbnail(atPath: file.path, account: account) { image, _, error in
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
                webDAVController.getImage(atPath: file.path, account: account) { image, _, error in
                    if let error = error {
                        NSLog(error.localizedDescription)
                    }
                    // Don't override the thumbnail if
                    // the full-size image didn't fetch.
                    if let image = image {
                        DispatchQueue.main.async {
                            self.image = image
                        }
                    }
                }
            }
        }
    }
}
