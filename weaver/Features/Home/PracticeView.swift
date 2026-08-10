import ARKit
import Observation
import RealityKit
import SwiftUI
import simd

enum PracticeImmersiveSpace {
    static let id = "PlainWeavePractice"
}

struct PracticeCheckpoint: Identifiable, Equatable {
    let id: Int
    let localPosition: SIMD3<Float>
    let guidance: String

    var worldPosition: SIMD3<Float> {
        PracticeWeaveLayout.worldPosition(for: localPosition)
    }
}

enum PracticeWeaveLayout {
    static let rootPosition = SIMD3<Float>(0, 1.18, -0.48)
    static let rootOrientation = simd_quatf(angle: .pi / 6, axis: [1, 0, 0])

    static func worldPosition(for localPosition: SIMD3<Float>) -> SIMD3<Float> {
        let rotated = rootOrientation.act(localPosition)
        return rootPosition + rotated
    }
}

@MainActor
@Observable
final class PracticeViewModel {
    enum Phase: Equatable {
        case idle
        case preparing
        case practicing
        case complete
        case failed(String)
    }

    private(set) var phase: Phase = .idle
    private(set) var currentCheckpointIndex = 0
    private(set) var latestFrame: HandMovementFrame?
    private(set) var completedPulsePosition: SIMD3<Float>?
    private(set) var statusText = "Open practice to begin."

    let checkpoints: [PracticeCheckpoint] = [
        PracticeCheckpoint(id: 0, localPosition: [-0.30, 0.035, 0.06], guidance: "Lift over"),
        PracticeCheckpoint(id: 1, localPosition: [-0.21, -0.026, -0.055], guidance: "Move under"),
        PracticeCheckpoint(id: 2, localPosition: [-0.12, 0.035, 0.06], guidance: "Lift over"),
        PracticeCheckpoint(id: 3, localPosition: [-0.03, -0.026, -0.055], guidance: "Move under"),
        PracticeCheckpoint(id: 4, localPosition: [0.06, 0.035, 0.06], guidance: "Lift over"),
        PracticeCheckpoint(id: 5, localPosition: [0.15, -0.026, -0.055], guidance: "Move under"),
        PracticeCheckpoint(id: 6, localPosition: [0.24, 0.035, 0.06], guidance: "Lift over"),
        PracticeCheckpoint(id: 7, localPosition: [0.32, -0.026, -0.055], guidance: "Move under")
    ]

    private let handTrackingSession = HandTrackingSession()
    private let checkpointThreshold: Float = 0.055
    private var clearPulseTask: Task<Void, Never>?

    var currentStepText: String {
        switch phase {
        case .complete:
            "Practice Complete"
        default:
            "Step \(min(currentCheckpointIndex + 1, checkpoints.count)) of \(checkpoints.count)"
        }
    }

    var currentGuidance: String {
        guard phase != .complete,
              let checkpoint = currentCheckpoint else {
            return "Practice Complete"
        }
        return checkpoint.guidance
    }

    var currentCheckpoint: PracticeCheckpoint? {
        guard checkpoints.indices.contains(currentCheckpointIndex) else { return nil }
        return checkpoints[currentCheckpointIndex]
    }

    func startPractice() async {
        phase = .preparing
        currentCheckpointIndex = 0
        latestFrame = nil
        completedPulsePosition = nil
        statusText = "Preparing hand tracking..."

        handTrackingSession.onFrame = { [weak self] frame in
            self?.handle(frame)
        }

        do {
            try await handTrackingSession.start()
            phase = .practicing
            statusText = "Reach the glowing checkpoint with your right index fingertip."
        } catch {
            phase = .failed("Unable to start hand tracking.")
            statusText = "Hand tracking unavailable."
        }
    }

    func stopPractice() {
        handTrackingSession.stop()
        clearPulseTask?.cancel()
        clearPulseTask = nil
        latestFrame = nil
        completedPulsePosition = nil
        if phase != .complete {
            phase = .idle
            statusText = "Practice stopped."
        }
    }

    func resetPractice() {
        currentCheckpointIndex = 0
        completedPulsePosition = nil
        phase = .practicing
        statusText = "Reach the glowing checkpoint with your right index fingertip."
    }

    private func handle(_ frame: HandMovementFrame) {
        latestFrame = frame
        guard phase == .practicing,
              let checkpoint = currentCheckpoint,
              let fingertip = rightIndexFingertipPosition(in: frame) else {
            return
        }

        if simd_distance(fingertip, checkpoint.worldPosition) <= checkpointThreshold {
            completeCurrentCheckpoint(checkpoint)
        }
    }

    private func completeCurrentCheckpoint(_ checkpoint: PracticeCheckpoint) {
        completedPulsePosition = checkpoint.localPosition
        clearPulseTask?.cancel()
        clearPulseTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))
            self?.completedPulsePosition = nil
        }

        let nextIndex = currentCheckpointIndex + 1
        if checkpoints.indices.contains(nextIndex) {
            currentCheckpointIndex = nextIndex
            statusText = "Good. Continue to the next checkpoint."
        } else {
            currentCheckpointIndex = checkpoints.count
            phase = .complete
            statusText = "Practice Complete"
        }
    }

    private func rightIndexFingertipPosition(in frame: HandMovementFrame) -> SIMD3<Float>? {
        frame.rightHandJoints.first { $0.jointName == .indexFingerTip }?.position
    }
}

