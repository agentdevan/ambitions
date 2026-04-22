import XCTest
@testable import Ambitions

final class GoalsShellIntegrationTests: XCTestCase {
    func testOverviewAddsCompactRuntimeBackedShellSummaryWithoutChangingOrdering() async throws {
        let directRepositories = try await makeRepositories()
        let runtimeRepositories = try await makeRepositories()

        let directService = RepositoryBackedGoalsService(repositories: directRepositories)
        let runtimeIntelligence = RepositoryBackedRuntimeGoalIntelligenceService(repositories: runtimeRepositories)
        let runtimeService = RepositoryBackedGoalsService(
            repositories: runtimeRepositories,
            goalIntelligenceService: runtimeIntelligence
        )

        _ = try await directService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let contradictionCreated = try await directService.createGoal(
            CreateGoalRequest(title: "I want to launch my business this summer, but I don't want deadlines"),
            now: fixedNow
        )

        _ = try await runtimeService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let runtimeContradictionCreated = try await runtimeService.createGoal(
            CreateGoalRequest(title: "I want to launch my business this summer, but I don't want deadlines"),
            now: fixedNow
        )

        let directOverview = try await directService.loadOverview()
        let runtimeOverview = try await runtimeService.loadOverview()

        XCTAssertEqual(runtimeOverview.items.map(\.title), directOverview.items.map(\.title))
        XCTAssertEqual(runtimeOverview.items.map(\.renderState), directOverview.items.map(\.renderState))
        XCTAssertEqual(runtimeOverview.items.map(\.nextStepHint), directOverview.items.map(\.nextStepHint))

        let contradictionItem = try XCTUnwrap(
            runtimeOverview.items.first(where: { $0.target == runtimeContradictionCreated.target })
        )
        let contradictionSummary = try XCTUnwrap(contradictionItem.shellSummary)
        XCTAssertFalse(contradictionSummary.pathSummary.isEmpty)
        XCTAssertTrue(contradictionSummary.indicators.contains(where: { $0.kind == .freshness }))
        XCTAssertTrue(contradictionSummary.indicators.contains(where: { $0.kind == .contradiction }))

        let runtimeContext = try await runtimeIntelligence.loadContext(
            RuntimeGoalIntelligenceRequest(
                target: runtimeContradictionCreated.target,
                primaryStepID: nil,
                includeWhyNow: true
            ),
            now: fixedNow
        )
        let expectedSummary = GoalShellSummaryProjector().makeState(from: try XCTUnwrap(runtimeContext))

        XCTAssertEqual(
            contradictionSummary.explanationSummary,
            expectedSummary.explanationSummary
        )
        XCTAssertEqual(contradictionSummary.pathSummary, expectedSummary.pathSummary)
        XCTAssertEqual(contradictionSummary.indicators, expectedSummary.indicators)
        XCTAssertFalse(contradictionSummary.indicators.contains(where: { $0.title.contains("Provenance:") }))

        let boardCard = try XCTUnwrap(
            runtimeOverview.bands
                .flatMap(\.cards)
                .first(where: { $0.target == runtimeContradictionCreated.target })
        )
        XCTAssertEqual(boardCard.shellSummary, contradictionSummary)
        _ = contradictionCreated
    }
}

private extension GoalsShellIntegrationTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    func makeRepositories() async throws -> AppRepositories {
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
