import Foundation

enum SourceAtlasLocalReferenceCompositionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case staleCritical = "stale_critical"
    case unavailable
    case conflicted
    case revoked
    case unsupported
    case reviewRequired = "review_required"

    var blocksCurrentUse: Bool {
        switch self {
        case .current, .stale:
            false
        case .staleCritical, .unavailable, .conflicted, .revoked, .unsupported, .reviewRequired:
            true
        }
    }
}

enum SourceAtlasLocalReferenceCompositionIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case privateLocalMatchRedacted = "private_local_match_redacted"
    case privatePublicEntityRedacted = "private_public_entity_redacted"
    case noEligiblePublicReference = "no_eligible_public_reference"
    case localFallbackUsed = "local_fallback_used"
    case sourceReviewRequired = "source_review_required"
    case sourceBlocked = "source_blocked"
}

struct SourceAtlasLocalReferenceCompositionProof: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let state: SourceAtlasLocalReferenceCompositionState
    let packID: String?
    let domainID: String?
    let sourceID: String?
    let sourceName: String
    let sourceKind: String
    let referenceTitle: String
    let retrievedLabel: String
    let freshnessLabel: String
    let useLabel: String
    let localMatchLabel: String
    let publicEntityLabel: String
    let localOnlyMatchingStatement: String
    let nonClaim: String
    let caveats: [String]
    let issues: [SourceAtlasLocalReferenceCompositionIssue]
    let publicReferencePackIDs: [String]
    let runtimeOwnsFitTimingPriorityProof: Bool
    let sourceAtlasOwnsFinalUserSteps: Bool
    let createsFinalSchedule: Bool
    let blocksCoreLocalPlanning: Bool
}

struct SourceAtlasLocalReferenceCompositionInput: Sendable, Equatable, Hashable {
    let cacheResolution: SourceAtlasLocalPackCacheResolution
    let fetchResolution: SourceAtlasPublicPackFetchResolution?
    let localMatchLabel: String
    let publicEntityLabel: String?

