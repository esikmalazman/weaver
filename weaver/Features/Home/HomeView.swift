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
        case .artisan: "person.fill"
        case .learner: "graduationcap.fill"
        }
    }
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                SectionHeader(title: "Choose Role")
                RoleSelectionRow()
            }
            .padding(AppSpacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .navigationTitle("CraftWeave")
        }
    }
}

private struct RoleSelectionRow: View {
    var body: some View {
        HStack(spacing: AppSpacing.xl) {
            ForEach(HomeMode.allCases) { mode in
                RoleCard(mode: mode)
            }
        }
        .frame(maxHeight: .infinity)
    }
}

private struct RoleCard: View {
    let mode: HomeMode

    var body: some View {
        NavigationLink {
            destination
        } label: {
            RoleCardLabel(title: mode.title, icon: mode.icon)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var destination: some View {
        switch mode {
        case .artisan: ArtisanHomeView()
        case .learner: LearnerHomeView()
        }
    }
}

private struct RoleCardLabel: View {
    let title: LocalizedStringResource
    let icon: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(AppColor.accent)
            Text(title)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.surface.opacity(0.7))
        .glassBackgroundEffect(in: .rect(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(AppColor.border, lineWidth: 1.5)
        )
        .hoverEffect()
    }
}

private struct ArtisanHomeView: View {
    @Environment(RecordingViewModel.self) private var recordingViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                NewRecordingButton()
                TechniqueLibrarySection(techniques: recordingViewModel.savedTechniques)
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Artisan")
    }
}

private struct LearnerHomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                LearnerVideosSection()
            }
            .padding(AppSpacing.lg)
        }
        .navigationTitle("Learner")
    }
}

private struct NewRecordingButton: View {
    var body: some View {
        NavigationLink {
            CameraView()
        } label: {
            Text("New Recording")
                .font(AppFont.headline)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .tint(AppColor.accent)
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
