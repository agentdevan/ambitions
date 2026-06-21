import Foundation

struct FixedPoint: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let inputRef: LifeShapeInputRef

    init(id: String, title: String, start: Date, end: Date, inputRef: LifeShapeInputRef) {
        precondition(end >= start, "FixedPoint end must not precede start.")
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.start = start
        self.end = end
        self.inputRef = inputRef
    }
}
