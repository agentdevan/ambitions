@testable import Ambitions
import XCTest

final class InteractionCanonicalOwnershipTests: XCTestCase {
    func testCanonicalInteractionOwnerFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Interaction/GestureGrammar.swift",
            "Native/Ambitions/Interaction/DirectManipulationPolicy.swift",
            "Native/Ambitions/Interaction/SurfaceGestureMap.swift",
            "Native/Ambitions/Interaction/KeyboardPolicy.swift",
            "Native/Ambitions/Interaction/HapticPolicy.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical Interaction owner: \(requiredPath)"
            )
        }
    }

    func testSurfaceGestureMapCoversOnlyPersistentRootSurfaces() {
        XCTAssertEqual(SurfaceGestureMap.validationIssues(), [])
        XCTAssertEqual(StageMutationTargetSurface.allCases, [.today, .goals, .time, .you])

        for surface in StageMutationTargetSurface.allCases {
            let grammar = SurfaceGestureMap.primaryGrammar(for: surface)
            XCTAssertTrue(grammar.isCanonSafe)
            XCTAssertTrue(DirectManipulationPolicy.isAllowed(grammar))
            XCTAssertFalse(KeyboardPolicy.primaryShortcut(for: surface).accessibilityLabel.isEmpty)
        }
    }

    func testTodayCommandHandlerUsesCanonicalInteractionGestureMap() {
        XCTAssertTrue(SurfaceGestureMap.todayCommandCapableKinds.contains(.complete))
        XCTAssertTrue(SurfaceGestureMap.todayCommandCapableKinds.contains(.quickLog))
        XCTAssertFalse(SurfaceGestureMap.todayCommandCapableKinds.contains(.openDetail))
        XCTAssertEqual(HapticPolicy.intent(for: .complete), .confirmation)
        XCTAssertEqual(HapticPolicy.intent(for: .askForHelp), .warning)
    }
}

private extension InteractionCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Interaction")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
