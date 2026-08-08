import Foundation

struct Technique: Codable, Identifiable {
    let id: UUID
    let name: String
    let date: Date
    let duration: TimeInterval
    let frames: [HandMovementFrame]
    let transcript: String

    init(
        id: UUID = UUID(),
        name: String,
        date: Date,
        duration: TimeInterval,
        frames: [HandMovementFrame],
        transcript: String
    ) {
        self.id = id
        self.name = name
        self.date = date
        self.duration = duration
        self.frames = frames
        self.transcript = transcript
    }
}
