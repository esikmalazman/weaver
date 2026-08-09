import Foundation

struct LearnerLibrary: Codable, Equatable {
    let schemaVersion: Int
    let patterns: [Pattern]
    let objects: [RattanObject]
}

struct Pattern: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let thumbnail: String
    let description: String
    let technique: String
    let structure: String
    let difficulty: String
    let learningMedia: LearningMedia
    let objectIds: [String]
}

struct LearningMedia: Codable, Equatable {
    let video2D: MediaResource
    let animation3D: MediaResource
}

struct MediaResource: Codable, Equatable {
    let resource: String
    let type: String
}

struct RattanObject: Codable, Equatable, Identifiable {
    let id: String
    let name: String
    let type: String
    let model: String
    let image: String
    let pattern: String
    let patternId: String
    let material: String
    let location: String
    let description: String
}
