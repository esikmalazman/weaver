import SwiftUI

enum HomeMode: CaseIterable, Identifiable {
    case artisan
    case learner

    var id: Self { self }

    var title: LocalizedStringResource {
        switch self {
        case .artisan: "Artisan"
        case .learner: "Learner"
        }
    }

    var icon: String {
        switch self {
        case .artisan: "hand.raised"
        case .learner: "square.grid.3x3"
        }
    }
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            CraftWeaveLandingPanel()
                .padding(AppSpacing.xxl)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

private struct CraftWeaveLandingPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            LandingHeader()
            LandingIntro()
            PrimaryModeCards()
            HeritageNavigationSection()
        }
        .padding(.horizontal, 48)
        .padding(.vertical, 44)
        .frame(maxWidth: 1040)
    }
}

private struct LandingHeader: View {
    var body: some View {
        HStack(alignment: .top) {
            HStack(spacing: AppSpacing.md) {
                WeaveMark(size: 52, color: .rattanAmber)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("CraftWeave")
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .foregroundStyle(AppColor.textPrimary)

                    Text("Preserve craft through movement.")
                        .font(.system(.body, weight: .medium))
                        .foregroundStyle(Color.rattanAmber.opacity(0.9))
                }
            }

            Spacer()

            Button {
            } label: {
                Label("About", systemImage: "info.circle")
                    .font(.system(.body, weight: .medium))
                    .padding(.horizontal, AppSpacing.xl)
                    .padding(.vertical, AppSpacing.sm)
            }
            .buttonStyle(.plain)
            .background(.white.opacity(0.1))
            .clipShape(Capsule())
            .foregroundStyle(AppColor.textPrimary)
            .hoverEffect()
        }
        .padding(.top, AppSpacing.sm)
    }
}

private struct LandingIntro: View {
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Record. Preserve. Learn.")
                .font(.system(size: 42, weight: .semibold, design: .serif))
                .foregroundStyle(AppColor.textPrimary)

