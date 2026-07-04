import Foundation

extension StepCandidate {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func clamp(_ value: Double, lowerBound: Double = 0, upperBound: Double = 1) -> Double {
        guard upperBound >= lowerBound else { return lowerBound }
        return min(max(value, lowerBound), upperBound)
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }

    static func semanticSignature(
        semanticAnchor: String,
        kind: StepCandidateKind,
        title: String,
        summary: String,
        accessRequirements: [String],
        equipmentRequirements: [String],
        facilityRequirements: [String],
        estimatedMinutes: Int,
        estimatedEnergyCost: Double,
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        approvalRequired: Bool,
        validity: CandidateValidity,
        evidenceFactorIDs: [String]
    ) -> String {
        [
            normalizedSemanticAnchor(semanticAnchor),
            normalizedSemanticAnchor(title),
            normalizedSemanticAnchor(summary),
            kind.rawValue,
            "minutes.\(durationBand(estimatedMinutes))",
            "energy.\(energyBand(estimatedEnergyCost))",
            "goal.\(band(goalContribution))",
            "deadline.\(band(deadlineContribution))",
            "pressure.\(band(futurePressureImpact))",
            "cost.\(band(opportunityCost))",
            approvalRequired ? "approval.required" : "approval.not_required",
            "validity.\(validity.rawValue)",
            "access.\(normalizedSemanticAnchor(accessRequirements.joined(separator: " ")))",
            "equipment.\(normalizedSemanticAnchor(equipmentRequirements.joined(separator: " ")))",
            "facility.\(normalizedSemanticAnchor(facilityRequirements.joined(separator: " ")))",
            evidenceFactorIDs.sorted().joined(separator: ",")
        ]
        .joined(separator: "|")
    }

    static func normalizedSemanticAnchor(_ value: String) -> String {
        let stopWords: Set<String> = [
            "a", "an", "and", "as", "at", "best", "by", "do", "for", "from", "in", "into", "it", "make", "now", "of", "on", "or", "path", "phase", "plan", "step", "the", "to", "today", "try", "up", "version", "work"
        ]

        let tokens = value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false && stopWords.contains($0) == false }

        return tokens.joined(separator: ".")
    }

    static func durationBand(_ value: Int) -> String {
        switch value {
        case ..<6:
            return "micro"
        case ..<12:
            return "short"
        case ..<20:
            return "brief"
        case ..<35:
            return "standard"
        default:
            return "extended"
        }
    }

    static func energyBand(_ value: Double) -> String {
        switch value {
        case ..<0.2:
            return "very_low"
        case ..<0.4:
            return "low"
        case ..<0.6:
            return "moderate"
        case ..<0.8:
            return "high"
        default:
            return "very_high"
        }
    }

    static func band(_ value: Double) -> String {
        switch value {
        case ..<0.2:
            return "very_low"
        case ..<0.4:
            return "low"
        case ..<0.6:
            return "moderate"
        case ..<0.8:
            return "high"
        default:
            return "very_high"
        }
    }

    static func durationScore(for estimatedMinutes: Int, kind: StepCandidateKind) -> Double {
        let base: Double
        switch estimatedMinutes {
        case ..<6:
            base = 1
        case ..<12:
            base = 0.95
        case ..<20:
            base = 0.8
        case ..<35:
            base = 0.65
        default:
            base = 0.45
        }

        switch kind {
        case .shorter, .proofGathering, .fallback:
            return min(1, base + 0.08)
        case .lighter, .lowerEnergy, .maintenance, .parallelPath:
            return min(1, base + 0.03)
        default:
            return base
        }
    }

    static func energyScore(for kind: StepCandidateKind, estimatedEnergyCost: Double) -> Double {
        let baseline = 1 - clamp(estimatedEnergyCost, lowerBound: 0, upperBound: 1)
        switch kind {
        case .lighter, .shorter, .lowerEnergy, .recoverySafe, .fallback:
            return min(1, baseline + 0.1)
        case .maintenance, .proofGathering, .prerequisite:
            return min(1, baseline + 0.04)
        default:
            return baseline
        }
    }

    static func accessScore(
        kind: StepCandidateKind,
        accessRequirements: [String],
        equipmentRequirements: [String],
        facilityRequirements: [String]
    ) -> Double {
        let burden = Double(accessRequirements.count + equipmentRequirements.count + facilityRequirements.count)
        let baseline = clamp(1 - (burden * 0.12), lowerBound: 0, upperBound: 1)
        switch kind {
        case .locationCompatible, .noEquipment, .substitution, .parallelPath, .fallback:
            return min(1, baseline + 0.08)
        case .adminSetup, .maintenance:
            return min(1, baseline + 0.03)
        default:
            return baseline
        }
    }

    static func validityScore(for validity: CandidateValidity) -> Double {
        switch validity {
        case .preferred:
            return 1
        case .review:
            return 0.72
        case .fallback:
            return 0.5
        case .blocked:
            return 0.18
        case .rejected:
            return 0
        }
    }

    static func factorEvidenceScore(for evidenceFactorIDs: [String]) -> Double {
        guard evidenceFactorIDs.isEmpty == false else {
            return 0
        }

        return min(1, Double(evidenceFactorIDs.count) / 5)
    }
}

extension CandidateGenerationContext {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension StepCandidateRejectionReason {
    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension StepCandidateRejectionRecord {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}

extension StepCandidateField {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}

extension CandidateRankingTrace {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}

extension CandidateTradeoff {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }
}

extension CandidateRejectionRisk {
    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }

    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }

    static func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}

extension Array where Element == String {
    func removingDuplicates() -> [String] {
        var seen: Set<String> = []
        return filter { seen.insert($0).inserted }
    }
}
