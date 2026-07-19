import Foundation

enum LifeShapeInputRefKind: String, Sendable, CaseIterable, Hashable {
    case clock
    case goal
    case step
    case capture
    case fixedPoint
    case protectedBoundary
    case userCorrection
    case localDefault
}

struct LifeShapeInputRef: Identifiable, Sendable, Hashable {
    let id: String
    let kind: LifeShapeInputRefKind
    let label: String

    init(id: String, kind: LifeShapeInputRefKind, label: String) {
        self.id = id
        self.kind = kind
        self.label = label.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
