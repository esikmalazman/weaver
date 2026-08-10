import ARKit
import RealityKit
import SwiftUI

/// Scans for a horizontal work surface before recording is allowed, and
/// visualizes any detected plane so the artisan can see when they're framed
/// correctly. Runs its own ARKitSession independent of hand tracking so it
/// can start as soon as the immersive space opens.
@MainActor
@Observable
final class SurfaceScanController {
    let rootEntity = Entity()

    private(set) var hasDetectedSurface = false
    private(set) var statusText = "Scanning for a surface…"

    private let session = ARKitSession()
    private let provider = PlaneDetectionProvider(alignments: [.horizontal])
    private var updatesTask: Task<Void, Never>?
    /// Wrapper entity per anchor: wrapper.transform = originFromAnchorTransform,
    /// and its "plane" child is sized/positioned by the anchor's extent transform.
    private var anchorEntities: [UUID: Entity] = [:]

    func run() async {
        guard PlaneDetectionProvider.isSupported else {
            statusText = "Surface scanning is not supported on this device."
            return
        }

        let authorization = await session.requestAuthorization(for: [.worldSensing])
        guard authorization[.worldSensing] == .allowed else {
            statusText = "World sensing access is required to find a work surface."
            return
        }

        do {
            try await session.run([provider])
        } catch {
            statusText = "Could not start surface scanning: \(error.localizedDescription)"
            return
        }

        updatesTask = Task { [weak self] in
            guard let self else { return }
            for await update in self.provider.anchorUpdates {
                if Task.isCancelled { return }
                switch update.event {
                case .added, .updated:
                    self.updatePlane(update.anchor)
                case .removed:
                    self.removePlane(update.anchor)
                }
            }
        }
    }

    func stop() {
        updatesTask?.cancel()
        updatesTask = nil
        session.stop()
        for entity in anchorEntities.values {
            entity.removeFromParent()
        }
        anchorEntities.removeAll()
        hasDetectedSurface = false
        statusText = "Scanning for a surface…"
    }

    func setVisualizationHidden(_ hidden: Bool) {
        rootEntity.isEnabled = !hidden
    }

    private func updatePlane(_ anchor: PlaneAnchor) {
        let mesh = MeshResource.generatePlane(width: anchor.geometry.extent.width, height: anchor.geometry.extent.height)

        let wrapper: Entity
        if let existing = anchorEntities[anchor.id] {
            wrapper = existing
            let planeEntity = wrapper.findEntity(named: "plane") as? ModelEntity
            planeEntity?.model?.mesh = mesh
            planeEntity?.transform = Transform(matrix: anchor.geometry.extent.anchorFromExtentTransform)
        } else {
            wrapper = Entity()
            let planeEntity = ModelEntity(
                mesh: mesh,
                materials: [UnlitMaterial(color: UIColor(AppColor.accent).withAlphaComponent(0.35))]
            )
            planeEntity.name = "plane"
            planeEntity.transform = Transform(matrix: anchor.geometry.extent.anchorFromExtentTransform)
            wrapper.addChild(planeEntity)
            anchorEntities[anchor.id] = wrapper
            rootEntity.addChild(wrapper)
        }

        wrapper.transform = Transform(matrix: anchor.originFromAnchorTransform)
        refreshDetectionState()
    }

    private func removePlane(_ anchor: PlaneAnchor) {
        if let entity = anchorEntities.removeValue(forKey: anchor.id) {
            entity.removeFromParent()
        }
        refreshDetectionState()
    }

    private func refreshDetectionState() {
        hasDetectedSurface = !anchorEntities.isEmpty
        statusText = hasDetectedSurface ? "Surface detected." : "Scanning for a surface…"
    }
}
