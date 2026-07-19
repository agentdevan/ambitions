@testable import Ambitions
import Foundation
import XCTest

final class TodayRealityWindowActionGatingTests: XCTestCase {
    func testTodayRootHasNoNoOpModeToggleOrEmbeddedCaptureCTA() throws {
        let railSource = try source("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailView.swift")
        let railStateSource = try source("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailViewStateRendering.swift")
        let railActionSource = try source("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailViewCurrentMoment.swift")
        let surfaceSource = try source("Native/Ambitions/Surfaces/Today/TodaySurface.swift")
        let combined = [railSource, railStateSource, railActionSource, surfaceSource].joined(separator: "\n")

        XCTAssertFalse(combined.contains("TodayRealityMeridianModeSelector"))
        XCTAssertFalse(combined.contains("Picker(\"Today mode\""))
        XCTAssertFalse(combined.contains("TodayMeridianZoom"))
        XCTAssertFalse(combined.contains("Capture what changed"))
        XCTAssertFalse(combined.contains("today.open-captures-button"))
        XCTAssertFalse(combined.contains("Review context"))
        XCTAssertFalse(combined.contains("Live now"))
    }

    func testNoStepStateHasNoRootActions() {
        let rail = PreviewTodayScenarios.empty.execution.dayRail
        let availability = TodayRootActionGate.actions(for: rail.heroStep)

        XCTAssertNil(rail.heroStep)
        XCTAssertNil(availability.shapeTime)
        XCTAssertNil(availability.protectWindow)
        XCTAssertNil(availability.recordOutcome)
    }

    func testValidStepStateShowsContextualActionsAndGatesOutcome() throws {
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let startingHero = hero.replacingPrimaryAction(
            TodayInlineAction(
                kind: .startStepSession,
                title: "Start now",
                systemImage: "play.fill",
                state: .selected,
                target: hero.primaryAction.target
            )
        )
        let availability = TodayRootActionGate.actions(for: startingHero)

        XCTAssertEqual(availability.shapeTime?.kind, .openTime)
        XCTAssertEqual(availability.shapeTime?.target.stepID, hero.primaryAction.target.stepID)
        XCTAssertEqual(availability.protectWindow?.kind, .protectLater)
        XCTAssertEqual(availability.protectWindow?.target.stepID, hero.primaryAction.target.stepID)
        XCTAssertNil(availability.recordOutcome)
    }

    func testClosureEligibleStepShowsRecordOutcomeOnlyWhenPrimaryActionCanClose() throws {
        let rail = PreviewTodayScenarios.stable.execution.dayRail
        let hero = try XCTUnwrap(rail.heroStep)
        let closingHero = DayRailHeroStepState(
            id: hero.id,
            title: hero.title,
            subtitle: hero.subtitle,
            duration: hero.duration,
            fitLabel: hero.fitLabel,
            whySummary: hero.whySummary,
            sourceQualityLabel: hero.sourceQualityLabel,
            becauseLine: hero.becauseLine,
            receiptLabel: hero.receiptLabel,
            proofLabel: hero.proofLabel,
            sourceRecordLabel: hero.sourceRecordLabel,
            replayTraceLabel: hero.replayTraceLabel,
            replayInspectionLabel: hero.replayInspectionLabel,
            contextEdge: hero.contextEdge,
            timeFitProof: hero.timeFitProof,
            goalThread: hero.goalThread,
            receiptItem: hero.receiptItem,
            primaryAction: TodayInlineAction(
                kind: .complete,
                title: "Still counts",
                systemImage: "checkmark.seal",
                state: .selected,
                target: hero.primaryAction.target
            ),
            secondaryAction: hero.secondaryAction,
            detailTarget: hero.detailTarget,
            sourceLabels: hero.sourceLabels
        )

        let availability = TodayRootActionGate.actions(for: closingHero)

        XCTAssertEqual(availability.recordOutcome?.kind, .closeActionClosure)
        XCTAssertEqual(availability.recordOutcome?.target.stepID, hero.primaryAction.target.stepID)
    }

    func testProtectAndShapeUseFocusedTodayFlowsInsteadOfRootTimeRouting() throws {
        let autoLoadSource = try source("Native/Ambitions/Surfaces/Today/TodaySurface+02-autoLoad.swift")
        let flowSource = try source("Native/Ambitions/Surfaces/Today/TodayFocusedFlows.swift")

        XCTAssertFalse(autoLoadSource.contains("route(to: .tab(.time)"))
        XCTAssertTrue(autoLoadSource.contains("selectedWindowProtection = windowProtectionFlowState"))
        XCTAssertTrue(autoLoadSource.contains("selectedTimeShape = timeShapeFlowState"))
        XCTAssertTrue(flowSource.contains("TodayWindowProtectionFlow"))
        XCTAssertTrue(flowSource.contains("TodayTimeShapeFlow"))
    }

    func testForbiddenTodayRootRailCopyIsAbsentFromRuntimeSources() throws {
        let paths = [
            "Native/Ambitions/Surfaces/Today",
            "Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailViewStateRendering.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailViewCurrentMoment.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailViewUpNextRows.swift"
        ]
        let combined = try paths.map(source).joined(separator: "\n")

        for forbidden in ["No source change yet", "All from work context", "Capture what changed", "Review context", "Live now"] {
            XCTAssertFalse(combined.contains(forbidden), "Today root runtime source still contains forbidden copy: \(forbidden)")
        }
    }

    private func source(_ relativePath: String) throws -> String {
        let url = repoRoot().appendingPathComponent(relativePath)
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
            XCTFail("Missing source path: \(relativePath)")
            return ""
        }
        if isDirectory.boolValue {
            let files = try FileManager.default
                .contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "swift" }
                .sorted { $0.path < $1.path }
            return try files.map { try String(contentsOf: $0, encoding: .utf8) }.joined(separator: "\n")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Surfaces/Today/TodaySurface.swift")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}

private extension DayRailHeroStepState {
    func replacingPrimaryAction(_ action: TodayInlineAction) -> DayRailHeroStepState {
        DayRailHeroStepState(
            id: id,
            title: title,
            subtitle: subtitle,
            duration: duration,
            fitLabel: fitLabel,
            whySummary: whySummary,
            sourceQualityLabel: sourceQualityLabel,
            becauseLine: becauseLine,
            receiptLabel: receiptLabel,
            proofLabel: proofLabel,
            sourceRecordLabel: sourceRecordLabel,
            replayTraceLabel: replayTraceLabel,
            replayInspectionLabel: replayInspectionLabel,
            contextEdge: contextEdge,
            timeFitProof: timeFitProof,
            goalThread: goalThread,
            receiptItem: receiptItem,
            primaryAction: action,
            secondaryAction: secondaryAction,
            detailTarget: detailTarget,
            sourceLabels: sourceLabels
        )
    }
}
