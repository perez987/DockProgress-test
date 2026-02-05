import SwiftUI

@MainActor
@main
struct AppMain: App {
    @State private var isLanguageSelectorPresented = false
    private let appState = AppState()

    var body: some Scene {
            WindowGroup {
                ContentView()
                    .navigationTitle("")
                    .environmentObject(appState)
                    .sheet(isPresented: $isLanguageSelectorPresented) {
                        LanguageSelectorView()
                    }
            }
            .windowResizability(.contentSize)
        
        // Language menu
        .commands {
            CommandMenu(NSLocalizedString("menu_language", comment: "Language menu")) {
                Button(NSLocalizedString("menu_select_language", comment: "Select Language menu item")) {
                    isLanguageSelectorPresented = true
                }
                .keyboardShortcut("l", modifiers: .command)
            }
        }
        
    }
}
