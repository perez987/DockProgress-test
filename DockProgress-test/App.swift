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
            .windowResizability(.contentSize)
        }
    }
