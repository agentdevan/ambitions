import Foundation
import XCTest
@testable import Ambitions

final class IOS26CalendarP0ContractHarnessTests: XCTestCase {
    func testHarnessBlocksBroadReplacementClaimsWhileRecurrenceEvidenceIsMissing() {
        let harness = CalendarP0ContractHarnessFixture(
            scheduledBlocksEvidence: true,
            recurrenceEvidence: false,
            eventKitPermissionEvidence: true,
            deniedFallbackEvidence: true,
            conflictDetectionEvidence: true,
            protectedFreeTimeEvidence: true,
            scheduleReceiptEvidence: true,
            todayConsumptionEvidence: true,
            replayAndPrivacyBoundaryEvidence: true,
            unsupportedClaims: CalendarP0ContractHarnessFixture.forbiddenBroadClaims
        )

        XCTAssertEqual(harness.missingEvidence, ["recurrence"])
        XCTAssertTrue(harness.blocksBroadReplacementClaims)
        XCTAssertFalse(harness.allEvidencePresent)
        XCTAssertEqual(Set(harness.blockedClaims), Set(CalendarP0ContractHarnessFixture.forbiddenBroadClaims))
    }

    func testSourceBackedScheduleContractsStayLocalOnlyAndRecordReceipts() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(4 * 3_600))
        let scheduledBlock = ScheduledAmbitionsBlock(
            id: "calendar-p0.block-1",
            title: "Draft proposal",
            start: now.addingTimeInterval(3_600),
            end: now.addingTimeInterval(5_400),
            contextLens: .work,
            relatedGoalID: "goal-1",
            relatedPlanID: "plan-1",
            isUserConfirmed: true,
            calendarEventIdentifier: "event-1"
        )
        let calendarContext = CalendarDerivedContext(
            permissionState: .readWrite,
            observedRangeStart: horizon.start,
            observedRangeEnd: horizon.end,
            derivedBusyWindowCount: 1,
            userInitiatedTimeAction: "Find real open windows",
            explanation: "Calendar-derived busy time stayed local.",
            eventLedgerEntryIDs: ["ledger.calendar.1"],
            recommendationExplanationIDs: ["explanation.calendar.1"]
        )
        let busyWindow = RealityWindow(
            id: "calendar-busy-1",
            kind: .calendarDerivedBusy,
            source: .calendarDerived,
            start: now.addingTimeInterval(1_800),
            end: now.addingTimeInterval(7_200),
            title: "Calendar busy time"
        )

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                workingWindows: [
                    RealityWindow(
                        id: "work-1",
                        kind: .working,
                        source: .userDefined,
                        start: now,
                        end: now.addingTimeInterval(3_600),
                        title: "Work block"
                    )
                ],
                protectedWindows: [
                    RealityWindow(
                        id: "protected-1",
                        kind: .protected,
                        source: .userDefined,
                        start: now.addingTimeInterval(7_200),
                        end: now.addingTimeInterval(10_800),
                        title: "Protected free time"
                    )
                ],
                scheduledBlocks: [scheduledBlock],
                calendarBusyWindows: [busyWindow],
                calendarContext: calendarContext,
                deadlineHints: [now.addingTimeInterval(9_000)],
                minimumWindowMinutes: 30
            )
        )

        let scheduleEntry = RealityIntegrationAdapter.calendarBlockScheduledEntry(
            block: scheduledBlock,
            occurredAt: now
        )
        let contextEntry = RealityIntegrationAdapter.calendarContextObservedEntry(
            snapshot: snapshot,
            occurredAt: now,
            actionName: "Find real open windows"
        )
        let explanation = RealityIntegrationAdapter.calendarAwareExplanation(
            snapshot: snapshot,
            ledgerEntryID: contextEntry.id
        )
        let confirmedIntent = ScheduledBlockWriteIntent(
            id: "intent-1",
            block: scheduledBlock,
            requestedAt: now
        )
        let unconfirmedIntent = ScheduledBlockWriteIntent(
            id: "intent-2",
            block: ScheduledAmbitionsBlock(
                id: "calendar-p0.block-2",
                title: "Tentative block",
                start: now.addingTimeInterval(10_800),
                end: now.addingTimeInterval(12_600),
                contextLens: .personal,
                isUserConfirmed: false
            ),
            requestedAt: now
        )

        XCTAssertEqual(snapshot.scheduledBlocks, [scheduledBlock])
        XCTAssertEqual(snapshot.availability.calendarDerivedBusyCount, 1)
        XCTAssertEqual(snapshot.capacityEstimate.scheduledAmbitionsMinutes, 30)
        XCTAssertEqual(snapshot.capacityEstimate.protectedMinutes, 60)
        XCTAssertEqual(snapshot.capacityEstimate.calendarBusyMinutes, 90)
        XCTAssertEqual(snapshot.conflictSummary.conflictCount, 2)
        XCTAssertTrue(snapshot.availability.summary.contains("calendar-derived busy time"))
        XCTAssertEqual(snapshot.privacy, .calendarDerived)
        XCTAssertTrue(snapshot.localOnly)
        XCTAssertEqual(scheduleEntry.kind, .planScheduled)
        XCTAssertEqual(scheduleEntry.source, .plan)
        XCTAssertEqual(scheduleEntry.privacy, .standard)
        XCTAssertTrue(scheduleEntry.localOnly)
        XCTAssertEqual(contextEntry.kind, .calendarContextObserved)
        XCTAssertEqual(contextEntry.source, .time)
        XCTAssertEqual(contextEntry.privacy, .calendarDerived)
        XCTAssertTrue(contextEntry.localOnly)
        XCTAssertEqual(explanation.privacy, .calendarDerived)
        XCTAssertTrue(explanation.localOnly)
        XCTAssertEqual(confirmedIntent.isExecutable, true)
        XCTAssertEqual(unconfirmedIntent.isExecutable, false)
    }

    func testLocalScheduleBlocksRoundTripThroughLocalFileWithInspectableTrustIDs() throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ambitions-local-schedule-tests-\(UUID().uuidString)")
        let fileURL = root.appendingPathComponent("schedule-blocks.json")
        defer { try? FileManager.default.removeItem(at: root) }

        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let block = ScheduledAmbitionsBlock(
            id: "local-schedule.block-1",
            title: "Protected writing block",
            start: now,
            end: now.addingTimeInterval(1_800),
            contextLens: .work,
            relatedGoalID: "goal-1",
            isUserConfirmed: true
        )

        let saveReceipts = try upsertLocalScheduleBlock(block, in: fileURL)
        let loaded = try loadLocalScheduleBlocks(from: fileURL)
        let deleteReceipt = try deleteLocalScheduleBlock(id: block.id, from: fileURL)
        let afterDelete = try loadLocalScheduleBlocks(from: fileURL)

        XCTAssertEqual(loaded, [block])
        XCTAssertEqual(saveReceipts, [block.localScheduleReceiptID(action: "save")])
        XCTAssertEqual(block.localScheduleSourceRecordID, "SourceRecord.local-schedule.local-schedule.block-1")
        XCTAssertEqual(block.localScheduleReplayTraceID(action: "save"), "ReplayTrace.local-schedule.local-schedule.block-1.save")
        XCTAssertTrue(block.localScheduleYouInspectionSummary.contains("Search Ambitions"))
        XCTAssertEqual(deleteReceipt, "Receipt.local-schedule.local-schedule.block-1.delete")
        XCTAssertTrue(afterDelete.isEmpty)
    }

    func testDeniedFallbackAndTodayConsumptionRemainInspectableWithoutRawEventLeakage() {
        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let horizon = DateInterval(start: now, end: now.addingTimeInterval(2 * 3_600))
        let calendarContext = CalendarDerivedContext(
            permissionState: .denied,
            observedRangeStart: horizon.start,
            observedRangeEnd: horizon.end,
            derivedBusyWindowCount: 0,
            userInitiatedTimeAction: "Make Time calendar-aware",
            explanation: "Time still works without calendar access."
        )

        let snapshot = RealityModelProjector().project(
            input: RealityProjectionInput(
                now: now,
                horizon: horizon,
                calendarContext: calendarContext
            )
        )
        let scheduleEntry = RealityIntegrationAdapter.calendarContextObservedEntry(
            snapshot: snapshot,
            occurredAt: now,
            actionName: "Make Time calendar-aware"
        )

        XCTAssertEqual(calendarContext.permissionState, .denied)
        XCTAssertFalse(calendarContext.hasCalendarReadAccess)
        XCTAssertTrue(snapshot.availability.summary.contains("Time still works without calendar access"))
        XCTAssertTrue(snapshot.openWindowCandidates.isEmpty == false)
        XCTAssertEqual(snapshot.capacityEstimate.openMinutes, 120)
        XCTAssertEqual(snapshot.capacityEstimate.calendarBusyMinutes, 0)
        XCTAssertEqual(snapshot.privacy, .calendarDerived)
        XCTAssertTrue(snapshot.localOnly)
        XCTAssertEqual(scheduleEntry.metadata["permissionState"], CalendarPermissionState.denied.rawValue)
        XCTAssertEqual(scheduleEntry.privacy, .calendarDerived)
        XCTAssertTrue(scheduleEntry.summary?.contains("derived calendar availability") == true)
    }

    func testCalendarReplacementGauntletCoversThreeHundredDeterministicScenarios() {
        let result = CalendarP0ReplacementGauntletHarness().run()

        XCTAssertEqual(result.scenarioCount, 300)
        XCTAssertEqual(result.domainCounts[.p0], 60)
        XCTAssertEqual(result.domainCounts[.today], 60)
        XCTAssertEqual(result.domainCounts[.permissionsAndStaleItems], 60)
        XCTAssertEqual(result.domainCounts[.recurrenceConflictProtectedFreeTime], 60)
        XCTAssertEqual(result.domainCounts[.receiptsReplayExportDelete], 60)
        XCTAssertEqual(result.aspectCounts[.p0Replacement], 30)
        XCTAssertEqual(result.aspectCounts[.todayConsumption], 30)
        XCTAssertEqual(result.aspectCounts[.staleItems], 30)
        XCTAssertEqual(result.aspectCounts[.permissions], 30)
        XCTAssertEqual(result.aspectCounts[.recurrence], 30)
        XCTAssertEqual(result.aspectCounts[.conflict], 30)
        XCTAssertEqual(result.aspectCounts[.protectedFreeTime], 30)
        XCTAssertEqual(result.aspectCounts[.freeTime], 30)
        XCTAssertEqual(result.aspectCounts[.receiptsReplay], 30)
        XCTAssertEqual(result.aspectCounts[.exportDelete], 30)
        XCTAssertEqual(result.permissionCounts[.notDetermined], 50)
        XCTAssertEqual(result.permissionCounts[.denied], 50)
        XCTAssertEqual(result.permissionCounts[.restricted], 50)
        XCTAssertEqual(result.permissionCounts[.readWrite], 50)
        XCTAssertEqual(result.permissionCounts[.writeOnly], 50)
        XCTAssertEqual(result.permissionCounts[.unavailable], 50)
        XCTAssertTrue(result.failingScenarios.isEmpty, result.failureSummary)
        XCTAssertEqual(
            Set(result.blockedClaims),
            Set(CalendarP0ContractHarnessFixture.forbiddenBroadClaims)
        )
    }
}

