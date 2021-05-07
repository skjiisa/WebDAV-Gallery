//
//  AddImageButton.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import SwiftUI

struct AddImageButton: View {
    @EnvironmentObject private var albumController: AlbumController
    
    var image: File
    var numColumns: Int
    
    var buttonSize: CGFloat {
        CGFloat(80 / numColumns)
    }
    
    var body: some View {
        Group {
            if let imagePaths = albumController.imagePaths {
                Button {
                    // Add or remove image
                } label: {
                    if imagePaths.contains(image.path) {
                        Image(systemName: "minus.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.green)
                    }
                }
                .background(Color.white)
                .cornerRadius(buttonSize / 2)
                .clipped()
                .frame(width: buttonSize, height: buttonSize)
            }
        }
    }
}

fileprivate struct AddImageButtonModifier: ViewModifier {
    var image: File
    var numColumns: Int
    
    func body(content: Content) -> some View {
        content.overlay(AddImageButton(image: image, numColumns: numColumns), alignment: .topTrailing)
    }
}

extension FileCell {
    func addImageButton(image: File, numColumns: Int) -> some View {
        self.modifier(AddImageButtonModifier(image: image, numColumns: numColumns))
    }
}

/*
struct AddImageButton_Previews: PreviewProvider {
    static var previews: some View {
        AddImageButton()
    }
}
*/
