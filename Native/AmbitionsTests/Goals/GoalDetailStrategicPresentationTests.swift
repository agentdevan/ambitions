import XCTest
@testable import Ambitions

final class GoalDetailStrategicPresentationTests: XCTestCase {
    func testRepositoryBackedDetailProjectsStrategicFirstLayerForActiveGoal() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)

        XCTAssertFalse(detail.strategicStatus.title.isEmpty)
        XCTAssertFalse(detail.strategicStatus.summary.isEmpty)
        XCTAssertNotNil(detail.nextMovement)
        XCTAssertFalse(detail.pathStages.isEmpty)
        XCTAssertTrue(detail.pathStages.contains(where: { $0.position == .current || $0.position == .blocked }))
        XCTAssertFalse(detail.trajectory.phaseTitle.isEmpty)
    }

    func testStarterPreviewKeepsFirstLayerStrategicReadVisible() {
        let detail = tryUnwrapScenario(PreviewGoalsScenarios.starterTarget.id)

        XCTAssertEqual(detail.strategicStatus.title, "Starter path is taking shape")
        XCTAssertEqual(detail.pathStages.first?.position, .current)
        XCTAssertEqual(detail.nextMovement?.title, "Record one rough pass")
        XCTAssertEqual(detail.recentMovement.items.count, 0)
    }

    func testMakePathStagesFallsBackToSectionDerivedFilmstrip() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)
        let section = PlanSection(
            id: "section-1",
            goalID: "goal-1",
            title: "Now",
            summary: "The highest-leverage move still open.",
            kind: .activeSteps,
            orderIndex: 0,
            steps: [
                Step(
                    id: "step-1",
                    sectionID: "section-1",
                    title: "Outline the talk pitch",
                    summary: "Turn the idea into one visible draft.",
                    type: .actionUnit,
                    state: .planned,
                    owner: .localOwner,
                    timing: GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: nil),
                    dependencyStepIDs: [],
                    isOptional: false,
                    isRepeatable: false,
                    evidenceRequired: false,
                    successSignals: ["A visible draft exists."],
                    actionability: StepActionability(
                        action: "Draft the opener",
                        completionDefinition: "The opener is written.",
                        evidenceOfCompletion: ["One visible draft."],
                        fallbackMicroStep: "Draft the opener",
                        contextRequirements: []
                    )
                )
            ]
        )

        let stages = service.makePathStagesForTesting(pathSummary: nil, sections: [section], renderState: .starter)

        XCTAssertEqual(stages.count, 1)
        XCTAssertEqual(stages.first?.position, .current)
        XCTAssertEqual(stages.first?.statusLabel, "Current")
        XCTAssertEqual(stages.first?.highlight, "Outline the talk pitch")
    }

    func testMakePathStagesSynthesizesFilmstripWhenNoPathOrSectionsExist() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedGoalsService(repositories: repositories)

        let blockedStages = service.makePathStagesForTesting(pathSummary: nil, sections: [], renderState: .blocked)
        XCTAssertEqual(blockedStages.count, 1)
        XCTAssertEqual(blockedStages.first?.position, .blocked)
        XCTAssertEqual(blockedStages.first?.highlight, "Resolve the blocker")

        let starterStages = service.makePathStagesForTesting(pathSummary: nil, sections: [], renderState: .starter)
        XCTAssertEqual(starterStages.count, 1)
        XCTAssertEqual(starterStages.first?.position, .current)
        XCTAssertEqual(starterStages.first?.highlight, "Take the first visible step")
    }

    func testClarificationAndBlockedScenariosKeepTruthFirstMovement() {
        let clarification = tryUnwrapScenario(PreviewGoalsScenarios.clarificationTarget.id)
        XCTAssertEqual(clarification.strategicStatus.title, "Clarification is the real work right now")
        XCTAssertEqual(clarification.nextMovement?.state, .warning)
        XCTAssertEqual(clarification.nextMovement?.title, "Answer the missing question")

        let blocked = tryUnwrapScenario(PreviewGoalsScenarios.blockedTarget.id)
        XCTAssertEqual(blocked.strategicStatus.title, "The path is waiting on a real blocker")
        XCTAssertEqual(blocked.nextMovement?.state, .warning)
        XCTAssertEqual(blocked.nextMovement?.title, "Resolve the blocker")
    }

    func testExplainabilityRemainsAvailableWithoutOwningFirstLayer() async throws {
        let repositories = try await makeRepositories()
        let runtime = RepositoryBackedRuntimeGoalIntelligenceService(repositories: repositories)
        let service = RepositoryBackedGoalsService(
            repositories: repositories,
            goalIntelligenceService: runtime
        )
        let created = try await service.createGoal(
            CreateGoalRequest(title: "Launch my business"),
            now: fixedNow
        )

        let detail = try await service.loadDetail(target: created.target)

        XCTAssertNotNil(detail.explainability)
        XCTAssertFalse(detail.strategicStatus.summary.isEmpty)
        XCTAssertNotNil(detail.nextMovement)
        XCTAssertFalse(detail.pathStages.isEmpty)
    }
}

private extension GoalDetailStrategicPresentationTests {
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

    func tryUnwrapScenario(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> GoalDetailPresentation {
        guard let detail = PreviewGoalsScenarios.detailScenarios[key] else {
            XCTFail("Missing preview scenario \(key)", file: file, line: line)
            return PreviewGoalsScenarios.detailScenarios.values.first!
        }
        return detail
    }
}
