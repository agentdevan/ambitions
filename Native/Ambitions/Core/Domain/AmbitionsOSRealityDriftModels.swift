import Foundation

let ambitionsOSRealityDriftSchemaVersion = "ambitionsos_reality_drift.native.v1"

enum AmbitionsOSRealityDriftLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noUpdate = "no_update"
    case microDrift = "micro_drift"
    case sameDayDrift = "same_day_drift"
    case weekDrift = "week_drift"
    case goalDeadlineDrift = "goal_deadline_drift"
    case absence
    case capacityShock = "capacity_shock"
}

enum AmbitionsOSReflowActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case keepPlan = "keep_plan"
    case makeSmaller = "make_smaller"
    case moveLater = "move_later"
    case splitStep = "split_step"
    case parkForReview = "park_for_review"
    case protectTime = "protect_time"
    case requestReview = "request_review"
    case closeStillCounts = "close_still_counts"
}

enum AmbitionsOSReflowReviewScope: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case sameDaySuggestion = "same_day_suggestion"
    case weekReview = "week_review"
    case goalDeadlineConfirmation = "goal_deadline_confirmation"
}

enum AmbitionsOSRealityDriftIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedSignal = "malformed_signal"
    case malformedProposal = "malformed_proposal"
    case noUpdateTreatedAsFailure = "no_update_treated_as_failure"
    case weekDriftRequiresReview = "week_drift_requires_review"
    case goalDeadlineRequiresConfirmation = "goal_deadline_requires_confirmation"
    case unboundedBlastRadius = "unbounded_blast_radius"
    case silentRescheduleRisk = "silent_reschedule_risk"
    case platformCalendarImplementation = "platform_calendar_implementation"
    case runtimeStoreBehavior = "runtime_store_behavior"
    case sourceReviewRequired = "source_review_required"
    case staleSourceReviewRequired = "stale_source_review_required"
    case protectedTimeViolation = "protected_time_violation"
    case proofReceiptRequired = "proof_receipt_required"
    case proofTrustReviewRequired = "proof_trust_review_required"
    case privateExternalProjectionRisk = "private_external_projection_risk"
    case harmfulRecoveryLanguage = "harmful_recovery_language"
}

struct AmbitionsOSRealityDriftSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let level: AmbitionsOSRealityDriftLevel
    let plannedCommitmentIDs: [String]
    let observedEventIDs: [String]
    let affectedGoalIDs: [String]
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let noUpdateObserved: Bool
    let userConfirmedRealityChange: Bool
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        level: AmbitionsOSRealityDriftLevel,
        plannedCommitmentIDs: [String],
        observedEventIDs: [String] = [],
        affectedGoalIDs: [String] = [],
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        noUpdateObserved: Bool = false,
        userConfirmedRealityChange: Bool = true,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSRealityDriftSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.level = level
        self.plannedCommitmentIDs = Self.orderedUnique(plannedCommitmentIDs)
        self.observedEventIDs = Self.orderedUnique(observedEventIDs)
        self.affectedGoalIDs = Self.orderedUnique(affectedGoalIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.noUpdateObserved = noUpdateObserved
        self.userConfirmedRealityChange = userConfirmedRealityChange
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            plannedCommitmentIDs.isEmpty == false &&
            schemaVersion == ambitionsOSRealityDriftSchemaVersion
    }

    var isSourceReviewReady: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState.blocksAutomaticMutation == false
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSBoundedReflowProposal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let signal: AmbitionsOSRealityDriftSignal
    let actions: [AmbitionsOSReflowActionKind]
    let commitmentProjection: AmbitionsOSCommitmentTimeProjection
    let proofTrustReceipts: [AmbitionsOSProofTrustReceipt]
    let reviewScope: AmbitionsOSReflowReviewScope
    let blastRadiusLevel: Int
    let requiresUserApproval: Bool
    let changesCommitments: Bool
    let performsPlatformCalendarWork: Bool
    let writesScheduleAutomatically: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        signal: AmbitionsOSRealityDriftSignal,
        actions: [AmbitionsOSReflowActionKind],
        commitmentProjection: AmbitionsOSCommitmentTimeProjection,
        proofTrustReceipts: [AmbitionsOSProofTrustReceipt] = [],
        reviewScope: AmbitionsOSReflowReviewScope,
        blastRadiusLevel: Int,
        requiresUserApproval: Bool = true,
        changesCommitments: Bool = false,
        performsPlatformCalendarWork: Bool = false,
        writesScheduleAutomatically: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSRealityDriftSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.signal = signal
        self.actions = Array(Set(actions)).sorted { $0.rawValue < $1.rawValue }
        self.commitmentProjection = commitmentProjection
        self.proofTrustReceipts = proofTrustReceipts
        self.reviewScope = reviewScope
        self.blastRadiusLevel = blastRadiusLevel
        self.requiresUserApproval = requiresUserApproval
        self.changesCommitments = changesCommitments
        self.performsPlatformCalendarWork = performsPlatformCalendarWork
        self.writesScheduleAutomatically = writesScheduleAutomatically
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            actions.isEmpty == false &&
            schemaVersion == ambitionsOSRealityDriftSchemaVersion
    }

    var hasBoundedBlastRadius: Bool {
        (0...5).contains(blastRadiusLevel)
    }

    var canProjectAsReviewableReflow: Bool {
        AmbitionsOSRealityDriftValidator().validate(self).isEmpty
    }
}

