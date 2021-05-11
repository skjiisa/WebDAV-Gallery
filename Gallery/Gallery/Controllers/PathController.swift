//
//  PathController.swift
//  Gallery
//
//  Created by Isaac Lyons on 3/29/21.
//

import Foundation
import WebDAV

class PathController: ObservableObject {
    
    struct AccountFile: Identifiable {
        var account: Account
        var file: WebDAVFile
        
        var id: String {
            account.description + file.path
        }
    }
    
    @Published var account: Account? {
        didSet {
            loadAccount()
        }
    }
    @Published var path: [Account: [String]] = [:]
    @Published var paths: [Account: [String]] = [:]
    @Published var file: AccountFile?
    
    var depth: Int {
        guard let account = account,
              let thisPath = path[account] else { return 0 }
        return thisPath.count
    }
    
    func push(dir: String) {
        guard let account = account else { return }
        loadAccount()
        
        path[account]?.append(dir)
        paths[account]?.append(path[account]!.dropFirst().joined(separator: "/"))
    }
    
    func back() {
        guard let account = account else { return }
        if path[account]?.count ?? 0 > 1 {
            path[account]?.removeLast()
            paths[account]?.removeLast()
        } else {
            self.account = nil
        }
    }
    
    func select(file: WebDAVFile) {
        guard let account = account else { return }
        self.file = AccountFile(account: account, file: file)
    }
    
    func close() {
        file = nil
    }
    
    private func loadAccount() {
        guard let account = account else { return }
        if (path[account] ?? []).isEmpty {
            path[account] = ["/"]
            paths[account] = ["/"]
        }
    }
}
