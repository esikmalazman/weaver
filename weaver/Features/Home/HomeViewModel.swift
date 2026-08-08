import Observation

@MainActor
@Observable
final class HomeViewModel {
    private let recentTechniquesLimit = 3

    private(set) var techniques: [Technique] = []

    var recentTechniques: [Technique] {
        Array(techniques.prefix(recentTechniquesLimit))
    }
}
