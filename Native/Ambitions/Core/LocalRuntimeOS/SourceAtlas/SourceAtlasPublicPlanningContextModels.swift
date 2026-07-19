import Foundation

let sourceAtlasVerifiedPublicPackProviderSchemaVersion = "source_atlas_verified_public_pack_provider.native.v1"

enum SourceAtlasPublicPlanningContextRequestIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingDomainID = "missing_domain_id"
    case missingTargetPackID = "missing_target_pack_id"
    case unsafePublicSelector = "unsafe_public_selector"
}

enum SourceAtlasPublicPlanningContextUseMode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case currentReference = "current_reference"
    case reviewOnlyReference = "review_only_reference"
    case unavailable
}

struct SourceAtlasPublicPlanningContextRequest: Codable, Sendable, Equatable, Hashable {
    let domainID: String
    let targetPackID: String
    let channel: String
    let schemaVersion: String
    let appVersion: String
    let publicLocale: String?
    let publicJurisdiction: String?
    let claimID: String?
    let requirementID: String?
    let sourceID: String?
    let sourceState: SourceAtlasRequirementSourceState?
    let freshnessState: SourceAtlasRequirementFreshnessState?
    let riskClass: SourceAtlasRiskClass?

    init(
        domainID: String,
        targetPackID: String,
        channel: String,
        schemaVersion: String,
        appVersion: String,
        publicLocale: String? = nil,
        publicJurisdiction: String? = nil,
        claimID: String? = nil,
        requirementID: String? = nil,
        sourceID: String? = nil,
        sourceState: SourceAtlasRequirementSourceState? = nil,
        freshnessState: SourceAtlasRequirementFreshnessState? = nil,
        riskClass: SourceAtlasRiskClass? = nil
    ) {
        self.domainID = Self.trimmedRequired(domainID)
        self.targetPackID = Self.trimmedRequired(targetPackID)
        self.channel = Self.trimmedRequired(channel)
        self.schemaVersion = Self.trimmedRequired(schemaVersion)
        self.appVersion = Self.trimmedRequired(appVersion)
        self.publicLocale = Self.trimmedOptional(publicLocale)
        self.publicJurisdiction = Self.trimmedOptional(publicJurisdiction)
        self.claimID = Self.trimmedOptional(claimID)
        self.requirementID = Self.trimmedOptional(requirementID)
        self.sourceID = Self.trimmedOptional(sourceID)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.riskClass = riskClass
    }

    var manifestRequest: SourceAtlasPublicManifestRequest {
        SourceAtlasPublicManifestRequest(
            domainID: domainID,
            channel: channel,
            schemaVersion: schemaVersion,
            appVersion: appVersion,
            publicLocale: publicLocale
        )
    }

    var query: SourceAtlasQuery {
        SourceAtlasQuery(
            goalIntent: nil,
            domainID: domainID,
            claimID: claimID,
            requirementID: requirementID,
            sourceState: sourceState,
            freshnessState: freshnessState,
            riskClass: riskClass,
            sourceID: sourceID
        )
    }

    var validationIssues: [SourceAtlasPublicPlanningContextRequestIssue] {
        var issues: Set<SourceAtlasPublicPlanningContextRequestIssue> = []
        if domainID.isEmpty {
            issues.insert(.missingDomainID)
        }
        if targetPackID.isEmpty {
            issues.insert(.missingTargetPackID)
        }
        if SourceAtlasNoPrivateGraphEgressAudit.validate([egressRecord]).isEmpty == false {
            issues.insert(.unsafePublicSelector)
        }
        return SourceAtlasPublicPlanningContextRequestIssue.allCases.filter { issues.contains($0) }
    }

    var egressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        let values: [String: String] = [
            "app_version": appVersion,
            "channel": channel,
            "claim_id": claimID ?? "",
            "domain_id": domainID,
            "freshness_state": freshnessState?.rawValue ?? "",
            "locale": publicLocale ?? "",
            "pack_id": targetPackID,
            "public_jurisdiction": publicJurisdiction ?? "",
            "requirement_id": requirementID ?? "",
            "risk_class": riskClass?.rawValue ?? "",
            "schema_version": schemaVersion,
            "source_id": sourceID ?? "",
            "source_state": sourceState?.rawValue ?? ""
        ]
        return SourceAtlasNoPrivateGraphEgressRecord(
            surface: .requestShape,
            identifier: "source-atlas-public-planning-context-request",
            inspectedValue: values
                .filter { $0.value.isEmpty == false }
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: " ")
        )
    }

    private static func trimmedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func trimmedOptional(_ value: String?) -> String? {
        guard let value else {
            return nil
        }
        let trimmed = trimmedRequired(value)
        return trimmed.isEmpty ? nil : trimmed
    }
}

