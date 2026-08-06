import XCTest
@testable import Ambitions

final class PublicReferenceRepositoryTests: XCTestCase {
    func testAdapterAcceptsOnlyApprovedONETSlice() {
        let accepted = PublicReferencePackAdapter().adapt(Self.artifact())
        XCTAssertTrue(accepted.isVerified)
        XCTAssertEqual(accepted.release?.release.id, "30.3")
        XCTAssertEqual(accepted.release?.claims.map(\.sourceNativeSubjectID), ["15-1252.00"])

        let unsupportedClaim = Self.claim(predicateID: "occupation.salary")
        let rejected = PublicReferencePackAdapter().adapt(Self.artifact(claims: [unsupportedClaim]))
        XCTAssertNil(rejected.release)
        XCTAssertEqual(rejected.quarantines.first?.failures, [.unsupportedPredicate])
    }

    func testAdditiveMigrationLeavesCurrentPointerUnsetAndOfflineReadsBundledRevision() async {
        let repository = PublicReferenceRepository()
        let migration = await repository.migrateAdditively(bundled: Self.artifact(releaseID: "30.3", hash: "a"))

        XCTAssertTrue(migration.didInstallBundledRelease)
        let current = await repository.currentSnapshot()
        XCTAssertNil(current)
        let offline = await repository.offlineSnapshot()
        XCTAssertEqual(offline?.delivery, .bundled)
        XCTAssertEqual(offline?.release.sourceRevision, "30.3|a")
    }

    func testPromotionRollbackAndOfflineSnapshotPreserveExactSourceRevision() async {
        let store = PublicReferenceInMemoryLastKnownGoodStore()
        let repository = PublicReferenceRepository(lastKnownGoodStore: store)
        let first = Self.artifact(releaseID: "30.3", hash: "a")
        let second = Self.artifact(releaseID: "30.3", hash: "b")

        let firstRefresh = await repository.refresh(first)
        let secondRefresh = await repository.refresh(second)
        let current = await repository.currentSnapshot()
        let rollback = await repository.rollbackToLastKnownGood()
        let offline = await repository.offlineSnapshot()
        XCTAssertEqual(firstRefresh, .promoted(sourceRevision: "30.3|a"))
        XCTAssertEqual(secondRefresh, .promoted(sourceRevision: "30.3|b"))
        XCTAssertEqual(current?.release.sourceRevision, "30.3|b")
        XCTAssertEqual(rollback, .rolledBack(sourceRevision: "30.3|a"))
        XCTAssertEqual(offline?.release.sourceRevision, "30.3|a")
    }

    func testCancellationLeavesPointersUntouched() async {
        let provider = DelayedProvider(entries: [(Self.artifact(hash: "a"), 500_000_000)])
        let repository = PublicReferenceRepository(provider: provider)
        let task = Task { await repository.refresh() }
        task.cancel()

        let result = await task.value
        let current = await repository.currentSnapshot()
        XCTAssertEqual(result, .cancelled)
        XCTAssertNil(current)
    }

    func testConcurrentRefreshDoesNotLetOlderResultOverwriteNewerPromotion() async {
        let provider = DelayedProvider(entries: [
            (Self.artifact(hash: "a"), 100_000_000),
            (Self.artifact(hash: "b"), 0)
        ])
        let repository = PublicReferenceRepository(provider: provider)

        async let older = repository.refresh()
        try? await Task.sleep(nanoseconds: 5_000_000)
        async let newer = repository.refresh()
        _ = await (older, newer)

        let current = await repository.currentSnapshot()
        XCTAssertEqual(current?.release.sourceRevision, "30.3|b")
    }

    private static func artifact(
        claims: [PublicReferenceClaimEnvelope]? = nil,
        releaseID: String = "30.3",
        hash: String = "abc123"
    ) -> PublicReferencePackArtifact {
        PublicReferencePackArtifact(
            id: "onet-30.3",
            request: SourceAtlasPublicPackRequest(
                packID: "onet-30.3",
                manifestVersionID: releaseID,
                declaredSHA256: String(repeating: "a", count: 64)
            ),
            release: PublicReferenceRelease(id: releaseID),
            publisherID: "onet",
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            signatureVerified: true,
            claims: claims ?? [claim(contentHash: hash)]
        )
    }

    private static func claim(
        predicateID: String = "occupation.task",
        contentHash: String = "abc123"
    ) -> PublicReferenceClaimEnvelope {
        PublicReferenceClaimEnvelope(
            id: PublicReferenceClaimID("claim-software-developers-task"),
            sourceNativeSubjectID: "15-1252.00",
            predicateID: predicateID,
            value: PublicReferenceClaimValue(text: "Develop software systems."),
            sourceRecordID: "onet-30.3-15-1252.00",
            authority: PublicReferenceAuthority(
                publisherID: "onet",
                lane: .description,
                statement: "O*NET owns this descriptive occupation claim."
            ),
            jurisdiction: PublicReferenceJurisdiction(code: "US", label: "United States"),
            release: PublicReferenceRelease(id: "30.3"),
            retrievedAt: "2026-08-06T00:00:00Z",
            checkedAt: "2026-08-06T00:00:00Z",
            deliveryState: .bundled,
            semanticReviewState: .complete,
            freshnessState: .current,
            rightsState: .approvedWithAttribution,
            requiredAttribution: "O*NET 30.3, CC BY 4.0",
            riskState: "descriptive",
            contentHash: contentHash
        )
    }
}

private actor DelayedProvider: PublicReferenceVerifiedPackProviding {
    private var entries: [(PublicReferencePackArtifact, UInt64)]

    init(entries: [(PublicReferencePackArtifact, UInt64)]) {
        self.entries = entries
    }

    func verifiedPublicReferencePack() async -> PublicReferencePackArtifact? {
        guard entries.isEmpty == false else { return nil }
        let entry = entries.removeFirst()
        if entry.1 > 0 {
            try? await Task.sleep(nanoseconds: entry.1)
        }
        return entry.0
    }
}
