//
//  ZoomButtons.swift
//  Gallery
//
//  Created by Isaac Lyons on 2/5/21.
//

import SwiftUI

struct ZoomButtons: View {
    @Binding var numColumns: Int
    var minZoom: Int = 2
    var maxZoom: Int = 8
    
    var zoomInButton: some View {
        Button {
            withAnimation {
                numColumns -= 1
            }
        } label: {
            Image(systemName: "plus")
                .imageScale(.large)
        }
        .disabled(numColumns <= minZoom)
    }
    
    var zoomOutButton: some View {
        Button {
            withAnimation {
                numColumns += 1
            }
        } label: {
            Image(systemName: "minus")
                .imageScale(.large)
        }
        .disabled(numColumns >= maxZoom)
    }
    
    var body: some View {
        HStack {
            zoomInButton
            Text("/")
            zoomOutButton
        }
    }
}

struct ZoomButtons_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Hello World")
                .toolbar {
                    ZoomButtons(numColumns: .constant(3))
                }
        }
    }
}
