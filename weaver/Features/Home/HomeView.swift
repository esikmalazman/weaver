import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.xl) {
                    newRecordingButton
                    recentTechniquesSection
                }
                .padding(AppSpacing.lg)
            }
            .background(AppColor.background)
            .navigationTitle("CraftWeave")
        }
    }

    private var newRecordingButton: some View {
        Button {
        } label: {
            Text("New Recording")
                .font(AppFont.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.md)
        }
        .background(AppColor.accent)
        .foregroundStyle(AppColor.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var recentTechniquesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text("Recent Techniques")
                    .font(AppFont.title)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Button("View All") {
                }
                .font(AppFont.body)
                .foregroundStyle(AppColor.accent)
            }

            if viewModel.recentTechniques.isEmpty {
                Text("No techniques recorded yet.")
                    .font(AppFont.body)
                    .foregroundStyle(AppColor.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, AppSpacing.xl)
            } else {
                VStack(spacing: AppSpacing.sm) {
                    ForEach(viewModel.recentTechniques) { technique in
                        TechniqueRow(technique: technique)
                    }
                }
            }
        }
    }
}

private struct TechniqueRow: View {
    let technique: Technique

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(technique.name)
                .font(AppFont.headline)
                .foregroundStyle(AppColor.textPrimary)

            HStack {
                Text(technique.date, style: .date)
                Spacer()
                Text(formattedDuration)
            }
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textSecondary)
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

    private var formattedDuration: String {
        let minutes = Int(technique.duration) / 60
        let seconds = Int(technique.duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    HomeView()
}
