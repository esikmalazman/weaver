import ARKit
import RealityKit
import SwiftUI

/// Renders a live sphere per tracked hand joint. Reused by the immersive
/// space (world-space, overlaid on the artisan's real hands) and the
/// windowed preview (recentered on the wrist so it stays framed).
struct HandJointsRealityView: View {
    let frame: HandMovementFrame?
    let recenterOnWrist: Bool

    @State private var jointEntities: [String: ModelEntity] = [:]

    var body: some View {
        RealityView { _ in
        } update: { content in
            updateJoints(in: content)
        }
    }

    private func updateJoints(in content: RealityViewContent) {
        guard let frame else {
            removeAllEntities(from: content)
            return
        }

        let offset = recenterOnWrist ? wristOffset(in: frame) : .zero
        var currentKeys: Set<String> = []

        for joint in frame.leftHandJoints where joint.jointName != .forearmArm {
            let key = "left_\(joint.jointName)"
            currentKeys.insert(key)
            place(joint, key: key, offset: offset, in: content)
        }
        for joint in frame.rightHandJoints where joint.jointName != .forearmArm {
            let key = "right_\(joint.jointName)"
            currentKeys.insert(key)
            place(joint, key: key, offset: offset, in: content)
        }

        removeStaleEntities(keeping: currentKeys, from: content)
    }

    private func removeStaleEntities(keeping currentKeys: Set<String>, from content: RealityViewContent) {
        let staleKeys = Set(jointEntities.keys).subtracting(currentKeys)
        for key in staleKeys {
            if let entity = jointEntities.removeValue(forKey: key) {
                content.entities.remove(entity)
            }
        }
    }

    private func removeAllEntities(from content: RealityViewContent) {
        for entity in jointEntities.values {
            content.entities.remove(entity)
        }
        jointEntities.removeAll()
    }

    private func wristOffset(in frame: HandMovementFrame) -> SIMD3<Float> {
        let wrist = frame.leftHandJoints.first(where: { $0.jointName == .wrist })
            ?? frame.rightHandJoints.first(where: { $0.jointName == .wrist })
        return wrist?.position ?? .zero
    }

    private func place(_ joint: HandJointSample, key: String, offset: SIMD3<Float>, in content: RealityViewContent) {
        let entity: ModelEntity
        if let existing = jointEntities[key] {
            entity = existing
        } else {
            entity = ModelEntity(
                mesh: .generateSphere(radius: 0.006),
                materials: [SimpleMaterial(color: .white, roughness: 0.4, isMetallic: false)]
            )
            jointEntities[key] = entity
            content.entities.append(entity)
        }
        entity.transform = Transform(scale: .one, rotation: joint.rotation, translation: joint.position - offset)
    }
}
