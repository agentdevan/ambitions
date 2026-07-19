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

    func testEdgeBackSwipeGrammarIsDrilldownOnlyAndRejectsNonBackDrags() {
        XCTAssertTrue(SurfaceGestureMap.edgeBackSwipeGrammar.isCanonSafe)
        XCTAssertTrue(DirectManipulationPolicy.isAllowed(SurfaceGestureMap.edgeBackSwipeGrammar))
        XCTAssertEqual(SurfaceGestureMap.edgeBackSwipeGrammar.semanticAction, "Back")
        XCTAssertEqual(SurfaceGestureMap.edgeBackSwipeGrammar.accessibilityAlternative, "Back button")

        XCTAssertTrue(SurfaceGestureMap.isEdgeBackSwipe(
            startDistanceFromLeadingEdge: 18,
            horizontalTranslation: 96,
            verticalTranslation: 12,
            screenWidth: 393
        ))
        XCTAssertFalse(SurfaceGestureMap.isEdgeBackSwipe(
            startDistanceFromLeadingEdge: 92,
            horizontalTranslation: 120,
            verticalTranslation: 8,
            screenWidth: 393
        ))
        XCTAssertFalse(SurfaceGestureMap.isEdgeBackSwipe(
            startDistanceFromLeadingEdge: 18,
            horizontalTranslation: 52,
            verticalTranslation: 6,
            screenWidth: 393
        ))
        XCTAssertFalse(SurfaceGestureMap.isEdgeBackSwipe(
            startDistanceFromLeadingEdge: 18,
            horizontalTranslation: 100,
            verticalTranslation: 88,
            screenWidth: 393
        ))
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
