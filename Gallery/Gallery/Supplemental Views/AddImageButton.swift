//
//  AddImageButton.swift
//  Gallery
//
//  Created by Isaac Lyons on 5/6/21.
//

import SwiftUI

struct AddImageButton: View {
    
    @Environment(\.managedObjectContext) private var moc
    
    @EnvironmentObject private var albumController: AlbumController
    
    var image: File
    var account: Account?
    var numColumns: Int
    var enabled: Bool
    
    var buttonSize: CGFloat {
        CGFloat(80 / numColumns)
    }
    
    var body: some View {
        Group {
            if enabled,
               !image.isDirectory,
               let imagePaths = albumController.imagePaths {
                Button {
                    guard let account = account else { return }
                    withAnimation {
                        albumController.toggleInSelectedAlbum(file: image, account: account, context: moc)
                    }
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
    var account: Account?
    var numColumns: Int
    var enabled: Bool
    
    func body(content: Content) -> some View {
        content.overlay(AddImageButton(image: image, account: account, numColumns: numColumns, enabled: enabled), alignment: .topTrailing)
    }
}

extension FileCell {
    func addImageButton(image: File, numColumns: Int, enabled: Bool = true) -> some View {
        self.modifier(AddImageButtonModifier(image: image, account: account, numColumns: numColumns, enabled: enabled))
    }
}

/*
struct AddImageButton_Previews: PreviewProvider {
    static var previews: some View {
        AddImageButton()
    }
}
*/