            Text("A digital space for rattan weaving knowledge,\nconnecting hands to heritage.")
                .font(.system(.title3, weight: .regular))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.textPrimary.opacity(0.78))
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PrimaryModeCards: View {
    var body: some View {
        ZStack {
            DecorativeWeaveStrands()

            HStack(spacing: 96) {
                ModeCard(
                    title: "Capture Craft",
                    icon: "hand.raised",
                    description: "Record weaving demonstrations\nand preserve craft in motion.",
                    buttonTitle: "Start Capture",
                    accent: .mutedSage
                ) {
                    ArtisanHomeView()
                }

                ModeCard(
                    title: "Learn Craft",
                    icon: "square.grid.3x3",
                    description: "Explore weaving patterns,\nobjects and gestures.",
                    buttonTitle: "Explore",
                    accent: .rattanAmber
                ) {
                    LearnerHomeView()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
    }
}

private struct ModeCard<Destination: View>: View {
    let title: LocalizedStringResource
    let icon: String
    let description: LocalizedStringResource
    let buttonTitle: LocalizedStringResource
    let accent: Color
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(accent.opacity(0.12))
                    .frame(width: 104, height: 104)
                    .overlay(
                        Circle()
                            .strokeBorder(accent.opacity(0.34), lineWidth: 1.5)
                    )

                Image(systemName: icon)
                    .font(.system(size: 44, weight: .light))
                    .foregroundStyle(accent.opacity(0.95))
                    .frame(width: 104, height: 104)

                if icon == "hand.raised" {
                    Image(systemName: "record.circle")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(accent)
                        .offset(x: -14, y: -14)
                }
            }

            VStack(spacing: AppSpacing.md) {
                Text(title)
                    .font(.system(size: 31, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)

                Text(description)
                    .font(.system(.body, weight: .regular))
                    .foregroundStyle(AppColor.textPrimary.opacity(0.78))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            NavigationLink {
                destination()
            } label: {
                HStack(spacing: AppSpacing.md) {
                    Text(buttonTitle)
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.system(.headline, weight: .medium))
                .padding(.leading, AppSpacing.xl)
                .padding(.trailing, AppSpacing.md)
                .frame(height: 52)
                .frame(maxWidth: .infinity)
                .background(accent.opacity(0.28))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColor.textPrimary)
        }
        .padding(.horizontal, 34)
        .padding(.vertical, 28)
        .frame(width: 320, height: 320)
        .background(accent.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(accent.opacity(0.34), lineWidth: 1.25)
        )
        .hoverEffect()
    }
}

private struct DecorativeWeaveStrands: View {
    var body: some View {
        ZStack {
            RattanStrand(inverted: false)
                .offset(y: 8)
            RattanStrand(inverted: true)
                .offset(y: -8)
        }
        .frame(height: 96)
        .allowsHitTesting(false)
        .opacity(0.42)
    }
}

private struct RattanStrand: View {
    let inverted: Bool

    var body: some View {
        CurvedRattanStrand(inverted: inverted)
            .stroke(
                LinearGradient(
                    colors: [
                        .rattanLight.opacity(0.46),
                        .rattanAmber.opacity(0.42),
                        .rattanLight.opacity(0.4)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 7, lineCap: .round)
            )
            .overlay(
                CurvedRattanStrand(inverted: inverted)
                    .stroke(
                        .white.opacity(0.14),
                        style: StrokeStyle(lineWidth: 1, lineCap: .round)
                    )
            )
            .shadow(color: .black.opacity(0.08), radius: 3, y: 1)
    }
}

private struct CurvedRattanStrand: Shape {
    let inverted: Bool

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let startY = inverted ? rect.maxY * 0.68 : rect.minY + rect.height * 0.32
        let endY = inverted ? rect.minY + rect.height * 0.32 : rect.maxY * 0.68

        path.move(to: CGPoint(x: rect.minX - 40, y: startY))
        path.addCurve(
            to: CGPoint(x: rect.maxX + 40, y: endY),
            control1: CGPoint(x: rect.width * 0.32, y: inverted ? rect.minY + 8 : rect.maxY - 8),
            control2: CGPoint(x: rect.width * 0.68, y: inverted ? rect.maxY - 8 : rect.minY + 8)
        )
        return path
    }
}

private struct HeritageNavigationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack(spacing: AppSpacing.md) {
                Text("Explore Our Craft Heritage")
                    .font(.system(.caption, weight: .medium))
                    .foregroundStyle(AppColor.textPrimary.opacity(0.62))
                Rectangle()
                    .fill(.white.opacity(0.14))
                    .frame(height: 1)
            }

            HStack(spacing: AppSpacing.lg) {
                HeritageNavigationLink(title: "Weaving\nPatterns", icon: "square.grid.3x3") {
                    LearnerHomeView()
                }
                HeritageNavigationLink(title: "Craft\nObjects", icon: "basket") {
                    LearnerHomeView()
                }
                HeritageNavigationItem(title: "Weaving\nGestures", icon: "hand.raised")
                HeritageNavigationItem(title: "Craft\nArchive", icon: "archivebox")
            }
        }
    }
}

private struct HeritageNavigationLink<Destination: View>: View {
    let title: LocalizedStringResource
    let icon: String
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink {
            destination()
        } label: {
            HeritageNavigationContent(title: title, icon: icon)
        }
        .buttonStyle(.plain)
    }
}

private struct HeritageNavigationItem: View {
    let title: LocalizedStringResource
    let icon: String

    var body: some View {
        HeritageNavigationContent(title: title, icon: icon)
            .opacity(0.82)
    }
}

private struct HeritageNavigationContent: View {
    let title: LocalizedStringResource
    let icon: String

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 32, weight: .light))
                .frame(height: 36)
                .foregroundStyle(AppColor.textPrimary.opacity(0.76))

            Text(title)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AppColor.textPrimary.opacity(0.86))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 76)
        .padding(.vertical, AppSpacing.xs)
        .hoverEffect()
    }
}

