import Foundation
import Observation

struct Learner3DMetadata: Equatable, Identifiable {
    let label: String
    let value: String

    var id: String { label }
}

struct LearnerObjectLibraryItem: Equatable, Identifiable {
    let object: RattanObject
    let modelURL: URL

    var id: String { object.id }
}

struct Learner3DContent: Equatable, Identifiable {
    enum Kind: Equatable {
        case patternAnimation
        case objectModel
    }

    let id: String
    let title: String
    let subtitle: String
    let description: String
    let metadata: [Learner3DMetadata]
    let resourceURL: URL
    let kind: Kind
}

@MainActor
@Observable
final class Learner3DViewModel {
    private(set) var content: Learner3DContent?
    private(set) var patternAnimation: Learner3DContent?
    private(set) var objectLibraryTitle = "Object Library"
    private(set) var objectLibraryItems: [LearnerObjectLibraryItem] = []
    private(set) var isModelWindowOpen = false
    private(set) var isObjectLibraryWindowOpen = false

    func showPatternAnimation(pattern: Pattern, url: URL) {
        let content = Learner3DContent(
            id: "pattern-\(pattern.id)",
            title: pattern.name,
            subtitle: "Pattern Animation",
            description: pattern.description,
            metadata: [
                Learner3DMetadata(label: "Technique", value: pattern.technique),
                Learner3DMetadata(label: "Structure", value: pattern.structure),
                Learner3DMetadata(label: "Difficulty", value: pattern.difficulty)
            ],
            resourceURL: url,
            kind: .patternAnimation
        )
        patternAnimation = content
        self.content = content
    }

    func showObject(_ object: RattanObject, url: URL) {
        content = Learner3DContent(
            id: "object-\(object.id)",
            title: object.name,
            subtitle: object.type,
            description: object.description,
            metadata: [
                Learner3DMetadata(label: "Pattern", value: object.pattern),
                Learner3DMetadata(label: "Material", value: object.material),
                Learner3DMetadata(label: "Location", value: object.location)
            ],
            resourceURL: url,
            kind: .objectModel
        )
    }

    func showObjectLibrary(title: String, items: [LearnerObjectLibraryItem]) {
        objectLibraryTitle = title
        objectLibraryItems = items
    }

    func returnToPatternAnimation() {
        content = patternAnimation
    }

    func markModelWindowOpen() {
        isModelWindowOpen = true
    }

    func markModelWindowClosed() {
        isModelWindowOpen = false
    }

    func markObjectLibraryWindowOpen() {
        isObjectLibraryWindowOpen = true
    }

    func markObjectLibraryWindowClosed() {
        isObjectLibraryWindowOpen = false
    }
}
