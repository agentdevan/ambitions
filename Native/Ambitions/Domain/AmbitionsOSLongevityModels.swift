import Foundation

let ambitionsOSLongevitySchemaVersion = "ambitionsos_longevity.native.v1"

enum AmbitionsOSLongevityObjectKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goal
    case path
    case step
    case proof
    case sourceClaim = "source_claim"
    case receipt
    case memory
    case archive
}

enum AmbitionsOSLongevityArchiveState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case agingReview = "aging_review"
    case archived
    case legacyPayload = "legacy_payload"
    case restoreReview = "restore_review"
    case conflictReview = "conflict_review"
    case deletePending = "delete_pending"
}

enum AmbitionsOSLongevityActionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case summarizeArchive = "summarize_archive"
    case ageArchive = "age_archive"
    case prepareRestore = "prepare_restore"
    case prepareMigrationReview = "prepare_migration_review"
    case prepareConflictReview = "prepare_conflict_review"
    case retireLegacyPayload = "retire_legacy_payload"
    case writePersistence = "write_persistence"
    case syncArchive = "sync_archive"
    case mergeMultiDeviceLedger = "merge_multi_device_ledger"
}

enum AmbitionsOSLongevityIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPlan = "malformed_plan"
    case sourceContinuityMissing = "source_continuity_missing"
    case staleHighRiskSource = "stale_high_risk_source"
    case proofSurvivalMissing = "proof_survival_missing"
    case sensitivePayloadNeedsRedaction = "sensitive_payload_needs_redaction"
    case userReviewMissing = "user_review_missing"
    case restorePathMissing = "restore_path_missing"
    case rollbackPlanMissing = "rollback_plan_missing"
    case migrationReviewMissing = "migration_review_missing"
    case conflictReviewMissing = "conflict_review_missing"
    case implementationBoundaryViolation = "implementation_boundary_violation"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
    case hostedOrRemoteDependency = "hosted_or_remote_dependency"
    case forbiddenLanguage = "forbidden_language"
    case releaseClaimWithoutEvidence = "release_claim_without_evidence"
}

struct AmbitionsOSLongevityReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let action: String
    let occurredAt: String
    let userReviewed: Bool

    init(id: String, action: String, occurredAt: String, userReviewed: Bool = true) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.action = action.trimmingCharacters(in: .whitespacesAndNewlines)
        self.occurredAt = occurredAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.userReviewed = userReviewed
    }

    var isWellFormed: Bool {
        id.isEmpty == false && action.isEmpty == false && occurredAt.isEmpty == false
    }
}

