//
//  HomeView.swift
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

struct HomeView: View {
    @StateObject var store = NotesStore()
    
    @State private var search = ""
    @State private var isLoading = false
    
    @AppStorage("serverURL") var serverURL: String = ""
    @AppStorage("notesTint") var notesTint: Color = .black
    
    @AppStorage("username") var username: String = ""
    @AppStorage("password") var password: String = ""
    
    func uploadNote(type: NoteType, title: String, noteData: Data) {
        let url = URL(string: serverURL)!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let loginString = "\(username):\(password)"
        let loginData = loginString.data(using: String.Encoding.utf8)!
        
        let base64LoginString = loginData.base64EncodedString()
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = noteData
        
        isLoading = true
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            isLoading = false
            print(response ?? "")
            if let error = error {
                print("Error: \(error)")
            } else {
                Task {
                    await store.push(note: NotesStore.Note(note: noteData, type: type, ref: String(data: data!, encoding: .utf8)!, title: title))
                    
                    do {
                        try await store.load()
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                GeometryReader { g in
                    ScrollView {
                        if isLoading {
                            ProgressView()
                        }
                        
                        let textnotes = store.notes.filter { $0.type == .text }
                        
                        List {
                            ForEach(textnotes.filter {
                                search.isEmpty ? true : $0.title.contains(search)
                            }) { note in
                                NavigationLink(destination: NoteView(note: note)) {
                                    Text(note.title)
                                        .foregroundStyle(notesTint)
                                }
                            }
                            .onDelete { index in
                                Task {
                                    let id = textnotes[index.first!].id
                                    store.notes.removeAll { $0.id == id }
                                    try? await store.save(notes: store.notes)
                                }
                            }
                        }
                        .frame(width: g.size.width - 5, height: CGFloat(textnotes.count * 45), alignment: .center)
                        .listStyle(.inset)
                        .scrollContentBackground(.hidden)
                        
                        let imagenotes = store.notes.filter { $0.type == .image }
                        
                        Section.init {
                            HStack {
                                Text("Images")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .padding()
                                
                                Spacer()
                            }
                        }
                        
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 160))],
                            spacing: 0
                        ) {
                            ForEach(imagenotes.filter {
                                search.isEmpty ? true : $0.title.contains(search)
                            }) { note in
                                NavigationLink(destination: NoteView(note: note)) {
                                    Image(uiImage: UIImage(data: note.note)!)
                                        .resizable()
                                        .cornerRadius(10)
                                        .scaledToFit()
                                }
                                .buttonStyle(.plain)
                            }
                            
                        }
                        .task {
                            do {
#if targetEnvironment(simulator)
                                try await store.save(notes: [
                                    NotesStore.Note(
                                        note: "Hello, World!".data(using: .utf8)!,
                                        type: .text,
                                        ref: "1",
                                        title: "Hello, World!"
                                    ),
                                    NotesStore.Note(
                                        note: UIImage(systemName: "star")!.pngData()!,
                                        type: .image,
                                        ref: "2",
                                        title: "Star"
                                    ),
                                    NotesStore.Note(
                                        note: "Test test test".data(using: .utf8)!,
                                        type: .text,
                                        ref: "3",
                                        title: "2nd note!"
                                    ),
                                    NotesStore.Note(
                                        note: UIImage(systemName: "plus")!.pngData()!,
                                        type: .image,
                                        ref: "4",
                                        title: "Plus"
                                    )
                                ])
#endif
                                try await store.load()
                            } catch {
                                await store.clear()
                                fatalError(error.localizedDescription)
                            }
                        }
                        .navigationTitle("Home")
                        .toolbar {
                            ToolbarItemGroup(placement: .topBarTrailing) {
                                NavigationLink(destination: NewNoteView(action: { type, title, data in
                                    uploadNote(type: type, title: title, noteData: data)
                                })) {
                                    Image(systemName: "plus")
                                }
                                
                                NavigationLink(destination: SettingsView(
                                    serverURL: $serverURL,
                                    notesTint: $notesTint,
                                    username: $username,
                                    password: $password
                                )) {
                                    Image(systemName: "gear")
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $search)
        }
    }
}

#Preview {
    HomeView()
}
