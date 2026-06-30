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

    func inspectJournalLinkage(
        entries: [CommandJournalEntry],
        runtimeEvents: [RuntimeEventEnvelope],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        let commandEventEnvelopes = runtimeEvents.filter { envelope in
            if case .commandExecution = envelope.event.payload {
                return true
            }
            return false
        }
        var diagnostics: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "command.journal_linkage.summary",
                area: .command,
                componentID: "CommandInspector",
                severity: .healthy,
                summary: "Inspected \(entries.count) command journal entries and \(commandEventEnvelopes.count) runtime command events for drift.",
                detail: "Command/event reconciliation verifies command-envelope-to-runtime-event references without exposing command payload text.",
                repairHint: "Every committed runtime command event must retain command journal receipt metadata, and every linked command journal entry must point to an existing runtime event and receipt.",
                generatedAt: generatedAt
            )
        ]
        let entriesByCommandID = Dictionary(grouping: entries, by: { $0.envelope.commandID })
        let eventsByID = Dictionary(uniqueKeysWithValues: runtimeEvents.map { ($0.id, $0) })

        for envelope in commandEventEnvelopes.sorted(by: { $0.id < $1.id }) {
            diagnostics += inspectRuntimeCommandEvent(
                envelope,
                matchingEntries: entriesByCommandID[envelope.event.commandID ?? ""] ?? [],
                generatedAt: generatedAt
            )
        }

        for entry in entries.sorted(by: { $0.id < $1.id }) {
            diagnostics += inspectCommandJournalRuntimeLink(
                entry,
                eventsByID: eventsByID,
                generatedAt: generatedAt
            )
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

    private func inspectRuntimeCommandEvent(
        _ envelope: RuntimeEventEnvelope,
        matchingEntries: [CommandJournalEntry],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        guard case let .commandExecution(payload) = envelope.event.payload else {
            return []
        }

        var diagnostics: [LocalRuntimeDiagnosticRecord] = []
        let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(envelope.id)
        let commandFingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(envelope.event.commandID ?? "missing-command-id")
        let evidence = [envelope.id, envelope.event.commandID].compactMap { $0 }
        let privacy = RuntimePrivacyClass(eventPrivacy: envelope.event.privacy)

        if envelope.event.commandID == nil || matchingEntries.isEmpty {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.event_without_journal.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .critical,
                summary: "Runtime command event has no matching command journal entry.",
                detail: "Runtime event \(fingerprint) references command \(commandFingerprint), but no command journal entry was supplied for that command.",
                repairHint: "Repair or quarantine the runtime event before replay claims command/event continuity.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        if payload.resultMetadata["commandJournalEnvelopeID"] == nil ||
            payload.resultMetadata["commandJournalReceiptID"] == nil {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.event_missing_journal_reference.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .critical,
                summary: "Runtime command event is missing command journal references.",
                detail: "Runtime event \(fingerprint) does not carry command journal envelope and receipt metadata.",
                repairHint: "Regenerate the event through CommandJournal -> RuntimeEvent commit so replay can inspect the command envelope.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        return diagnostics
    }

    private func inspectCommandJournalRuntimeLink(
        _ entry: CommandJournalEntry,
        eventsByID: [String: RuntimeEventEnvelope],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        guard let link = entry.runtimeLink else {
            return []
        }

        var diagnostics: [LocalRuntimeDiagnosticRecord] = []
        let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(entry.id)
        let evidence = [entry.id, entry.envelope.commandID, link.runtimeEventID, link.runtimeReceiptID]
        let privacy = RuntimePrivacyClass(eventPrivacy: entry.envelope.privacy)

        guard let runtimeEvent = eventsByID[link.runtimeEventID] else {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.journal_link_missing_event.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .critical,
                summary: "Command journal runtime link points to a missing runtime event.",
                detail: "Command journal entry \(fingerprint) is linked to a runtime event that was not supplied to diagnostics.",
                repairHint: "Replay the runtime event journal and repair or quarantine the command journal link before claiming command/event continuity.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
            return diagnostics
        }

        guard case let .commandExecution(payload) = runtimeEvent.event.payload else {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.journal_link_non_command_event.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .critical,
                summary: "Command journal runtime link points to a non-command runtime event.",
                detail: "Command journal entry \(fingerprint) links to runtime event \(LocalRuntimeDiagnosticsRedactor.fingerprint(runtimeEvent.id)) with kind \(runtimeEvent.event.kind.rawValue).",
                repairHint: "Repair the link to point at the command execution event for this command.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
            return diagnostics
        }

        if runtimeEvent.event.commandID != entry.envelope.commandID {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.journal_link_command_mismatch.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .critical,
                summary: "Command journal runtime link points to a different command.",
                detail: "Command journal entry \(fingerprint) and its linked runtime event do not share a command ID.",
                repairHint: "Repair or quarantine the link before replay can trust command/event continuity.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        if payload.resultMetadata["receiptID"] != link.runtimeReceiptID {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "command.journal_link_receipt_mismatch.\(fingerprint)",
                area: .command,
                componentID: "CommandInspector",
                severity: .critical,
                summary: "Command journal runtime link receipt does not match the runtime event payload.",
                detail: "Command journal entry \(fingerprint) links to a runtime receipt that does not match the linked event payload.",
                repairHint: "Repair the command journal runtime link or regenerate the event through the runtime transaction coordinator.",
                evidenceIDs: evidence,
                privacy: privacy,
                generatedAt: generatedAt
            ))
        }

        return diagnostics
    }
}
