import ARKit
import RealityKit

enum HandTrackingSessionError: Error {
    case unsupported
    case authorizationDenied
}

/// Owns the ARKitSession + HandTrackingProvider lifecycle. Must be started
/// while an ImmersiveSpace is open — ARKit hand tracking is not available
/// from a windowed scene.
@MainActor
final class HandTrackingSession {
    var onFrame: ((HandMovementFrame) -> Void)?

    private let arkitSession = ARKitSession()
    private let handTrackingProvider = HandTrackingProvider()
    private var updatesTask: Task<Void, Never>?

    func start() async throws {
        guard HandTrackingProvider.isSupported else {
            throw HandTrackingSessionError.unsupported
        }

        let authorization = await arkitSession.requestAuthorization(for: [.handTracking])
        guard authorization[.handTracking] == .allowed else {
            throw HandTrackingSessionError.authorizationDenied
        }

        try await arkitSession.run([handTrackingProvider])
        observeUpdates()
    }

    func stop() {
        updatesTask?.cancel()
        updatesTask = nil
        arkitSession.stop()
    }

    private func observeUpdates() {
        updatesTask?.cancel()
        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await update in self.handTrackingProvider.anchorUpdates {
                if Task.isCancelled { return }
                self.handle(update)
            }
        }
    }

    private func handle(_ update: AnchorUpdate<HandAnchor>) {
        guard update.event != .removed else { return }

        let anchors = handTrackingProvider.latestAnchors
        let frame = HandMovementFrame(
            timestamp: update.timestamp,
            leftHandJoints: joints(from: anchors.leftHand),
            rightHandJoints: joints(from: anchors.rightHand)
        )
        onFrame?(frame)
    }

    private func joints(from anchor: HandAnchor?) -> [HandJointSample] {
        guard let anchor, anchor.isTracked, let skeleton = anchor.handSkeleton else { return [] }

        return HandSkeleton.JointName.trackedJoints.map { name in
            let joint = skeleton.joint(name)
            let transform = Transform(matrix: anchor.originFromAnchorTransform * joint.anchorFromJointTransform)
            return HandJointSample(jointName: joint.name, position: transform.translation, rotation: transform.rotation)
        }
    }
}
