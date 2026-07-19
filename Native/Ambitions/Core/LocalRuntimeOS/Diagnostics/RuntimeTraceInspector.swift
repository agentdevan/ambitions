import Foundation

struct RuntimeTraceInspector: Sendable, Equatable, Hashable {
    func inspect(
        envelopes: [RuntimeEventEnvelope],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        let ordered = envelopes.sorted { lhs, rhs in
            if lhs.sequence != rhs.sequence {
                return lhs.sequence < rhs.sequence
            }
            return lhs.id < rhs.id
        }
        var diagnostics: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "runtime_trace.summary",
                area: .runtimeTrace,
                componentID: "RuntimeTraceInspector",
                severity: ordered.isEmpty ? .notice : .healthy,
                summary: ordered.isEmpty ? "No runtime event envelopes supplied." : "Inspected \(ordered.count) runtime event envelopes.",
                detail: "Runtime trace diagnostics check append-only order, checksum validity, previous-checksum continuity, local-only posture, and privacy redaction.",
                repairHint: ordered.isEmpty ? "Wire RuntimeEventStore output into diagnostics before claiming replay health." : "Use event sequence and checksum evidence to repair replay drift.",
                generatedAt: generatedAt
            )
        ]

        var previous: RuntimeEventEnvelope?
        for envelope in ordered {
            let fingerprint = LocalRuntimeDiagnosticsRedactor.fingerprint(envelope.id)
            let privacy = RuntimePrivacyClass(eventPrivacy: envelope.event.privacy)
            let expectedSequence = (previous?.sequence ?? 0) + 1

            if envelope.sequence != expectedSequence {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "runtime_trace.sequence.\(fingerprint)",
                    area: .runtimeTrace,
                    componentID: "RuntimeTraceInspector",
                    severity: .critical,
                    summary: "Runtime event sequence is not append-only.",
                    detail: "Event \(fingerprint) has sequence \(envelope.sequence); expected \(expectedSequence).",
                    repairHint: "Quarantine the event journal and rebuild projections from the last valid cursor.",
                    evidenceIDs: [envelope.id, envelope.event.commandID].compactMap { $0 },
                    privacy: privacy,
                    generatedAt: generatedAt
                ))
            }

            if RuntimeEventChecksum.isValid(envelope) == false {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "runtime_trace.checksum.\(fingerprint)",
                    area: .runtimeTrace,
                    componentID: "RuntimeTraceInspector",
                    severity: .critical,
                    summary: "Runtime event checksum is invalid.",
                    detail: "Event \(fingerprint) failed checksum validation.",
                    repairHint: "Stop projection materialization and inspect the event journal before replay.",
                    evidenceIDs: [envelope.id, envelope.event.commandID].compactMap { $0 },
                    privacy: privacy,
                    generatedAt: generatedAt
                ))
            }

            if envelope.previousChecksum != previous?.checksum {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "runtime_trace.previous_checksum.\(fingerprint)",
                    area: .runtimeTrace,
                    componentID: "RuntimeTraceInspector",
                    severity: .critical,
                    summary: "Runtime event checksum chain is broken.",
                    detail: "Event \(fingerprint) does not point to the previous envelope checksum.",
                    repairHint: "Replay only through the last contiguous checksum cursor and quarantine later events.",
                    evidenceIDs: [envelope.id, previous?.id].compactMap { $0 },
                    privacy: privacy,
                    generatedAt: generatedAt
                ))
            }

            if envelope.event.localOnly == false {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "runtime_trace.local_only.\(fingerprint)",
                    area: .runtimeTrace,
                    componentID: "RuntimeTraceInspector",
                    severity: .critical,
                    summary: "Runtime event is not local-only.",
                    detail: "Event \(fingerprint) has localOnly=false for kind \(envelope.event.kind.rawValue).",
                    repairHint: "Private life runtime events must remain local-only unless future continuity law explicitly permits envelope sync.",
                    evidenceIDs: [envelope.id, envelope.event.commandID].compactMap { $0 },
                    privacy: privacy,
                    generatedAt: generatedAt
                ))
            }

            previous = envelope
        }

        return diagnostics.sorted { $0.id < $1.id }
    }
}
