import XCTest
@testable import Ambitions

final class TodayFreshGoalVisibilityTests: XCTestCase {
    func testCreatedGoalAppearsInTodayTargetsAndFocus() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Ship the native create goal flow"),
            now: fixedNow
        )
        let experience = try await todayService.loadTodayExperience(
            userDisplayName: "Sample User",
            now: fixedNow
        )

        guard case .active = experience.mode else {
            return XCTFail("Expected Today to become active once a created goal exists.")
        }
        XCTAssertFalse(experience.support.fixedCommitments.items.isEmpty)
        XCTAssertTrue(experience.support.fixedCommitments.items.contains(where: {
            $0.subtitle == "Ship the native create goal flow" &&
            $0.action?.target.goalID == created.target.goalID
        }))

        XCTAssertEqual(experience.hero.truth.nowSubtitle, "Ship the native create goal flow")
        XCTAssertFalse(experience.hero.truth.nowTitle.isEmpty)
        XCTAssertEqual(experience.hero.primaryAction.action.kind, .startStepSession)
        XCTAssertFalse(experience.support.timeAperture.windows.isEmpty)
        let heroActions = [experience.hero.primaryAction.action] + experience.hero.primaryAction.supportingActions
        XCTAssertTrue(heroActions.contains(where: {
            $0.kind == .openDetail && $0.target.goalID == created.target.goalID
        }))
    }

    func testSCG009CPersistedGoalThreadFeedsTodayAfterRepositoryReload() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let writeRepositories = makeRepositories(store: store)
        let readRepositories = makeRepositories(store: store)
        let goalsService = RepositoryBackedGoalsService(repositories: writeRepositories)
        let todayService = RepositoryBackedTodayService(repositories: readRepositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Feed Today from a persisted goal thread"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let fetchedGoal = try await readRepositories.goals.goal(id: goalID)
        let persistedGoal = try XCTUnwrap(fetchedGoal)

        let experience = try await todayService.loadTodayExperience(
            userDisplayName: "Sample User",
            now: fixedNow.addingTimeInterval(60)
        )
        let primaryStepID = try XCTUnwrap(experience.hero.primaryAction.action.target.stepID)
        let persistedStep = try XCTUnwrap(persistedGoal.plan?.sections.flatMap(\.steps).first { $0.id == primaryStepID })

        guard case .active = experience.mode else {
            return XCTFail("Expected persisted goal thread state to make Today active.")
        }
        XCTAssertEqual(experience.hero.truth.nowSubtitle, "Feed Today from a persisted goal thread")
        XCTAssertEqual(experience.hero.primaryAction.action.target.goalID, goalID)
        XCTAssertEqual(experience.hero.primaryAction.action.target.stepID, persistedStep.id)
        XCTAssertTrue(experience.support.fixedCommitments.items.contains {
            $0.action?.target.goalID == goalID && $0.action?.target.stepID == persistedStep.id
        })
    }

    func testQuickLogActionCreatesPersistedCapture() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Ship capture persistence"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let fetchedGoal = try await repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(fetchedGoal)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        let priorEvidence = try await repositories.evidence.listEvidence(goalID: goalID)

        _ = try await todayService.performAction(
            TodayInlineAction(
                kind: .quickLog,
                title: "Quick log",
                systemImage: "plus.bubble",
                state: .success,
                target: TodayActionTarget(goalID: goalID, stepID: step.id)
            ),
            now: fixedNow
        )
        let captures = try await repositories.captures.listCaptures()
        let evidence = try await repositories.evidence.listEvidence(goalID: goalID)

        XCTAssertEqual(captures.count, 1)
        XCTAssertEqual(captures.first?.status, .actionable)
        XCTAssertEqual(captures.first?.sourceType, .todayQuickCapture)
        XCTAssertEqual(captures.first?.linkedGoalID, goalID)
        XCTAssertEqual(evidence.count, priorEvidence.count + 1)
        XCTAssertTrue(evidence.contains(where: { $0.evidenceKind == .sessionLogged }))
        XCTAssertTrue(evidence.contains(where: { $0.goalID == goalID && $0.stepID == step.id && $0.source == .manual }))
    }

    func testNavigationOnlyActionsDoNotCreateMutationsInTodayData() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Protect the day from noisy state changes"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let initialCaptures = try await repositories.captures.listCaptures()
        let initialFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let initialEvidence = try await repositories.evidence.listEvidence(goalID: nil)

        let response = try await todayService.performAction(
            TodayInlineAction(
                kind: .openTime,
                title: "Open Time",
                systemImage: "calendar",
                state: .default,
                target: TodayActionTarget()
            ),
            now: fixedNow
        )
        let finalCaptures = try await repositories.captures.listCaptures()
        let finalFeedback = try await repositories.feedback.listEvents(goalID: goalID)
        let finalEvidence = try await repositories.evidence.listEvidence(goalID: nil)

        XCTAssertNil(response.message)
        XCTAssertEqual(initialCaptures.count, finalCaptures.count)
        XCTAssertEqual(initialFeedback.count, finalFeedback.count)
        XCTAssertEqual(initialEvidence.count, finalEvidence.count)
    }

    func testAskWhyThisMattersUsesMetadataBackedProjectionWhenDraftMetadataExists() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let todayService = RepositoryBackedTodayService(repositories: repositories)

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let draftID = try XCTUnwrap(created.target.draftID)
        let storedGoal = try await repositories.goals.goal(id: goalID)
        let storedDraft = try await repositories.drafts.draft(id: draftID)
        let goal = try XCTUnwrap(storedGoal)
        let draft = try XCTUnwrap(storedDraft)
        let step = try XCTUnwrap(goal.plan?.sections.first?.steps.first)
        let expected = DefaultGoalExplainabilityProjector().makeState(
            metadata: try XCTUnwrap(draft.metadata),
            applicableSignals: nil,
            primaryStepID: step.id,
            whyNow: LearningAnticipationService().learnedStepInsight(
                goal: goal,
                step: step,
                snapshot: LearningAnticipationService().buildSnapshot(
                    goals: [goal],
                    evidence: [],
                    feedback: [.askedWhyThisMatters(
                        base: GoalFeedbackEventBase(
                            id: "feedback-why",
                            stepID: step.id,
                            occurredAt: DomainTimestamp.string(from: fixedNow),
                            note: "Asked why this matters from Today."
                        )
                    )],
                    now: fixedNow
                ),
                now: fixedNow
            ).whyNow
        )

        let response = try await todayService.performAction(
            TodayInlineAction(
                kind: .askWhyThisMatters,
                title: "Why this matters",
                systemImage: "questionmark.circle",
                state: .default,
                target: TodayActionTarget(goalID: goalID, stepID: step.id, draftID: draftID)
            ),
            now: fixedNow
        )

        XCTAssertEqual(response.message?.title, "Why this matters")
        XCTAssertEqual(response.message?.body, expected.whyThis.compactSummary)
    }

    func testAskWhyThisMattersMatchesRuntimeIntelligencePath() async throws {
        let directRepositories = try await makeRepositories()
        let runtimeRepositories = try await makeRepositories()
        let directGoalsService = RepositoryBackedGoalsService(repositories: directRepositories)
        let runtimeGoalsService = RepositoryBackedGoalsService(repositories: runtimeRepositories)

        let directCreated = try await directGoalsService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let runtimeCreated = try await runtimeGoalsService.createGoal(
            CreateGoalRequest(title: "Submit my conference talk proposal by 2026-05-15"),
            now: fixedNow
        )
        let directGoalID = try XCTUnwrap(directCreated.target.goalID)
        let runtimeGoalID = try XCTUnwrap(runtimeCreated.target.goalID)
        let directStoredGoal = try await directRepositories.goals.goal(id: directGoalID)
        let runtimeStoredGoal = try await runtimeRepositories.goals.goal(id: runtimeGoalID)
        let directGoal = try XCTUnwrap(directStoredGoal)
        let runtimeGoal = try XCTUnwrap(runtimeStoredGoal)
        let directStep = try XCTUnwrap(directGoal.plan?.sections.first?.steps.first)
        let runtimeStep = try XCTUnwrap(runtimeGoal.plan?.sections.first?.steps.first)

        let directTodayService = RepositoryBackedTodayService(repositories: directRepositories)
        let migratedTodayService = RepositoryBackedTodayService(
            repositories: runtimeRepositories,
            goalIntelligenceService: RepositoryBackedRuntimeGoalIntelligenceService(repositories: runtimeRepositories)
        )

        let directResponse = try await directTodayService.performAction(
            TodayInlineAction(
                kind: .askWhyThisMatters,
                title: "Why this matters",
                systemImage: "questionmark.circle",
                state: .default,
                target: TodayActionTarget(goalID: directGoalID, stepID: directStep.id, draftID: directCreated.target.draftID)
            ),
            now: fixedNow
        )
        let migratedResponse = try await migratedTodayService.performAction(
            TodayInlineAction(
                kind: .askWhyThisMatters,
                title: "Why this matters",
                systemImage: "questionmark.circle",
                state: .default,
                target: TodayActionTarget(goalID: runtimeGoalID, stepID: runtimeStep.id, draftID: runtimeCreated.target.draftID)
            ),
            now: fixedNow
        )

        XCTAssertEqual(migratedResponse.message?.title, directResponse.message?.title)
        XCTAssertEqual(migratedResponse.message?.body, directResponse.message?.body)
    }

    @MainActor
    func testTodayViewModelActivateRefreshesOnReturnToTodayTab() async {
        let first = PreviewTodayScenarios.empty
        let second = PreviewTodayScenarios.recovery
        let service = MutableTodayService(experience: first)
        let viewModel = TodayViewModel()

        await viewModel.activate(using: service, userDisplayName: "Sample User", now: fixedNow, calendar: PreviewClock.utcCalendar)

        guard case let .loaded(initialExperience) = viewModel.state else {
            return XCTFail("Expected Today to load on first activation.")
        }
        guard case .empty = initialExperience.mode else {
            return XCTFail("Expected the first activation to use the initial empty scenario.")
        }

        await service.setExperience(second)
        await viewModel.activate(using: service, userDisplayName: "Sample User", now: fixedNow, calendar: PreviewClock.utcCalendar)

        guard case let .loaded(refreshedExperience) = viewModel.state else {
            return XCTFail("Expected Today to refresh when activated again.")
        }
        guard case .active = refreshedExperience.mode else {
            return XCTFail("Expected the second activation to reflect the updated active scenario.")
        }
        XCTAssertEqual(refreshedExperience.hero.truth.posture, .recovering)
        XCTAssertEqual(refreshedExperience.hero.truth.nowTitle, "Split the next step")
        XCTAssertNotNil(refreshedExperience.support.recoveryBloom)
    }
}

private extension TodayFreshGoalVisibilityTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    func makeRepositories() async throws -> AppRepositories {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        return makeRepositories(store: store)
    }

    func makeRepositories(store: AmbitionsPersistenceStore) -> AppRepositories {
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

private actor MutableTodayService: TodayServicing {
    private var experience: TodayExperience

    init(experience: TodayExperience) {
        self.experience = experience
    }

    func setExperience(_ experience: TodayExperience) {
        self.experience = experience
    }

    func loadTodayExperience(userDisplayName: String, now: Date, entryContext: TodayEntryContext) async throws -> TodayExperience {
        _ = userDisplayName
        _ = now
        _ = entryContext
        return experience
    }

    func performAction(_ action: TodayInlineAction, now: Date) async throws -> TodayActionResponse {
        _ = action
        _ = now
        return TodayActionResponse(message: nil)
    }
}
