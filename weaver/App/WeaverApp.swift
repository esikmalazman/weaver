import SwiftUI

@main
struct WeaverApp: App {
    @State private var recordingViewModel = RecordingViewModel()
    @State private var appModel = AppModel()
    @State private var learner3DViewModel = Learner3DViewModel()
    
    var body: some Scene {
        WindowGroup(id: WeaverWindow.main) {
            HomeView()
                .environment(recordingViewModel)
                .environment(appModel)
                .environment(learner3DViewModel)
        }

        WindowGroup(id: WeaverWindow.model3D) {
            Model3DPlaceholderWindow()
                .environment(learner3DViewModel)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 0.34, height: 0.42, depth: 0.34, in: .meters)
        .defaultLaunchBehavior(.suppressed)
        .defaultWindowPlacement { _, context in
            if let mainWindow = context.windows.first(where: { $0.id == WeaverWindow.main }) {
                return WindowPlacement(.trailing(mainWindow))
            }
            return WindowPlacement()
        }

        WindowGroup(id: WeaverWindow.objectLibrary) {
            LearnerObjectLibraryWindow()
                .environment(learner3DViewModel)
        }
        .defaultSize(width: 360, height: 620)
        .defaultLaunchBehavior(.suppressed)
        .restorationBehavior(.disabled)
        .defaultWindowPlacement { _, context in
            if let modelWindow = context.windows.first(where: { $0.id == WeaverWindow.model3D }) {
                return WindowPlacement(.trailing(modelWindow))
            }
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
            if let objectLibraryWindow = context.windows.first(where: { $0.id == WeaverWindow.objectLibrary }) {
                return WindowPlacement(.trailing(objectLibraryWindow))
            }
            if let modelWindow = context.windows.first(where: { $0.id == WeaverWindow.model3D }) {
                return WindowPlacement(.trailing(modelWindow))
            }
            return WindowPlacement()
        }

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
        .upperLimbVisibility(.visible)
        
        ImmersiveSpace(id: RecordingImmersiveSpace.id) {
            RecordingImmersiveView()
                .environment(recordingViewModel)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
