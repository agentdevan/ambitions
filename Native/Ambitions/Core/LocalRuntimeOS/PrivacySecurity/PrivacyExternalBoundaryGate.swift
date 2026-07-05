import Foundation

enum PrivacyExternalBoundaryKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case networkEgress = "network_egress"
    case export
    case diagnosticsRedaction = "diagnostics_redaction"
    case externalSnapshot = "external_snapshot"
    case appIntentResponse = "app_intent_response"
    case shareHandoff = "share_handoff"
    case fileProtection = "file_protection"

    var receiptAction: PrivacySecurityReceiptAction {
        switch self {
        case .networkEgress:
            return .networkEgress
        case .export:
            return .export
        case .diagnosticsRedaction:
            return .diagnosticsRedaction
        case .externalSnapshot:
            return .externalSnapshot
        case .appIntentResponse:
            return .appIntentResponse
        case .shareHandoff:
            return .shareHandoff
        case .fileProtection:
            return .fileProtection
        }
    }

    var surface: SensitiveSurface? {
        switch self {
        case .networkEgress:
            return nil
        case .export:
            return .portableExport
        case .diagnosticsRedaction:
            return .diagnosticsExport
        case .externalSnapshot:
            return .widgetSnapshot
        case .appIntentResponse:
            return .appIntentOutput
        case .shareHandoff:
            return .shareExtensionPayload
        case .fileProtection:
            return .encryptedVault
        }
    }
}

enum PrivacyExternalBoundaryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case receiptMissing = "receipt_missing"
    case receiptActionMismatch = "receipt_action_mismatch"
    case receiptDecisionMismatch = "receipt_decision_mismatch"
    case receiptDenied = "receipt_denied"
    case rawPrivateRuntimeData = "raw_private_runtime_data"
    case privateGraphTouched = "private_graph_touched"
    case boundaryReportNotGreen = "boundary_report_not_green"
    case redactedProjectionMissing = "redacted_projection_missing"
    case runtimeInspectionAnchorsMissing = "runtime_inspection_anchors_missing"
    case diagnosticsSurfaceMismatch = "diagnostics_surface_mismatch"
    case diagnosticsRedactionMissing = "diagnostics_redaction_missing"
    case externalSnapshotUnsafe = "external_snapshot_unsafe"
    case externalSnapshotPayloadMissing = "external_snapshot_payload_missing"
    case externalSnapshotChecksumMissing = "external_snapshot_checksum_missing"
    case externalSnapshotPrivatePrivacyClass = "external_snapshot_private_privacy_class"
    case externalSnapshotPrivacyProjectionMismatch = "external_snapshot_privacy_projection_mismatch"
    case externalSurfaceBridgeNotLocalOnly = "external_surface_bridge_not_local_only"
    case externalSurfaceBridgeMissingCommittedProjection = "external_surface_bridge_missing_committed_projection"
    case externalSurfaceBridgeContainsPrivateRuntimeData = "external_surface_bridge_contains_private_runtime_data"
    case fileProtectionInsufficient = "file_protection_insufficient"
    case encryptedBlobVaultRequired = "encrypted_blob_vault_required"
}

struct PrivacyExternalSurfaceBridgeEvidence: Codable, Sendable, Equatable, Hashable {
    let id: String
    let kind: PrivacyExternalBoundaryKind
    let commitRequirement: SideEffectCommitRequirement
    let requestedBoundary: SideEffectLedgerBoundary?
    let requestedStatus: SideEffectLedgerStatus?
    let externalEffect: Bool
    let containsPrivateRuntimeData: Bool
    let receiptID: String?
    let summary: String

