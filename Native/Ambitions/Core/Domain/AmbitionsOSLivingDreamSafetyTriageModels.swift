import Foundation

let ambitionsOSLivingDreamSafetyTriageSchemaVersion = "ambitionsos_living_dream_safety_triage.native.v1"

enum AmbitionsOSLivingDreamSafetyConcern: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case illegalOrHarmful = "illegal_or_harmful"
    case crisisOrSelfHarm = "crisis_or_self_harm"
    case harmToOthers = "harm_to_others"
    case stalkingHarassment = "stalking_harassment"
    case fraudOrEvasion = "fraud_or_evasion"
    case exploitationOrCoercion = "exploitation_or_coercion"
    case academicOrWorkplaceDishonesty = "academic_or_workplace_dishonesty"
    case dangerousHealthFitness = "dangerous_health_fitness"
    case regulatedProfessionalDomain = "regulated_professional_domain"
    case impossibleTimeline = "impossible_timeline"
    case fantasyImpossible = "fantasy_impossible"
    case delusionParanoiaCoded = "delusion_paranoia_coded"
    case minorAgeSensitive = "minor_age_sensitive"
    case privacySensitive = "privacy_sensitive"
    case sourceSensitive = "source_sensitive"
    case ambiguous = "ambiguous"

    var isHardBlock: Bool {
        switch self {
        case .illegalOrHarmful, .crisisOrSelfHarm, .harmToOthers,
             .stalkingHarassment, .fraudOrEvasion, .exploitationOrCoercion,
             .academicOrWorkplaceDishonesty, .delusionParanoiaCoded:
            return true
        case .dangerousHealthFitness, .regulatedProfessionalDomain,
             .impossibleTimeline, .fantasyImpossible, .minorAgeSensitive,
             .privacySensitive, .sourceSensitive, .ambiguous:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamSafetyDisposition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case blockAndRedirect = "block_and_redirect"
    case crisisSupport = "crisis_support"
    case professionalBoundaryReview = "professional_boundary_review"
    case ageSensitiveReview = "age_sensitive_review"
    case privacyReview = "privacy_review"
    case sourceReview = "source_review"
    case realityCheck = "reality_check"
    case northStarExtraction = "north_star_extraction"
    case clarification = "clarification"
    case safePlanningCandidate = "safe_planning_candidate"
}

enum AmbitionsOSLivingDreamSafetyIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedRequest = "malformed_request"
    case malformedOutcome = "malformed_outcome"
    case unsafeOperationalized = "unsafe_operationalized"
    case crisisRoutedToProductivity = "crisis_routed_to_productivity"
    case professionalBoundaryMissing = "professional_boundary_missing"
    case sourceReviewMissing = "source_review_missing"
    case privacyReviewMissing = "privacy_review_missing"
    case localFirstBoundaryBroken = "local_first_boundary_broken"
}

struct AmbitionsOSLivingDreamSafetyTriageRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let inputSummary: String
    let concerns: [AmbitionsOSLivingDreamSafetyConcern]
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let privacyClass: HumanProgressPrivacyClass
    let schemaVersion: String

    init(
        id: String,
        inputSummary: String,
        concerns: [AmbitionsOSLivingDreamSafetyConcern],
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSLivingDreamSafetyTriageSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.inputSummary = inputSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.concerns = Array(Set(concerns)).sorted { $0.rawValue < $1.rawValue }
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.privacyClass = privacyClass
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            inputSummary.isEmpty == false &&
            concerns.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamSafetyTriageSchemaVersion
    }

    var containsHardBlock: Bool {
        concerns.contains { $0.isHardBlock }
    }

    var requiresProfessionalBoundary: Bool {
        concerns.contains(.regulatedProfessionalDomain) ||
            concerns.contains(.dangerousHealthFitness) ||
            concerns.contains(.minorAgeSensitive)
    }

    var requiresSourceReview: Bool {
        concerns.contains(.sourceSensitive) ||
            sourceState.canDriveSourceSensitiveRecommendation == false ||
            freshnessState.blocksHighRiskUse
    }

    var requiresPrivacyReview: Bool {
        concerns.contains(.privacySensitive) ||
            concerns.contains(.minorAgeSensitive) ||
            privacyClass == .sensitive ||
            privacyClass == .externalRedacted
    }
}

