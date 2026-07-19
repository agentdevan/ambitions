import Foundation

enum LifeShapeFallbackKind: String, Sendable, CaseIterable, Hashable {
    case localDefault
    case calendarUnavailable
    case sourceUnavailable
    case insufficientContext
}

struct LifeShapeFallback: Sendable, Hashable {
    let kind: LifeShapeFallbackKind
    let userVisibleSummary: String

    init(kind: LifeShapeFallbackKind, userVisibleSummary: String) {
        self.kind = kind
        self.userVisibleSummary = userVisibleSummary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
