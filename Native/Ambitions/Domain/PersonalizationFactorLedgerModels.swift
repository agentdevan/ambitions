import Foundation

let personalizationFactorLedgerSchemaVersion = "personalization_factor_ledger.native.v1"

enum PersonalizationFactorLedgerFactorCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goal
    case timing
    case access
    case history
    case recovery
    case trust
    case proof
    case safety
    case preference
    case eligibility
    case freshness
    case sensitivity
    case replay
}

enum PersonalizationFactorLedgerFactorType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalRequirement = "goal_requirement"
    case deadlinePressure = "deadline_pressure"
    case availabilityWindow = "availability_window"
    case travelFit = "travel_fit"
    case transportationConstraint = "transportation_constraint"
    case facilityAccess = "facility_access"
    case equipmentAccess = "equipment_access"
    case historicalContext = "historical_context"
    case pastFailure = "past_failure"
    case pastSuccess = "past_success"
    case recoveryConstraint = "recovery_constraint"
    case executionBehavior = "execution_behavior"
    case timeOfDayFit = "time_of_day_fit"
    case energyPattern = "energy_pattern"
    case eligibilityPathway = "eligibility_pathway"
    case seasonality = "seasonality"
    case dependencyConstraint = "dependency_constraint"
    case budgetConstraint = "budget_constraint"
    case preference = "preference"
    case trustAllowance = "trust_allowance"
    case recentProof = "recent_proof"
    case recentDrift = "recent_drift"
    case safetyConstraint = "safety_constraint"
}

enum PersonalizationFactorLedgerSourceKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case lifeContext = "life_context"
    case recommendationTrace = "recommendation_trace"
    case receipt = "receipt"
    case runtime = "runtime"
    case replay = "replay"
}

enum PersonalizationFactorLedgerFreshnessState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case mayNeedReview = "may_need_review"
    case basedOnOlderContext = "based_on_older_context"
    case stale
}

enum PersonalizationFactorLedgerPermissionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case allowed
    case disabled
    case blocked
    case needsReview = "needs_review"
}

enum PersonalizationFactorLedgerConfidenceBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case guarded
    case moderate
    case high
    case reviewNeeded = "review_needed"
}

struct PersonalizationFactorSourceProjection: Codable, Sendable, Equatable, Hashable {
    let kind: PersonalizationFactorLedgerSourceKind
    let sourceID: String
    let sourceLabel: String
    let freshness: PersonalizationFactorLedgerFreshnessState
    let isSensitive: Bool
    let isUserOwned: Bool
    let isPresent: Bool

    init(
        kind: PersonalizationFactorLedgerSourceKind,
        sourceID: String,
        sourceLabel: String,
        freshness: PersonalizationFactorLedgerFreshnessState,
        isSensitive: Bool,
        isUserOwned: Bool = true,
        isPresent: Bool = true
    ) {
        self.kind = kind
        self.sourceID = sourceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceLabel = sourceLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.freshness = freshness
        self.isSensitive = isSensitive
        self.isUserOwned = isUserOwned
        self.isPresent = isPresent
    }
}

struct PersonalizationFactorFreshnessProjection: Codable, Sendable, Equatable, Hashable {
    let state: PersonalizationFactorLedgerFreshnessState
    let lastAffectedLabel: String
    let needsReview: Bool
    let reviewReason: String?

