import Foundation

enum LifeShapeCorrectionKind: String, Sendable, CaseIterable, Hashable {
    case move
    case protect
    case lighten
    case review
}

struct LifeShapeCorrection: Identifiable, Sendable, Hashable {
    let id: String
    let kind: LifeShapeCorrectionKind
    let title: String
    let accessibilitySummary: String

    init(id: String, kind: LifeShapeCorrectionKind, title: String, accessibilitySummary: String) {
        self.id = id
        self.kind = kind
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.accessibilitySummary = accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
