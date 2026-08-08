import Foundation
import Observation

@MainActor
@Observable
final class RecordingViewModel {
    enum Phase: Equatable {
        case preparing
        case recording
        case failed(message: String)
    }

    private(set) var phase: Phase = .preparing
    private(set) var elapsedTime: TimeInterval = 0
    private(set) var handMovementFrames: [HandMovementFrame] = []
    private(set) var latestFrame: HandMovementFrame?

    let handTrackingSession = HandTrackingSession()

    private var timerTask: Task<Void, Never>?

    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func startRecording() async {
        phase = .preparing
        elapsedTime = 0
        handMovementFrames = []
        latestFrame = nil

        handTrackingSession.onFrame = { [weak self] frame in
            self?.handMovementFrames.append(frame)
            self?.latestFrame = frame
        }

        do {
            try await handTrackingSession.start()
        } catch {
            phase = .failed(message: "Unable to start hand tracking.")
            return
        }

        phase = .recording
        startTimer()
    }

    /// Called by the view when opening the ImmersiveSpace itself fails —
    /// hand tracking can only run inside one, so that's part of F-001's gate too.
    func markStartFailed() {
        phase = .failed(message: "Unable to start hand tracking.")
    }

    func stopRecording() {
        timerTask?.cancel()
        handTrackingSession.stop()
    }

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self?.elapsedTime += 1
            }
        }
    }
}
