import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayFlagshipR13FixtureParityTests: XCTestCase {
    func testArabicSaudiStressFixturePreservesR13SemanticTruthParity() {
        let english = TodayFlagshipCalibrationFixture.preparingForBaby
        let rtl = english.arabicSaudiEvaluation

        XCTAssertEqual(rtl.primaryStep.id, english.primaryStep.id)
        XCTAssertEqual(rtl.primaryStep.parentPursuitID, english.primaryStep.parentPursuitID)
        XCTAssertEqual(
            rtl.primaryStep.currentAcceptedTruth,
            "أُخليت الزاوية واختيرت عيّنة الطلاء."
        )
        XCTAssertEqual(
            rtl.primaryStep.stillCountsProposal.proposedTruth,
            "دهنتُ الجدار بطبقة أساس وجرّبتُ اللون الجديد."
        )
        XCTAssertEqual(
            rtl.primaryStep.stillCountsProposal.settledTruth,
            "دهنتُ الجدار بطبقة أساس وجرّبتُ اللون الجديد."
        )
        XCTAssertEqual(
            rtl.recovery.lastSavedProgress,
            rtl.primaryStep.stillCountsProposal.settledTruth
        )
        XCTAssertEqual(rtl.primaryStep.temporalContext.exactTime, "متاح الآن")
        XCTAssertEqual(rtl.primaryStep.temporalContext.relationship, "قبل تسليم الساعة ٢:٠٠ م")
        XCTAssertEqual(
            rtl.revealedStartHereStep.temporalContext.exactTime,
            rtl.timeline.first(where: { $0.canonicalObjectID == rtl.revealedStartHereStep.id })?.timeLabel
        )
        XCTAssertEqual(
            rtl.primaryStep.temporalContext.fullDayTimeLabel,
            rtl.timeline.first?.timeLabel
        )
    }
}
