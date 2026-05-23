import Foundation

let stepCandidateFieldSchemaVersion = "step_candidate_field.native.v1"

enum CandidateSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalIntentCompiler = "goal_intent_compiler"
    case privateLifeRuntime = "private_life_runtime"
    case replayTrace = "replay_trace"
    case personalizationFactorLedger = "personalization_factor_ledger"
    case fallback
}

enum CandidateValidity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case preferred
    case review
    case fallback
    case blocked
    case rejected

    var sortWeight: Int {
        switch self {
        case .preferred:
            return 4
        case .review:
            return 3
        case .fallback:
            return 2
        case .blocked:
            return 1
        case .rejected:
            return 0
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .preferred:
            return "Preferred"
        case .review:
            return "Needs review"
        case .fallback:
            return "Fallback"
        case .blocked:
            return "Blocked"
        case .rejected:
            return "Rejected"
        }
    }
}

enum CandidateRiskLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case moderate
    case high

    var sortWeight: Int {
        switch self {
        case .low:
            return 2
        case .moderate:
            return 1
        case .high:
            return 0
        }
    }
}

enum StepCandidateRejectionReasonCode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case tooLong = "too_long"
    case tooHard = "too_hard"
    case tooEasy = "too_easy"
    case tooMuchEnergy = "too_much_energy"
    case wrongLocation = "wrong_location"
    case noEquipment = "no_equipment"
    case noTransportation = "no_transportation"
    case notEnoughTime = "not_enough_time"
    case emotionallyNotReady = "emotionally_not_ready"
    case blockedBySomeoneElse = "blocked_by_someone_else"
    case alreadyDidSimilar = "already_did_similar"
    case notUseful = "not_useful"
    case unsafeInjuryConcern = "unsafe_injury_concern"
    case boringLowMotivation = "boring_low_motivation"
    case preferDifferentPath = "prefer_different_path"
    case custom

    var displayLabel: String {
        switch self {
        case .tooLong: return "Too long"
        case .tooHard: return "Too hard"
        case .tooEasy: return "Too easy"
        case .tooMuchEnergy: return "Too much energy"
        case .wrongLocation: return "Wrong location"
        case .noEquipment: return "No equipment"
        case .noTransportation: return "No transportation"
        case .notEnoughTime: return "Not enough time"
        case .emotionallyNotReady: return "Emotionally not ready"
        case .blockedBySomeoneElse: return "Blocked by someone else"
        case .alreadyDidSimilar: return "Already did something similar"
        case .notUseful: return "Not useful"
        case .unsafeInjuryConcern: return "Unsafe / injury concern"
        case .boringLowMotivation: return "Boring / low motivation"
        case .preferDifferentPath: return "Prefer a different path"
        case .custom: return "Custom reason"
        }
    }

    var redactedLabel: String {
        switch self {
        case .custom:
            return "Custom reason"
        default:
            return displayLabel
        }
    }

    var isSensitive: Bool {
        switch self {
        case .emotionallyNotReady, .unsafeInjuryConcern, .custom:
            return true
        default:
            return false
        }
    }

    var learningWeight: Double {
        switch self {
        case .tooLong, .tooHard, .tooMuchEnergy, .wrongLocation, .noEquipment, .noTransportation, .notEnoughTime, .emotionallyNotReady, .blockedBySomeoneElse, .unsafeInjuryConcern:
            return 1
        case .tooEasy, .alreadyDidSimilar, .notUseful, .boringLowMotivation, .preferDifferentPath:
            return 0.72
        case .custom:
            return 0.5
        }
    }
}

struct StepCandidateRejectionReason: Codable, Sendable, Equatable, Hashable {
    let code: StepCandidateRejectionReasonCode
    let customText: String?

    init(code: StepCandidateRejectionReasonCode, customText: String? = nil) {
        self.code = code
        self.customText = Self.normalizedOptional(customText)
    }

    var displayLabel: String {
        code.displayLabel
    }

    var redactedLabel: String {
        code.redactedLabel
    }

    var storageLabel: String {
        code.rawValue
    }

    var traceLabel: String {
        code == .custom ? "custom" : code.rawValue
    }

    var hasSensitiveText: Bool {
        code.isSensitive || customText != nil
    }

    var customTextForLearning: String? {
        code == .custom ? customText : nil
    }
}

struct StepCandidateRejectionRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let candidateID: String
    let sourceCandidateID: String?
    let sourceStepID: String
    let contextFingerprint: String
    let reason: StepCandidateRejectionReason
    let skippedReason: Bool
    let recordedAt: String

    init(
        candidateID: String,
        sourceCandidateID: String? = nil,
        sourceStepID: String,
        contextFingerprint: String,
        reason: StepCandidateRejectionReason,
        skippedReason: Bool,
        recordedAt: String
    ) {
        self.candidateID = Self.normalizedRequired(candidateID)
        self.sourceCandidateID = Self.normalizedOptional(sourceCandidateID)
        self.sourceStepID = Self.normalizedRequired(sourceStepID)
        self.contextFingerprint = Self.normalizedRequired(contextFingerprint)
        self.reason = reason
        self.skippedReason = skippedReason
        self.recordedAt = Self.normalizedRequired(recordedAt)
        self.id = Self.stableIdentifier(
            prefix: "step-candidate-rejection",
            components: [
                self.candidateID,
                self.contextFingerprint,
                self.reason.storageLabel,
                self.recordedAt
            ]
        )
    }

    var isLearningQualityLow: Bool {
        skippedReason || reason.code == .custom
    }

    var publicSummary: String {
        let qualityNote = skippedReason ? " (reason skipped)" : ""
        return "\(reason.redactedLabel)\(qualityNote)"
    }
}

