import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityShellTests: XCTestCase {
    func testRootCrownOwnsEnglishAmbitionsIdentityAndTodayAccessibilityHeading() throws {
        let shellSource = try foundrySource(named: "TodayVitalityShell.swift")
        let wrapperSource = try foundrySource(named: "TodayFlagshipCalibrationView.swift")

        XCTAssertTrue(shellSource.contains("struct TodayVitalityRootCrown"))
        XCTAssertTrue(shellSource.contains("copy.todayAccessibilityHeading"))
        XCTAssertTrue(shellSource.contains("copy.ambitionsWordmark"))
        XCTAssertTrue(shellSource.contains("tfcs-today-heading"))
        XCTAssertTrue(shellSource.contains(".accessibilityElement(children: .ignore)"))
        XCTAssertFalse(shellSource.contains(".accessibilityElement(children: .contain)"))
        XCTAssertFalse(shellSource.contains("tfcs-ambitions-wordmark"))
        XCTAssertTrue(wrapperSource.contains("TodayVitalityRootCrown("))
        XCTAssertFalse(wrapperSource.contains("private var crown:"))
    }

    func testDockKeepsLockedRootAndGlobalCommandGroups() throws {
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.roots,
            [.today, .goals, .time, .you]
        )
        XCTAssertEqual(
            TodayFlagshipNavigationCommand.globalActions,
            [.search, .capture]
        )

        let chromeSource = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")
        XCTAssertTrue(chromeSource.contains("tfcs-dock-roots-group"))
        XCTAssertTrue(chromeSource.contains("tfcs-dock-global-actions-group"))
        XCTAssertTrue(chromeSource.contains("TodayFlagshipNavigationCommand.roots.contains"))
        XCTAssertTrue(chromeSource.contains("TodayFlagshipNavigationCommand.globalActions.contains"))
    }

    func testDockPeekUsesNarrowVisibleSeamInsideActualMinimumTarget() throws {
        let shellSource = try foundrySource(named: "TodayVitalityShell.swift")

        XCTAssertTrue(shellSource.contains("TodayVitalityDockPeekLabel"))
        XCTAssertTrue(shellSource.contains("frame(width: 44, height: 56"))
        XCTAssertTrue(shellSource.contains("Text(copy.navigationTitle(for: .today))"))
        XCTAssertTrue(shellSource.contains("Image(systemName: TodayFlagshipNavigationCommand.today.symbolName)"))
        XCTAssertTrue(shellSource.contains("contentShape(Rectangle())"))
        XCTAssertFalse(shellSource.contains("Capsule(style: .continuous)"))
    }

    func testExpandedDockHasCompactHeightScrollEscapeAndOpaqueFallback() throws {
        let chromeSource = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")
        let shellSource = try foundrySource(named: "TodayVitalityShell.swift")

        XCTAssertTrue(chromeSource.contains("ViewThatFits(in: .vertical)"))
        XCTAssertTrue(chromeSource.contains("ScrollView(.vertical)"))
        XCTAssertTrue(chromeSource.contains("tfcs-dock-compact-scroll"))
        XCTAssertTrue(chromeSource.contains("tfcs-dock-shell-peek-opaque"))
        XCTAssertTrue(shellSource.contains("accessibilityReduceTransparency"))
        XCTAssertTrue(shellSource.contains("palette.opaqueChrome"))
        XCTAssertTrue(shellSource.contains("glassEffect"))
    }

    func testSelectedTodayUsesShapeLabelAndTraitRatherThanHueAlone() throws {
        let chromeSource = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")

        XCTAssertTrue(chromeSource.contains("command.isSelectedRoot"))
        XCTAssertTrue(chromeSource.contains("Image(systemName: \"checkmark\")"))
        XCTAssertTrue(chromeSource.contains(".accessibilityAddTraits(command.isSelectedRoot ? .isSelected : [])"))
        XCTAssertTrue(chromeSource.contains(".accessibilityValue(command.isSelectedRoot ? copy.selectedRootValue"))
    }

    func testDockRemainsRootOwnedAndAbsentFromDepthDestinations() throws {
        let wrapperSource = try foundrySource(named: "TodayFlagshipCalibrationView.swift")
        let focusedSource = try foundrySource(named: "TodayFlagshipFocusedStepView.swift")
        let fullDaySource = try foundrySource(named: "TodayOpenContinuityFullDayView.swift")
        let reviewSource = try foundrySource(named: "TodayFlagshipReviewView.swift")

        XCTAssertTrue(wrapperSource.contains("private var todayRoot"))
        XCTAssertEqual(wrapperSource.components(separatedBy: "TodayFlagshipDock(").count - 1, 1)
        XCTAssertFalse(focusedSource.contains("TodayFlagshipDock("))
        XCTAssertFalse(fullDaySource.contains("TodayFlagshipDock("))
        XCTAssertFalse(reviewSource.contains("TodayFlagshipDock("))
    }

    private func foundrySource(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        return try String(
            contentsOf: packageRoot
                .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
                .appendingPathComponent(filename),
            encoding: .utf8
        )
    }
}
