import ARKit
import Foundation
import simd

struct HandJointSample: Codable {
    let jointName: HandSkeleton.JointName
    let position: SIMD3<Float>
    let rotation: simd_quatf

    init(jointName: HandSkeleton.JointName, position: SIMD3<Float>, rotation: simd_quatf) {
        self.jointName = jointName
        self.position = position
        self.rotation = rotation
    }

    private enum CodingKeys: String, CodingKey {
        case jointName
        case position
        case rotation
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let jointNameValue = try container.decode(String.self, forKey: .jointName)
        guard let decodedJointName = HandSkeleton.JointName.fromStorageName(jointNameValue) else {
            throw DecodingError.dataCorruptedError(
                forKey: .jointName,
                in: container,
                debugDescription: "Unknown hand joint name: \(jointNameValue)"
            )
        }
        jointName = decodedJointName
        position = try container.decode(StoredVector3.self, forKey: .position).simdValue
        rotation = try container.decode(StoredQuaternion.self, forKey: .rotation).simdValue
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jointName.storageName, forKey: .jointName)
        try container.encode(StoredVector3(position), forKey: .position)
        try container.encode(StoredQuaternion(rotation), forKey: .rotation)
    }
}

extension HandSkeleton.JointName {
    /// A reduced 10-joint outline (wrist, 5 fingertips, 4 finger knuckles) —
    /// enough to read the hand's shape without tracking/storing/rendering
    /// all 27 joints ARKit provides per hand.
    static let trackedJoints: [HandSkeleton.JointName] = [
        .wrist,
        .thumbTip,
        .indexFingerTip,
        .middleFingerTip,
        .ringFingerTip,
        .littleFingerTip,
        .indexFingerKnuckle,
        .middleFingerKnuckle,
        .ringFingerKnuckle,
        .littleFingerKnuckle,
    ]

    private static let storableJoints: [HandSkeleton.JointName] = trackedJoints + [
        .forearmWrist,
        .forearmArm,
    ]

    var storageName: String {
        String(describing: self)
    }

    static func fromStorageName(_ value: String) -> HandSkeleton.JointName? {
        storableJoints.first { $0.storageName == value }
    }
}

struct HandMovementFrame: Identifiable, Codable {
    let id: UUID
    let timestamp: TimeInterval
    let leftHandJoints: [HandJointSample]
    let rightHandJoints: [HandJointSample]

    init(
        id: UUID = UUID(),
        timestamp: TimeInterval,
        leftHandJoints: [HandJointSample],
        rightHandJoints: [HandJointSample]
    ) {
        self.id = id
        self.timestamp = timestamp
        self.leftHandJoints = leftHandJoints
        self.rightHandJoints = rightHandJoints
    }
}

private struct StoredVector3: Codable {
    let x: Float
    let y: Float
    let z: Float

    init(_ vector: SIMD3<Float>) {
        x = vector.x
        y = vector.y
        z = vector.z
    }

    var simdValue: SIMD3<Float> {
        SIMD3<Float>(x, y, z)
    }
}

private struct StoredQuaternion: Codable {
    let vector: StoredVector4

    init(_ quaternion: simd_quatf) {
        vector = StoredVector4(quaternion.vector)
    }

    var simdValue: simd_quatf {
        simd_quatf(vector: vector.simdValue)
    }
}

private struct StoredVector4: Codable {
    let x: Float
    let y: Float
    let z: Float
    let w: Float

    init(_ vector: SIMD4<Float>) {
        x = vector.x
        y = vector.y
        z = vector.z
        w = vector.w
    }

    var simdValue: SIMD4<Float> {
        SIMD4<Float>(x, y, z, w)
    }
}
