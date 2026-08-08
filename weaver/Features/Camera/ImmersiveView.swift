import RealityKit
import SwiftUI

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel
    @State private var replayRenderer = HandReplayRenderer()

    var body: some View {
        RealityView { content in
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: .main) {
                content.add(immersiveContentEntity)
            }

            content.add(replayRenderer.rootEntity)
        } update: { _ in
            replayRenderer.apply(frame: appModel.handSessionController.currentReplayFrame)
        }
    }
}

#Preview(immersionStyle: .mixed) {
    ImmersiveView()
        .environment(AppModel())
}