struct AmbitionsOSRealityDriftValidator: Sendable, Equatable, Hashable {
    func validate(_ proposal: AmbitionsOSBoundedReflowProposal) -> [AmbitionsOSRealityDriftIssue] {
        var issues: Set<AmbitionsOSRealityDriftIssue> = []

        validateSchemaAndShape(proposal, issues: &issues)
        validateDriftBoundaries(proposal, issues: &issues)
        validateRuntimeBoundaries(proposal, issues: &issues)
        validateSourceAndPrivacy(proposal.signal, issues: &issues)
        validateCommitmentProjection(proposal.commitmentProjection, issues: &issues)
        validateProofTrust(proposal, issues: &issues)
        validateLanguage(proposal.signal.surfaceLanguageSamples, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateSchemaAndShape(
        _ proposal: AmbitionsOSBoundedReflowProposal,
        issues: inout Set<AmbitionsOSRealityDriftIssue>
    ) {
        if proposal.schemaVersion != ambitionsOSRealityDriftSchemaVersion ||
            proposal.signal.schemaVersion != ambitionsOSRealityDriftSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if proposal.signal.isWellFormed == false {
            issues.insert(.malformedSignal)
        }
        if proposal.isWellFormed == false {
            issues.insert(.malformedProposal)
        }
        if proposal.hasBoundedBlastRadius == false {
            issues.insert(.unboundedBlastRadius)
        }
    }

    private func validateDriftBoundaries(
        _ proposal: AmbitionsOSBoundedReflowProposal,
        issues: inout Set<AmbitionsOSRealityDriftIssue>
    ) {
        if proposal.signal.level == .noUpdate &&
            (proposal.signal.noUpdateObserved || proposal.signal.userConfirmedRealityChange == false) &&
            proposal.actions.contains(where: { $0 != .keepPlan && $0 != .requestReview }) {
            issues.insert(.noUpdateTreatedAsFailure)
        }
        if proposal.signal.level == .weekDrift && proposal.reviewScope != .weekReview {
            issues.insert(.weekDriftRequiresReview)
        }
        if proposal.signal.level == .goalDeadlineDrift &&
            proposal.reviewScope != .goalDeadlineConfirmation {
            issues.insert(.goalDeadlineRequiresConfirmation)
        }
        if proposal.changesCommitments && proposal.requiresUserApproval == false {
            issues.insert(.silentRescheduleRisk)
        }
    }

    private func validateRuntimeBoundaries(
        _ proposal: AmbitionsOSBoundedReflowProposal,
        issues: inout Set<AmbitionsOSRealityDriftIssue>
    ) {
        if proposal.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if proposal.performsPlatformCalendarWork {
            issues.insert(.platformCalendarImplementation)
        }
        if proposal.writesScheduleAutomatically {
            issues.insert(.silentRescheduleRisk)
        }
    }

    private func validateSourceAndPrivacy(
        _ signal: AmbitionsOSRealityDriftSignal,
        issues: inout Set<AmbitionsOSRealityDriftIssue>
    ) {
        if signal.sourceState.canDriveSourceSensitiveRecommendation == false ||
            signal.reviewState.blocksAutomaticMutation {
            issues.insert(.sourceReviewRequired)
        }
        if signal.freshnessState.blocksHighRiskUse {
            issues.insert(.staleSourceReviewRequired)
        }
        if signal.privacyClass == .sensitive && signal.isExternalProjectionSafe == false {
            issues.insert(.privateExternalProjectionRisk)
        }
    }

    private func validateCommitmentProjection(
        _ projection: AmbitionsOSCommitmentTimeProjection,
        issues: inout Set<AmbitionsOSRealityDriftIssue>
    ) {
        let commitmentIssues = AmbitionsOSCommitmentTimeValidator().validate(projection)
        if commitmentIssues.contains(.protectedTimeViolation) {
            issues.insert(.protectedTimeViolation)
        }
        if commitmentIssues.contains(.sourceReviewRequired) || commitmentIssues.contains(.staleDeadlineSource) {
            issues.insert(.sourceReviewRequired)
        }
        if commitmentIssues.contains(.silentRescheduleRisk) {
            issues.insert(.silentRescheduleRisk)
        }
        if commitmentIssues.contains(.platformCalendarImplementation) {
            issues.insert(.platformCalendarImplementation)
        }
        if commitmentIssues.contains(.runtimeStoreBehavior) {
            issues.insert(.runtimeStoreBehavior)
        }
    }

    private func validateProofTrust(
        _ proposal: AmbitionsOSBoundedReflowProposal,
        issues: inout Set<AmbitionsOSRealityDriftIssue>
    ) {
        if proposal.changesCommitments && proposal.proofTrustReceipts.isEmpty {
            issues.insert(.proofReceiptRequired)
        }
        let proofValidator = AmbitionsOSProofTrustValidator()
        for receipt in proposal.proofTrustReceipts {
            if proofValidator.validate(receipt: receipt).isEmpty == false {
                issues.insert(.proofTrustReviewRequired)
            }
        }
    }

    private func validateLanguage(
        _ samples: [String],
        issues: inout Set<AmbitionsOSRealityDriftIssue>
    ) {
        let blocked = ["failed", "missed", "overdue", "behind", "punished", "ruined"]
        if samples.contains(where: { sample in
            let normalized = sample.lowercased()
            return blocked.contains(where: normalized.contains)
        }) {
            issues.insert(.harmfulRecoveryLanguage)
        }
    }
}
