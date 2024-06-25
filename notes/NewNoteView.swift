//
//  NewNoteView.swift
//  notes
//
//  Created by Divy Srivastava on 25/06/24.
//

import SwiftUI
import PhotosUI

struct NewNoteView: View {
    @State private var title = "Untitled"
    
    @State private var text = ""
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            TextEditor(text: $text)
                .padding(.horizontal)
                .frame(height: .infinity)
                .navigationTitle($title)
                .toolbarRole(.editor)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        PhotosPicker(
                            selection: $photoPickerItem,
                            matching: .images
                        ) {
                            Image(systemName: "photo")
                        }
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Spacer()
                    }
                    ToolbarItem(placement: .bottomBar) {
                        Button {
                            // send note
                        } label: {
                            Image(systemName: "paperplane")
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
        }
    }
}

#Preview {
    NewNoteView()
}
