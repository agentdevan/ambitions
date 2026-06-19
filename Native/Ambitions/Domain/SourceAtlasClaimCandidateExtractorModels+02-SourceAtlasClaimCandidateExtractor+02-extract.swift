import Foundation

extension SourceAtlasClaimCandidateExtractor {
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


    struct DocumentContext: Sendable, Equatable, Hashable {
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


    static func documentContext(
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


    static func candidates(
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


    static func makeCandidate(
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


    static func makeUnknownCandidate(
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


    static func kind(for signal: SourceAtlasClaimCandidateSignal) -> SourceAtlasClaimCandidateKind {
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


    static func sourceKind(
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
}
