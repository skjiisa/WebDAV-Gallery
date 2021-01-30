//
//  ContentView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Account.entity(), sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)])
    private var accounts: FetchedResults<Account>
    
    @StateObject private var webDAVController = WebDAVController()
    
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            Group {
                if let account = accounts.first {
                    FileBrowserView(path: "/")
                        .environmentObject(account)
                } else {
                    Text("Please add an account")
                }
            }
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
        }
        .environmentObject(webDAVController)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