enum StepCandidateKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case directBest = "direct_best"
    case lighter
    case shorter
    case lowerEnergy = "lower_energy"
    case locationCompatible = "location_compatible"
    case noEquipment = "no_equipment"
    case recoverySafe = "recovery_safe"
    case adminSetup = "admin_setup"
    case learningResearch = "learning_research"
    case proofGathering = "proof_gathering"
    case prerequisite
    case maintenance
    case catchUp = "catch_up"
    case substitution
    case parallelPath = "parallel_path"
    case fallback

    var semanticLabel: String {
        switch self {
        case .directBest:
            return "Direct best"
        case .lighter:
            return "Lighter"
        case .shorter:
            return "Shorter"
        case .lowerEnergy:
            return "Lower energy"
        case .locationCompatible:
            return "Location compatible"
        case .noEquipment:
            return "No equipment"
        case .recoverySafe:
            return "Recovery safe"
        case .adminSetup:
            return "Admin setup"
        case .learningResearch:
            return "Learning and research"
        case .proofGathering:
            return "Proof gathering"
        case .prerequisite:
            return "Prerequisite"
        case .maintenance:
            return "Maintenance"
        case .catchUp:
            return "Catch up"
        case .substitution:
            return "Substitution"
        case .parallelPath:
            return "Parallel path"
        case .fallback:
            return "Fallback"
        }
    }

    var defaultValidity: CandidateValidity {
        switch self {
        case .directBest, .lighter, .shorter, .lowerEnergy, .locationCompatible, .noEquipment, .recoverySafe, .adminSetup, .learningResearch, .proofGathering, .prerequisite, .maintenance, .catchUp, .substitution, .parallelPath:
            return .review
        case .fallback:
            return .fallback
        }
    }
}

struct CandidateTradeoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let label: String
    let benefit: String
    let cost: String
    let note: String?

    init(
        id: String,
        label: String,
        benefit: String,
        cost: String,
        note: String? = nil
    ) {
        self.id = Self.normalizedRequired(id)
        self.label = Self.normalizedRequired(label)
        self.benefit = Self.normalizedRequired(benefit)
        self.cost = Self.normalizedRequired(cost)
        self.note = Self.normalizedOptional(note)
    }
}

struct CandidateRejectionRisk: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let level: CandidateRiskLevel
    let summary: String
    let factorIDs: [String]
    let requiresReview: Bool

    init(
        id: String,
        level: CandidateRiskLevel,
        summary: String,
        factorIDs: [String] = [],
        requiresReview: Bool
    ) {
        self.id = Self.normalizedRequired(id)
        self.level = level
        self.summary = Self.normalizedRequired(summary)
        self.factorIDs = Self.normalizedStrings(factorIDs)
        self.requiresReview = requiresReview
    }
}

struct CandidateScore: Codable, Sendable, Equatable, Hashable {
    let durationScore: Double
    let energyScore: Double
    let accessScore: Double
    let goalContributionScore: Double
    let deadlineContributionScore: Double
    let futurePressureScore: Double
    let opportunityCostScore: Double
    let approvalRequirementScore: Double
    let validityScore: Double
    let factorEvidenceScore: Double
    let rejectionFitScore: Double
    let evidenceFactorIDs: [String]
    let total: Double

    init(
        durationScore: Double,
        energyScore: Double,
        accessScore: Double,
        goalContributionScore: Double,
        deadlineContributionScore: Double,
        futurePressureScore: Double,
        opportunityCostScore: Double,
        approvalRequirementScore: Double,
        validityScore: Double,
        factorEvidenceScore: Double,
        rejectionFitScore: Double = 0,
        evidenceFactorIDs: [String] = []
    ) {
        self.durationScore = Self.clamp(durationScore)
        self.energyScore = Self.clamp(energyScore)
        self.accessScore = Self.clamp(accessScore)
        self.goalContributionScore = Self.clamp(goalContributionScore)
        self.deadlineContributionScore = Self.clamp(deadlineContributionScore)
        self.futurePressureScore = Self.clamp(futurePressureScore)
        self.opportunityCostScore = Self.clamp(opportunityCostScore)
        self.approvalRequirementScore = Self.clamp(approvalRequirementScore)
        self.validityScore = Self.clamp(validityScore)
        self.factorEvidenceScore = Self.clamp(factorEvidenceScore)
        self.rejectionFitScore = Self.clamp(rejectionFitScore)
        self.evidenceFactorIDs = Self.normalizedStrings(evidenceFactorIDs)
        let weightedTotal = (
            self.durationScore * 0.10 +
            self.energyScore * 0.12 +
            self.accessScore * 0.12 +
            self.goalContributionScore * 0.15 +
            self.deadlineContributionScore * 0.10 +
            self.futurePressureScore * 0.10 +
            self.opportunityCostScore * 0.10 +
            self.approvalRequirementScore * 0.06 +
            self.validityScore * 0.04 +
            self.factorEvidenceScore * 0.07 +
            self.rejectionFitScore * 0.04
        )
        self.total = Self.clamp(weightedTotal)
    }
}

enum DeadlinePressureDelta: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case preserved
    case compressed
    case delayed
    case threatensProtectedTime = "threatens_protected_time"
    case requiresDeadlineReview = "requires_deadline_review"
    case requiresScopeReview = "requires_scope_review"
    case impossible

    var accessibilityLabel: String {
        switch self {
        case .preserved:
            return "Preserved"
        case .compressed:
            return "Compressed"
        case .delayed:
            return "Delayed"
        case .threatensProtectedTime:
            return "Threatens protected time"
        case .requiresDeadlineReview:
            return "Needs deadline review"
        case .requiresScopeReview:
            return "Needs scope review"
        case .impossible:
            return "Impossible"
        }
    }
}

enum FeasibilityBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case comfortablyOnTrack = "comfortably_on_track"
    case onTrack = "on_track"
    case tightButPossible = "tight_but_possible"
    case atRisk = "at_risk"
    case unrealisticWithoutChangingScopeTimeCapacity = "unrealistic_without_changing_scope_time_capacity"
    case impossibleUnderCurrentConstraints = "impossible_under_current_constraints"

    var accessibilityLabel: String {
        switch self {
        case .comfortablyOnTrack:
            return "Comfortably on track"
        case .onTrack:
            return "On track"
        case .tightButPossible:
            return "Tight but possible"
        case .atRisk:
            return "At risk"
        case .unrealisticWithoutChangingScopeTimeCapacity:
            return "Unrealistic without changing scope, time, or capacity"
        case .impossibleUnderCurrentConstraints:
            return "Impossible under current constraints"
        }
    }
}

