import AVKit
import SwiftUI

struct LearnerPatternLibraryScreen: View {
    let viewModel: LearnerPatternLibraryViewModel

    var body: some View {
        LearnerPatternLibraryContent(
            patterns: viewModel.patterns,
            loadState: viewModel.loadState,
            viewModel: viewModel
        )
        .padding(AppSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(AppColor.surface.opacity(0.12))
        .glassBackgroundEffect(in: .rect(cornerRadius: 24, style: .continuous))
        .navigationTitle("Learner")
    }
}

private struct LearnerPatternLibraryContent: View {
    let patterns: [Pattern]
    let loadState: LearnerPatternLibraryViewModel.LoadState
    let viewModel: LearnerPatternLibraryViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            LearnCraftHeader()

            ViewThatFits(in: .horizontal) {
                HStack(alignment: .top, spacing: AppSpacing.xl) {
                    PatternLibraryStateView(
                        patterns: patterns,
                        loadState: loadState,
                        viewModel: viewModel
                    )

                    FromOurWeaverCard()
                }

                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    PatternLibraryStateView(
                        patterns: patterns,
                        loadState: loadState,
                        viewModel: viewModel
                    )

                    FromOurWeaverCard()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct LearnCraftHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Learn Craft")
                .font(.system(.headline, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary.opacity(0.86))

            Text("Choose a weave pattern")
                .font(.system(size: 38, weight: .semibold, design: .serif))
                .foregroundStyle(AppColor.textPrimary)

            Text("Each pattern holds a story of hands, material and tradition.")
                .font(.system(.title3, weight: .regular))
                .foregroundStyle(AppColor.textPrimary.opacity(0.76))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .frame(maxWidth: .infinity, minHeight: 360, alignment: .center)
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

    var body: some View {
        HStack(spacing: AppSpacing.lg) {
            ForEach(Array(patterns.enumerated()), id: \.element.id) { index, pattern in
                NavigationLink {
                    PatternDetailView(
                        pattern: pattern,
                        videoURL: viewModel.videoURL(for: pattern),
                        patternAnimationURL: viewModel.patternAnimationURL(for: pattern),
                        relatedObjects: viewModel.objects(for: pattern),
                        viewModel: viewModel
                    )
                } label: {
                    PatternCard(
                        thumbnail: pattern.thumbnail,
                        name: pattern.name,
                        difficulty: displayDifficulty(for: pattern),
                        description: displayDescription(for: pattern),
                        accent: accent(for: index)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func accent(for index: Int) -> Color {
        switch index {
        case 0:
            .learnCraftSage
        case 1:
            .learnCraftAmber
        default:
            .learnCraftBrownAmber
        }
    }

    private func displayDifficulty(for pattern: Pattern) -> String {
        pattern.name == "Octagonal Weave" ? "Advanced" : pattern.difficulty
    }

    private func displayDescription(for pattern: Pattern) -> LocalizedStringResource {
        switch pattern.name {
        case "Plain Weave":
            "The foundation of weaving. Simple, strong and timeless."
        case "Twill Weave":
            "Diagonal lines, added strength and beautiful texture."
        case "Octagonal Weave":
            "Intricate and elegant. A traditional cane classic."
        default:
            LocalizedStringResource(stringLiteral: pattern.description)
        }
    }
}

private struct PatternCard: View {
    let thumbnail: String
    let name: String
    let difficulty: String
    let description: LocalizedStringResource
    let accent: Color

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(thumbnail)
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 360)
                .clipped()

            LinearGradient(
                colors: [
                    .black.opacity(0.06),
                    .black.opacity(0.34),
                    .black.opacity(0.68)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack {
                    PatternIcon(accent: accent, systemImage: iconName)
                    Spacer()
                    Text(difficulty)
                        .font(.system(.callout, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .padding(.horizontal, AppSpacing.md)
                        .padding(.vertical, AppSpacing.xs)
                        .background(.black.opacity(0.24))
                        .glassBackgroundEffect(in: .capsule)
                }

                Spacer()

                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(name)
                        .font(.system(size: 30, weight: .semibold, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(2)

                    Text(description)
                        .font(.system(.body, weight: .medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: AppSpacing.md) {
                    Text("Learn")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.system(.headline, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.leading, AppSpacing.lg)
                .padding(.trailing, AppSpacing.md)
                .frame(height: 52)
                .background(accent.opacity(0.72))
                .clipShape(Capsule())
            }
            .padding(AppSpacing.lg)
        }
        .frame(width: 260, height: 360)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(accent.opacity(0.72), lineWidth: 1.25)
        )
        .shadow(color: .black.opacity(0.14), radius: 18, y: 10)
        .hoverEffect()
    }

    private var iconName: String {
        switch name {
        case "Plain Weave":
            "grid"
        case "Twill Weave":
            "line.diagonal"
        default:
            "circle.hexagongrid"
        }
    }
}

private struct PatternIcon: View {
    let accent: Color
    let systemImage: String

    var body: some View {
        Image(systemName: systemImage)
            .font(.system(size: 30, weight: .light))
            .foregroundStyle(.white)
            .frame(width: 64, height: 64)
            .background(accent.opacity(0.32))
            .glassBackgroundEffect(in: .rect(cornerRadius: 32, style: .continuous))
            .overlay(
                Circle().strokeBorder(accent.opacity(0.82), lineWidth: 1.2)
            )
    }
}

private struct FromOurWeaverCard: View {
    @Environment(AppAudioManager.self) private var audioManager

    @State private var player: AVPlayer?
    @State private var didFailToLoadVideo = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("From Our Weaver")
                .font(.system(.title3, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)

            content
            .padding(AppSpacing.md)
            .background(AppColor.surface.opacity(0.22))
            .glassBackgroundEffect(in: .rect(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(AppColor.border.opacity(0.7), lineWidth: 1)
            )
        }
        .padding(AppSpacing.xl)
        .frame(width: 360, alignment: .topLeading)
        .background(AppColor.surface.opacity(0.16))
        .glassBackgroundEffect(in: .rect(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(.white.opacity(0.14), lineWidth: 1)
        )
        .onDisappear(perform: stopVideo)
        .onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)) { notification in
            guard let currentItem = player?.currentItem,
                  notification.object as? AVPlayerItem === currentItem else {
                return
            }
            finishVideo()
        }
    }

    private var content: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            thumbnail
            quote
            Spacer(minLength: AppSpacing.sm)
            playIndicator
        }
    }

    private var thumbnail: some View {
        ZStack {
            if let player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
            } else {
                Image("uncle_chen_thumbnail")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 110, height: 110)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var quote: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("\u{201c}Weaving is rhythm. Feel the over, feel the under.\u{201d}")
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)

            Text("\u{2014} Uncle Chen")
                .font(.system(.callout, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary.opacity(0.72))
        }
    }

    private var playIndicator: some View {
        Button(action: toggleWeaverStory) {
            Image(systemName: player == nil ? "play.fill" : "stop.fill")
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 48, height: 48)
        }
        .buttonStyle(.plain)
        .foregroundStyle(AppColor.textPrimary)
        .background(Color.learnCraftSage.opacity(0.22))
        .glassBackgroundEffect(in: .rect(cornerRadius: 24, style: .continuous))
        .overlay(
            Circle().strokeBorder(Color.learnCraftSage.opacity(0.66), lineWidth: 1.2)
        )
        .accessibilityLabel("Play")
    }

    private func toggleWeaverStory() {
        if player != nil {
            stopVideo()
            return
        }

        guard let url = weaverStoryVideoURL else {
            player = nil
            didFailToLoadVideo = true
            return
        }

        didFailToLoadVideo = false
        audioManager.prepareForVideoPlayback()
        let player = AVPlayer(url: url)
        player.isMuted = false
        player.volume = 1.0
        self.player = player
        audioManager.duckForVideoPlayback()
    }

    private func stopVideo() {
        player?.pause()
        player = nil
        audioManager.restoreBGMVolume()
    }

    private func finishVideo() {
        player = nil
        audioManager.restoreBGMVolume()
    }
}

private var weaverStoryVideoURL: URL? {
    let directMatches = [
        Bundle.main.url(
            forResource: "weaver_story_uncle_chen",
            withExtension: "mp4",
            subdirectory: "Videos"
        ),
        Bundle.main.url(
            forResource: "weaver_story_uncle_chen",
            withExtension: "mp4",
            subdirectory: "Resources/Videos"
        ),
        Bundle.main.url(
            forResource: "weaver_story_uncle_chen",
            withExtension: "mp4"
        )
    ]

    if let url = directMatches.compactMap({ $0 }).first {
        return url
    }

    guard let resourceURL = Bundle.main.resourceURL,
          let enumerator = FileManager.default.enumerator(
            at: resourceURL,
            includingPropertiesForKeys: nil
          ) else {
        return nil
    }

    for case let url as URL in enumerator where url.lastPathComponent == "weaver_story_uncle_chen.mp4" {
        return url
    }

    return nil
}

private extension Color {
    static let learnCraftSage = Color(red: 0.63, green: 0.72, blue: 0.52)
    static let learnCraftAmber = Color(red: 0.82, green: 0.58, blue: 0.32)
    static let learnCraftBrownAmber = Color(red: 0.64, green: 0.38, blue: 0.16)
}

private struct PatternDetailView: View {
    let pattern: Pattern
    let videoURL: URL?
    let patternAnimationURL: URL?
    let relatedObjects: [RattanObject]
    let viewModel: LearnerPatternLibraryViewModel

    @Environment(Learner3DViewModel.self) private var learner3DViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        PatternDetailMainPane(
            pattern: pattern,
            videoURL: videoURL,
            showPatternAnimationAction: showPatternAnimation
        )
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.surface.opacity(0.18))
        .glassBackgroundEffect(in: .rect(cornerRadius: 24, style: .continuous))
        .navigationTitle(pattern.name)
        .task(id: pattern.id) {
            await showPatternWorkspace()
        }
    }

    private func showPatternWorkspace() async {
        showPatternAnimation()
        showObjectLibrary()
        try? await Task.sleep(for: .milliseconds(450))
        openObjectLibraryWindowIfNeeded()
    }

    private func showPatternAnimation() {
        guard let patternAnimationURL else { return }
        learner3DViewModel.showPatternAnimation(pattern: pattern, url: patternAnimationURL)
        openModelWindowIfNeeded()
    }

    private func showObjectLibrary() {
        let items = relatedObjects.compactMap { object -> LearnerObjectLibraryItem? in
            guard let modelURL = viewModel.objectModelURL(for: object) else { return nil }
            return LearnerObjectLibraryItem(object: object, modelURL: modelURL)
        }
        learner3DViewModel.showObjectLibrary(title: pattern.name, items: items)
    }

    private func openModelWindowIfNeeded() {
        guard !learner3DViewModel.isModelWindowOpen else { return }
        learner3DViewModel.markModelWindowOpen()
        openWindow(id: WeaverWindow.model3D)
    }

    private func openObjectLibraryWindowIfNeeded() {
        guard !learner3DViewModel.isObjectLibraryWindowOpen else { return }
        learner3DViewModel.markObjectLibraryWindowOpen()
        openWindow(id: WeaverWindow.objectLibrary)
    }
}

private struct PatternDetailMainPane: View {
    let pattern: Pattern
    let videoURL: URL?
    let showPatternAnimationAction: () -> Void

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
                Pattern3DSection(showPatternAnimationAction: showPatternAnimationAction)
                if pattern.name == "Plain Weave" {
                    PlainWeavePracticeSection()
                }
                PatternVideoSection(videoURL: videoURL)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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
                .frame(maxWidth: 520)
                .frame(height: 180)
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
        .frame(maxWidth: 640, alignment: .leading)
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
        .background(AppColor.surface.opacity(0.34))
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

private struct Pattern3DSection: View {
    let showPatternAnimationAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("3D Pattern")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            Button(action: showPatternAnimationAction) {
                Label("Return to Pattern Animation", systemImage: "arrow.uturn.backward")
                    .font(AppFont.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppColor.accent)
        }
    }
}

private struct PlainWeavePracticeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Practice Mode")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            NavigationLink {
                PracticeView()
            } label: {
                Label("Practice Plain Weave", systemImage: "hand.point.up.left.fill")
                    .font(AppFont.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(AppColor.accent)
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
        .background(AppColor.surface.opacity(0.34))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
        .onAppear(perform: configurePlayer)
        .onDisappear(perform: tearDownPlayer)
    }

    private func configurePlayer() {
        duration = validDuration(from: player.currentItem?.duration.seconds)
        guard timeObserver == nil else { return }

        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.25, preferredTimescale: 600),
            queue: .main
        ) { time in
            guard !isScrubbing else { return }
            currentTime = time.seconds
            duration = validDuration(from: player.currentItem?.duration.seconds)
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

    private func validDuration(from seconds: Double?) -> Double {
        guard let seconds, seconds.isFinite, seconds > 0 else { return 1 }
        return seconds
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
    let showObjectAction: (RattanObject) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 180), spacing: AppSpacing.md)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Object Library")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            ScrollView {
                LazyVGrid(columns: columns, spacing: AppSpacing.md) {
                    ForEach(objects) { object in
                        Button {
                            showObjectAction(object)
                        } label: {
                            RelatedObjectCard(
                                image: object.image,
                                name: object.name,
                                type: object.type,
                                material: object.material,
                                location: object.location,
                                pattern: object.pattern,
                                description: object.description
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .frame(maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.surface.opacity(0.5))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1)
        )
    }
}

private struct RelatedObjectCard: View {
    let image: String
    let name: String
    let type: String
    let material: String
    let location: String
    let pattern: String
    let description: String

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
                ObjectMetadataText(label: "Pattern", value: pattern)
                ObjectMetadataText(label: "Material", value: material)
                ObjectMetadataText(label: "Location", value: location)
                Text(description)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(3)
                    .padding(.top, AppSpacing.xs)
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

private struct ObjectMetadataText: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Text(label)
                .foregroundStyle(AppColor.textSecondary)
            Text(value)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
        }
        .font(AppFont.caption)
    }
}

#Preview {
    NavigationStack {
        LearnerPatternLibraryScreen(viewModel: LearnerPatternLibraryViewModel())
            .environment(Learner3DViewModel())
    }
}