struct AmbitionsOSLongevityLegacyPayload: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let originalSchemaVersion: String
    let payloadSummary: String
    let preservedFieldNames: [String]
    let droppedFieldNames: [String]
    let proofReferenceIDs: [String]
    let sourceClaimIDs: [String]
    let migrationReviewID: String?

    init(
        id: String,
        originalSchemaVersion: String,
        payloadSummary: String,
        preservedFieldNames: [String],
        droppedFieldNames: [String] = [],
        proofReferenceIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        migrationReviewID: String? = nil
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.originalSchemaVersion = originalSchemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.payloadSummary = payloadSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.preservedFieldNames = Self.orderedUnique(preservedFieldNames)
        self.droppedFieldNames = Self.orderedUnique(droppedFieldNames)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.migrationReviewID = migrationReviewID?.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            originalSchemaVersion.isEmpty == false &&
            payloadSummary.isEmpty == false &&
            preservedFieldNames.isEmpty == false
    }

    var preservesEvidence: Bool {
        proofReferenceIDs.isEmpty == false || sourceClaimIDs.isEmpty == false
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLongevityArchivePlan: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let objectID: String
    let objectKind: AmbitionsOSLongevityObjectKind
    let ownerSurface: AmbitionsOSControlPlaneSurface
    let archiveState: AmbitionsOSLongevityArchiveState
    let actionKind: AmbitionsOSLongevityActionKind
    let summary: String
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let privacyClass: HumanProgressPrivacyClass
    let sensitiveAreas: [AmbitionsOSPrivacySensitiveArea]
    let projectionPolicy: AmbitionsOSPrivacyProjectionPolicy
    let redactionSummary: String
    let proofReferenceIDs: [String]
    let sourceClaimIDs: [String]
    let sourcePackIDs: [String]
    let legacyPayloads: [AmbitionsOSLongevityLegacyPayload]
    let receipts: [AmbitionsOSLongevityReceipt]
    let hasRestorePath: Bool
    let hasRollbackPlan: Bool
    let hasMigrationReview: Bool
    let hasConflictReview: Bool
    let changesAppState: Bool
    let dependsOnNetworkOrHostedService: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let surfaceLanguageSamples: [String]
    let schemaVersion: String

    init(
        id: String,
        objectID: String,
        objectKind: AmbitionsOSLongevityObjectKind,
        ownerSurface: AmbitionsOSControlPlaneSurface,
        archiveState: AmbitionsOSLongevityArchiveState,
        actionKind: AmbitionsOSLongevityActionKind,
        summary: String,
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .redactedLocal,
        redactionSummary: String,
        proofReferenceIDs: [String],
        sourceClaimIDs: [String] = [],
        sourcePackIDs: [String] = [],
        legacyPayloads: [AmbitionsOSLongevityLegacyPayload] = [],
        receipts: [AmbitionsOSLongevityReceipt],
        hasRestorePath: Bool = true,
        hasRollbackPlan: Bool = true,
        hasMigrationReview: Bool = true,
        hasConflictReview: Bool = true,
        changesAppState: Bool = false,
        dependsOnNetworkOrHostedService: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        surfaceLanguageSamples: [String] = [],
        schemaVersion: String = ambitionsOSLongevitySchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.objectID = objectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.objectKind = objectKind
        self.ownerSurface = ownerSurface
        self.archiveState = archiveState
        self.actionKind = actionKind
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.privacyClass = privacyClass
        self.sensitiveAreas = Array(Set(sensitiveAreas)).sorted { $0.rawValue < $1.rawValue }
        self.projectionPolicy = projectionPolicy
        self.redactionSummary = redactionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.proofReferenceIDs = Self.orderedUnique(proofReferenceIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.sourcePackIDs = Self.orderedUnique(sourcePackIDs)
        self.legacyPayloads = legacyPayloads.sorted { $0.id < $1.id }
        self.receipts = receipts.sorted { $0.id < $1.id }
        self.hasRestorePath = hasRestorePath
        self.hasRollbackPlan = hasRollbackPlan
        self.hasMigrationReview = hasMigrationReview
        self.hasConflictReview = hasConflictReview
        self.changesAppState = changesAppState
        self.dependsOnNetworkOrHostedService = dependsOnNetworkOrHostedService
        self.runtimeBoundary = runtimeBoundary
        self.surfaceLanguageSamples = surfaceLanguageSamples
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            objectID.isEmpty == false &&
            summary.isEmpty == false &&
            receipts.allSatisfy(\.isWellFormed) &&
            legacyPayloads.allSatisfy(\.isWellFormed) &&
            schemaVersion == ambitionsOSLongevitySchemaVersion
    }

    var hasReviewReadySourceContinuity: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState == .ready &&
            (sourceClaimIDs.isEmpty == false || sourcePackIDs.isEmpty == false)
    }

    var preservesProofOrLegacyEvidence: Bool {
        proofReferenceIDs.isEmpty == false ||
            legacyPayloads.contains(where: \.preservesEvidence)
    }

    var hasUserReviewedReceipt: Bool {
        receipts.contains { $0.userReviewed }
    }

    var isSensitivePayload: Bool {
        privacyClass == .sensitive ||
            privacyClass == .deletePending ||
            sensitiveAreas.isEmpty == false
    }

    var isTerminalOrDestructiveArchiveAction: Bool {
        archiveState == .deletePending ||
            actionKind == .retireLegacyPayload
    }

    var crossesLegacyOrMergeBoundary: Bool {
        actionKind == .prepareMigrationReview ||
            actionKind == .prepareConflictReview ||
            actionKind == .mergeMultiDeviceLedger ||
            legacyPayloads.isEmpty == false
    }

    var hasForbiddenLanguage: Bool {
        let blocked = [
            "app store ready",
            "testflight ready",
            "release ready",
            "device verified",
            "public accessibility compliant",
            "legal compliant",
            "privacy compliant",
            "sync ready",
            "cloud ready",
            "done forever",
            "failed goal",
            "no longer matters"
        ] + ForbiddenTopLevelTerms.terms.map { $0.lowercased() }
        let combined = surfaceLanguageSamples.joined(separator: " ").lowercased()
        return blocked.contains { combined.contains($0) }
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct AmbitionsOSLongevityValidator: Sendable, Equatable, Hashable {
    func validate(_ plan: AmbitionsOSLongevityArchivePlan) -> [AmbitionsOSLongevityIssue] {
        var issues: Set<AmbitionsOSLongevityIssue> = []

        validateShape(plan, issues: &issues)
        validateContinuity(plan, issues: &issues)
        validatePrivacyAndReview(plan, issues: &issues)
        validateRuntimeBoundary(plan, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateShape(
        _ plan: AmbitionsOSLongevityArchivePlan,
        issues: inout Set<AmbitionsOSLongevityIssue>
    ) {
        if plan.schemaVersion != ambitionsOSLongevitySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if plan.isWellFormed == false {
            issues.insert(.malformedPlan)
        }
    }

    private func validateContinuity(
        _ plan: AmbitionsOSLongevityArchivePlan,
        issues: inout Set<AmbitionsOSLongevityIssue>
    ) {
        if plan.hasReviewReadySourceContinuity == false {
            issues.insert(.sourceContinuityMissing)
        }
        if plan.freshnessState.blocksHighRiskUse {
            issues.insert(.staleHighRiskSource)
        }
        if plan.preservesProofOrLegacyEvidence == false {
            issues.insert(.proofSurvivalMissing)
        }
        if plan.crossesLegacyOrMergeBoundary && plan.hasMigrationReview == false {
            issues.insert(.migrationReviewMissing)
        }
        if plan.actionKind == .prepareConflictReview || plan.actionKind == .mergeMultiDeviceLedger {
            if plan.hasConflictReview == false {
                issues.insert(.conflictReviewMissing)
            }
        }
    }

    private func validatePrivacyAndReview(
        _ plan: AmbitionsOSLongevityArchivePlan,
        issues: inout Set<AmbitionsOSLongevityIssue>
    ) {
        if plan.isSensitivePayload &&
            (plan.projectionPolicy != .redactedLocal || plan.redactionSummary.isEmpty) {
            issues.insert(.sensitivePayloadNeedsRedaction)
        }
        if plan.hasUserReviewedReceipt == false || plan.reviewState != .ready {
            issues.insert(.userReviewMissing)
        }
        if plan.isTerminalOrDestructiveArchiveAction && plan.hasRestorePath == false {
            issues.insert(.restorePathMissing)
        }
        if plan.isTerminalOrDestructiveArchiveAction && plan.hasRollbackPlan == false {
            issues.insert(.rollbackPlanMissing)
        }
    }

    private func validateRuntimeBoundary(
        _ plan: AmbitionsOSLongevityArchivePlan,
        issues: inout Set<AmbitionsOSLongevityIssue>
    ) {
        if plan.actionKind == .writePersistence ||
            plan.actionKind == .syncArchive ||
            plan.actionKind == .mergeMultiDeviceLedger {
            issues.insert(.implementationBoundaryViolation)
        }
        if plan.changesAppState {
            issues.insert(.hiddenMutationRisk)
        }
        if plan.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
        if plan.dependsOnNetworkOrHostedService {
            issues.insert(.hostedOrRemoteDependency)
        }
        if plan.hasForbiddenLanguage {
            issues.insert(.forbiddenLanguage)
            issues.insert(.releaseClaimWithoutEvidence)
        }
    }
}
