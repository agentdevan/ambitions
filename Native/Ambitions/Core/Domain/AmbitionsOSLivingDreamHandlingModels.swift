import Foundation

let ambitionsOSLivingDreamHandlingSchemaVersion = "ambitionsos_living_dream_handling.native.v1"

enum AmbitionsOSLivingDreamHandlingLane: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case parkedThought = "parked_thought"
    case clarificationNeeded = "clarification_needed"
    case quickStep = "quick_step"
    case projectPlan = "project_plan"
    case dreamScaffold = "dream_scaffold"
    case sourceBackedPlan = "source_backed_plan"
    case regulatedPlan = "regulated_plan"
    case professionalBoundaryScaffold = "professional_boundary_scaffold"
    case northStarExtraction = "north_star_extraction"
    case unsafeBlocked = "unsafe_blocked"
    case crisisSupport = "crisis_support"
    case sourceStaleReview = "source_stale_review"
    case sourceConflictReview = "source_conflict_review"
    case impossibleTimelineReview = "impossible_timeline_review"
    case conflictReview = "conflict_review"
    case privacySensitivePlan = "privacy_sensitive_plan"
    case syncRecovery = "sync_recovery"
    case unsupportedDomainExploration = "unsupported_domain_exploration"
    case sourceCheckFirst = "source_check_first"
    case userReviewRequired = "user_review_required"
    case localOnlyPrivatePlan = "local_only_private_plan"

    var blocksActivation: Bool {
        switch self {
        case .unsafeBlocked, .crisisSupport, .clarificationNeeded, .sourceStaleReview,
             .sourceConflictReview, .impossibleTimelineReview, .conflictReview,
             .sourceCheckFirst, .userReviewRequired:
            return true
        case .parkedThought, .quickStep, .projectPlan, .dreamScaffold,
             .sourceBackedPlan, .regulatedPlan, .professionalBoundaryScaffold,
             .northStarExtraction, .privacySensitivePlan, .syncRecovery,
             .unsupportedDomainExploration, .localOnlyPrivatePlan:
            return false
        }
    }
}

enum AmbitionsOSLivingDreamInputKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case note
    case oneStep = "one_step"
    case project
    case lifeDefiningDream = "life_defining_dream"
    case regulatedGoal = "regulated_goal"
    case impossibleOrSymbolic = "impossible_or_symbolic"
    case sourceSensitive = "source_sensitive"
    case privacySensitive = "privacy_sensitive"
}

enum AmbitionsOSLivingDreamSeriousness: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case parked
    case quick
    case project
    case lifeDefining = "life_defining"
    case urgent
}

enum AmbitionsOSLivingDreamSignal: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ambiguous
    case unsafeOrIllegal = "unsafe_or_illegal"
    case crisisCoded = "crisis_coded"
    case regulatedDomain = "regulated_domain"
    case professionalBoundary = "professional_boundary"
    case impossibleOrFantasy = "impossible_or_fantasy"
    case impossibleTimeline = "impossible_timeline"
    case sourceCoverageRequired = "source_coverage_required"
    case sourceStale = "source_stale"
    case sourceConflict = "source_conflict"
    case goalConflict = "goal_conflict"
    case privacySensitive = "privacy_sensitive"
    case syncRecoveryNeeded = "sync_recovery_needed"
    case unsupportedDomain = "unsupported_domain"
    case localOnly = "local_only"
}

enum AmbitionsOSLivingDreamHandlingIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedRequest = "malformed_request"
    case malformedOutcome = "malformed_outcome"
    case unsafeOperationalized = "unsafe_operationalized"
    case crisisRoutedToProductivity = "crisis_routed_to_productivity"
    case activationWithoutReview = "activation_without_review"
    case staleSourceActivationRisk = "stale_source_activation_risk"
    case professionalBoundaryMissing = "professional_boundary_missing"
    case localFirstBoundaryBroken = "local_first_boundary_broken"
}

struct AmbitionsOSLivingDreamHandlingRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let rawInputSummary: String
    let inputKind: AmbitionsOSLivingDreamInputKind
    let seriousness: AmbitionsOSLivingDreamSeriousness
    let signals: [AmbitionsOSLivingDreamSignal]
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let schemaVersion: String

    init(
        id: String,
        rawInputSummary: String,
        inputKind: AmbitionsOSLivingDreamInputKind,
        seriousness: AmbitionsOSLivingDreamSeriousness,
        signals: [AmbitionsOSLivingDreamSignal] = [],
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .needsUserReview,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = ambitionsOSLivingDreamHandlingSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rawInputSummary = rawInputSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.inputKind = inputKind
        self.seriousness = seriousness
        self.signals = Array(Set(signals)).sorted { $0.rawValue < $1.rawValue }
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            rawInputSummary.isEmpty == false &&
            schemaVersion == ambitionsOSLivingDreamHandlingSchemaVersion
    }

    var needsProfessionalBoundary: Bool {
        inputKind == .regulatedGoal ||
            signals.contains(.regulatedDomain) ||
            signals.contains(.professionalBoundary)
    }

    var isPrivacySensitive: Bool {
        inputKind == .privacySensitive ||
            privacyClass == .sensitive ||
            signals.contains(.privacySensitive) ||
            signals.contains(.localOnly)
    }

    var sourceRequiresReview: Bool {
        sourceState == .sourceNeeded ||
            sourceState == .unsupported ||
            sourceState == .disputed ||
            sourceState == .revoked ||
            sourceState == .unknown ||
            freshnessState.blocksHighRiskUse ||
            signals.contains(.sourceCoverageRequired) ||
            signals.contains(.sourceStale) ||
            signals.contains(.sourceConflict)
    }
}

struct AmbitionsOSLivingDreamHandlingOutcome: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let requestID: String
    let primaryLane: AmbitionsOSLivingDreamHandlingLane
    let secondaryFlags: [AmbitionsOSLivingDreamHandlingLane]
    let ladderStepIndex: Int
    let receiptSummary: String
    let requiresUserReview: Bool
    let mayActivateAfterReview: Bool
    let blocksNormalProductivityRouting: Bool
    let professionalBoundaryRequired: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        requestID: String,
        primaryLane: AmbitionsOSLivingDreamHandlingLane,
        secondaryFlags: [AmbitionsOSLivingDreamHandlingLane] = [],
        ladderStepIndex: Int,
        receiptSummary: String,
        requiresUserReview: Bool = true,
        mayActivateAfterReview: Bool = false,
        blocksNormalProductivityRouting: Bool = false,
        professionalBoundaryRequired: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSLivingDreamHandlingSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requestID = requestID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.primaryLane = primaryLane
        self.secondaryFlags = Array(Set(secondaryFlags.filter { $0 != primaryLane }))
            .sorted { $0.rawValue < $1.rawValue }
        self.ladderStepIndex = ladderStepIndex
        self.receiptSummary = receiptSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requiresUserReview = requiresUserReview
        self.mayActivateAfterReview = mayActivateAfterReview
        self.blocksNormalProductivityRouting = blocksNormalProductivityRouting
        self.professionalBoundaryRequired = professionalBoundaryRequired
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            requestID.isEmpty == false &&
            receiptSummary.isEmpty == false &&
            (1...16).contains(ladderStepIndex) &&
            schemaVersion == ambitionsOSLivingDreamHandlingSchemaVersion
    }
}

struct AmbitionsOSLivingDreamHandlingRouter: Sendable, Equatable, Hashable {
    func route(_ request: AmbitionsOSLivingDreamHandlingRequest) -> AmbitionsOSLivingDreamHandlingOutcome {
        let primary = primaryLane(for: request)
        let flags = secondaryFlags(for: request, primary: primary)
        let blocked = primary == .unsafeBlocked || primary == .crisisSupport
        let sourceBlocked = primary == .sourceCheckFirst ||
            primary == .sourceStaleReview ||
            primary == .sourceConflictReview
        let reviewRequired = request.reviewState != .ready ||
            primary.blocksActivation ||
            request.needsProfessionalBoundary ||
            request.isPrivacySensitive ||
            sourceBlocked

        return AmbitionsOSLivingDreamHandlingOutcome(
            id: "\(request.id).handling",
            requestID: request.id,
            primaryLane: primary,
            secondaryFlags: flags,
            ladderStepIndex: ladderStepIndex(for: primary),
            receiptSummary: receiptSummary(for: primary),
            requiresUserReview: reviewRequired,
            mayActivateAfterReview: blocked == false &&
                sourceBlocked == false &&
                primary.blocksActivation == false &&
                reviewRequired,
            blocksNormalProductivityRouting: blocked,
            professionalBoundaryRequired: request.needsProfessionalBoundary,
            runtimeBoundary: .valueModelOnly
        )
    }

