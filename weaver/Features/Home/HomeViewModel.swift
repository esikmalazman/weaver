import Combine
import Foundation

final class HomeViewModel: ObservableObject {
    private let recentTechniquesLimit = 3

    @Published private(set) var techniques: [Technique] = []

    var recentTechniques: [Technique] {
        Array(techniques.prefix(recentTechniquesLimit))
    }
}
