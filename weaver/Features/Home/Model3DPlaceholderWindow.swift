import RealityKit
import SwiftUI

struct Model3DPlaceholderWindow: View {
    @Environment(Learner3DViewModel.self) private var viewModel

    var body: some View {
        Learner3DWindowContent(content: viewModel.content)
            .onAppear {
                viewModel.markModelWindowOpen()
            }
            .onDisappear {
                viewModel.markModelWindowClosed()
            }
    }
}

private struct Learner3DWindowContent: View {
    let content: Learner3DContent?

    @State private var rootEntity = Entity()
    @State private var currentEntity: Entity?
    @State private var animationResource: AnimationResource?
    @State private var animationController: AnimationPlaybackController?
    @State private var isAnimationPlaying = false
    @State private var hasAnimation = false
    @State private var yaw: Float = 0
    @State private var yawAtGestureStart: Float = 0
    @State private var modelScale: Float = 1
    @State private var scaleAtGestureStart: Float = 1

    private let defaultModelPosition = SIMD3<Float>(0, -0.16, 0)
    private let defaultModelScale = SIMD3<Float>(repeating: 0.18)
    private let minimumModelScale: Float = 0.6
    private let maximumModelScale: Float = 1.8

    var body: some View {
        RealityView { realityContent in
            realityContent.add(rootEntity)
        } update: { _ in
            rootEntity.orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
            currentEntity?.scale = defaultModelScale * modelScale
        }
        .background(.clear)
        .gesture(rotationGesture)
        .simultaneousGesture(scaleGesture)
        .task(id: content?.id) {
            await loadSelectedContent()
        }
        .ornament(attachmentAnchor: .scene(.top)) {
            Learner3DOverlay(
                content: content,
                hasAnimation: hasAnimation,
                isAnimationPlaying: isAnimationPlaying,
                scaleDownAction: scaleDown,
                scaleUpAction: scaleUp,
                rotateLeftAction: rotateLeft,
                rotateRightAction: rotateRight,
                resetViewAction: resetView,
                playAction: playAnimation,
                pauseAction: pauseAnimation,
                replayAction: replayAnimation
            )
            .padding(.bottom, AppSpacing.md)
            .offset(y: 16)
        }
        .ornament(attachmentAnchor: .scene(.trailing)) {
            if content?.kind == .patternAnimation {
                WeavingProxyLegend()
                    .padding(.leading, AppSpacing.sm)
            }
        }
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                yaw = yawAtGestureStart + Float(value.translation.width) * 0.01
            }
            .onEnded { _ in
                yawAtGestureStart = yaw
            }
    }

    private var scaleGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                modelScale = clampedScale(scaleAtGestureStart * Float(value.magnification))
            }
            .onEnded { _ in
                scaleAtGestureStart = modelScale
            }
    }

    @MainActor
    private func loadSelectedContent() async {
        guard let content else {
            clearCurrentContent()
            return
        }

        do {
            let entity = try await Entity(contentsOf: content.resourceURL)
            replaceCurrentContent(with: entity, playsAnimation: content.kind == .patternAnimation)
        } catch {
            clearCurrentContent()
        }
    }

    private func replaceCurrentContent(with entity: Entity, playsAnimation: Bool) {
        clearCurrentContent()
        resetView()
        entity.position = defaultModelPosition
        entity.scale = defaultModelScale * modelScale
        currentEntity = entity
        rootEntity.addChild(entity)

        guard playsAnimation, let animation = firstAnimation(in: entity) else {
            animationResource = nil
            hasAnimation = false
            isAnimationPlaying = false
            return
        }

        animationResource = animation.repeat()
        hasAnimation = true
        playAnimation()
    }

    private func clearCurrentContent() {
        animationController?.stop()
        animationController = nil
        animationResource = nil
        hasAnimation = false
        isAnimationPlaying = false

        for child in rootEntity.children {
            child.removeFromParent()
        }
        currentEntity = nil
    }

    private func firstAnimation(in entity: Entity) -> AnimationResource? {
        if let animation = entity.availableAnimations.first {
            return animation
        }

        for child in entity.children {
            if let animation = firstAnimation(in: child) {
                return animation
            }
        }

        return nil
    }

    private func scaleDown() {
        modelScale = clampedScale(modelScale - 0.1)
        scaleAtGestureStart = modelScale
    }

    private func scaleUp() {
        modelScale = clampedScale(modelScale + 0.1)
        scaleAtGestureStart = modelScale
    }

    private func rotateLeft() {
        yaw -= .pi / 12
        yawAtGestureStart = yaw
    }

    private func rotateRight() {
        yaw += .pi / 12
        yawAtGestureStart = yaw
    }

    private func resetView() {
        yaw = 0
        yawAtGestureStart = 0
        modelScale = 1
        scaleAtGestureStart = 1
    }

    private func clampedScale(_ scale: Float) -> Float {
        min(max(scale, minimumModelScale), maximumModelScale)
    }

    private func playAnimation() {
        if let animationController, animationController.isValid {
            animationController.resume()
            isAnimationPlaying = animationController.isPlaying
            return
        }

        guard let currentEntity, let animationResource else { return }
        animationController = currentEntity.playAnimation(animationResource)
        isAnimationPlaying = true
    }

    private func pauseAnimation() {
        animationController?.pause()
        isAnimationPlaying = false
    }

    private func replayAnimation() {
        animationController?.stop()
        animationController = nil
        playAnimation()
    }
}

