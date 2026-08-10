import AVFoundation
import Observation


@MainActor
@Observable
final class AppAudioManager {
    private let normalBGMVolume: Float = 0.25
    private let duckedBGMVolume: Float = 0.05
    private var bgmPlayer: AVAudioPlayer?
    private var didConfigureAudioSession = false
    private var isConfiguringAudioSession = false
    private(set) var statusText = "Audio not started."

    func startBGMIfNeeded() {
        Task {
            guard await configureAudioSessionIfNeeded() else { return }
            playBGMIfNeeded()
        }
    }

    func duckForVideoPlayback() {
        Task {
            _ = await configureAudioSessionIfNeeded()
            bgmPlayer?.setVolume(duckedBGMVolume, fadeDuration: 0.2)
        }
    }

    func prepareForVideoPlayback() {
        Task {
            await configureAudioSessionIfNeeded()
        }
    }

    func restoreBGMVolume() {
        bgmPlayer?.setVolume(normalBGMVolume, fadeDuration: 0.3)
    }

    private func configureAudioSessionIfNeeded() async -> Bool {
        guard !didConfigureAudioSession else { return true }
        guard !isConfiguringAudioSession else { return false }

        isConfiguringAudioSession = true
        defer { isConfiguringAudioSession = false }

        do {
            try await activateAudioSession()
            didConfigureAudioSession = true
            statusText = "Audio session active."
            return true
        } catch {
            didConfigureAudioSession = false
            statusText = "Audio session failed: \(error.localizedDescription)"
            return false
        }
    }

    private func activateAudioSession() async throws {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let session = AVAudioSession.sharedInstance()
                    try session.setCategory(.playback, mode: .moviePlayback)
                    try session.setActive(true)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func playBGMIfNeeded() {
        if let bgmPlayer {
            bgmPlayer.volume = normalBGMVolume
            if !bgmPlayer.isPlaying {
                statusText = bgmPlayer.play() ? "BGM playing." : "BGM play request failed."
            } else {
                statusText = "BGM already playing."
            }
            return
        }

        guard let url = Bundle.main.url(forResource: "BGM", withExtension: "m4a") else {
            statusText = "BGM.m4a missing from bundle."
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = normalBGMVolume
            player.prepareToPlay()
            bgmPlayer = player
            statusText = player.play() ? "BGM playing." : "BGM play request failed."
        } catch {
            bgmPlayer = nil
            statusText = "BGM failed: \(error.localizedDescription)"
        }
    }
}
