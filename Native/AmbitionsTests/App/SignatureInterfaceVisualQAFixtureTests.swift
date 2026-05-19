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
            XCTAssertFalse(fixture.nonColorNote.isEmpty)
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

    func testSI16SurfaceCoverageRowsMapTheFiveTopLevelSurfaces() {
        XCTAssertEqual(SI16PreviewFixtureCatalog.canonicalTopLevelSurfaces, ["Today", "Goals", "Capture", "Time", "You"])
        XCTAssertEqual(
            SI16PreviewFixtureCatalog.surfaceCoverageRows.map(\.ownerSurface),
            SI16PreviewFixtureCatalog.canonicalTopLevelSurfaces
        )

        for row in SI16PreviewFixtureCatalog.surfaceCoverageRows {
            XCTAssertFalse(row.primaryObject.isEmpty)
            XCTAssertFalse(row.accessibilityNote.isEmpty)
            XCTAssertFalse(row.nonColorNote.isEmpty)
            XCTAssertFalse(row.fixtureIDs.isEmpty)
            XCTAssertFalse(row.fixtures.isEmpty)
            XCTAssertEqual(
                row.fixtureIDs.count,
                row.fixtures.count,
                "Unresolved fixture IDs for \(row.ownerSurface): \(Set(row.fixtureIDs).subtracting(row.fixtures.map(\.id)))"
            )
            for fixture in row.fixtures {
                XCTAssertEqual(fixture.ownerSurface, row.ownerSurface)
                XCTAssertFalse(fixture.nonColorNote.isEmpty)
            }
        }
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

    func testAFI13VisualQAScorecardsLockActiveSurfaceTargetsWithoutClaims() {
        XCTAssertEqual(AFI13VisualQACatalog.ownerBatch, "AFI13")
        XCTAssertEqual(
            AFI13VisualQACatalog.activeTopLevelSurfaces,
            ["Today", "Goals", "Capture", "Time", "You"]
        )
        XCTAssertFalse(AFI13VisualQACatalog.containsPlanTopLevelSurface)
        XCTAssertFalse(AFI13VisualQACatalog.changesRuntimeBehavior)
        XCTAssertFalse(AFI13VisualQACatalog.claimsRenderedScreenshotProof)
        XCTAssertFalse(AFI13VisualQACatalog.claimsHumanVisualApproval)
        XCTAssertFalse(AFI13VisualQACatalog.claimsDeviceProof)
        XCTAssertFalse(AFI13VisualQACatalog.claimsAccessibilityConformance)

        XCTAssertEqual(
            AFI13VisualQACatalog.scorecards.map(\.surface),
            AFI13VisualQACatalog.activeTopLevelSurfaces
        )
        XCTAssertEqual(
            Set(AFI13VisualQACatalog.missingGreenProofSurfaces),
            Set(AFI13VisualQACatalog.activeTopLevelSurfaces)
        )

        for entry in AFI13VisualQACatalog.scorecards {
            XCTAssertGreaterThanOrEqual(entry.minimumScore, 95)
            XCTAssertGreaterThanOrEqual(entry.targetScore, entry.minimumScore)
            if entry.surface == "Today" || entry.surface == "Capture" {
                XCTAssertEqual(entry.targetScore, 98)
            }
            XCTAssertFalse(entry.requiredRenderedInventory.isEmpty)
            XCTAssertFalse(entry.hardRedDriftExamples.isEmpty)
            XCTAssertEqual(entry.status, "Yellow")
            XCTAssertTrue(entry.isBlockedFromGreen)
            XCTAssertFalse(entry.hasRenderedScreenshotProof)
            XCTAssertFalse(entry.primaryObject.localizedCaseInsensitiveContains("Plan"))
        }
    }

    func testAFI13VisualDriftGalleryCarriesPassAndFailExamples() {
        let categories = Set(AFI13VisualQACatalog.driftGallery.map(\.category))
        let required: Set<String> = [
            "Native shell",
            "Celestial Field",
            "Graphite Recess",
            "Luminous Trace",
            "Quiet Glass",
            "Today",
            "Goals",
            "Capture",
            "Time",
            "You",
            "Trust",
            "Continuity Dock"
        ]

        XCTAssertTrue(required.isSubset(of: categories), "Missing categories: \(required.subtracting(categories))")

        for example in AFI13VisualQACatalog.driftGallery {
            XCTAssertFalse(example.passPattern.isEmpty)
            XCTAssertFalse(example.failPattern.isEmpty)
            XCTAssertTrue(example.redLabel == "Yellow: adjacent drift" || example.redLabel.hasPrefix("Red: "))
            XCTAssertFalse(example.passPattern.localizedCaseInsensitiveContains("dashboard"))
            XCTAssertFalse(example.passPattern.localizedCaseInsensitiveContains("chatbot"))
        }
    }
}