    init(
        id: String,
        kind: PrivacyExternalBoundaryKind,
        commitRequirement: SideEffectCommitRequirement,
        requestedBoundary: SideEffectLedgerBoundary?,
        requestedStatus: SideEffectLedgerStatus?,
        externalEffect: Bool,
        containsPrivateRuntimeData: Bool,
        receiptID: String?,
        summary: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.commitRequirement = commitRequirement
        self.requestedBoundary = requestedBoundary
        self.requestedStatus = requestedStatus
        self.externalEffect = externalEffect
        self.containsPrivateRuntimeData = containsPrivateRuntimeData
        self.receiptID = receiptID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PrivacyExternalBoundaryDecision: Codable, Sendable, Equatable, Hashable {
    let kind: PrivacyExternalBoundaryKind
    let objectID: String
    let permitted: Bool
    let issueCodes: [String]
    let receipt: PrivacySecurityReceipt

    var isPermitted: Bool {
        permitted && receipt.permitted && issueCodes.isEmpty
    }
}

enum PrivacyExternalBoundaryGateError: Error, Equatable {
    case denied(kind: PrivacyExternalBoundaryKind, objectID: String, issueCodes: [String])
}

struct PrivacyExternalBoundaryGate: Sendable, Equatable, Hashable {
    func evaluateEgress(_ decision: PrivacyEgressDecision) -> PrivacyExternalBoundaryDecision {
        var issues = receiptIssues(
            receipt: decision.receipt,
            expectedAction: .networkEgress,
            expectedPermitted: decision.permitted
        )
        if decision.redaction.containsRawPrivatePayload {
            issues.append(.rawPrivateRuntimeData)
        }
        if decision.networkDecision.touchesPrivateLifeGraph {
            issues.append(.privateGraphTouched)
        }
        if decision.permitted == false {
            issues.append(.receiptDenied)
        }
        issues.append(contentsOf: decision.receipt.issueCodes.compactMap(PrivacyExternalBoundaryIssue.init(rawValue:)))

        return makeDecision(
            kind: .networkEgress,
            objectID: decision.receipt.objectID,
            redactionApplied: decision.redaction.redactionApplied,
            localOnlyInspectionPath: decision.receipt.localOnlyInspectionPath,
            issues: issues,
            summary: decision.receipt.summary
        )
    }

    func evaluateExport(_ decision: PrivacyExportDecision) -> PrivacyExternalBoundaryDecision {
        var issues = receiptIssues(
            receipt: decision.receipt,
            expectedAction: .export,
            expectedPermitted: decision.permitted
        )
        if decision.permitted == false {
            issues.append(.receiptDenied)
        }
        if decision.report.isGreen == false {
            issues.append(.boundaryReportNotGreen)
        }
        if decision.allowedProjectionIDs.isEmpty {
            issues.append(.redactedProjectionMissing)
        }
        if decision.report.projections.contains(where: { $0.isBoundaryPreserving == false }) {
            issues.append(.runtimeInspectionAnchorsMissing)
        }

        return makeDecision(
            kind: .export,
            objectID: decision.requestID,
            redactionApplied: decision.receipt.redactionApplied,
            localOnlyInspectionPath: decision.receipt.localOnlyInspectionPath,
            issues: issues,
            summary: decision.receipt.summary
        )
    }

    func evaluateDiagnostics(_ redaction: PrivacyRedactionResult) -> PrivacyExternalBoundaryDecision {
        var issues: [PrivacyExternalBoundaryIssue] = []
        if redaction.surface != .diagnosticsExport {
            issues.append(.diagnosticsSurfaceMismatch)
        }
        if redaction.containsRawPrivatePayload {
            issues.append(.rawPrivateRuntimeData)
        }
        if redaction.privacyClass.requiresRedaction && redaction.redactionApplied == false {
            issues.append(.diagnosticsRedactionMissing)
        }
        if SourceAtlasNoPrivateGraphEgressAudit.validate([redaction.egressRecord]).isEmpty == false {
            issues.append(.privateGraphTouched)
        }

        return makeDecision(
            kind: .diagnosticsRedaction,
            objectID: redaction.id,
            redactionApplied: redaction.redactionApplied,
            localOnlyInspectionPath: redaction.localOnlyInspectionPath,
            issues: issues,
            summary: issues.isEmpty
                ? "Diagnostics boundary emitted redacted local-only metadata."
                : "Diagnostics boundary denied raw private runtime data."
        )
    }

    func evaluateExternalSnapshot(
        record: AppGroupSnapshotRecord,
        widget: WidgetProjection,
        privacy: PrivacyProjection
    ) -> PrivacyExternalBoundaryDecision {
        var issues: [PrivacyExternalBoundaryIssue] = []
        if record.isSafeForExternalProcess == false {
            issues.append(.externalSnapshotUnsafe)
        }
        if record.payloadData.isEmpty {
            issues.append(.externalSnapshotPayloadMissing)
        }
        if record.payloadChecksum.isEmpty {
            issues.append(.externalSnapshotChecksumMissing)
        }
        if record.containsPrivateRuntimeData {
            issues.append(.rawPrivateRuntimeData)
        }
        if record.privacyClasses.contains(.privateUserText) || record.privacyClasses.contains(.sensitive) {
            issues.append(.externalSnapshotPrivatePrivacyClass)
        }
        let unsafeRows = widget.rows.filter { row in
            row.privacySummary == EventLedgerPrivacyClassification.privateUserText.rawValue ||
                row.privacySummary == EventLedgerPrivacyClassification.sensitive.rawValue
        }
        if unsafeRows.isEmpty == false {
            issues.append(.externalSnapshotPrivatePrivacyClass)
        }
        let redactionRequired = Set(privacy.redactionRequiredEventIDs)
        let widgetRedacted = Set(widget.redactedEventIDs)
        if redactionRequired.isSubset(of: widgetRedacted) == false {
            issues.append(.externalSnapshotPrivacyProjectionMismatch)
        }

        return makeDecision(
            kind: .externalSnapshot,
            objectID: record.id,
            redactionApplied: privacy.redactionRequiredEventIDs.isEmpty == false,
            localOnlyInspectionPath: "You / Privacy / External surfaces / \(record.id)",
            issues: issues,
            summary: issues.isEmpty
                ? "External snapshot boundary permitted sanitized widget/privacy projection record."
                : "External snapshot boundary denied unsafe private runtime data."
        )
    }

    func evaluateExternalSurfaceBridge(_ evidence: PrivacyExternalSurfaceBridgeEvidence) -> PrivacyExternalBoundaryDecision {
        var issues: [PrivacyExternalBoundaryIssue] = []
        if evidence.kind != .appIntentResponse && evidence.kind != .shareHandoff {
            issues.append(.receiptActionMismatch)
        }
        if evidence.commitRequirement != .committedProjection {
            issues.append(.externalSurfaceBridgeMissingCommittedProjection)
        }
        if evidence.requestedBoundary != .localOnly || evidence.externalEffect {
            issues.append(.externalSurfaceBridgeNotLocalOnly)
        }
        if evidence.requestedStatus != .recordedLocalOnly {
            issues.append(.externalSurfaceBridgeNotLocalOnly)
        }
        if evidence.containsPrivateRuntimeData {
            issues.append(.externalSurfaceBridgeContainsPrivateRuntimeData)
        }
        if evidence.receiptID?.isEmpty != false {
            issues.append(.receiptMissing)
        }

        return makeDecision(
            kind: evidence.kind,
            objectID: evidence.id,
            redactionApplied: false,
            localOnlyInspectionPath: "You / Privacy / External surfaces / \(evidence.id)",
            issues: issues,
            summary: issues.isEmpty
                ? evidence.summary
                : "External surface bridge denied unsafe handoff metadata."
        )
    }

    func evaluateFileProtection(_ decision: FileProtectionDecision) -> PrivacyExternalBoundaryDecision {
        var issues: [PrivacyExternalBoundaryIssue] = []
        if fileProtectionSatisfied(decision) == false {
            issues.append(.fileProtectionInsufficient)
        }
        if decision.privacyClass.requiresRedaction && decision.requiresEncryptedBlobVault == false {
            issues.append(.encryptedBlobVaultRequired)
        }

        return makeDecision(
            kind: .fileProtection,
            objectID: decision.objectID,
            redactionApplied: decision.requiresEncryptedBlobVault,
            localOnlyInspectionPath: "You / Privacy / File protection / \(decision.objectID)",
            issues: issues,
            summary: issues.isEmpty
                ? "File protection boundary requires the expected private blob protection."
                : "File protection boundary denied weak private blob protection."
        )
    }

    func requirePermitted(_ decision: PrivacyExternalBoundaryDecision) throws {
        guard decision.isPermitted else {
            throw PrivacyExternalBoundaryGateError.denied(
                kind: decision.kind,
                objectID: decision.objectID,
                issueCodes: decision.issueCodes
            )
        }
    }

    private func receiptIssues(
        receipt: PrivacySecurityReceipt,
        expectedAction: PrivacySecurityReceiptAction,
        expectedPermitted: Bool
    ) -> [PrivacyExternalBoundaryIssue] {
        var issues: [PrivacyExternalBoundaryIssue] = []
        if receipt.id.isEmpty {
            issues.append(.receiptMissing)
        }
        if receipt.action != expectedAction {
            issues.append(.receiptActionMismatch)
        }
        if receipt.permitted != expectedPermitted {
            issues.append(.receiptDecisionMismatch)
        }
        if receipt.permitted == false {
            issues.append(.receiptDenied)
        }
        return issues
    }

    private func fileProtectionSatisfied(_ decision: FileProtectionDecision) -> Bool {
        let requiredLevel: PrivacyFileProtectionLevel
        switch decision.privacyClass {
        case .privateUserText, .privateSensitive, .proofRestricted, .replayRestricted, .lineageRestricted:
            requiredLevel = .complete
        case .sensitive, .localOnly, .calendarDerived:
            requiredLevel = .completeUntilFirstUserAuthentication
        case .publicMetadata, .systemOwned, .standard, .syncMetadata:
            requiredLevel = .standard
        }

        switch requiredLevel {
        case .standard:
            return true
        case .completeUntilFirstUserAuthentication:
            return decision.protectionLevel == .completeUntilFirstUserAuthentication || decision.protectionLevel == .complete
        case .complete:
            return decision.protectionLevel == .complete
        }
    }

    private func makeDecision(
        kind: PrivacyExternalBoundaryKind,
        objectID: String,
        redactionApplied: Bool,
        localOnlyInspectionPath: String,
        issues: [PrivacyExternalBoundaryIssue],
        summary: String
    ) -> PrivacyExternalBoundaryDecision {
        let issueCodes = orderedUnique(issues.map(\.rawValue))
        let permitted = issueCodes.isEmpty
        return PrivacyExternalBoundaryDecision(
            kind: kind,
            objectID: objectID,
            permitted: permitted,
            issueCodes: issueCodes,
            receipt: PrivacySecurityReceipt(
                id: "privacy_receipt.\(kind.rawValue).\(objectID)",
                action: kind.receiptAction,
                objectID: objectID,
                surface: kind.surface,
                permitted: permitted,
                redactionApplied: redactionApplied,
                localOnlyInspectionPath: localOnlyInspectionPath,
                issueCodes: issueCodes,
                summary: summary
            )
        )
    }

    private func orderedUnique(_ values: [String]) -> [String] {
        var seen = Set<String>()
        return values.filter { seen.insert($0).inserted }
    }
}
