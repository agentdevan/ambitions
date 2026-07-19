import Foundation

enum FixedPointKind: String, Sendable, CaseIterable, Hashable {
    case commitment
    case manualUnavailable
    case calendarBusy
}

struct FixedPoint: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let kind: FixedPointKind
    let isNonNegotiable: Bool
    let inputRef: LifeShapeInputRef

    init(
        id: String,
        title: String,
        start: Date,
        end: Date,
        kind: FixedPointKind = .commitment,
        isNonNegotiable: Bool = false,
        inputRef: LifeShapeInputRef
    ) {
        precondition(end >= start, "FixedPoint end must not precede start.")
        self.id = id
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.start = start
        self.end = end
        self.kind = kind
        self.isNonNegotiable = isNonNegotiable
        self.inputRef = inputRef
    }
}