struct OnTrackProjection: Codable, Sendable, Equatable, Hashable {
    let isOnTrack: Bool
    let summary: String
}

struct DelayProjection: Codable, Sendable, Equatable, Hashable {
    let isDelayed: Bool
    let summary: String
    let estimatedDelayDays: Int?
}

struct CompressionProjection: Codable, Sendable, Equatable, Hashable {
    let isCompressed: Bool
    let summary: String
    let estimatedMinutesSaved: Int?
}

struct RecoveryProjection: Codable, Sendable, Equatable, Hashable {
    let isRecoverySafe: Bool
    let summary: String
    let protectsProtectedTime: Bool
}

struct PlanRiskProjection: Codable, Sendable, Equatable, Hashable {
    let feasibilityBand: FeasibilityBand
    let deadlinePressureDelta: DeadlinePressureDelta
    let threatensProtectedTime: Bool
    let requiresDeadlineReview: Bool
    let requiresScopeReview: Bool
    let isImpossible: Bool
    let summary: String
}

struct GoalTimelineSimulation: Codable, Sendable, Equatable, Hashable {
    let deadlineTargetDate: String?
    let deadlineDaysRemaining: Int?
    let estimatedMinutes: Int
    let goalContribution: Double
    let deadlineContribution: Double
    let futurePressureImpact: Double
    let opportunityCost: Double
    let openCapacityWindowCount: Int
    let protectedCapacityWindowCount: Int
    let sourceStepIsOptional: Bool
    let sourceStepIsExecutable: Bool
    let rejectionHistoryCount: Int
    let planRisk: PlanRiskProjection
    let onTrack: OnTrackProjection
    let delay: DelayProjection
    let compression: CompressionProjection
    let recovery: RecoveryProjection
    let summary: String
}

struct StepImpactSimulation: Codable, Sendable, Equatable, Hashable {
    let goalTimeline: GoalTimelineSimulation
    let kindRawValue: String
    let sourceStepID: String
    let candidateID: String
    let sourceCandidateID: String?
    let summary: String

    var deadlinePressureDelta: DeadlinePressureDelta {
        goalTimeline.planRisk.deadlinePressureDelta
    }

    var feasibilityBand: FeasibilityBand {
        goalTimeline.planRisk.feasibilityBand
    }

    var threatensProtectedTime: Bool {
        goalTimeline.planRisk.threatensProtectedTime
    }

    var requiresDeadlineReview: Bool {
        goalTimeline.planRisk.requiresDeadlineReview
    }

    var requiresScopeReview: Bool {
        goalTimeline.planRisk.requiresScopeReview
    }
}

struct CandidateRankingTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let schemaVersion: String
    let generatedAt: String
    let selectedCandidateID: String
    let rankedCandidateIDs: [String]
    let rejectedCandidateIDs: [String]
    let suppressedRejectedCandidateIDs: [String]
    let duplicateRejectedCandidateIDs: [String]
    let sourceProvenance: [CandidateSource]
    let factorEvidenceIDs: [String]
    let replayReferenceID: String?
    let replayFingerprint: String?
    let semanticSummary: String
    let factorlessRanking: Bool

    init(
        generatedAt: String,
        selectedCandidateID: String,
        rankedCandidateIDs: [String],
        rejectedCandidateIDs: [String],
        suppressedRejectedCandidateIDs: [String] = [],
        duplicateRejectedCandidateIDs: [String] = [],
        sourceProvenance: [CandidateSource] = [],
        factorEvidenceIDs: [String] = [],
        replayReferenceID: String? = nil,
        replayFingerprint: String? = nil,
        semanticSummary: String,
        factorlessRanking: Bool
    ) {
        self.schemaVersion = stepCandidateFieldSchemaVersion
        self.generatedAt = Self.normalizedRequired(generatedAt)
        self.selectedCandidateID = Self.normalizedRequired(selectedCandidateID)
        self.rankedCandidateIDs = Self.normalizedStrings(rankedCandidateIDs)
        self.rejectedCandidateIDs = Self.normalizedStrings(rejectedCandidateIDs)
        self.suppressedRejectedCandidateIDs = Self.normalizedStrings(suppressedRejectedCandidateIDs)
        self.duplicateRejectedCandidateIDs = Self.normalizedStrings(duplicateRejectedCandidateIDs)
        self.sourceProvenance = Array(Set(sourceProvenance)).sorted { $0.rawValue < $1.rawValue }
        self.factorEvidenceIDs = Self.normalizedStrings(factorEvidenceIDs)
        self.replayReferenceID = Self.normalizedOptional(replayReferenceID)
        self.replayFingerprint = Self.normalizedOptional(replayFingerprint)
        self.semanticSummary = Self.normalizedRequired(semanticSummary)
        self.factorlessRanking = factorlessRanking
        self.id = Self.stableIdentifier(
            prefix: "candidate-ranking-trace",
            components: [
                self.selectedCandidateID,
                self.replayFingerprint ?? "no-replay",
                self.generatedAt
            ]
        )
    }
}

