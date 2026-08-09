import AVKit
import SwiftUI

struct LearnerPatternLibraryScreen: View {
    let viewModel: LearnerPatternLibraryViewModel

    var body: some View {
        ScrollView {
            LearnerPatternLibraryContent(
                patterns: viewModel.patterns,
                loadState: viewModel.loadState,
                viewModel: viewModel
            )
            .padding(AppSpacing.lg)
        }
        .background(AppColor.background)
        .navigationTitle("Learner")
    }
}

private struct LearnerPatternLibraryContent: View {
    let patterns: [Pattern]
    let loadState: LearnerPatternLibraryViewModel.LoadState
    let viewModel: LearnerPatternLibraryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            PatternLibraryHeader()
            PatternLibraryStateView(
                patterns: patterns,
                loadState: loadState,
                viewModel: viewModel
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct PatternLibraryHeader: View {
    var body: some View {
        Text("Pattern Library")
            .font(AppFont.title)
            .foregroundStyle(AppColor.textPrimary)
    }
}

private struct PatternLibraryStateView: View {
    let patterns: [Pattern]
    let loadState: LearnerPatternLibraryViewModel.LoadState
    let viewModel: LearnerPatternLibraryViewModel

    var body: some View {
        switch loadState {
        case .loading:
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, AppSpacing.xl)
        case .loaded:
            PatternCardGrid(patterns: patterns, viewModel: viewModel)
        case .failed(let message):
            Text(message)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, AppSpacing.xl)
        }
    }
}

private struct PatternCardGrid: View {
    let patterns: [Pattern]
    let viewModel: LearnerPatternLibraryViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 220), spacing: AppSpacing.md)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.md) {
            ForEach(patterns) { pattern in
                NavigationLink {
                    PatternDetailView(
                        pattern: pattern,
                        videoURL: viewModel.videoURL(for: pattern),
                        relatedObjects: viewModel.objects(for: pattern)
                    )
                } label: {
                    PatternCard(
                        thumbnail: pattern.thumbnail,
                        name: pattern.name,
                        difficulty: pattern.difficulty
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct PatternCard: View {
    let thumbnail: String
    let name: String
    let difficulty: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(thumbnail)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            PatternCardText(name: name, difficulty: difficulty)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface.opacity(0.7))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
        .hoverEffect()
    }
}

private struct PatternCardText: View {
    let name: String
    let difficulty: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(name)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(2)
            Text(difficulty)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

private struct PatternDetailView: View {
    let pattern: Pattern
    let videoURL: URL?
    let relatedObjects: [RattanObject]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                PatternDetailHeader(
                    thumbnail: pattern.thumbnail,
                    name: pattern.name,
                    difficulty: pattern.difficulty
                )
                PatternDetailDescription(description: pattern.description)
                PatternDetailMetadata(
                    technique: pattern.technique,
                    structure: pattern.structure,
                    difficulty: pattern.difficulty
                )
                PatternVideoSection(videoURL: videoURL)
                RelatedObjectsSection(objects: relatedObjects)
            }
            .padding(AppSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(AppColor.background)
        .navigationTitle(pattern.name)
    }
}

private struct PatternDetailHeader: View {
    let thumbnail: String
    let name: String
    let difficulty: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Image(thumbnail)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(name)
                    .font(AppFont.largeTitle)
                    .foregroundStyle(AppColor.textPrimary)
                Text(difficulty)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
    }
}

private struct PatternDetailDescription: View {
    let description: String

    var body: some View {
        Text(description)
            .font(AppFont.body)
            .foregroundStyle(AppColor.textPrimary)
    }
}

private struct PatternDetailMetadata: View {
    let technique: String
    let structure: String
    let difficulty: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            PatternMetadataRow(label: "Technique", value: technique)
            PatternMetadataRow(label: "Structure", value: structure)
            PatternMetadataRow(label: "Difficulty", value: difficulty)
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface.opacity(0.7))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
    }
}

