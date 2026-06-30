import Foundation

struct LocalRuntimeStoreHealthSample: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let tier: LocalRuntimeStorageTier
    let schemaVersion: String
    let recordCount: Int
    let checksumHead: String?
    let detail: String

    init(
        tier: LocalRuntimeStorageTier,
        schemaVersion: String,
        recordCount: Int,
        checksumHead: String? = nil,
        detail: String = ""
    ) {
        self.id = tier.rawValue
        self.tier = tier
        self.schemaVersion = schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recordCount = max(0, recordCount)
        self.checksumHead = checksumHead?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.detail = detail.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

extension LocalRuntimeStoreHealthSample {
    init(_ health: EventStoreSQLiteHealth) {
        self.init(
            tier: health.storageTier,
            schemaVersion: health.schemaVersion,
            recordCount: health.eventCount,
            checksumHead: health.checksumHead,
            detail: "Runtime event store kind: \(health.storeKind.rawValue). Latest event cursor: \(health.latestCursor?.eventID ?? "none")."
        )
    }

    init(_ health: ProjectionStoreSQLiteHealth) {
        self.init(
            tier: health.storageTier,
            schemaVersion: health.schemaVersion,
            recordCount: health.projectionCount,
            detail: "Stored projections: \(health.storedProjectionIDs.map(\.rawValue).joined(separator: ", "))."
        )
    }

    init(_ health: SearchStoreFTSHealth) {
        self.init(
            tier: health.storageTier,
            schemaVersion: health.schemaVersion,
            recordCount: health.indexedRecordCount,
            detail: "Indexed runtime event count: \(health.indexedEventIDs.count)."
        )
    }

    init(_ health: BackupStoreHealth) {
        self.init(
            tier: health.storageTier,
            schemaVersion: health.schemaVersion,
            recordCount: health.packageCount,
            detail: "Backup package count: \(health.packageCount)."
        )
    }

    init(_ health: MigrationStoreHealth) {
        self.init(
            tier: health.storageTier,
            schemaVersion: health.schemaVersion,
            recordCount: health.recordCount,
            detail: "Migration records with execution allowed: \(health.executionAllowedRecordCount)."
        )
    }
}

struct StoreInspector: Sendable, Equatable, Hashable {
    func inspect(
        storeHealthReport: StoreHealthReport? = nil,
        storageManifest: LocalRuntimeStorageManifest = .current,
        tierSamples: [LocalRuntimeStoreHealthSample],
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        let samplesByTier = Dictionary(grouping: tierSamples, by: \.tier)
        var diagnostics: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "store.summary",
                area: .store,
                componentID: "StoreInspector",
                severity: tierSamples.isEmpty ? .notice : .healthy,
                summary: tierSamples.isEmpty ? "No storage tier health samples supplied." : "Inspected \(tierSamples.count) storage tier health samples.",
                detail: "Store diagnostics inspect local runtime storage tier samples, SwiftData health, schema versions, and command/event/projection/receipt/replay storage posture.",
                repairHint: "Collect storage tier health from LocalRuntimeOS stores before claiming local backend health.",
                generatedAt: generatedAt
            )
        ]

        for descriptor in storageManifest.tiers {
            if let samples = samplesByTier[descriptor.id], samples.count > 1 {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "store.tier_duplicate.\(descriptor.id.rawValue)",
                    area: .store,
                    componentID: "StoreInspector",
                    severity: .warning,
                    summary: "Storage tier health sample is duplicated.",
                    detail: "Tier \(descriptor.id.rawValue) emitted \(samples.count) health samples.",
                    repairHint: "Emit one authoritative health sample per storage tier before claiming local backend health.",
                    evidenceIDs: [descriptor.id.rawValue],
                    generatedAt: generatedAt
                ))
            }

            guard let sample = samplesByTier[descriptor.id]?.sorted(by: { lhs, rhs in
                if lhs.schemaVersion != rhs.schemaVersion {
                    return lhs.schemaVersion < rhs.schemaVersion
                }
                return lhs.recordCount < rhs.recordCount
            }).first else {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "store.tier_missing.\(descriptor.id.rawValue)",
                    area: .store,
                    componentID: "StoreInspector",
                    severity: .warning,
                    summary: "Storage tier health sample is missing.",
                    detail: "Tier \(descriptor.id.rawValue) at \(descriptor.rootPath) has no health sample.",
                    repairHint: "Wire \(descriptor.id.rawValue) health into StoreInspector before claiming full local backend health.",
                    evidenceIDs: [descriptor.id.rawValue],
                    generatedAt: generatedAt
                ))
                continue
            }

            if sample.schemaVersion.isEmpty {
                diagnostics.append(LocalRuntimeDiagnosticRecord(
                    id: "store.schema_missing.\(sample.tier.rawValue)",
                    area: .store,
                    componentID: "StoreInspector",
                    severity: .critical,
                    summary: "Storage tier health sample has no schema version.",
                    detail: "Tier \(sample.tier.rawValue) emitted an empty schema version.",
                    repairHint: "Restore typed storage adapters and schema versions for this tier.",
                    evidenceIDs: [sample.tier.rawValue],
                    generatedAt: generatedAt
                ))
            }
        }

        if let storeHealthReport {
            diagnostics += inspect(storeHealthReport, generatedAt: generatedAt)
        }

        return diagnostics.sorted { $0.id < $1.id }
    }

    private func inspect(
        _ report: StoreHealthReport,
        generatedAt: String
    ) -> [LocalRuntimeDiagnosticRecord] {
        var diagnostics: [LocalRuntimeDiagnosticRecord] = [
            LocalRuntimeDiagnosticRecord(
                id: "store.swiftdata_health",
                area: .store,
                componentID: "StoreInspector",
                severity: severity(for: report.status),
                summary: "SwiftData object-store health is \(report.status.rawValue).",
                detail: "Read verified: \(report.readVerified); write verified: \(report.writeVerified); invariant blockers: \(report.invariantBlockerCount).",
                repairHint: report.isGreen ? "Keep SwiftData limited to object-store responsibilities." : "Run StoreInvariantChecker and MigrationRepair before migration or release claims.",
                evidenceIDs: [report.schemaVersion, report.checkedAt],
                privacy: .systemOwned,
                generatedAt: generatedAt
            )
        ]

        for issue in report.issues.sorted(by: { $0.id < $1.id }) {
            diagnostics.append(LocalRuntimeDiagnosticRecord(
                id: "store.issue.\(LocalRuntimeDiagnosticsRedactor.fingerprint(issue.id))",
                area: .store,
                componentID: "StoreInspector",
                severity: issue.kind == .extensionSnapshotWriteFailure ? .warning : .critical,
                summary: "Store health issue: \(issue.kind.rawValue).",
                detail: issue.summary,
                repairHint: "Repair local storage through MigrationRepair before widening backend health claims.",
                evidenceIDs: [issue.id],
                privacy: .privateSensitive,
                generatedAt: generatedAt
            ))
        }

        return diagnostics
    }

    private func severity(for status: StoreHealthStatus) -> LocalRuntimeDiagnosticSeverity {
        switch status {
        case .green:
            return .healthy
        case .yellow:
            return .warning
        case .red:
            return .critical
        }
    }
}
