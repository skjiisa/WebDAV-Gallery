//
//  Gallery+Wrapping.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import Foundation
import WebDAV

extension Account: WebDAVAccount {
    var defaultPathArray: [String] {
        ["/"] + (defaultPath?.split(separator: "/").map { String($0) } ?? [])
    }
}

extension Album {
    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }
}

//MARK: Operators

infix operator ???: NilCoalescingPrecedence
extension Collection {
    static func ??? (lhs: Self?, rhs: Self) -> Self {
        if let lhs = lhs,
           !lhs.isEmpty {
            return lhs
        }
        return rhs
    }
}
