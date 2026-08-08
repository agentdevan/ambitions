import Foundation

// swiftlint:disable:next identifier_name
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

enum SourceAtlasPublicPlanningConsumerKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case career
    case education
    case hobby
    case credential

    var approvedDomainIDs: Set<String> {
        switch self {
        case .career:
            ["occupation_foundation"]
        case .education, .credential:
            ["education_credentialing"]
        case .hobby:
            ["hobbies_recreation"]
        }
    }
}

enum SourceAtlasPublicPlanningArtifactIdentityOrigin: String, Codable, Sendable, Equatable, Hashable {
    case approvedPublicRegistry = "approved_public_registry"
    case derivedFromPrivateState = "derived_from_private_state"
}

enum SourceAtlasPublicPlanningConsumerOperation: String, Codable, Sendable, Equatable, Hashable {
    case validateBoundary = "validate_boundary"
    case readVerifiedLocalArtifact = "read_verified_local_artifact"
    case fetchAllowlistedArtifact = "fetch_allowlisted_artifact"
    case projectForLocalPlanning = "project_for_local_planning"
}

enum SourceAtlasPublicPlanningConsumerIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case contextUnavailable = "context_unavailable"
    case ownershipViolation = "ownership_violation"
    case privateField = "private_field"
    case derivedArtifactIdentity = "derived_artifact_identity"
    case openEndedQuery = "open_ended_query"
    case artifactMismatch = "artifact_mismatch"
    case unsupportedArtifactID = "unsupported_artifact_id"
    case domainMismatch = "domain_mismatch"
    case unsupportedSource = "unsupported_source"
    case invalidOperationOrder = "invalid_operation_order"
    case networkBeforeValidation = "network_before_validation"
}

struct SourceAtlasPublicPlanningConsumerRequest: Sendable, Equatable, Hashable {
    let consumer: SourceAtlasPublicPlanningConsumerKind
    let context: SourceAtlasPublicPlanningContext
    let artifactID: String
    let domainID: String
    let sourceID: String
    let artifactIdentityOrigin: SourceAtlasPublicPlanningArtifactIdentityOrigin
    let openEndedQuery: String?
    let boundaryFields: [String: String]
    let operationOrder: [SourceAtlasPublicPlanningConsumerOperation]

    init(
        consumer: SourceAtlasPublicPlanningConsumerKind,
        context: SourceAtlasPublicPlanningContext,
        artifactID: String,
        domainID: String,
        sourceID: String,
        artifactIdentityOrigin: SourceAtlasPublicPlanningArtifactIdentityOrigin,
        openEndedQuery: String?,
        boundaryFields: [String: String],
        operationOrder: [SourceAtlasPublicPlanningConsumerOperation]
    ) {
        self.consumer = consumer
        self.context = context
        self.artifactID = artifactID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainID = domainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceID = sourceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.artifactIdentityOrigin = artifactIdentityOrigin
        self.openEndedQuery = openEndedQuery?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.boundaryFields = boundaryFields
        self.operationOrder = operationOrder
    }
}

struct SourceAtlasPublicPlanningConsumerDecision: Sendable, Equatable, Hashable {
    let canExposeToLocalPlanning: Bool
    let acceptedArtifactID: String?
    let issues: [SourceAtlasPublicPlanningConsumerIssue]

    fileprivate init(
        acceptedArtifactID: String?,
        issues: [SourceAtlasPublicPlanningConsumerIssue]
    ) {
        self.canExposeToLocalPlanning = acceptedArtifactID != nil && issues.isEmpty
        self.acceptedArtifactID = self.canExposeToLocalPlanning ? acceptedArtifactID : nil
        self.issues = issues
    }
}

struct SourceAtlasPublicPlanningConsumerPolicy: Sendable, Equatable, Hashable {
    func evaluate(
        _ request: SourceAtlasPublicPlanningConsumerRequest
    ) -> SourceAtlasPublicPlanningConsumerDecision {
        var findings: Set<SourceAtlasPublicPlanningConsumerIssue> = []
        let context = request.context

        if context.canInformLocalPlanning == false ||
            context.availability.canSupportCurrentPublicReferenceUse == false ||
            context.availability.localPlanningBlocked ||
            context.useMode == .unavailable {
            findings.insert(.contextUnavailable)
        }
        if context.ownership != .publicReferenceOnly {
            findings.insert(.ownershipViolation)
        }
        if request.artifactIdentityOrigin != .approvedPublicRegistry {
            findings.insert(.derivedArtifactIdentity)
        }
        if request.openEndedQuery?.isEmpty == false {
            findings.insert(.openEndedQuery)
        }
        if request.artifactID != context.selectedPackID {
            findings.insert(.artifactMismatch)
        }
        if Self.isSupportedArtifactID(request.artifactID, domainID: request.domainID) == false {
            findings.insert(.unsupportedArtifactID)
        }
        if request.domainID != context.requestDomainID ||
            request.domainID != context.selectedPackDomainID ||
            request.consumer.approvedDomainIDs.contains(request.domainID) == false {
            findings.insert(.domainMismatch)
        }
        if context.sourceIDs.contains(request.sourceID) == false {
            findings.insert(.unsupportedSource)
        }
        if Self.hasPrivateBoundaryField(request.boundaryFields) {
            findings.insert(.privateField)
        }
        if Self.hasValidOperationOrder(request.operationOrder) == false {
            findings.insert(.invalidOperationOrder)
        }
        if Self.networkRunsBeforeValidation(request.operationOrder) {
            findings.insert(.networkBeforeValidation)
        }

        let issues = SourceAtlasPublicPlanningConsumerIssue.allCases.filter(findings.contains)
        return SourceAtlasPublicPlanningConsumerDecision(
            acceptedArtifactID: issues.isEmpty ? request.artifactID : nil,
            issues: issues
        )
    }

    private static func hasPrivateBoundaryField(_ fields: [String: String]) -> Bool {
        let records = fields.sorted { $0.key < $1.key }.map { key, value in
            SourceAtlasNoPrivateGraphEgressRecord(
                surface: .requestShape,
                identifier: key,
                inspectedValue: "\(key)=\(value)"
            )
        }
        return SourceAtlasNoPrivateGraphEgressAudit.validate(records).isEmpty == false
    }

    private static func isSupportedArtifactID(_ artifactID: String, domainID: String) -> Bool {
        let components = artifactID.split(separator: "/", omittingEmptySubsequences: false)
        guard components.count == 5,
              components[0] == "source-atlas",
              components[1] == "v1",
              components[2] == "domain",
              components[3] == Substring(domainID),
              components[4].isEmpty == false else {
            return false
        }
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-_."))
        return components.allSatisfy { component in
            component.unicodeScalars.allSatisfy(allowed.contains)
        }
    }

    private static func hasValidOperationOrder(
        _ operations: [SourceAtlasPublicPlanningConsumerOperation]
    ) -> Bool {
        operations.first == .validateBoundary &&
            operations.last == .projectForLocalPlanning &&
            Set(operations).count == operations.count
    }

    private static func networkRunsBeforeValidation(
        _ operations: [SourceAtlasPublicPlanningConsumerOperation]
    ) -> Bool {
        guard let fetchIndex = operations.firstIndex(of: .fetchAllowlistedArtifact) else {
            return false
        }
        guard let validationIndex = operations.firstIndex(of: .validateBoundary) else {
            return true
        }
        return fetchIndex < validationIndex
    }
}