private struct WeaveMark: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Capsule()
                    .fill(color.opacity(0.72))
                    .frame(width: size * 0.18, height: size * 0.92)
                    .offset(x: CGFloat(index - 1) * size * 0.22)
                    .rotationEffect(.degrees(45))

                Capsule()
                    .fill(color.opacity(0.72))
                    .frame(width: size * 0.18, height: size * 0.92)
                    .offset(x: CGFloat(index - 1) * size * 0.22)
                    .rotationEffect(.degrees(-45))
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

private extension Color {
    static let mutedSage = Color(red: 0.63, green: 0.72, blue: 0.52)
    static let rattanAmber = Color(red: 0.82, green: 0.58, blue: 0.32)
    static let rattanLight = Color(red: 0.92, green: 0.77, blue: 0.55)
}

private struct ArtisanHomeView: View {
    @Environment(RecordingViewModel.self) private var recordingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                CaptureCraftHeader(backAction: { dismiss() })
                CaptureCraftMainSection()
                CapturedTechniqueLibrarySection(techniques: recordingViewModel.savedTechniques)
            }
            .padding(.horizontal, 44)
            .padding(.vertical, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassBackgroundEffect(in: .rect(cornerRadius: 32, style: .continuous))
        .navigationTitle("Capture Craft")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct LearnerHomeView: View {
    @State private var viewModel = LearnerPatternLibraryViewModel()

    var body: some View {
        LearnerPatternLibraryScreen(viewModel: viewModel)
    }
}

private struct NewRecordingButton: View {
    var body: some View {
        NavigationLink {
            CameraView()
        } label: {
            HStack(spacing: AppSpacing.md) {
                Text("Start Capture")
                Image(systemName: "arrow.right")
            }
            .font(.system(.headline, weight: .semibold))
            .frame(maxWidth: .infinity)
            .frame(height: 54)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .tint(.mutedSage)
    }
}

private struct LearnerVideosSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Learner Videos")
            LearnerVideoRow(video: .weaving)
        }
    }
}

private struct TechniqueLibrarySection: View {
    let techniques: [Technique]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            SectionHeader(title: "Technique Library")
            TechniqueLibraryContent(techniques: techniques)
        }
    }
}

private struct CaptureCraftHeader: View {
    let backAction: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.lg) {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .background(.white.opacity(0.1))
            .clipShape(Circle())
            .foregroundStyle(AppColor.textPrimary)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Capture Craft")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(AppColor.textPrimary)

                Text("Record weaving demonstrations and preserve craft knowledge.")
                    .font(.system(.body, weight: .regular))
                    .foregroundStyle(AppColor.textPrimary.opacity(0.74))
            }

            Spacer()

            Button {
            } label: {
                Label("Help", systemImage: "questionmark.circle")
                    .font(.system(.body, weight: .medium))
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
            }
            .buttonStyle(.plain)
            .background(.white.opacity(0.08))
            .clipShape(Capsule())
            .foregroundStyle(AppColor.textPrimary)
        }
    }
}

private struct CaptureCraftMainSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Record a weaving demonstration")
                    .font(.system(.title2, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

                Text("Capture hand movement and craft knowledge as it happens.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.72))
            }

            ViewThatFits {
                HStack(alignment: .top, spacing: AppSpacing.lg) {
                    CaptureReadyPanel()
                    CaptureTipsPanel()
                }

                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    CaptureReadyPanel()
                    CaptureTipsPanel()
                }
            }
        }
    }
}

private struct CaptureReadyPanel: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xl) {
            HStack(alignment: .top, spacing: AppSpacing.lg) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text("READY TO CAPTURE")
                        .font(.system(.caption, weight: .bold))
                        .foregroundStyle(Color.mutedSage)

