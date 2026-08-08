import SwiftUI

@main
struct WeaverApp: App {
    @State private var recordingViewModel = RecordingViewModel()

    var body: some Scene {
        WindowGroup(id: WeaverWindow.main) {
            HomeView()
                .environment(recordingViewModel)
        }

        WindowGroup(id: WeaverWindow.model3D) {
            Model3DPlaceholderWindow()
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.3, height: 0.3, depth: 0.3, in: .meters)
        .defaultWindowPlacement { _, context in
            if let mainWindow = context.windows.first(where: { $0.id == WeaverWindow.main }) {
                return WindowPlacement(.trailing(mainWindow))
            }
            return WindowPlacement()
        }

        WindowGroup(id: WeaverWindow.palette) {
            PaletteWindow()
        }
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { _, context in
            if let modelWindow = context.windows.first(where: { $0.id == WeaverWindow.model3D }) {
                return WindowPlacement(.trailing(modelWindow))
            }
            return WindowPlacement()
        }

        ImmersiveSpace(id: RecordingImmersiveSpace.id) {
            RecordingImmersiveView()
                .environment(recordingViewModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
