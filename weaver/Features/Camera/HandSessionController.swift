import ARKit
import AVFAudio
import Foundation
import simd

@MainActor
@Observable
final class HandSessionController {
    enum SessionState: Equatable {
        case idle
        case recording
        case playing
    }

    private(set) var state: SessionState = .idle
    private(set) var statusText = "Ready to record hand motion and voice."
    private(set) var savedRecordings: [StoredHandRecording] = []
    private(set) var activeRecording: StoredHandRecording?
    private(set) var currentReplayFrame: HandRecordingFrame?
    private(set) var detectedHandCount = 0
    private(set) var detectedJointCount = 0
    private(set) var trackedJointCount = 0
    private(set) var detectionStatusText = "No active hand-tracking session."

    private let recordingsDirectory: URL
    private var arSession: ARKitSession?
    private var handTrackingProvider: HandTrackingProvider?
    private var recordingTask: Task<Void, Never>?
    private var playbackTask: Task<Void, Never>?
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingStartTimestamp: TimeInterval?
    private var recordingStartDate: Date?
    private var capturedFrames: [HandRecordingFrame] = []
    private var latestHands: [HandChirality: RecordedHand] = [:]
    private var currentAudioURL: URL?

    init() {
        recordingsDirectory = URL.documentsDirectory.appending(path: "HandRecordings", directoryHint: .isDirectory)
        loadSavedRecordings()
    }

    var canRecord: Bool {
        state == .idle
    }

    var canStop: Bool {
        state == .recording || state == .playing
    }

    func clearReplayPreview() {
        currentReplayFrame = nil
    }
    
    func startRecording() async {
        guard state == .idle else { return }

        guard HandTrackingProvider.isSupported else {
            statusText = "Hand tracking is not supported on this device or run destination."
            return
        }

        guard await requestMicrophonePermission() else {
            statusText = "Microphone access is required to record voice."
            return
        }

        do {
            try FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
            let sessionID = UUID()
            let audioURL = recordingsDirectory.appending(path: "\(sessionID.uuidString).m4a")
            let recorder = try makeAudioRecorder(url: audioURL)
            let session = ARKitSession()
            let provider = HandTrackingProvider()
            let authorization = await session.requestAuthorization(for: HandTrackingProvider.requiredAuthorizations)

            guard authorization.values.allSatisfy({ $0 == .allowed }) else {
                statusText = "Hand tracking access is required to record joint motion."
                return
            }

            try await session.run([provider])
            recorder.record()

            arSession = session
            handTrackingProvider = provider
            audioRecorder = recorder
            currentAudioURL = audioURL
            capturedFrames = []
            latestHands = [:]
            recordingStartTimestamp = nil
            recordingStartDate = Date()
            currentReplayFrame = nil
            resetDetectionStats(message: "Waiting for tracked hands...")
            state = .recording
            statusText = "Recording hand motion and voice..."

            recordingTask = Task { [weak self, provider] in
                for await update in provider.anchorUpdates {
                    self?.record(update: update)
                }
            }
        } catch {
            cleanupRecordingResources()
            statusText = "Could not start recording: \(error.localizedDescription)"
        }
    }

    func stop() {
        switch state {
        case .recording:
            finishRecording()
        case .playing:
            stopPlayback()
        case .idle:
            break
        }
    }

    func playLatestRecording() {
        guard state == .idle else { return }
        guard let recording = savedRecordings.first else {
            statusText = "No recording available to replay."
            return
        }
        play(recording)
    }

    func play(_ storedRecording: StoredHandRecording) {
        guard state == .idle else { return }

        let audioURL = recordingsDirectory.appending(path: storedRecording.recording.audioFileName)
        do {
            let player = try AVAudioPlayer(contentsOf: audioURL)
            player.prepareToPlay()
            audioPlayer = player
            activeRecording = storedRecording
            currentReplayFrame = storedRecording.recording.frames.first
            state = .playing
            statusText = "Replaying hand motion with voice..."
            player.play()

            playbackTask = Task { [weak self] in
                await self?.runPlaybackClock(for: storedRecording.recording)
            }
        } catch {
            statusText = "Could not play recording audio: \(error.localizedDescription)"
        }
    }

