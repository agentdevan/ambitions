import XCTest
@testable import Ambitions

final class GoalDetailExplainabilityActionTests: XCTestCase {
    func testResourceCorrectionWritesAnchoredTeachingSignal() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Launch my business"),
            now: fixedNow
        )
        let detail = try await service.loadDetail(target: created.target)
        let control = try XCTUnwrap(
            detail.explainability?.correctionControls.first(where: { $0.artifactKind == .resourceHook })
        )

        _ = try await service.submitExplainabilityCorrection(
            GoalExplainabilityCorrectionRequest(
                target: created.target,
                control: control
            ),
            now: fixedNow
        )
        let signals = try await repositories.teaching.listSignals(goalID: nil)

        XCTAssertEqual(signals.count, 1)
        XCTAssertEqual(signals.first?.kind, .requirementRelevanceCorrection)
    }

    func testContradictionCorrectionWritesAnchoredTeachingSignal() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "I want to launch my business this summer, but I don't want deadlines"),
            now: fixedNow
        )
        let detail = try await service.loadDetail(target: created.target)
        let control = try XCTUnwrap(
            detail.explainability?.correctionControls.first(where: { $0.artifactKind == .contradictionShape })
        )

        _ = try await service.submitExplainabilityCorrection(
            GoalExplainabilityCorrectionRequest(
                target: created.target,
                control: control
            ),
            now: fixedNow
        )
        let signals = try await repositories.teaching.listSignals(goalID: nil)

        XCTAssertEqual(signals.count, 1)
        XCTAssertEqual(signals.first?.kind, .contradictionDispositionCorrection)
    }

    func testEnergyCorrectionWritesAnchoredTeachingSignal() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let detail = try await service.loadDetail(target: created.target)
        let control = try XCTUnwrap(
            detail.explainability?.correctionControls.first(where: { $0.artifactKind == .energyEvaluation })
        )

        _ = try await service.submitExplainabilityCorrection(
            GoalExplainabilityCorrectionRequest(
                target: created.target,
                control: control
            ),
            now: fixedNow
        )
        let signals = try await repositories.teaching.listSignals(goalID: nil)

        XCTAssertEqual(signals.count, 1)
        XCTAssertEqual(signals.first?.kind, .energyFitCorrection)
    }
}

private extension GoalDetailExplainabilityActionTests {
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
            teaching: SwiftDataGoalTeachingSignalRepository(store: store),
            appState: SwiftDataAppStateRepository(store: store)
        )
    }
}
