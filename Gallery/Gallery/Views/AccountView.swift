//
//  AccountView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI

struct AccountView: View {
    
    @EnvironmentObject private var webDAVController: WebDAVController
    
    @ObservedObject var account: Account
    
    @State private var username = ""
    @State private var baseURL = ""
    @State private var password = ""
    
    var body: some View {
        Form {
            Section(header: Text("WebDAV Server URL"), footer: Text("Server must support SSL (HTTPS)")) {
                TextField("https://nextcloud.example.com/", text: $baseURL)
            }
            
            Section(header: Text("Account")) {
                TextField("Username", text: $username)
                SecureField("Password", text: $password)
            }
            
            HStack {
                Button("Login", action: login)
            }
        }
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .navigationTitle("Account")
    }
    
    private func login() {
        account.username = username
        account.baseURL = baseURL
        webDAVController.testLogin(account: account, password: password) { error in
            
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var account: Account = {
        let account = Account(context: PersistenceController.preview.container.viewContext)
        return account
    }()
    static var previews: some View {
        NavigationView {
            AccountView(account: account)
        }
        .environmentObject(WebDAVController())
    }
}