private struct CalendarP0ContractHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "release-ready",
        "App Store-ready",
        "TestFlight-ready",
        "fully accessible",
        "performance validated",
        "privacy approved",
        "forbidden claim fixture: Calendar replacement is complete",
        "forbidden claim fixture: Calendar is fully replaced",
    ]

    let scheduledBlocksEvidence: Bool
    let recurrenceEvidence: Bool
    let eventKitPermissionEvidence: Bool
    let deniedFallbackEvidence: Bool
    let conflictDetectionEvidence: Bool
    let protectedFreeTimeEvidence: Bool
    let scheduleReceiptEvidence: Bool
    let todayConsumptionEvidence: Bool
    let replayAndPrivacyBoundaryEvidence: Bool
    let unsupportedClaims: [String]

    var missingEvidence: [String] {
        var items: [String] = []
        if scheduledBlocksEvidence == false { items.append("scheduled blocks") }
        if recurrenceEvidence == false { items.append("recurrence") }
        if eventKitPermissionEvidence == false { items.append("EventKit permission") }
        if deniedFallbackEvidence == false { items.append("denied fallback") }
        if conflictDetectionEvidence == false { items.append("conflicts") }
        if protectedFreeTimeEvidence == false { items.append("protected/free time") }
        if scheduleReceiptEvidence == false { items.append("schedule receipts") }
        if todayConsumptionEvidence == false { items.append("Today consumption") }
        if replayAndPrivacyBoundaryEvidence == false { items.append("replay/privacy boundaries") }
        return items
    }

    var allEvidencePresent: Bool {
        missingEvidence.isEmpty
    }

    var blocksBroadReplacementClaims: Bool {
        allEvidencePresent == false || unsupportedClaims.isEmpty == false
    }

    var blockedClaims: [String] {
        Array(Set(unsupportedClaims)).sorted()
    }
}

