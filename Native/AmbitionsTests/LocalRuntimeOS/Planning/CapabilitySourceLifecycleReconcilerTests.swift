import XCTest
@testable import Ambitions

final class CapabilitySourceLifecycleReconcilerTests: XCTestCase {
    func testLifecycleFactsReconcileCapabilityEvidenceOnceAndKeepSourceCausalLink() async throws {
        let record = CapabilityRecord(id: CapabilityID("swift"), createdAt: "2026-08-06T00:00:00Z", updatedAt: "2026-08-06T00:00:00Z", name: "Swift", meaning: "Language", creationKind: .manual)
        let source = CapabilityEvidenceSourceReference(kind: .proof, stableID: "proof-1", revision: 1, fingerprint: "before")
        let relationship = CapabilityEvidenceRelationship(id: "evidence", capabilityID: record.id, source: source, relationKind: .proofLinked, userApprovedContext: "A private note")
        let store = CapabilityStateStore()
        _ = try await store.append(.create(record), expectedRevision: 0, idempotencyKey: "create")
        _ = try await store.append(.attachEvidence(relationship), expectedRevision: 1, idempotencyKey: "attach")
        let reconciler = CapabilitySourceLifecycleReconciler(store: store)
        let corrected = CapabilityEvidenceSourceReference(kind: .proof, stableID: "proof-1", revision: 2, fingerprint: "after")
        let request = CapabilitySourceLifecycleReconciliation(id: "source-redaction", causalCommandID: "proof-command", expectedCapabilityRevision: 2, idempotencyKey: "reconcile", source: corrected, change: .redacted)

        let settled = try await reconciler.reconcile(request)
        let duplicate = try await reconciler.reconcile(request)
        let snapshot = await store.currentSnapshot()
        let evidence = snapshot.evidenceRelationships.first
        XCTAssertEqual(settled.status, .settled)
        XCTAssertEqual(duplicate.status, .duplicate)
        XCTAssertEqual(evidence?.source, corrected)
        XCTAssertEqual(evidence?.availability, .redacted)
        XCTAssertEqual(evidence?.contradictionState, .needsReview)
        XCTAssertNil(evidence?.userApprovedContext)
        XCTAssertTrue(evidence?.lineageIDs.contains("proof-command") == true)
    }

    func testNoMatchingRelationshipReportsPendingWithoutWriting() async throws {
        let store = CapabilityStateStore()
        let reconciler = CapabilitySourceLifecycleReconciler(store: store)
        let request = CapabilitySourceLifecycleReconciliation(
            id: "pending", causalCommandID: "source-command", expectedCapabilityRevision: 0,
            idempotencyKey: "pending",
            source: CapabilityEvidenceSourceReference(kind: .goal, stableID: "missing", revision: 1, fingerprint: "a"),
            change: .trash
        )
        let result = try await reconciler.reconcile(request)
        let snapshot = await store.currentSnapshot()
        XCTAssertEqual(result.status, .pendingNoRelationship)
        XCTAssertNil(result.receipt)
        XCTAssertEqual(snapshot.revision, 0)
    }
}
