import SwiftUI

struct RecordingView: View {
    @Environment(RecordingViewModel.self) private var viewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            HandPreviewArea(phase: viewModel.phase, frame: viewModel.latestFrame)
            RecordingTimerDisplay(text: viewModel.formattedElapsedTime)
            Spacer()
            RecordingControls()
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .navigationTitle("New Recording")
        .task {
            await beginRecording()
        }
        .onDisappear {
            endRecording()
        }
        .alert(
            "Unable to start hand tracking.",
            isPresented: Binding(
                get: {
                    if case .failed = viewModel.phase { return true }
                    return false
                },
                set: { _ in }
            )
        ) {
            Button("Try Again") {
                Task { await beginRecording() }
            }
            Button("Cancel", role: .cancel) {
                dismiss()
            }
        }
    }

    /// Hand tracking can only run inside an open ImmersiveSpace, so the space
    /// must open before RecordingViewModel starts the ARKit session.
    private func beginRecording() async {
        let result = await openImmersiveSpace(id: RecordingImmersiveSpace.id)
        guard result == .opened else {
            viewModel.markStartFailed()
            return
        }
        await viewModel.startRecording()
    }

    private func endRecording() {
        viewModel.stopRecording()
        Task { await dismissImmersiveSpace() }
    }
}

private struct HandPreviewArea: View {
    let phase: RecordingViewModel.Phase
    let frame: HandMovementFrame?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            content

            HandTrackingStatusBadge(phase: phase, jointCount: jointCount)
                .padding(AppSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 320)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }

    private var jointCount: Int {
        (frame?.leftHandJoints.count ?? 0) + (frame?.rightHandJoints.count ?? 0)
    }

    @ViewBuilder
    private var content: some View {
        switch phase {
        case .recording:
            HandJointsRealityView(frame: frame, recenterOnWrist: true)
        case .preparing:
            HandPreviewPlaceholder(systemImage: "hand.raised.fill", message: "Preparing hand tracking…")
        case .failed:
            HandPreviewPlaceholder(systemImage: "hand.raised.slash.fill", message: "Hand tracking unavailable")
        }
    }
}

private struct HandPreviewPlaceholder: View {
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            Image(systemName: systemImage)
                .font(.system(size: 32))
            Text(message)
                .font(AppFont.body)
        }
        .foregroundStyle(AppColor.textSecondary)
    }
}

private struct HandTrackingStatusBadge: View {
    let phase: RecordingViewModel.Phase
    let jointCount: Int

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: "hand.raised.fill")
            Text(statusText)
        }
        .font(AppFont.caption)
        .foregroundStyle(AppColor.textPrimary)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(AppColor.background.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var statusText: String {
        switch phase {
        case .recording:
            jointCount > 0 ? "Tracking · \(jointCount) joints" : "Tracking"
        case .preparing:
            "Preparing"
        case .failed:
            "Not tracking"
        }
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
            .environment(RecordingViewModel())
    }
}
