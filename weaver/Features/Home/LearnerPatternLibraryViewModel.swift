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
    private(set) var loadState = LoadState.loading

    private let loader: LearnerLibraryLoader

    init(loader: LearnerLibraryLoader = LearnerLibraryLoader()) {
        self.loader = loader
        loadLibrary()
    }

    private func loadLibrary() {
        do {
            let library = try loader.load()
            patterns = Self.orderedLearnerPatterns(from: library.patterns)
            loadState = .loaded
        } catch {
            patterns = []
            loadState = .failed("Unable to load pattern library.")
        }
    }

    private static func orderedLearnerPatterns(from patterns: [Pattern]) -> [Pattern] {
        let expectedPatternIDs = ["PAT_001", "PAT_002", "PAT_003"]
        return expectedPatternIDs.compactMap { patternID in
            patterns.first { $0.id == patternID }
        }
    }
}
