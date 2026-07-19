import Foundation

enum LifeShapeReadingKind: String, Sendable, CaseIterable, Hashable {
    case unavailable
    case open
    case protected
    case pressure
    case buffer
}

struct LifeShapeReading: Sendable, Hashable {
    let horizon: LifeShapeHorizon
    let kind: LifeShapeReadingKind
    let title: String
    let summary: String
    let capacityStatement: String
    let sourceDetail: String
    let fallbackState: LifeShapeFallback?
    let accessibilitySummary: String

    init(
        horizon: LifeShapeHorizon,
        kind: LifeShapeReadingKind = .open,
        title: String,
        summary: String,
        capacityStatement: String,
        sourceDetail: String,
        fallbackState: LifeShapeFallback? = nil,
        accessibilitySummary: String? = nil
    ) {
        self.horizon = horizon
        self.kind = kind
        self.title = title
        self.summary = summary
        self.capacityStatement = capacityStatement
        self.sourceDetail = sourceDetail
        self.fallbackState = fallbackState
        self.accessibilitySummary = accessibilitySummary ?? [
            title,
            capacityStatement,
            summary
        ].filter { $0.isEmpty == false }.joined(separator: ". ")
    }
}
