@testable import Ambitions
import AmbitionsDesignSystem
import SwiftUI
import XCTest

final class DesignSystemFoundationsCanonicalOwnershipTests: XCTestCase {
    func testCanonicalFoundationFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsColor.swift",
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsTypography.swift",
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsSpacing.swift",
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsMaterial.swift",
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsLighting.swift",
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsDepth.swift",
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsMotion.swift",
            "Native/Ambitions/DesignSystem/Foundations/AmbitionsHaptics.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical foundation owner: \(requiredPath)"
            )
        }
    }

    func testFoundationOwnersBridgeExistingThemeContracts() {
        let theme = AmbitionTheme.dark
        let colors = AmbitionsColor(theme: theme)
        let spacing = AmbitionsSpacing(theme: theme)
        let haptics = AmbitionsHaptics(theme: theme)

        XCTAssertEqual(AmbitionsColor.rootSurfaceRoles.count, 7)
        XCTAssertEqual(spacing.minimumTapTarget, theme.panel.minimumTapTarget)
        XCTAssertEqual(spacing.actionWidth(dynamicTypeIsAccessibilitySize: false), 220)
        XCTAssertNil(spacing.actionWidth(dynamicTypeIsAccessibilitySize: true))
        XCTAssertEqual(haptics.primaryActionIntent, theme.haptics.routeChange)
        XCTAssertTrue(haptics.userInitiatedOnly)
        XCTAssertEqual(AmbitionsHaptics.boundary, "Feedback follows explicit user action and never communicates pressure.")
        XCTAssertTrue(AmbitionsColor.rootSurfaceRoles.contains("startHereAccent"))
        _ = colors.startHereAccent
    }

    func testStartHereSurfaceUsesCanonicalFoundationOwners() throws {
        let root = repoRoot()
        let source = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift"),
            encoding: .utf8
        )

        for owner in [
            "AmbitionsColor",
            "AmbitionsTypography",
            "AmbitionsSpacing",
            "AmbitionsMaterial",
            "AmbitionsLighting",
            "AmbitionsDepth",
            "AmbitionsMotion",
        ] {
            XCTAssertTrue(source.contains(owner), "StartHereSurface must consume \(owner)")
        }
    }

    func testPrimaryActionButtonUsesCanonicalHapticOwner() throws {
        let root = repoRoot()
        let source = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/TodayPanels+06-TodayPrimaryActionButton.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("AmbitionsHaptics"))
        XCTAssertTrue(source.contains(".ambitionHaptic"))
    }
}

private extension DesignSystemFoundationsCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/DesignSystem/Foundations")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
