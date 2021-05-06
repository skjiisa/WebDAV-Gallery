//
//  Gallery+Wrapping.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import Foundation
import WebDAV

extension Account: WebDAVAccount {}

extension Album {
    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }
}

//MARK: Operators

infix operator ???: NilCoalescingPrecedence
extension String {
    static func ??? (lhs: String?, rhs: String) -> String {
        if let lhs = lhs,
           !lhs.isEmpty {
            return lhs
        }
        return rhs
    }
}
