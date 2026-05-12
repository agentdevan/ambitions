import Foundation

let ambitionsOSPrivacySafetySchemaVersion = "ambitionsos_privacy_safety.native.v1"

enum AmbitionsOSPrivacySensitiveArea: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case medical
    case legal
    case financial
    case immigration
    case education
    case careerSensitive = "career_sensitive"
    case identity
    case family
    case relationship
    case minorsStudentData = "minors_student_data"
    case location
    case publicReputation = "public_reputation"
    case safetyCrisis = "safety_crisis"
    case politicalCivic = "political_civic"
    case thirdPartyPersonalData = "third_party_personal_data"
    case privateAttachment = "private_attachment"
}

enum AmbitionsOSPrivacyPermissionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case remember
    case privateOnly = "private"
    case hide
    case askLater = "ask_later"
    case reject
    case forget
    case correct
    case stale
    case sourceBacked = "source_backed"
    case inferredNeedsReview = "inferred_needs_review"
    case localOnly = "local_only"
    case externalBlocked = "external_blocked"
    case deletePending = "delete_pending"

    var blocksProjection: Bool {
        switch self {
        case .hide, .reject, .forget, .inferredNeedsReview, .externalBlocked, .deletePending:
            return true
        case .remember, .privateOnly, .askLater, .correct, .stale, .sourceBacked, .localOnly:
            return false
        }
    }
}

enum AmbitionsOSPrivacyProjectionPolicy: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fullLocal = "full_local"
    case redactedLocal = "redacted_local"
    case reviewOnly = "review_only"
    case externalRedacted = "external_redacted"
    case externalBlocked = "external_blocked"
    case hidden
}

enum AmbitionsOSPrivacyToolIntent: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case readLocalSummary = "read_local_summary"
    case proposeMemoryChange = "propose_memory_change"
    case prepareExport = "prepare_export"
    case projectExternally = "project_externally"
    case invokeAdapter = "invoke_adapter"
    case mutateGraph = "mutate_graph"
}

enum AmbitionsOSPrivacySafetyIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unsupportedSchema = "unsupported_schema"
    case malformedPolicy = "malformed_policy"
    case inferredMemoryTreatedAsFact = "inferred_memory_treated_as_fact"
    case sensitiveAreaNeedsReview = "sensitive_area_needs_review"
    case externalProjectionBlocked = "external_projection_blocked"
    case rawSensitiveExternalProjection = "raw_sensitive_external_projection"
    case missingRedactionSummary = "missing_redaction_summary"
    case deletePendingProjection = "delete_pending_projection"
    case toolApprovalRequired = "tool_approval_required"
    case deterministicFallbackMissing = "deterministic_fallback_missing"
    case privacyReceiptMissing = "privacy_receipt_missing"
    case hiddenMutationRisk = "hidden_mutation_risk"
    case runtimeStoreBehavior = "runtime_store_behavior"
}

struct AmbitionsOSPrivacyReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
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

struct AmbitionsOSPrivacySafetyPolicy: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let objectID: String
    let surface: AmbitionsOSControlPlaneSurface
    let permissionState: AmbitionsOSPrivacyPermissionState
    let privacyClass: HumanProgressPrivacyClass
    let sensitiveAreas: [AmbitionsOSPrivacySensitiveArea]
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let projectionPolicy: AmbitionsOSPrivacyProjectionPolicy
    let toolIntent: AmbitionsOSPrivacyToolIntent
    let toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState
    let deterministicFallbackAvailable: Bool
    let redactionSummary: String
    let receipts: [AmbitionsOSPrivacyReceipt]
    let changesAppState: Bool
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let schemaVersion: String

    init(
        id: String,
        objectID: String,
        surface: AmbitionsOSControlPlaneSurface,
        permissionState: AmbitionsOSPrivacyPermissionState,
        privacyClass: HumanProgressPrivacyClass,
        sensitiveAreas: [AmbitionsOSPrivacySensitiveArea] = [],
        sourceState: HumanProgressSourceState = .userConfirmed,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .ready,
        projectionPolicy: AmbitionsOSPrivacyProjectionPolicy = .redactedLocal,
        toolIntent: AmbitionsOSPrivacyToolIntent = .readLocalSummary,
        toolApprovalState: AmbitionsOSLocalLanguageToolApprovalState = .reviewOnly,
        deterministicFallbackAvailable: Bool = true,
        redactionSummary: String,
        receipts: [AmbitionsOSPrivacyReceipt],
        changesAppState: Bool = false,
        runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly,
        schemaVersion: String = ambitionsOSPrivacySafetySchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.objectID = objectID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.permissionState = permissionState
        self.privacyClass = privacyClass
        self.sensitiveAreas = Array(Set(sensitiveAreas)).sorted { $0.rawValue < $1.rawValue }
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.projectionPolicy = projectionPolicy
        self.toolIntent = toolIntent
        self.toolApprovalState = toolApprovalState
        self.deterministicFallbackAvailable = deterministicFallbackAvailable
        self.redactionSummary = redactionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.receipts = receipts.sorted { $0.id < $1.id }
        self.changesAppState = changesAppState
        self.runtimeBoundary = runtimeBoundary
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            objectID.isEmpty == false &&
            schemaVersion == ambitionsOSPrivacySafetySchemaVersion &&
            receipts.allSatisfy(\.isWellFormed)
    }

    var isSensitive: Bool {
        privacyClass == .sensitive ||
            privacyClass == .deletePending ||
            sensitiveAreas.isEmpty == false
    }

    var projectsExternally: Bool {
        surface == .externalProjection ||
            projectionPolicy == .externalRedacted ||
            projectionPolicy == .externalBlocked
    }

    var hasReviewReadySource: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState == .ready
    }
}

