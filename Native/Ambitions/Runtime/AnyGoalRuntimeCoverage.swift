import Foundation

enum AnyGoalFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case health
    case legalCivic = "legal_civic"
    case finance
    case moving
    case creative
    case family
    case education
    case repair
    case travel
    case sensitivePrivate = "sensitive_private"
}

enum AnyGoalOperatingMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case supported
    case unsupportedCaptured = "unsupported_captured"
    case unsafeBlocked = "unsafe_blocked"
    case jurisdictionNeeded = "jurisdiction_needed"
    case awaitingSource = "awaiting_source"
    case sourceArrived = "source_arrived"
}

enum AnyGoalSupportState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceBacked = "source_backed"
    case sourceNeeded = "source_needed"
    case unsupported
}

enum AnyGoalSafetyState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case safe
    case highRisk = "high_risk"
    case unsafe
}

enum AnyGoalJurisdictionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notNeeded = "not_needed"
    case satisfied
    case needed
}

enum CoverageNeedMissingSourceType: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case publicSource = "public_source"
    case pack
    case seed
    case review
    case freshness
    case jurisdiction
    case releaseReceipt = "release_receipt"
    case rollbackReceipt = "rollback_receipt"
    case compatibility
    case highRiskReview = "high_risk_review"
}

enum CoverageNeedSeedGapCategory: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalFamily = "goal_family"
    case capability
    case starter
    case proof
    case elasticity
    case recovery
    case jurisdiction
    case replacement
    case highRiskReview = "high_risk_review"
    case sourceFreshness = "source_freshness"
    case sourceReview = "source_review"
    case compatibility
    case rollback
    case releaseReceipt = "release_receipt"
}

enum CoverageNeedRiskJurisdictionClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case standard
    case jurisdictionNeeded = "jurisdiction_needed"
    case highRiskReview = "high_risk_review"
    case unsafeBlocked = "unsafe_blocked"
    case unknownRisk = "unknown_risk"
}

enum CoverageNeedFreshnessReviewClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case currentMissing = "current_missing"
    case stale
    case reviewNeeded = "review_needed"
    case sourceChanged = "source_changed"
    case revoked
    case contradicted
    case unreviewed
    case unknown
}

enum CoverageNeedLifecycleState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localDetected = "local_detected"
    case queuedLocal = "queued_local"
    case waitingForCoverage = "waiting_for_coverage"
    case coverageArrivedCandidate = "coverage_arrived_candidate"
    case routeRecheck = "route_recheck"
    case resolved
    case blocked
}

enum CoverageNeedPrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localPrivate = "local_private"
    case localAbstract = "local_abstract"
    case remoteAbstractAllowed = "remote_abstract_allowed"
    case blockedSensitive = "blocked_sensitive"
    case highRiskReviewOnly = "high_risk_review_only"
}

enum CoverageConsentState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case notEligible = "not_eligible"
    case notRequested = "not_requested"
    case pending
    case allowed
    case denied
}

enum CoverageSourceArrivalState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noMatch = "no_match"
    case candidateForRecheck = "candidate_for_recheck"
    case blockedByAuthority = "blocked_by_authority"
}

struct AnyGoalSourceAuthoritySnapshot: Codable, Sendable, Equatable, Hashable {
    let canSupportCurrentUse: Bool
    let sourceRecordIDs: [String]
    let sourceFingerprintIDs: [String]
    let authorityIssueCodes: [String]
    let freshnessReviewClass: CoverageNeedFreshnessReviewClass

    init(
        canSupportCurrentUse: Bool,
        sourceRecordIDs: [String],
        sourceFingerprintIDs: [String],
        authorityIssueCodes: [String] = [],
        freshnessReviewClass: CoverageNeedFreshnessReviewClass = .currentMissing
    ) {
        self.canSupportCurrentUse = canSupportCurrentUse
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.sourceFingerprintIDs = Self.orderedUnique(sourceFingerprintIDs)
        self.authorityIssueCodes = Self.orderedUnique(authorityIssueCodes)
        self.freshnessReviewClass = freshnessReviewClass
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct CoverageNeed: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let operatingMode: AnyGoalOperatingMode
    let family: AnyGoalFamily
    let domain: String
    let specificDomain: String?
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let riskJurisdictionClass: CoverageNeedRiskJurisdictionClass
    let freshnessReviewClass: CoverageNeedFreshnessReviewClass
    let blockerReason: String
    let lifecycleState: CoverageNeedLifecycleState
    let privacyClass: CoverageNeedPrivacyClass
    let consentState: CoverageConsentState
    let dedupeKey: String
    let receiptRef: String
    let sourceRecordIDs: [String]

    var canBuildRemoteAbstractRequest: Bool {
        privacyClass == .remoteAbstractAllowed &&
            consentState == .allowed &&
            riskJurisdictionClass != .unsafeBlocked &&
            riskJurisdictionClass != .jurisdictionNeeded &&
            riskJurisdictionClass != .highRiskReview
    }
}

struct PrivacySafeCoverageRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let needID: String
    let dedupeKey: String
    let family: AnyGoalFamily
    let domain: String
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let riskJurisdictionClass: CoverageNeedRiskJurisdictionClass
    let redactionBoundary: String
    let consentState: CoverageConsentState
    let sourceRecordIDs: [String]
}