    private func primaryLane(
        for request: AmbitionsOSLivingDreamHandlingRequest
    ) -> AmbitionsOSLivingDreamHandlingLane {
        if request.signals.contains(.crisisCoded) {
            return .crisisSupport
        }
        if request.signals.contains(.unsafeOrIllegal) {
            return .unsafeBlocked
        }
        if request.signals.contains(.ambiguous) || request.rawInputSummary.count < 4 {
            return .clarificationNeeded
        }
        if request.signals.contains(.sourceConflict) || request.sourceState == .disputed {
            return .sourceConflictReview
        }
        if request.signals.contains(.sourceStale) || request.freshnessState.blocksHighRiskUse {
            return .sourceStaleReview
        }
        if request.signals.contains(.goalConflict) {
            return .conflictReview
        }
        if request.signals.contains(.syncRecoveryNeeded) {
            return .syncRecovery
        }
        if request.signals.contains(.impossibleTimeline) {
            return .impossibleTimelineReview
        }
        if request.inputKind == .impossibleOrSymbolic || request.signals.contains(.impossibleOrFantasy) {
            return .northStarExtraction
        }
        if request.isPrivacySensitive {
            return request.signals.contains(.localOnly) ? .localOnlyPrivatePlan : .privacySensitivePlan
        }
        if request.needsProfessionalBoundary {
            return request.sourceState == .sourceBacked ? .regulatedPlan : .professionalBoundaryScaffold
        }
        if request.signals.contains(.unsupportedDomain) || request.sourceState == .unsupported {
            return .unsupportedDomainExploration
        }
        if request.inputKind == .sourceSensitive || request.sourceRequiresReview {
            return request.sourceState == .sourceBacked ? .sourceBackedPlan : .sourceCheckFirst
        }

        switch (request.inputKind, request.seriousness) {
        case (.note, .parked):
            return .parkedThought
        case (.oneStep, _), (_, .quick):
            return .quickStep
        case (.project, _), (_, .project):
            return .projectPlan
        case (.lifeDefiningDream, _), (_, .lifeDefining), (_, .urgent):
            return .dreamScaffold
        case (.note, _):
            return .parkedThought
        case (.regulatedGoal, _):
            return .professionalBoundaryScaffold
        case (.impossibleOrSymbolic, _):
            return .northStarExtraction
        case (.sourceSensitive, _):
            return .sourceCheckFirst
        case (.privacySensitive, _):
            return .privacySensitivePlan
        }
    }

    private func secondaryFlags(
        for request: AmbitionsOSLivingDreamHandlingRequest,
        primary: AmbitionsOSLivingDreamHandlingLane
    ) -> [AmbitionsOSLivingDreamHandlingLane] {
        var flags: Set<AmbitionsOSLivingDreamHandlingLane> = []
        if request.needsProfessionalBoundary {
            flags.insert(.professionalBoundaryScaffold)
        }
        if request.isPrivacySensitive {
            flags.insert(.privacySensitivePlan)
        }
        if request.sourceRequiresReview {
            flags.insert(.sourceCheckFirst)
        }
        if request.reviewState != .ready {
            flags.insert(.userReviewRequired)
        }
        flags.remove(primary)
        return flags.sorted { $0.rawValue < $1.rawValue }
    }

