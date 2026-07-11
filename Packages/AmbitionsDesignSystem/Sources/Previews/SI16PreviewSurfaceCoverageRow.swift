#if canImport(SwiftUI)
import SwiftUI

public struct SI16PreviewSurfaceCoverageRow: Identifiable, Hashable, Sendable {
    public let id: String
    public let ownerSurface: String
    public let primaryObject: String
    public let fixtureIDs: [String]
    public let accessibilityNote: String
    public let nonColorNote: String

    public init(
        id: String,
        ownerSurface: String,
        primaryObject: String,
        fixtureIDs: [String],
        accessibilityNote: String,
        nonColorNote: String
    ) {
        self.id = id
        self.ownerSurface = ownerSurface
        self.primaryObject = primaryObject
        self.fixtureIDs = fixtureIDs
        self.accessibilityNote = accessibilityNote
        self.nonColorNote = nonColorNote
    }

    public var fixtures: [SI16VisualQAFixture] {
        fixtureIDs.compactMap { SI16PreviewFixtureCatalog.fixtureLookup[$0] }
    }

    public var accessibilitySummary: String {
        "\(ownerSurface). \(primaryObject). \(accessibilityNote) \(nonColorNote)"
    }
}
#endif
