import Foundation

struct DiagnosticLedgerSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let generatedAt: String
    let schemaVersion: String
    let entries: [DiagnosticLedgerEntry]
    let entryFingerprint: String
    let requiresAttention: Bool

    init(
        eventLedger: [EventLedgerEntry],
        sideEffectLedger: [SideEffectLedgerRecord],
        privacyClassifications: [AmbitionsOSPrivacySafetyClassification],
        generatedAt: String
    ) {
        let eventDiagnostics = eventLedger.map { $0.toDiagnosticLedgerEntry() }
        let sideEffectDiagnostics = sideEffectLedger.map { $0.toDiagnosticLedgerEntry() }
        let privacyDiagnostics = privacyClassifications.map {
            $0.toDiagnosticLedgerEntry(occurredAt: generatedAt)
        }
        let orderedEntries = Self.orderedUniqueDiagnostics(
            entries: eventDiagnostics + sideEffectDiagnostics + privacyDiagnostics
        )
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.schemaVersion = diagnosticLedgerSchemaVersion
        self.entries = orderedEntries
        self.requiresAttention = orderedEntries.contains(where: \.isAttentionRequired)
        self.entryFingerprint = Self.fingerprint(orderedEntries)
        self.id = "diagnostic.snapshot.\(self.generatedAt).\(self.entryFingerprint.count)"
    }

    static func orderedUniqueDiagnostics(entries: [DiagnosticLedgerEntry]) -> [DiagnosticLedgerEntry] {
        var seen = Set<String>()
        return entries
            .sorted { lhs, rhs in
                if lhs.occurredAt != rhs.occurredAt {
                    return lhs.occurredAt < rhs.occurredAt
                }
                if lhs.signal != rhs.signal {
                    return lhs.signal.rawValue < rhs.signal.rawValue
                }
                return lhs.id < rhs.id
            }
            .filter { seen.insert($0.id).inserted }
    }

    static func fingerprint(_ entries: [DiagnosticLedgerEntry]) -> String {
        entries
            .map(\.issueFingerprint)
            .sorted()
            .joined(separator: "|")
    }
}

protocol DiagnosticLedgerSnapshotRepository: Sendable {
    func append(_ snapshot: DiagnosticLedgerSnapshot) async throws
    func fetchRecent(limit: Int) async throws -> [DiagnosticLedgerSnapshot]
    func fetchSnapshot(id: String) async throws -> DiagnosticLedgerSnapshot?
}

actor InMemoryDiagnosticLedgerSnapshotRepository: DiagnosticLedgerSnapshotRepository {
    var snapshots: [DiagnosticLedgerSnapshot] = []

    func append(_ snapshot: DiagnosticLedgerSnapshot) async throws {
        snapshots.removeAll { $0.id == snapshot.id }
        snapshots.append(snapshot)
    }

    func fetchRecent(limit: Int) async throws -> [DiagnosticLedgerSnapshot] {
        Array(
            snapshots
                .sorted { lhs, rhs in
                    if lhs.generatedAt != rhs.generatedAt {
                        return lhs.generatedAt > rhs.generatedAt
                    }
                    return lhs.id < rhs.id
                }
                .prefix(max(0, limit))
        )
    }

    func fetchSnapshot(id: String) async throws -> DiagnosticLedgerSnapshot? {
        snapshots.first { $0.id == id }
    }
}
