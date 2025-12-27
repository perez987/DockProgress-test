import SwiftUI

@MainActor
@main
struct AppMain: App {
    private let appState = AppState()

    var body: some Scene {
        if #available(macOS 13.0, *) {
            WindowGroup {
                ContentView()
                    .navigationTitle("")
                    .environmentObject(appState)
            }
            .windowResizability(.contentSize)
        } else {
            WindowGroup {
                ContentView()
                    .navigationTitle("")
                    .environmentObject(appState)
            }
        }
    }
}
