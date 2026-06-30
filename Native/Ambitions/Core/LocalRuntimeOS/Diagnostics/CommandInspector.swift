import Foundation

struct CommandInspector: Sendable, Equatable, Hashable {
    func inspect(
        records: [AmbitionsCommandExecutionRecord],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        var diagnostics: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "command.summary",
                area: .command,
                componentID: "CommandInspector",
                severity: records.isEmpty ? .notice : .healthy,
                summary: records.isEmpty ? "No command execution records supplied." : "Inspected \(records.count) command execution records.",
                detail: "Command diagnostics inspect validation state, execution status, local-only posture, and privacy class without exposing command payload text.",
                repairHint: records.isEmpty ? "Wire command journal records into diagnostics before claiming command-spine health." : "Keep command failures tied to command IDs, receipts, and replay evidence.",
                generatedAt: generatedAt
            )
        ]

        for record in records.sorted(by: { $0.id < $1.id }) {
            diagnostics += inspect(record, generatedAt: generatedAt)
        }

        return diagnostics.sorted { $0.id < $1.id }
    }

    private func inspect(
        _ record: AmbitionsCommandExecutionRecord,
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        var diagnostics: [LocalRuntimeDiagnosticRecord] = []
        let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(record.id)
        let evidence = [record.id, record.commandID] + record.result.eventLedgerEntryIDs
        let privacy = RuntimePrivacyClass(eventPrivacy: record.privacy)

        if record.localOnly == false || record.command.localOnly == false {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.local_only.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .critical,
                summary: "Command execution record is not local-only.",
                detail: "Command \(fingerprint) has local-only disabled for kind \(record.command.kind.rawValue).",
                repairHint: "Route private runtime commands through local-only command execution unless a future approved sync law permits otherwise.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        if record.command.validationState != .valid {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.validation.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: record.result.status == .succeeded ? .critical : .warning,
                summary: "Command validation is not valid.",
                detail: "Command \(fingerprint) validation state is \(record.command.validationState.rawValue), result status is \(record.result.status.rawValue).",
                repairHint: "Validation must happen before mutation and failed validation must not produce successful local mutation.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        if [.failed, .blocked, .unsupported].contains(record.result.status) {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.result.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .warning,
                summary: "Command execution did not complete successfully.",
                detail: "Command \(fingerprint) ended with \(record.result.status.rawValue). \(record.result.summary)",
                repairHint: "Inspect command receipt, replay outcome, and target object references before retrying.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        if privacy.requiresRedaction {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.privacy.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .notice,
                summary: "Command payload is privacy-sensitive and diagnostics are redacted.",
                detail: "Command \(fingerprint) uses privacy class \(record.privacy.rawValue); payload text stays out of diagnostics.",
                repairHint: "Use local command detail inspection for private payload values.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        return diagnostics
    }
}
