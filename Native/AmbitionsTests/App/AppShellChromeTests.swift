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
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
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

    func testShellThemeKeepsHeaderAndTabChromeReadableInBothModes() {
        for mode in AmbitionThemeMode.allCases {
            let theme = AmbitionTheme.theme(for: mode)

            XCTAssertEqual(theme.surfaces.backgroundBlurOpacity, 1.0)
            XCTAssertGreaterThanOrEqual(theme.panel.minimumTapTarget, 44)
            XCTAssertGreaterThanOrEqual(theme.spacing.sm, 16)
            XCTAssertGreaterThan(theme.radius.md, 0)
        }
    }

    func testM12HeaderPosturesExposeContinuityWithoutHiddenNavigation() {
        let messages = [
            AppShellHeaderPosture.execution.continuityMessage,
            AppShellHeaderPosture.direction.continuityMessage,
            AppShellHeaderPosture.shaping.continuityMessage,
            AppShellHeaderPosture.reflection.continuityMessage,
            AppShellHeaderPosture.utility.continuityMessage
        ]

        XCTAssertEqual(messages.count, Set(messages).count)
        XCTAssertTrue(messages.allSatisfy { $0.isEmpty == false })
        XCTAssertFalse(messages.contains { message in
            message.localizedCaseInsensitiveContains("dashboard") ||
            message.localizedCaseInsensitiveContains("AI") ||
            message.localizedCaseInsensitiveContains("sync") ||
            message.localizedCaseInsensitiveContains("sixth tab")
        })
    }

    func testM12ContinuityMaturityReportCoversRequiredSurfacesAndLayer3Blockers() {
        XCTAssertEqual(
            CrossSurfaceContinuityMaturityReport.handoffs.map(\.surface),
            [.today, .capture, .goals, .plan, .you, .reviews, .externalSurfaces, .goalDetail]
        )
        XCTAssertTrue(CrossSurfaceContinuityMaturityReport.handoffs.contains { $0.id == "path-builder" })
        XCTAssertTrue(CrossSurfaceContinuityMaturityReport.handoffs.allSatisfy { $0.owningRoute.isEmpty == false })
        XCTAssertFalse(CrossSurfaceContinuityMaturityReport.handoffs.contains { $0.continuityBehavior.localizedCaseInsensitiveContains("top-level Insights") })
        XCTAssertFalse(CrossSurfaceContinuityMaturityReport.handoffs.contains { $0.continuityBehavior.localizedCaseInsensitiveContains("Tasks tab") })

        XCTAssertEqual(
            CrossSurfaceContinuityMaturityReport.performanceChecks.map(\.id),
            ["life-graph", "ledger-receipts", "trust-memory", "path-portfolio", "external-snapshots", "device-responsiveness"]
        )
        XCTAssertEqual(CrossSurfaceContinuityMaturityReport.layer3Blockers.map(\.ownerBatch), ["R01", "R02", "R03", "R04-R05"])
        XCTAssertTrue(CrossSurfaceContinuityMaturityReport.completionSummary.contains("R04/R05 own remaining external release truth"))
    }

    func testSI03SurfaceShellKindsDoNotCreateNavigationDestinations() {
        XCTAssertEqual(
            AmbitionsSurfaceShellKind.allCases,
            [.topLevelSurface, .drillDown, .utilityHub, .overlayHost]
        )

        for kind in AmbitionsSurfaceShellKind.allCases {
            XCTAssertFalse(kind.title.isEmpty)
            XCTAssertFalse(kind.accessibilityRole.isEmpty)
            XCTAssertTrue(AmbitionModeLens.allCases.contains(kind.defaultLens))
            XCTAssertTrue(AmbitionAmbientStatus.allCases.contains(kind.defaultStatus))
        }

        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Capture", "Time", "You"])
    }
}
