import Foundation

let ambitionsOSRecommendationStartHereSchemaVersion = "ambitionsos_recommendation_start_here.native.v1"

enum AmbitionsOSStartHereRecommendationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case startHere = "start_here"
    case recommendedStep = "recommended_step"
    case sourceCheck = "source_check"
    case proofReview = "proof_review"
    case clarification
    case recovery
    case stillCounts = "still_counts"
    case reviewLater = "review_later"
}

enum AmbitionsOSStartHereControlAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case start
    case open
    case adjust
    case makeSmaller = "make_smaller"
    case reviewLater = "review_later"
    case notNow = "not_now"
    case explainMore = "explain_more"
}

enum AmbitionsOSRecommendationFitState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fits
    case reviewable
    case sourceNeeded = "source_needed"
    case proofNeeded = "proof_needed"
    case blocked
}

enum AmbitionsOSRecommendationStartHereIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedRecommendation = "malformed_recommendation"
    case missingSourceLabel = "missing_source_label"
    case sourceReviewRequired = "source_review_required"
    case staleSourceReviewRequired = "stale_source_review_required"
    case proofTrustReviewRequired = "proof_trust_review_required"
    case controlPlaneBlocksRecommendation = "control_plane_blocks_recommendation"
    case missingExplanation = "missing_explanation"
    case missingUserControl = "missing_user_control"
    case missingReceiptBehavior = "missing_receipt_behavior"
    case genericPriorityOnly = "generic_priority_only"
    case confidenceScoreExposed = "confidence_score_exposed"
    case guaranteedOutcomeLanguage = "guaranteed_outcome_language"
    case harmfulRecommendationLanguage = "harmful_recommendation_language"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case privateExternalProjectionRisk = "private_external_projection_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSStartHereRecommendation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let kind: AmbitionsOSStartHereRecommendationKind
    let surface: AmbitionsOSControlPlaneSurface
    let recommendedObjectID: String
    let sourceLabel: String
    let sourceClaims: [AmbitionsOSSourceTruthClaim]
    let proofTrustReceipts: [AmbitionsOSProofTrustReceipt]
    let controlClassification: AmbitionsOSControlPlaneClassification
    let fitState: AmbitionsOSRecommendationFitState
    let whyNow: [String]
    let advances: [String]
    let protects: [String]
    let assumptions: [String]
    let notChosen: [String]
    let controlActions: [AmbitionsOSStartHereControlAction]
    let exposesConfidenceScore: Bool
    let usesGenericPriorityOnly: Bool
    let claimsGuaranteedOutcome: Bool
    let mutatesPlansAutomatically: Bool
    let privacyClass: HumanProgressPrivacyClass
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        title: String,
        kind: AmbitionsOSStartHereRecommendationKind,
        surface: AmbitionsOSControlPlaneSurface,
        recommendedObjectID: String,
        sourceLabel: String,
        sourceClaims: [AmbitionsOSSourceTruthClaim],
        proofTrustReceipts: [AmbitionsOSProofTrustReceipt],
        controlClassification: AmbitionsOSControlPlaneClassification,
        fitState: AmbitionsOSRecommendationFitState,
        whyNow: [String],
        advances: [String] = [],
        protects: [String] = [],
        assumptions: [String] = [],
        notChosen: [String] = [],
        controlActions: [AmbitionsOSStartHereControlAction],
        exposesConfidenceScore: Bool = false,
        usesGenericPriorityOnly: Bool = false,
        claimsGuaranteedOutcome: Bool = false,
        mutatesPlansAutomatically: Bool = false,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSRecommendationStartHereSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.surface = surface
        self.recommendedObjectID = recommendedObjectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLabel = sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceClaims = sourceClaims
        self.proofTrustReceipts = proofTrustReceipts
        self.controlClassification = controlClassification
        self.fitState = fitState
        self.whyNow = Self.orderedUnique(whyNow)
        self.advances = Self.orderedUnique(advances)
        self.protects = Self.orderedUnique(protects)
        self.assumptions = Self.orderedUnique(assumptions)
        self.notChosen = Self.orderedUnique(notChosen)
        self.controlActions = Array(Set(controlActions)).sorted { $0.rawValue < $1.rawValue }
        self.exposesConfidenceScore = exposesConfidenceScore
        self.usesGenericPriorityOnly = usesGenericPriorityOnly
        self.claimsGuaranteedOutcome = claimsGuaranteedOutcome
        self.mutatesPlansAutomatically = mutatesPlansAutomatically
        self.privacyClass = privacyClass
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            recommendedObjectID.isEmpty == false &&
            schemaVersion == ambitionsOSRecommendationStartHereSchemaVersion
    }

    var hasPlainExplanation: Bool {
        whyNow.isEmpty == false &&
            (advances.isEmpty == false || protects.isEmpty == false || assumptions.isEmpty == false)
    }

    var hasUserControl: Bool {
        controlActions.isEmpty == false
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    static func sourceClaim(
        from result: SourceAtlasQueryResult,
        text: String,
        lastReviewedAt: String? = nil
    ) -> AmbitionsOSSourceTruthClaim {
        AmbitionsOSSourceTruthClaim(
            id: "source-atlas.\(result.id)",
            text: text,
            scopeID: result.requirementID ?? result.claimID ?? result.domainID,
            state: sourceTruthClaimState(for: result),
            sourceQualityState: sourceQualityState(for: result),
            freshnessState: freshnessState(for: result),
            riskClass: result.riskClass ?? .careerContext,
            sourceIDs: result.provenanceSourceIDs,
            sourcePackIDs: [result.packID],
            reviewState: reviewState(for: result),
            lastReviewedAt: lastReviewedAt
        )
    }

    static func fitState(for result: SourceAtlasQueryResult) -> AmbitionsOSRecommendationFitState {
        if result.canSupportCurrentUse {
            return .fits
        }

        switch result.fallbackReason {
        case .sourceNeeded, .provenanceMissing, .noLoadedPacks, .noMatchingCandidate, .noCurrentCandidate:
            return .sourceNeeded
        case .stale, .reviewRequired, .unknown:
            return .reviewable
        case .contradicted, .revoked:
            return .blocked
        case .none:
            return .reviewable
        }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    private static func sourceTruthClaimState(for result: SourceAtlasQueryResult) -> AmbitionsOSSourceTruthClaimState {
        switch result.sourceState {
        case .officialCurrent:
            return result.canSupportCurrentUse ? .officialSourceBacked : .sourcedSourceBacked
        case .current, .official:
            return .sourcedSourceBacked
        case .locallyProven:
            return .verifiedByLocalProof
        case .sourceNeeded:
            return .sourceNeeded
        case .stale:
            return .stale
        case .contradicted:
            return .contradicted
        case .revoked:
            return .revoked
        case .unknown:
            return .unknown
        }
    }

    private static func sourceQualityState(for result: SourceAtlasQueryResult) -> AmbitionsOSSourceQualityState {
        result.sourceState == .officialCurrent ? .official : .unknown
    }

    private static func freshnessState(for result: SourceAtlasQueryResult) -> HumanProgressFreshnessState {
        switch result.freshnessState {
        case .current:
            return result.fallbackReason == .stale ? .staleCritical : .current
        case .stale:
            return .staleCritical
        case .unknown:
            return .unknown
        }
    }

    private static func reviewState(for result: SourceAtlasQueryResult) -> HumanProgressReviewState {
        switch result.reviewState {
        case .approved:
            return result.canSupportCurrentUse ? .ready : .needsSourceReview
        case .none, .requested, .required:
            return .needsSourceReview
        case .blocked:
            return .needsCorrection
        }
    }
}

struct AmbitionsOSStartHereRecommendationValidator: Sendable, Equatable, Hashable {
    func validate(_ recommendation: AmbitionsOSStartHereRecommendation) -> [AmbitionsOSRecommendationStartHereIssue] {
        var issues: Set<AmbitionsOSRecommendationStartHereIssue> = []

        validateSchemaAndShape(recommendation, issues: &issues)
        validateSourceClaims(recommendation.sourceClaims, issues: &issues)
        validateProofReceipts(recommendation.proofTrustReceipts, issues: &issues)
        validateControlAndExplanation(recommendation, issues: &issues)
        validateRuntimeAndPrivacy(recommendation, issues: &issues)
        validateLanguage(recommendation, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateSchemaAndShape(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.schemaVersion != ambitionsOSRecommendationStartHereSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if recommendation.isWellFormed == false {
            issues.insert(.malformedRecommendation)
        }
        if recommendation.sourceLabel.isEmpty || recommendation.sourceClaims.isEmpty {
            issues.insert(.missingSourceLabel)
        }
    }

    private func validateSourceClaims(
        _ claims: [AmbitionsOSSourceTruthClaim],
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        for claim in claims {
            if claim.canDriveSourceSensitiveRecommendation == false {
                issues.insert(.sourceReviewRequired)
            }
            if claim.freshnessState.blocksHighRiskUse {
                issues.insert(.staleSourceReviewRequired)
            }
        }
    }

    private func validateProofReceipts(
        _ receipts: [AmbitionsOSProofTrustReceipt],
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if receipts.isEmpty {
            issues.insert(.missingReceiptBehavior)
            return
        }

        let proofValidator = AmbitionsOSProofTrustValidator()
        for receipt in receipts {
            if proofValidator.validate(receipt: receipt).isEmpty == false {
                issues.insert(.proofTrustReviewRequired)
            }
        }
    }

    private func validateControlAndExplanation(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.controlClassification.blocksRecommendation {
            issues.insert(.controlPlaneBlocksRecommendation)
        }
        if recommendation.hasPlainExplanation == false {
            issues.insert(.missingExplanation)
        }
        if recommendation.hasUserControl == false {
            issues.insert(.missingUserControl)
        }
        if recommendation.usesGenericPriorityOnly {
            issues.insert(.genericPriorityOnly)
        }
    }

    private func validateRuntimeAndPrivacy(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if recommendation.mutatesPlansAutomatically {
            issues.insert(.hiddenMutationRisk)
        }
        if recommendation.privacyClass == .sensitive && recommendation.isExternalProjectionSafe == false {
            issues.insert(.privateExternalProjectionRisk)
        }
    }

    private func validateLanguage(
        _ recommendation: AmbitionsOSStartHereRecommendation,
        issues: inout Set<AmbitionsOSRecommendationStartHereIssue>
    ) {
        if recommendation.exposesConfidenceScore {
            issues.insert(.confidenceScoreExposed)
        }
        if recommendation.claimsGuaranteedOutcome {
            issues.insert(.guaranteedOutcomeLanguage)
        }

        let blocked = [
            "ai " + "confidence",
            "model " + "confidence",
            "productivity " + "score",
            "best " + "possible",
            "next " + "best " + "move",
            "guaranteed",
            "you " + "failed",
            "over" + "due"
        ]
        if recommendation.surfaceLanguageSamples.contains(where: { sample in
            let normalized = sample.lowercased()
            return blocked.contains(where: normalized.contains)
        }) {
            issues.insert(.harmfulRecommendationLanguage)
        }
    }
}

extension RecommendationTrace {
    init(
        startHere recommendation: AmbitionsOSStartHereRecommendation,
        explanation: RecommendationExplanation
    ) {
        let evidenceModel = explanation.recommendationEvidenceModel
        let receiptBehavior = Self.receiptBehavior(for: recommendation.proofTrustReceipts)
        let sourceIDs = Self.sourceIDs(
            from: recommendation.sourceClaims,
            evidenceModel: evidenceModel
        )
        let blockReasons = Self.blockReasons(
            from: recommendation.sourceClaims,
            evidenceModel: evidenceModel
        )

        self.init(
            id: "trace.\(recommendation.id)",
            recommendationID: recommendation.id,
            source: RecommendationTraceSource(
                citedSourceIDs: sourceIDs,
                sourceAtlasBlockReasons: blockReasons,
                localEvidenceCategories: evidenceModel.categories,
                canSupportRecommendation: evidenceModel.canDriveRecommendation &&
                    recommendation.sourceClaims.allSatisfy(\.canDriveSourceSensitiveRecommendation)
            ),
            reason: RecommendationTraceReason(
                explanationID: explanation.id,
                summary: explanation.summary,
                evidenceCategoryIDs: evidenceModel.categories.map(\.rawValue)
            ),
            fit: RecommendationTraceFit(
                state: RecommendationTraceFitState(recommendation.fitState),
                blockReasons: blockReasons,
                canDriveRecommendation: recommendation.fitState == .fits &&
                    evidenceModel.canDriveRecommendation &&
                    recommendation.sourceClaims.allSatisfy(\.canDriveSourceSensitiveRecommendation)
            ),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: explanation.uncertainty.map(\.id).sorted(),
                summaries: explanation.uncertainty.map(\.summary).sorted()
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: explanation.correctionActions.map(\.id).sorted(),
                controlActionIDs: recommendation.controlActions.map(\.rawValue).sorted(),
                correctableFieldKeys: evidenceModel.correctableFieldKeys,
                hasRequiredControl: recommendation.controlActions.isEmpty == false &&
                    (explanation.correctionActions.isEmpty == false || evidenceModel.correctableFieldKeys.isEmpty == false)
            ),
            receiptBehavior: receiptBehavior
        )
    }

    private static func sourceIDs(
        from claims: [AmbitionsOSSourceTruthClaim],
        evidenceModel: RecommendationEvidenceModel
    ) -> [String] {
        orderedUnique(
            evidenceModel.citedSourceIDs +
                claims.map(\.id) +
                claims.flatMap(\.sourceIDs) +
                claims.flatMap(\.sourcePackIDs)
        )
    }

    private static func blockReasons(
        from claims: [AmbitionsOSSourceTruthClaim],
        evidenceModel: RecommendationEvidenceModel
    ) -> [String] {
        orderedUnique(
            evidenceModel.sourceAtlasBlockReasons +
                claims.filter { $0.canDriveSourceSensitiveRecommendation == false }.map(\.state.rawValue) +
                claims.filter { $0.freshnessState.blocksHighRiskUse }.map(\.freshnessState.rawValue) +
                claims.filter { $0.reviewState.blocksAutomaticMutation }.map(\.reviewState.rawValue)
        )
    }

    private static func receiptBehavior(
        for receipts: [AmbitionsOSProofTrustReceipt]
    ) -> RecommendationTraceReceiptBehavior {
        if receipts.isEmpty {
            return .missing()
        }

        let receiptIDs = orderedUnique(receipts.map(\.id))
        let actionReceiptIDs = orderedUnique(receipts.flatMap(\.actionReceiptIDs))
        let proofReferenceIDs = orderedUnique(receipts.flatMap(\.proofReferenceIDs))

        if actionReceiptIDs.isEmpty && proofReferenceIDs.isEmpty {
            return .required()
        }

        return .available(
            receiptIDs: receiptIDs,
            actionReceiptIDs: actionReceiptIDs,
            proofReferenceIDs: proofReferenceIDs
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

private extension RecommendationTraceFitState {
    init(_ fitState: AmbitionsOSRecommendationFitState) {
        switch fitState {
        case .fits:
            self = .fits
        case .reviewable:
            self = .reviewable
        case .sourceNeeded:
            self = .sourceNeeded
        case .proofNeeded:
            self = .proofNeeded
        case .blocked:
            self = .blocked
        }
    }
}
