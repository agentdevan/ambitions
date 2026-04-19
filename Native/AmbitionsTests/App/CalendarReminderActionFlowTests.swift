import XCTest
@testable import Ambitions

final class CalendarReminderActionFlowTests: XCTestCase {
    func testGoalDetailCreateCalendarEventUsesSelectedStepAndReportsConflictCount() async throws {
        let repositories = try await makeRepositories()
        let calendarService = RecordingCalendarRemindersService()
        let goalsService = RepositoryBackedGoalsService(
            repositories: repositories,
            calendarRemindersService: calendarService
        )

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Ship CFP proposal 2026-05-01"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let fetchedGoal = try await repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(fetchedGoal)
        let scheduledStep = try XCTUnwrap(goal.plan?.sections.first?.steps.last)

        await calendarService.setCalendarAuthorizationResponse(.fullAccess)
        await calendarService.setConflictReport(
            CalendarConflictReport(
                proposedStartDate: fixedNow,
                proposedEndDate: fixedNow.addingTimeInterval(45 * 60),
                conflicts: [
                    CalendarConflict(
                        title: "Existing overlap",
                        startDate: fixedNow.addingTimeInterval(-300),
                        endDate: fixedNow.addingTimeInterval(900),
                        isAllDay: false
                    )
                ]
            )
        )

        let response = try await goalsService.performAction(
            GoalDetailActionRequest(
                target: created.target,
                kind: .createCalendarEvent,
                stepID: scheduledStep.id
            ),
            now: fixedNow
        )

        let message = try XCTUnwrap(response.message)
        let selection = await calendarService.lastCalendarSelection

        XCTAssertEqual(message.title, "Calendar event created")
        XCTAssertTrue(message.body.contains("\"\(scheduledStep.title)\" was scheduled."))
        XCTAssertTrue(message.body.contains("1 overlap detected."))
        XCTAssertEqual(selection?.goalID, goalID)
        XCTAssertEqual(selection?.stepID, scheduledStep.id)
        XCTAssertEqual(selection?.suggestedDate, suggestedDate(for: scheduledStep))
    }

    func testTodayCreateCalendarEventUsesDateOnlyStepTiming() async throws {
        let repositories = try await makeRepositories()
        let goalsService = RepositoryBackedGoalsService(repositories: repositories)
        let calendarService = RecordingCalendarRemindersService()
        let todayService = RepositoryBackedTodayService(
            repositories: repositories,
            calendarRemindersService: calendarService
        )

        let created = try await goalsService.createGoal(
            CreateGoalRequest(title: "Ship capture follow-through 2026-05-01"),
            now: fixedNow
        )
        let goalID = try XCTUnwrap(created.target.goalID)
        let fetchedGoal = try await repositories.goals.goal(id: goalID)
        let goal = try XCTUnwrap(fetchedGoal)
        let scheduledStep = try XCTUnwrap(goal.plan?.sections.first?.steps.last)

        await calendarService.setCalendarAuthorizationResponse(.fullAccess)

        let response = try await todayService.performAction(
            TodayInlineAction(
                kind: .createCalendarEvent,
                title: "Calendar event",
                systemImage: "calendar.badge.plus",
                state: .default,
                target: TodayActionTarget(goalID: goalID, stepID: scheduledStep.id)
            ),
            now: fixedNow
        )

        let message = try XCTUnwrap(response.message)
        let selection = await calendarService.lastCalendarSelection

        XCTAssertEqual(message.title, "Calendar event created")
        XCTAssertTrue(message.body.contains("\"\(scheduledStep.title)\" was scheduled."))
        XCTAssertTrue(message.body.contains("No overlap detected."))
        XCTAssertEqual(selection?.goalID, goalID)
        XCTAssertEqual(selection?.stepID, scheduledStep.id)
        XCTAssertEqual(selection?.stepTitle, scheduledStep.title)
        XCTAssertEqual(selection?.suggestedDate, suggestedDate(for: scheduledStep))
    }
}

private extension CalendarReminderActionFlowTests {
    var fixedNow: Date {
        Date(timeIntervalSince1970: 1_712_692_800)
    }

    func suggestedDate(for step: Step) -> Date? {
        guard let value = step.timing.suggestedNextAt ?? step.timing.targetBy ?? step.timing.dueAt else {
            return nil
        }
        if let date = DomainTimestamp.date(from: value) {
            return date
        }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.date(from: value)
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

private actor RecordingCalendarRemindersService: CalendarRemindersServicing {
    private var reminderAuthorizationResponse: CalendarRemindersAuthorizationState = .notDetermined
    private var calendarAuthorizationResponse: CalendarRemindersAuthorizationState = .notDetermined
    private var conflictReport: CalendarConflictReport?

    private(set) var lastReminderSelection: NextStepSchedulingSelection?
    private(set) var lastCalendarSelection: NextStepSchedulingSelection?

    func authorizationState(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        switch scope {
        case .reminders:
            return reminderAuthorizationResponse
        case .calendarEvents:
            return calendarAuthorizationResponse
        }
    }

    func requestAuthorizationIfNeeded(for scope: CalendarRemindersScope) async -> CalendarRemindersAuthorizationState {
        await authorizationState(for: scope)
    }

    func createReminder(for selection: NextStepSchedulingSelection, now: Date) async throws -> CreatedReminderRecord {
        _ = now
        lastReminderSelection = selection
        return CreatedReminderRecord(identifier: "reminder-test", title: selection.stepTitle)
    }

    func createCalendarEvent(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async throws -> CreatedCalendarEventRecord {
        _ = durationMinutes
        _ = now
        lastCalendarSelection = selection
        let start = selection.suggestedDate ?? now
        return CreatedCalendarEventRecord(
            identifier: "event-test",
            title: selection.stepTitle,
            startDate: start,
            endDate: start.addingTimeInterval(45 * 60)
        )
    }

    func detectConflicts(for selection: NextStepSchedulingSelection, durationMinutes: Int, now: Date) async -> CalendarConflictReport? {
        _ = selection
        _ = durationMinutes
        _ = now
        return conflictReport
    }

    func setReminderAuthorizationResponse(_ state: CalendarRemindersAuthorizationState) {
        reminderAuthorizationResponse = state
    }

    func setCalendarAuthorizationResponse(_ state: CalendarRemindersAuthorizationState) {
        calendarAuthorizationResponse = state
    }

    func setConflictReport(_ report: CalendarConflictReport?) {
        conflictReport = report
    }
}
