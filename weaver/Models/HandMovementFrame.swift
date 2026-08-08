import ARKit
import Foundation
import simd

struct HandJointSample {
    let jointName: HandSkeleton.JointName
    let position: SIMD3<Float>
    let rotation: simd_quatf
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
}

struct HandMovementFrame: Identifiable {
    let id = UUID()
    let timestamp: TimeInterval
    let leftHandJoints: [HandJointSample]
    let rightHandJoints: [HandJointSample]
}
