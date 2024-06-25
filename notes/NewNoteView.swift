//
//  NewNoteView.swift
//
//  Copyright (c) 2024 Divy Srivastava
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import SwiftUI
import PhotosUI

extension View {
    /// Usually you would pass  `@Environment(\.displayScale) var displayScale`
    @MainActor func render(scale displayScale: CGFloat = 1.0) -> UIImage? {
        let renderer = ImageRenderer(content: self)

        renderer.scale = displayScale
        
        return renderer.uiImage
    }
    
}

struct NewNoteView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var title = "Untitled"
    
    @State private var text = ""
    @State private var photoPickerItem: PhotosPickerItem?

    var action: (
        _: NoteType,
        _: Data
    ) -> Void = { _, _ in }

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
                            action(
                                NoteType.text,
                                Data(
                                    text.utf8
                                )
                            )
                            dismiss()
                        } label: {
                            Image(systemName: "paperplane")
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
                .onChange(of: photoPickerItem) { _, item in
                    guard let item = item else {
                        return
                    }
                    
                    Task {
                        if let image = try await item.loadTransferable(type: Image.self) {
                            if let uiimage = image.render() {
                                let data = uiimage.jpegData(compressionQuality: 1)!
                                action(NoteType.image, data)
                                
                                dismiss()
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    NewNoteView()
}