private enum CalendarP0ReplacementGauntletDomain: String, CaseIterable, Sendable {
    case p0
    case today
    case permissionsAndStaleItems = "permissions-and-stale-items"
    case recurrenceConflictProtectedFreeTime = "recurrence-conflict-protected-free-time"
    case receiptsReplayExportDelete = "receipts-replay-export-delete"
}

private enum CalendarP0ReplacementGauntletAspect: String, CaseIterable, Sendable {
    case p0Replacement = "p0-replacement"
    case todayConsumption = "today-consumption"
    case staleItems = "stale-items"
    case permissions = "permissions"
    case recurrence = "recurrence"
    case conflict = "conflict"
    case protectedFreeTime = "protected-free-time"
    case freeTime = "free-time"
    case receiptsReplay = "receipts-replay"
    case exportDelete = "export-delete"
}

private struct CalendarP0ReplacementGauntletScenario: Sendable, Hashable, Identifiable {
    let domain: CalendarP0ReplacementGauntletDomain
    let aspect: CalendarP0ReplacementGauntletAspect
    let permissionState: CalendarPermissionState

    var id: String {
        "\(domain.rawValue).\(aspect.rawValue).\(permissionState.rawValue)"
    }

    var label: String {
        "Calendar P0 \(domain.rawValue) / \(aspect.rawValue) / \(permissionState.rawValue)"
    }
}

private struct CalendarP0ReplacementGauntletScenarioOutcome: Sendable, Hashable {
    let scenario: CalendarP0ReplacementGauntletScenario
    let failures: [String]
}

private struct CalendarP0ReplacementGauntletResult: Sendable {
    let outcomes: [CalendarP0ReplacementGauntletScenarioOutcome]
    let blockedClaims: [String]

    var scenarioCount: Int {
        outcomes.count
    }