    private func record(update: AnchorUpdate<HandAnchor>) {
        guard state == .recording else { return }

        if recordingStartTimestamp == nil {
            recordingStartTimestamp = update.timestamp
        }

        guard let startTimestamp = recordingStartTimestamp else {
            detectionStatusText = "Waiting for ARKit timestamps..."
            return
        }

        guard let hand = makeRecordedHand(from: update.anchor) else {
            updateDetectionStats(for: update.anchor, hand: nil)
            return
        }

        updateDetectionStats(for: update.anchor, hand: hand)
        latestHands[hand.chirality] = hand
        let frame = HandRecordingFrame(
            time: update.timestamp - startTimestamp,
            hands: HandChirality.allCases.compactMap { latestHands[$0] }
        )
        capturedFrames.append(frame)
        currentReplayFrame = frame
        statusText = "Recording... \(capturedFrames.count) motion frames"
    }

    private func finishRecording() {
        let duration = audioRecorder?.currentTime ?? capturedFrames.last?.time ?? 0
        audioRecorder?.stop()
        arSession?.stop()
        recordingTask?.cancel()

        defer {
            cleanupRecordingResources()
            state = .idle
        }

        guard let audioURL = currentAudioURL,
              let startDate = recordingStartDate,
              !capturedFrames.isEmpty else {
            statusText = "Recording stopped. No tracked hands were captured. Open the immersive space and keep your hands visible in front of you."
            return
        }

        let recording = HandRecording(
            id: UUID(),
            createdAt: startDate,
            duration: duration,
            audioFileName: audioURL.lastPathComponent,
            frames: capturedFrames
        )
        let motionURL = recordingsDirectory.appending(path: "\(recording.id.uuidString).json")
        let stored = StoredHandRecording(recording: recording, motionFileName: motionURL.lastPathComponent)

        do {
            let data = try JSONEncoder.handRecordingEncoder.encode(recording)
            try data.write(to: motionURL, options: [.atomic])
            savedRecordings.insert(stored, at: 0)
            activeRecording = stored
            currentReplayFrame = recording.frames.first
            statusText = "Saved \(recording.frameCount) hand frames with voice."
        } catch {
            statusText = "Recording captured but could not save motion data: \(error.localizedDescription)"
        }
    }

    private func stopPlayback() {
        playbackTask?.cancel()
        playbackTask = nil
        audioPlayer?.stop()
        audioPlayer = nil
        state = .idle
        statusText = "Replay stopped."
    }

    private func runPlaybackClock(for recording: HandRecording) async {
        while !Task.isCancelled {
            guard let player = audioPlayer else { break }
            let playbackTime = player.currentTime
            currentReplayFrame = nearestFrame(in: recording, at: playbackTime)

            if playbackTime >= recording.duration || !player.isPlaying {
                break
            }

            try? await Task.sleep(for: .milliseconds(16))
        }

        if !Task.isCancelled {
            stopPlayback()
            currentReplayFrame = recording.frames.last
            statusText = "Replay finished."
        }
    }

    private func nearestFrame(in recording: HandRecording, at time: TimeInterval) -> HandRecordingFrame? {
        guard !recording.frames.isEmpty else { return nil }

        var low = 0
        var high = recording.frames.count - 1

        while low < high {
            let mid = (low + high) / 2
            if recording.frames[mid].time < time {
                low = mid + 1
            } else {
                high = mid
            }
        }

        return recording.frames[low]
    }