    init(
        cacheResolution: SourceAtlasLocalPackCacheResolution,
        fetchResolution: SourceAtlasPublicPackFetchResolution? = nil,
        localMatchLabel: String,
        publicEntityLabel: String? = nil
    ) {
        self.cacheResolution = cacheResolution
        self.fetchResolution = fetchResolution
        self.localMatchLabel = localMatchLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.publicEntityLabel = publicEntityLabel?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct SourceAtlasLocalReferenceCompositionProofBuilder: Sendable, Equatable, Hashable {
    func make(_ input: SourceAtlasLocalReferenceCompositionInput) -> SourceAtlasLocalReferenceCompositionProof {
        let cache = input.cacheResolution
        let pack = cache.selectedPack
        let selectedResult = cache.queryResponse.selectedResult
        let source = selectedSource(in: pack, selectedResult: selectedResult)
        let referenceTitle = selectedReferenceTitle(in: pack, selectedResult: selectedResult)
        let state = compositionState(cacheResolution: cache, fetchResolution: input.fetchResolution)
        let localMatch = sanitizedInspectionLabel(
            input.localMatchLabel,
            fallback: "Matched locally on this device",
            issue: .privateLocalMatchRedacted
        )
        let publicEntity = sanitizedInspectionLabel(
            input.publicEntityLabel ?? pack?.manifest.title ?? selectedResult.domainID,
            fallback: "Public reference",
            issue: .privatePublicEntityRedacted
        )
        let issues = orderedIssues(
            localMatch.issues +
                publicEntity.issues +
                compositionIssues(state: state, cacheResolution: cache)
        )
        let fallback = SourceAtlasLocalCompositionFallback().evaluate(cacheResolution: cache)

        return SourceAtlasLocalReferenceCompositionProof(
            id: stableID(
                packID: pack?.id,
                sourceID: source?.id,
                state: state,
                localMatchLabel: localMatch.label,
                publicEntityLabel: publicEntity.label
            ),
            state: state,
            packID: pack?.id,
            domainID: pack?.manifest.domainID ?? selectedResult.domainID,
            sourceID: source?.id,
            sourceName: source?.title ?? "Public reference pack",
            sourceKind: sourceKindLabel(source?.kind),
            referenceTitle: referenceTitle,
            retrievedLabel: source?.retrievedAt ?? "Checked from local reference cache",
            freshnessLabel: freshnessLabel(state: state, cacheResolution: cache),
            useLabel: useLabel(state: state, fallback: fallback),
            localMatchLabel: localMatch.label,
            publicEntityLabel: publicEntity.label,
            localOnlyMatchingStatement: "Matched locally on this device.",
            nonClaim: "Public reference only. This is not a guarantee, professional advice, or a completed plan.",
            caveats: orderedUnique(fallback.caveats + caveats(state: state, cacheResolution: cache)),
            issues: issues,
            publicReferencePackIDs: fallback.publicReferencePackIDs,
            runtimeOwnsFitTimingPriorityProof: true,
            sourceAtlasOwnsFinalUserSteps: false,
            createsFinalSchedule: false,
            blocksCoreLocalPlanning: false
        )
    }
}

private extension SourceAtlasLocalReferenceCompositionProofBuilder {
    func selectedSource(
        in pack: SourceAtlasPack?,
        selectedResult: SourceAtlasQueryResult
    ) -> SourceAtlasSourceRecord? {
        guard let pack else {
            return nil
        }
        return selectedResult.provenanceSourceIDs
            .compactMap { sourceID in pack.sources.first { $0.id == sourceID } }
            .first ?? pack.sources.first
    }

    func selectedReferenceTitle(
        in pack: SourceAtlasPack?,
        selectedResult: SourceAtlasQueryResult
    ) -> String {
        guard let pack else {
            return "Public reference unavailable"
        }
        if let requirementID = selectedResult.requirementID,
           let requirement = pack.requirements.first(where: { $0.id == requirementID }) {
            return requirement.title
        }
        if let claimID = selectedResult.claimID,
           let claim = pack.claims.first(where: { $0.id == claimID }) {
            return claim.text
        }
        return pack.requirements.first?.title ?? pack.claims.first?.text ?? pack.manifest.title
    }

    func compositionState(
        cacheResolution: SourceAtlasLocalPackCacheResolution,
        fetchResolution: SourceAtlasPublicPackFetchResolution?
    ) -> SourceAtlasLocalReferenceCompositionState {
        let cacheIssues = Set(cacheResolution.cacheIssues)
        let requestIssues = Set(cacheResolution.requestIssues)
        let quarantines = cacheResolution.loadResult.quarantines
        let selectedResult = cacheResolution.queryResponse.selectedResult

        if cacheIssues.contains(.revokedByManifest) ||
            quarantines.contains(where: { $0.reason == .revoked }) ||
            selectedResult.sourceState == .revoked ||
            cacheResolution.queryResponse.fallbackReason == .revoked {
            return .revoked
        }
        if cacheIssues.contains(.contradictedByManifest) ||
            quarantines.contains(where: { $0.reason == .contradicted }) ||
            selectedResult.sourceState == .contradicted ||
            cacheResolution.queryResponse.fallbackReason == .contradicted {
            return .conflicted
        }
        if cacheIssues.contains(.staleCriticalByManifest) ||
            quarantines.contains(where: { $0.reason == .staleCritical }) {
            return .staleCritical
        }
        if requestIssues.isEmpty == false ||
            cacheIssues.contains(.manifestVersionMismatch) ||
            cacheIssues.contains(.manifestHashMismatch) ||
            fetchResolution?.fetchIssues.contains(.unsupportedManifestSchema) == true ||
            fetchResolution?.fetchIssues.contains(.unsafePackRequest) == true ||
            fetchResolution?.fetchIssues.contains(.unsafeManifestRequest) == true {
            return .unsupported
        }
        if cacheIssues.contains(.missingManifestEntry) ||
            cacheIssues.contains(.accessBoundaryUnavailable) ||
            cacheIssues.contains(.noEligiblePack) ||
            fetchResolution?.status == .unavailable ||
            cacheResolution.selectedPack == nil {
            return .unavailable
        }
        if selectedResult.reviewState.blocksCurrentProjection ||
            cacheResolution.fallback.selectedReviewState.blocksCurrentProjection ||
            cacheResolution.queryResponse.fallbackReason == .reviewRequired {
            return .reviewRequired
        }
        if cacheIssues.contains(.staleManifest) ||
            cacheResolution.fallback.conditions.contains(.staleCache) ||
            selectedResult.freshnessState == .stale ||
            cacheResolution.queryResponse.fallbackReason == .stale {
            return .stale
        }
        return cacheResolution.canSupportCurrentUse ? .current : .reviewRequired
    }

    func sanitizedInspectionLabel(
        _ value: String,
        fallback: String,
        issue: SourceAtlasLocalReferenceCompositionIssue
    ) -> (label: String, issues: [SourceAtlasLocalReferenceCompositionIssue]) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = trimmed.isEmpty ? fallback : trimmed
        let findings = SourceAtlasNoPrivateGraphEgressAudit.validate([
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .inspectionDetail,
                identifier: "source-atlas-local-reference-composition",
                inspectedValue: candidate
            )
        ])
        guard findings.isEmpty else {
            return (fallback, [issue])
        }
        return (candidate, [])
    }