struct AmbitionsOSLivingDreamSafetyTriageOutcome: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let requestID: String
    let primaryLane: AmbitionsOSLivingDreamHandlingLane
    let disposition: AmbitionsOSLivingDreamSafetyDisposition
    let receiptSummary: String
    let blocksNormalProductivityRouting: Bool
    let permitsPlanCandidate: Bool
    let requiresUserReview: Bool
    let professionalBoundaryRequired: Bool
    let sourceReviewRequired: Bool
    let privacyReviewRequired: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        requestID: String,
        primaryLane: AmbitionsOSLivingDreamHandlingLane,
        disposition: AmbitionsOSLivingDreamSafetyDisposition,
        receiptSummary: String,
        blocksNormalProductivityRouting: Bool,
        permitsPlanCandidate: Bool,
        requiresUserReview: Bool = true,
        professionalBoundaryRequired: Bool = false,
        sourceReviewRequired: Bool = false,
        privacyReviewRequired: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamSafetyTriageSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requestID = requestID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.primaryLane = primaryLane
        self.disposition = disposition
        self.receiptSummary = receiptSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.blocksNormalProductivityRouting = blocksNormalProductivityRouting
        self.permitsPlanCandidate = permitsPlanCandidate
        self.requiresUserReview = requiresUserReview
        self.professionalBoundaryRequired = professionalBoundaryRequired
        self.sourceReviewRequired = sourceReviewRequired
        self.privacyReviewRequired = privacyReviewRequired
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            requestID.isEmpty == false &&
            receiptSummary.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamSafetyTriageSchemaVersion
    }
}

struct AmbitionsOSLivingDreamSafetyTriageEngine: Sendable, Equatable, Hashable {
    func triage(
        _ request: AmbitionsOSLivingDreamSafetyTriageRequest
    ) -> AmbitionsOSLivingDreamSafetyTriageOutcome {
        let lane = primaryLane(for: request)
        let disposition = disposition(for: request, lane: lane)
        let hardBlock = request.containsHardBlock || lane == .unsafeBlocked || lane == .crisisSupport
        let sourceReview = request.requiresSourceReview && hardBlock == false
        let privacyReview = request.requiresPrivacyReview
        let professionalBoundary = request.requiresProfessionalBoundary

        return AmbitionsOSLivingDreamSafetyTriageOutcome(
            id: "\(request.id).safety-triage",
            requestID: request.id,
            primaryLane: lane,
            disposition: disposition,
            receiptSummary: receiptSummary(for: disposition),
            blocksNormalProductivityRouting: hardBlock,
            permitsPlanCandidate: hardBlock == false &&
                lane != .clarificationNeeded &&
                lane != .impossibleTimelineReview &&
                lane != .sourceCheckFirst &&
                lane != .sourceStaleReview,
            requiresUserReview: true,
            professionalBoundaryRequired: professionalBoundary,
            sourceReviewRequired: sourceReview,
            privacyReviewRequired: privacyReview,
            runtimeBoundary: .valueModelOnly
        )
    }

    private func primaryLane(
        for request: AmbitionsOSLivingDreamSafetyTriageRequest
    ) -> AmbitionsOSLivingDreamHandlingLane {
        if request.concerns.contains(.crisisOrSelfHarm) {
            return .crisisSupport
        }
        if request.concerns.contains(.illegalOrHarmful) ||
            request.concerns.contains(.harmToOthers) ||
            request.concerns.contains(.stalkingHarassment) ||
            request.concerns.contains(.fraudOrEvasion) ||
            request.concerns.contains(.exploitationOrCoercion) ||
            request.concerns.contains(.academicOrWorkplaceDishonesty) ||
            request.concerns.contains(.delusionParanoiaCoded) {
            return .unsafeBlocked
        }
        if request.concerns.contains(.ambiguous) {
            return .clarificationNeeded
        }
        if request.concerns.contains(.minorAgeSensitive) {
            return .professionalBoundaryScaffold
        }
        if request.concerns.contains(.regulatedProfessionalDomain) ||
            request.concerns.contains(.dangerousHealthFitness) {
            return request.sourceState == .sourceBacked ? .regulatedPlan : .professionalBoundaryScaffold
        }
        if request.concerns.contains(.impossibleTimeline) {
            return .impossibleTimelineReview
        }
        if request.concerns.contains(.fantasyImpossible) {
            return .northStarExtraction
        }
        if request.requiresPrivacyReview {
            return .privacySensitivePlan
        }
        if request.requiresSourceReview {
            return request.freshnessState.blocksHighRiskUse ? .sourceStaleReview : .sourceCheckFirst
        }
        return .dreamScaffold
    }

