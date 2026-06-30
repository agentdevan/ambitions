import Foundation

extension SourceAtlasClaimCandidateExtractor {

    static func provenanceState(
        for signal: SourceAtlasClaimCandidateSignal,
        explicitProofAllowed: Bool,
        documentContext: DocumentContext
    ) -> SourceAtlasSourceContainerProvenanceState {
        guard signal == .proof, explicitProofAllowed else {
            return documentContext.provenanceState
        }

        if documentContext.allowsReadyProofCandidate {
            return .approvedOfficial
        }
        if documentContext.allowsLocalProofCandidate {
            return .localFile
        }
        return documentContext.provenanceState
    }


    static func sourceState(
        for signal: SourceAtlasClaimCandidateSignal,
        explicitProofAllowed: Bool,
        clause: String,
        documentContext: DocumentContext
    ) -> SourceAtlasRequirementSourceState {
        switch signal {
        case .warning:
            if Self.containsAny(clause, ["revoked", "withdrawn", "rescinded"]) {
                return .revoked
            }
            if Self.containsAny(clause, ["contradicted", "conflicts with", "inconsistent", "retracted"]) {
                return .contradicted
            }
            if Self.containsAny(clause, ["stale", "archived", "outdated", "expired", "superseded", "older version"]) {
                return .stale
            }
            return documentContext.sourceState
        case .unknown:
            return .unknown
        case .proof where explicitProofAllowed:
            if documentContext.allowsReadyProofCandidate {
                return .officialCurrent
            }
            if documentContext.allowsLocalProofCandidate {
                return .locallyProven
            }
            return documentContext.sourceState
        default:
            return .sourceNeeded
        }
    }


    static func freshnessState(
        for signal: SourceAtlasClaimCandidateSignal,
        explicitProofAllowed: Bool,
        clause: String,
        documentContext: DocumentContext
    ) -> SourceAtlasFreshnessState {
        switch signal {
        case .warning:
            if Self.containsAny(clause, ["revoked", "withdrawn", "rescinded"]) {
                return .revoked
            }
            if Self.containsAny(clause, ["contradicted", "conflicts with", "inconsistent", "retracted"]) {
                return .disputed
            }
            if Self.containsAny(clause, ["stale", "archived", "outdated", "expired", "superseded", "older version"]) {
                return .stale
            }
            return .unknown
        case .unknown:
            return .unknown
        case .proof where explicitProofAllowed:
            return documentContext.freshnessState
        default:
            return .needsReview
        }
    }


    static func reviewState(
        for signal: SourceAtlasClaimCandidateSignal,
        explicitProofAllowed: Bool,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasFreshnessState,
        documentContext: DocumentContext
    ) -> HumanProgressReviewState {
        guard signal == .proof, explicitProofAllowed else {
            return .needsSourceReview
        }

        if documentContext.allowsReadyProofCandidate,
           sourceState == .officialCurrent,
           freshnessState == .current {
            return .ready
        }
        if documentContext.allowsLocalProofCandidate,
           sourceState == .locallyProven {
            return .ready
        }
        return .needsSourceReview
    }


    static func isExplicitProofAllowed(
        clause: String,
        documentContext: DocumentContext
    ) -> Bool {
        guard documentContext.allowsReadyProofCandidate || documentContext.allowsLocalProofCandidate else {
            return false
        }
        guard Self.containsProofSignal(clause) else {
            return false
        }
        if Self.containsAny(clause, ["revoked", "withdrawn", "rescinded", "contradicted", "retracted", "stale", "outdated", "superseded"]) {
            return false
        }
        return true
    }


    static func signals(in clause: String) -> [SourceAtlasClaimCandidateSignal] {
        var signals: [SourceAtlasClaimCandidateSignal] = []
        let lowercased = clause.lowercased()

        if Self.containsRequirementSignal(lowercased) {
            signals.append(.requirement)
        }
        if Self.containsDeadlineSignal(lowercased) {
            signals.append(.deadline)
        }
        if Self.containsEquipmentSignal(lowercased) {
            signals.append(.equipment)
        }
        if Self.containsPrerequisiteSignal(lowercased) {
            signals.append(.prerequisite)
        }
        if Self.containsProofSignal(lowercased) {
            signals.append(.proof)
        }
        if Self.containsWarningSignal(lowercased) {
            signals.append(.warning)
        }

        return signals
    }


    static func containsRequirementSignal(_ text: String) -> Bool {
        containsAny(text, [
            "must",
            "required",
            "required to",
            "need to",
            "needs to",
            "shall",
            "mandatory",
            "requirements",
            "requires",
            "requirement"
        ])
    }


    static func containsDeadlineSignal(_ text: String) -> Bool {
        if containsAny(text, [
            "deadline",
            "due",
            "before",
            "until",
            "expires",
            "expiration",
            "renew by",
            "application window",
            "submit by"
        ]) {
            return true
        }
        if text.contains("by ") && containsTemporalSignal(text) {
            return true
        }
        return false
    }


    static func containsEquipmentSignal(_ text: String) -> Bool {
        containsAny(text, [
            "equipment",
            "gear",
            "uniform",
            "materials",
            "supplies",
            "device",
            "devices",
            "tool",
            "tools",
            "laptop",
            "helmet",
            "shoes",
            "gloves"
        ])
    }


    static func containsPrerequisiteSignal(_ text: String) -> Bool {
        containsAny(text, [
            "prerequisite",
            "before you can",
            "before applying",
            "prior to",
            "must complete",
            "complete first",
            "completion required",
            "already have",
            "eligible after"
        ])
    }


    static func containsProofSignal(_ text: String) -> Bool {
        containsAny(text, [
            "proof",
            "evidence",
            "receipt",
            "verification",
            "verified",
            "documented",
            "source",
            "citation",
            "official record",
            "current as of",
            "published",
            "effective date",
            "certificate",
            "transcript"
        ])
    }


    static func containsWarningSignal(_ text: String) -> Bool {
        containsAny(text, [
            "warning",
            "caution",
            "important",
            "note",
            "may change",
            "subject to change",
            "not valid",
            "revoked",
            "withdrawn",
            "rescinded",
            "stale",
            "outdated",
            "archived",
            "superseded",
            "conflicts with",
            "contradicted",
            "retracted",
            "expired"
        ])
    }


    static func containsTemporalSignal(_ text: String) -> Bool {
        containsAny(text, [
            "monday",
            "tuesday",
            "wednesday",
            "thursday",
            "friday",
            "saturday",
            "sunday",
            "january",
            "february",
            "march",
            "april",
            "may",
            "june",
            "july",
            "august",
            "september",
            "october",
            "november",
            "december"
        ]) || text.range(of: #"\b\d{1,2}/\d{1,2}(/\d{2,4})?\b"#, options: .regularExpression) != nil
    }


    static func containsAny(_ text: String, _ needles: [String]) -> Bool {
        needles.contains { text.contains($0) }
    }


    static func normalizedText(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }


    static func bodyClauses(for bodyText: String, title: String?) -> [String] {
        let sourceText = bodyText.isEmpty ? (title ?? "") : bodyText
        let normalized = normalizedText(sourceText)
        guard normalized.isEmpty == false else {
            return []
        }

        let parts = normalized
            .components(separatedBy: .whitespacesAndNewlines)
            .joined(separator: " ")
            .components(separatedBy: CharacterSet(charactersIn: ".!?;\n"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }

        if parts.isEmpty {
            return [normalized]
        }

        return parts
    }
}
