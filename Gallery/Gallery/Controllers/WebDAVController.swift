//
//  WebDAVController.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import Foundation
import WebDAV

class WebDAVController: ObservableObject {
    
    private var webDAV = WebDAV()
    
    func testLogin(account: Account, password: String, completion: @escaping (WebDAVError?) -> Void) {
        webDAV.listFiles(atPath: "/", account: account, password: password) { files, error in
            completion(error)
            //TODO: Save password to keychain if no error
        }
    }
    
}
