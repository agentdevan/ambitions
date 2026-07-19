@testable import Ambitions
import XCTest

final class RealDeviceRenderChecklistTests: XCTestCase {
    func testCanonicalRealDeviceRenderChecklistExistsAndValidates() {
        let root = repoRoot()
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: root.appendingPathComponent("Native/Ambitions/Quality/RealDeviceRenderChecklist.swift").path
            )
        )

        XCTAssertEqual(RealDeviceRenderChecklist.validationFailures(), [])
        XCTAssertEqual(
            Set(RealDeviceRenderChecklist.items.map(\.requirement)),
            Set(RealDeviceRenderChecklistItem.Requirement.allCases)
        )
    }

    func testChecklistRoutesThroughExistingQualityOwners() {
        XCTAssertEqual(
            VisualRegressionHarness.realDeviceChecklist,
            RealDeviceRenderChecklist.items
        )
        XCTAssertTrue(
            RealDeviceRenderChecklist.items.contains {
                $0.owner == "DesignSystem/Accessibility/VoiceOverFocusPolicy" &&
                    $0.proofRequirement.contains("VoiceOver")
            }
        )
        XCTAssertTrue(
            RealDeviceRenderChecklist.items.contains {
                $0.owner == "Quality/PerformanceBudgets" &&
                    $0.proofRequirement.contains("budgets")
            }
        )
        XCTAssertTrue(RealDeviceRenderChecklist.items.allSatisfy(\.blocksGreen))
    }
}

private extension RealDeviceRenderChecklistTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Quality")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
