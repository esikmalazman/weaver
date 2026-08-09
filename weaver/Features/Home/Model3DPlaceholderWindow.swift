import RealityKit
import SwiftUI

struct Model3DPlaceholderWindow: View {
    @Environment(Learner3DViewModel.self) private var viewModel

    var body: some View {
        Learner3DWindowContent(content: viewModel.content)
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

    var body: some View {
        ZStack(alignment: .bottom) {
            RealityView { realityContent in
                realityContent.add(rootEntity)
            } update: { _ in
                rootEntity.orientation = simd_quatf(angle: yaw, axis: [0, 1, 0])
            }
            .gesture(rotationGesture)
            .task(id: content?.id) {
                await loadSelectedContent()
            }

            Learner3DOverlay(
                title: content?.title ?? "3D Preview",
                hasAnimation: hasAnimation,
                isAnimationPlaying: isAnimationPlaying,
                playAction: playAnimation,
                pauseAction: pauseAnimation,
                replayAction: replayAnimation
            )
            .padding(AppSpacing.md)
        }
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 4)
            .onChanged { value in
                yaw = Float(value.translation.width) * 0.01
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
        entity.position = .zero
        entity.scale = SIMD3<Float>(repeating: 0.18)
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

        currentEntity?.removeFromParent()
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
    let title: String
    let hasAnimation: Bool
    let isAnimationPlaying: Bool
    let playAction: () -> Void
    let pauseAction: () -> Void
    let replayAction: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)

            Spacer()

            if hasAnimation {
                ModelControlButton(systemImage: "gobackward", action: replayAction)
                ModelControlButton(systemImage: isAnimationPlaying ? "pause.fill" : "play.fill") {
                    isAnimationPlaying ? pauseAction() : playAction()
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppColor.background.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
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
