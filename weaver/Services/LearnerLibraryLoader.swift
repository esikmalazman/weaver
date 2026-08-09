import Foundation

enum LearnerLibraryLoaderError: Error, Equatable {
    case missingResource(name: String, extension: String)
}

struct LearnerLibraryLoader {
    private let bundle: Bundle
    private let decoder: JSONDecoder

    init(bundle: Bundle = .main, decoder: JSONDecoder = JSONDecoder()) {
        self.bundle = bundle
        self.decoder = decoder
    }

    func load() throws -> LearnerLibrary {
        guard let url = bundle.url(
            forResource: "weaver_learning_library_xcode_ready",
            withExtension: "json",
            subdirectory: "Data"
        ) else {
            throw LearnerLibraryLoaderError.missingResource(
                name: "weaver_learning_library_xcode_ready",
                extension: "json"
            )
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode(LearnerLibrary.self, from: data)
    }
}