private struct Learner3DOverlay: View {
    let content: Learner3DContent?
    let hasAnimation: Bool
    let isAnimationPlaying: Bool
    let scaleDownAction: () -> Void
    let scaleUpAction: () -> Void
    let rotateLeftAction: () -> Void
    let rotateRightAction: () -> Void
    let resetViewAction: () -> Void
    let playAction: () -> Void
    let pauseAction: () -> Void
    let replayAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(content?.title ?? "3D Preview")
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(1)

                    if let subtitle = content?.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(AppFont.caption)
                            .foregroundStyle(AppColor.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }

            HStack(spacing: AppSpacing.sm) {
                ModelControlButton(systemImage: "minus.magnifyingglass", action: scaleDownAction)
                ModelControlButton(systemImage: "plus.magnifyingglass", action: scaleUpAction)
                ModelControlButton(systemImage: "rotate.left", action: rotateLeftAction)
                ModelControlButton(systemImage: "rotate.right", action: rotateRightAction)
                ModelControlButton(systemImage: "arrow.counterclockwise", action: resetViewAction)

                if hasAnimation {
                    Divider()
                        .frame(height: 24)
                    ModelControlButton(systemImage: "gobackward", action: replayAction)
                    ModelControlButton(systemImage: isAnimationPlaying ? "pause.fill" : "play.fill") {
                        isAnimationPlaying ? pauseAction() : playAction()
                    }
                }
            }

            if let content {
                Learner3DMetadataRows(metadata: content.metadata)

                Text(content.description)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(AppSpacing.sm)
        .frame(maxWidth: 340, alignment: .leading)
        .background(AppColor.surface.opacity(0.28))
        .glassBackgroundEffect(in: .rect(cornerRadius: 12, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(AppColor.border.opacity(0.7), lineWidth: 1)
        )
    }
}

private struct Learner3DMetadataRows: View {
    let metadata: [Learner3DMetadata]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            ForEach(metadata) { item in
                HStack(spacing: AppSpacing.sm) {
                    Text(item.label)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textSecondary)
                    Spacer()
                    Text(item.value)
                        .font(AppFont.caption)
                        .foregroundStyle(AppColor.textPrimary)
                        .lineLimit(1)
                }
            }
        }
    }
}

private struct ModelControlButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColor.textPrimary)
    }
}

private struct WeavingProxyLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            LegendRow(symbol: .circle(.blue), text: "Blue — Left hand proxy")
            LegendRow(symbol: .circle(.green), text: "Green — Right hand proxy")
            LegendRow(symbol: .triangle(.gray), text: "Grey — Weaving tool")
        }
        .font(AppFont.caption)
        .foregroundStyle(AppColor.textPrimary.opacity(0.82))
        .padding(AppSpacing.sm)
        .background(AppColor.surface.opacity(0.22))
        .glassBackgroundEffect(in: .rect(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(AppColor.border.opacity(0.55), lineWidth: 1)
        )
    }
}

private struct LegendRow: View {
    let symbol: LegendSymbol
    let text: LocalizedStringResource

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            symbol.view
                .frame(width: 10, height: 10)
            Text(text)
                .lineLimit(1)
        }
    }
}

private enum LegendSymbol {
    case circle(Color)
    case triangle(Color)

    @ViewBuilder
    var view: some View {
        switch self {
        case .circle(let color):
            Circle()
                .fill(color)
        case .triangle(let color):
            Image(systemName: "triangle.fill")
                .resizable()
                .scaledToFit()
                .foregroundStyle(color)
        }
    }
}
