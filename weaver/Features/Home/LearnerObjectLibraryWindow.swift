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
        .background(AppColor.surface.opacity(0.28))
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
            Text("Craft Object Library")
                .font(AppFont.title)
                .foregroundStyle(AppColor.textPrimary)

            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(AppColor.textSecondary)

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
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(object.name)
                    .font(AppFont.headline)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(2)
                Text(object.type)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                ObjectLibraryMetadataText(label: "Pattern", value: object.pattern)
                ObjectLibraryMetadataText(label: "Material", value: object.material)
                ObjectLibraryMetadataText(label: "Location", value: object.location)
                Text(object.description)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
                    .lineLimit(3)
                    .padding(.top, AppSpacing.xs)
            }
        }
        .padding(AppSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surface.opacity(0.42))
        .glassBackgroundEffect(in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(AppColor.border.opacity(0.7), lineWidth: 1)
        )
        .hoverEffect()
    }
}

private struct ObjectLibraryMetadataText: View {
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
    LearnerObjectLibraryWindow()
        .environment(Learner3DViewModel())
}
