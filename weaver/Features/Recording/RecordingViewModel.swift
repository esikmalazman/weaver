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
    private(set) var savedTechniques: [Technique] = []
    private(set) var liveTranscript = ""

    let handTrackingSession = HandTrackingSession()

    private let transcriptionSession = SpeechTranscriptionSession()
    private var timerTask: Task<Void, Never>?

    init() {
        savedTechniques = loadSavedTechniques()
    }

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
        liveTranscript = ""

        handTrackingSession.onFrame = { [weak self] frame in
            self?.handMovementFrames.append(frame)
            self?.latestFrame = frame
        }
        transcriptionSession.onTranscriptChange = { [weak self] transcript in
            self?.liveTranscript = transcript
        }

        do {
            try await handTrackingSession.start()
            try await transcriptionSession.start()
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
        timerTask = nil
        handTrackingSession.stop()
        transcriptionSession.stop()
    }

    func saveTechnique(named name: String) -> Technique? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty, !handMovementFrames.isEmpty else { return nil }

        let normalizedFrames = normalizedTimeline(from: handMovementFrames)
        let technique = Technique(
            name: trimmedName,
            date: .now,
            duration: normalizedFrames.last?.timestamp ?? elapsedTime,
            frames: normalizedFrames,
            transcript: liveTranscript
        )
        savedTechniques.insert(technique, at: 0)
        saveTechniquesToDisk()
        stopRecording()
        return technique
    }

    private func normalizedTimeline(from frames: [HandMovementFrame]) -> [HandMovementFrame] {
        guard let firstTimestamp = frames.first?.timestamp else { return [] }
        return frames.map { frame in
            HandMovementFrame(
                id: frame.id,
                timestamp: frame.timestamp - firstTimestamp,
                leftHandJoints: frame.leftHandJoints,
                rightHandJoints: frame.rightHandJoints
            )
        }
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

    private func loadSavedTechniques() -> [Technique] {
        let fileURL = savedTechniquesURL
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([Technique].self, from: data)) ?? []
    }

    private func saveTechniquesToDisk() {
        let fileURL = savedTechniquesURL
        try? FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        guard let data = try? JSONEncoder().encode(savedTechniques) else { return }
        try? data.write(to: fileURL, options: [.atomic])
    }

    private var savedTechniquesURL: URL {
        let applicationSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return applicationSupportURL
            .appendingPathComponent("Weaver", isDirectory: true)
            .appendingPathComponent("TechniqueLibrary.json")
    }
}
