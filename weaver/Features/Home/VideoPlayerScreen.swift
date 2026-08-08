import AVKit
import SwiftUI

struct VideoPlayerScreen: View {
    let video: LearnerVideo

    @State private var player: AVPlayer?
    @State private var didFailToLoad = false
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        content
            .padding(AppSpacing.lg)
            .background(AppColor.background)
            .navigationTitle(video.title)
            .task {
                if let url = Bundle.main.url(forResource: video.resourceName, withExtension: video.resourceExtension) {
                    player = AVPlayer(url: url)
                    openWindow(id: WeaverWindow.model3D)
                } else {
                    didFailToLoad = true
                }
            }
            .ornament(attachmentAnchor: .scene(.bottom)) {
                PracticeButton {
                    openWindow(id: WeaverWindow.palette)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let player {
            VideoPlayer(player: player)
                .onAppear { player.play() }
        } else if didFailToLoad {
            Text("Unable to load video.")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
        } else {
            ProgressView()
        }
    }
}

private struct PracticeButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("Practice")
                .font(AppFont.headline)
                .padding(.horizontal, AppSpacing.xl)
                .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.plain)
        .background(AppColor.accent)
        .foregroundStyle(AppColor.background)
        .clipShape(Capsule())
    }
}
