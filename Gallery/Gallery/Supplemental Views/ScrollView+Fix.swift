//
//  ScrollView+Fix.swift
//  Gallery
//
//  Created by Isaac Lyons on 2/2/21.
//  Source originally from https://stackoverflow.com/a/65218077
//  CC BY-SA 4.0
//

import SwiftUI

extension ScrollView {
    public func fixFlickering() -> some View {
        self.fixFlickering { scrollView in
            scrollView
        }
    }
    
    public func fixFlickering<T: View>(@ViewBuilder configurator: @escaping (ScrollView<AnyView>) -> T) -> some View {
        GeometryReader { geometryWithSafeArea in
            GeometryReader { geometry in
                configurator(
                    ScrollView<AnyView>(axes, showsIndicators: showsIndicators) {
                        AnyView(
                            VStack {
                                content
                            }
                            .padding(.top, geometryWithSafeArea.safeAreaInsets.top)
                            .padding(.bottom, geometryWithSafeArea.safeAreaInsets.bottom)
                            .padding(.leading, geometryWithSafeArea.safeAreaInsets.leading)
                            .padding(.trailing, geometryWithSafeArea.safeAreaInsets.trailing)
                        )
                    }
                )
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
}
