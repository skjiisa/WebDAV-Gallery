//
//  WebDAVController.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI
import WebDAV
import KeychainSwift

class WebDAVController: ObservableObject {
    
    //MARK: Properties
    
    var webDAV = WebDAV()
    private var keychain = KeychainSwift()
    private var passwordCache: [UUID: String] = [:]
    
    @Published var files: [AccountPath: [WebDAVFile]] = [:]
    @Published var images: [AccountPath: [WebDAVFile]] = [:]
    var parents: [WebDAVFile: WebDAVFile] = [:]
    
    func files(for account: Account, at path: String) -> [WebDAVFile]? {
        files[AccountPath(account: account, path: path)]
    }
    
    func images(for account: Account, at path: String) -> [WebDAVFile]? {
        images[AccountPath(account: account, path: path)]
    }
    
    var unsupportedThumbnailSizeLimit: Int {
        get {
            UserDefaults.standard.integer(forKey: Defaults.unsupportedThumbnailSizeLimit.rawValue)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Defaults.unsupportedThumbnailSizeLimit.rawValue)
        }
    }
    
    var unsupportedThumbnailSizeLimitString: String {
        webDAV.byteCountFormatter.string(fromByteCount: Int64(unsupportedThumbnailSizeLimit))
    }
    
    init() {
        UserDefaults.standard.register(defaults: [
            Defaults.unsupportedThumbnailSizeLimit.rawValue: 1_000_000 // 1 MB
        ])
    }
    
    // Not all of these have been tested.
    // List from https://developer.apple.com/library/archive/documentation/2DDrawing/Conceptual/DrawingPrintingiOS/LoadingImages/LoadingImages.html#//apple_ref/doc/uid/TP40010156-CH17-SW7
    // plus extras
    static let imageExtensions: [String] = [
        "jpg",
        "jpeg",
        "png",
        "gif",
        "bmp",
        "bmpf",
        "tiff",
        "tif",
        "ico",
        "cur",
        "xbm",
        "webp"
        /* HEIF images cause the app to lag really badly when rendered.
         * Not sure what can be done about this. It seems to be worst the
         * first time one is displayed. When that happens, this is output:
            AVDRegister - AppleAVD HEVC codec registered
         * Can't find anything online about this. Dropping support for now.
        "heic",
        "heics",
        "heif",
        "heifs"
         */
    ]
    
    // The file extensions that support thumbnails.
    // This list is from experimentation.
    static let thumbnailExtensions: [String] = [
        "jpg",
        "jpeg",
        "png",
        "gif"
    ]
    
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
    
    @discardableResult
    func listSupportedFiles(atPath path: String, account: Account, completion: ((_ error: WebDAVError?) -> Void)? = nil) -> URLSessionDataTask? {
        guard let password = getPassword(for: account) else {
            completion?(.invalidCredentials)
            return nil
        }
        return webDAV.listFiles(atPath: path, account: account, password: password, caching: .requestEvenIfCached) { [weak self] files, error in
            if let files = files?.filter({ $0.isDirectory || WebDAVController.imageExtensions.contains($0.extension) }) {
                let accountPath = AccountPath(account: account, path: path)
                DispatchQueue.main.async {
                    if self?.files[accountPath] == nil {
                        // If this is the initial fetch, don't animate it.
                        self?.files[accountPath] = files
                        self?.images[accountPath] = files.filter { !$0.isDirectory }
                    } else {
                        // If it's updating and existing directory, animate the change.
                        withAnimation {
                            self?.files[accountPath] = files
                            self?.images[accountPath] = files.filter { !$0.isDirectory }
                        }
                    }
                }
            }
            completion?(error)
        }
    }
    
    @discardableResult
    func getImage(for file: File, account: Account, preview: WebDAV.ThumbnailPreviewMode? = .memoryOnly, completion: @escaping (_ image: UIImage?, _ error: WebDAVError?) -> Void) -> URLSessionDataTask? {
        guard let password = getPassword(for: account) else {
            completion(nil, .invalidCredentials)
            return nil
        }
        return webDAV.downloadImage(path: file.path, account: account, password: password, preview: preview, completion: completion)
    }
    
    @discardableResult
    func getThumbnail(for file: File, account: Account, completion: @escaping (_ image: UIImage?, _ error: WebDAVError?) -> Void) -> URLSessionDataTask? {
        // Don't try getting thumbnail for image that doesn't support it.
        if WebDAVController.thumbnailExtensions.contains(file.extension) {
            guard let password = getPassword(for: account) else {
                completion(nil, .invalidCredentials)
                return nil
            }
            return webDAV.downloadThumbnail(path: file.path, account: account, password: password, with: .init((width: 256, height: 256), contentMode: .fill), completion: completion)
        }
        
        // If the full-size image has already been cached, return that.
        if let cachedImage = webDAV.getCachedImage(forItemAtPath: file.path, account: account) {
            completion(cachedImage, nil)
            return nil
        }
        
        // If the full-size image is under the specified limit, just fetch that instead.
        if file.size < unsupportedThumbnailSizeLimit {
            guard let password = getPassword(for: account) else {
                completion(nil, .invalidCredentials)
                return nil
            }
            return webDAV.downloadImage(path: file.path, account: account, password: password, completion: completion)
        }
        
        completion(nil, nil)
        return nil
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
        static let slash = CharacterSet(charactersIn: "/")
        
        var account: Account
        var path: String
        
        init(account: Account, path: String) {
            self.account = account
            self.path = path.trimmingCharacters(in: WebDAVController.AccountPath.slash)
        }
    }
    
}
