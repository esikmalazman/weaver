import Foundation
import Observation

@MainActor
@Observable
final class RecordingViewModel {
    private(set) var elapsedTime: TimeInterval = 0

    var formattedElapsedTime: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
