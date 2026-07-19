import Foundation

extension AnyGoalCoverageInput {
    static func normalizedDomain(_ value: String) -> String {
        let normalized = value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "_")
        return normalized.isEmpty ? "general" : normalized
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let normalized = normalizedDomain(value)
        return normalized == "general" ? nil : normalized
    }

    static func ordered(_ values: [CoverageNeedMissingSourceType]) -> [CoverageNeedMissingSourceType] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }

    static func ordered(_ values: [CoverageNeedSeedGapCategory]) -> [CoverageNeedSeedGapCategory] {
        Array(Set(values)).sorted { $0.rawValue < $1.rawValue }
    }
}

extension CoverageSourceArrivalSignal {
    static func normalizedDomain(_ value: String) -> String {
        AnyGoalCoverageInput.normalizedDomain(value)
    }

    static func ordered(_ values: [CoverageNeedMissingSourceType]) -> [CoverageNeedMissingSourceType] {
        AnyGoalCoverageInput.ordered(values)
    }

    static func ordered(_ values: [CoverageNeedSeedGapCategory]) -> [CoverageNeedSeedGapCategory] {
        AnyGoalCoverageInput.ordered(values)
    }
}
