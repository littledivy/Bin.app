import SwiftUI

struct CardView: View {
    var notesTint: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text("Title")
                .font(.title)
                .fontWeight(.bold)
            Text("Content")
                .font(.body)
        }
        .frame(width: 180, height: 160)
        .background(notesTint)
        .cornerRadius(10)
        .padding(.vertical, 10)
    }
}

struct HomeView: View {
    @State private var search = ""

    @AppStorage("serverURL") var serverURL: String = ""
    @AppStorage("notesTint") var notesTint: Color = .gray
    
    @AppStorage("username") var username: String = ""
    @AppStorage("password") var password: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 160))],
                        spacing: 0
                    ) {
                        ForEach(0..<10) { _ in
                            NavigationLink(destination: Text("Note")) {
                                CardView(notesTint: notesTint)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink(destination: NewNoteView()) {
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

#Preview {
    HomeView()
}
