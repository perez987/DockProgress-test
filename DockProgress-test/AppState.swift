import DockProgress
import SwiftUI
internal import Combine

// MARK: - Constants

private enum Constants {
    static let windowWidth: CGFloat = 450
    static let windowHeight: CGFloat = 470
}

@MainActor
final class AppState: ObservableObject {
    @Published var isAnimating = false
    private nonisolated(unsafe) var timer: Timer?
    private var stylesIterator: Array<DockProgress.Style>.Iterator?

    let styles: [DockProgress.Style] = [
        .bar,
        .squircle(color: .blue),
        .circle(radius: 30, color: .purple),
        .badge(color: .blue) { Int(DockProgress.displayedProgress * 12) },
        .pie(color: .blue),
        .customView { progress in
            CustomView(progress: progress)
        },
    ]

    let styleNames = [
        "Bar Style",
        "Squircle Style",
        "Circle Style",
        "Badge Style",
        "Pie Style",
        "Custom View Style",
    ]

    func startStyle(at index: Int) {
        guard index < styles.count else { return }
        startStyle(styles[index])
        isAnimating = true
    }

    private func startStyle(_ style: DockProgress.Style) {
        stopTimer()
        DockProgress.resetProgress()
        DockProgress.style = style

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if DockProgress.displayedProgress >= 1 {
                    DockProgress.resetProgress()
                }

                DockProgress.progress = min(DockProgress.progress + 0.2, 1)
            }
        }
    }

    func startAutoCycle() {
        stopTimer()
        stylesIterator = styles.makeIterator()
        advanceToNextStyle()
        isAnimating = true

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                if DockProgress.displayedProgress >= 1 {
                    self.advanceToNextStyle()
                }

                DockProgress.progress = min(DockProgress.progress + 0.2, 1)
            }
        }
    }

    private func advanceToNextStyle() {
        if let style = stylesIterator?.next() {
            DockProgress.resetProgress()
            DockProgress.style = style
            return
        }

        stylesIterator = styles.makeIterator()

        if let style = stylesIterator?.next() {
            DockProgress.resetProgress()
            DockProgress.style = style
        }
    }

    private nonisolated func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func stop() {
        stopTimer()
        DockProgress.resetProgress()
        isAnimating = false
    }

    deinit {
        stopTimer()
    }
}

private func borrowIconFromApp(_ app: String) {
    guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app) else {
        return
    }

    let icon = NSWorkspace.shared.icon(forFile: appURL.path)
    icon.size = CGSize(width: 128, height: 128)

    // Reduce flicker by checking if icon actually changed
    if NSApp.applicationIconImage != icon {
        NSApp.applicationIconImage = icon
    }
}

struct ContentView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text("DockProgress Styles")
                .font(.title)
                .padding(.top, 20)

            Divider()

            Text("Click a button to start the animation:")
                .font(.headline)

            VStack(spacing: 15) {
                ForEach(0 ..< appState.styles.count, id: \.self) { index in
                    Button(appState.styleNames[index]) {
                        borrowIconFromApp("com.apple.Photos")
                        appState.startStyle(at: index)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            Divider()

            Button("Auto-Cycle All Styles") {
                borrowIconFromApp("com.apple.Photos")
                appState.startAutoCycle()
            }
            .buttonStyle(.bordered)
            .controlSize(.large)

            Button("Stop") {
                appState.stop()
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
            .controlSize(.large)
            .disabled(!appState.isAnimating)

            Spacer()
        }
        .padding()
        .frame(width: Constants.windowWidth, height: Constants.windowHeight)
    }
}

private struct CustomView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 8
                )
                .opacity(0.3)
                .frame(width: 80, height: 80)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 80, height: 80)
            Text("\(Int(progress * 100))%")
                .font(.system(size: 20, weight: .bold).monospacedDigit())
                .foregroundColor(.white)
        }
    }
}
