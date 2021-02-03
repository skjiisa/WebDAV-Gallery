//
//  SettingsView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        entity: Account.entity(),
        sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)],
        animation: .default)
    private var accounts: FetchedResults<Account>
    
    @EnvironmentObject private var webDAVController: WebDAVController
    
    @State private var accountSelection: Account?
    @State private var cacheSize: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Accounts")) {
                ForEach(accounts) { account in
                    NavigationLink(
                        destination: AccountView(account: account, accountSelection: $accountSelection),
                        tag: account,
                        selection: $accountSelection) {
                        TextWithCaption(account.username ?? "New Account", caption: account.baseURL)
                            .foregroundColor(account.username == nil ? .secondary : .primary)
                    }
                }
                
                Button("Add new account") {
                    let account = Account(username: nil, baseURL: nil, context: moc)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        accountSelection = account
                    }
                }
            }
            
            Section(header: Text("Local files")) {
                Text("Cache size: \(cacheSize)")
                Button("Clear cache") {
                    try? webDAVController.webDAV.deleteAllCachedData()
                    calculateCacheSize()
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear(perform: calculateCacheSize)
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
    }
    
    private func calculateCacheSize() {
        cacheSize = webDAVController.webDAV.getCacheSize()
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
