import SwiftUI

#if os(iOS)
typealias PlatformColor = UIColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(uiColor: platformColor)
    }
}
#elseif os(macOS)
typealias PlatformColor = NSColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(nsColor: platformColor)
    }
}
#endif

extension Color: RawRepresentable {
    // TODO: Sort out alpha
    public init?(rawValue: Int) {
        let red =   Double((rawValue & 0xFF0000) >> 16) / 0xFF
        let green = Double((rawValue & 0x00FF00) >> 8) / 0xFF
        let blue =  Double(rawValue & 0x0000FF) / 0xFF
        self = Color(red: red, green: green, blue: blue)
    }

    public var rawValue: Int {
        guard let coreImageColor = coreImageColor else {
            return 0
        }
        let red = Int(coreImageColor.red * 255 + 0.5)
        let green = Int(coreImageColor.green * 255 + 0.5)
        let blue = Int(coreImageColor.blue * 255 + 0.5)
        return (red << 16) | (green << 8) | blue
    }

    private var coreImageColor: CIColor? {
        return CIColor(color: PlatformColor(self))
    }
}

struct SettingsView: View {
    @Binding var serverURL: String
    @Binding var notesTint: Color
    
    @Binding var username: String
    @Binding var password: String

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("General")) {
                    TextField("Server URL", text: $serverURL)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .keyboardType(.URL)

                    TextField("Username", text: $username)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                }
                
                Section(header: Text("Appearance")) {
                    ColorPicker("Note background", selection: $notesTint)
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: Text("About")) {
                        Label("About", systemImage: "info.circle")
                    }

                    Link(destination: URL(string: "https://github.com/littledivy/notes")!) {
                        Label("Report Issue", systemImage: "exclamationmark.bubble")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    SettingsView(
        serverURL: .constant("https://example.com"),
        notesTint: .constant(.white),
        username: .constant("admin"),
        password: .constant("admin")
    )
}
