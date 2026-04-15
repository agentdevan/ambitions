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
}
