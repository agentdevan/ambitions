import XCTest
@testable import Ambitions

final class AmbitionsProductCanonV2ModelsTests: XCTestCase {
    func testDurationLabelsAreGroundedAndNeverPretendSuggestedDurationsAreFacts() {
        XCTAssertEqual(
            DurationMetadata(plannedDuration: .seconds(1_800), source: .userSet).displayLabel,
            "30 min planned"
        )
        XCTAssertEqual(
            DurationMetadata(plannedDuration: .seconds(900), source: .suggested).displayLabel,
            "Suggested: 15 min"
        )
        XCTAssertEqual(
            DurationMetadata(source: .historical, range: .seconds(600) ... .seconds(1_800)).displayLabel,
            "Usually 10 min-30 min"
        )
        XCTAssertEqual(
            DurationMetadata(source: .unset).displayLabel,
            "Duration not set"
        )
        XCTAssertEqual(
            DurationMetadata(actualDuration: .seconds(720), source: .actual).displayLabel,
            "Completed in 12 min"
        )
    }

    func testVacationIsUnavailableByDefaultAndCanBeExplicitlyChangedPerVacation() {
        XCTAssertEqual(VacationAvailabilityBehavior.defaultBehavior, .unavailable)
        XCTAssertEqual(VacationAvailabilityBehavior.defaultBehavior.availabilityState, .unavailable)

        let choice = VacationAvailabilityChoice(behavior: .flexible, makeDefaultForFutureVacations: true)

        XCTAssertEqual(choice.behavior.availabilityState, .flexible)
        XCTAssertTrue(choice.makeDefaultForFutureVacations)
    }

    func testTimeContextHierarchyExcludesHardContextBeforeReportingOpenWindows() {
        let calendar = Calendar(identifier: .gregorian)
        let start = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 8))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 18))!
        let workStart = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 9))!
        let workEnd = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 12))!
        let commuteStart = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 12))!
        let commuteEnd = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 12, minute: 30))!
        let protectedStart = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 15))!
        let protectedEnd = calendar.date(from: DateComponents(year: 2026, month: 4, day: 29, hour: 16))!
        let blocks = [
            TimeContextBlock(kind: .work, start: workStart, end: workEnd, source: .workSchedule, rigidity: .fixed, availability: .unavailable),
            TimeContextBlock(kind: .commute, start: commuteStart, end: commuteEnd, source: .calendar, rigidity: .fixed, availability: .unavailable),
            TimeContextBlock(kind: .protected, start: protectedStart, end: protectedEnd, source: .protectedByYou, rigidity: .protected, availability: .protectedFreeTime),
        ]

        let windows = TimeContextHierarchyProjector().availabilityWindows(dayStart: start, dayEnd: end, blocks: blocks)

        XCTAssertEqual(windows.map { Int($0.end.timeIntervalSince($0.start) / 60) }, [60, 150, 120])
        XCTAssertTrue(windows.allSatisfy { $0.state == .open })
    }

    func testVacationBlockIsHardContextUnlessUserMarksItOpenOrFlexible() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let end = start.addingTimeInterval(3_600)

        let unavailable = TimeContextBlock(kind: .vacation, start: start, end: end, source: .fromYou, rigidity: .protected, availability: .unavailable)
        let open = TimeContextBlock(kind: .vacation, start: start, end: end, source: .fromYou, rigidity: .flexible, availability: .open)

        XCTAssertTrue(unavailable.isHardContext)
        XCTAssertFalse(open.isHardContext)
    }

    func testAutomationDefaultIsGuidedAndMeaningfulReflowRequiresApproval() {
        XCTAssertEqual(AutomationLevel.defaultLevel, .guided)
        XCTAssertEqual(AutomationLevel.guided.explanation, "Ambitions proposes and asks before changing meaningful parts of the day.")

        let window = AvailabilityWindow(
            start: Date(timeIntervalSinceReferenceDate: 0),
            end: Date(timeIntervalSinceReferenceDate: 1_200),
            state: .open,
            source: .plan
        )
        let opportunity = ReflowOpportunity(reason: .completedEarly, openedWindow: window)

        XCTAssertTrue(opportunity.requiresUserApproval)
        XCTAssertEqual(opportunity.promptTitle, "Use this open time?")
        XCTAssertEqual(Set(opportunity.suggestedOptions.map(\.displayLabel)), ["Suggest a step", "Reflow my day", "Protect this time", "Keep plan as is"])
    }

    func testClosureStateLabelsAvoidOverdueFailedMissedBehindLanguage() {
        let labels = ClosureState.allCases.map(\.displayLabel).joined(separator: " ")

        XCTAssertEqual(ClosureState.awaitingClosure.displayLabel, "Needs a quick check")
        XCTAssertEqual(ClosureState.stillCounts.displayLabel, "Still Counts")
        XCTAssertEqual(ClosureState.moved.displayLabel, "Rescheduled")
        XCTAssertFalse(labels.localizedCaseInsensitiveContains("Overdue"))
        XCTAssertFalse(labels.localizedCaseInsensitiveContains("Failed"))
        XCTAssertFalse(labels.localizedCaseInsensitiveContains("Missed"))
        XCTAssertFalse(labels.localizedCaseInsensitiveContains("Behind"))
    }

    func testStepOccurrenceRecommendationRespectsReadinessClosureAndCognitiveFitEvidence() {
        let stepID = UUID()
        let occurrence = StepOccurrence(
            stepID: stepID,
            duration: DurationMetadata(plannedDuration: .seconds(1_200), source: .userAccepted),
            rigidity: .flexible,
            readiness: .ready,
            contextRequirements: [.quietRequired, .device],
            closureState: .now,
            cognitiveFits: [
                StepCognitiveFit(fit: .creative, evidence: .inferredFromContext),
                StepCognitiveFit(fit: .admin, evidence: .userSelected),
            ]
        )
        let waiting = StepOccurrence(
            stepID: stepID,
            duration: DurationMetadata(source: .unset),
            rigidity: .waiting,
            readiness: .waitingOnPerson,
            closureState: .waiting
        )

        XCTAssertTrue(occurrence.isRecommendableNow)
        XCTAssertEqual(Set(occurrence.cognitiveFits.map(\.evidence)), [.inferredFromContext, .userSelected])
        XCTAssertFalse(waiting.isRecommendableNow)
    }
}
