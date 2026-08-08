import SwiftUI

struct RecordingView: View {
    @State private var viewModel = RecordingViewModel()

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            CameraPreviewArea()
            RecordingTimerDisplay(text: viewModel.formattedElapsedTime)
            Spacer()
            RecordingControls()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .navigationTitle("New Recording")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct CameraPreviewArea: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColor.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColor.border, lineWidth: 1)
                )
                .overlay {
                    VStack(spacing: AppSpacing.sm) {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                        Text("Camera Preview")
                            .font(AppFont.body)
                    }
                    .foregroundStyle(AppColor.textSecondary)
                }

            HandMovementPreviewBadge()
                .padding(AppSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
    }
}

private struct HandMovementPreviewBadge: View {
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "hand.raised.fill")
            Text("Hand Movement Preview")
        }
        .font(AppFont.caption)
        .foregroundStyle(AppColor.textPrimary)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.background.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct RecordingTimerDisplay: View {
    let text: String

    var body: some View {
        Text(text)
            .font(AppFont.largeTitle)
            .foregroundStyle(AppColor.textPrimary)
            .monospacedDigit()
    }
}

private struct RecordingControls: View {
    var body: some View {
        HStack(spacing: AppSpacing.xl) {
            ControlButton(systemImage: "mic.fill", label: "Voice Note") {
            }
            ControlButton(systemImage: "pause.fill", label: "Pause") {
            }
            ControlButton(systemImage: "stop.fill", label: "Stop") {
            }
        }
    }
}

private struct ControlButton: View {
    let systemImage: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: systemImage)
                    .font(.system(size: 20))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 56, height: 56)
                    .background(AppColor.surface)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(AppColor.border, lineWidth: 1)
                    )
                Text(label)
                    .font(AppFont.caption)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        RecordingView()
    }
}