    private func ladderStepIndex(for lane: AmbitionsOSLivingDreamHandlingLane) -> Int {
        switch lane {
        case .parkedThought, .quickStep, .projectPlan, .dreamScaffold:
            return 10
        case .clarificationNeeded:
            return 2
        case .unsafeBlocked, .crisisSupport:
            return 4
        case .regulatedPlan, .professionalBoundaryScaffold:
            return 5
        case .northStarExtraction, .impossibleTimelineReview:
            return 6
        case .sourceBackedPlan, .sourceCheckFirst, .sourceStaleReview, .sourceConflictReview:
            return 7
        case .conflictReview:
            return 10
        case .privacySensitivePlan, .localOnlyPrivatePlan:
            return 10
        case .syncRecovery:
            return 15
        case .unsupportedDomainExploration:
            return 10
        case .userReviewRequired:
            return 11
        }
    }

    private func receiptSummary(for lane: AmbitionsOSLivingDreamHandlingLane) -> String {
        switch lane {
        case .parkedThought:
            return "Parked without activation."
        case .clarificationNeeded:
            return "One question is needed before placement."
        case .quickStep:
            return "Safe one-step handling candidate; review before activation."
        case .projectPlan:
            return "Project handling candidate; review before activation."
        case .dreamScaffold:
            return "Dream scaffold candidate; review before activation."
        case .sourceBackedPlan:
            return "Source-backed handling candidate; review before activation."
        case .regulatedPlan:
            return "Regulated plan candidate with professional-boundary review."
        case .professionalBoundaryScaffold:
            return "Professional-boundary scaffold; no professional advice."
        case .northStarExtraction:
            return "North Star meaning extraction; no literal guarantee."
        case .unsafeBlocked:
            return "Unsafe or illegal operationalization blocked."
        case .crisisSupport:
            return "Crisis-coded input routed away from productivity."
        case .sourceStaleReview:
            return "Source freshness review required before planning."
        case .sourceConflictReview:
            return "Source conflict review required before planning."
        case .impossibleTimelineReview:
            return "Timeline realism review required before planning."
        case .conflictReview:
            return "Goal or life-context conflict review required."
        case .privacySensitivePlan:
            return "Privacy-sensitive handling candidate; review required."
        case .syncRecovery:
            return "Continuity or sync recovery review required."
        case .unsupportedDomainExploration:
            return "Unsupported domain exploration only; no plan guarantee."
        case .sourceCheckFirst:
            return "Source check required before recommendation."
        case .userReviewRequired:
            return "User review required before activation."
        case .localOnlyPrivatePlan:
            return "Local-only private handling candidate; review required."
        }
    }
}

struct AmbitionsOSLivingDreamHandlingValidator: Sendable, Equatable, Hashable {
    func validate(
        request: AmbitionsOSLivingDreamHandlingRequest,
        outcome: AmbitionsOSLivingDreamHandlingOutcome
    ) -> [AmbitionsOSLivingDreamHandlingIssue] {
        var issues: Set<AmbitionsOSLivingDreamHandlingIssue> = []

        if request.schemaVersion != ambitionsOSLivingDreamHandlingSchemaVersion ||
            outcome.schemaVersion != ambitionsOSLivingDreamHandlingSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if request.isWellFormed == false {
            issues.insert(.malformedRequest)
        }
        if outcome.isWellFormed == false || outcome.requestID != request.id {
            issues.insert(.malformedOutcome)
        }
        if request.signals.contains(.unsafeOrIllegal) && outcome.primaryLane != .unsafeBlocked {
            issues.insert(.unsafeOperationalized)
        }
        if request.signals.contains(.crisisCoded) &&
            (outcome.primaryLane != .crisisSupport || outcome.blocksNormalProductivityRouting == false) {
            issues.insert(.crisisRoutedToProductivity)
        }
        if outcome.mayActivateAfterReview && outcome.requiresUserReview == false {
            issues.insert(.activationWithoutReview)
        }
        if request.sourceRequiresReview && outcome.primaryLane == .sourceBackedPlan {
            issues.insert(.staleSourceActivationRisk)
        }
        if request.needsProfessionalBoundary && outcome.professionalBoundaryRequired == false {
            issues.insert(.professionalBoundaryMissing)
        }
        if outcome.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.localFirstBoundaryBroken)
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }
}
