import Foundation
import Observation

struct Learner3DContent: Equatable, Identifiable {
    enum Kind: Equatable {
        case patternAnimation
        case objectModel
    }

    let id: String
    let title: String
    let resourceURL: URL
    let kind: Kind
}

@MainActor
@Observable
final class Learner3DViewModel {
    private(set) var content: Learner3DContent?
    private(set) var patternAnimation: Learner3DContent?

    func showPatternAnimation(pattern: Pattern, url: URL) {
        let content = Learner3DContent(
            id: "pattern-\(pattern.id)",
            title: pattern.name,
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
            resourceURL: url,
            kind: .objectModel
        )
    }

    func returnToPatternAnimation() {
        content = patternAnimation
    }
}