    private func disposition(
        for request: AmbitionsOSLivingDreamSafetyTriageRequest,
        lane: AmbitionsOSLivingDreamHandlingLane
    ) -> AmbitionsOSLivingDreamSafetyDisposition {
        switch lane {
        case .crisisSupport:
            return .crisisSupport
        case .unsafeBlocked:
            return .blockAndRedirect
        case .professionalBoundaryScaffold, .regulatedPlan:
            return request.concerns.contains(.minorAgeSensitive) ? .ageSensitiveReview : .professionalBoundaryReview
        case .impossibleTimelineReview:
            return .realityCheck
        case .northStarExtraction:
            return .northStarExtraction
        case .privacySensitivePlan, .localOnlyPrivatePlan:
            return .privacyReview
        case .sourceCheckFirst, .sourceStaleReview, .sourceConflictReview:
            return .sourceReview
        case .clarificationNeeded:
            return .clarification
        case .parkedThought, .quickStep, .projectPlan, .dreamScaffold,
             .sourceBackedPlan, .conflictReview, .syncRecovery,
             .unsupportedDomainExploration, .userReviewRequired:
            return .safePlanningCandidate
        }
    }

    private func receiptSummary(for disposition: AmbitionsOSLivingDreamSafetyDisposition) -> String {
        switch disposition {
        case .blockAndRedirect:
            return "Unsafe operationalization is blocked; only safe redirect handling is allowed."
        case .crisisSupport:
            return "Crisis-coded input is routed away from productivity handling."
        case .professionalBoundaryReview:
            return "Regulated or high-risk domain requires source and professional-boundary review."
        case .ageSensitiveReview:
            return "Age-sensitive handling requires guardian, local-rule, and safety review before planning."
        case .privacyReview:
            return "Privacy-sensitive handling requires discreet local review before activation."
        case .sourceReview:
            return "Source-sensitive handling requires source or freshness review before planning."
        case .realityCheck:
            return "Timeline realism review is required before any planning candidate."
        case .northStarExtraction:
            return "Impossible or symbolic input becomes meaning extraction, not a literal plan."
        case .clarification:
            return "One clarification is required before safety triage can finish."
        case .safePlanningCandidate:
            return "No hard safety block found; user review is still required before activation."
        }
    }
}

struct AmbitionsOSLivingDreamSafetyTriageValidator: Sendable, Equatable, Hashable {
    func validate(
        request: AmbitionsOSLivingDreamSafetyTriageRequest,
        outcome: AmbitionsOSLivingDreamSafetyTriageOutcome
    ) -> [AmbitionsOSLivingDreamSafetyIssue] {
        var issues: Set<AmbitionsOSLivingDreamSafetyIssue> = []

        if request.schemaVersion != ambitionsOSLivingDreamSafetyTriageSchemaVersion ||
            outcome.schemaVersion != ambitionsOSLivingDreamSafetyTriageSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if request.isWellFormed == false {
            issues.insert(.malformedRequest)
        }
        if outcome.isWellFormed == false || outcome.requestID != request.id {
            issues.insert(.malformedOutcome)
        }
        if request.containsHardBlock && outcome.permitsPlanCandidate {
            issues.insert(.unsafeOperationalized)
        }
        if request.concerns.contains(.crisisOrSelfHarm) &&
            (outcome.primaryLane != .crisisSupport || outcome.blocksNormalProductivityRouting == false) {
            issues.insert(.crisisRoutedToProductivity)
        }
        if request.requiresProfessionalBoundary && outcome.professionalBoundaryRequired == false {
            issues.insert(.professionalBoundaryMissing)
        }
        if request.requiresSourceReview &&
            request.containsHardBlock == false &&
            outcome.sourceReviewRequired == false {
            issues.insert(.sourceReviewMissing)
        }
        if request.requiresPrivacyReview && outcome.privacyReviewRequired == false {
            issues.insert(.privacyReviewMissing)
        }
        if outcome.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.localFirstBoundaryBroken)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }
}