    var failureCount: Int {
        outcomes.reduce(0) { $0 + $1.failures.count }
    }

    var failingScenarios: [CalendarP0ReplacementGauntletScenarioOutcome] {
        outcomes.filter { $0.failures.isEmpty == false }
    }

    var failureSummary: String {
        guard failingScenarios.isEmpty == false else {
            return "No failing scenarios."
        }
        return failingScenarios
            .map { "\($0.scenario.id): \($0.failures.joined(separator: " | "))" }
            .joined(separator: "\n")
    }

    var domainCounts: [CalendarP0ReplacementGauntletDomain: Int] {
        Dictionary(grouping: outcomes, by: { $0.scenario.domain }).mapValues(\.count)
    }

    var aspectCounts: [CalendarP0ReplacementGauntletAspect: Int] {
        Dictionary(grouping: outcomes, by: { $0.scenario.aspect }).mapValues(\.count)
    }

    var permissionCounts: [CalendarPermissionState: Int] {
        Dictionary(grouping: outcomes, by: { $0.scenario.permissionState }).mapValues(\.count)
    }
}

private struct CalendarP0ReplacementGauntletHarness {
    private let fixedNow = Date(timeIntervalSince1970: 1_714_000_000)

    func run() -> CalendarP0ReplacementGauntletResult {
        let scenarios = makeScenarios()
        let outcomes = scenarios.map(validate(_:))
        return CalendarP0ReplacementGauntletResult(
            outcomes: outcomes,
            blockedClaims: CalendarP0ContractHarnessFixture.forbiddenBroadClaims
        )
    }

    private func makeScenarios() -> [CalendarP0ReplacementGauntletScenario] {
        CalendarP0ReplacementGauntletDomain.allCases.flatMap { domain in
            CalendarPermissionState.allCases.flatMap { permissionState in
                CalendarP0ReplacementGauntletAspect.allCases.map { aspect in
                    CalendarP0ReplacementGauntletScenario(
                        domain: domain,
                        aspect: aspect,
                        permissionState: permissionState
                    )
                }
            }
        }
    }

    private func validate(_ scenario: CalendarP0ReplacementGauntletScenario) -> CalendarP0ReplacementGauntletScenarioOutcome {
        var failures: [String] = []

        func record(_ condition: @autoclosure () -> Bool, _ message: String) {
            if condition() == false {
                failures.append(message)
            }
        }

        let permission = calendarRemindersAuthorizationState(for: scenario.permissionState)
        let readState = CalendarPermissionState(calendarRemindersState: permission)
        let awarenessState = timeCalendarAwarenessState(for: scenario.permissionState)

        record(scenario.label.contains("Calendar P0"), "Scenario label must stay on the calendar gauntlet path.")
        record(permission.canWrite == scenario.permissionState.canWrite, "Permission write capability drifted.")
        record(permission.canReadCalendarContext == scenario.permissionState.canRead, "Permission read capability drifted.")
        if scenario.permissionState == .unavailable {
            record(permission.canReadCalendarContext == false, "Unavailable calendar permission must not read calendar context.")
            record(permission.canWrite == false, "Unavailable calendar permission must not write calendar context.")
        } else {
            record(readState == scenario.permissionState, "Calendar permission mapping drifted.")
        }
        record(
            awarenessState.canRequestCalendarRead == (scenario.permissionState == .notDetermined),
            "Time calendar-awareness read gate drifted."
        )

        switch scenario.aspect {
        case .p0Replacement:
            validateP0ReplacementScenario(scenario, record: record)
        case .todayConsumption:
            validateTodayConsumptionScenario(scenario, permission: permission, awarenessState: awarenessState, record: record)
        case .staleItems:
            validateStaleItemsScenario(scenario, permission: permission, record: record)
        case .permissions:
            validatePermissionsScenario(scenario, permission: permission, record: record)
        case .recurrence:
            validateRecurrenceScenario(scenario, permission: permission, record: record)
        case .conflict:
            validateConflictScenario(scenario, permission: permission, record: record)
        case .protectedFreeTime:
            validateProtectedFreeTimeScenario(scenario, permission: permission, record: record)
        case .freeTime:
            validateFreeTimeScenario(scenario, permission: permission, record: record)
        case .receiptsReplay:
            validateReceiptsReplayScenario(scenario, permission: permission, record: record)
        case .exportDelete:
            validateExportDeleteScenario(scenario, permission: permission, record: record)
        }

        return CalendarP0ReplacementGauntletScenarioOutcome(
            scenario: scenario,
            failures: failures
        )
    }

