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
                
                webDAVController.getImage(for: file, account: account, preview: .memoryOnly) { image, error in
                    switch error {
                    // Cached thumbnail returned
                    case .placeholder:
                        if self.image == nil {
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                        
                    // Full-size image fetched
                    case .none:
                        if let image = image {
                            DispatchQueue.main.async {
                                self.image = image
                            }
                        }
                        self.finishedFetch = true
                        
                    // Log the error
                    case .some(let unexpectedError):
                        NSLog(unexpectedError.localizedDescription)
                    }
                }
            }
        }
    }
}
