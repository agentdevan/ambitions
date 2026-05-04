import AmbitionsDesignSystem
import XCTest

final class SignatureInterfaceVisualQAFixtureTests: XCTestCase {
    func testSI16FixtureCatalogCoversEveryPromptStateFamily() {
        XCTAssertEqual(SI16PreviewFixtureCatalog.ownerBatch, "SI16")
        XCTAssertEqual(
            SI16PreviewFixtureCatalog.stateFamilies,
            Set(SI16VisualQAStateFamily.allCases)
        )
        XCTAssertEqual(
            SI16PreviewFixtureCatalog.fixtures.count,
            SI16VisualQAStateFamily.allCases.count
        )
    }

    func testSI16FixtureCatalogUsesDeterministicPreviewAndScreenshotNames() {
        for fixture in SI16PreviewFixtureCatalog.fixtures {
            XCTAssertTrue(fixture.previewName.hasPrefix("SI16 "))
            XCTAssertTrue(fixture.screenshotName.hasPrefix("si16-"))
            XCTAssertTrue(fixture.screenshotName.hasSuffix(".png"))
            XCTAssertFalse(fixture.primaryObject.isEmpty)
            XCTAssertFalse(fixture.accessibilityNote.isEmpty)
            XCTAssertFalse(fixture.reduceMotionNote.isEmpty)
            XCTAssertFalse(fixture.privacyNote.isEmpty)
        }

        XCTAssertEqual(
            Set(SI16PreviewFixtureCatalog.previewNames).count,
            SI16PreviewFixtureCatalog.fixtures.count
        )
        XCTAssertEqual(
            Set(SI16PreviewFixtureCatalog.screenshotNames).count,
            SI16PreviewFixtureCatalog.fixtures.count
        )
    }

    func testSI16FixturesStayEvidenceOnlyWithoutRuntimeOrProofClaims() {
        XCTAssertFalse(SI16PreviewFixtureCatalog.claimsHumanApproval)
        XCTAssertFalse(SI16PreviewFixtureCatalog.claimsDeviceProof)
        XCTAssertFalse(SI16PreviewFixtureCatalog.changesRuntimeBehavior)

        for fixture in SI16PreviewFixtureCatalog.fixtures {
            XCTAssertFalse(fixture.claimsHumanApproval)
            XCTAssertFalse(fixture.claimsDeviceProof)
            XCTAssertFalse(fixture.changesRuntimeBehavior)
        }
    }

    func testSI16LDIHookFixturesUseLaneVocabularyOnly() {
        let lanes = Set(SI16PreviewFixtureCatalog.ldiFixtures.compactMap(\.ldiHandlingLane))

        let requiredLanes: Set<String> = [
            "clarification_needed",
            "source_check_first",
            "source_conflict_review",
            "privacy_sensitive_plan",
            "source_stale_review",
            "local_only_private_plan",
            "unsafe_blocked",
            "professional_boundary_scaffold",
            "parked_thought"
        ]

        XCTAssertTrue(requiredLanes.isSubset(of: lanes), "Missing lanes: \(requiredLanes.subtracting(lanes))")

        let combined = SI16PreviewFixtureCatalog.ldiFixtures
            .map { "\($0.privacyNote) \($0.accessibilityNote) \($0.reduceMotionNote)" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("hosted " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("backend " + "sync"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("automatic commitment"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release " + "ready"))
    }

    func testSI16SourceFilesStayWithinAllowedOwnerFamilies() {
        for path in SI16PreviewFixtureCatalog.sourceFiles {
            XCTAssertTrue(
                path.hasPrefix("Sources/Previews/") ||
                    path.hasPrefix("Native/AmbitionsTests/"),
                "Unexpected SI16 owner path: \(path)"
            )
        }
    }
}
