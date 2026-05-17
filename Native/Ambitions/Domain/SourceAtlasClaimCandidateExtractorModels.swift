import Foundation

let sourceAtlasClaimCandidateExtractorSchemaVersion = "source_atlas_claim_candidate_extractor.native.v1"

enum SourceAtlasClaimCandidateKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case requirement
    case deadline
    case equipment
    case prerequisite
    case proof
    case unknown
    case warning
}

enum SourceAtlasClaimCandidateSignal: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case requirement
    case deadline
    case equipment
    case prerequisite
    case proof
    case unknown
    case warning
}

struct SourceAtlasClaimCandidateLocatorHint: Codable, Sendable, Equatable, Hashable {
    let sourceLocator: String?
    let pageNumber: Int?
    let lineNumber: Int?
    let pageLocator: String?
    let lineLocator: String?

    init(
        sourceLocator: String?,
        pageNumber: Int?,
        lineNumber: Int?,
        pageLocator: String?,
        lineLocator: String?
    ) {
        self.sourceLocator = Self.trimmedOptional(sourceLocator)
        self.pageNumber = pageNumber
        self.lineNumber = lineNumber
        self.pageLocator = Self.trimmedOptional(pageLocator)
        self.lineLocator = Self.trimmedOptional(lineLocator)
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

struct SourceAtlasClaimCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: SourceAtlasClaimCandidateKind
    let signal: SourceAtlasClaimCandidateSignal
    let text: String
    let normalizedText: String
    let title: String?
    let sourceLocator: String?
    let locatorHint: SourceAtlasClaimCandidateLocatorHint
    let documentType: SourceAtlasDocumentType?
    let riskClass: SourceAtlasRiskClass
    let sourceKind: SourceAtlasSourceKind
    let provenanceState: SourceAtlasSourceContainerProvenanceState
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let reviewState: HumanProgressReviewState
    let reviewRequired: Bool
    let isExplicitProofCandidate: Bool
    let schemaVersion: String
}

struct SourceAtlasClaimCandidateExtractionBehavior: Codable, Sendable, Equatable, Hashable {
    let performsNetworkAccess: Bool
    let persistsState: Bool
    let mutatesState: Bool
    let makesReleaseClaims: Bool

    static let valueModelOnly = SourceAtlasClaimCandidateExtractionBehavior(
        performsNetworkAccess: false,
        persistsState: false,
        mutatesState: false,
        makesReleaseClaims: false
    )
}

struct SourceAtlasClaimCandidateExtractionInput: Codable, Sendable, Equatable, Hashable {
    let title: String?
    let bodyText: String
    let sourceLocator: String?
    let documentClassifierDecision: SourceAtlasDocumentTypeClassifierDecision?

    init(
        title: String? = nil,
        bodyText: String,
        sourceLocator: String? = nil,
        documentClassifierDecision: SourceAtlasDocumentTypeClassifierDecision? = nil
    ) {
        self.title = Self.trimmedOptional(title)
        self.bodyText = bodyText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLocator = Self.trimmedOptional(sourceLocator)
        self.documentClassifierDecision = documentClassifierDecision
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedValue.isEmpty ? nil : trimmedValue
    }
}

struct SourceAtlasClaimCandidateExtraction: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String?
    let bodyText: String
    let sourceLocator: String?
    let documentType: SourceAtlasDocumentType?
    let riskClass: SourceAtlasRiskClass
    let sourceKind: SourceAtlasSourceKind
    let provenanceState: SourceAtlasSourceContainerProvenanceState
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let reviewState: HumanProgressReviewState
    let reviewRequired: Bool
    let candidates: [SourceAtlasClaimCandidate]
    let behavior: SourceAtlasClaimCandidateExtractionBehavior
    let schemaVersion: String

    var hasCandidatesRequiringReview: Bool {
        candidates.contains(where: \.reviewRequired)
    }
}

