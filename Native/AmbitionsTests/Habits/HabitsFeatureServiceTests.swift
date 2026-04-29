import XCTest
@testable import Ambitions

final class HabitsFeatureServiceTests: XCTestCase {
    func testLoadDashboardFromEmptyRepositoriesShowsEmptyMode() async throws {
        let repositories = try await makeRepositories()
        let service = RepositoryBackedHabitsService(repositories: repositories)

        let dashboard = try await service.loadDashboard(now: .now)

        XCTAssertEqual(dashboard.mode, .empty)
        XCTAssertEqual(dashboard.emptyTitle, "No rituals are live yet")
    }

    func testQuickLogAddsEvidenceAndShowsPartialStatus() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedHabitsService(repositories: repositories)
        let habitGoals = try await repositories.goals.listHabitGoals()
        let goal = try XCTUnwrap(habitGoals.first)
        let step = try XCTUnwrap(HabitGoalSemantics.preferredStep(in: goal))
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(formatter.date(from: GoalEngineFixtures.fixedNow))

        _ = try await service.performAction(
            HabitActionRequest(
                kind: .quickLog,
                target: HabitActionTarget(goalID: goal.id, stepID: step.id, draftID: nil)
            ),
            now: now
        )

        let evidence = try await repositories.evidence.listEvidence(goalID: goal.id)
        let dashboard = try await service.loadDashboard(now: now)
        let loggedHabit = try XCTUnwrap((dashboard.habits + dashboard.recoveryHabits).first(where: { $0.id == goal.id }))

        XCTAssertTrue(evidence.contains(where: { $0.evidenceKind == .habitQuickLog && $0.stepID == step.id }))
        XCTAssertEqual(loggedHabit.status, .partial)
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }

    func testD16RitualSurfaceCopyDoesNotPresentStandaloneHabitsPosture() async throws {
        #if DEBUG
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let repositories = try await AppContainerFactory.prepareRepositories(for: .demo, store: store)
        let service = RepositoryBackedHabitsService(repositories: repositories)
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        let now = try XCTUnwrap(formatter.date(from: GoalEngineFixtures.fixedNow))

        let dashboard = try await service.loadDashboard(now: now)
        let surfaceCopy = userFacingCopy(from: dashboard).joined(separator: " ")

        XCTAssertTrue(surfaceCopy.localizedCaseInsensitiveContains("ritual"))
        XCTAssertFalse(surfaceCopy.localizedCaseInsensitiveContains("habit"))

        let firstRitual = try XCTUnwrap((dashboard.habits + dashboard.recoveryHabits).first)
        let openDetail = try XCTUnwrap(firstRitual.actions.first(where: { $0.kind == .openDetail }))
        let response = try await service.performAction(
            HabitActionRequest(kind: openDetail.kind, target: openDetail.target),
            now: now
        )

        let message = try XCTUnwrap(response.message)
        XCTAssertTrue(message.title.localizedCaseInsensitiveContains("ritual"))
        XCTAssertTrue(message.body.localizedCaseInsensitiveContains("ritual"))
        XCTAssertFalse(message.title.localizedCaseInsensitiveContains("habit"))
        XCTAssertFalse(message.body.localizedCaseInsensitiveContains("habit"))
        #else
        throw XCTSkip("Demo bootstrap fixtures are only available in DEBUG builds.")
        #endif
    }
}

private extension HabitsFeatureServiceTests {
    func userFacingCopy(from dashboard: HabitsDashboard) -> [String] {
        var copy = [
            dashboard.title,
            dashboard.subtitle,
            dashboard.summaryLabel,
            dashboard.summaryDetail,
            dashboard.streak.title,
            dashboard.streak.subtitle,
            dashboard.streak.recoveryNote,
            dashboard.guidanceTitle,
            dashboard.guidanceBody
        ]
        copy.append(contentsOf: dashboard.stats.flatMap { [$0.title, $0.value, $0.detail ?? ""] })
        copy.append(contentsOf: dashboard.streak.stats.flatMap { [$0.title, $0.value, $0.detail ?? ""] })
        copy.append(contentsOf: (dashboard.habits + dashboard.recoveryHabits).flatMap { summary in
            [
                summary.cadenceLabel,
                summary.streakLabel,
                summary.consistencyLabel,
                summary.progressLabel,
                summary.status.title,
                summary.note,
                summary.minimumVersionLabel ?? "",
                summary.supportLabel ?? ""
            ] + summary.actions.map(\.title)
        })
        return copy.filter { !$0.isEmpty }
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