struct StepCandidate: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceStepID: String
    let sourceCandidateID: String?
    let source: CandidateSource
    let kind: StepCandidateKind
    let title: String
    let summary: String
    let accessibilitySummary: String
    let estimatedMinutes: Int
    let estimatedEnergyCost: Double
    let accessRequirements: [String]
    let equipmentRequirements: [String]
    let facilityRequirements: [String]
    let goalContribution: Double
    let deadlineContribution: Double
    let futurePressureImpact: Double
    let opportunityCost: Double
    let approvalRequired: Bool
    let validity: CandidateValidity
    let tradeoffs: [CandidateTradeoff]
    let rejectionRisk: CandidateRejectionRisk
    let impactSimulation: StepImpactSimulation
    let score: CandidateScore
    let normalizedSemanticSignature: String

    init(
        sourceStepID: String,
        sourceCandidateID: String? = nil,
        source: CandidateSource,
        kind: StepCandidateKind,
        title: String,
        summary: String,
        accessibilitySummary: String,
        estimatedMinutes: Int,
        estimatedEnergyCost: Double,
        accessRequirements: [String] = [],
        equipmentRequirements: [String] = [],
        facilityRequirements: [String] = [],
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        approvalRequired: Bool,
        validity: CandidateValidity,
        tradeoffs: [CandidateTradeoff] = [],
        rejectionRisk: CandidateRejectionRisk,
        rejectionFitScore: Double = 0,
        evidenceFactorIDs: [String] = [],
        semanticAnchor: String,
        deadlineTargetDate: String? = nil,
        generatedAt: String? = nil,
        openCapacityWindowCount: Int = 0,
        protectedCapacityWindowCount: Int = 0,
        sourceStepIsOptional: Bool = false,
        sourceStepIsExecutable: Bool = true,
        rejectionHistoryCount: Int = 0,
        impactSimulation: StepImpactSimulation? = nil
    ) {
        self.sourceStepID = Self.normalizedRequired(sourceStepID)
        self.sourceCandidateID = Self.normalizedOptional(sourceCandidateID)
        self.source = source
        self.kind = kind
        self.title = Self.normalizedRequired(title)
        self.summary = Self.normalizedRequired(summary)
        self.accessibilitySummary = Self.normalizedRequired(accessibilitySummary)
        self.estimatedMinutes = max(0, estimatedMinutes)
        self.estimatedEnergyCost = Self.clamp(estimatedEnergyCost, lowerBound: 0, upperBound: 1)
        self.accessRequirements = Self.normalizedStrings(accessRequirements)
        self.equipmentRequirements = Self.normalizedStrings(equipmentRequirements)
        self.facilityRequirements = Self.normalizedStrings(facilityRequirements)
        self.goalContribution = Self.clamp(goalContribution)
        self.deadlineContribution = Self.clamp(deadlineContribution)
        self.futurePressureImpact = Self.clamp(futurePressureImpact)
        self.opportunityCost = Self.clamp(opportunityCost)
        self.approvalRequired = approvalRequired
        self.validity = validity
        self.tradeoffs = tradeoffs
        self.rejectionRisk = rejectionRisk

        let normalizedSemanticSignature = Self.semanticSignature(
            semanticAnchor: semanticAnchor,
            kind: kind,
            title: self.title,
            summary: self.summary,
            accessRequirements: self.accessRequirements,
            equipmentRequirements: self.equipmentRequirements,
            facilityRequirements: self.facilityRequirements,
            estimatedMinutes: self.estimatedMinutes,
            estimatedEnergyCost: self.estimatedEnergyCost,
            goalContribution: self.goalContribution,
            deadlineContribution: self.deadlineContribution,
            futurePressureImpact: self.futurePressureImpact,
            opportunityCost: self.opportunityCost,
            approvalRequired: self.approvalRequired,
            validity: validity,
            evidenceFactorIDs: evidenceFactorIDs
        )
        self.normalizedSemanticSignature = normalizedSemanticSignature
        let candidateID = Self.stableIdentifier(
            prefix: "step-candidate",
            components: [
                kind.rawValue,
                self.sourceStepID,
                normalizedSemanticSignature
            ]
        )
        self.impactSimulation = impactSimulation ?? StepImpactSimulation.make(
            goalID: nil,
            kind: kind,
            sourceStepID: self.sourceStepID,
            sourceCandidateID: self.sourceCandidateID,
            candidateID: candidateID,
            generatedAt: generatedAt,
            deadlineTargetDate: deadlineTargetDate,
            estimatedMinutes: self.estimatedMinutes,
            goalContribution: self.goalContribution,
            deadlineContribution: self.deadlineContribution,
            futurePressureImpact: self.futurePressureImpact,
            opportunityCost: self.opportunityCost,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: sourceStepIsExecutable,
            rejectionHistoryCount: rejectionHistoryCount,
            approvalRequired: approvalRequired,
            validity: validity
        )
        self.id = candidateID
        self.score = CandidateScore(
            durationScore: Self.durationScore(for: estimatedMinutes, kind: kind),
            energyScore: Self.energyScore(for: kind, estimatedEnergyCost: self.estimatedEnergyCost),
            accessScore: Self.accessScore(
                kind: kind,
                accessRequirements: self.accessRequirements,
                equipmentRequirements: self.equipmentRequirements,
                facilityRequirements: self.facilityRequirements
            ),
            goalContributionScore: self.goalContribution,
            deadlineContributionScore: self.deadlineContribution,
            futurePressureScore: self.futurePressureImpact,
            opportunityCostScore: 1 - self.opportunityCost,
            approvalRequirementScore: approvalRequired ? 0.35 : 1,
            validityScore: Self.validityScore(for: validity),
            factorEvidenceScore: Self.factorEvidenceScore(for: evidenceFactorIDs),
            rejectionFitScore: rejectionFitScore,
            evidenceFactorIDs: evidenceFactorIDs
        )
    }
}

