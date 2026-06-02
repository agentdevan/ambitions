@testable import Ambitions
import XCTest

final class TodayRealityMeridianExperienceElevationTests: XCTestCase {
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
        XCTAssertTrue(privateRail.privacyProjection.isSensitiveProjection)
        XCTAssertEqual(recovery.hero.kind, .recovery)
        XCTAssertEqual(lowConfidence.hero.confidenceLabel, "Low-data")
        XCTAssertNil(empty.heroStep)
    }

    func testTodayRealityMeridianReceiptAccessibilitySummariesStayInspectable() throws {
        let stale = try XCTUnwrap(PreviewTodayScenarios.sourceStale.execution.dayRail.heroStep)
        let blocked = try XCTUnwrap(PreviewTodayScenarios.blockedWaiting.execution.dayRail.heroStep)
        let unavailable = try XCTUnwrap(PreviewTodayScenarios.sourceUnavailable.execution.dayRail.heroStep)
        let privateStep = try XCTUnwrap(PreviewTodayScenarios.privateRail.execution.dayRail.heroStep)

        XCTAssertTrue(stale.receiptItem.accessibilitySummary.contains("Review source"))
        XCTAssertTrue(stale.receiptItem.accessibilitySummary.contains("Review or adjust before changing the plan."))
        XCTAssertTrue(blocked.receiptItem.accessibilitySummary.contains("Blocked"))
        XCTAssertTrue(blocked.receiptItem.accessibilitySummary.contains("Waiting item"))
        XCTAssertTrue(unavailable.receiptItem.accessibilitySummary.contains("No source"))
        XCTAssertEqual(unavailable.sourceRecordLabel, "Source record unavailable")
        XCTAssertTrue(privateStep.receiptItem.accessibilitySummary.contains("Private details hidden"))
        XCTAssertTrue(privateStep.receiptItem.accessibilitySummary.contains("Details stay private on Today."))
        XCTAssertEqual(privateStep.sourceQualityLabel, "Private source")
    }
}
