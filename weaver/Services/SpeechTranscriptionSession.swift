import AVFoundation
import Speech

@MainActor
final class SpeechTranscriptionSession {
    var onTranscriptChange: ((String) -> Void)?

    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    func start() async throws {
        guard await requestSpeechAuthorization() else {
            return
        }
        guard let speechRecognizer, speechRecognizer.isAvailable else {
            return
        }

        stop()

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        request.taskHint = .dictation
        recognitionRequest = request

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        if #available(visionOS 27.0, *) {
            try inputNode.installAudioTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
                request?.append(AVAudioPCMBuffer(copying: buffer))
            }
        } else {
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { [weak request] buffer, _ in
                request?.append(buffer)
            }
        }

        audioEngine.prepare()
        try audioEngine.start()

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let transcript = result?.bestTranscription.formattedString, !transcript.isEmpty {
                self.onTranscriptChange?(transcript)
            }
            if error != nil || result?.isFinal == true {
                self.stop()
            }
        }
    }

    func stop() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
    }

    private func requestSpeechAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
