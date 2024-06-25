//
//  NoteView.swift
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

struct LeftAligned: ViewModifier {
    func body(content: Content) -> some View {
        HStack {
            content
            Spacer()
        }
    }
}

extension View {
    func leftAligned() -> some View {
        return self.modifier(LeftAligned())
    }
}

struct NoteView: View {
    var note: NotesStore.Note

    var body: some View {
        NavigationStack {
            ScrollView {
                if note.type == NoteType.image {
                    GeometryReader { proxy in
                        PanZoomView(size: proxy.size, image: UIImage(data: note.note)!)
                    }
                    .cornerRadius(10)
                    .scaledToFit()
                    .padding()
                    .frame(maxHeight: .infinity)
                } else {
                    Text(String(data: note.note, encoding: .utf8)!)
                        .padding()
                        .leftAligned()
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Spacer()
                }
                ToolbarItem(placement: .bottomBar) {
                    let url = URL(string: "https://www.example.com")!
                    ShareLink(item: url) {
                        Label("Share", systemImage: "paperclip")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if note.type == NoteType.image {
                        let image = Image(uiImage: UIImage(data: note.note)!)
                        ShareLink(item: image, preview: SharePreview("Note", image: image))
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    if note.type == NoteType.image {
                        Button {
                            UIImageWriteToSavedPhotosAlbum(UIImage(data: note.note)!, nil, nil, nil)
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                        }
                        .keyboardShortcut(.defaultAction)
                    }
                }
            }
            .frame(height: .infinity)
            .navigationTitle("Note")
        }
    }
}

class PanZoomViewUIScrollView: UIScrollView, UIScrollViewDelegate {
    var imageView: UIImageView!
    var image: UIImage!
    var size :CGSize

    init(size :CGSize, image: UIImage) {
        self.image = image
        self.size = size
        super.init(frame: .zero)
        imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("unimplemented")
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

struct PanZoomView: UIViewRepresentable {
    let size: CGSize
    let image: UIImage

    func makeUIView(context: Context) -> PanZoomViewUIScrollView {
        let view = PanZoomViewUIScrollView(size: size, image: image)
        return view
    }

    func updateUIView(_ pageControl: PanZoomViewUIScrollView, context: Context) {
        let fitScale = self.size.width / self.image.size.width
        pageControl.minimumZoomScale = fitScale
        pageControl.maximumZoomScale = 2.0
        pageControl.zoomScale = fitScale
    }
}

#Preview {
    NoteView(note: NotesStore.Note(note: Data("Hello, World!".utf8), type: .text))
}