    func compositionIssues(
        state: SourceAtlasLocalReferenceCompositionState,
        cacheResolution: SourceAtlasLocalPackCacheResolution
    ) -> [SourceAtlasLocalReferenceCompositionIssue] {
        var issues: [SourceAtlasLocalReferenceCompositionIssue] = []
        if cacheResolution.selectedPack == nil {
            issues.append(.noEligiblePublicReference)
        }
        if cacheResolution.cacheIssues.contains(.localFallbackUsed) ||
            cacheResolution.fallback.conditions.isEmpty == false {
            issues.append(.localFallbackUsed)
        }
        if state == .reviewRequired {
            issues.append(.sourceReviewRequired)
        }
        if state.blocksCurrentUse {
            issues.append(.sourceBlocked)
        }
        return issues
    }

    func sourceKindLabel(_ kind: SourceAtlasSourceKind?) -> String {
        switch kind {
        case .official:
            "Official public reference"
        case .semiOfficial:
            "Semi-official public reference"
        case .expert:
            "Expert public reference"
        case .community:
            "Community public reference"
        case .maintainerCurated:
            "Curated public reference"
        case .candidate:
            "Candidate public reference"
        case .userProvided:
            "Local user-provided reference"
        case .internalMarker:
            "Internal marker"
        case .unknown, nil:
            "Public reference"
        }
    }

    func freshnessLabel(
        state: SourceAtlasLocalReferenceCompositionState,
        cacheResolution: SourceAtlasLocalPackCacheResolution
    ) -> String {
        switch state {
        case .current:
            "Current public reference."
        case .stale:
            "Older public reference; confirm before it changes behavior."
        case .staleCritical:
            "Too old to use for current behavior."
        case .unavailable:
            "Reference unavailable; local planning continues."
        case .conflicted:
            "Conflicting public references need review."
        case .revoked:
            "Reference has been withdrawn."
        case .unsupported:
            "Reference cannot be used here."
        case .reviewRequired:
            "Reference needs review before use."
        }
    }

    func useLabel(
        state: SourceAtlasLocalReferenceCompositionState,
        fallback: SourceAtlasLocalCompositionFallbackResult
    ) -> String {
        switch state {
        case .current:
            "Use as public context only; Ambitions keeps fit, timing, and priority local."
        case .stale:
            "Use as older context only; do not let it silently change current behavior."
        case .staleCritical:
            "Cannot guide current behavior until refreshed."
        case .unavailable:
            "Cannot guide current behavior right now; local starter planning remains available."
        case .conflicted:
            "Cannot guide current behavior until the conflict is reviewed."
        case .revoked:
            "Cannot guide current behavior because the reference was withdrawn."
        case .unsupported:
            "Cannot guide current behavior in this form."
        case .reviewRequired:
            "Cannot guide current behavior until reviewed."
        }
    }

    func caveats(
        state: SourceAtlasLocalReferenceCompositionState,
        cacheResolution: SourceAtlasLocalPackCacheResolution
    ) -> [String] {
        var caveats: [String] = []
        if state.blocksCurrentUse {
            caveats.append("This reference cannot guide current behavior.")
        }
        if cacheResolution.loadResult.selectedSource == .lastKnownGood {
            caveats.append("Using last verified public reference.")
        }
        if cacheResolution.loadResult.quarantines.isEmpty == false {
            caveats.append("Unsafe public reference artifacts were blocked.")
        }
        return caveats
    }

    func stableID(
        packID: String?,
        sourceID: String?,
        state: SourceAtlasLocalReferenceCompositionState,
        localMatchLabel: String,
        publicEntityLabel: String
    ) -> String {
        CandidateSource.stableIdentifier(
            prefix: "source-atlas.local-reference-composition",
            components: [
                packID ?? "no-pack",
                sourceID ?? "no-source",
                state.rawValue,
                localMatchLabel,
                publicEntityLabel
            ]
        )
    }

    func orderedIssues(
        _ issues: [SourceAtlasLocalReferenceCompositionIssue]
    ) -> [SourceAtlasLocalReferenceCompositionIssue] {
        SourceAtlasLocalReferenceCompositionIssue.allCases.filter { issues.contains($0) }
    }

    func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
