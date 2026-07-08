@testable import Ambitions
import AmbitionsDesignSystem
import SwiftUI
import XCTest

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

    func testAppearancePreferenceUsesDesignSystemThemePreferenceBridge() {
        XCTAssertEqual(AppAppearancePreference.system.themePreference, .system)
        XCTAssertEqual(AppAppearancePreference.light.themePreference, .light)
        XCTAssertEqual(AppAppearancePreference.dark.themePreference, .dark)
        XCTAssertEqual(AmbitionThemePreference.system.resolvedMode(systemMode: .dark), .dark)
        XCTAssertEqual(AmbitionThemePreference.system.resolvedMode(systemMode: .light), .light)
        XCTAssertEqual(AmbitionThemePreference.light.resolvedMode(systemMode: .dark), .light)
        XCTAssertEqual(AmbitionThemePreference.dark.resolvedMode(systemMode: .light), .dark)
    }

    @MainActor
    func testDebugLaunchConfigurationAcceptsAppearancePreferenceForScreenshotProof() {
        #if DEBUG
            let configuration = AppBootstrapper().debugLaunchConfiguration(
                arguments: [
                    "Ambitions",
                    "-AmbitionsInitialSurface", "time",
                    "-AmbitionsScreenshotMode", "YES",
                    "-AmbitionsAppearancePreference", "light",
                    "-AmbitionsSystemAppearance", "dark"
                ]
            )

            XCTAssertTrue(configuration.screenshotModeEnabled)
            XCTAssertEqual(configuration.initialSurface, .time)
            XCTAssertEqual(configuration.appearancePreference, .light)
            XCTAssertEqual(configuration.systemThemeModeOverride, .dark)
        #endif
    }

    func testYouAppearanceDetailAppliesEditorChangesLiveBeforePersistenceSave() throws {
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Surfaces/You/YouRootDetailRouteSurface.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("applyAppearancePreviewFromEditor()"))
        XCTAssertTrue(source.contains(".onChange(of: viewModel.appearancePreference)"))
        XCTAssertTrue(source.contains(".onChange(of: viewModel.accentFamily)"))
        XCTAssertTrue(source.contains("userSystem.applyAppearancePreference("))
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
            .accessibilityContrastStroke,
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
            AmbitionTheme.theme(for: .light, accentFamily: .sage),
        ]

        for theme in themes {
            for token in AmbitionPrimitiveSemanticToken.allCases {
                XCTAssertFalse(String(describing: token.color(in: theme)).isEmpty)
            }
        }
    }
}

private extension AppearancePreferenceTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
