@testable import Ambitions
import XCTest

extension ExternalSurfaceSnapshotTests {
    static func readSharedSnapshotRecord(
        from store: AppGroupSnapshotStore,
        sideEffectLedger: any SideEffectLedgerRepository
    ) async throws -> AppGroupSnapshotRecord {
        do {
            return try await store.read(id: SharedExternalSnapshotStore.snapshotRecordID)
        } catch {
            let failureRecord = try? await sideEffectLedger.fetchRecord(id: "externalSnapshot.failed_safely.1712779200")
            XCTFail("Snapshot writer did not create shared record. \(failureRecord?.degradedFacts.joined(separator: " | ") ?? "No failure side effect recorded.")")
            throw error
        }
    }
}
