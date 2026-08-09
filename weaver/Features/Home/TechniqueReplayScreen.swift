import SwiftUI

struct TechniqueReplayScreen: View {
    let technique: Technique

    @State private var currentTime: TimeInterval = 0
    @State private var isPlaying = true
    @State private var playbackSpeed = 1.0
    @State private var repeatsPlayback = true

    private let playbackSpeeds = [0.5, 0.75, 1.0, 1.5]

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            TechniqueReplayStage(frame: frame(at: currentTime), transcript: technique.transcript)
            TechniqueReplayControls(
                currentTime: $currentTime,
                isPlaying: $isPlaying,
                playbackSpeed: $playbackSpeed,
                repeatsPlayback: $repeatsPlayback,
                duration: duration,
                playbackSpeeds: playbackSpeeds
            )
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
        .navigationTitle(technique.name)
        .task {
            await runPlaybackLoop()
        }
    }

    private var duration: TimeInterval {
        max(technique.duration, technique.frames.last?.timestamp ?? 0)
    }

    private func frame(at time: TimeInterval) -> HandMovementFrame? {
        guard !technique.frames.isEmpty else { return nil }
        return technique.frames.last(where: { $0.timestamp <= time }) ?? technique.frames.first
    }

    private func runPlaybackLoop() async {
        var lastUpdate = Date.now
        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(33))
            guard isPlaying else {
                lastUpdate = .now
                continue
            }

            let now = Date.now
            let delta = now.timeIntervalSince(lastUpdate) * playbackSpeed
            lastUpdate = now

            let nextTime = currentTime + delta
            if nextTime >= duration {
                currentTime = repeatsPlayback ? 0 : duration
                isPlaying = repeatsPlayback
            } else {
                currentTime = nextTime
            }
        }
    }
}

private struct TechniqueReplayStage: View {
    let frame: HandMovementFrame?
    let transcript: String

    var body: some View {
        ZStack(alignment: .bottom) {
            HandJointsRealityView(frame: frame, recenterOnWrist: true)

            TranscriptCaption(text: transcript)
                .padding(AppSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 380)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }
}

private struct TranscriptCaption: View {
    let text: String

    var body: some View {
        Text(text.isEmpty ? "No transcript captured." : text)
            .font(AppFont.body)
            .foregroundStyle(AppColor.textPrimary)
            .multilineTextAlignment(.center)
            .lineLimit(3)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(AppColor.background.opacity(0.86))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct TechniqueReplayControls: View {
    @Binding var currentTime: TimeInterval
    @Binding var isPlaying: Bool
    @Binding var playbackSpeed: Double
    @Binding var repeatsPlayback: Bool

    let duration: TimeInterval
    let playbackSpeeds: [Double]

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Slider(value: $currentTime, in: 0...max(duration, 0.1))
            HStack {
                Text(formattedTime(currentTime))
                Spacer()
                Text(formattedTime(duration))
            }
            .font(AppFont.caption)
            .foregroundStyle(AppColor.textSecondary)
            ViewThatFits {
                HStack(spacing: AppSpacing.md) {
                    transportButtons
                    speedPicker
                    repeatToggle
                }
                VStack(spacing: AppSpacing.md) {
                    transportButtons
                    speedPicker
                    repeatToggle
                }
            }
        }
        .padding(AppSpacing.md)
        .background(AppColor.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColor.border, lineWidth: 1)
        )
    }

    private var transportButtons: some View {
        HStack(spacing: AppSpacing.md) {
            ReplayIconButton(systemImage: "gobackward.10") {
                currentTime = max(0, currentTime - 10)
            }
            ReplayIconButton(systemImage: isPlaying ? "pause.fill" : "play.fill") {
                isPlaying.toggle()
            }
            ReplayIconButton(systemImage: "goforward.10") {
                currentTime = min(duration, currentTime + 10)
            }
        }
    }

    private var speedPicker: some View {
        Picker("Speed", selection: $playbackSpeed) {
            ForEach(playbackSpeeds, id: \.self) { speed in
                Text("\(speed, specifier: "%g")x").tag(speed)
            }
        }
        .pickerStyle(.segmented)
        .frame(minWidth: 260)
    }

    private var repeatToggle: some View {
        Toggle("Repeat", isOn: $repeatsPlayback)
            .font(AppFont.body)
            .toggleStyle(.button)
    }

    private func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

private struct ReplayIconButton: View {
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

#Preview {
    NavigationStack {
        TechniqueReplayScreen(
            technique: Technique(
                name: "Pick and Pass",
                date: .now,
                duration: 12,
                frames: [],
                transcript: "Lift the thread, pass the shuttle, and keep the edge relaxed."
            )
        )
    }
}
