import Foundation
import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityResilienceTests: XCTestCase {
    private let content = TodayFlagshipCalibrationFixture.preparingForBaby

    func testOfflineLocalTruthKeepsExactStepAndClosurePathAvailable() {
        let offline = content.offlineLocalTruth

        XCTAssertEqual(offline.contextSeam?.condition, .offlineLocalTruth)
        XCTAssertEqual(offline.contextSeam?.affectedObjectID, offline.primaryStep.id)
        XCTAssertEqual(offline.primaryStep.currentAcceptedTruth, content.primaryStep.currentAcceptedTruth)

        var state = TodayFlagshipJourneyState(content: offline)
        XCTAssertTrue(state.openStartHere())
        XCTAssertTrue(state.selectStillCounts())
        XCTAssertTrue(state.beginCommit())
        XCTAssertTrue(state.settle())
        XCTAssertEqual(state.acceptedTruth, offline.primaryStep.stillCountsProposal.settledTruth)
    }

    func testStaleExternalContextStaysOnExternalObjectAndDoesNotWeakenLocalTruth() {
        let stale = content.staleExternalContext

        XCTAssertEqual(stale.contextSeam?.condition, .staleExternalContext)
        XCTAssertEqual(stale.contextSeam?.affectedObjectID, stale.revealedStartHereStep.id)
        XCTAssertEqual(stale.primaryStep.currentAcceptedTruth, content.primaryStep.currentAcceptedTruth)
        XCTAssertEqual(
            stale.timeline.first(where: {
                $0.canonicalObjectID == stale.revealedStartHereStep.id
            })?.role,
            .external
        )
    }

    func testConflictTransferKeepsTodayTruthAndTimelineUnchanged() {
        let conflict = content.conflictTransfer

        XCTAssertEqual(conflict.contextSeam?.condition, .conflictTransfer)
        XCTAssertEqual(conflict.contextSeam?.ownerTitle, "Time")
        XCTAssertEqual(conflict.primaryStep.currentAcceptedTruth, content.primaryStep.currentAcceptedTruth)
        XCTAssertEqual(conflict.timeline, content.timeline)
    }

    func testFailedSettlementAndCancellationRetainAcceptedTruth() {
        var failed = TodayFlagshipJourneyState.preview(content: content, phase: .savingAcceptedTruth)
        let acceptedTruth = failed.acceptedTruth
        XCTAssertTrue(failed.failCommit())
        XCTAssertEqual(failed.phase, .failedSettlement)
        XCTAssertEqual(failed.acceptedTruth, acceptedTruth)
        XCTAssertEqual(failed.proposedTruth, content.primaryStep.stillCountsProposal.proposedTruth)
        XCTAssertFalse(failed.hasCommittedMutation)

        var cancelled = TodayFlagshipJourneyState.preview(content: content, phase: .reviewingProposal)
        XCTAssertTrue(cancelled.cancelReview())
        XCTAssertEqual(cancelled.phase, .focusedCurrent)
        XCTAssertEqual(cancelled.acceptedTruth, acceptedTruth)
        XCTAssertNil(cancelled.proposedTruth)
        XCTAssertFalse(cancelled.hasCommittedMutation)
    }

    func testExactEligibleInverseReopensStableStepAndPreservesMutationLineage() {
        let eligible = content.undoAvailableEvaluation
        var state = TodayFlagshipJourneyState.preview(content: eligible, phase: .settled)

        XCTAssertTrue(state.openSupportingRoute(.undoReview))
        XCTAssertTrue(state.applyEligibleInverse())
        XCTAssertEqual(state.acceptedTruth, eligible.primaryStep.currentAcceptedTruth)
        XCTAssertNil(state.proposedTruth)
        XCTAssertEqual(state.phase, .focusedCurrent)
        XCTAssertEqual(state.navigationPath, [.step(id: eligible.primaryStep.id)])
        XCTAssertNil(state.supportingRoute)
        XCTAssertEqual(state.focusAnchor, .focusedIdentity)
        XCTAssertEqual(state.appliedInverseCommandID, eligible.supporting.inverse.commandID)
        XCTAssertTrue(state.hasCommittedMutation)
        XCTAssertTrue(eligible.supporting.inverse.preservesHistory)
    }

    func testInverseIsUnavailableWithoutEveryExactPrerequisite() {
        var defaultState = TodayFlagshipJourneyState.preview(content: content, phase: .settled)
        XCTAssertFalse(defaultState.openSupportingRoute(.undoReview))
        XCTAssertFalse(defaultState.applyEligibleInverse())
        XCTAssertNil(defaultState.appliedInverseCommandID)

        var eligibleButNotSettled = TodayFlagshipJourneyState(
            content: content.undoAvailableEvaluation
        )
        XCTAssertFalse(eligibleButNotSettled.openSupportingRoute(.undoReview))
        XCTAssertFalse(eligibleButNotSettled.applyEligibleInverse())
    }

    func testR13ResilienceSourceUsesNarrowSeamsAndNoSyntheticControls() throws {
        let source = try source(named: "TodayVitalityResilienceViews.swift")

        XCTAssertTrue(source.contains("struct TodayVitalityContextSeam"))
        XCTAssertTrue(source.contains("TodayVitalityNode"))
        XCTAssertTrue(source.contains("tfcs-context-seam-"))
        XCTAssertTrue(source.contains("struct TodayVitalityUndoReviewView"))
        XCTAssertTrue(source.contains("r13-undo-history-preserved"))
        XCTAssertFalse(source.contains("Review Changes"))
        XCTAssertFalse(source.contains("Open in Time"))
        XCTAssertFalse(source.contains("blockedConsequence"))
        XCTAssertFalse(source.contains("r13-blocked"))
    }

    func testCurrentFixtureExposesNoBlockedConsequenceStateOrControl() throws {
        let stateSource = try source(named: "TodayFlagshipJourneyState.swift")
        let previewSource = try source(named: "TodayFlagshipCalibrationPreviews.swift")

        XCTAssertFalse(stateSource.contains("blockedConsequence"))
        XCTAssertFalse(previewSource.contains("r13-resilience-blocked"))
        XCTAssertFalse(previewSource.contains("R13-D10"))
    }

    private func source(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
            .appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: url.path) else {
            XCTFail("Missing resilience source: \(filename)")
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
