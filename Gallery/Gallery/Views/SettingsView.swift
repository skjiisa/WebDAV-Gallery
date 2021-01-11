//
//  SettingsView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI

struct SettingsView: View {
    
    @FetchRequest(entity: Account.entity(), sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)]) private var accounts: FetchedResults<Account>
    
    var body: some View {
        Form {
            Section(header: Text("Accounts")) {
                ForEach(accounts) { account in
                    Text(account.username ?? "")
                }
                
                NavigationLink("Add new account", destination: Text("lol"))
            }
            
            Text("Hello, World!")
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