struct SourceAtlasVerifiedPublicPackProviderInput: Sendable, Equatable, Hashable {
    let request: SourceAtlasPublicPlanningContextRequest
    let fetchedCurrentPointerData: Data?
    let fetchedManifestData: Data?
    let fetchedRevocationManifestData: Data?
    let fetchedLastKnownGoodPointerData: Data?
    let fetchedLastKnownGoodManifestData: Data?
    let cachedManifest: SourceAtlasFreshnessManifest?
    let downloadedPackData: Data?
    let cachedPayload: SourceAtlasStorePayload?
    let bundledPayload: SourceAtlasStorePayload?
    let lastKnownGoodPayload: SourceAtlasStorePayload?
    let accessDecision: SourceAtlasAccessDecision
    let checkedAt: Date
    let cachePolicy: SourceAtlasLocalPackCachePolicy

    init(
        request: SourceAtlasPublicPlanningContextRequest,
        fetchedCurrentPointerData: Data? = nil,
        fetchedManifestData: Data? = nil,
        fetchedRevocationManifestData: Data? = nil,
        fetchedLastKnownGoodPointerData: Data? = nil,
        fetchedLastKnownGoodManifestData: Data? = nil,
        cachedManifest: SourceAtlasFreshnessManifest? = nil,
        downloadedPackData: Data? = nil,
        cachedPayload: SourceAtlasStorePayload? = nil,
        bundledPayload: SourceAtlasStorePayload? = nil,
        lastKnownGoodPayload: SourceAtlasStorePayload? = nil,
        accessDecision: SourceAtlasAccessDecision,
        checkedAt: Date,
        cachePolicy: SourceAtlasLocalPackCachePolicy = SourceAtlasLocalPackCachePolicy()
    ) {
        self.request = request
        self.fetchedCurrentPointerData = fetchedCurrentPointerData
        self.fetchedManifestData = fetchedManifestData
        self.fetchedRevocationManifestData = fetchedRevocationManifestData
        self.fetchedLastKnownGoodPointerData = fetchedLastKnownGoodPointerData
        self.fetchedLastKnownGoodManifestData = fetchedLastKnownGoodManifestData
        self.cachedManifest = cachedManifest
        self.downloadedPackData = downloadedPackData
        self.cachedPayload = cachedPayload
        self.bundledPayload = bundledPayload
        self.lastKnownGoodPayload = lastKnownGoodPayload
        self.accessDecision = accessDecision
        self.checkedAt = checkedAt
        self.cachePolicy = cachePolicy
    }

    var fetchInput: SourceAtlasPublicPackFetchInput {
        SourceAtlasPublicPackFetchInput(
            manifestRequest: request.manifestRequest,
            targetPackID: request.targetPackID,
            fetchedCurrentPointerData: fetchedCurrentPointerData,
            fetchedManifestData: fetchedManifestData,
            fetchedRevocationManifestData: fetchedRevocationManifestData,
            fetchedLastKnownGoodPointerData: fetchedLastKnownGoodPointerData,
            fetchedLastKnownGoodManifestData: fetchedLastKnownGoodManifestData,
            cachedManifest: cachedManifest,
            downloadedPackData: downloadedPackData,
            cachedPayload: cachedPayload,
            bundledPayload: bundledPayload,
            lastKnownGoodPayload: lastKnownGoodPayload,
            accessDecision: accessDecision,
            query: request.query,
            checkedAt: checkedAt,
            policy: cachePolicy
        )
    }
}