struct AmbitionsOSLivingDreamSafetyRedTeamFixture: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let fixtureFamilyNumber: Int
    let concern: AmbitionsOSLivingDreamSafetyConcern
    let expectedLane: AmbitionsOSLivingDreamHandlingLane
    let expectedDisposition: AmbitionsOSLivingDreamSafetyDisposition
}

enum AmbitionsOSLivingDreamSafetyRedTeamCatalog {
    static let fixtures: [AmbitionsOSLivingDreamSafetyRedTeamFixture] = [
        .init(id: "ldi03-illegal-harmful", fixtureFamilyNumber: 7, concern: .illegalOrHarmful, expectedLane: .unsafeBlocked, expectedDisposition: .blockAndRedirect),
        .init(id: "ldi03-crisis", fixtureFamilyNumber: 8, concern: .crisisOrSelfHarm, expectedLane: .crisisSupport, expectedDisposition: .crisisSupport),
        .init(id: "ldi03-harm-to-others", fixtureFamilyNumber: 9, concern: .harmToOthers, expectedLane: .unsafeBlocked, expectedDisposition: .blockAndRedirect),
        .init(id: "ldi03-stalking", fixtureFamilyNumber: 10, concern: .stalkingHarassment, expectedLane: .unsafeBlocked, expectedDisposition: .blockAndRedirect),
        .init(id: "ldi03-fraud", fixtureFamilyNumber: 11, concern: .fraudOrEvasion, expectedLane: .unsafeBlocked, expectedDisposition: .blockAndRedirect),
        .init(id: "ldi03-coercion", fixtureFamilyNumber: 12, concern: .exploitationOrCoercion, expectedLane: .unsafeBlocked, expectedDisposition: .blockAndRedirect),
        .init(id: "ldi03-dishonesty", fixtureFamilyNumber: 12, concern: .academicOrWorkplaceDishonesty, expectedLane: .unsafeBlocked, expectedDisposition: .blockAndRedirect),
        .init(id: "ldi03-dangerous-health", fixtureFamilyNumber: 13, concern: .dangerousHealthFitness, expectedLane: .professionalBoundaryScaffold, expectedDisposition: .professionalBoundaryReview),
        .init(id: "ldi03-impossible-timeline", fixtureFamilyNumber: 14, concern: .impossibleTimeline, expectedLane: .impossibleTimelineReview, expectedDisposition: .realityCheck),
        .init(id: "ldi03-fantasy", fixtureFamilyNumber: 15, concern: .fantasyImpossible, expectedLane: .northStarExtraction, expectedDisposition: .northStarExtraction),
        .init(id: "ldi03-delusion", fixtureFamilyNumber: 16, concern: .delusionParanoiaCoded, expectedLane: .unsafeBlocked, expectedDisposition: .blockAndRedirect),
        .init(id: "ldi03-minor", fixtureFamilyNumber: 18, concern: .minorAgeSensitive, expectedLane: .professionalBoundaryScaffold, expectedDisposition: .ageSensitiveReview),
        .init(id: "ldi03-regulated", fixtureFamilyNumber: 19, concern: .regulatedProfessionalDomain, expectedLane: .professionalBoundaryScaffold, expectedDisposition: .professionalBoundaryReview),
        .init(id: "ldi03-source-stale", fixtureFamilyNumber: 20, concern: .sourceSensitive, expectedLane: .sourceStaleReview, expectedDisposition: .sourceReview),
        .init(id: "ldi03-privacy", fixtureFamilyNumber: 26, concern: .privacySensitive, expectedLane: .privacySensitivePlan, expectedDisposition: .privacyReview),
        .init(id: "ldi03-ambiguous", fixtureFamilyNumber: 35, concern: .ambiguous, expectedLane: .clarificationNeeded, expectedDisposition: .clarification)
    ]
}
