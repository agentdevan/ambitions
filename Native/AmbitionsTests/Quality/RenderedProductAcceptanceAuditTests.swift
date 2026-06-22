import XCTest
@testable import Ambitions

final class RenderedProductAcceptanceAuditTests: XCTestCase {
    func testSingleOwnerAuditRejectsDuplicateTimeCrown() {
        let shell = LifeShapeSourceFile(
            path: "Native/Ambitions/Stage/AppShellScaffold.swift",
            contents: "AppShellScaffold(title: \"Time\", subtitle: \"LifeShape Field\")"
        )
        let object = LifeShapeSourceFile(
            path: "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift",
            contents: "var contextCrown: some View { Text(\"Time\") }"
        )

        let report = SingleOwnerAudit.audit([shell, object])

        XCTAssertTrue(report.containsFinding("single-owner.duplicate-time-crown"))
    }

    func testProductObjectDominanceAuditRejectsStackedTimeRoot() {
        let stacked = LifeShapeSourceFile(
            path: "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift",
            contents: """
            var body: some View {
                VStack {
                    contextCrown
                    LifeShapeLayerSelector(selection: $selectedLayer)
                    LifeShapeNowInstrument()
                    objectCanvas
                    LifeShapeBucketDetail()
                }
            }
            """
        )

        let report = ProductObjectDominanceAudit.auditTimeRootComposition([stacked])

        XCTAssertTrue(report.containsFinding("dominance.crown-before-primary-object"))
        XCTAssertTrue(report.containsFinding("dominance.selector-sibling-before-object"))
        XCTAssertTrue(report.containsFinding("dominance.now-instrument-sibling"))
        XCTAssertTrue(report.containsFinding("dominance.detail-root-sibling"))
    }

    func testRootReportPanelAuditRejectsLifeShapeNowReportPanel() {
        let reportPanel = LifeShapeSourceFile(
            path: "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeNowInstrument.swift",
            contents: """
            struct LifeShapeNowInstrument {
                Text(reading.capacityStatement)
                let primaryActionTitle = "Place Step"
            }
            """
        )

        let report = RootReportPanelAudit.audit([reportPanel])

        XCTAssertTrue(report.containsFinding("report-panel.lifeshape-now-instrument"))
        XCTAssertTrue(report.containsFinding("report-panel.capacity-copy-with-cta"))
    }

    func testProjectionTruthAuditRejectsFabricatedMinimumCounts() {
        let projection = LifeShapeSourceFile(
            path: "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeFieldProjection.swift",
            contents: """
            let focusedBlockCount = max(activeGoalCount, 1)
            let lightStepCount = max(openDays, 1)
            """
        )

        let report = ProjectionTruthAudit.audit([projection])

        XCTAssertEqual(
            report.findings.filter { $0.id == "projection-truth.fabricated-minimum-count" }.count,
            2
        )
    }

    func testUserLanguageCategoryAuditRejectsRootJargon() {
        let jargon = LifeShapeSourceFile(
            path: "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift",
            contents: """
            Text("Compression ridge")
            Text("Execution lane")
            Text("Protected pocket")
            """
        )

        let report = UserLanguageCategoryAudit.auditRootStrings([jargon])

        XCTAssertTrue(report.containsFinding("user-language-category.ridge"))
        XCTAssertTrue(report.containsFinding("user-language-category.lane"))
        XCTAssertTrue(report.containsFinding("user-language-category.pocket"))
    }

    func testTestStrengthAuditRejectsSourceOnlyVisualProof() {
        let test = LifeShapeSourceFile(
            path: "Native/AmbitionsTests/Time/LifeShapeFieldViewReconstructionTests.swift",
            contents: """
            func testFirstClassVisualField() throws {
                let source = try source("LifeShapeFieldView.swift")
                XCTAssertTrue(source.contains("LifeShapeField"))
            }
            """
        )

        let report = TestStrengthAudit.audit([test])

        XCTAssertTrue(report.containsFinding("test-strength.source-only-visual-proof"))
    }

    func testVisualTargetArtifactAuditRequiresTargetAndRedFixture() {
        let report = VisualTargetArtifactAudit.audit(paths: [
            "docs/design/targets/time/lifeshape_field_visual_target.md",
            "docs/design/targets/time/lifeshape_field_acceptance_rubric.md",
            "docs/design/red_fixtures/time/current_failed_lifeshape_field.png",
            "docs/design/red_fixtures/time/current_failed_lifeshape_field.md"
        ])

        XCTAssertTrue(report.passed)
    }

    func testDeviceEvidenceAuditRejectsVisualGreenWithoutPhysicalDeviceProof() {
        let closeout = LifeShapeSourceFile(
            path: "docs/validation/amb_1176_closeout.md",
            contents: "Status: Visual Green\nDevice proof: simulator screenshot"
        )

        let report = DeviceEvidenceAudit.auditCloseout(closeout)

        XCTAssertTrue(report.containsFinding("device-evidence.missing-for-green"))
    }

    func testCurrentTimeLifeShapeImplementationPassesRenderedProductAcceptanceAudits() throws {
        let files = try currentTimeAcceptanceFiles()

        XCTAssertTrue(SingleOwnerAudit.audit(files).passed)
        XCTAssertTrue(ProductObjectDominanceAudit.auditTimeRootComposition(files).passed)
        XCTAssertTrue(RootReportPanelAudit.audit(files).passed)
        XCTAssertTrue(ProjectionTruthAudit.audit(files).passed)
        XCTAssertTrue(UserLanguageCategoryAudit.auditRootStrings(files).passed)
    }

    private func currentTimeAcceptanceFiles() throws -> [LifeShapeSourceFile] {
        let root = repoRoot()
        let paths = [
            "Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldCanvas.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualFieldSupport.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldModels.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeFieldProjection.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeSemanticProjection.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeModels.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeSuiteState.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeDrillDownProjection.swift",
            "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            "Native/Ambitions/Surfaces/Time/TimeObjectView.swift",
            "Native/Ambitions/Surfaces/Time/WeeklyReviewScreen.swift"
        ]

        return try paths.map { path in
            LifeShapeSourceFile(
                path: path,
                contents: try String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
            )
        }
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
