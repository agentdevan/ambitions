@testable import Ambitions
import XCTest

final class TodayRealityMeridianExperienceElevationTests: XCTestCase {
    func testAMB572TodayObjectStagePrimitiveContractReplacesFirstViewportContainers() {
        let contract = TodayObjectStagePrimitiveContract.current

        XCTAssertEqual(contract.primitiveID, "today-object-stage")
        XCTAssertEqual(contract.ownerSurface, "Today")
        XCTAssertEqual(contract.productObject, "Reality Meridian / Start here")
        XCTAssertEqual(contract.screenshotIdentifier, "TodayObjectStage")
        XCTAssertTrue(contract.firstViewportAvoidsVisibleCardStructure)
        XCTAssertEqual(contract.sourceTrustLineOrder, ["source", "freshness", "receipt", "privacy"])
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("source/trust strip item chrome"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
    }

    func testAMB572PrimitiveRegistryIncludesTodayObjectStageEntry() throws {
        let registryURL = repoRoot().appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md")
        guard FileManager.default.fileExists(atPath: registryURL.path) else {
            throw XCTSkip("Repo source tree is unavailable from this test runner sandbox.")
        }
        let registry = try String(
            contentsOf: registryURL,
            encoding: .utf8
        )

        XCTAssertTrue(registry.contains("| today-object-stage | Promoted | Today | Reality Meridian / Start here | AMB-572 |"))
        XCTAssertTrue(registry.contains("### today-object-stage"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/object-stage/AMB-572-today-object-stage.md"))
    }

    func testTodayRealityMeridianPreviewFixturesCoverFreshnessVariants() {
        let happy = PreviewTodayScenarios.stable.execution.dayRail
        let stale = PreviewTodayScenarios.sourceStale.execution.dayRail
        let blocked = PreviewTodayScenarios.blockedWaiting.execution.dayRail
        let unavailable = PreviewTodayScenarios.sourceUnavailable.execution.dayRail
        let privateRail = PreviewTodayScenarios.privateRail.execution.dayRail
        let recovery = PreviewTodayScenarios.recovery.execution
        let lowConfidence = PreviewTodayScenarios.lowData.execution
        let reviewRequired = PreviewTodayScenarios.heroDisabled.execution.dayRail
        let empty = PreviewTodayScenarios.empty.execution.dayRail

        XCTAssertEqual(happy.heroStep?.receiptItem.freshness, .fresh)
        XCTAssertEqual(stale.heroStep?.receiptItem.freshness, .stale)
        XCTAssertEqual(stale.heroStep?.sourceQualityLabel, "Source needs review")
        XCTAssertEqual(blocked.heroStep?.receiptItem.freshness, .blocked)
        XCTAssertEqual(blocked.heroStep?.sourceQualityLabel, "Blocked or waiting")
        XCTAssertEqual(unavailable.heroStep?.receiptItem.freshness, .unavailable)
        XCTAssertEqual(unavailable.heroStep?.sourceRecordLabel, "Source record unavailable")
        XCTAssertEqual(reviewRequired.heroStep?.receiptItem.freshness, .partial)
        XCTAssertEqual(reviewRequired.heroStep?.sourceQualityLabel, "Source needs review")
        XCTAssertTrue(happy.heroStep?.becauseLine.contains("open window") == true)
        XCTAssertFalse(happy.heroStep?.becauseLine.localizedCaseInsensitiveContains("runtime summary truth") == true)
        XCTAssertTrue(privateRail.privacyProjection.isSensitiveProjection)
        XCTAssertEqual(recovery.hero.kind, .recovery)
        XCTAssertEqual(lowConfidence.hero.confidenceLabel, "Low-data")
        XCTAssertNil(empty.heroStep)
        XCTAssertEqual(empty.primaryAction?.kind, .openTime)
        XCTAssertEqual(empty.primaryAction?.title, "Build today")
    }

    func testTodayRealityMeridianReceiptAccessibilitySummariesStayInspectable() throws {
        let stale = try XCTUnwrap(PreviewTodayScenarios.sourceStale.execution.dayRail.heroStep)
        let blocked = try XCTUnwrap(PreviewTodayScenarios.blockedWaiting.execution.dayRail.heroStep)
        let unavailable = try XCTUnwrap(PreviewTodayScenarios.sourceUnavailable.execution.dayRail.heroStep)
        let privateStep = try XCTUnwrap(PreviewTodayScenarios.privateRail.execution.dayRail.heroStep)

        XCTAssertTrue(stale.receiptItem.accessibilitySummary.contains("Review context"))
        XCTAssertTrue(stale.receiptItem.accessibilitySummary.contains("Review or adjust before changing the plan."))
        XCTAssertTrue(blocked.receiptItem.accessibilitySummary.contains("Blocked"))
        XCTAssertTrue(blocked.receiptItem.accessibilitySummary.contains("Waiting item"))
        XCTAssertTrue(unavailable.receiptItem.accessibilitySummary.contains("No source"))
        XCTAssertEqual(unavailable.sourceRecordLabel, "Source record unavailable")
        XCTAssertTrue(privateStep.receiptItem.accessibilitySummary.contains("Private details hidden"))
        XCTAssertTrue(privateStep.receiptItem.accessibilitySummary.contains("Details stay private on Today."))
        XCTAssertEqual(privateStep.sourceQualityLabel, "Private source")
    }

    func testTodayRealityMeridianRequiredStateMatrixCoverage() {
        let active = PreviewTodayScenarios.stable.execution.dayRail
        let nextSoon = PreviewTodayScenarios.nextSoon.execution.dayRail
        let protected = PreviewTodayScenarios.protectedTime.execution.dayRail
        let noSchedule = PreviewTodayScenarios.noSchedule.execution.dayRail
        let missedRecoverable = PreviewTodayScenarios.missedRecoverable.execution.dayRail
        let blocked = PreviewTodayScenarios.blockedWaiting.execution.dayRail
        let recoveryExperience = PreviewTodayScenarios.recovery
        let review = PreviewTodayScenarios.heroDisabled.execution.dayRail
        let sourceUnavailable = PreviewTodayScenarios.sourceUnavailable.execution.dayRail

        XCTAssertEqual(active.mode, .normal)
        XCTAssertNotNil(active.heroStep)
        XCTAssertEqual(nextSoon.mode, .normal)
        XCTAssertFalse(nextSoon.rows.filter { $0.slot == .next }.isEmpty)
        XCTAssertEqual(protected.mode, .protected)
        XCTAssertEqual(protected.continuity.pressureLabel, "Protected now")
        XCTAssertEqual(noSchedule.mode, .noSchedule)
        XCTAssertEqual(noSchedule.continuity.pressureLabel, "No schedule connected")
        XCTAssertEqual(missedRecoverable.heroStep?.receiptItem.freshness, .partial)
        XCTAssertEqual(blocked.heroStep?.receiptItem.freshness, .blocked)
        XCTAssertEqual(recoveryExperience.support.recoveryBloom?.title, "Recovery Bloom")
        XCTAssertEqual(review.heroStep?.sourceQualityLabel, "Source needs review")
        XCTAssertEqual(sourceUnavailable.heroStep?.receiptItem.freshness, .unavailable)
        XCTAssertEqual(sourceUnavailable.heroStep?.sourceRecordLabel, "Source record unavailable")
        XCTAssertEqual(recoveryExperience.execution.dayStateSummary, PreviewTodayScenarios.recovery.hero.truth.supportingText.todayShortSentence)
    }

    func testTodayRealityMeridianContinuityAndAccessibilitySummaries() {
        let continuity = PreviewTodayScenarios.stable.execution.realityMeridianContinuity
        let reflowHero = PreviewTodayScenarios.reflow.execution.dayRail.heroStep
        let coverage = PreviewTodayScenarios.startHereReady.execution.dayRail.heroStep?.startHereReplayCoverage

        XCTAssertTrue(continuity.reducedMotionSummary.contains("Reduced motion keeps the same order"))
        XCTAssertTrue(continuity.dynamicTypeSummary.contains("Dynamic Type keeps"))
        XCTAssertEqual(continuity.voiceOverOrder.first, "Reality Meridian")
        XCTAssertEqual(continuity.voiceOverOrder[1], "Start here")
        XCTAssertTrue((reflowHero?.title.count ?? 0) > continuity.recommendationTitle.count)
        XCTAssertEqual(coverage?.isInsideRealityMeridian, true)
        XCTAssertEqual(coverage?.hasStartHereDecisionLayer, true)
        XCTAssertEqual(coverage?.hasSourceRecord, true)
        XCTAssertEqual(coverage?.hasReceipt, true)
        XCTAssertEqual(coverage?.hasReplayTrace, true)
        XCTAssertEqual(coverage?.isInspectableFromYou, true)
        XCTAssertEqual(coverage?.isGreen, true)
    }

    func testTrain5TodayLensWrapsRealityMeridianStates() {
        let generatedAt = PreviewClock.default.now
        let normal = TodayLens(experience: PreviewTodayScenarios.stable, generatedAt: generatedAt)
        let protected = TodayLens(experience: PreviewTodayScenarios.protectedTime, generatedAt: generatedAt)
        let blocked = TodayLens(experience: PreviewTodayScenarios.blockedWaiting, generatedAt: generatedAt)
        let empty = TodayLens(experience: PreviewTodayScenarios.empty, generatedAt: generatedAt)
        let sourceUnavailable = TodayLens(experience: PreviewTodayScenarios.sourceUnavailable, generatedAt: generatedAt)
        let completedProof = TodayLens(experience: PreviewTodayScenarios.startHereReady, generatedAt: generatedAt)

        XCTAssertEqual(normal.stageScene.meridian.primaryObjectTitle, "Reality Meridian")
        XCTAssertEqual(normal.stageScene.startHere?.primaryActionTitle, "Start now")
        XCTAssertTrue(normal.stageScene.meridian.voiceOverOrder.contains("Start here"))
        XCTAssertTrue(normal.stageScene.meridian.dynamicTypeSummary.contains("Dynamic Type"))
        XCTAssertTrue(normal.stageScene.meridian.reducedMotionSummary.contains("Reduced motion"))
        XCTAssertEqual(protected.stageScene.meridian.mode, .protected)
        XCTAssertTrue(blocked.stageScene.showsBlockedOrWaitingState)
        XCTAssertNil(empty.stageScene.startHere)
        XCTAssertEqual(empty.stageScene.meridian.noStepSummary, "No step is required right now.")
        XCTAssertTrue(sourceUnavailable.stageScene.meridian.sourceUnavailable)
        XCTAssertTrue(completedProof.stageScene.showsCompletedProofState)
    }

    private func repoRoot() -> URL {
        let environment = ProcessInfo.processInfo.environment
        let roots = [
            environment["SRCROOT"],
            environment["PROJECT_DIR"],
            FileManager.default.currentDirectoryPath,
            #filePath,
        ].compactMap { $0 }

        for root in roots {
            var url = URL(fileURLWithPath: root)
            if url.pathExtension.isEmpty == false {
                url.deleteLastPathComponent()
            }
            while url.pathComponents.count > 1 {
                let candidate = url.appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md")
                if FileManager.default.fileExists(atPath: candidate.path) {
                    return url
                }
                url.deleteLastPathComponent()
            }
        }

        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
