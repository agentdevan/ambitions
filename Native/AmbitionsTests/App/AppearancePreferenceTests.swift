import AmbitionsDesignSystem
import SwiftUI
import XCTest
@testable import Ambitions

final class AppearancePreferenceTests: XCTestCase {
    func testSystemAppearanceDoesNotForceColorScheme() {
        XCTAssertNil(AppAppearancePreference.system.preferredColorScheme)
    }

    func testExplicitAppearancesForceExpectedColorScheme() {
        XCTAssertEqual(AppAppearancePreference.light.preferredColorScheme, .light)
        XCTAssertEqual(AppAppearancePreference.dark.preferredColorScheme, .dark)
    }

    func testAppearancePreferenceResolvesDistinctRootThemeModes() {
        let darkTheme = AppAppearancePreference.dark.resolveTheme(systemColorScheme: .light, accentFamily: .sage)
        let lightTheme = AppAppearancePreference.light.resolveTheme(systemColorScheme: .dark, accentFamily: .sage)
        let systemDarkTheme = AppAppearancePreference.system.resolveTheme(systemColorScheme: .dark, accentFamily: .sage)
        let systemLightTheme = AppAppearancePreference.system.resolveTheme(systemColorScheme: .light, accentFamily: .sage)

        XCTAssertEqual(darkTheme.mode, .dark)
        XCTAssertEqual(lightTheme.mode, .light)
        XCTAssertEqual(systemDarkTheme.mode, .dark)
        XCTAssertEqual(systemLightTheme.mode, .light)
        XCTAssertNotEqual(darkTheme.mode, lightTheme.mode)
    }

    func testThemeChromeUsesOpaqueHeaderAndMeaningfulDarkLightModes() {
        let darkTheme = AmbitionTheme.theme(for: .dark, accentFamily: .sage)
        let lightTheme = AmbitionTheme.theme(for: .light, accentFamily: .sage)

        XCTAssertEqual(darkTheme.surfaces.backgroundBlurOpacity, 1.0)
        XCTAssertEqual(lightTheme.surfaces.backgroundBlurOpacity, 1.0)
        XCTAssertNotEqual(darkTheme.mode, lightTheme.mode)
        XCTAssertGreaterThanOrEqual(darkTheme.panel.minimumTapTarget, 44)
        XCTAssertGreaterThanOrEqual(lightTheme.panel.minimumTapTarget, 44)
    }
}
