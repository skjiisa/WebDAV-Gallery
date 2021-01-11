//
//  TextWithCaption.swift
//
//  Created by Isaac Lyons.
//

import SwiftUI

struct TextWithCaption: View {
    
    var text: String
    var caption: String?
    
    init(_ text: String, caption: String?) {
        self.text = text
        self.caption = caption
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text)
            if let caption = caption,
               !caption.isEmpty {
                Text(caption)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}

struct TextWithCaption_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                TextWithCaption("Text", caption: "Caption")
                TextWithCaption("Text with no caption", caption: nil)
            }
            .navigationTitle("TextWithCaption")
        }
    }
}
