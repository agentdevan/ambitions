@testable import Ambitions
import Foundation
import XCTest

final class BufferEngineTests: XCTestCase {
    func testAMB1172RuntimeSnapshotStoresHiddenRoomAvailableBufferReading() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))
        let nowState = CanonicalNowState.empty(generatedAt: DomainTimestamp.string(from: now))
        let runtime = PrivateLifeRuntime(
            projectionPipeline: RuntimeProjectionPipeline(projector: StaticBufferNowStateProjector(nowState: nowState))
        )

        let snapshot = runtime.snapshot(input: NowStateProjectionInput(now: now))

        XCTAssertEqual(snapshot.bufferReading.kind, .roomAvailable)
        XCTAssertEqual(snapshot.bufferReading.summary, "Room available")
        XCTAssertEqual(snapshot.bufferReading.ordinal, 0)
        XCTAssertTrue(snapshot.bufferReading.hiddenFromRootUI)
        XCTAssertEqual(snapshot.bufferReading.semanticSummary, "Room available: schedule has room around the next block.")
        XCTAssertEqual(snapshot.bufferReading.accessibilitySummary, "Buffer room is available around the next block.")
    }

    func testAMB1172BufferEngineProducesDeterministicRuleSnapshotsForLateDenseFrozenState() {
        let nowState = denseLateNowState()
        let capacity = denseCapacity()

        let reading = BufferEngine().reading(nowState: nowState, capacityShape: capacity)

        XCTAssertEqual(reading.kind, .needsBuffer)
        XCTAssertGreaterThanOrEqual(reading.ordinal, 5)
        XCTAssertEqual(reading.summary, "Needs buffer after 5:00 PM.")
        XCTAssertTrue(reading.hiddenFromRootUI)
        XCTAssertEqual(
            Set(reading.ruleSnapshots.map(\.kind)),
            Set([
                .blockedOrMovedSteps,
                .fixedPointDensity,
                .lateDayCompression,
                .planningDefaultBuffer,
                .recentClosurePattern
            ])
        )
        XCTAssertTrue(reading.ruleSnapshots.contains { $0.kind == .lateDayCompression && $0.contribution == 2 })
        XCTAssertTrue(reading.ruleSnapshots.contains { $0.kind == .fixedPointDensity && $0.evidenceReferenceIDs == ["fixed-proof-1"] })
        XCTAssertTrue(reading.ruleSnapshots.contains { $0.kind == .blockedOrMovedSteps && $0.evidenceReferenceIDs.contains("step-blocked") })
    }

    func testAMB1172BufferCorrectionCreatesInspectableFutureRoomProof() {
        let engine = BufferEngine()
        let base = engine.reading(nowState: denseLateNowState(), capacityShape: denseCapacity())
        let addedRoom = engine.reading(
            nowState: denseLateNowState(),
            capacityShape: denseCapacity(),
            corrections: [
                BufferCorrection(
                    id: "buffer-correction-room",
                    kind: .addedFutureRoom,
                    createdAt: "2026-04-25T18:00:00Z",
                    evidenceReferenceID: "buffer-proof-room"
                )
            ]
        )
        let needsRoom = engine.reading(
            nowState: roomAvailableNowState(),
            capacityShape: roomAvailableCapacity(),
            corrections: [
                BufferCorrection(
                    id: "buffer-correction-need",
                    kind: .needsMoreRoom,
                    createdAt: "2026-04-25T12:00:00Z",
                    evidenceReferenceID: "buffer-proof-need"
                )
            ]
        )

        XCTAssertEqual(base.kind, .needsBuffer)
        XCTAssertLessThan(addedRoom.ordinal, base.ordinal)
        XCTAssertTrue(addedRoom.ruleSnapshots.contains { $0.kind == .manualCorrection && $0.contribution == -2 && $0.evidenceReferenceIDs == ["buffer-proof-room"] })
        XCTAssertEqual(needsRoom.kind, .keepLight)
        XCTAssertEqual(needsRoom.summary, "Keep this block light.")
        XCTAssertTrue(needsRoom.ruleSnapshots.contains { $0.kind == .manualCorrection && $0.evidenceReferenceIDs == ["buffer-proof-need"] })
    }

    func testAMB1172BufferCopyAvoidsWellnessAssessmentAndScores() {
        let readings = [
            BufferEngine().reading(nowState: roomAvailableNowState(), capacityShape: roomAvailableCapacity()),
            BufferEngine().reading(nowState: lightNowState(), capacityShape: lightCapacity()),
            BufferEngine().reading(nowState: addRoomNowState(), capacityShape: addRoomCapacity()),
            BufferEngine().reading(nowState: denseLateNowState(), capacityShape: denseCapacity())
        ]
        let combined = readings.flatMap { [$0.summary, $0.semanticSummary, $0.accessibilitySummary] }.joined(separator: " ")
        let forbidden = [
            "%",
            "diagnosis",
            "depleted",
            "low-energy",
            "low energy",
            "burned out",
            "wellness",
            "bad fit",
            "failure likely",
            "poor productivity"
        ]

        for phrase in forbidden {
            XCTAssertFalse(combined.localizedCaseInsensitiveContains(phrase), phrase)
        }
        XCTAssertTrue(combined.contains("Needs buffer after 5:00 PM."))
        XCTAssertTrue(combined.contains("Keep this block light."))
        XCTAssertTrue(combined.contains("Add room after this fixed point."))
    }

    func testAMB1172BufferReadingStaysHiddenFromRootTimeUI() throws {
        let root = repoRoot()
        let selector = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeLayerSelector.swift", root: root)
        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let pressurePresentation = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView+PressurePresentation.swift", root: root)
        let timeSurface = try source("Native/Ambitions/Surfaces/Time/TimeSurface.swift", root: root)
        let scannedRoot = [selector, rootView, pressurePresentation, timeSurface].joined(separator: "\n")

        XCTAssertTrue(selector.contains("[.open, .protected, .pressure]"))
        XCTAssertFalse(selector.contains(".buffer"))
        XCTAssertFalse(scannedRoot.contains("BufferReading"))
        XCTAssertFalse(scannedRoot.localizedCaseInsensitiveContains("Needs buffer after 5:00 PM."))
    }

    private func roomAvailableNowState() -> CanonicalNowState {
        CanonicalNowState.empty(generatedAt: "2026-04-25T12:00:00Z")
    }

    private func lightNowState() -> CanonicalNowState {
        CanonicalNowState(
            id: "now.buffer.light",
            generatedAt: "2026-04-25T13:00:00Z",
            activeContextLens: .all,
            lensSource: .systemDefault,
            todayPosture: .steady,
            schedulePressure: NowPressureSummary(level: .moderate, itemCount: 3, summary: "Local fixed points are visible."),
            priorityPressure: NowPriorityRealitySummary(overallPressure: .low, summary: "Goal load is light."),
            deadlinePressure: NowPressureSummary(level: .low, summary: "Dated Steps are steady."),
            captureUrgency: NowPressureSummary(level: .none, summary: "No captures need review."),
            blockersWaiting: NowBlockersWaitingSummary(summary: "No blockers or waiting items are visible."),
            recoveryState: .stable,
            urgentOutsideLens: NowUrgentOutsideLensSummary(level: .none, summary: "No outside-lens items are visible.")
        )
    }

    private func addRoomNowState() -> CanonicalNowState {
        CanonicalNowState(
            id: "now.buffer.add-room",
            generatedAt: "2026-04-25T18:00:00Z",
            activeContextLens: .all,
            lensSource: .systemDefault,
            todayPosture: .tight,
            schedulePressure: NowPressureSummary(level: .moderate, itemCount: 3, summary: "Local fixed points are visible."),
            priorityPressure: NowPriorityRealitySummary(overallPressure: .moderate, summary: "Goal load is visible."),
            deadlinePressure: NowPressureSummary(level: .low, summary: "Dated Steps are steady."),
            captureUrgency: NowPressureSummary(level: .none, summary: "No captures need review."),
            blockersWaiting: NowBlockersWaitingSummary(summary: "No blockers or waiting items are visible."),
            recoveryState: .stable,
            urgentOutsideLens: NowUrgentOutsideLensSummary(level: .none, summary: "No outside-lens items are visible.")
        )
    }

    private func denseLateNowState() -> CanonicalNowState {
        CanonicalNowState(
            id: "now.buffer.dense-late",
            generatedAt: "2026-04-25T18:00:00Z",
            activeContextLens: .all,
            lensSource: .systemDefault,
            todayPosture: .tight,
            schedulePressure: NowPressureSummary(
                level: .high,
                itemCount: 6,
                summary: "Local fixed points are visible.",
                evidenceReferenceIDs: ["fixed-proof-1"]
            ),
            priorityPressure: NowPriorityRealitySummary(overallPressure: .elevated, summary: "Goal load is visible."),
            deadlinePressure: NowPressureSummary(level: .moderate, itemCount: 2, summary: "Dated Steps are close."),
            captureUrgency: NowPressureSummary(
                level: .moderate,
                itemCount: 2,
                summary: "Recent closures still need review.",
                evidenceReferenceIDs: ["closure-proof-1"]
            ),
            blockersWaiting: NowBlockersWaitingSummary(
                blockedCount: 2,
                waitingCount: 1,
                summary: "Blocked and moved Steps are visible.",
                references: [NowActionReference(goalID: "goal-buffer", stepID: "step-blocked")]
            ),
            recoveryState: .stable,
            urgentOutsideLens: NowUrgentOutsideLensSummary(level: .none, summary: "No outside-lens items are visible.")
        )
    }

    private func roomAvailableCapacity() -> CapacityShape {
        CapacityShape(
            openMinutes: 180,
            protectedMinutes: 0,
            blockedMinutes: 0,
            flexibleMinutes: 120,
            scheduledAmbitionsMinutes: 30,
            calendarBusyMinutes: 0,
            pressureLevel: .low,
            summary: "Schedule has room."
        )
    }

    private func lightCapacity() -> CapacityShape {
        CapacityShape(
            openMinutes: 120,
            protectedMinutes: 0,
            blockedMinutes: 0,
            flexibleMinutes: 60,
            scheduledAmbitionsMinutes: 60,
            calendarBusyMinutes: 0,
            pressureLevel: .moderate,
            summary: "Schedule can stay light."
        )
    }

    private func addRoomCapacity() -> CapacityShape {
        CapacityShape(
            openMinutes: 70,
            protectedMinutes: 0,
            blockedMinutes: 20,
            flexibleMinutes: 30,
            scheduledAmbitionsMinutes: 120,
            calendarBusyMinutes: 0,
            pressureLevel: .elevated,
            summary: "Schedule can use room."
        )
    }

    private func denseCapacity() -> CapacityShape {
        CapacityShape(
            openMinutes: 70,
            protectedMinutes: 30,
            blockedMinutes: 60,
            flexibleMinutes: 10,
            scheduledAmbitionsMinutes: 180,
            calendarBusyMinutes: 0,
            pressureLevel: .high,
            summary: "Schedule needs room."
        )
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/Runtime")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private struct StaticBufferNowStateProjector: NowStateProjecting {
    let nowState: CanonicalNowState

    func project(input: NowStateProjectionInput) -> CanonicalNowState {
        nowState
    }
}