extension StepImpactSimulation {
    static func make(
        goalID: String?,
        kind: StepCandidateKind,
        sourceStepID: String,
        sourceCandidateID: String?,
        candidateID: String,
        generatedAt: String? = nil,
        deadlineTargetDate: String?,
        estimatedMinutes: Int,
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        openCapacityWindowCount: Int,
        protectedCapacityWindowCount: Int,
        sourceStepIsOptional: Bool,
        sourceStepIsExecutable: Bool,
        rejectionHistoryCount: Int,
        approvalRequired: Bool,
        validity: CandidateValidity
    ) -> StepImpactSimulation {
        let deadlineDaysRemaining = deadlineTargetDate.flatMap { deadlineDateString -> Int? in
            guard
                let deadlineDate = DomainTimestamp.date(from: deadlineDateString),
                let generatedAt,
                let generatedAtDate = DomainTimestamp.date(from: generatedAt)
            else {
                return nil
            }
            return deadlineDays(from: generatedAtDate, to: deadlineDate)
        }
        let protectedTimeThreat = Self.protectedTimeThreat(
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: sourceStepIsExecutable,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            estimatedMinutes: estimatedMinutes,
            validity: validity
        )
        let requiresDeadlineReview = Self.requiresDeadlineReview(
            deadlineDaysRemaining: deadlineDaysRemaining,
            estimatedMinutes: estimatedMinutes,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact,
            protectedTimeThreat: protectedTimeThreat,
            sourceStepIsExecutable: sourceStepIsExecutable
        )
        let requiresScopeReview = Self.requiresScopeReview(
            kind: kind,
            goalContribution: goalContribution,
            opportunityCost: opportunityCost,
            rejectionHistoryCount: rejectionHistoryCount,
            sourceStepIsOptional: sourceStepIsOptional,
            approvalRequired: approvalRequired,
            validity: validity
        )
        let feasibilityBand = Self.feasibilityBand(
            sourceStepIsExecutable: sourceStepIsExecutable,
            deadlineDaysRemaining: deadlineDaysRemaining,
            estimatedMinutes: estimatedMinutes,
            goalContribution: goalContribution,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact,
            opportunityCost: opportunityCost,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            rejectionHistoryCount: rejectionHistoryCount,
            protectedTimeThreat: protectedTimeThreat,
            requiresDeadlineReview: requiresDeadlineReview,
            requiresScopeReview: requiresScopeReview
        )
        let deadlinePressureDelta = Self.deadlinePressureDelta(
            kind: kind,
            feasibilityBand: feasibilityBand,
            sourceStepIsExecutable: sourceStepIsExecutable,
            protectedTimeThreat: protectedTimeThreat,
            requiresDeadlineReview: requiresDeadlineReview,
            requiresScopeReview: requiresScopeReview,
            futurePressureImpact: futurePressureImpact,
            deadlineContribution: deadlineContribution,
            estimatedMinutes: estimatedMinutes
        )

        let onTrackSummary: String
        if protectedTimeThreat {
            onTrackSummary = "This threatens protected time."
        } else if feasibilityBand == .tightButPossible {
            onTrackSummary = "This keeps you on track, but it is tight."
        } else if feasibilityBand == .comfortablyOnTrack || feasibilityBand == .onTrack {
            onTrackSummary = "This keeps you on track."
        } else if feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            onTrackSummary = "This makes the deadline tighter."
        } else {
            onTrackSummary = "This likely delays the goal."
        }

