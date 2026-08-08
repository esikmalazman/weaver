import SwiftUI

/// Simple typography built on the system font and Dynamic Type text styles.
enum AppFont {
    static let largeTitle = Font.system(.largeTitle, weight: .bold)
    static let title = Font.system(.title2, weight: .semibold)
    static let headline = Font.system(.headline, weight: .semibold)
    static let body = Font.system(.body, weight: .regular)
    static let caption = Font.system(.caption, weight: .regular)
}
