import Foundation

struct RuntimeDoctorHealthReaders: Sendable, Equatable, Hashable {
    func commandJournal(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .commandJournal,
            componentID: "CommandJournalHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func eventStore(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .eventStore,
            componentID: "EventStoreHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func projectionStore(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .projectionStore,
            componentID: "ProjectionStoreHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func searchIndex(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .searchIndex,
            componentID: "SearchIndexHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func blobVault(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .blobVault,
            componentID: "BlobVaultHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func sideEffectOutbox(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .sideEffectOutbox,
            componentID: "SideEffectOutboxHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func syncContinuity(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .syncContinuity,
            componentID: "SyncContinuityHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func privacyBoundary(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .privacyBoundary,
            componentID: "PrivacyBoundaryHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func migrationState(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .migrationState,
            componentID: "MigrationStateHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    func storageTier(
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String] = [],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        reader(
            domain: .storageTier,
            componentID: "StorageTierHealthReader",
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }

    private func reader(
        domain: RuntimeDoctorHealthDomain,
        componentID: String,
        diagnostics: [LocalRuntimeDiagnosticRecord],
        evidenceIDs: [String],
        generatedAt: String
    ) -> RuntimeDoctorHealthReader {
        RuntimeDoctorHealthReader(
            domain: domain,
            componentID: componentID,
            diagnostics: diagnostics,
            evidenceIDs: evidenceIDs,
            generatedAt: generatedAt
        )
    }
}

struct RuntimeDoctorHealthSnapshot: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let generatedAt: String
    let readers: [RuntimeDoctorHealthReader]
    let commandEventProjectionReceiptReplayRequired: Bool
    let releaseHealthClaimed: Bool

    init(
        schemaVersion: String = runtimeDoctorRepairOperatorSchemaVersion,
        generatedAt: String,
        readers: [RuntimeDoctorHealthReader],
        commandEventProjectionReceiptReplayRequired: Bool = true,
        releaseHealthClaimed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.readers = readers.sorted { $0.domain.rawValue < $1.domain.rawValue }
        self.commandEventProjectionReceiptReplayRequired = commandEventProjectionReceiptReplayRequired
        self.releaseHealthClaimed = releaseHealthClaimed
    }

    var driftSignals: [RuntimeDoctorDriftSignal] {
        readers.flatMap(\.driftSignals).sorted {
            if $0.domain != $1.domain {
                return $0.domain.rawValue < $1.domain.rawValue
            }
            return $0.id < $1.id
        }
    }
}
