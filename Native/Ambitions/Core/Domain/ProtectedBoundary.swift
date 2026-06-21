import Foundation

enum ProtectedBoundaryKind: String, Sendable, CaseIterable, Hashable {
    case explicit
    case sleep
    case away
    case vacation
    case fixedCommitment
    case keepClearCorrection
}

struct ProtectedBoundary: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let reason: String
    let kind: ProtectedBoundaryKind
    let inputRef: LifeShapeInputRef

    init(
        id: String,
        title: String,
        start: Date,
        end: Date,
        reason: String,
        kind: ProtectedBoundaryKind = .explicit,
        inputRef: LifeShapeInputRef
    ) {
        precondition(end >= start, "ProtectedBoundary end must not precede start.")
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.start = start
        self.end = end
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.inputRef = inputRef
    }
}
