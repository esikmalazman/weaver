import Foundation
import Observation

@MainActor
@Observable
final class LearnerPatternLibraryViewModel {
    enum LoadState: Equatable {
        case loading
        case loaded
        case failed(String)
    }

    private(set) var patterns: [Pattern] = []
    private(set) var objects: [RattanObject] = []
    private(set) var loadState = LoadState.loading

    private let loader: LearnerLibraryLoader

    init() {
        self.loader = LearnerLibraryLoader()
        loadLibrary()
    }

    init(loader: LearnerLibraryLoader) {
        self.loader = loader
        loadLibrary()
    }

    private func loadLibrary() {
        do {
            let library = try loader.load()
            patterns = Self.orderedLearnerPatterns(from: library.patterns)
            objects = library.objects
            loadState = .loaded
        } catch {
            patterns = []
            objects = []
            loadState = .failed("Unable to load pattern library.")
        }
    }

    func objects(for pattern: Pattern) -> [RattanObject] {
        pattern.objectIds.compactMap { objectID in
            objects.first { $0.id == objectID }
        }
    }

    func videoURL(for pattern: Pattern) -> URL? {
        loader.videoURL(for: pattern.learningMedia.video2D.resource)
    }

    func patternAnimationURL(for pattern: Pattern) -> URL? {
        loader.patternAnimationURL(for: pattern.learningMedia.animation3D.resource)
    }

    func objectModelURL(for object: RattanObject) -> URL? {
        loader.objectModelURL(for: object.model)
    }

    private static func orderedLearnerPatterns(from patterns: [Pattern]) -> [Pattern] {
        let expectedPatternIDs = ["PAT_001", "PAT_002", "PAT_003"]
        return expectedPatternIDs.compactMap { patternID in
            patterns.first { $0.id == patternID }
        }
    }
}
