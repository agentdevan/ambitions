import Foundation

extension ClassificationConfidence {
    var recommendationConfidence: RecommendationConfidence {
        switch self {
        case .low:
            return .low
        case .medium:
            return .medium
        case .high:
            return .high
        }
    }
}
