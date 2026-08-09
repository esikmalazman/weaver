import SwiftUI

struct LearnerObjectLibraryWindow: View {
    @Environment(Learner3DViewModel.self) private var viewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        ObjectLibraryPanel(
            title: viewModel.objectLibraryTitle,
            items: viewModel.objectLibraryItems,
            selectAction: showObject(_:)
        )
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColor.surface.opacity(0.16))
        .glassBackgroundEffect(in: .rect(cornerRadius: 24, style: .continuous))
        .onAppear {
            viewModel.markObjectLibraryWindowOpen()
        }
        .onDisappear {
            viewModel.markObjectLibraryWindowClosed()
        }
    }

    private func showObject(_ item: LearnerObjectLibraryItem) {
        viewModel.showObject(item.object, url: item.modelURL)
        if !viewModel.isModelWindowOpen {
            viewModel.markModelWindowOpen()
            openWindow(id: WeaverWindow.model3D)
        }
    }
}

private struct ObjectLibraryPanel: View {
    let title: String
    let items: [LearnerObjectLibraryItem]
    let selectAction: (LearnerObjectLibraryItem) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Appears in")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

            TapToView3DCue()

            ScrollView {
                LazyVStack(spacing: AppSpacing.md) {
                    ForEach(items) { item in
                        Button {
                            selectAction(item)
                        } label: {
                            ObjectLibraryCard(object: item.object)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

private struct ObjectLibraryCard: View {
    let object: RattanObject

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Image(object.image)
                .resizable()
                .scaledToFill()
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(alignment: .center, spacing: AppSpacing.sm) {
                Text(object.name)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)

                Spacer()

                Label("3D", systemImage: "cube")
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, AppSpacing.xs)
                    .background(AppColor.accent.opacity(0.35))
                    .clipShape(Capsule())
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface.opacity(0.28))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border.opacity(0.7), lineWidth: 1)
        )
        .hoverEffect()
    }
}

private struct TapToView3DCue: View {
    var body: some View {
        Label("Tap an object to view in 3D", systemImage: "hand.tap")
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColor.accent.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(AppColor.border.opacity(0.7), lineWidth: 1)
            }
        }
}

#Preview {
    LearnerObjectLibraryWindow()
        .environment(Learner3DViewModel())
}
