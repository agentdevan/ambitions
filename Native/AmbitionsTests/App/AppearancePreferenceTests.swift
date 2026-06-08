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

    func testAMB571PrimitiveSemanticTokenInventoryTiesTokensToInstalledPrimitives() {
        let expectedTokens: Set<AmbitionPrimitiveSemanticToken> = [
            .source,
            .sourceAttention,
            .privacyBoundary,
            .receipt,
            .accessibilityFallbackSurface,
            .accessibilityContrastStroke
        ]

        XCTAssertEqual(Set(AmbitionPrimitiveSemanticToken.allCases), expectedTokens)

        for token in AmbitionPrimitiveSemanticToken.allCases {
            XCTAssertFalse(token.rawValue.isEmpty)
            XCTAssertFalse(token.installedPrimitive.isEmpty)
            XCTAssertFalse(token.behaviorUse.isEmpty)
            XCTAssertFalse(token.accessibilityImplication.isEmpty)
        }

        XCTAssertEqual(AmbitionPrimitiveSemanticToken.source.installedPrimitive, "SourceTrustReceiptStrip")
        XCTAssertEqual(AmbitionPrimitiveSemanticToken.sourceAttention.installedPrimitive, "SourceTrustReceiptStrip")
        XCTAssertEqual(AmbitionPrimitiveSemanticToken.privacyBoundary.installedPrimitive, "SourceTrustReceiptStrip")
        XCTAssertEqual(AmbitionPrimitiveSemanticToken.receipt.installedPrimitive, "SourceTrustReceiptStrip")
        XCTAssertEqual(AmbitionPrimitiveSemanticToken.accessibilityFallbackSurface.installedPrimitive, "AmbitionsPrimitiveAccessibilityFallbackModifier")
        XCTAssertEqual(AmbitionPrimitiveSemanticToken.accessibilityContrastStroke.installedPrimitive, "AmbitionsPrimitiveAccessibilityFallbackModifier")
    }

    func testAMB571PrimitiveSemanticTokensResolveInDarkAndLightThemes() {
        let themes = [
            AmbitionTheme.theme(for: .dark, accentFamily: .sage),
            AmbitionTheme.theme(for: .light, accentFamily: .sage)
        ]

        for theme in themes {
            for token in AmbitionPrimitiveSemanticToken.allCases {
                XCTAssertFalse(String(describing: token.color(in: theme)).isEmpty)
            }
        }
    }
}
