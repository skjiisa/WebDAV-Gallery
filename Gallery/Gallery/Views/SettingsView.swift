//
//  SettingsView.swift
//  Gallery
//
//  Created by Isaac Lyons on 1/11/21.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        Form {
            Text("Hello, World!")
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
