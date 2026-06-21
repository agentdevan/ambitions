import Foundation

enum LifeShapeConfidenceLevel: String, Sendable, CaseIterable, Hashable {
    case unavailable
    case low
    case partial
    case grounded
}

struct LifeShapeConfidence: Sendable, Hashable {
    let level: LifeShapeConfidenceLevel
    let explanation: String

    init(level: LifeShapeConfidenceLevel, explanation: String) {
        self.level = level
        self.explanation = explanation.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static let unavailable = LifeShapeConfidence(
        level: .unavailable,
        explanation: "Not enough local context is available yet."
    )
}