                    Text("Hands will be tracked in 3D")
                        .font(.system(.title3, weight: .semibold))
                        .foregroundStyle(AppColor.textPrimary)
                }

                Spacer()

                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color.mutedSage.opacity(0.14))
                        .frame(width: 92, height: 92)
                    Image(systemName: "hand.raised")
                        .font(.system(size: 42, weight: .light))
                        .foregroundStyle(Color.mutedSage)
                    Image(systemName: "record.circle")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(Color.rattanAmber.opacity(0.86))
                        .offset(x: -8, y: -8)
                }
            }

            HStack(spacing: AppSpacing.md) {
                CaptureStatusIndicator(title: "Hands Ready", systemImage: "hand.raised.fill")
                CaptureStatusIndicator(title: "Workspace Ready", systemImage: "rectangle.dashed")
            }

            NewRecordingButton()
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity, minHeight: 260, alignment: .leading)
        .background(Color.mutedSage.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.mutedSage.opacity(0.28), lineWidth: 1.25)
        )
    }
}

private struct CaptureStatusIndicator: View {
    let title: LocalizedStringResource
    let systemImage: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(.callout, weight: .medium))
            .foregroundStyle(AppColor.textPrimary.opacity(0.84))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(.white.opacity(0.08))
            .clipShape(Capsule())
    }
}

private struct CaptureTipsPanel: View {
    private let tips = [
        CaptureTip(text: "Keep your hands in view", systemImage: "hand.raised"),
        CaptureTip(text: "Work within your workspace", systemImage: "rectangle.dashed"),
        CaptureTip(text: "Good lighting helps capture details", systemImage: "lightbulb")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Capture Tips")
                .font(.system(.headline, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)

            ForEach(tips) { tip in
                Label(tip.text, systemImage: tip.systemImage)
                    .font(.system(.callout, weight: .regular))
                    .foregroundStyle(AppColor.textPrimary.opacity(0.76))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(AppSpacing.lg)
        .frame(width: 260, alignment: .topLeading)
        .background(Color.rattanLight.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        )
    }
}

private struct CaptureTip: Identifiable {
    let text: LocalizedStringResource
    let systemImage: String

    var id: String { systemImage }
}

private struct CapturedTechniqueLibrarySection: View {
    let techniques: [Technique]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Captured Technique Library")
                .font(.system(.title2, weight: .semibold))
                .foregroundStyle(AppColor.textPrimary)

            if techniques.isEmpty {
                CaptureEmptyState()
            } else {
                TechniqueCardRow(techniques: techniques)
            }
        }
    }
}

private struct TechniqueCardRow: View {
    let techniques: [Technique]

    var body: some View {
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: AppSpacing.lg) {
                ForEach(Array(techniques.prefix(6).enumerated()), id: \.element.id) { index, technique in
                    CapturedTechniqueCard(
                        technique: technique,
                        accent: index.isMultiple(of: 2) ? .mutedSage : .rattanAmber
                    )
                }

                NewCaptureCard()
            }
            .padding(.vertical, AppSpacing.xs)
        }
    }
}

private struct CapturedTechniqueCard: View {
    let technique: Technique
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            WeaveThumbnail(accent: accent)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(technique.name)
                    .font(.system(.headline, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                Text("Hand sequence · \(formattedDuration)")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.72))

                Text(technique.date, style: .relative)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.66))
            }

            Spacer(minLength: AppSpacing.sm)

            NavigationLink {
                TechniqueReplayScreen(technique: technique)
            } label: {
                HStack {
                    Text("Replay")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.system(.callout, weight: .semibold))
                .padding(.horizontal, AppSpacing.md)
                .frame(height: 42)
                .background(accent.opacity(0.22))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .foregroundStyle(AppColor.textPrimary)
        }
        .padding(AppSpacing.md)
        .frame(width: 230, alignment: .leading)
        .frame(minHeight: 260)
        .background(accent.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(accent.opacity(0.26), lineWidth: 1)
        )
        .hoverEffect()
    }

    private var formattedDuration: String {
        let minutes = Int(technique.duration) / 60
        let seconds = Int(technique.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct WeaveThumbnail: View {
    let accent: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(accent.opacity(0.12))

            WeavePatternLines(accent: accent)
                .padding(AppSpacing.lg)
        }
        .frame(height: 92)
    }
}