    init(
        state: PersonalizationFactorLedgerFreshnessState,
        lastAffectedLabel: String,
        needsReview: Bool,
        reviewReason: String? = nil
    ) {
        self.state = state
        self.lastAffectedLabel = lastAffectedLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.needsReview = needsReview
        self.reviewReason = reviewReason?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PersonalizationFactorControlProjection: Codable, Sendable, Equatable, Hashable {
    let userControlled: Bool
    let canDisable: Bool
    let allowedForRuntimeUse: Bool
    let active: Bool
    let fallbackBehaviorIfRemoved: String

    init(
        userControlled: Bool,
        canDisable: Bool,
        allowedForRuntimeUse: Bool,
        active: Bool,
        fallbackBehaviorIfRemoved: String
    ) {
        self.userControlled = userControlled
        self.canDisable = canDisable
        self.allowedForRuntimeUse = allowedForRuntimeUse
        self.active = active
        self.fallbackBehaviorIfRemoved = fallbackBehaviorIfRemoved.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PersonalizationFactorSensitiveUseProjection: Codable, Sendable, Equatable, Hashable {
    let isSensitive: Bool
    let permissionState: PersonalizationFactorLedgerPermissionState
    let sensitiveUseLabel: String
    let redactedReason: String?

    init(
        isSensitive: Bool,
        permissionState: PersonalizationFactorLedgerPermissionState,
        sensitiveUseLabel: String,
        redactedReason: String? = nil
    ) {
        self.isSensitive = isSensitive
        self.permissionState = permissionState
        self.sensitiveUseLabel = sensitiveUseLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.redactedReason = redactedReason?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PersonalizationFactorReplayProjection: Codable, Sendable, Equatable, Hashable {
    let isReplayable: Bool
    let stableFactorFingerprint: String
    let stableEvidenceIDs: [String]
    let selectedCandidateID: String?
    let rejectedCandidateIDs: [String]

    init(
        isReplayable: Bool,
        stableFactorFingerprint: String,
        stableEvidenceIDs: [String],
        selectedCandidateID: String?,
        rejectedCandidateIDs: [String]
    ) {
        self.isReplayable = isReplayable
        self.stableFactorFingerprint = stableFactorFingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stableEvidenceIDs = Self.normalized(stableEvidenceIDs)
        self.selectedCandidateID = selectedCandidateID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rejectedCandidateIDs = Self.normalized(rejectedCandidateIDs)
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
typealias RuntimeLearningSignal = CorrectionFoldRecommendationLearningInfluence

struct PersonalizationFactorLedgerFactor: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let factorType: PersonalizationFactorLedgerFactorType
    let factorCategory: PersonalizationFactorLedgerFactorCategory
    let humanReadableReason: String
    let source: PersonalizationFactorSourceProjection
    let freshness: PersonalizationFactorFreshnessProjection
    let userControlled: Bool
    let runtimeWeight: Double
    let affectedRecommendationArea: String
    let allowedForRuntimeUse: Bool
    let canDisable: Bool
    let fallbackBehaviorIfRemoved: String
    let active: Bool
    let lastAffectedLabel: String
    let control: PersonalizationFactorControlProjection
    let sensitiveUse: PersonalizationFactorSensitiveUseProjection
    let replay: PersonalizationFactorReplayProjection

    init(
        id: String,
        factorType: PersonalizationFactorLedgerFactorType,
        factorCategory: PersonalizationFactorLedgerFactorCategory,
        humanReadableReason: String,
        source: PersonalizationFactorSourceProjection,
        freshness: PersonalizationFactorFreshnessProjection,
        userControlled: Bool,
        runtimeWeight: Double,
        affectedRecommendationArea: String,
        allowedForRuntimeUse: Bool,
        canDisable: Bool,
        fallbackBehaviorIfRemoved: String,
        active: Bool,
        lastAffectedLabel: String,
        control: PersonalizationFactorControlProjection,
        sensitiveUse: PersonalizationFactorSensitiveUseProjection,
        replay: PersonalizationFactorReplayProjection
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.factorType = factorType
        self.factorCategory = factorCategory
        self.humanReadableReason = sensitiveUse.redactedReason?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? humanReadableReason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.source = source
        self.freshness = freshness
        self.userControlled = userControlled
        self.runtimeWeight = runtimeWeight
        self.affectedRecommendationArea = affectedRecommendationArea.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowedForRuntimeUse = allowedForRuntimeUse
        self.canDisable = canDisable
        self.fallbackBehaviorIfRemoved = fallbackBehaviorIfRemoved.trimmingCharacters(in: .whitespacesAndNewlines)
        self.active = active
        self.lastAffectedLabel = lastAffectedLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        self.control = control
        self.sensitiveUse = sensitiveUse
        self.replay = replay
    }
}

struct PersonalizationFactorLedgerSourceProjection: Codable, Sendable, Equatable, Hashable {
    let sourceIDs: [String]
    let sourceKinds: [String]
    let currentFactorCount: Int
    let reviewFactorCount: Int
    let blockedFactorCount: Int
}

struct PersonalizationFactorLedgerFreshnessProjection: Codable, Sendable, Equatable, Hashable {
    let currentFactorCount: Int
    let needsReviewFactorCount: Int
    let staleFactorCount: Int
}

struct PersonalizationFactorLedgerControlProjection: Codable, Sendable, Equatable, Hashable {
    let userControlledFactorIDs: [String]
    let disabledFactorIDs: [String]
    let blockedFactorIDs: [String]
}

struct PersonalizationFactorLedgerSensitiveUseProjection: Codable, Sendable, Equatable, Hashable {
    let usedFactorIDs: [String]
    let blockedFactorIDs: [String]
    let permissionRequiredFactorIDs: [String]
    let redactedFactorIDs: [String]
}

struct PersonalizationFactorLedgerReplayProjection: Codable, Sendable, Equatable, Hashable {
    let canReplay: Bool
    let stableFingerprint: String
    let stableFactorIDs: [String]
    let selectedCandidateID: String
    let rejectedCandidateIDs: [String]
}

struct PersonalizationFactorLedgerExplanationProjection: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let sourceLabels: [String]
    let whyThisChangesPlans: [String]
    let confidenceLabel: String
}

struct PersonalizationFactorLedger: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let recommendationID: String
    let generatedAt: String
    let runtimeVersion: String
    let userContextVersion: String
    let goalID: String?
    let selectedCandidateID: String
    let rejectedCandidateIDs: [String]
    let factors: [PersonalizationFactorLedgerFactor]
    let confidenceBand: PersonalizationFactorLedgerConfidenceBand
    let missingContextQuestions: [String]
    let sensitiveFactorUsage: PersonalizationFactorLedgerSensitiveUseProjection
    let explanationProjection: PersonalizationFactorLedgerExplanationProjection
    let replayProjection: PersonalizationFactorLedgerReplayProjection
    let personalRuntimeLearningSignals: [RuntimeLearningSignal]
    let sourceProjection: PersonalizationFactorLedgerSourceProjection
    let freshnessProjection: PersonalizationFactorLedgerFreshnessProjection
    let controlProjection: PersonalizationFactorLedgerControlProjection

    init(
        recommendationID: String,
        generatedAt: String,
        runtimeVersion: String,
        userContextVersion: String,
        goalID: String?,
        selectedCandidateID: String,
        rejectedCandidateIDs: [String],
        factors: [PersonalizationFactorLedgerFactor],
        confidenceBand: PersonalizationFactorLedgerConfidenceBand,
        missingContextQuestions: [String],
        sensitiveFactorUsage: PersonalizationFactorLedgerSensitiveUseProjection,
        explanationProjection: PersonalizationFactorLedgerExplanationProjection,
        replayProjection: PersonalizationFactorLedgerReplayProjection,
        personalRuntimeLearningSignals: [RuntimeLearningSignal] = [],
        sourceProjection: PersonalizationFactorLedgerSourceProjection,
        freshnessProjection: PersonalizationFactorLedgerFreshnessProjection,
        controlProjection: PersonalizationFactorLedgerControlProjection
    ) {
        self.id = "personalization-factor-ledger.\(recommendationID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "unscoped" : recommendationID)"
        self.recommendationID = recommendationID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.runtimeVersion = runtimeVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userContextVersion = userContextVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.goalID = goalID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedCandidateID = selectedCandidateID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rejectedCandidateIDs = Self.normalized(rejectedCandidateIDs)
        self.factors = factors.sorted { lhs, rhs in
            if lhs.factorType.rawValue != rhs.factorType.rawValue {
                return lhs.factorType.rawValue < rhs.factorType.rawValue
            }
            return lhs.id < rhs.id
        }
        self.confidenceBand = confidenceBand
        self.missingContextQuestions = Self.normalized(missingContextQuestions)
        self.sensitiveFactorUsage = sensitiveFactorUsage
        self.explanationProjection = explanationProjection
        self.replayProjection = replayProjection
        self.personalRuntimeLearningSignals = personalRuntimeLearningSignals.sorted { lhs, rhs in
            if lhs.signalType.rawValue != rhs.signalType.rawValue {
                return lhs.signalType.rawValue < rhs.signalType.rawValue
            }
            return lhs.id < rhs.id
        }
        self.sourceProjection = sourceProjection
        self.freshnessProjection = freshnessProjection
        self.controlProjection = controlProjection
    }

    var sourceIDs: [String] {
        sourceProjection.sourceIDs
    }

    var stableFactorIDs: [String] {
        replayProjection.stableFactorIDs
    }

    var learningSignalIDs: [String] {
        personalRuntimeLearningSignals.map(\.id).sorted()
    }

    var learningSignalSummaries: [String] {
        personalRuntimeLearningSignals.map(\.personalRuntimeInspectableSummary)
    }

    var visibleCopy: [String] {
        [
            selectedCandidateID,
            explanationProjection.summary
        ] +
            factors.flatMap {
                [
                    $0.factorType.rawValue,
                    $0.humanReadableReason,
                    $0.source.sourceLabel,
                    $0.freshness.lastAffectedLabel,
                    $0.fallbackBehaviorIfRemoved
                ]
            } +
            personalRuntimeLearningSignals.flatMap { [
                $0.id,
                $0.correctionRecordID,
                $0.recommendationID,
                $0.rejectionReason.rawValue,
                $0.adjustment.rawValue,
                $0.personalRuntimeInspectableSummary,
                $0.personalRuntimeResetRoute,
                $0.personalRuntimeDeleteRoute,
                $0.personalRuntimeInspectionLabel,
                $0.receiptID
            ] }
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
