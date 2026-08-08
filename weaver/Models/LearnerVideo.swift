import Foundation

struct LearnerVideo: Identifiable {
    let id = UUID()
    let title: String
    let resourceName: String
    let resourceExtension: String
}

extension LearnerVideo {
    static let weaving = LearnerVideo(title: "Weaving", resourceName: "weaving", resourceExtension: "mp4")
}
