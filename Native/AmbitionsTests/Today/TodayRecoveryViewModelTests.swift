@testable import Ambitions
import AmbitionsDesignSystem
import Foundation
import XCTest

final class TodayRecoveryViewModelTests: TodayViewModelTestCase {
    func testRepositoryBackedServiceCanSurfaceSharedResponsibilityRitualThesis() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-20T09:00:00Z"))
        var goal = makeGoal(id: "goal-home", stepID: "step-home", stepTitle: "Home shared step", dueAt: "2026-04-21T16:00:00Z")
        goal = Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision,
            createdAt: goal.createdAt,
            updatedAt: goal.updatedAt,
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: .support,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: goal.plan,
            lifeGraph: LifeGraphContext(
                domains: [LifeDomainAssignment(domain: .home)],
                roles: [LifeRole(kind: .supporting, title: "Partner support")],
                path: nil,
                stages: [],
                prerequisites: [],
                milestones: [],
                sharedLife: SharedLifeContext(
                    participants: [SharedLifeParticipant(id: "partner", displayName: "Alex", relationshipKind: .partner, roleLabel: "Partner")],
                    responsibilities: [SharedResponsibility(id: "groceries", title: "Groceries", kind: .household, participantID: "partner")]
                )
            )
        )
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)

        XCTAssertTrue(experience.hero.truth.supportingText.localizedCaseInsensitiveContains("shared"))
    }

    func testSharedNextStepSelectorDeprioritizesBlockedDependencyWork() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let blocked = makeGoal(
            id: "goal-blocked",
            stepID: "step-blocked",
            stepTitle: "Blocked dependency step",
            dueAt: "2026-04-16T12:00:00Z",
            stepState: .blocked,
            dependencyStepIDs: ["step-prereq"]
        )
        let clean = makeGoal(
            id: "goal-clean",
            stepID: "step-clean",
            stepTitle: "Clean recovery-safe step",
            dueAt: "2026-04-17T12:00:00Z"
        )
        try await repositories.goals.saveGoals([blocked, clean])

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let expected = PlanningNextStepSelector().bestSelection(goals: [blocked, clean], now: now)

        XCTAssertEqual(expected?.goal.id, "goal-clean")
        XCTAssertEqual(experience.hero.truth.nowTitle, expected?.step.title)
        XCTAssertEqual(experience.support.fixedCommitments.items.first?.id, expected?.step.id)
        XCTAssertNil(experience.support.recoveryBloom)
        XCTAssertEqual(experience.support.timeAperture.bestUseTitle, "Next 45 minutes")
        XCTAssertFalse(experience.support.timeAperture.windows.isEmpty)
    }

    func testFCP16OverloadedTodayShowsSmallerRecoveryLoopAndReceiptPreview() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-15T12:00:00Z"))
        let goals = (0..<5).map {
            makeGoal(
                id: "goal-overload-\($0)",
                stepID: "step-overload-\($0)",
                stepTitle: "Overload step \($0)",
                dueAt: "2026-04-15T20:00:00Z"
            )
        }
        try await repositories.goals.saveGoals(goals)
        let beforeGoals = try await repositories.goals.listGoals()
        let beforeCaptures = try await repositories.captures.listCaptures()

        let experience = try await service.loadTodayExperience(userDisplayName: "", now: now)
        let afterGoals = try await repositories.goals.listGoals()
        let afterCaptures = try await repositories.captures.listCaptures()
        let recovery = try XCTUnwrap(experience.support.recoveryBloom)
        let visibleCopy = [
            recovery.title,
            recovery.subtitle,
            recovery.explanation,
            recovery.pressureFieldLabel,
            recovery.recoveryLoopLabel,
            recovery.smallerStepAnchorLabel,
            recovery.recoveryReceiptPreviewLabel,
            recovery.options.map { "\($0.title) \($0.detail)" }.joined(separator: " ")
        ].joined(separator: " ").lowercased()

        XCTAssertEqual(experience.hero.truth.posture, .overloaded)
        XCTAssertEqual(recovery.title, "Lighten today")
        XCTAssertTrue(recovery.pressureFieldLabel.contains("Pressure field"))
        XCTAssertTrue(recovery.recoveryLoopLabel.contains("smaller safe next step"))
        XCTAssertTrue(recovery.smallerStepAnchorLabel.contains("small enough to start"))
        XCTAssertTrue(recovery.recoveryReceiptPreviewLabel.contains("Recovery review preview"))
        XCTAssertEqual(recovery.options.first?.title, "Smaller version")
        XCTAssertEqual(recovery.options.first?.action.kind, .split)
        XCTAssertFalse(visibleCopy.contains("overdue"))
        XCTAssertFalse(visibleCopy.contains("failed"))
        XCTAssertFalse(visibleCopy.contains("streak rescue"))
        XCTAssertFalse(visibleCopy.contains(forbiddenCopyTerm("productivity", "score")))
        XCTAssertEqual(beforeGoals, afterGoals)
        XCTAssertEqual(beforeCaptures, afterCaptures)
    }

    func testStepSessionEntryContextSurfacesBoundedStepSession() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedTodayService(repositories: repositories)
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-21T08:00:00Z"))
        let goal = makeGoal(id: "goal-step-session", stepID: "step-session-step", stepTitle: "Step session-backed step", dueAt: "2026-04-21T16:00:00Z")
        try await repositories.goals.saveGoals([goal])

        let experience = try await service.loadTodayExperience(
            userDisplayName: "",
            now: now,
            entryContext: .stepSession
        )

        XCTAssertEqual(experience.hero.truth.posture, .stable)
        XCTAssertEqual(experience.hero.primaryAction.action.kind, .complete)
        XCTAssertEqual(experience.support.stepSession?.title, "Step session-backed step")
        XCTAssertTrue(experience.support.stepSession?.detail.contains("Step session") == true)
        XCTAssertEqual(experience.support.stepSession?.primaryAction.kind, .complete)
        XCTAssertEqual(experience.support.stepSession?.contextReminderLabel, "One step is in focus. The rest of Today stays available behind it.")
        XCTAssertEqual(experience.support.stepSession?.goalConnectionLabel, "Goal context stays attached while this step is in session.")
        XCTAssertFalse(experience.support.stepSession?.visibleCopy.localizedCaseInsensitiveContains(forbiddenCopyTerm("AI", "confidence")) == true)
        XCTAssertFalse(experience.support.stepSession?.visibleCopy.localizedCaseInsensitiveContains("overdue") == true)
        XCTAssertFalse(experience.support.stepSession?.visibleCopy.localizedCaseInsensitiveContains("streak") == true)
    }

    @MainActor
    func testHandlePublishesTransientMessageAfterActionResponse() async {
        let expectedMessage = TodayInlineMessage(
            title: "Captured",
            body: "Progress was saved.",
            state: .success
        )
        let viewModel = TodayViewModel(state: .loaded(PreviewTodayScenarios.empty))
        let service = TodayViewModelServiceRecorder(experience: PreviewTodayScenarios.empty, actionResponse: TodayActionResponse(message: expectedMessage))

        await viewModel.handle(
            TodayInlineAction(
                kind: .openTime,
                title: "Open Time",
                systemImage: "calendar",
                state: .success,
                target: TodayActionTarget(goalID: "goal-1", stepID: "step-1")
            ),
            using: service,
            userDisplayName: "",
            now: PreviewClock.default.now,
            calendar: PreviewClock.default.calendar
        )

        let transientMessage = viewModel.transientMessage
        XCTAssertEqual(transientMessage?.title, expectedMessage.title)
        XCTAssertEqual(transientMessage?.body, expectedMessage.body)
        let actionCount = await service.performedActionCount()
        XCTAssertEqual(actionCount, 1)
    }

    @MainActor
    func testRefreshFailureMovesStateToFailed() async {
        let viewModel = TodayViewModel()
        await viewModel.refresh(
            using: TodayViewModelFailingService(),
            userDisplayName: "",
            now: PreviewClock.default.now,
            calendar: PreviewClock.default.calendar
        )

        let state = viewModel.state
        guard case let .failed(message) = state else {
            return XCTFail("Expected Today refresh to end in a failed state.")
        }

        XCTAssertTrue(message.contains("Unable to load Today"))
    }
}
import AmbitionsTimeFoundation
