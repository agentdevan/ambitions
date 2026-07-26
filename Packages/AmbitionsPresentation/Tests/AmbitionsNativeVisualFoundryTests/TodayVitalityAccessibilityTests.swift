import XCTest
@testable import AmbitionsNativeVisualFoundry

final class TodayVitalityAccessibilityTests: XCTestCase {
    func testR13JourneyFocusAnchorsResolveToSemanticTargets() {
        let content = TodayFlagshipCalibrationFixture.preparingForBaby
        var state = TodayFlagshipJourneyState(content: content)

        XCTAssertEqual(state.focusAnchor, .startHere)

        XCTAssertTrue(state.openStartHere())
        XCTAssertEqual(state.focusAnchor, .focusedIdentity)

        XCTAssertTrue(state.selectStillCounts())
        XCTAssertEqual(state.focusAnchor, .reviewCurrentTruth)

        XCTAssertTrue(state.cancelReview())
        XCTAssertEqual(state.focusAnchor, .focusedIdentity)

        XCTAssertTrue(state.selectStillCounts())
        XCTAssertTrue(state.beginCommit())
        XCTAssertEqual(state.focusAnchor, .saving)

        XCTAssertTrue(state.settle())
        XCTAssertEqual(state.focusAnchor, .settledTruth)

        XCTAssertTrue(state.returnToToday())
        XCTAssertEqual(state.focusAnchor, .returnedSettledStep)
    }

    func testR13RootAttachesInitialFocusToDominantStartHereObject() throws {
        let source = try foundrySource(named: "TodayVitalityRootView.swift")

        XCTAssertTrue(source.contains(".accessibilityFocused($accessibilityFocus, equals: .startHere)"))
        XCTAssertTrue(source.contains(".onAppear {\n                routeFocus(for: state.phase)"))
        XCTAssertTrue(source.contains(".accessibilityIdentifier(\"tfcs-start-here-object\")"))
    }

    func testR13FullDayUsesLazyStableRowsAndSharedMotionPolicy() throws {
        let source = try foundrySource(named: "TodayVitalityFullDayView.swift")

        XCTAssertTrue(source.contains("LazyVStack(alignment: .leading, spacing: 0)"))
        XCTAssertTrue(source.contains("TodayOpenContinuityMotionPolicy(reduceMotion: reduceMotion)"))
        XCTAssertTrue(source.contains("withAnimation(motionPolicy.stateAnimation)"))
        XCTAssertFalse(source.contains("withAnimation(.easeInOut(duration:"))
        XCTAssertTrue(source.contains("ForEach(Array(objects.enumerated()), id: \\.element.id)"))
    }

    func testR13MotionAndChromeRetainNonSpatialAccessibilityEquivalents() throws {
        let grammar = try foundrySource(named: "TodayOpenContinuityGrammar.swift")
        let vitalityGrammar = try foundrySource(named: "TodayVitalityGrammar.swift")
        let chrome = try foundrySource(named: "TodayFlagshipNavigationChrome.swift")

        XCTAssertTrue(grammar.contains("reduceMotion ? nil"))
        XCTAssertTrue(vitalityGrammar.contains("reduceMotion ? 1"))
        XCTAssertTrue(chrome.contains("@Environment(\\.accessibilityReduceTransparency)"))
        XCTAssertTrue(chrome.contains("tfcs-dock-shell-peek-opaque"))
        XCTAssertTrue(chrome.contains("TodayVitalityDockMaterial("))
    }

    func testR13RecoveryFocusIsAttachedToVisibleMeaningNotModalContainer() throws {
        let source = try foundrySource(named: "TodayVitalityRecoveryView.swift")

        XCTAssertTrue(source.contains(".accessibilityFocused($isInterruptionFocused)"))
        XCTAssertTrue(source.contains(".accessibilityIdentifier(\"tfcs-interruption-seam\")"))
        XCTAssertTrue(source.contains(".accessibilityFocused($focusedCommandID, equals: id)"))
        XCTAssertFalse(
            source.contains(
                ".accessibilityFocused($focusedCommandID)\n"
                    + "        .accessibilityIdentifier(\"tfcs-recovery-review\")"
            )
        )
    }

    func testR13RootKeepsTodayAsAccessibilityHeadingAndAmbitionsAsVisualCrown() throws {
        let shell = try foundrySource(named: "TodayVitalityShell.swift")
        let wrapper = try foundrySource(named: "TodayFlagshipCalibrationView.swift")

        XCTAssertTrue(shell.contains("accessibilityIdentifier(\"tfcs-today-heading\")"))
        XCTAssertTrue(wrapper.contains("navigationTitle(content.interfaceCopy.todayNavigationTitle)"))
        XCTAssertTrue(wrapper.contains("TodayVitalityRootCrown("))
    }

    private func foundrySource(named filename: String) throws -> String {
        let packageRoot = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let url = packageRoot
            .appendingPathComponent("Sources/AmbitionsNativeVisualFoundry")
            .appendingPathComponent(filename)

        guard FileManager.default.fileExists(atPath: url.path) else {
            XCTFail("R13 accessibility source is missing: \(filename)")
            return ""
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
