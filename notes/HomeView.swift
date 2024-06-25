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

struct CardView: View {
    var notesTint: Color
    var note: NotesStore.Note
    
    var body: some View {
        ZStack {
            VStack {
                if note.type == NoteType.image {
                    Image(uiImage: UIImage(data: note.note)!)
                        .resizable()
                        .cornerRadius(10)
                        .scaledToFit()
                } else {
                    Text(String(data: note.note, encoding: .utf8)!)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(notesTint)
                }
            }
            .padding()
        }
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct HomeView: View {
    @StateObject var store = NotesStore()

    @State private var search = ""
    @State private var isLoading = false

    @AppStorage("serverURL") var serverURL: String = ""
    @AppStorage("notesTint") var notesTint: Color = .gray
    
    @AppStorage("username") var username: String = ""
    @AppStorage("password") var password: String = ""
    
    func uploadNote(type: NoteType, noteData: Data) {
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
                    await store.push(note: NotesStore.Note(note: noteData, type: type))

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
                ScrollView {
                    if isLoading {
                        ProgressView()
                    }
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 160))],
                        spacing: 0
                    ) {
                        ForEach(store.notes.filter {
                            search.isEmpty ? true : $0.type == NoteType.text && String(data: $0.note, encoding: .utf8)!.contains(search)
                        }) { note in
                            NavigationLink(destination: NoteView(note: note)) {
                                CardView(
                                    notesTint: notesTint, note: note)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical)
                }
                .task {
                    do {
                        // await store.clear()
                        try await store.load()
                    } catch {
                        await store.clear()
                        fatalError(error.localizedDescription)
                    }
                }
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        NavigationLink(destination: NewNoteView(action: { type, data in
                            uploadNote(type: type, noteData: data)
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
            .searchable(text: $search)
        }
    }
}

#Preview {
    HomeView()
}