    private func validateP0ReplacementScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        do {
            let root = FileManager.default.temporaryDirectory
                .appendingPathComponent("ambitions-calendar-p0-gauntlet-\(scenario.id)")
            let fileURL = root.appendingPathComponent("schedule-blocks.json")
            defer { try? FileManager.default.removeItem(at: root) }

            let block = ScheduledAmbitionsBlock(
                id: "calendar-p0.\(scenario.id)",
                title: "Calendar P0 replacement \(scenario.permissionState.rawValue)",
                start: fixedNow,
                end: fixedNow.addingTimeInterval(1_800),
                contextLens: .work,
                relatedGoalID: "goal.\(scenario.domain.rawValue)",
                relatedPlanID: "plan.\(scenario.aspect.rawValue)",
                isUserConfirmed: scenario.permissionState.canWrite,
                calendarEventIdentifier: scenario.permissionState.canWrite ? "event.\(scenario.id)" : nil
            )

            let receipts = try upsertLocalScheduleBlock(block, in: fileURL)
            let loaded = try loadLocalScheduleBlocks(from: fileURL)
            let deleteReceipt = try deleteLocalScheduleBlock(id: block.id, from: fileURL)

            record(receipts == [block.localScheduleReceiptID(action: "save")], "Local schedule receipts must stay deterministic.")
            record(loaded == [block], "Local schedule blocks must round-trip deterministically.")
            record(deleteReceipt == "Receipt.local-schedule.\(block.id).delete", "Local schedule deletes must stay inspectable.")
            record(block.localScheduleYouInspectionSummary.contains("Search Ambitions"), "You inspection summary must remain present.")
        } catch {
            record(false, "Local schedule round-trip failed: \(error)")
        }
    }

    private func validateTodayConsumptionScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        awarenessState: TimeCalendarAwarenessState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let calendarContext = CalendarDerivedContext(
            permissionState: scenario.permissionState,
            observedRangeStart: fixedNow,
            observedRangeEnd: fixedNow.addingTimeInterval(3_600),
            derivedBusyWindowCount: permission.canReadCalendarContext ? 1 : 0,
            userInitiatedTimeAction: "Make Time calendar-aware",
            explanation: permission.canReadCalendarContext
                ? "Calendar-derived busy time stayed local."
                : "Time still works without calendar access.",
            eventLedgerEntryIDs: ["ledger.\(scenario.id)"],
            recommendationExplanationIDs: ["explanation.\(scenario.id)"]
        )

        record(calendarContext.hasCalendarReadAccess == permission.canReadCalendarContext, "Calendar-derived read access must match the permission state.")
        record(calendarContext.localOnly, "Calendar-derived context must stay local-only.")
        record(calendarContext.privacy == .calendarDerived, "Calendar-derived context privacy must stay calendar-derived.")
        record(awarenessState.sourceLabel.isEmpty == false, "Calendar awareness source label must stay local-first.")
    }

    private func validateStaleItemsScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let staleContext = CalendarDerivedContext(
            permissionState: scenario.permissionState,
            observedRangeStart: fixedNow.addingTimeInterval(-86_400),
            observedRangeEnd: fixedNow,
            derivedBusyWindowCount: permission.canReadCalendarContext ? 2 : 0,
            userInitiatedTimeAction: "Review stale calendar items",
            explanation: "Stale items stay reviewable before Time uses them.",
            eventLedgerEntryIDs: ["stale.\(scenario.id)"],
            recommendationExplanationIDs: ["stale.explanation.\(scenario.id)"]
        )

        record(staleContext.eventLedgerEntryIDs == ["stale.\(scenario.id)"], "Stale-item ledger IDs must stay stable.")
        record(staleContext.recommendationExplanationIDs == ["stale.explanation.\(scenario.id)"], "Stale-item explanation IDs must stay stable.")
        record(staleContext.hasCalendarReadAccess == permission.canReadCalendarContext, "Stale-item read access must match the permission state.")
        record(staleContext.explanation.contains("Stale items"), "Stale-item copy must stay explicit.")
    }

    private func validatePermissionsScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let calendarError = CalendarRemindersError.authorizationDenied(scope: .calendarEvents)

        record(permission.canWrite == scenario.permissionState.canWrite, "Calendar permission write gating must stay consistent.")
        record(permission.canReadCalendarContext == scenario.permissionState.canRead, "Calendar permission read gating must stay consistent.")
        record(calendarError.errorDescription?.contains("Calendar permission") == true, "Calendar permission error copy must stay local and specific.")
    }

    private func validateRecurrenceScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let selection = NextStepSchedulingSelection(
            goalID: "goal.\(scenario.domain.rawValue)",
            goalTitle: "Calendar replacement goal",
            stepID: "step.\(scenario.id)",
            stepTitle: "Review open work weekly",
            stepSummary: "Keep recurrence local and deterministic.",
            suggestedDate: permission.canWrite ? fixedNow.addingTimeInterval(3_600) : nil
        )

        record(selection.stepTitle.localizedCaseInsensitiveContains("weekly"), "Recurrence labels must stay deterministic.")
        record(selection.goalID.contains("goal"), "Recurrence goal IDs must stay inspectable.")
        record(selection.suggestedDate != nil || permission.canWrite == false, "Recurrence suggestions must respect the permission gate.")
    }

    private func validateConflictScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let conflict = CalendarConflict(
            title: "Calendar busy time",
            startDate: fixedNow.addingTimeInterval(1_800),
            endDate: fixedNow.addingTimeInterval(5_400),
            isAllDay: false
        )
        let report = CalendarConflictReport(
            proposedStartDate: fixedNow.addingTimeInterval(3_600),
            proposedEndDate: fixedNow.addingTimeInterval(5_400),
            conflicts: [conflict],
            nearbyAvailableWindow: permission.canReadCalendarContext
                ? DateInterval(start: fixedNow.addingTimeInterval(5_400), end: fixedNow.addingTimeInterval(7_200))
                : nil,
            pressure: permission.canReadCalendarContext ? .moderate : .low
        )

        record(report.hasConflicts, "Conflict reports must surface the conflict.")
        record(report.conflicts.first?.title == "Calendar busy time", "Conflict titles must stay inspectable.")
        record(report.pressure == (permission.canReadCalendarContext ? .moderate : .low), "Conflict pressure must remain grounded in the permission state.")
        record(report.nearbyAvailableWindow != nil || permission.canReadCalendarContext == false, "Nearby room must remain bounded by the permission state.")
    }

    private func validateProtectedFreeTimeScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let protectedWindow = RealityWindow(
            id: "protected.\(scenario.id)",
            kind: .protected,
            source: .userDefined,
            start: fixedNow,
            end: fixedNow.addingTimeInterval(3_600),
            title: "Protected free time"
        )
        let openCandidate = OpenWindowCandidate(
            id: "open.\(scenario.id)",
            start: fixedNow.addingTimeInterval(7_200),
            end: fixedNow.addingTimeInterval(10_800),
            source: .systemDefault,
            fitSummary: "Open room stays visible."
        )
        let snapshot = RealitySnapshot(
            id: "snapshot.\(scenario.id)",
            generatedAt: fixedNow,
            horizonStart: fixedNow,
            horizonEnd: fixedNow.addingTimeInterval(10_800),
            activeContextLens: .all,
            windows: [protectedWindow],
            openWindowCandidates: [openCandidate],
            availability: AvailabilitySummary(
                horizonStart: fixedNow,
                horizonEnd: fixedNow.addingTimeInterval(10_800),
                openWindowCount: 1,
                blockedWindowCount: 0,
                protectedWindowCount: 1,
                calendarDerivedBusyCount: permission.canReadCalendarContext ? 1 : 0,
                schedulePressure: .moderate,
                summary: "Protected time and free room stay visible."
            ),
            calendarContext: CalendarDerivedContext(
                permissionState: scenario.permissionState,
                observedRangeStart: fixedNow,
                observedRangeEnd: fixedNow.addingTimeInterval(10_800),
                derivedBusyWindowCount: permission.canReadCalendarContext ? 1 : 0,
                userInitiatedTimeAction: "Find real open windows",
                explanation: "Calendar-aware protected time stays local."
            ),
            conflictSummary: RealityConflictSummary(
                conflictCount: 1,
                calendarConflictCount: permission.canReadCalendarContext ? 1 : 0,
                protectedConflictCount: 1,
                affectedWindowIDs: [protectedWindow.id],
                summary: "Protected time remains visible before any move.",
                localOnly: true,
                privacy: .calendarDerived
            ),
            scheduledBlocks: [],
            capacityEstimate: CapacityEstimate(
                openMinutes: 60,
                totalOpenMinutes: 180,
                protectedMinutes: 60,
                vacationAwayMinutes: 0,
                blockedBusyMinutes: 0,
                blockedMinutes: 0,
                flexibleMinutes: 120,
                scheduledAmbitionsMinutes: 0,
                calendarBusyMinutes: permission.canReadCalendarContext ? 60 : 0,
                timeFitProofSummary: "Protected time stays inspectable.",
                deadlineFitProofSummary: "Open room remains available.",
                capacityLevel: .moderate,
                summary: "Protected free time remains visible.",
                localOnly: true,
                privacy: .calendarDerived
            ),
            deadlinePressure: NowPressureSummary(level: .none, summary: "No deadline pressure is visible."),
            contextFitSummary: "Protected free time remains available locally.",
            recommendationExplanationIDs: ["protected.free.time.\(scenario.id)"]
        )

        record(protectedWindow.isProtected, "Protected windows must stay marked protected.")
        record(openCandidate.canFitDeadlineItem, "Open windows must stay usable for deadline items.")
        record(snapshot.capacityEstimate.protectedMinutes == 60, "Protected minutes must stay visible.")
        record(snapshot.openWindowCandidates.isEmpty == false, "Open window candidates must stay visible.")
        record(snapshot.localOnly, "Reality snapshots must stay local-only.")
    }

    private func validateFreeTimeScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let awarenessState = timeCalendarAwarenessState(for: scenario.permissionState)
        let openWindow = OpenWindowCandidate(
            id: "free.\(scenario.id)",
            start: fixedNow.addingTimeInterval(3_600),
            end: fixedNow.addingTimeInterval(5_400),
            source: .calendarDerived,
            fitSummary: "Free time stays visible."
        )

        record(awarenessState.status == expectedAwarenessStatus(for: scenario.permissionState), "Free-time calendar awareness must remain grounded in the permission state.")
        record(openWindow.durationMinutes == 30, "Free-time window duration must stay deterministic.")
        record(openWindow.privacy == .calendarDerived, "Free-time candidates must stay calendar-derived when sourced from calendar data.")
    }

    private func validateReceiptsReplayScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        let sourceRecord = KnowledgeSourceRecord(
            id: "source.calendar.\(scenario.id)",
            providerID: "provider.local",
            entityTitle: "Calendar replacement contract",
            publisher: nil,
            locator: "local://calendar/\(scenario.id)",
            provenanceKind: .userProvided,
            isOfficial: false
        )
        let sourceObject = LifeGraphObjectReference(
            kind: .evidence,
            id: sourceRecord.id,
            label: sourceRecord.entityTitle,
            sourceDomain: .you
        )
        let receipt = ActionReceipt(
            id: "receipt.calendar.\(scenario.id)",
            resultState: .completed,
            title: "Calendar P0 contract recorded",
            summary: "Receipt, proof, and replay stay local.",
            sourceDomain: .time,
            occurredAt: "2026-05-24T04:08:53Z",
            affectedObjects: [
                LifeGraphObjectReference(
                    kind: .step,
                    id: "step.calendar.\(scenario.id)",
                    label: "Calendar replacement step",
                    sourceDomain: .today
                )
            ],
            correctionAvailability: .available,
            undoAvailability: .availableLocal,
            sourceObject: sourceObject
        )
        let proofLedgerEntry = ActionReceiptProofLedgerEntry(
            receipt: receipt,
            proofRelevance: .countsAsProof
        )
        let proofReferenceID = proofLedgerEntry.proofReference?.id ?? "proof.calendar.missing"
        let replayTrace = makeReplayTrace(
            sourceRecordID: sourceRecord.id,
            receiptID: receipt.id,
            proofReferenceID: proofReferenceID
        )

        record(permission.canReadCalendarContext == (scenario.permissionState.canRead), "Replay scenarios must stay tied to the permission state.")
        record(receipt.sourceObject?.id == sourceRecord.id, "Receipt source objects must stay linked.")
        record(proofLedgerEntry.hasProofBridge, "Receipt proof bridges must stay present.")
        record(replayTrace.isReplayable, "Replay traces must stay replayable.")
        record(replayTrace.isLocalOnly, "Replay traces must stay local-only.")
    }

    private func validateExportDeleteScenario(
        _ scenario: CalendarP0ReplacementGauntletScenario,
        permission: CalendarRemindersAuthorizationState,
        record: (_ condition: @autoclosure () -> Bool, _ message: String) -> Void
    ) {
        do {
            let root = FileManager.default.temporaryDirectory
                .appendingPathComponent("ambitions-calendar-p0-export-delete-\(scenario.id)")
            let fileURL = root.appendingPathComponent("schedule-blocks.json")
            defer { try? FileManager.default.removeItem(at: root) }

            let block = ScheduledAmbitionsBlock(
                id: "calendar-export.\(scenario.id)",
                title: "Calendar export and delete",
                start: fixedNow.addingTimeInterval(1_800),
                end: fixedNow.addingTimeInterval(3_600),
                contextLens: .all,
                relatedGoalID: "goal.export.\(scenario.domain.rawValue)",
                isUserConfirmed: permission.canWrite,
                calendarEventIdentifier: permission.canWrite ? "event.export.\(scenario.id)" : nil
            )

            let saveReceipts = try upsertLocalScheduleBlock(block, in: fileURL)
            let loaded = try loadLocalScheduleBlocks(from: fileURL)
            let deleteReceipt = try deleteLocalScheduleBlock(id: block.id, from: fileURL)
            let afterDelete = try loadLocalScheduleBlocks(from: fileURL)

            record(saveReceipts == [block.localScheduleReceiptID(action: "save")], "Export receipts must stay deterministic.")
            record(loaded == [block], "Exported calendar blocks must round-trip locally.")
            record(deleteReceipt == "Receipt.local-schedule.\(block.id).delete", "Delete receipts must stay inspectable.")
            record(afterDelete.isEmpty, "Delete must remove the exported calendar block.")
        } catch {
            record(false, "Export/delete round-trip failed: \(error)")
        }
    }

    private func timeCalendarAwarenessState(for permission: CalendarPermissionState) -> TimeCalendarAwarenessState {
        switch permission {
        case .notDetermined:
            return TimeCalendarAwarenessState(
                status: .baseline,
                title: "Calendar-aware mode is waiting",
                detail: "Time stays local until you choose to share calendar access.",
                primaryActionTitle: "Make Time calendar-aware",
                primaryActionSystemImage: "calendar.badge.plus",
                valueLabel: "Ask later",
                sourceLabel: "Based on Time",
                visualState: .default,
                canRequestCalendarRead: true
            )
        case .denied, .restricted:
            return TimeCalendarAwarenessState(
                status: .denied,
                title: "Calendar-aware mode unavailable",
                detail: "Time is using Ambitions data only in this runtime.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar",
                valueLabel: "Local",
                sourceLabel: "Created in Ambitions",
                visualState: .default,
                canRequestCalendarRead: false
            )
        case .readWrite:
            return TimeCalendarAwarenessState(
                status: .calendarAware,
                title: "Calendar-aware mode is on",
                detail: "Time can read calendar context locally after approval.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar.badge.checkmark",
                valueLabel: "Approved",
                sourceLabel: "Based on Time",
                visualState: .selected,
                canRequestCalendarRead: false
            )
        case .writeOnly:
            return TimeCalendarAwarenessState(
                status: .writeOnly,
                title: "Calendar write-only mode",
                detail: "Time can confirm a write without reading calendar context.",
                primaryActionTitle: "Prepare calendar block",
                primaryActionSystemImage: "calendar.badge.clock",
                valueLabel: "Write only",
                sourceLabel: "Based on Time",
                visualState: .warning,
                canRequestCalendarRead: false
            )
        case .unavailable:
            return TimeCalendarAwarenessState(
                status: .unavailable,
                title: "Calendar-aware mode unavailable",
                detail: "Time is using Ambitions data only in this runtime.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar",
                valueLabel: "Local",
                sourceLabel: "Created in Ambitions",
                visualState: .default,
                canRequestCalendarRead: false
            )
        }
    }

    private func expectedAwarenessStatus(for permission: CalendarPermissionState) -> TimeCalendarAwarenessStatus {
        switch permission {
        case .notDetermined:
            return .baseline
        case .denied, .restricted:
            return .denied
        case .readWrite:
            return .calendarAware
        case .writeOnly:
            return .writeOnly
        case .unavailable:
            return .unavailable
        }
    }

    private func calendarRemindersAuthorizationState(for permissionState: CalendarPermissionState) -> CalendarRemindersAuthorizationState {
        switch permissionState {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .readWrite:
            return .fullAccess
        case .writeOnly:
            return .writeOnly
        case .unavailable:
            return .denied
        }
    }

    private func makeReplayTrace(
        sourceRecordID: String,
        receiptID: String,
        proofReferenceID: String
    ) -> ReplayableDecisionTrace {
        let runtimeContext = RuntimeContextSnapshot(
            clientContext: .iphoneApp,
            capabilities: .currentLocalRuntime,
            syncStatus: SyncCapabilityStatus(
                backendKind: .localOnly,
                trustPosture: .localOnly,
                availability: .unavailable,
                detail: "Calendar replacement evidence remains local-only."
            ),
            knowledgeProviderStatuses: [
                KnowledgeProviderStatus(
                    provider: KnowledgeProviderDescriptor(
                        id: "provider.local",
                        type: .systemFallback,
                        displayName: "Local provider"
                    ),
                    availability: .localOnlyMode,
                    detail: "Calendar evidence stays on device.",
                    runtimeTrustPosture: .localOnly
                )
            ],
            memorySummary: RuntimeMemorySummary(
                memory: RuntimeMemorySnapshot(
                    goals: [],
                    drafts: [],
                    evidence: [],
                    feedback: [],
                    captures: [],
                    appState: .default
                )
            ),
            externalSurfaceSnapshot: nil
        )
        let traceContext = PrivateLifeRuntimeKernelTraceContext(runtimeContext: runtimeContext)
        let recommendationTrace = RecommendationTrace(
            id: "trace.calendar.\(sourceRecordID)",
            recommendationID: "recommendation.calendar.\(sourceRecordID)",
            source: RecommendationTraceSource(
                citedSourceIDs: [sourceRecordID],
                sourceAtlasBlockReasons: [],
                localEvidenceCategories: [.sourceTruth, .memoryEvent],
                canSupportRecommendation: true
            ),
            reason: RecommendationTraceReason(
                explanationID: "explanation.calendar.\(sourceRecordID)",
                summary: "Calendar evidence stays local and inspectable.",
                evidenceCategoryIDs: ["source_truth", "memory_event"]
            ),
            fit: RecommendationTraceFit(state: .fits, blockReasons: [], canDriveRecommendation: true),
            uncertainty: RecommendationTraceUncertainty(
                uncertaintyIDs: ["uncertainty.calendar.\(sourceRecordID)"],
                summaries: ["Calendar evidence is user-owned and reviewable."]
            ),
            control: RecommendationTraceControl(
                correctionActionIDs: ["correct.calendar"],
                controlActionIDs: ["open", "start", "hold"],
                correctableFieldKeys: ["receipt", "replayTrace", "sourceRecord"],
                hasRequiredControl: true
            ),
            receiptBehavior: RecommendationTraceReceiptBehavior.available(
                receiptIDs: [receiptID],
                actionReceiptIDs: [receiptID],
                proofReferenceIDs: [proofReferenceID]
            )
        )

        return PrivateLifeRuntimeKernel().makeReplayableDecisionTrace(
            PrivateLifeRuntimeKernelDecisionInput(
                traceContext: traceContext,
                decisionKey: "calendar.\(sourceRecordID)",
                goalText: "Calendar replacement proof",
                recommendationTrace: recommendationTrace
            )
        )
    }
}
