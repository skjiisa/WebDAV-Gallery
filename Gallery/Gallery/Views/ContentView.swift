//
//  ContentView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @FetchRequest(entity: Account.entity(), sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)])
    private var accounts: FetchedResults<Account>
    
    @StateObject private var webDAVController = WebDAVController()
    
    var body: some View {
        NavigationView {
            FileBrowserView(account: accounts.first, path: "/")
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