    private func makeRecordedHand(from anchor: HandAnchor) -> RecordedHand? {
        guard anchor.isTracked, let skeleton = anchor.handSkeleton else {
            return nil
        }

        let chirality: HandChirality
        switch anchor.chirality {
        case .left:
            chirality = .left
        case .right:
            chirality = .right
        @unknown default:
            return nil
        }

        let joints = skeleton.allJoints.map { joint in
            let originFromJoint = anchor.originFromAnchorTransform * joint.anchorFromJointTransform
            let translation = originFromJoint.columns.3
            return RecordedJoint(
                name: String(describing: joint.name),
                parentName: joint.parentJoint.map { String(describing: $0.name) },
                position: CodableVector3(SIMD3<Float>(translation.x, translation.y, translation.z)),
                isTracked: joint.isTracked
            )
        }

        return RecordedHand(chirality: chirality, joints: joints)
    }

    private func updateDetectionStats(for anchor: HandAnchor, hand: RecordedHand?) {
        guard anchor.isTracked else {
            detectedHandCount = latestHands.count
            detectedJointCount = latestHands.values.reduce(0) { $0 + $1.joints.count }
            trackedJointCount = latestHands.values.reduce(0) { partialResult, hand in
                partialResult + hand.joints.filter(\.isTracked).count
            }
            detectionStatusText = "ARKit is running, but this hand anchor is not currently tracked."
            return
        }

        guard let hand else {
            detectedHandCount = latestHands.count
            detectedJointCount = latestHands.values.reduce(0) { $0 + $1.joints.count }
            trackedJointCount = latestHands.values.reduce(0) { partialResult, hand in
                partialResult + hand.joints.filter(\.isTracked).count
            }
            detectionStatusText = "Hand anchor tracked, but no skeleton joints were available yet."
            return
        }

        let pendingHands = latestHands.merging([hand.chirality: hand]) { _, new in new }
        detectedHandCount = pendingHands.count
        detectedJointCount = pendingHands.values.reduce(0) { $0 + $1.joints.count }
        trackedJointCount = pendingHands.values.reduce(0) { partialResult, hand in
            partialResult + hand.joints.filter(\.isTracked).count
        }
        detectionStatusText = "Detected \(trackedJointCount) tracked joints across \(detectedHandCount) hand(s)."
    }

    private func resetDetectionStats(message: String) {
        detectedHandCount = 0
        detectedJointCount = 0
        trackedJointCount = 0
        detectionStatusText = message
    }

    private func requestMicrophonePermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    private func makeAudioRecorder(url: URL) throws -> AVAudioRecorder {
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44_100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        let recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder.prepareToRecord()
        return recorder
    }

    private func loadSavedRecordings() {
        do {
            try FileManager.default.createDirectory(at: recordingsDirectory, withIntermediateDirectories: true)
            let motionFiles = try FileManager.default.contentsOfDirectory(
                at: recordingsDirectory,
                includingPropertiesForKeys: nil
            )
            .filter { $0.pathExtension == "json" }

            savedRecordings = motionFiles.compactMap { url in
                guard let data = try? Data(contentsOf: url),
                      let recording = try? JSONDecoder.handRecordingDecoder.decode(HandRecording.self, from: data) else {
                    return nil
                }
                return StoredHandRecording(recording: recording, motionFileName: url.lastPathComponent)
            }
            .sorted { $0.recording.createdAt > $1.recording.createdAt }

            activeRecording = savedRecordings.first
            currentReplayFrame = activeRecording?.recording.frames.first
        } catch {
            statusText = "Could not load saved recordings: \(error.localizedDescription)"
        }
    }

    private func cleanupRecordingResources() {
        recordingTask?.cancel()
        recordingTask = nil
        arSession?.stop()
        arSession = nil
        handTrackingProvider = nil
        audioRecorder = nil
        currentAudioURL = nil
        recordingStartTimestamp = nil
        recordingStartDate = nil
        latestHands = [:]
        resetDetectionStats(message: "No active hand-tracking session.")
    }
}

private extension JSONEncoder {
    static var handRecordingEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return encoder
    }
}

private extension JSONDecoder {
    static var handRecordingDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