struct SourceAtlasClaimCandidateExtractor: Sendable, Equatable, Hashable {
    func extract(_ input: SourceAtlasClaimCandidateExtractionInput) -> SourceAtlasClaimCandidateExtraction {
        let sourceLocatorHint = Self.locatorHint(for: input.sourceLocator)
        let bodyClauses = Self.bodyClauses(for: input.bodyText, title: input.title)
        let documentContext = Self.documentContext(for: input.documentClassifierDecision, sourceLocator: input.sourceLocator)
        let candidates = Self.candidates(
            from: bodyClauses,
            title: input.title,
            sourceLocator: input.sourceLocator,
            locatorHint: sourceLocatorHint,
            documentContext: documentContext
        )
        let reviewRequired = candidates.contains(where: \.reviewRequired)

        return SourceAtlasClaimCandidateExtraction(
            id: Self.deterministicID(
                seed: [
                    input.title ?? "",
                    input.bodyText,
                    input.sourceLocator ?? "",
                    input.documentClassifierDecision?.documentType.rawValue ?? "none"
                ].joined(separator: "\u{1f}")
            ),
            title: input.title,
            bodyText: input.bodyText,
            sourceLocator: input.sourceLocator,
            documentType: documentContext.documentType,
            riskClass: documentContext.riskClass,
            sourceKind: documentContext.sourceKind,
            provenanceState: documentContext.provenanceState,
            sourceState: documentContext.sourceState,
            freshnessState: documentContext.freshnessState,
            reviewState: reviewRequired ? .needsSourceReview : .ready,
            reviewRequired: reviewRequired,
            candidates: candidates,
            behavior: .valueModelOnly,
            schemaVersion: sourceAtlasClaimCandidateExtractorSchemaVersion
        )
    }

    private struct DocumentContext: Sendable, Equatable, Hashable {
        let documentType: SourceAtlasDocumentType?
        let riskClass: SourceAtlasRiskClass
        let sourceKind: SourceAtlasSourceKind
        let provenanceState: SourceAtlasSourceContainerProvenanceState
        let sourceState: SourceAtlasRequirementSourceState
        let freshnessState: SourceAtlasFreshnessState
        let reviewState: HumanProgressReviewState
        let allowsReadyProofCandidate: Bool
        let allowsLocalProofCandidate: Bool
    }

    private static func documentContext(
        for decision: SourceAtlasDocumentTypeClassifierDecision?,
        sourceLocator: String?
    ) -> DocumentContext {
        guard let decision else {
            return DocumentContext(
                documentType: nil,
                riskClass: .lowRiskSkill,
                sourceKind: .candidate,
                provenanceState: sourceLocator == nil ? .copiedContent : .sourceAttached,
                sourceState: .sourceNeeded,
                freshnessState: .unknown,
                reviewState: .needsSourceReview,
                allowsReadyProofCandidate: false,
                allowsLocalProofCandidate: false
            )
        }

        return DocumentContext(
            documentType: decision.documentType,
            riskClass: decision.riskClass,
            sourceKind: decision.sourceKindRecommendation,
            provenanceState: decision.provenanceRecommendation,
            sourceState: decision.requirementSourceState,
            freshnessState: decision.freshnessState,
            reviewState: decision.reviewState,
            allowsReadyProofCandidate: decision.claimBoundary.canSupportOfficialCurrentClaim &&
                decision.reviewState == .ready,
            allowsLocalProofCandidate: decision.claimBoundary.canSupportLocalProofClaim &&
                decision.reviewState == .ready
        )
    }

