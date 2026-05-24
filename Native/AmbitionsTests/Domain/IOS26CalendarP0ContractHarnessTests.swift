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
            userInitiatedPlanAction: "Find real open windows",
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
        XCTAssertEqual(contextEntry.source, .plan)
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
        XCTAssertTrue(block.localScheduleYouInspectionSummary.contains("What Ambitions knows"))
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
            userInitiatedPlanAction: "Make Time calendar-aware",
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
}

private struct CalendarP0ContractHarnessFixture: Sendable, Equatable {
    static let forbiddenBroadClaims = [
        "release-ready",
        "App Store-ready",
        "TestFlight-ready",
        "fully accessible",
        "performance validated",
        "privacy approved",
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
