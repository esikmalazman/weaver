import Foundation
import RealityKit
import UIKit
import simd

@MainActor
final class HandReplayRenderer {
    let rootEntity = Entity()

    private var jointEntities: [String: ModelEntity] = [:]
    private var boneEntities: [String: ModelEntity] = [:]
    private let jointMesh = MeshResource.generateSphere(radius: 0.008)
    private let boneThickness: Float = 0.006
    private let leftMaterial = SimpleMaterial(color: .systemBlue, roughness: 0.35, isMetallic: false)
    private let rightMaterial = SimpleMaterial(color: .systemGreen, roughness: 0.35, isMetallic: false)
    private let inactiveMaterial = SimpleMaterial(color: .systemGray, roughness: 0.8, isMetallic: false)

    init() {
        rootEntity.name = "Hand Replay Root"
    }

    func apply(frame: HandRecordingFrame?) {
        guard let frame else {
            rootEntity.isEnabled = false
            return
        }

        rootEntity.isEnabled = true
        var visibleJointKeys = Set<String>()
        var visibleBoneKeys = Set<String>()

        for hand in frame.hands {
            let material = material(for: hand.chirality)
            let jointsByName = Dictionary(uniqueKeysWithValues: hand.joints.map { ($0.name, $0) })

            for joint in hand.joints {
                let key = entityKey(chirality: hand.chirality, jointName: joint.name)
                visibleJointKeys.insert(key)

                let entity = jointEntity(for: key, material: joint.isTracked ? material : inactiveMaterial)
                entity.position = joint.position.simdValue
                entity.isEnabled = true
                entity.model?.materials = [joint.isTracked ? material : inactiveMaterial]

                guard let parentName = joint.parentName,
                      let parent = jointsByName[parentName] else {
                    continue
                }

                let boneKey = "\(key)-\(parentName)"
                visibleBoneKeys.insert(boneKey)
                updateBone(
                    key: boneKey,
                    from: parent.position.simdValue,
                    to: joint.position.simdValue,
                    material: material
                )
            }
        }

        hideUnusedEntities(keepingJointKeys: visibleJointKeys, boneKeys: visibleBoneKeys)
    }

    private func jointEntity(for key: String, material: SimpleMaterial) -> ModelEntity {
        if let entity = jointEntities[key] {
            return entity
        }

        let entity = ModelEntity(mesh: jointMesh, materials: [material])
        entity.name = key
        jointEntities[key] = entity
        rootEntity.addChild(entity)
        return entity
    }

    private func updateBone(key: String, from start: SIMD3<Float>, to end: SIMD3<Float>, material: SimpleMaterial) {
        let direction = end - start
        let length = simd_length(direction)
        guard length > 0.001 else { return }

        let entity: ModelEntity
        if let existing = boneEntities[key] {
            entity = existing
        } else {
            entity = ModelEntity(
                mesh: .generateBox(size: [boneThickness, boneThickness, 1]),
                materials: [material]
            )
            entity.name = key
            boneEntities[key] = entity
            rootEntity.addChild(entity)
        }

        entity.isEnabled = true
        entity.model?.materials = [material]
        entity.scale = SIMD3<Float>(1, 1, length)
        entity.position = (start + end) / 2
        entity.orientation = simd_quatf(from: SIMD3<Float>(0, 0, 1), to: simd_normalize(direction))
    }

    private func hideUnusedEntities(keepingJointKeys jointKeys: Set<String>, boneKeys: Set<String>) {
        for (key, entity) in jointEntities where !jointKeys.contains(key) {
            entity.isEnabled = false
        }

        for (key, entity) in boneEntities where !boneKeys.contains(key) {
            entity.isEnabled = false
        }
    }

    private func material(for chirality: HandChirality) -> SimpleMaterial {
        switch chirality {
        case .left:
            leftMaterial
        case .right:
            rightMaterial
        }
    }

    private func entityKey(chirality: HandChirality, jointName: String) -> String {
        "\(chirality.rawValue)-\(jointName)"
    }
}
