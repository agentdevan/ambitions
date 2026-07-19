import Foundation

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
    let sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace?
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
        sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace? = nil,
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
        self.sourceAtlasExpansionTrace = sourceAtlasExpansionTrace
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
