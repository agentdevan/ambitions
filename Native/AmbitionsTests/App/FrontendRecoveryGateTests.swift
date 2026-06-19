import XCTest
@testable import Ambitions

final class FrontendRecoveryGateTests: XCTestCase {
    func testIR01TopLevelTabsStayOnActiveCanon() {
        XCTAssertEqual(AppTab.allCases.map(\.title), ["Today", "Goals", "Time", "You"])
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Plan"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Capture"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Pulse"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Profile"))
        XCTAssertFalse(AppTab.allCases.map(\.title).contains("Captures"))
    }

    func testIR01VisibleRecoveryCopyAvoidsObsoleteRootLabelsAndConfidenceTheater() throws {
        let checkedFiles = [
            "Native/Ambitions/Surfaces/Today/TodayScreen.swift",
            "Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift",
            "Native/Ambitions/Surfaces/Goals/GoalsScreen.swift",
            "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            "Native/Ambitions/Surfaces/You/YouRootSurface.swift"
        ]

        for relativePath in checkedFiles {
            let contents = try String(contentsOfFile: repoRoot.appendingPathComponent(relativePath).path)
            XCTAssertFalse(contents.contains("Label(\"Profile\""), relativePath)
            XCTAssertFalse(contents.contains("Plan " + "tab"), relativePath)
            XCTAssertFalse(contents.contains("Profile " + "tab"), relativePath)
            XCTAssertFalse(contents.contains("AI " + "recommends"), relativePath)
            XCTAssertFalse(contents.contains("best next " + "move"), relativePath)
            XCTAssertFalse(contents.contains("Suggested Route Alignment"), relativePath)
            XCTAssertFalse(contents.contains("TrustSeamExplainer("), relativePath)
            XCTAssertFalse(contents.contains("Text(\"Dashboard\""), relativePath)
            XCTAssertFalse(contents.contains("Label(\"Dashboard\""), relativePath)
            XCTAssertFalse(contents.contains("Text(\"Chat" + "bot\""), relativePath)
            XCTAssertFalse(contents.contains("Label(\"Chat" + "bot\""), relativePath)
            XCTAssertFalse(contents.contains("Text(\"AI " + "confidence\""), relativePath)
            XCTAssertFalse(contents.contains("Label(\"AI " + "confidence\""), relativePath)
        }
    }

    func testIR01RecoveredSurfacesExposeCanonObjectIdentifiers() throws {
        let expectations: [(String, String)] = [
            ("Native/Ambitions/Surfaces/Today/TodayScreen.swift", "TodayRealityMeridianFlagshipAdapter"),
            ("Native/Ambitions/DesignSystem/ProductObjects/TodayDayRailPanels.swift", "RealityMeridianView"),
            ("Native/Ambitions/Surfaces/Today/TodayScreen.swift", "TodayExecutionDepthDisclosure"),
            ("Native/Ambitions/Surfaces/Goals/GoalsScreen.swift", "GoalsDirectionDepthDisclosure"),
            ("Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift", "AtmosphereComposerCanvas"),
            ("Native/Ambitions/Composer/Capture/CaptureComposerSurface.swift", "CaptureDepthDisclosure"),
            ("Native/Ambitions/Surfaces/Time/TimeSurface.swift", "TimeObjectView"),
            ("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift", "LifeShapeFieldView"),
            ("Native/Ambitions/Surfaces/You/YouRootSurface.swift", "User System Profile")
        ]

        for (relativePath, needle) in expectations {
            let contents = try String(contentsOfFile: repoRoot.appendingPathComponent(relativePath).path)
            XCTAssertTrue(contents.contains(needle), "\(relativePath) should contain \(needle)")
        }
    }

    func testIR01TopLevelRecoveryCopyStaysOnActiveCanon() throws {
        let filePaths = [
            "Native/Ambitions/Surfaces/Goals/GoalsScreen.swift",
            "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            "Native/Ambitions/Surfaces/You/YouRootSurface.swift",
            "Sources/Components/TopLevelSurfaceCompositionPrimitives.swift"
        ]

        let contents = try filePaths
            .map { try String(contentsOfFile: repoRoot.appendingPathComponent($0).path) }
            .joined(separator: "\n")

        XCTAssertFalse(contents.localizedCaseInsensitiveContains("plan " + "tab"))
        XCTAssertFalse(contents.localizedCaseInsensitiveContains("profile " + "tab"))
        XCTAssertFalse(contents.localizedCaseInsensitiveContains("mission control"))
        XCTAssertFalse(contents.contains("Text(\"Dashboard\""))
        XCTAssertFalse(contents.contains("Label(\"Dashboard\""))
        XCTAssertFalse(contents.localizedCaseInsensitiveContains("chat" + "bot"))
        XCTAssertFalse(contents.localizedCaseInsensitiveContains("AI " + "confidence"))
    }

    var repoRoot: URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.lastPathComponent != "ambitions", url.path != "/" {
            url.deleteLastPathComponent()
        }
        return url
    }
}
