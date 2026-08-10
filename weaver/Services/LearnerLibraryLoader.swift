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
        guard let url = bundledURL(
            forResource: "weaver_learning_library_xcode_ready",
            withExtension: "json",
            subdirectories: ["Data", "Resources/Data"]
        ) else {
            throw LearnerLibraryLoaderError.missingResource(
                name: "weaver_learning_library_xcode_ready",
                extension: "json"
            )
        }

        let data = try Data(contentsOf: url)
        return try decoder.decode(LearnerLibrary.self, from: data)
    }

    func videoURL(for resource: String) -> URL? {
        bundledURL(for: resource, subdirectories: ["Videos", "Resources/Videos"])
    }

    func patternAnimationURL(for resource: String) -> URL? {
        bundledURL(for: resource, subdirectories: ["animated weave USDZ", "Resources/animated weave USDZ"])
    }

    func objectModelURL(for resource: String) -> URL? {
        bundledURL(for: resource, subdirectories: ["ObjectModels", "Resources/ObjectModels"])
    }

    private func bundledURL(for resource: String, subdirectories: [String]) -> URL? {
        let resourceURL = URL(fileURLWithPath: resource)
        let resourceName = resourceURL.deletingPathExtension().lastPathComponent
        let resourceExtension = resourceURL.pathExtension

        return bundledURL(
            forResource: resourceName,
            withExtension: resourceExtension,
            subdirectories: subdirectories
        )
    }

    private func bundledURL(
        forResource resourceName: String,
        withExtension resourceExtension: String,
        subdirectories: [String]
    ) -> URL? {
        for subdirectory in subdirectories {
            if let url = bundle.url(
                forResource: resourceName,
                withExtension: resourceExtension,
                subdirectory: subdirectory
            ) {
                return url
            }
        }

        return bundle.url(forResource: resourceName, withExtension: resourceExtension)
    }
}
