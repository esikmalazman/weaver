import RealityKit
import SwiftUI

/// Placeholder 3D model window — a plain cube stands in until a real
/// weaving-technique model (e.g. a USDZ asset) is added.
struct Model3DPlaceholderWindow: View {
    var body: some View {
        RealityView { content in
            let entity = ModelEntity(
                mesh: .generateBox(size: 0.2),
                materials: [SimpleMaterial(color: .white, roughness: 0.4, isMetallic: false)]
            )
            content.entities.append(entity)
        }
    }
}