struct SourceAtlasPlanningOwnershipBoundary: Codable, Sendable, Equatable, Hashable {
    let sourceAtlasOwnsPublicReferenceContext: Bool
    let privateRuntimeOwnsPersonalization: Bool
    let privateRuntimeOwnsPathing: Bool
    let privateRuntimeOwnsScheduling: Bool
    let privateRuntimeOwnsReceipts: Bool
    let sourceAtlasCreatesFinalSteps: Bool
    let sourceAtlasCreatesUserSchedule: Bool
    let sourceAtlasStoresRuntimeState: Bool
    let localPlanningMustApplyUserContext: Bool

    static let publicReferenceOnly = SourceAtlasPlanningOwnershipBoundary(
        sourceAtlasOwnsPublicReferenceContext: true,
        privateRuntimeOwnsPersonalization: true,
        privateRuntimeOwnsPathing: true,
        privateRuntimeOwnsScheduling: true,
        privateRuntimeOwnsReceipts: true,
        sourceAtlasCreatesFinalSteps: false,
        sourceAtlasCreatesUserSchedule: false,
        sourceAtlasStoresRuntimeState: false,
        localPlanningMustApplyUserContext: true
    )
}

struct SourceAtlasPublicPlanningContextAvailability: Codable, Sendable, Equatable, Hashable {
    let fetchStatus: SourceAtlasPublicPackFetchStatus
    let selectedStoreSource: SourceAtlasStorePayloadSource?
    let storeSourceState: SourceAtlasStoreSourceState
    let fallbackConditions: [SourceAtlasOfflineFallbackCondition]
    let canSupportCurrentPublicReferenceUse: Bool
    let localPlanningBlocked: Bool
    let isLastKnownGood: Bool
    let isLocalFallback: Bool
}

struct SourceAtlasPublicRequirementContext: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claimID: String
    let title: String
    let kind: SourceAtlasRequirementKind
    let required: Bool
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState
    let sourceIDs: [String]
    let proofEntryIDs: [String]
}

struct SourceAtlasPublicProofNeedContext: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let requirementID: String
    let proofCandidate: SourceAtlasProofCandidate
    let proofStrength: SourceAtlasProofStrength
    let privacyClass: HumanProgressPrivacyClass
    let sourceRecordIDs: [String]
    let sourceClaimIDs: [String]
}

struct SourceAtlasPublicStarterActionContext: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let stepCandidateSeed: String
    let storesFinalSchedule: Bool
}

struct SourceAtlasPublicRiskMetadataContext: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let riskClass: SourceAtlasRiskClass
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState
    let strictReviewRequired: Bool
    let sourceBacked: Bool
}

struct SourceAtlasPublicCaveatContext: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let message: String
    let relatedIDs: [String]
}

struct SourceAtlasPublicPlanningContext: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: String
    let id: String
    let requestDomainID: String
    let selectedPackID: String
    let selectedPackDomainID: String
    let manifestVersionID: String?
    let useMode: SourceAtlasPublicPlanningContextUseMode
    let availability: SourceAtlasPublicPlanningContextAvailability
    let requirements: [SourceAtlasPublicRequirementContext]
    let proofNeeds: [SourceAtlasPublicProofNeedContext]
    let starterActions: [SourceAtlasPublicStarterActionContext]
    let sourceIDs: [String]
    let claimIDs: [String]
    let caveats: [SourceAtlasPublicCaveatContext]
    let riskMetadata: [SourceAtlasPublicRiskMetadataContext]
    let ownership: SourceAtlasPlanningOwnershipBoundary

    var canInformLocalPlanning: Bool {
        useMode != .unavailable && ownership.localPlanningMustApplyUserContext
    }
}

struct SourceAtlasVerifiedPublicPackProviderOutput: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let requestIssues: [SourceAtlasPublicPlanningContextRequestIssue]
    let fetchStatus: SourceAtlasPublicPackFetchStatus
    let fetchIssues: [SourceAtlasPublicPackFetchIssue]
    let manifestRequestIssues: [SourceAtlasPublicManifestRequestIssue]
    let packRequestIssues: [SourceAtlasPublicPackRequestIssue]
    let cacheIssues: [SourceAtlasLocalPackCacheIssue]
    let storeQuarantines: [SourceAtlasStoreQuarantine]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let context: SourceAtlasPublicPlanningContext?

    var canProvidePublicPlanningContext: Bool {
        context != nil && requestIssues.isEmpty && egressFindings.isEmpty
    }
}
