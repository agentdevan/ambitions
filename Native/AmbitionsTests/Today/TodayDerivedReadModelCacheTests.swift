import XCTest
@testable import Ambitions

final class TodayDerivedReadModelCacheTests: XCTestCase {
    func testTodayServiceReusesDerivedReadModelForMatchingSnapshotKey() async throws {
        let repositories = try makeRepositories()
        let cache = TodayDerivedReadModelCache()
        let service = RepositoryBackedTodayService(
            repositories: repositories,
            derivedReadModelCache: cache
        )
        let now = Date(timeIntervalSince1970: 1_712_692_800)

        let first = try await service.loadTodayExperience(userDisplayName: "Devan", now: now, entryContext: .standard)
        let second = try await service.loadTodayExperience(userDisplayName: "Devan", now: now, entryContext: .standard)

        XCTAssertEqual(first.execution, second.execution)
        XCTAssertEqual(cache.missCount, 1)
        XCTAssertEqual(cache.hitCount, 1)
    }

    func testTodayDerivedReadModelCacheCanBeCleared() {
        let cache = TodayDerivedReadModelCache()

        cache.removeAll()

        XCTAssertEqual(cache.missCount, 0)
        XCTAssertEqual(cache.hitCount, 0)
    }
}

private extension TodayDerivedReadModelCacheTests {
    func makeRepositories() throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return AppRepositories(
            goals: SwiftDataGoalRepository(store: store),
            drafts: SwiftDataGoalDraftRepository(store: store),
            evidence: SwiftDataProgressEvidenceRepository(store: store),
            feedback: SwiftDataFeedbackEventRepository(store: store),
            captures: SwiftDataCaptureRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
