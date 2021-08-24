//
//  NavigationController.swift
//  Gallery
//
//  Created by Elaine Lyons on 8/24/21.
//

import SwiftUI
import Introspect

//MARK: Navigation Controller

class NavigationController: ObservableObject {
    var uiNavigationController: UINavigationController?
    
    func push<Content: View>(title: String? = nil, animated: Bool = true, @ViewBuilder _ content: () -> Content) {
        guard let nc = uiNavigationController else { return }
        let vc = UIHostingController(rootView: content())
        vc.title = title
        nc.pushViewController(vc, animated: animated)
    }
}

extension NavigationView {
    func navigationController(_ navigationController: NavigationController) -> some View {
        self.environmentObject(navigationController)
            .introspectNavigationController { nc in
                navigationController.uiNavigationController = nc
            }
    }
}

//MARK: Disclosure Indicator

struct DisclosureIndicator: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
            Image(systemName: "chevron.forward")
                .foregroundColor(Color(.tertiaryLabel))
                .imageScale(.small)
                .font(.bold(.body)())
        }
    }
}

extension View {
    func addDisclosureIndicator() -> some View {
        modifier(DisclosureIndicator())
    }
}
