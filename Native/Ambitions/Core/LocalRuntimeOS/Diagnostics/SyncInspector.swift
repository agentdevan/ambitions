import Foundation

struct SyncInspector: Sendable, Equatable, Hashable {
    func inspect(
        diagnostics: CloudKitContinuityDiagnostics,
        pendingOutboxCount: Int = 0,
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        var records: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "sync.summary",
                area: .sync,
                componentID: "SyncInspector",
                severity: severity(for: diagnostics),
                summary: "Sync continuity state is \(diagnostics.syncState.rawValue).",
                detail: diagnostics.detail,
                repairHint: repairHint(for: diagnostics),
                evidenceIDs: [diagnostics.syncMode.rawValue, diagnostics.syncState.rawValue, diagnostics.accountStatus.rawValue],
                generatedAt: generatedAt
            )
        ]

        if diagnostics.localOperationBlocked {
            records.append(LocalRuntimeDiagnosticRecord(
                id: "sync.local_operation_blocked",
                area: .sync,
                componentID: "SyncInspector",
                severity: .critical,
                summary: "Sync diagnostics report blocked local operation.",
                detail: "Local operation must remain available even when sync is unavailable.",
                repairHint: "Force local-only fallback and stop sync setup from gating local writes.",
                evidenceIDs: [diagnostics.syncState.rawValue],
                generatedAt: generatedAt
            ))
        }

        if diagnostics.writesUserData || diagnostics.userDataCaptured {
            records.append(LocalRuntimeDiagnosticRecord(
                id: "sync.private_graph_capture",
                area: .sync,
                componentID: "SyncInspector",
                severity: .critical,
                summary: "Sync diagnostics indicate private user data capture or write.",
                detail: "writesUserData=\(diagnostics.writesUserData), userDataCaptured=\(diagnostics.userDataCaptured).",
                repairHint: "Disable continuity writes until a future approved user-owned sync architecture exists.",
                evidenceIDs: [diagnostics.syncState.rawValue],
                privacy: .privateSensitive,
                generatedAt: generatedAt
            ))
        }

        if pendingOutboxCount > 0, diagnostics.proofVerified == false {
            records.append(LocalRuntimeDiagnosticRecord(
                id: "sync.pending_without_proof",
                area: .sync,
                componentID: "SyncInspector",
                severity: .warning,
                summary: "Sync outbox has pending entries before proof is verified.",
                detail: "\(pendingOutboxCount) pending continuity entries exist while proofVerified=false.",
                repairHint: "Hold pending sync entries locally and require proof before any external write attempt.",
                evidenceIDs: [String(pendingOutboxCount), diagnostics.syncState.rawValue],
                generatedAt: generatedAt
            ))
        }

        return records.sorted { $0.id < $1.id }
    }

    private func severity(for diagnostics: CloudKitContinuityDiagnostics) -> LocalRuntimeDiagnosticSeverity {
        if diagnostics.localOperationBlocked || diagnostics.writesUserData || diagnostics.userDataCaptured {
            return .critical
        }
        switch diagnostics.syncState {
        case .healthyAfterProof, .localOnlyUnavailable, .disabled, .paused:
            return .healthy
        case .temporarilyUnavailable, .accountUnavailable, .restricted, .needsReview:
            return .notice
        }
    }

    private func repairHint(for diagnostics: CloudKitContinuityDiagnostics) -> String {
        if diagnostics.syncMode == .localOnly {
            return "Keep local-only operation authoritative; no continuity repair is required."
        }
        return diagnostics.rollbackDetail
    }
}
