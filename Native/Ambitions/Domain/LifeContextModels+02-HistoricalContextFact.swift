import Foundation

struct HistoricalContextFact: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let category: HistoricalContextFactCategory
    let title: String
    let detail: String?
    let dateRange: LifeContextDateRange?
    let confidence: Double
    let sourceType: HistoricalContextFactSourceType
    let freshness: HistoricalContextFactFreshness
    let sensitivity: HistoricalContextFactSensitivity
    let runtimeUseAllowed: Bool
    let usedFor: [HistoricalContextFactUse]
    let createdAt: String
    let updatedAt: String
    let confirmedAt: String?
    let deletedAt: String?
    let pausedAt: String?

    init(
        id: String,
        category: HistoricalContextFactCategory,
        title: String,
        detail: String? = nil,
        dateRange: LifeContextDateRange? = nil,
        confidence: Double = 1,
        sourceType: HistoricalContextFactSourceType,
        freshness: HistoricalContextFactFreshness = .current,
        sensitivity: HistoricalContextFactSensitivity = .normal,
        runtimeUseAllowed: Bool = true,
        usedFor: [HistoricalContextFactUse] = [],
        createdAt: String,
        updatedAt: String,
        confirmedAt: String? = nil,
        deletedAt: String? = nil,
        pausedAt: String? = nil
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.detail = detail
        self.dateRange = dateRange
        self.confidence = confidence
        self.sourceType = sourceType
        self.freshness = freshness
        self.sensitivity = sensitivity
        self.runtimeUseAllowed = runtimeUseAllowed
        self.usedFor = usedFor
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.confirmedAt = confirmedAt
        self.deletedAt = deletedAt
        self.pausedAt = pausedAt
    }

    var isDeletedOrPaused: Bool {
        deletedAt != nil || pausedAt != nil || sourceType == .deleted || sourceType == .paused
    }

    var isRuntimeEligible: Bool {
        isDeletedOrPaused == false && (sensitivity == .normal || runtimeUseAllowed)
    }

    func markedDeleted(at timestamp: String) -> HistoricalContextFact {
        HistoricalContextFact(
            id: id,
            category: category,
            title: title,
            detail: detail,
            dateRange: dateRange,
            confidence: confidence,
            sourceType: .deleted,
            freshness: freshness,
            sensitivity: sensitivity,
            runtimeUseAllowed: runtimeUseAllowed,
            usedFor: usedFor,
            createdAt: createdAt,
            updatedAt: timestamp,
            confirmedAt: confirmedAt,
            deletedAt: timestamp,
            pausedAt: pausedAt
        )
    }

    func markedPaused(at timestamp: String) -> HistoricalContextFact {
        HistoricalContextFact(
            id: id,
            category: category,
            title: title,
            detail: detail,
            dateRange: dateRange,
            confidence: confidence,
            sourceType: .paused,
            freshness: freshness,
            sensitivity: sensitivity,
            runtimeUseAllowed: runtimeUseAllowed,
            usedFor: usedFor,
            createdAt: createdAt,
            updatedAt: timestamp,
            confirmedAt: confirmedAt,
            deletedAt: deletedAt,
            pausedAt: timestamp
        )
    }
}

struct LifeContextQuestion: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let prompt: String
    let reason: String
    let priority: Int

    init(id: String, prompt: String, reason: String, priority: Int) {
        self.id = id
        self.prompt = prompt
        self.reason = reason
        self.priority = priority
    }
}

struct LifeContextConstraintSummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let isHardConstraint: Bool

    init(id: String, title: String, detail: String, isHardConstraint: Bool) {
        self.id = id
        self.title = title
        self.detail = detail
        self.isHardConstraint = isHardConstraint
    }
}

struct LifeContextOpportunityAnchor: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let verificationStatus: LifeContextVerificationStatus

    init(id: String, title: String, detail: String, verificationStatus: LifeContextVerificationStatus) {
        self.id = id
        self.title = title
        self.detail = detail
        self.verificationStatus = verificationStatus
    }
}

struct LifeContextTravelModel: Codable, Sendable, Equatable {
    let radiusMinutes: Int?
    let radiusMiles: Double?
    let transportationAccess: LifeContextTransportationAccess
    let locationLabel: String?
    let locationPrecision: LifeContextLocationPrecision
}

struct LifeContextSourceFreshnessSummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let sourceID: String
    let label: String
    let freshness: LifeContextFreshness
    let detail: String
}

struct LifeContextSensitiveUseWarning: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let factID: String
    let title: String
    let detail: String
}

struct LifeContextHistorySummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let freshness: HistoricalContextFactFreshness
    let usedFor: [HistoricalContextFactUse]
}

enum LifeContextHistoryExclusionReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case deleted
    case paused
}

struct LifeContextHistoryExclusionSummary: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let factID: String
    let reason: LifeContextHistoryExclusionReason
}

enum LifeContextPrivacyIndexingBoundary: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case summaryOnly = "summary_only"
    case privateDetailHidden = "private_detail_hidden"
    case excludedFromRuntime = "excluded_from_runtime"
}

struct LifeContextInspectableRecord: Codable, Sendable, Equatable, Identifiable, Hashable {
    let id: String
    let title: String
    let visibleDetail: String
    let sourceLabel: String
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let confidence: Double
    let freshness: HistoricalContextFactFreshness
    let privacyIndexingBoundary: LifeContextPrivacyIndexingBoundary
    let controlActionIDs: [String]
    let inspectionSurfaceTitle: String
    let inspectionSummary: String
}

struct LifeContextRuntimeProjection: Codable, Sendable, Equatable {
    let ageYears: Int?
    let lifeStage: LifeContextLifeStage
    let availableOpportunityAnchors: [LifeContextOpportunityAnchor]
    let hardConstraints: [LifeContextConstraintSummary]
    let softConstraints: [LifeContextConstraintSummary]
    let travelModel: LifeContextTravelModel
    let eligibilityModel: [LifeContextEligibilityPathway]
    let historySummary: [LifeContextHistorySummary]
    let excludedHistorySummary: [LifeContextHistoryExclusionSummary]
    let sourceFreshnessSummary: [LifeContextSourceFreshnessSummary]
    let sensitiveUseWarnings: [LifeContextSensitiveUseWarning]
    let missingContextQuestions: [LifeContextQuestion]
}
