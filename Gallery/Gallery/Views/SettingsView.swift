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
    
    @State private var accountSelection: Account?
    
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
            
            Text("Hello, World!")
        }
        .navigationTitle("Settings")
        .onDisappear {
            if moc.hasChanges {
                try? moc.save()
            }
        }
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