enum AmbitionsOSPrivacySafetyClassificationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case local
    case localRedacted
    case externalRedacted
    case blocked
    case unsafe
}

struct AmbitionsOSPrivacySafetyClassification: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let policyID: String
    let humanProgressPrivacyClass: HumanProgressPrivacyClass
    let actionReceiptPrivacyLevel: ActionReceiptPrivacyLevel
    let eventLedgerPrivacyClassification: EventLedgerPrivacyClassification
    let sideEffectLedgerBoundary: SideEffectLedgerBoundary
    let projectionPolicy: AmbitionsOSPrivacyProjectionPolicy
    let localProjectionOnly: Bool
    let requiresUserReview: Bool
    let requiresRedaction: Bool
    let receiptCompatible: Bool
    let externallyProjectable: Bool
    let classification: AmbitionsOSPrivacySafetyClassificationKind
    let issues: [AmbitionsOSPrivacySafetyIssue]
    let issueFingerprint: String

    init(
        policy: AmbitionsOSPrivacySafetyPolicy,
        issues: [AmbitionsOSPrivacySafetyIssue]
    ) {
        let issueSet = Set(issues)
        let isBlocked = policy.permissionState == .deletePending || policy.permissionState == .externalBlocked ||
            policy.permissionState == .hide || policy.permissionState == .reject || policy.permissionState == .forget
        let runtimeUnsafe = issueSet.contains(.runtimeStoreBehavior) || issueSet.contains(.hiddenMutationRisk)
        let requiresRedaction = policy.projectionPolicy == .redactedLocal ||
            policy.projectionPolicy == .externalRedacted ||
            policy.isSensitive
        let requiresReview = isBlocked ||
            policy.reviewState != .ready ||
            policy.sensitiveAreas.isEmpty == false
        let canProjectExternally = policy.projectsExternally &&
            issueSet.contains(.externalProjectionBlocked) == false &&
            issueSet.contains(.deletePendingProjection) == false &&
            policy.permissionState.blocksProjection == false
        let actionReceiptPrivacyLevel: ActionReceiptPrivacyLevel = {
            if isBlocked || policy.projectionPolicy == .hidden {
                return .unavailable
            }
            if requiresRedaction || policy.privacyClass == .sensitive {
                return .redacted
            }
            if policy.privacyClass == .shareableByUser {
                return .safeToShow
            }
            return .privateItem
        }()
        let eventLedgerPrivacyClassification: EventLedgerPrivacyClassification = {
            switch policy.privacyClass {
            case .deletePending, .externalRedacted, .privateLife:
                return .privateUserText
            case .sensitive:
                return .sensitive
            case .shareableByUser:
                return .standard
            }
        }()
        let sideEffectLedgerBoundary: SideEffectLedgerBoundary = {
            if isBlocked || issueSet.contains(.deletePendingProjection) {
                return .privacySensitive
            }
            if runtimeUnsafe {
                return .destructive
            }
            if canProjectExternally && requiresReview {
                return .privacySensitive
            }
            if canProjectExternally {
                return .externalEffect
            }
            if requiresReview {
                return .confirmationGate
            }
            if policy.changesAppState {
                return .destructive
            }
            return .localOnly
        }()
        let classification: AmbitionsOSPrivacySafetyClassificationKind = {
            if isBlocked || issueSet.contains(.deletePendingProjection) || issueSet.contains(.externalProjectionBlocked) {
                return .blocked
            }
            if runtimeUnsafe || issueSet.contains(.toolApprovalRequired) {
                return .unsafe
            }
            if canProjectExternally && requiresReview {
                return .externalRedacted
            }
            if requiresRedaction {
                return .localRedacted
            }
            return .local
        }()

        self.id = AmbitionsOSPrivacySafetyClassification.makeID(
            policyID: policy.id,
            objectID: policy.objectID,
            issues: issues
        )
        self.policyID = policy.id
        self.humanProgressPrivacyClass = policy.privacyClass
        self.actionReceiptPrivacyLevel = actionReceiptPrivacyLevel
        self.eventLedgerPrivacyClassification = eventLedgerPrivacyClassification
        self.sideEffectLedgerBoundary = sideEffectLedgerBoundary
        self.projectionPolicy = policy.projectionPolicy
        self.localProjectionOnly = canProjectExternally == false
        self.requiresUserReview = requiresReview
        self.requiresRedaction = requiresRedaction
        self.receiptCompatible = issueSet.contains(.privacyReceiptMissing) == false
        self.externallyProjectable = canProjectExternally
        self.classification = classification
        self.issues = issues.sorted { $0.rawValue < $1.rawValue }
        self.issueFingerprint = AmbitionsOSPrivacySafetyClassification.makeFingerprint(policy: policy, issues: issues)
    }

    var isGreen: Bool {
        switch classification {
        case .local, .localRedacted:
            return true
        case .externalRedacted, .blocked, .unsafe:
            return false
        }
    }

    private static func makeFingerprint(
        policy: AmbitionsOSPrivacySafetyPolicy,
        issues: [AmbitionsOSPrivacySafetyIssue]
    ) -> String {
        let issueList = issues
            .sorted { $0.rawValue < $1.rawValue }
            .map(\.rawValue)
            .joined(separator: "|")
        let sensitiveAreas = policy.sensitiveAreas
            .map(\.rawValue)
            .joined(separator: "|")
        let receiptIDs = policy.receipts
            .map(\.id)
            .sorted()
            .joined(separator: "|")
        return "\(issueList)::\(sensitiveAreas)::\(receiptIDs)"
    }

    private static func makeID(policyID: String, objectID: String, issues: [AmbitionsOSPrivacySafetyIssue]) -> String {
        let issueHash = issues
            .map(\.rawValue)
            .sorted()
            .joined(separator: "|")
        return "\(policyID)|\(objectID)|\(issueHash)"
    }
}

