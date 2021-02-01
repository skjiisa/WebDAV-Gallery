//
//  WebDAVController.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import UIKit
import WebDAV
import KeychainSwift

class WebDAVController: ObservableObject {
    
    //MARK: Properties
    
    var webDAV = WebDAV()
    private var keychain = KeychainSwift()
    private var passwordCache: [UUID: String] = [:]
    
    @Published var files: [AccountPath: [WebDAVFile]] = [:]
    
    func files(for account: Account, at path: String) -> [WebDAVFile]? {
        files[AccountPath(account: account, path: path)]
    }
    
    //MARK: WebDAV
    
    /// Login and save password if successful.
    /// - Parameters:
    ///   - account: The Account to log in with.
    ///   - givenPassword: The password to log in with.
    ///   If no password is given, a test login will be performed on the stored password, if any.
    ///   - completion: If credentials are invalid, this will run immediately on the same thread.
    ///   Otherwise, it runs when the nextwork call finishes on a background thread.
    ///   - error: A WebDAVError if the call was unsuccessful.
    func login(account: Account, password givenPassword: String, completion: @escaping (_ error: WebDAVError?) -> Void) {
        let password: String
        if givenPassword.isEmpty {
            guard let storedPassword = getPassword(for: account) else {
                return completion(.invalidCredentials)
            }
            password = storedPassword
        } else {
            password = givenPassword
        }
        
        webDAV.listFiles(atPath: "/", account: account, password: password) { [weak self] files, error in
            switch error {
            case .none:
                guard let id = account.id else { break }
                self?.keychain.set(password, forKey: id.uuidString)
                self?.passwordCache[id] = password
            default: break
            }
            completion(error)
        }
    }
    
    func listFiles(atPath path: String, account: Account, completion: @escaping (_ error: WebDAVError?) -> Void) {
        guard let password = getPassword(for: account) else { return completion(.invalidCredentials) }
        webDAV.listFiles(atPath: path, account: account, password: password) { [weak self] files, error in
            if let files = files {
                let accountPath = AccountPath(account: account, path: path)
                DispatchQueue.main.async {
                    self?.files[accountPath] = files
                }
            }
            completion(error)
        }
    }
    
    func getImage(atPath path: String, account: Account, completion: @escaping (_ image: UIImage?, _ cachedImageURL: URL?, _ error: WebDAVError?) -> Void) {
        guard let password = getPassword(for: account) else { return completion(nil, nil, .invalidCredentials) }
        webDAV.downloadImage(path: path, account: account, password: password, completion: completion)
    }
    
    //MARK: Private
    
    private func getPassword(for account: Account) -> String? {
        guard let id = account.id else { return nil }
        if let cachedPassword = passwordCache[id] {
            return cachedPassword
        }
        
        let password = keychain.get(id.uuidString)
        if let password = password {
            passwordCache[id] = password
        }
        return password
    }
    
    //MARK: AccountPath
    
    struct AccountPath: Hashable {
        var account: Account
        var path: String
        //TODO: write a custom initializer that modifies the path to a standard format
        // For example, /path/, /path, path, and path/ will all give the same results
        // from a `listFiles` call, but will generate different AccountPaths and thus
        // different `files` dictionary keys.
    }
    
}
