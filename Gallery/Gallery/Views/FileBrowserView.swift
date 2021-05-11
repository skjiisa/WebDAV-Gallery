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
    @EnvironmentObject private var pathController: PathController
    
    @State private var numColumns: Int = 2
    
    @State private var offset: CGFloat = 0.0
    @State private var x: CGFloat = 0.0
    
    //MARK: Views
    
    let width = UIScreen.main.bounds.width
    
    private var backGesture: some Gesture {
        DragGesture().onChanged { value in
            guard pathController.depth > 1 else { return }
            if x == 0 && offset == 0 && value.location.x < 100 {
                withAnimation(.interactiveSpring()) {
                    offset = 100
                }
            } else {
                x = min(value.translation.width, width/2 - offset)
            }
        }.onEnded { value in
            // -8 to add some leniency
            if x + offset > width/2 - 8 {
                withAnimation(.push) {
                    pathController.back()
                }
            }
            withAnimation(.spring()) {
                x = 0
                offset = 0
            }
        }
    }
    
    private var backArrow: some View {
        Circle()
            .foregroundColor(Color(.separator))
            .frame(width: 100, height: 100)
            .overlay(
                Image(systemName: "arrow.backward")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .offset(x: 25)
                    .frame(width: 40)
                    .foregroundColor(.white)
            )
    }
    
    //MARK: Body
    
    var body: some View {
        ZStack {
            // This exists because otherwise the .transition doesn't play on the way out
            // See https://sarunw.com/posts/how-to-fix-zstack-transition-animation-in-swiftui/
            Text("A")
                .opacity(0)
                .zIndex(1)
            
            if let account = pathController.account,
               let path = pathController.path[account],
               let paths = pathController.paths[account] {
                ForEach(Array(path.enumerated()), id: \.offset) { index, dir in
                    DirectoryView(directory: paths[index], title: dir == "/" ? "Gallery" : dir, accounts: accounts, numColumns: $numColumns)
                        .transition(.move(edge: .trailing))
                }
                .environmentObject(account)
            } else {
                NavigationView {
                    VStack {
                        Text("Please add an account")
                    }
                    .navigationTitle("Gallery")
                }
            }
        }
        .gesture(backGesture)
        .overlay(backArrow.offset(x: x - width + offset))
        .onAppear {
            if pathController.account == nil {
                pathController.account = accounts.first
            }
        }
    }
    
}

//MARK: DirectoryView

struct DirectoryView<C: RandomAccessCollection>: View where C.Element == Account {
    
    //MARK: Properties
    
    @EnvironmentObject private var webDAVController: WebDAVController
    @EnvironmentObject private var pathController: PathController
    @EnvironmentObject private var account: Account
    
    var directory: String
    var title: String
    var accounts: C
    @Binding var numColumns: Int
    
    @State private var dataTask: URLSessionDataTask?
    
    private var columns: [GridItem] {
        (0..<numColumns).map { _ in GridItem(spacing: 0) }
    }
    
    //MARK: Body
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                if let files = webDAVController.files(for: account, at: directory) {
                    LazyVGrid(columns: columns) {
                        ForEach(files) { file in
                            FileCell(file, account: account)
                                .addImageButton(image: file, numColumns: numColumns)
                                .onTapGesture {
                                    if file.isDirectory {
                                        withAnimation(.push) {
                                            pathController.push(dir: file.fileName)
                                        }
                                    } else {
                                        pathController.select(file: file)
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
                            // You'd think I could just use a Picker here,
                            // but that didn't work for some reason.
                            ForEach(accounts) { account in
                                Button {
                                    pathController.account = account
                                } label: {
                                    if pathController.account == account {
                                        Label(account.username ?? "New Account", systemImage: "checkmark")
                                    } else {
                                        Text(account.username ?? "New Account")
                                    }
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
                ToolbarItem(placement: .navigation) {
                    if directory != "/" {
                        Button("Back") {
                            withAnimation(.push) {
                                pathController.back()
                            }
                        }
                    }
                }
            }
        }
        .onAppear(perform: load)
        .onChange(of: pathController.account) { account in
            if account == self.account {
                load()
            }
        }
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
        .environmentObject(PathController())
    }
}