        let delaySummary: String
        if deadlinePressureDelta == .delayed || feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            delaySummary = "This likely delays the goal."
        } else {
            delaySummary = "This does not visibly delay the goal."
        }

        let compressionSummary: String
        if deadlinePressureDelta == .compressed {
            compressionSummary = "This makes the deadline tighter."
        } else {
            compressionSummary = "This does not materially compress the timeline."
        }

        let recoverySummary: String
        if kind == .recoverySafe || sourceStepIsOptional || futurePressureImpact >= 0.72 {
            recoverySummary = protectedTimeThreat ? "This protects recovery, but not protected time." : "This protects recovery time."
        } else {
            recoverySummary = "This does not materially change recovery pressure."
        }

        let planRiskSummary: String
        switch deadlinePressureDelta {
        case .preserved:
            planRiskSummary = feasibilityBand == .comfortablyOnTrack ? "This keeps you on track." : onTrackSummary
        case .compressed:
            planRiskSummary = "This makes the deadline tighter."
        case .delayed:
            planRiskSummary = "This likely delays the goal."
        case .threatensProtectedTime:
            planRiskSummary = "This threatens protected time."
        case .requiresDeadlineReview:
            planRiskSummary = "This needs deadline review."
        case .requiresScopeReview:
            planRiskSummary = "This needs scope review."
        case .impossible:
            planRiskSummary = "This is impossible under current constraints."
        }

        let planRisk = PlanRiskProjection(
            feasibilityBand: feasibilityBand,
            deadlinePressureDelta: deadlinePressureDelta,
            threatensProtectedTime: protectedTimeThreat,
            requiresDeadlineReview: requiresDeadlineReview,
            requiresScopeReview: requiresScopeReview,
            isImpossible: feasibilityBand == .impossibleUnderCurrentConstraints,
            summary: planRiskSummary
        )
        let goalTimeline = GoalTimelineSimulation(
            deadlineTargetDate: deadlineTargetDate,
            deadlineDaysRemaining: deadlineDaysRemaining,
            estimatedMinutes: estimatedMinutes,
            goalContribution: goalContribution,
            deadlineContribution: deadlineContribution,
            futurePressureImpact: futurePressureImpact,
            opportunityCost: opportunityCost,
            openCapacityWindowCount: openCapacityWindowCount,
            protectedCapacityWindowCount: protectedCapacityWindowCount,
            sourceStepIsOptional: sourceStepIsOptional,
            sourceStepIsExecutable: sourceStepIsExecutable,
            rejectionHistoryCount: rejectionHistoryCount,
            planRisk: planRisk,
            onTrack: OnTrackProjection(
                isOnTrack: feasibilityBand == .comfortablyOnTrack || feasibilityBand == .onTrack || feasibilityBand == .tightButPossible,
                summary: onTrackSummary
            ),
            delay: DelayProjection(
                isDelayed: deadlinePressureDelta == .delayed || feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity || feasibilityBand == .impossibleUnderCurrentConstraints,
                summary: delaySummary,
                estimatedDelayDays: Self.estimatedDelayDays(
                    deadlineDaysRemaining: deadlineDaysRemaining,
                    feasibilityBand: feasibilityBand,
                    deadlinePressureDelta: deadlinePressureDelta
                )
            ),
            compression: CompressionProjection(
                isCompressed: deadlinePressureDelta == .compressed,
                summary: compressionSummary,
                estimatedMinutesSaved: Self.estimatedMinutesSaved(
                    kind: kind,
                    estimatedMinutes: estimatedMinutes,
                    deadlinePressureDelta: deadlinePressureDelta
                )
            ),
            recovery: RecoveryProjection(
                isRecoverySafe: kind == .recoverySafe || sourceStepIsOptional,
                summary: recoverySummary,
                protectsProtectedTime: protectedTimeThreat == false
            ),
            summary: planRiskSummary
        )

        return StepImpactSimulation(
            goalTimeline: goalTimeline,
            kindRawValue: kind.rawValue,
            sourceStepID: sourceStepID,
            candidateID: candidateID,
            sourceCandidateID: sourceCandidateID,
            summary: "\(kind.semanticLabel): \(planRiskSummary)"
        )
    }

    static func protectedTimeThreat(
        sourceStepIsOptional: Bool,
        sourceStepIsExecutable: Bool,
        openCapacityWindowCount: Int,
        protectedCapacityWindowCount: Int,
        estimatedMinutes: Int,
        validity: CandidateValidity
    ) -> Bool {
        guard sourceStepIsExecutable, validity != .blocked else { return false }
        guard protectedCapacityWindowCount > 0 else { return false }
        if openCapacityWindowCount == 0 {
            return estimatedMinutes > 0 && sourceStepIsOptional == false
        }
        return openCapacityWindowCount <= protectedCapacityWindowCount && estimatedMinutes > 20 && sourceStepIsOptional == false
    }

    static func requiresDeadlineReview(
        deadlineDaysRemaining: Int?,
        estimatedMinutes: Int,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        protectedTimeThreat: Bool,
        sourceStepIsExecutable: Bool
    ) -> Bool {
        guard sourceStepIsExecutable, protectedTimeThreat == false else { return false }
        guard let deadlineDaysRemaining else { return estimatedMinutes >= 25 && deadlineContribution < 0.7 && futurePressureImpact < 0.8 }
        if deadlineDaysRemaining <= 1 {
            return true
        }
        if deadlineDaysRemaining <= 3 {
            return estimatedMinutes >= 15 || deadlineContribution < 0.75 || futurePressureImpact < 0.72
        }
        return false
    }

    static func requiresScopeReview(
        kind: StepCandidateKind,
        goalContribution: Double,
        opportunityCost: Double,
        rejectionHistoryCount: Int,
        sourceStepIsOptional: Bool,
        approvalRequired: Bool,
        validity: CandidateValidity
    ) -> Bool {
        if validity == .blocked {
            return true
        }
        if kind == .fallback {
            return true
        }
        if approvalRequired {
            return sourceStepIsOptional || goalContribution < 0.8
        }
        if rejectionHistoryCount > 0 && goalContribution < 0.85 {
            return true
        }
        return sourceStepIsOptional && (goalContribution < 0.9 || opportunityCost > 0.55)
    }

    static func feasibilityBand(
        sourceStepIsExecutable: Bool,
        deadlineDaysRemaining: Int?,
        estimatedMinutes: Int,
        goalContribution: Double,
        deadlineContribution: Double,
        futurePressureImpact: Double,
        opportunityCost: Double,
        openCapacityWindowCount: Int,
        protectedCapacityWindowCount: Int,
        rejectionHistoryCount: Int,
        protectedTimeThreat: Bool,
        requiresDeadlineReview: Bool,
        requiresScopeReview: Bool
    ) -> FeasibilityBand {
        guard sourceStepIsExecutable else {
            return .impossibleUnderCurrentConstraints
        }

        let capacitySupport = Double(max(0, openCapacityWindowCount)) * 0.08
        let protectedPenalty = protectedCapacityWindowCount > 0 && openCapacityWindowCount == 0 ? 0.22 : 0
        let rejectionPenalty = min(0.16, Double(rejectionHistoryCount) * 0.04)
        let deadlineUrgencyPenalty: Double
        switch deadlineDaysRemaining {
        case .some(let days) where days <= 1:
            deadlineUrgencyPenalty = 0.16
        case .some(let days) where days <= 3:
            deadlineUrgencyPenalty = 0.1
        case .some(let days) where days <= 7:
            deadlineUrgencyPenalty = 0.05
        default:
            deadlineUrgencyPenalty = 0
        }

        let durationLoad: Double = (Double(estimatedMinutes) / 45.0) * 0.34
        let goalLoad: Double = (1 - goalContribution) * 0.18
        let deadlineLoad: Double = (1 - deadlineContribution) * 0.18
        let pressureLoad: Double = (1 - futurePressureImpact) * 0.17
        let opportunityLoad: Double = opportunityCost * 0.12
        let penaltyLoad: Double = rejectionPenalty + protectedPenalty + deadlineUrgencyPenalty
        let supportLoad: Double = capacitySupport
        let loadScore = Self.clamp(durationLoad + goalLoad + deadlineLoad + pressureLoad + opportunityLoad + penaltyLoad - supportLoad)

        if protectedTimeThreat {
            if deadlineDaysRemaining.map({ $0 <= 1 }) == true || loadScore >= 0.9 {
                return .impossibleUnderCurrentConstraints
            }
            return .atRisk
        }

        if requiresScopeReview && loadScore >= 0.78 {
            return .unrealisticWithoutChangingScopeTimeCapacity
        }

        if requiresDeadlineReview && loadScore >= 0.72 {
            return .atRisk
        }

        if loadScore >= 0.9 {
            return .impossibleUnderCurrentConstraints
        }
        if loadScore >= 0.78 {
            return .unrealisticWithoutChangingScopeTimeCapacity
        }
        if loadScore >= 0.62 {
            return .atRisk
        }
        if loadScore >= 0.38 {
            return .tightButPossible
        }
        if goalContribution >= 0.9 && deadlineContribution >= 0.82 && futurePressureImpact >= 0.72 {
            return .comfortablyOnTrack
        }
        return .onTrack
    }

    static func deadlinePressureDelta(
        kind: StepCandidateKind,
        feasibilityBand: FeasibilityBand,
        sourceStepIsExecutable: Bool,
        protectedTimeThreat: Bool,
        requiresDeadlineReview: Bool,
        requiresScopeReview: Bool,
        futurePressureImpact: Double,
        deadlineContribution: Double,
        estimatedMinutes: Int
    ) -> DeadlinePressureDelta {
        if feasibilityBand == .impossibleUnderCurrentConstraints || sourceStepIsExecutable == false {
            return .impossible
        }
        if protectedTimeThreat {
            return .threatensProtectedTime
        }
        if requiresScopeReview && feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            return .requiresScopeReview
        }
        if requiresDeadlineReview {
            return .requiresDeadlineReview
        }
        if kind == .lighter || kind == .shorter || kind == .lowerEnergy {
            if futurePressureImpact < 0.7 || deadlineContribution < 0.72 || estimatedMinutes >= 20 {
                return .compressed
            }
        }
        if feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity {
            return .delayed
        }
        return .preserved
    }

    static func estimatedDelayDays(
        deadlineDaysRemaining: Int?,
        feasibilityBand: FeasibilityBand,
        deadlinePressureDelta: DeadlinePressureDelta
    ) -> Int? {
        guard deadlinePressureDelta == .delayed || feasibilityBand == .atRisk || feasibilityBand == .unrealisticWithoutChangingScopeTimeCapacity || feasibilityBand == .impossibleUnderCurrentConstraints else {
            return nil
        }
        if let deadlineDaysRemaining {
            return max(1, min(7, deadlineDaysRemaining / 2 + 1))
        }
        return deadlinePressureDelta == .impossible ? nil : 2
    }

    static func estimatedMinutesSaved(
        kind: StepCandidateKind,
        estimatedMinutes: Int,
        deadlinePressureDelta: DeadlinePressureDelta
    ) -> Int? {
        guard deadlinePressureDelta == .compressed else {
            return nil
        }
        switch kind {
        case .lighter:
            return max(1, estimatedMinutes / 4)
        case .shorter:
            return max(1, estimatedMinutes / 2)
        case .lowerEnergy:
            return max(1, estimatedMinutes / 5)
        default:
            return max(1, estimatedMinutes / 6)
        }
    }

    static func deadlineDays(from generatedAt: Date, to deadlineDate: Date) -> Int {
        let interval = deadlineDate.timeIntervalSince(generatedAt)
        return Int((interval / 86_400).rounded(.down))
    }
}

