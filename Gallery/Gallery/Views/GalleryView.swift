//
//  GalleryView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI

struct GalleryView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingSettings = false
    
    var body: some View {
        Group {
            Text("Hello, World!")
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
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
        }
    }
    
}

struct GalleryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GalleryView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
