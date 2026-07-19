import XCTest
@testable import Ambitions

final class AFEP004ExportPolicyTests: XCTestCase {
    func testPortableExportManifestExposesConservativePolicyDefaults() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            eventLedger: InMemoryEventLedgerRepository(),
            appState: SwiftDataAppStateRepository(store: store)
        )
        let service = PortableSnapshotService(
            repositories: repositories,
            resetStore: { try await store.resetAllData() }
        )

        let snapshot = try await service.exportSnapshot()

        let goals: PortableExportCategorySummary = try XCTUnwrap(snapshot.manifest.summary(for: PortableExportCategory.goalsAndPlans))
        let captures: PortableExportCategorySummary = try XCTUnwrap(snapshot.manifest.summary(for: PortableExportCategory.captures))
        let proof: PortableExportCategorySummary = try XCTUnwrap(snapshot.manifest.summary(for: PortableExportCategory.proof))
        let receipts: PortableExportCategorySummary = try XCTUnwrap(snapshot.manifest.summary(for: PortableExportCategory.receipts))
        let memory: PortableExportCategorySummary = try XCTUnwrap(snapshot.manifest.summary(for: PortableExportCategory.memory))
        let settings: PortableExportCategorySummary = try XCTUnwrap(snapshot.manifest.summary(for: PortableExportCategory.settings))

        XCTAssertTrue(goals.containsSensitiveUserText)
        XCTAssertEqual(goals.privacyClass, .privateSensitive)
        XCTAssertEqual(goals.indexingPolicy, .notIndexed)
        XCTAssertEqual(goals.exportPolicy, .exportReviewOnly)
        XCTAssertEqual(goals.measurementEvidenceState, .planned)

        XCTAssertTrue(captures.containsSensitiveUserText)
        XCTAssertEqual(captures.privacyClass, .privateSensitive)
        XCTAssertEqual(captures.indexingPolicy, .notIndexed)
        XCTAssertEqual(captures.exportPolicy, .exportReviewOnly)

        XCTAssertTrue(proof.containsSensitiveUserText)
        XCTAssertEqual(proof.privacyClass, .proofRestricted)
        XCTAssertEqual(proof.indexingPolicy, .notIndexed)
        XCTAssertEqual(proof.exportPolicy, .exportReviewOnly)

        XCTAssertTrue(receipts.containsSensitiveUserText)
        XCTAssertEqual(receipts.privacyClass, .proofRestricted)
        XCTAssertEqual(receipts.indexingPolicy, .notIndexed)
        XCTAssertEqual(receipts.exportPolicy, .exportReviewOnly)

        XCTAssertTrue(memory.containsSensitiveUserText)
        XCTAssertEqual(memory.privacyClass, .localOnly)
        XCTAssertEqual(memory.indexingPolicy, .notIndexed)
        XCTAssertEqual(memory.exportPolicy, .exportReviewOnly)

        XCTAssertFalse(settings.containsSensitiveUserText)
        XCTAssertEqual(settings.privacyClass, .systemOwned)
        XCTAssertEqual(settings.indexingPolicy, .indexed)
        XCTAssertEqual(settings.exportPolicy, .safe)
        XCTAssertEqual(settings.measurementEvidenceState, .planned)

        XCTAssertTrue(snapshot.manifest.exclusions.contains { $0.id == "excluded.cloud-sync-account" })
        XCTAssertTrue(snapshot.manifest.privacyRules.contains("Preview surfaces must use redacted receipt/proof summaries for private or sensitive details."))
    }
}