    private static func candidates(
        from bodyClauses: [String],
        title: String?,
        sourceLocator: String?,
        locatorHint: SourceAtlasClaimCandidateLocatorHint,
        documentContext: DocumentContext
    ) -> [SourceAtlasClaimCandidate] {
        var candidates: [SourceAtlasClaimCandidate] = []
        var seen: Set<String> = []

        for (index, clause) in bodyClauses.enumerated() {
            let signals = Self.signals(in: clause)
            if signals.isEmpty {
                let candidate = Self.makeUnknownCandidate(
                    text: clause,
                    title: title,
                    sourceLocator: sourceLocator,
                    locatorHint: locatorHint,
                    clauseIndex: index,
                    documentContext: documentContext
                )
                let dedupKey = [
                    candidate.kind.rawValue,
                    candidate.normalizedText,
                    candidate.locatorHint.sourceLocator ?? "",
                    candidate.locatorHint.pageLocator ?? "",
                    candidate.locatorHint.lineLocator ?? ""
                ].joined(separator: "\u{1f}")
                if seen.insert(dedupKey).inserted {
                    candidates.append(candidate)
                }
                continue
            }

            for signal in signals {
                let candidate = Self.makeCandidate(
                    clause: clause,
                    title: title,
                    sourceLocator: sourceLocator,
                    locatorHint: locatorHint,
                    signal: signal,
                    clauseIndex: index,
                    documentContext: documentContext
                )
                let dedupKey = [
                    candidate.kind.rawValue,
                    candidate.normalizedText,
                    candidate.locatorHint.sourceLocator ?? "",
                    candidate.locatorHint.pageLocator ?? "",
                    candidate.locatorHint.lineLocator ?? ""
                ].joined(separator: "\u{1f}")
                if seen.insert(dedupKey).inserted {
                    candidates.append(candidate)
                }
            }
        }

        if candidates.isEmpty {
            candidates.append(
                Self.makeUnknownCandidate(
                    title: title,
                    sourceLocator: sourceLocator,
                    locatorHint: locatorHint,
                    documentContext: documentContext
                )
            )
        }

        return candidates.sorted { lhs, rhs in
            if lhs.kind != rhs.kind {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            if lhs.normalizedText != rhs.normalizedText {
                return lhs.normalizedText < rhs.normalizedText
            }
            return lhs.id < rhs.id
        }
    }

    private static func makeCandidate(
        clause: String,
        title: String?,
        sourceLocator: String?,
        locatorHint: SourceAtlasClaimCandidateLocatorHint,
        signal: SourceAtlasClaimCandidateSignal,
        clauseIndex: Int,
        documentContext: DocumentContext
    ) -> SourceAtlasClaimCandidate {
        let normalizedClause = Self.normalizedText(clause)
        let normalizedClauseForSignals = normalizedClause.lowercased()
        let explicitProofAllowed = signal == .proof &&
            Self.isExplicitProofAllowed(
                clause: normalizedClauseForSignals,
                documentContext: documentContext
            )

        let sourceState = Self.sourceState(
            for: signal,
            explicitProofAllowed: explicitProofAllowed,
            clause: normalizedClauseForSignals,
            documentContext: documentContext
        )
        let freshnessState = Self.freshnessState(
            for: signal,
            explicitProofAllowed: explicitProofAllowed,
            clause: normalizedClauseForSignals,
            documentContext: documentContext
        )
        let provenanceState = Self.provenanceState(
            for: signal,
            explicitProofAllowed: explicitProofAllowed,
            documentContext: documentContext
        )
        let sourceKind = Self.sourceKind(
            for: signal,
            explicitProofAllowed: explicitProofAllowed,
            documentContext: documentContext
        )
        let reviewState = Self.reviewState(
            for: signal,
            explicitProofAllowed: explicitProofAllowed,
            sourceState: sourceState,
            freshnessState: freshnessState,
            documentContext: documentContext
        )

        return SourceAtlasClaimCandidate(
            id: Self.deterministicID(
                seed: [
                    signal.rawValue,
                    String(clauseIndex),
                    normalizedClause,
                    sourceLocator ?? "",
                    locatorHint.pageLocator ?? "",
                    locatorHint.lineLocator ?? ""
                ].joined(separator: "\u{1f}")
            ),
            kind: Self.kind(for: signal),
            signal: signal,
            text: normalizedClause,
            normalizedText: normalizedClause,
            title: title,
            sourceLocator: sourceLocator,
            locatorHint: locatorHint,
            documentType: documentContext.documentType,
            riskClass: documentContext.riskClass,
            sourceKind: sourceKind,
            provenanceState: provenanceState,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            reviewRequired: reviewState.blocksAutomaticMutation,
            isExplicitProofCandidate: explicitProofAllowed,
            schemaVersion: sourceAtlasClaimCandidateExtractorSchemaVersion
        )
    }

    private static func makeUnknownCandidate(
        text: String? = nil,
        title: String?,
        sourceLocator: String?,
        locatorHint: SourceAtlasClaimCandidateLocatorHint,
        clauseIndex: Int? = nil,
        documentContext: DocumentContext
    ) -> SourceAtlasClaimCandidate {
        let text = Self.normalizedText(text ?? title ?? sourceLocator ?? "unknown claim candidate")
        return SourceAtlasClaimCandidate(
            id: Self.deterministicID(
                seed: [
                    "unknown",
                    clauseIndex.map(String.init) ?? "",
                    text,
                    sourceLocator ?? "",
                    locatorHint.pageLocator ?? "",
                    locatorHint.lineLocator ?? ""
                ].joined(separator: "\u{1f}")
            ),
            kind: .unknown,
            signal: .unknown,
            text: text,
            normalizedText: text,
            title: title,
            sourceLocator: sourceLocator,
            locatorHint: locatorHint,
            documentType: documentContext.documentType,
            riskClass: documentContext.riskClass,
            sourceKind: documentContext.sourceKind,
            provenanceState: documentContext.provenanceState,
            sourceState: .unknown,
            freshnessState: .unknown,
            reviewState: .needsSourceReview,
            reviewRequired: true,
            isExplicitProofCandidate: false,
            schemaVersion: sourceAtlasClaimCandidateExtractorSchemaVersion
        )
    }

    private static func kind(for signal: SourceAtlasClaimCandidateSignal) -> SourceAtlasClaimCandidateKind {
        switch signal {
        case .requirement:
            return .requirement
        case .deadline:
            return .deadline
        case .equipment:
            return .equipment
        case .prerequisite:
            return .prerequisite
        case .proof:
            return .proof
        case .unknown:
            return .unknown
        case .warning:
            return .warning
        }
    }

    private static func sourceKind(
        for signal: SourceAtlasClaimCandidateSignal,
        explicitProofAllowed: Bool,
        documentContext: DocumentContext
    ) -> SourceAtlasSourceKind {
        guard signal == .proof, explicitProofAllowed else {
            return documentContext.sourceKind
        }

        if documentContext.allowsReadyProofCandidate {
            return .official
        }
        if documentContext.allowsLocalProofCandidate {
            return .userProvided
        }
        return documentContext.sourceKind
    }

    private static func provenanceState(
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

    private static func sourceState(
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

    private static func freshnessState(
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

    private static func reviewState(
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

    private static func isExplicitProofAllowed(
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

    private static func signals(in clause: String) -> [SourceAtlasClaimCandidateSignal] {
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

    private static func containsRequirementSignal(_ text: String) -> Bool {
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

    private static func containsDeadlineSignal(_ text: String) -> Bool {
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

    private static func containsEquipmentSignal(_ text: String) -> Bool {
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

    private static func containsPrerequisiteSignal(_ text: String) -> Bool {
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

    private static func containsProofSignal(_ text: String) -> Bool {
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

    private static func containsWarningSignal(_ text: String) -> Bool {
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

    private static func containsTemporalSignal(_ text: String) -> Bool {
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

    private static func containsAny(_ text: String, _ needles: [String]) -> Bool {
        needles.contains { text.contains($0) }
    }

    private static func normalizedText(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\r\n", with: "\n")
            .replacingOccurrences(of: "\r", with: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func bodyClauses(for bodyText: String, title: String?) -> [String] {
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

    private static func locatorHint(for sourceLocator: String?) -> SourceAtlasClaimCandidateLocatorHint {
        guard let sourceLocator else {
            return SourceAtlasClaimCandidateLocatorHint(
                sourceLocator: nil,
                pageNumber: nil,
                lineNumber: nil,
                pageLocator: nil,
                lineLocator: nil
            )
        }

        let lowercased = sourceLocator.lowercased()
        let pageNumber = Self.firstCapturedInteger(
            in: lowercased,
            pattern: #"page\s*[:.]?\s*(\d+)"#
        ) ?? Self.firstCapturedInteger(
            in: lowercased,
            pattern: #"\bp\.\s*(\d+)"#
        )
        let lineNumber = Self.firstCapturedInteger(
            in: lowercased,
            pattern: #"lines?\s*[:.]?\s*(\d+)"#
        )

        return SourceAtlasClaimCandidateLocatorHint(
            sourceLocator: sourceLocator,
            pageNumber: pageNumber,
            lineNumber: lineNumber,
            pageLocator: pageNumber.map { "page:\($0)" },
            lineLocator: lineNumber.map { "line:\($0)" }
        )
    }

    private static func firstCapturedInteger(in text: String, pattern: String) -> Int? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range), match.numberOfRanges > 1 else {
            return nil
        }
        let capturedRange = match.range(at: 1)
        guard let swiftRange = Range(capturedRange, in: text) else {
            return nil
        }
        return Int(text[swiftRange])
    }

    private static func deterministicID(seed: String) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in seed.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return String(format: "fnv1a64:%016llx", hash)
    }
}