struct PracticeView: View {
    @Environment(PracticeViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            PracticeHeader()
            PracticeProgressPanel(
                stepText: viewModel.currentStepText,
                guidance: viewModel.currentGuidance,
                status: viewModel.statusText,
                phase: viewModel.phase
            )
            PracticeControls(
                phase: viewModel.phase,
                resetAction: viewModel.resetPractice,
                closeAction: closePractice
            )
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.surface.opacity(0.14))
        .glassBackgroundEffect(in: .rect(cornerRadius: 24, style: .continuous))
        .navigationTitle("Plain Weave Practice")
        .task {
            await beginPractice()
        }
        .onDisappear {
            endPractice()
        }
    }

    private func beginPractice() async {
        let result = await openImmersiveSpace(id: PracticeImmersiveSpace.id)
        guard result == .opened else {
            return
        }
        await viewModel.startPractice()
    }

    private func endPractice() {
        viewModel.stopPractice()
        Task { await dismissImmersiveSpace() }
    }

    private func closePractice() {
        dismiss()
    }
}

private struct PracticeHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Plain Weave Practice")
                .font(.system(size: 34, weight: .semibold, design: .serif))
                .foregroundStyle(AppColor.textPrimary)

            Text("Follow the glowing checkpoint with your right index fingertip.")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

private struct PracticeProgressPanel: View {
    let stepText: String
    let guidance: String
    let status: String
    let phase: PracticeViewModel.Phase

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(stepText)
                .font(AppFont.largeTitle)
                .foregroundStyle(phase == .complete ? .green : AppColor.textPrimary)

            Text(guidance)
                .font(AppFont.title)
                .foregroundStyle(AppColor.accent)

            Text(status)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        }
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface.opacity(0.28))
        .glassBackgroundEffect(in: .rect(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(AppColor.border.opacity(0.7), lineWidth: 1)
        )
    }
}

private struct PracticeControls: View {
    let phase: PracticeViewModel.Phase
    let resetAction: () -> Void
    let closeAction: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button("Reset", action: resetAction)
                .buttonStyle(.bordered)
                .disabled(phase == .preparing)

            Button("Close", action: closeAction)
                .buttonStyle(.borderedProminent)
                .tint(AppColor.accent)
        }
    }
}

struct PracticeImmersiveView: View {
    @Environment(PracticeViewModel.self) private var viewModel
    @State private var sceneRoot = Entity()
    @State private var weaveRoot = Entity()
    @State private var checkpointEntity: ModelEntity?
    @State private var completedEntity: ModelEntity?
    @State private var didBuildScene = false

    var body: some View {
        RealityView { content in
            content.add(sceneRoot)
            buildSceneIfNeeded()
        } update: { _ in
            updateCheckpointEntities()
        }
    }

    private func buildSceneIfNeeded() {
        guard !didBuildScene else { return }
        didBuildScene = true
        buildPlainWeaveScene()
    }

    private func buildPlainWeaveScene() {
        let horizontalMaterial = SimpleMaterial(color: .systemBrown, roughness: 0.45, isMetallic: false)
        let verticalMaterial = SimpleMaterial(color: .systemYellow, roughness: 0.55, isMetallic: false)

        weaveRoot.position = PracticeWeaveLayout.rootPosition
        weaveRoot.orientation = PracticeWeaveLayout.rootOrientation
        sceneRoot.addChild(weaveRoot)

        for index in 0..<4 {
            let z = -0.18 + Float(index) * 0.12
            let strand = ModelEntity(
                mesh: .generateBox(size: [0.68, 0.018, 0.018]),
                materials: [horizontalMaterial]
            )
            strand.position = [0, 0, z]
            weaveRoot.addChild(strand)
        }

        for index in 0..<5 {
            let x = -0.28 + Float(index) * 0.14
            let strand = ModelEntity(
                mesh: .generateBox(size: [0.018, 0.018, 0.44]),
                materials: [verticalMaterial]
            )
            strand.position = [x, 0.018, 0]
            weaveRoot.addChild(strand)
        }
    }

    private func updateCheckpointEntities() {
        if let checkpoint = viewModel.currentCheckpoint {
            let entity = checkpointEntity ?? makeCheckpointEntity(color: .systemCyan, radius: 0.026)
            checkpointEntity = entity
            addIfNeeded(entity)
            entity.position = checkpoint.localPosition
            entity.isEnabled = true
        } else {
            checkpointEntity?.isEnabled = false
        }

        if let position = viewModel.completedPulsePosition {
            let entity = completedEntity ?? makeCheckpointEntity(color: .systemGreen, radius: 0.03)
            completedEntity = entity
            addIfNeeded(entity)
            entity.position = position
            entity.isEnabled = true
        } else {
            completedEntity?.isEnabled = false
        }
    }

    private func makeCheckpointEntity(color: UIColor, radius: Float) -> ModelEntity {
        ModelEntity(
            mesh: .generateSphere(radius: radius),
            materials: [UnlitMaterial(color: color)]
        )
    }

    private func addIfNeeded(_ entity: Entity) {
        guard entity.parent == nil else { return }
        weaveRoot.addChild(entity)
    }
}

#Preview {
    NavigationStack {
        PracticeView()
            .environment(PracticeViewModel())
    }
}
