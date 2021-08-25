//
//  FileBrowserView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import WebDAV

//MARK: FileBrowserView

struct FileBrowserView: View {
    
    //MARK: Properties
    
    @FetchRequest(
        entity: Account.entity(),
        sortDescriptors: [NSSortDescriptor(key: "username", ascending: true)],
        predicate: NSPredicate(format: "username != nil AND username != \"\" AND baseURL != nil AND baseURL != \"\""),
        animation: .default)
    private var accounts: FetchedResults<Account>
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @StateObject private var navigationController = NavigationController()
    
    @State private var numColumns: Int = 2
    @State private var account: Account?
    
    //MARK: Body
    
    var body: some View {
        NavigationView {
            if let account = account {
                DirectoryView(directory: "/", title: "Gallery", accounts: accounts, account: account, numColumns: $numColumns) { account in
                    navigationController.popToRoot(animated: false)
                    self.account = account
                }
                    .environmentObject(account)
            } else {
                VStack {
                    Text("Please add an account")
                }
                .navigationTitle("Gallery")
            }
        }
        .navigationController(navigationController)
        .onAppear {
            if account == nil {
                account = accounts.first
            }
        }
    }
    
}

//MARK: DirectoryView

struct DirectoryView<C: RandomAccessCollection>: View where C.Element == Account {
    
    //MARK: Properties
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var navigationController: NavigationController
//    @EnvironmentObject private var account: Account
    
    var directory: String
    var title: String
    var accounts: C
    var account: Account
    @Binding var numColumns: Int
    var changeAccount: (Account) -> Void
    
    @State private var dataTask: URLSessionDataTask?
    
    private var columns: [GridItem] {
        (0..<numColumns).map { _ in GridItem(spacing: 0) }
    }
    
    //MARK: Body
    
    var body: some View {
            ScrollView(.vertical) {
                if let files = webDAVController.files(for: account, at: directory) {
                    LazyVGrid(columns: columns) {
                        ForEach(files) { file in
                            FileCell(file, account: account)
                                .addImageButton(image: file, numColumns: numColumns)
                                .onTapGesture {
                                    navigationController.push(title: file.name) {
                                        if file.isDirectory {
                                            DirectoryView(directory: file.path, title: file.name, accounts: accounts, account: account, numColumns: $numColumns, changeAccount: changeAccount)
                                                .environmentObject(account)
                                        } else {
                                            ImageView(file: file)
                                                .environmentObject(account)
                                        }
                                    }
                                }
                        }
                    }
                } else {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
            .fixFlickering()
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        Menu {
                            Section(header: Text("Account")) {
                                // You'd think I could just use a Picker here,
                                // but that didn't work for some reason.
                                ForEach(accounts) { account in
                                    Button {
                                        changeAccount(account)
                                    } label: {
                                        if self.account == account {
                                            Label(account.username ?? "New Account", systemImage: "checkmark")
                                        } else {
                                            Text(account.username ?? "New Account")
                                        }
                                    }
                                }
                            }
                            
                            Section(header: Text("Actions")) {
                                Button("Make default directory for account") {
                                    account.defaultPath = directory
                                    PersistenceController.save(context: moc)
                                }
                            }
                        } label: {
                            Label("Account", systemImage: "person.circle")
                                .imageScale(.large)
                        }

                        ZoomButtons(numColumns: $numColumns)
                            .padding(.trailing)
                    }
                }
            }
        .onAppear(perform: load)
    }
    
    //MARK: Functions
    
    private func load() {
        if dataTask?.state != .running {
            dataTask = webDAVController.listSupportedFiles(atPath: directory, account: account)
        }
    }
}

//MARK: Previews

struct FileBrowserView_Previews: PreviewProvider {
    static var moc = PersistenceController.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            FileBrowserView()
        }
        .environment(\.managedObjectContext, moc)
        .environmentObject(WebDAVController())
        .environmentObject(Account(context: moc))
    }
}
