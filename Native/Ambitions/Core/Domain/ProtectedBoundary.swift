import Foundation

struct ProtectedBoundary: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let reason: String
    let inputRef: LifeShapeInputRef

    init(id: String, title: String, start: Date, end: Date, reason: String, inputRef: LifeShapeInputRef) {
        precondition(end >= start, "ProtectedBoundary end must not precede start.")
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.start = start
        self.end = end
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.inputRef = inputRef
    }
}
