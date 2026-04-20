import XCTest
@testable import Ambitions

final class GoalDetailExplainabilityActionTests: XCTestCase {
    func testGoalDetailExplainabilityMatchesRuntimeIntelligencePath() async throws {
        let repositories = try await makeRepositories()
        let directService = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await directService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let runtimeService = RepositoryBackedRuntimeGoalIntelligenceService(repositories: repositories)
        let migratedService = RepositoryBackedGoalsService(
            repositories: repositories,
            goalIntelligenceService: runtimeService
        )

        let directDetail = try await directService.loadDetail(target: created.target)
        let migratedDetail = try await migratedService.loadDetail(target: created.target)

        assertExplainabilityParity(migratedDetail.explainability, directDetail.explainability)
    }

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

    func assertExplainabilityParity(
        _ lhs: GoalExplainabilityState?,
        _ rhs: GoalExplainabilityState?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(lhs?.whyThis.compactSummary, rhs?.whyThis.compactSummary, file: file, line: line)
        XCTAssertEqual(lhs?.whyThis.lines, rhs?.whyThis.lines, file: file, line: line)
        XCTAssertEqual(
            lhs?.sourceAudit.rows.map(\.resourceID),
            rhs?.sourceAudit.rows.map(\.resourceID),
            file: file,
            line: line
        )
        XCTAssertEqual(lhs?.freshness.posture, rhs?.freshness.posture, file: file, line: line)
        XCTAssertEqual(
            lhs?.confidence.understandingConfidence,
            rhs?.confidence.understandingConfidence,
            file: file,
            line: line
        )
        XCTAssertEqual(
            lhs?.contradictions.map(\.code),
            rhs?.contradictions.map(\.code),
            file: file,
            line: line
        )
        XCTAssertEqual(
            lhs?.correctionControls.map(\.id),
            rhs?.correctionControls.map(\.id),
            file: file,
            line: line
        )
        XCTAssertEqual(
            lhs?.appliedTeachingBadges.map(\.signalID),
            rhs?.appliedTeachingBadges.map(\.signalID),
            file: file,
            line: line
        )
    }
}