private struct PatternMetadataRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)
            Spacer()
            Text(value)
                .font(AppFont.body)
                .foregroundStyle(AppColor.textPrimary)
        }
    }
}

private struct PatternVideoSection: View {
    let videoURL: URL?

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("2D Video")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            if let videoURL {
                PatternVideoPlayer(url: videoURL)
            } else {
                Text("Unable to load video.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.xl)
            }
        }
    }
}

private struct PatternVideoPlayer: View {
    let url: URL

    @State private var player: AVPlayer
    @State private var currentTime = 0.0
    @State private var duration = 1.0
    @State private var isPlaying = false
    @State private var isScrubbing = false
    @State private var timeObserver: Any?

    init(url: URL) {
        self.url = url
        _player = State(initialValue: AVPlayer(url: url))
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            VideoPlayer(player: player)
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VideoScrubber(
                currentTime: $currentTime,
                duration: duration,
                isScrubbing: $isScrubbing,
                seekAction: seek(to:)
            )

            VideoTransportControls(
                isPlaying: isPlaying,
                playAction: play,
                pauseAction: pause,
                replayAction: replay
            )
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface.opacity(0.7))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
        .onAppear(perform: configurePlayer)
        .onDisappear(perform: tearDownPlayer)
    }

    private func configurePlayer() {
        duration = max(player.currentItem?.asset.duration.seconds ?? 1, 1)
        guard timeObserver == nil else { return }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { time in
            guard !isScrubbing else { return }
            currentTime = time.seconds
            duration = max(player.currentItem?.duration.seconds ?? duration, 1)
            isPlaying = player.timeControlStatus == .playing
        }
    }

    private func tearDownPlayer() {
        pause()
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
    }

    private func play() {
        player.play()
        isPlaying = true
    }

    private func pause() {
        player.pause()
        isPlaying = false
    }

    private func replay() {
        seek(to: 0)
        player.play()
        isPlaying = true
    }

    private func seek(to time: Double) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 600)
        player.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currentTime = time
    }
}

private struct VideoScrubber: View {
    @Binding var currentTime: Double
    let duration: Double
    @Binding var isScrubbing: Bool
    let seekAction: (Double) -> Void

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Slider(
                value: Binding(
                    get: { currentTime },
                    set: { value in
                        isScrubbing = true
                        currentTime = value
                    }
                ),
                in: 0...max(duration, 1),
                onEditingChanged: { editing in
                    isScrubbing = editing
                    if !editing {
                        seekAction(currentTime)
                    }
                }
            )

            HStack {
                Text(formattedTime(currentTime))
                Spacer()
                Text(formattedTime(duration))
            }
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textSecondary)
        }
    }

    private func formattedTime(_ time: Double) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct VideoTransportControls: View {
    let isPlaying: Bool
    let playAction: () -> Void
    let pauseAction: () -> Void
    let replayAction: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            VideoControlButton(systemImage: "gobackward", action: replayAction)
            VideoControlButton(systemImage: isPlaying ? "pause.fill" : "play.fill") {
                isPlaying ? pauseAction() : playAction()
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct VideoControlButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .background(AppColor.background)
        .foregroundStyle(AppColor.textPrimary)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(AppColor.border, lineWidth: 1)
        )
    }
}

private struct RelatedObjectsSection: View {
    let objects: [RattanObject]

    private let columns = [
        GridItem(.adaptive(minimum: 180), spacing: AppSpacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Related Objects")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                ForEach(objects) { object in
                    RelatedObjectCard(
                        image: object.image,
                        name: object.name,
                        type: object.type
                    )
                }
            }
        }
    }
}

private struct RelatedObjectCard: View {
    let image: String
    let name: String
    let type: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(name)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                Text(type)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface.opacity(0.7))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
    }
}

#Preview {
    NavigationStack {
        LearnerPatternLibraryScreen(viewModel: LearnerPatternLibraryViewModel())
    }
}
