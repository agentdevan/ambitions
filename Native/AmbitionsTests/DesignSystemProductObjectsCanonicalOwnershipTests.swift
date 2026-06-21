@testable import Ambitions
import XCTest

final class DesignSystemProductObjectsCanonicalOwnershipTests: XCTestCase {
    func testCanonicalProductObjectFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/DesignSystem/ProductObjects/RealityMeridianView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/StartHereToken.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/ConstellationNode.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/AtmosphereComposerField.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/MotionCurrentView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/ProofStitchView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/RecoveryBand.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/UserSystemProfileView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/NativeSettingsGroup.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/NativeSettingsRow.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical product object owner: \(requiredPath)"
            )
        }
    }

    func testRealityMeridianOwnershipMovedToCanonicalFile() throws {
        let root = repoRoot()
        let canonical = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/RealityMeridianView.swift"),
            encoding: .utf8
        )
        let oldFile = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(canonical.contains("struct RealityMeridianView"))
        XCTAssertFalse(oldFile.contains("struct RealityMeridianView"))
    }

    func testTodayStartHereUsesCanonicalToken() throws {
        let root = repoRoot()
        let source = try String(
            contentsOf: root.appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects/TodayStartHereSurface.swift"),
            encoding: .utf8
        )

        XCTAssertTrue(source.contains("StartHereToken()"))
    }
}

private extension DesignSystemProductObjectsCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/DesignSystem/ProductObjects")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
