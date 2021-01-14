//
//  AccountView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI

struct AccountView: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var webDAVController: WebDAVController
    
    @ObservedObject var account: Account
    @Binding var accountSelection: Account?
    
    @State private var username = ""
    @State private var baseURL = ""
    @State private var password = ""
    @State private var loggingIn = false
    @State private var alert: AlertItem?
    @State private var initialzed = false
    
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
                if loggingIn {
                    Spacer()
                    ProgressView()
                }
            }
        }
        .disabled(loggingIn)
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .navigationTitle("Account")
        .alert(item: $alert, content: AlertItem.alert(for:))
        .onAppear {
            if !initialzed {
                initialzed = true
                if let username = account.username {
                    self.username = username
                }
                if let baseURL = account.baseURL {
                    self.baseURL = baseURL
                }
            }
        }
        .onDisappear {
            if accountSelection == nil,
               account.username?.isEmpty ?? true,
               account.baseURL?.isEmpty ?? true {
                moc.delete(account)
            }
        }
    }
    
    private func login() {
        loggingIn = true
        account.username = username
        account.baseURL = baseURL
        webDAVController.login(account: account, password: password) { error in
            self.loggingIn = false
            switch error {
            case .none:
                self.alert = .init(title: "Login Successful!")
            case .unauthorized:
                self.alert = .init(title: "Login Failed", message: "Incorrect username or password.")
            case .invalidCredentials:
                self.alert = .init(title: "Login Failed", message: "Invalid credentials provided.")
            default:
                self.alert = .init(title: "Login Failed")
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var account: Account = {
        let account = Account(username: nil, baseURL: nil, context: PersistenceController.preview.container.viewContext)
        return account
    }()
    static var previews: some View {
        NavigationView {
            AccountView(account: account, accountSelection: .constant(nil))
        }
        .environmentObject(WebDAVController())
    }
}
