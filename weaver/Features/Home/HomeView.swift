import SwiftUI

enum HomeMode: String, CaseIterable, Identifiable {
    case artisan = "Artisan"
    case learner = "Learner"

    var id: String { rawValue }
}

struct HomeView: View {
    @Environment(RecordingViewModel.self) private var recordingViewModel
    @State private var mode: HomeMode = .artisan

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    ModePicker(selection: $mode)

                    if mode == .artisan {
                        NewRecordingButton()
                    } else {
                        LearnerVideosSection()
                    }

                    TechniqueLibrarySection(techniques: recordingViewModel.savedTechniques)
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColor.background)
            .navigationTitle("CraftWeave")
        }
    }
}

private struct ModePicker: View {
    @Binding var selection: HomeMode

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            ForEach(HomeMode.allCases) { mode in
                ModePickerSegment(mode: mode, isSelected: selection == mode) {
                    selection = mode
                }
            }
        }
        .padding(AppSpacing.xs)
        .background(AppColor.surface)
        .clipShape(Capsule())
    }
}

private struct ModePickerSegment: View {
    let mode: HomeMode
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(mode.rawValue)
                .font(AppFont.body)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.sm)
        }
        .buttonStyle(.plain)
        .background(isSelected ? AppColor.accent : Color.clear)
        .foregroundStyle(isSelected ? AppColor.background : AppColor.textSecondary)
        .clipShape(Capsule())
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
                .padding(.vertical, AppSpacing.md)
        }
        .buttonStyle(.plain)
        .background(AppColor.accent)
        .foregroundStyle(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColor.border, lineWidth: 1)
            )
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
            .background(AppColor.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColor.border, lineWidth: 1)
            )
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
