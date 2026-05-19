import AmbitionsDesignSystem
import XCTest

final class TopLevelSurfaceCompositionTests: XCTestCase {
    func testSI17CompositionKeepsFiveCanonicalSurfacesOnly() {
        XCTAssertEqual(
            AmbitionsTopLevelSurfaceComposition.allCases,
            [.today, .goals, .capture, .time, .you]
        )

        XCTAssertEqual(
            AmbitionsTopLevelSurfaceComposition.allCases.map(\.title),
            ["Today", "Goals", "Capture", "Time", "You"]
        )
    }

    func testSI17EachSurfaceHasOnePrimaryObjectAndSubordinateModules() {
        for surface in AmbitionsTopLevelSurfaceComposition.allCases {
            XCTAssertFalse(surface.primaryObject.isEmpty)
            XCTAssertFalse(surface.primaryObject.contains(" + "))
            XCTAssertFalse(surface.orientation.isEmpty)
            XCTAssertEqual(surface.supportingModules.count, 3)
            XCTAssertTrue(surface.accessibilitySummary.contains(surface.title))
            XCTAssertTrue(surface.accessibilitySummary.contains(surface.primaryObject))
        }

        XCTAssertEqual(AmbitionsTopLevelSurfaceComposition.goals.primaryObject, "Constellation Atlas")
        XCTAssertTrue(AmbitionsTopLevelSurfaceComposition.goals.supportingModules.contains("Orbital Lens"))
    }

    func testSI17CompositionAvoidsGenericSurfaceDrift() {
        let combined = AmbitionsTopLevelSurfaceComposition.allCases
            .map { "\($0.title) \($0.primaryObject) \($0.orientation) \($0.supportingModules.joined(separator: " "))" }
            .joined(separator: " ")

        XCTAssertFalse(combined.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("chatbot"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("project-management"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("sixth destination"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("hosted " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("production " + "AI"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("backend " + "sync"))
        XCTAssertFalse(combined.localizedCaseInsensitiveContains("release " + "ready"))
    }

    func testSI17SurfaceLensesAndStatusExposeNonColorMeaning() {
        for surface in AmbitionsTopLevelSurfaceComposition.allCases {
            XCTAssertFalse(surface.lens.title.isEmpty)
            XCTAssertFalse(surface.lens.systemImage.isEmpty)
            XCTAssertFalse(surface.ambientStatus.title.isEmpty)
            XCTAssertFalse(surface.ambientStatus.systemImage.isEmpty)
        }
    }

    func testAFI14CoherenceCatalogLocksProductGrammarAndSurfaceFamily() {
        XCTAssertEqual(AFI14CrossSurfaceCoherenceCatalog.ownerBatch, "AFI14")
        XCTAssertEqual(
            AFI14CrossSurfaceCoherenceCatalog.activeTopLevelSurfaces,
            ["Today", "Goals", "Capture", "Time", "You"]
        )
        XCTAssertEqual(
            AFI14CrossSurfaceCoherenceCatalog.productGrammar,
            ["Capture", "Clarify", "Shape", "Start", "Close", "Remember"]
        )
        XCTAssertFalse(AFI14CrossSurfaceCoherenceCatalog.activeTopLevelSurfaces.contains("Plan"))
        XCTAssertFalse(AFI14CrossSurfaceCoherenceCatalog.changesRuntimeBehavior)
        XCTAssertFalse(AFI14CrossSurfaceCoherenceCatalog.claimsRenderedProof)
        XCTAssertFalse(AFI14CrossSurfaceCoherenceCatalog.claimsHumanApproval)
        XCTAssertFalse(AFI14CrossSurfaceCoherenceCatalog.claimsReleaseReadiness)
        XCTAssertEqual(AFI14CrossSurfaceCoherenceCatalog.missingStageSurfaces, [])
        XCTAssertFalse(AFI14CrossSurfaceCoherenceCatalog.disconnectedOneOffRisk)
    }

    func testAFI14CoherenceStagesPreservePromiseLadderAndTrustRoutes() {
        let stages = AFI14CrossSurfaceCoherenceCatalog.stages
        XCTAssertEqual(stages.map(\.verb), AFI14CrossSurfaceCoherenceCatalog.productGrammar)
        XCTAssertEqual(stages.map(\.promise), [
            "Capture anything.",
            "Give it a place.",
            "Shape your time around what matters.",
            "Start where reality allows.",
            "Close the loop without shame.",
            "Trust what changed."
        ])

        for stage in stages {
            XCTAssertFalse(stage.ownerSurfaces.isEmpty)
            XCTAssertFalse(stage.evidenceObject.isEmpty)
            XCTAssertFalse(stage.evidenceObject.localizedCaseInsensitiveContains("dashboard"))
            XCTAssertFalse(stage.evidenceObject.localizedCaseInsensitiveContains("chatbot"))
        }

        let handoffs = AFI14CrossSurfaceCoherenceCatalog.handoffs
        XCTAssertGreaterThanOrEqual(handoffs.count, 9)
        XCTAssertTrue(handoffs.contains { $0.fromSurface == "Capture" && $0.toSurface == "Goals" })
        XCTAssertTrue(handoffs.contains { $0.fromSurface == "Time" && $0.toSurface == "Today" })
        XCTAssertTrue(handoffs.contains { $0.fromSurface == "Today" && $0.toSurface == "Goals" })
        XCTAssertTrue(handoffs.contains { $0.fromSurface == "Any" && $0.toSurface == "You" })

        for handoff in handoffs {
            XCTAssertFalse(handoff.thread.isEmpty)
            XCTAssertFalse(handoff.trustRoute.isEmpty)
            XCTAssertFalse(handoff.thread.localizedCaseInsensitiveContains("silent automation"))
            XCTAssertFalse(handoff.trustRoute.localizedCaseInsensitiveContains("hidden"))
        }
    }
}
