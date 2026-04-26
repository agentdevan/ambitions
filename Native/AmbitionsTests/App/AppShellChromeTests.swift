import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class AppShellChromeTests: XCTestCase {
    func testModeLensUsesPresentationLabelsOnly() {
        XCTAssertEqual(AmbitionModeLens.allCases.map(\.title), ["Focus", "Triage", "Plan", "Recover", "Review"])
    }

    func testAmbientStatusOrbStatesStayQualitative() {
        XCTAssertEqual(AmbitionAmbientStatus.allCases.map(\.title), ["Clear", "Steady", "Tight", "Fragile", "At risk", "Recovered", "Protected"])
        XCTAssertFalse(AmbitionAmbientStatus.allCases.map(\.title).contains { title in
            title.contains("%") || title.contains("score")
        })
    }

    func testMissionControlLaneLabelsDoNotCreateTopLevelTabs() {
        XCTAssertEqual(AmbitionMissionLane.allCases.map(\.title), ["Path", "Now", "Proof", "Risk"])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Plan", "You"])
    }

    func testTrustBadgeCopyDoesNotClaimGlobalSyncByDefault() {
        XCTAssertEqual(AmbitionTrustBadgeState.localOnly.title, "Local only")
        XCTAssertEqual(AmbitionTrustBadgeState.calendarLocal.title, "Calendar local")
        XCTAssertEqual(AmbitionTrustBadgeState.needsBackup.title, "Needs backup")
    }

    func testHeaderPosturesResolveToSafeModeLensPresentation() {
        XCTAssertEqual(AppShellHeaderPosture.execution.modeLens, .focus)
        XCTAssertEqual(AppShellHeaderPosture.direction.modeLens, .focus)
        XCTAssertEqual(AppShellHeaderPosture.shaping.modeLens, .plan)
        XCTAssertEqual(AppShellHeaderPosture.reflection.modeLens, .review)
        XCTAssertEqual(AppShellHeaderPosture.utility.modeLens, .focus)
    }
}