struct StepCandidateField: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: String
    let id: String
    let goalID: String?
    let deadlineTargetDate: String?
    let generatedAt: String
    let sourceProvenance: [CandidateSource]
    let candidates: [StepCandidate]
    let rankingTrace: CandidateRankingTrace
    let localOnly: Bool

    init(
        goalID: String? = nil,
        deadlineTargetDate: String? = nil,
        generatedAt: String,
        sourceProvenance: [CandidateSource] = [],
        candidates: [StepCandidate],
        rankingTrace: CandidateRankingTrace,
        localOnly: Bool = true
    ) {
        self.schemaVersion = stepCandidateFieldSchemaVersion
        self.goalID = Self.normalizedOptional(goalID)
        self.deadlineTargetDate = Self.normalizedOptional(deadlineTargetDate)
        self.generatedAt = Self.normalizedRequired(generatedAt)
        self.sourceProvenance = Array(Set(sourceProvenance)).sorted { $0.rawValue < $1.rawValue }
        self.candidates = candidates
        self.rankingTrace = rankingTrace
        self.localOnly = localOnly
        self.id = Self.stableIdentifier(
            prefix: "step-candidate-field",
            components: [
                self.goalID ?? "unscoped",
                self.deadlineTargetDate ?? "no-deadline",
                self.generatedAt,
                rankingTrace.selectedCandidateID
            ]
        )
    }

    var selectedCandidate: StepCandidate? {
        candidates.first(where: { $0.id == rankingTrace.selectedCandidateID })
    }

    var selectedCandidateID: String {
        rankingTrace.selectedCandidateID
    }

    var rejectedCandidates: [StepCandidate] {
        let rejectedIDs = Set(rankingTrace.rejectedCandidateIDs + rankingTrace.suppressedRejectedCandidateIDs)
        return candidates.filter { rejectedIDs.contains($0.id) }
    }

    var candidateIDs: [String] {
        candidates.map(\.id)
    }
}

struct CandidateGenerationContext: Sendable {
    let goalID: String?
    let deadlineTargetDate: String?
    let compilerOutput: GoalIntentDayCompilerOutput?
    let runtimeOutput: PrivateLifeRuntimeKernelDecisionOutput?
    let decisionRecord: PrivateLifeRuntimeKernelDecisionRecord?
    let replayTrace: ReplayableDecisionTrace?
    let factorLedger: PersonalizationFactorLedger?
    let lifeContextProjection: LifeContextRuntimeProjection?
    let rejectionHistory: [StepCandidateRejectionRecord]
    let generatedAt: String
    let candidateLimit: Int
    let localOnly: Bool

    init(
        goalID: String? = nil,
        deadlineTargetDate: String? = nil,
        compilerOutput: GoalIntentDayCompilerOutput? = nil,
        runtimeOutput: PrivateLifeRuntimeKernelDecisionOutput? = nil,
        decisionRecord: PrivateLifeRuntimeKernelDecisionRecord? = nil,
        replayTrace: ReplayableDecisionTrace? = nil,
        factorLedger: PersonalizationFactorLedger? = nil,
        lifeContextProjection: LifeContextRuntimeProjection? = nil,
        rejectionHistory: [StepCandidateRejectionRecord] = [],
        generatedAt: String,
        candidateLimit: Int = 24,
        localOnly: Bool = true
    ) {
        self.goalID = Self.normalizedOptional(goalID)
        self.deadlineTargetDate = Self.normalizedOptional(deadlineTargetDate)
        self.compilerOutput = compilerOutput
        self.runtimeOutput = runtimeOutput
        self.decisionRecord = decisionRecord
        self.replayTrace = replayTrace
        self.factorLedger = factorLedger
        self.lifeContextProjection = lifeContextProjection
        self.rejectionHistory = rejectionHistory
        self.generatedAt = Self.normalizedRequired(generatedAt)
        self.candidateLimit = max(1, candidateLimit)
        self.localOnly = localOnly
    }

