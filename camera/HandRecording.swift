import Foundation
import simd

struct HandRecording: Codable, Identifiable, Hashable {
    let id: UUID
    let createdAt: Date
    let duration: TimeInterval
    let audioFileName: String
    let frames: [HandRecordingFrame]

    var frameCount: Int {
        frames.count
    }
}

struct HandRecordingFrame: Codable, Identifiable, Hashable {
    let id: UUID
    let time: TimeInterval
    let hands: [RecordedHand]

    init(id: UUID = UUID(), time: TimeInterval, hands: [RecordedHand]) {
        self.id = id
        self.time = time
        self.hands = hands
    }
}

struct RecordedHand: Codable, Hashable {
    let chirality: HandChirality
    let joints: [RecordedJoint]
}

enum HandChirality: String, Codable, Hashable, CaseIterable {
    case left
    case right
}

struct RecordedJoint: Codable, Hashable {
    let name: String
    let parentName: String?
    let position: CodableVector3
    let isTracked: Bool
}

struct CodableVector3: Codable, Hashable {
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

struct StoredHandRecording: Codable, Hashable {
    let recording: HandRecording
    let motionFileName: String
}