struct AmbitionsOSPrivacySafetyValidator: Sendable, Equatable, Hashable {
    func classify(_ policy: AmbitionsOSPrivacySafetyPolicy) -> AmbitionsOSPrivacySafetyClassification {
        let issues = validate(policy)
        return AmbitionsOSPrivacySafetyClassification(policy: policy, issues: issues)
    }

    func validate(_ policy: AmbitionsOSPrivacySafetyPolicy) -> [AmbitionsOSPrivacySafetyIssue] {
        var issues: Set<AmbitionsOSPrivacySafetyIssue> = []

        validateShape(policy, issues: &issues)
        validateMemoryPermission(policy, issues: &issues)
        validateProjection(policy, issues: &issues)
        validateToolFallbackAndReceipts(policy, issues: &issues)
        validateRuntime(policy, issues: &issues)

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    private func validateShape(
        _ policy: AmbitionsOSPrivacySafetyPolicy,
        issues: inout Set<AmbitionsOSPrivacySafetyIssue>
    ) {
        if policy.schemaVersion != ambitionsOSPrivacySafetySchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if policy.isWellFormed == false {
            issues.insert(.malformedPolicy)
        }
    }

    private func validateMemoryPermission(
        _ policy: AmbitionsOSPrivacySafetyPolicy,
        issues: inout Set<AmbitionsOSPrivacySafetyIssue>
    ) {
        if policy.permissionState == .inferredNeedsReview && policy.reviewState == .ready {
            issues.insert(.inferredMemoryTreatedAsFact)
        }
        if policy.isSensitive && policy.reviewState != .ready {
            issues.insert(.sensitiveAreaNeedsReview)
        }
        if policy.permissionState == .deletePending && policy.projectionPolicy != .hidden {
            issues.insert(.deletePendingProjection)
        }
    }

    private func validateProjection(
        _ policy: AmbitionsOSPrivacySafetyPolicy,
        issues: inout Set<AmbitionsOSPrivacySafetyIssue>
    ) {
        if policy.permissionState.blocksProjection && policy.projectionPolicy != .hidden {
            issues.insert(.externalProjectionBlocked)
        }
        if policy.projectsExternally && policy.isSensitive && policy.projectionPolicy != .externalRedacted {
            issues.insert(.rawSensitiveExternalProjection)
        }
        if policy.projectsExternally && policy.redactionSummary.isEmpty {
            issues.insert(.missingRedactionSummary)
        }
    }

    private func validateToolFallbackAndReceipts(
        _ policy: AmbitionsOSPrivacySafetyPolicy,
        issues: inout Set<AmbitionsOSPrivacySafetyIssue>
    ) {
        if policy.toolIntent != .readLocalSummary &&
            policy.toolApprovalState != .userApproved &&
            policy.toolApprovalState != .reviewOnly {
            issues.insert(.toolApprovalRequired)
        }
        if policy.deterministicFallbackAvailable == false {
            issues.insert(.deterministicFallbackMissing)
        }
        if policy.receipts.isEmpty || policy.receipts.contains(where: { $0.userReviewed == false }) {
            issues.insert(.privacyReceiptMissing)
        }
    }

    private func validateRuntime(
        _ policy: AmbitionsOSPrivacySafetyPolicy,
        issues: inout Set<AmbitionsOSPrivacySafetyIssue>
    ) {
        if policy.changesAppState {
            issues.insert(.hiddenMutationRisk)
        }
        if policy.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }
    }
}