    var resolvedFactorLedger: PersonalizationFactorLedger? {
        factorLedger ?? runtimeOutput?.personalizationFactorLedger ?? decisionRecord?.personalizationFactorLedger ?? replayTrace?.personalizationFactorLedger
    }

    var sourceProvenance: [CandidateSource] {
        var sources: [CandidateSource] = []
        if compilerOutput != nil {
            sources.append(.goalIntentCompiler)
        } else {
            sources.append(.fallback)
        }
        if runtimeOutput != nil || decisionRecord != nil {
            sources.append(.privateLifeRuntime)
        }
        if replayTrace != nil {
            sources.append(.replayTrace)
        }
        if resolvedFactorLedger != nil {
            sources.append(.personalizationFactorLedger)
        }
        return Array(Set(sources)).sorted { $0.rawValue < $1.rawValue }
    }

    var contextFingerprint: String {
        CandidateSource.stableIdentifier(
            prefix: "step-candidate-context",
            components: [
                goalID ?? "unscoped",
                deadlineTargetDate ?? "no-deadline",
                compilerOutputFingerprint,
                runtimeFingerprint,
                decisionFingerprint,
                replayFingerprint,
                factorFingerprint,
                lifeContextFingerprint
            ]
        )
    }

    var relevantRejectionHistory: [StepCandidateRejectionRecord] {
        rejectionHistory.filter { $0.contextFingerprint == contextFingerprint }
    }

    private var compilerOutputFingerprint: String {
        guard let compilerOutput else { return "compiler.none" }
        return CandidateSource.stableIdentifier(
            prefix: "compiler",
            components: [
                compilerOutput.intent.id,
                compilerOutput.compiledAt,
                compilerOutput.status.rawValue,
                compilerOutput.compiledSteps.map { "\($0.id):\($0.title):\($0.orderIndex)" }.joined(separator: "|"),
                compilerOutput.blockedReasons.map(\.kind.rawValue).joined(separator: ",")
            ]
        )
    }

    private var runtimeFingerprint: String {
        runtimeOutput?.personalizationFactorLedger.replayProjection.stableFingerprint ?? "runtime.none"
    }

    private var decisionFingerprint: String {
        decisionRecord?.personalizationFactorLedger.replayProjection.stableFingerprint ?? "decision.none"
    }

    private var replayFingerprint: String {
        replayTrace?.personalizationFactorLedger.replayProjection.stableFingerprint ?? "replay.none"
    }

    private var factorFingerprint: String {
        resolvedFactorLedger?.replayProjection.stableFingerprint ?? "factors.none"
    }

    private var lifeContextFingerprint: String {
        guard let lifeContextProjection else { return "life.none" }
        let signature = [
            lifeContextProjection.lifeStage.rawValue,
            lifeContextProjection.availableOpportunityAnchors.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.hardConstraints.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.softConstraints.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.travelModel.transportationAccess.rawValue,
            lifeContextProjection.travelModel.locationPrecision.rawValue,
            lifeContextProjection.eligibilityModel.map(\.id).sorted().joined(separator: ","),
            lifeContextProjection.historySummary.map { "\($0.id):\($0.freshness.rawValue)" }.sorted().joined(separator: ","),
            lifeContextProjection.excludedHistorySummary.map { "\($0.id):\($0.reason.rawValue)" }.sorted().joined(separator: ","),
            lifeContextProjection.sourceFreshnessSummary.map { "\($0.sourceID):\($0.freshness.rawValue)" }.sorted().joined(separator: ","),
            lifeContextProjection.sensitiveUseWarnings.map(\.factID).sorted().joined(separator: ","),
            lifeContextProjection.missingContextQuestions.map(\.id).sorted().joined(separator: ",")
        ].joined(separator: "|")
        return CandidateSource.stableIdentifier(prefix: "life-context", components: [signature])
    }
}

private extension CandidateScore {
    static func clamp(_ value: Double) -> Double {
        Self.clamp(value, lowerBound: 0, upperBound: 1)
    }

    static func clamp(_ value: Double, lowerBound: Double, upperBound: Double) -> Double {
        guard upperBound >= lowerBound else { return lowerBound }
        return min(max(value, lowerBound), upperBound)
    }

    static func normalizedStrings(_ values: [String]) -> [String] {
        values
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .removingDuplicates()
            .sorted()
    }
}

private extension StepImpactSimulation {
    static func clamp(_ value: Double) -> Double {
        min(max(value, 0), 1)
    }
}

private extension CandidateValidity {
    static func normalized(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension CandidateSource {
    static func stableIdentifier(prefix: String, components: [String]) -> String {
        let seed = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .joined(separator: "|")
        let hashed = stableHash(seed)
        return "\(prefix).\(hashed)"
    }

    static func stableHash(_ value: String) -> String {
        var hash: UInt64 = 14_695_981_039_346_656_037
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1_099_511_628_211
        }
        return String(hash, radix: 16, uppercase: false)
    }
}

private extension CandidateSource {
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

    static func clamp(_ value: Double, lowerBound: Double, upperBound: Double) -> Double {
        guard upperBound >= lowerBound else { return lowerBound }
        return min(max(value, lowerBound), upperBound)
    }

}

private extension StepCandidate {
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

private extension CandidateGenerationContext {
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

private extension StepCandidateRejectionReason {
    static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private extension StepCandidateRejectionRecord {
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

private extension StepCandidateField {
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

private extension CandidateRankingTrace {
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

private extension CandidateTradeoff {
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

private extension CandidateRejectionRisk {
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

private extension Array where Element == String {
    func removingDuplicates() -> [String] {
        var seen: Set<String> = []
        return filter { seen.insert($0).inserted }
    }
}
