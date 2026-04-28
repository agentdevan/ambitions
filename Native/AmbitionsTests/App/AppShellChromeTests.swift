import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class AppShellChromeTests: XCTestCase {
    func testModeLensUsesPresentationLabelsOnly() {
        XCTAssertEqual(AmbitionModeLens.allCases.map(\.title), ["Focus", "Sort", "Plan", "Recover", "Review"])
    }

    func testAmbientStatusOrbStatesStayQualitative() {
        XCTAssertEqual(AmbitionAmbientStatus.allCases.map(\.title), ["Clear", "Steady", "Tight", "Too much planned", "Needs attention", "Recovered", "Private"])
        XCTAssertFalse(AmbitionAmbientStatus.allCases.map(\.title).contains { title in
            title.contains("%") ||
            title.localizedCaseInsensitiveContains("score") ||
            title.localizedCaseInsensitiveContains("confidence") ||
            title.localizedCaseInsensitiveContains("protected")
        })
    }

    func testMissionControlLaneLabelsDoNotCreateTopLevelTabs() {
        XCTAssertEqual(AmbitionMissionLane.allCases.map(\.title), ["Overview", "Path", "Steps", "Proof", "Decisions", "Risks", "Archive"])
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Plan", "You"])
    }

    func testTrustBadgeCopyDoesNotClaimGlobalSyncByDefault() {
        XCTAssertEqual(AmbitionTrustBadgeState.localOnly.title, "Local only")
        XCTAssertEqual(AmbitionTrustBadgeState.calendarLocal.title, "From calendar")
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