private struct WeavePatternLines: View {
    let accent: Color

    var body: some View {
        ZStack {
            ForEach(0..<5) { index in
                Capsule()
                    .fill(accent.opacity(0.55))
                    .frame(width: 10, height: 76)
                    .offset(x: CGFloat(index - 2) * 26)

                Capsule()
                    .fill(Color.rattanLight.opacity(0.58))
                    .frame(width: 88, height: 10)
                    .offset(y: CGFloat(index - 2) * 18)
            }
        }
        .rotationEffect(.degrees(-4))
    }
}

private struct NewCaptureCard: View {
    var body: some View {
        NavigationLink {
            CameraView()
        } label: {
            VStack(spacing: AppSpacing.md) {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .semibold))
                    .frame(width: 64, height: 64)
                    .background(Color.mutedSage.opacity(0.18))
                    .clipShape(Circle())

                Text("New Capture")
                    .font(.system(.headline, weight: .semibold))
                    .multilineTextAlignment(.center)
            }
            .foregroundStyle(AppColor.textPrimary)
            .frame(width: 170)
            .frame(minHeight: 260)
            .background(.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.mutedSage.opacity(0.28), style: StrokeStyle(lineWidth: 1, dash: [6, 5]))
            )
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

private struct CaptureEmptyState: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "tray")
                .font(.system(size: 34, weight: .light))
                .foregroundStyle(Color.mutedSage)

            VStack(spacing: AppSpacing.xs) {
                Text("No techniques captured yet.")
                    .font(.system(.headline, weight: .semibold))
                    .foregroundStyle(AppColor.textPrimary)

                Text("Start your first craft recording to build the library.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textPrimary.opacity(0.72))
                    .multilineTextAlignment(.center)
            }

            NavigationLink {
                CameraView()
            } label: {
                Label("Start Capture", systemImage: "arrow.right")
                    .font(.system(.headline, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .tint(.mutedSage)
        }
        .padding(AppSpacing.xxl)
        .frame(maxWidth: .infinity, minHeight: 220)
        .background(.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.mutedSage.opacity(0.24), lineWidth: 1)
        )
    }
}

private struct SectionHeader: View {
    let title: LocalizedStringResource

    var body: some View {
        Text(title)
            .font(AppFont.title)
            .foregroundStyle(AppColor.textPrimary)
    }
}

private struct TechniqueLibraryContent: View {
    let techniques: [Technique]

    var body: some View {
        if techniques.isEmpty {
            Text("No techniques recorded yet.")
                .font(AppFont.body)
                .foregroundStyle(AppColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, AppSpacing.xl)
        } else {
            VStack(spacing: AppSpacing.sm) {
                ForEach(techniques) { technique in
                    TechniqueRow(technique: technique)
                }
            }
        }
    }
}

private struct LearnerVideoRow: View {
    let video: LearnerVideo

    var body: some View {
        NavigationLink {
            VideoPlayerScreen(video: video)
        } label: {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColor.accent)
                Text(video.title)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
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
        .buttonStyle(.plain)
    }
}

private struct TechniqueRow: View {
    let technique: Technique

    var body: some View {
        NavigationLink {
            TechniqueReplayScreen(technique: technique)
        } label: {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(AppColor.accent)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(technique.name)
                        .font(AppFont.headline)
                        .foregroundStyle(AppColor.textPrimary)

                    HStack {
                        Text(technique.date, style: .date)
                        Text(formattedDuration)
                    }
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                }

                Spacer()
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
        .buttonStyle(.plain)
    }

    private var formattedDuration: String {
        let minutes = Int(technique.duration) / 60
        let seconds = Int(technique.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    HomeView()
        .environment(RecordingViewModel())
}
