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
    
    @StateObject private var imageLoader = ImageLoader()
    
    var body: some View {
        ZStack {
            if let image = imageLoader.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            if !imageLoader.done {
                ProgressView()
            }
        }
        .navigationTitle(file.name)
        .onAppear {
            imageLoader.load(file: file, webDAVController: webDAVController, account: account)
        }
    }
}
