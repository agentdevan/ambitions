import Foundation

enum ContinuitySourceAuthority: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case runtimeEvent = "runtime_event"
    case approvedProjection = "approved_projection"
    case directObjectStore = "direct_object_store"
    case remoteBackend = "remote_backend"
    case unknown

    var isApprovedContinuitySource: Bool {
        switch self {
        case .runtimeEvent, .approvedProjection:
            return true
        case .directObjectStore, .remoteBackend, .unknown:
            return false
        }
    }
}

enum ContinuityAuthorityIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case nonRuntimeSource = "non_runtime_source"
    case missingRuntimeLineage = "missing_runtime_lineage"
    case privacyClassDenied = "privacy_class_denied"
    case privatePayloadClassDenied = "private_payload_class_denied"
    case localStoreNotAuthoritative = "local_store_not_authoritative"
    case backendAuthorityAttempt = "backend_authority_attempt"
    case accountRequiredForCoreUse = "account_required_for_core_use"
}

struct ContinuityAuthorityEvidence: Sendable, Equatable {
    let envelope: CloudKitContinuityPortableRecordEnvelope
    let sourceAuthority: ContinuitySourceAuthority
    let privacyClass: RuntimePrivacyClass
    let runtimeEventID: String?
    let approvedProjectionID: String?
    let localStoreAuthoritative: Bool
    let attemptsBackendAuthority: Bool
    let accountRequiredForCoreUse: Bool

    init(
        envelope: CloudKitContinuityPortableRecordEnvelope,
        sourceAuthority: ContinuitySourceAuthority,
        privacyClass: RuntimePrivacyClass,
        runtimeEventID: String? = nil,
        approvedProjectionID: String? = nil,
        localStoreAuthoritative: Bool,
        attemptsBackendAuthority: Bool,
        accountRequiredForCoreUse: Bool
    ) {
        self.envelope = envelope
        self.sourceAuthority = sourceAuthority
        self.privacyClass = privacyClass
        self.runtimeEventID = runtimeEventID?.trimmingCharacters(in: .whitespacesAndNewlines).continuityNilIfEmpty
        self.approvedProjectionID = approvedProjectionID?.trimmingCharacters(in: .whitespacesAndNewlines).continuityNilIfEmpty
        self.localStoreAuthoritative = localStoreAuthoritative
        self.attemptsBackendAuthority = attemptsBackendAuthority
        self.accountRequiredForCoreUse = accountRequiredForCoreUse
    }
}

struct ContinuityAuthorityDecision: Codable, Sendable, Equatable, Hashable {
    let id: String
    let allowedForLocalOutbox: Bool
    let allowedForCloudKitTransport: Bool
    let requiresLocalReview: Bool
    let localStoreRemainsAuthoritative: Bool
    let issues: [ContinuityAuthorityIssue]
    let reasons: [String]
    let nonClaims: [String]
}

struct ContinuityAuthorityGate: Sendable, Equatable {
    func evaluate(_ evidence: ContinuityAuthorityEvidence) -> ContinuityAuthorityDecision {
        var issues: [ContinuityAuthorityIssue] = []
        var reasons: [String] = []

        if evidence.localStoreAuthoritative == false {
            issues.append(.localStoreNotAuthoritative)
            reasons.append("local_store_must_remain_authoritative")
        }

        if evidence.attemptsBackendAuthority {
            issues.append(.backendAuthorityAttempt)
            reasons.append("continuity_cannot_become_backend_authority")
        }

        if evidence.accountRequiredForCoreUse {
            issues.append(.accountRequiredForCoreUse)
            reasons.append("offline_core_must_not_require_account")
        }

        if evidence.sourceAuthority.isApprovedContinuitySource == false {
            issues.append(.nonRuntimeSource)
            reasons.append("continuity_envelopes_must_derive_from_runtime_events_or_approved_projections")
        }

        if hasRequiredLineage(evidence) == false {
            issues.append(.missingRuntimeLineage)
            reasons.append("continuity_envelope_missing_runtime_event_or_projection_lineage")
        }

        if privacyClassAllowsContinuityTransport(evidence.privacyClass) == false {
            issues.append(.privacyClassDenied)
            reasons.append("privacy_class_\(evidence.privacyClass.rawValue)_cannot_enter_continuity")
        }

        if evidence.envelope.payloadClass.eligibleForContinuityEnvelope == false {
            issues.append(.privatePayloadClassDenied)
            reasons.append("payload_class_\(evidence.envelope.payloadClass.rawValue)_cannot_enter_continuity")
        }

        let orderedIssues = orderedUnique(issues)
        let transportAllowed = orderedIssues.isEmpty && evidence.envelope.canEnterCloudKitContinuity

        return ContinuityAuthorityDecision(
            id: "continuity_authority.\(evidence.envelope.id)",
            allowedForLocalOutbox: evidence.localStoreAuthoritative,
            allowedForCloudKitTransport: transportAllowed,
            requiresLocalReview: transportAllowed == false,
            localStoreRemainsAuthoritative: evidence.localStoreAuthoritative,
            issues: orderedIssues,
            reasons: orderedUnique(reasons),
            nonClaims: [
                "productionCloudKitContinuityNonClaim",
                "continuityTransportIsNotBackendAuthority",
                "privateLifeGraphBackendAuthorityDenied",
            ]
        )
    }

    private func hasRequiredLineage(_ evidence: ContinuityAuthorityEvidence) -> Bool {
        switch evidence.sourceAuthority {
        case .runtimeEvent:
            return evidence.runtimeEventID != nil ||
                evidence.envelope.receiptID != nil ||
                evidence.envelope.replayTraceID != nil ||
                evidence.envelope.sourceRecordID != nil
        case .approvedProjection:
            return evidence.approvedProjectionID != nil
        case .directObjectStore, .remoteBackend, .unknown:
            return false
        }
    }

    private func privacyClassAllowsContinuityTransport(_ privacyClass: RuntimePrivacyClass) -> Bool {
        switch privacyClass {
        case .publicMetadata, .systemOwned, .standard, .syncMetadata:
            return true
        case .sensitive, .privateUserText, .localOnly, .privateSensitive, .proofRestricted, .replayRestricted, .lineageRestricted, .calendarDerived:
            return false
        }
    }

    private func orderedUnique<T: Hashable>(_ values: [T]) -> [T] {
        var seen = Set<T>()
        return values.filter { seen.insert($0).inserted }
    }
}

private extension String {
    var continuityNilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
