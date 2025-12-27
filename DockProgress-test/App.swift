import SwiftUI

@MainActor
@main
struct AppMain: App {
    private let appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .navigationTitle("")
                .environmentObject(appState)
        }
        // macOS 13.0 or newer
//        .windowResizability(.contentSize)
    }
}
