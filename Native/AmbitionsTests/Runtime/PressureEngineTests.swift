@testable import Ambitions
import Foundation
import XCTest

final class PressureEngineTests: XCTestCase {
    func testAMB1170RuntimeSnapshotStoresHiddenLightPressureReading() throws {
        let now = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))
        let nowState = CanonicalNowState.empty(generatedAt: DomainTimestamp.string(from: now))
        let runtime = PrivateLifeRuntime(
            projectionPipeline: RuntimeProjectionPipeline(projector: StaticPressureNowStateProjector(nowState: nowState))
        )

        let snapshot = runtime.snapshot(input: NowStateProjectionInput(now: now))

        XCTAssertEqual(snapshot.pressureReading.kind, .light)
        XCTAssertEqual(snapshot.pressureReading.summary, "Light")
        XCTAssertEqual(snapshot.pressureReading.ordinal, 0)
        XCTAssertTrue(snapshot.pressureReading.hiddenFromRootUI)
        XCTAssertEqual(snapshot.pressureReading.semanticSummary, "Light: capacity has room.")
        XCTAssertEqual(snapshot.pressureReading.accessibilitySummary, "Pressure is light. Capacity has room.")
    }

    func testAMB1170PressureEngineProducesDeterministicRuleSnapshotsForDenseFrozenState() throws {
        let nowState = denseNowState()
        let capacity = denseCapacity()

        let reading = PressureEngine().reading(nowState: nowState, capacityShape: capacity)

        XCTAssertEqual(reading.kind, .needsBuffer)
        XCTAssertGreaterThanOrEqual(reading.ordinal, 6)
        XCTAssertEqual(reading.summary, "Needs buffer")
        XCTAssertTrue(reading.hiddenFromRootUI)
        XCTAssertEqual(
            Set(reading.ruleSnapshots.map(\.kind)),
            Set([
                .fixedPointDensity,
                .gapFragmentation,
                .pastDueSteps,
                .unclosedSteps,
                .goalThreadLoad,
                .shortTransitions,
                .protectedWindowConflicts
            ])
        )
        XCTAssertTrue(reading.ruleSnapshots.contains { $0.kind == .fixedPointDensity && $0.contribution == 2 })
        XCTAssertTrue(reading.ruleSnapshots.contains { $0.kind == .gapFragmentation && $0.contribution == 2 })
        XCTAssertTrue(reading.ruleSnapshots.contains { $0.kind == .pastDueSteps && $0.contribution == 2 })
        XCTAssertTrue(reading.ruleSnapshots.contains { $0.kind == .goalThreadLoad && $0.evidenceReferenceIDs.contains("goal-proof-1") })
    }

    func testAMB1170PressureCorrectionCalibratesFutureReadings() {
        let nowState = crowdedNowState()
        let capacity = crowdedCapacity()
        let engine = PressureEngine()

        let base = engine.reading(nowState: nowState, capacityShape: capacity)
        let moreBuffer = engine.reading(
            nowState: nowState,
            capacityShape: capacity,
            corrections: [
                PressureCorrection(
                    id: "correction-buffer",
                    kind: .needsTransitionBuffer,
                    createdAt: nowState.generatedAt,
                    evidenceReferenceID: "correction-proof"
                )
            ]
        )
        let feltLight = engine.reading(
            nowState: nowState,
            capacityShape: capacity,
            corrections: [
                PressureCorrection(
                    id: "correction-light",
                    kind: .feltLight,
                    createdAt: nowState.generatedAt,
                    evidenceReferenceID: "correction-light-proof"
                ),
                PressureCorrection(
                    id: "correction-light-2",
                    kind: .feltLight,
                    createdAt: nowState.generatedAt,
                    evidenceReferenceID: "correction-light-proof-2"
                )
            ]
        )

        XCTAssertEqual(base.kind, .crowded)
        XCTAssertEqual(moreBuffer.kind, .tight)
        XCTAssertEqual(feltLight.kind, .light)
        XCTAssertTrue(moreBuffer.ruleSnapshots.contains { $0.kind == .manualCorrection && $0.evidenceReferenceIDs == ["correction-proof"] })
        XCTAssertTrue(feltLight.ruleSnapshots.contains { $0.kind == .manualCorrection && $0.contribution == -2 })
    }

    func testAMB1170PressureCopyAvoidsScoresAndShameLanguage() {
        let readings = PressureKind.allCases.map { kind in
            PressureReading(
                id: "reading-\(kind.rawValue)",
                kind: kind,
                ordinal: 4,
                summary: kind.title,
                semanticSummary: PressureEngine().reading(nowState: denseNowState(), capacityShape: denseCapacity()).semanticSummary,
                accessibilitySummary: PressureEngine().reading(nowState: denseNowState(), capacityShape: denseCapacity()).accessibilitySummary,
                ruleSnapshots: []
            )
        }
        let combined = readings.flatMap { [$0.summary, $0.semanticSummary, $0.accessibilitySummary] }.joined(separator: " ")
        let forbidden = [
            "82% pressure",
            "%",
            "high risk",
            "bad fit",
            "overloaded",
            "failure likely",
            "behind",
            "poor productivity"
        ]

        for phrase in forbidden {
            XCTAssertFalse(combined.localizedCaseInsensitiveContains(phrase), phrase)
        }
        XCTAssertTrue(combined.contains("Light"))
        XCTAssertTrue(combined.contains("Crowded"))
        XCTAssertTrue(combined.contains("Tight"))
        XCTAssertTrue(combined.contains("Needs buffer"))
    }

    func testAMB1170PressureReadingStaysRuntimeOwnedAfterRootExposureGate() throws {
        let root = repoRoot()
        let rootView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", root: root)
        let timeSurface = try source("Native/Ambitions/Surfaces/Time/TimeSurface.swift", root: root)
        let scannedRoot = [rootView, timeSurface].joined(separator: "\n")

        XCTAssertFalse(scannedRoot.contains("PressureReading"))
        XCTAssertFalse(scannedRoot.contains("82% pressure"))
    }

    private func crowdedNowState() -> CanonicalNowState {
        CanonicalNowState(
            id: "now.pressure.crowded",
            generatedAt: "2026-04-25T12:00:00Z",
            activeContextLens: .all,
            lensSource: .systemDefault,
            todayPosture: .steady,
            schedulePressure: NowPressureSummary(level: .moderate, itemCount: 5, summary: "Local fixed points are visible."),
            priorityPressure: NowPriorityRealitySummary(overallPressure: .moderate, summary: "Goal load is visible."),
            deadlinePressure: NowPressureSummary(level: .moderate, summary: "Dated Steps are steady."),
            captureUrgency: NowPressureSummary(level: .none, summary: "No captures need review."),
            blockersWaiting: NowBlockersWaitingSummary(summary: "No blockers or waiting items are visible."),
            recoveryState: .stable,
            urgentOutsideLens: NowUrgentOutsideLensSummary(level: .none, summary: "No outside-lens items are visible.")
        )
    }

    private func denseNowState() -> CanonicalNowState {
        CanonicalNowState(
            id: "now.pressure.dense",
            generatedAt: "2026-04-25T12:00:00Z",
            activeContextLens: .all,
            lensSource: .systemDefault,
            todayPosture: .tight,
            schedulePressure: NowPressureSummary(
                level: .high,
                itemCount: 6,
                summary: "Local fixed points are visible.",
                evidenceReferenceIDs: ["fixed-proof-1"]
            ),
            priorityPressure: NowPriorityRealitySummary(
                overallPressure: .elevated,
                capacity: .elevated,
                summary: "Goal load is visible."
            ),
            deadlinePressure: NowPressureSummary(
                level: .elevated,
                itemCount: 2,
                summary: "Dated Steps are close.",
                evidenceReferenceIDs: ["date-proof-1"]
            ),
            captureUrgency: NowPressureSummary(level: .none, summary: "No captures need review."),
            blockersWaiting: NowBlockersWaitingSummary(
                blockedCount: 2,
                waitingCount: 1,
                summary: "Blocked and waiting Steps are visible."
            ),
            recoveryState: .watch,
            urgentOutsideLens: NowUrgentOutsideLensSummary(level: .none, summary: "No outside-lens items are visible."),
            activeGoalPressure: (0..<4).map { index in
                NowGoalPressureSummary(
                    id: "goal-pressure-\(index)",
                    kind: .activeGoal,
                    level: .moderate,
                    goalID: "goal-\(index)",
                    title: "Goal \(index)",
                    summary: "Goal thread is visible.",
                    eventLedgerEntryIDs: ["goal-proof-\(index)"]
                )
            },
            passiveGoalPressure: (4..<6).map { index in
                NowGoalPressureSummary(
                    id: "goal-pressure-\(index)",
                    kind: .passiveGoal,
                    level: .low,
                    goalID: "goal-\(index)",
                    title: "Goal \(index)",
                    summary: "Goal thread is visible."
                )
            }
        )
    }

    private func crowdedCapacity() -> CapacityShape {
        CapacityShape(
            openMinutes: 120,
            protectedMinutes: 0,
            blockedMinutes: 0,
            flexibleMinutes: 60,
            scheduledAmbitionsMinutes: 90,
            calendarBusyMinutes: 0,
            pressureLevel: .moderate,
            summary: "Capacity can hold one focused Step."
        )
    }

    private func denseCapacity() -> CapacityShape {
        CapacityShape(
            openMinutes: 70,
            protectedMinutes: 45,
            blockedMinutes: 60,
            flexibleMinutes: 10,
            scheduledAmbitionsMinutes: 180,
            calendarBusyMinutes: 0,
            pressureLevel: .high,
            summary: "Capacity asks for buffer."
        )
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/Scheduling")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private struct StaticPressureNowStateProjector: NowStateProjecting {
    let nowState: CanonicalNowState

    func project(input: NowStateProjectionInput) -> CanonicalNowState {
        nowState
    }
}
