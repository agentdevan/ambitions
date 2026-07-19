import Foundation

let storeHealthCheckSchemaVersion = "store_health_check.native.v1"

enum StoreHealthStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case green
    case yellow
    case red
}

enum StoreHealthIssueKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unavailableLocalStore = "unavailable_local_store"
    case migrationFailure = "migration_failure"
    case corruptStore = "corrupt_store"
    case readFailure = "read_failure"
    case writeFailure = "write_failure"
    case schemaMismatch = "schema_mismatch"
    case extensionSnapshotWriteFailure = "extension_snapshot_write_failure"
    case storageInvariantFailure = "storage_invariant_failure"
}

struct StoreHealthIssue: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StoreHealthIssueKind
    let summary: String
    let underlyingIssueCount: Int

    init(
        kind: StoreHealthIssueKind,
        summary: String,
        underlyingIssueCount: Int = 0
    ) {
        self.kind = kind
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.underlyingIssueCount = max(0, underlyingIssueCount)
        self.id = "\(kind.rawValue).\(self.summary)"
    }
}

struct StoreHealthReport: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let status: StoreHealthStatus
    let checkedAt: String
    let isLocalOnly: Bool
    let modelCount: Int
    let readVerified: Bool
    let writeVerified: Bool
    let extensionSnapshotWriteVerified: Bool
    let invariantBlockerCount: Int
    let issues: [StoreHealthIssue]

    var isGreen: Bool {
        status == .green && issues.isEmpty
    }
}

struct StoreHealthCheck: Sendable {
    let requiredModelNames: Set<String>
    let invariantChecker: StoreInvariantChecker
    let timestampProvider: @Sendable () -> String

    init(
        requiredModelNames: Set<String> = AmbitionsPersistenceStore.storedModelNames,
        invariantChecker: StoreInvariantChecker = StoreInvariantChecker(),
        timestampProvider: @escaping @Sendable () -> String = { ISO8601DateFormatter().string(from: .now) }
    ) {
        self.requiredModelNames = requiredModelNames
        self.invariantChecker = invariantChecker
        self.timestampProvider = timestampProvider
    }

    func openAndCheck(inMemory: Bool = false) async -> StoreHealthReport {
        do {
            let store = try AmbitionsPersistenceStore(inMemory: inMemory)
            return await check(store: store)
        } catch {
            return StoreHealthReport(
                schemaVersion: storeHealthCheckSchemaVersion,
                status: .red,
                checkedAt: timestampProvider(),
                isLocalOnly: true,
                modelCount: requiredModelNames.count,
                readVerified: false,
                writeVerified: false,
                extensionSnapshotWriteVerified: false,
                invariantBlockerCount: 0,
                issues: [
                    StoreHealthIssue(kind: .unavailableLocalStore, summary: String(describing: error)),
                    StoreHealthIssue(kind: .migrationFailure, summary: "Local store could not open for health inspection.")
                ]
            )
        }
    }

    func check(
        store: AmbitionsPersistenceStore,
        extensionSnapshotWriter: (@Sendable () throws -> Void)? = nil
    ) async -> StoreHealthReport {
        var issues: [StoreHealthIssue] = []
        let readVerified = await verifyRead(store: store, issues: &issues)
        let writeVerified = await verifyWrite(store: store, issues: &issues)
        let invariantBlockerCount = await verifyInvariants(store: store, issues: &issues)
        let extensionSnapshotWriteVerified = verifyExtensionSnapshotWrite(
            writer: extensionSnapshotWriter,
            issues: &issues
        )
        verifySchema(issues: &issues)

        return StoreHealthReport(
            schemaVersion: storeHealthCheckSchemaVersion,
            status: status(for: issues),
            checkedAt: timestampProvider(),
            isLocalOnly: true,
            modelCount: AmbitionsPersistenceStore.storedModelNames.count,
            readVerified: readVerified,
            writeVerified: writeVerified,
            extensionSnapshotWriteVerified: extensionSnapshotWriteVerified,
            invariantBlockerCount: invariantBlockerCount,
            issues: issues.sorted { $0.id < $1.id }
        )
    }

    private func verifyRead(
        store: AmbitionsPersistenceStore,
        issues: inout [StoreHealthIssue]
    ) async -> Bool {
        do {
            _ = try await store.read { _ in true }
            return true
        } catch {
            issues.append(StoreHealthIssue(kind: .readFailure, summary: String(describing: error)))
            return false
        }
    }

    private func verifyWrite(
        store: AmbitionsPersistenceStore,
        issues: inout [StoreHealthIssue]
    ) async -> Bool {
        do {
            _ = try await store.write { _ in true }
            return true
        } catch {
            issues.append(StoreHealthIssue(kind: .writeFailure, summary: String(describing: error)))
            return false
        }
    }

    private func verifyInvariants(
        store: AmbitionsPersistenceStore,
        issues: inout [StoreHealthIssue]
    ) async -> Int {
        do {
            let report = try await invariantChecker.check(store: store)
            guard report.blockerCount > 0 else {
                return 0
            }
            issues.append(StoreHealthIssue(
                kind: .storageInvariantFailure,
                summary: "Storage invariant check found blocker issues.",
                underlyingIssueCount: report.blockerCount
            ))
            issues.append(StoreHealthIssue(
                kind: .corruptStore,
                summary: "Persisted records need repair before migration or release claims.",
                underlyingIssueCount: report.blockerCount
            ))
            return report.blockerCount
        } catch {
            issues.append(StoreHealthIssue(kind: .corruptStore, summary: String(describing: error)))
            return 1
        }
    }

    private func verifyExtensionSnapshotWrite(
        writer: (@Sendable () throws -> Void)?,
        issues: inout [StoreHealthIssue]
    ) -> Bool {
        guard let writer else {
            return false
        }
        do {
            try writer()
            return true
        } catch {
            issues.append(StoreHealthIssue(
                kind: .extensionSnapshotWriteFailure,
                summary: String(describing: error)
            ))
            return false
        }
    }

    private func verifySchema(issues: inout [StoreHealthIssue]) {
        let missing = requiredModelNames.subtracting(AmbitionsPersistenceStore.storedModelNames)
        guard missing.isEmpty == false else {
            return
        }
        issues.append(StoreHealthIssue(
            kind: .schemaMismatch,
            summary: "Missing stored models: \(missing.sorted().joined(separator: ", "))",
            underlyingIssueCount: missing.count
        ))
    }

    private func status(for issues: [StoreHealthIssue]) -> StoreHealthStatus {
        if issues.contains(where: { issue in
            issue.kind == .unavailableLocalStore ||
                issue.kind == .migrationFailure ||
                issue.kind == .corruptStore ||
                issue.kind == .readFailure ||
                issue.kind == .writeFailure ||
                issue.kind == .schemaMismatch
        }) {
            return .red
        }
        return issues.isEmpty ? .green : .yellow
    }
}
