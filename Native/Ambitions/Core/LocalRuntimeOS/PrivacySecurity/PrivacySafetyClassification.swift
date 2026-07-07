import Foundation

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