struct CoverageSourceArrivalSignal: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: AnyGoalFamily
    let domain: String
    let sourceFingerprintID: String
    let sourceRecordIDs: [String]
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let canSupportCurrentUse: Bool
    let authorityIssueCodes: [String]
    let releaseReceiptIDs: [String]
    let rollbackReceiptIDs: [String]
    let observedAt: String

    init(
        id: String,
        family: AnyGoalFamily,
        domain: String,
        sourceFingerprintID: String,
        sourceRecordIDs: [String],
        missingSourceTypes: [CoverageNeedMissingSourceType],
        seedGapCategories: [CoverageNeedSeedGapCategory],
        canSupportCurrentUse: Bool,
        authorityIssueCodes: [String] = [],
        releaseReceiptIDs: [String],
        rollbackReceiptIDs: [String],
        observedAt: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.family = family
        self.domain = Self.normalizedDomain(domain)
        self.sourceFingerprintID = sourceFingerprintID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = AnyGoalSourceAuthoritySnapshot.orderedUnique(sourceRecordIDs)
        self.missingSourceTypes = Self.ordered(missingSourceTypes)
        self.seedGapCategories = Self.ordered(seedGapCategories)
        self.canSupportCurrentUse = canSupportCurrentUse
        self.authorityIssueCodes = AnyGoalSourceAuthoritySnapshot.orderedUnique(authorityIssueCodes)
        self.releaseReceiptIDs = AnyGoalSourceAuthoritySnapshot.orderedUnique(releaseReceiptIDs)
        self.rollbackReceiptIDs = AnyGoalSourceAuthoritySnapshot.orderedUnique(rollbackReceiptIDs)
        self.observedAt = observedAt.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct CoverageSourceArrivalTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let needID: String
    let signalID: String
    let state: CoverageSourceArrivalState
    let sourceFingerprintID: String
    let sourceRecordIDs: [String]
    let authorityIssueCodes: [String]
    let releaseReceiptIDs: [String]
    let rollbackReceiptIDs: [String]
    let requiresLocalRouteRecheck: Bool
}

struct AnyGoalRecoveryReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let mode: AnyGoalOperatingMode
    let receiptID: String
    let replayTraceID: String
    let sourceRecordIDs: [String]
    let coverageNeedIDs: [String]
    let whatAmbitionsKnowsRoute: String
    let boundary: String
    let allowedLocalActions: [String]
    let blockedOutputs: [String]
}

struct AnyGoalJurisdictionHandoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let family: AnyGoalFamily
    let jurisdictionState: AnyGoalJurisdictionState
    let requestedJurisdictionID: String?
    let handoffRoute: String
    let blockedOutputs: [String]
}

struct AnyGoalCoverageInput: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let rawGoalText: String
    let family: AnyGoalFamily
    let domain: String
    let specificDomain: String?
    let supportState: AnyGoalSupportState
    let safetyState: AnyGoalSafetyState
    let jurisdictionState: AnyGoalJurisdictionState
    let requestedJurisdictionID: String?
    let sourceAuthority: AnyGoalSourceAuthoritySnapshot
    let missingSourceTypes: [CoverageNeedMissingSourceType]
    let seedGapCategories: [CoverageNeedSeedGapCategory]
    let consentState: CoverageConsentState
    let localOnly: Bool
    let receiptID: String
    let replayTraceID: String
    let whatAmbitionsKnowsRoute: String

    init(
        id: String,
        rawGoalText: String,
        family: AnyGoalFamily,
        domain: String,
        specificDomain: String? = nil,
        supportState: AnyGoalSupportState,
        safetyState: AnyGoalSafetyState = .safe,
        jurisdictionState: AnyGoalJurisdictionState = .notNeeded,
        requestedJurisdictionID: String? = nil,
        sourceAuthority: AnyGoalSourceAuthoritySnapshot,
        missingSourceTypes: [CoverageNeedMissingSourceType],
        seedGapCategories: [CoverageNeedSeedGapCategory],
        consentState: CoverageConsentState = .notRequested,
        localOnly: Bool = true,
        receiptID: String,
        replayTraceID: String,
        whatAmbitionsKnowsRoute: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rawGoalText = rawGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.family = family
        self.domain = Self.normalizedDomain(domain)
        self.specificDomain = Self.normalizedOptional(specificDomain)
        self.supportState = supportState
        self.safetyState = safetyState
        self.jurisdictionState = jurisdictionState
        self.requestedJurisdictionID = Self.normalizedOptional(requestedJurisdictionID)
        self.sourceAuthority = sourceAuthority
        self.missingSourceTypes = Self.ordered(missingSourceTypes)
        self.seedGapCategories = Self.ordered(seedGapCategories)
        self.consentState = consentState
        self.localOnly = localOnly
        self.receiptID = receiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayTraceID = replayTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.whatAmbitionsKnowsRoute = whatAmbitionsKnowsRoute.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct AnyGoalCoverageRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalReferenceID: String
    let family: AnyGoalFamily
    let operatingMode: AnyGoalOperatingMode
    let coverageNeeds: [CoverageNeed]
    let privacySafeRequest: PrivacySafeCoverageRequest?
    let sourceArrivalTraces: [CoverageSourceArrivalTrace]
    let recoveryReceipt: AnyGoalRecoveryReceipt
    let jurisdictionHandoff: AnyGoalJurisdictionHandoff?
    let canContinueToStepQualityFirewall: Bool
    let canGenerateVisibleStep: Bool
}
