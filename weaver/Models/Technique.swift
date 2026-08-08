import Foundation

struct Technique: Identifiable, Hashable {
    let id: UUID
    let name: String
    let date: Date
    let duration: TimeInterval

    init(id: UUID = UUID(), name: String, date: Date, duration: TimeInterval) {
        self.id = id
        self.name = name
        self.date = date
        self.duration = duration
    }
}
