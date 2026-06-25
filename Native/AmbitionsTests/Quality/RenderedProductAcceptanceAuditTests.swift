@testable import Ambitions
import XCTest

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

    func testProductObjectDominanceAuditRejectsRadialGaugePrimaryObject() {
        let radial = LifeShapeSourceFile(
            path: "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift",
            contents: """
            struct LifeShapeFieldVisualField {
                var body: some View { LifeShapeArcShape(start: .degrees(0), end: .degrees(90)) }
                var orbitalRings: some View { Text("rings") }
                var layerBandSpecs: [String] { [] }
            }
            """
        )

        let report = ProductObjectDominanceAudit.auditTimeRootComposition([radial])

        XCTAssertTrue(report.containsFinding("dominance.radial-gauge-primary-object"))
    }

    func testProductObjectDominanceAuditRejectsRootArchitectureScreens() {
        let files = [
            LifeShapeSourceFile(
                path: "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
                contents: "LazyVGrid { LifeAreaRegionButton() }"
            ),
            LifeShapeSourceFile(
                path: "Native/Ambitions/Surfaces/You/YouRootSurface.swift",
                contents: "struct PersonalSystemCenterRootView { YouPersonalSystemNavigation(sections: []) }"
            ),
            LifeShapeSourceFile(
                path: "Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift",
                contents: "self.projection = projection ?? .objectConsequence(renderState: .launchArgument)"
            ),
            LifeShapeSourceFile(
                path: "Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift",
                contents: "CaptureObjectView(); func saveCapture() {}"
            ),
        ]

        let report = ProductObjectDominanceAudit.auditRootObjectComposition(files)

        XCTAssertTrue(report.containsFinding("dominance.goals-card-grid-root"))
        XCTAssertTrue(report.containsFinding("dominance.you-governance-root"))
        XCTAssertTrue(report.containsFinding("dominance.motion-production-fixture-fallback"))
        XCTAssertTrue(report.containsFinding("dominance.capture-quick-sheet-composer"))
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

    func testRootReportPanelAuditRejectsArchitectureAsRootObjects() {
        let files = [
            LifeShapeSourceFile(
                path: "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
                contents: "LazyVGrid { RoundedRectangle(cornerRadius: theme.radius.lg) }"
            ),
            LifeShapeSourceFile(
                path: "Native/Ambitions/Surfaces/You/YouRootSurface.swift",
                contents: "source-settings receipts-history PersonalSystemCenterRootView"
            ),
            LifeShapeSourceFile(
                path: "Native/Ambitions/Composer/Capture/CaptureAtmosphereComposer.swift",
                contents: "isRouteRevealVisible Keyboard dictation only"
            ),
            LifeShapeSourceFile(
                path: "Native/Ambitions/Stage/Motion/StageMotionState.swift",
                contents: "objectConsequence(renderState: .launchArgument)"
            ),
        ]

        let report = RootReportPanelAudit.audit(files)

        XCTAssertTrue(report.containsFinding("report-panel.goals-dashboard-grid"))
        XCTAssertTrue(report.containsFinding("report-panel.you-governance-manual-root"))
        XCTAssertTrue(report.containsFinding("report-panel.capture-routing-taxonomy"))
        XCTAssertTrue(report.containsFinding("report-panel.motion-default-fixture-page"))
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
            Text("open layer")
            Text("This week shows 7 open days.")
            Text("Free time shows where action may fit.")
            """
        )

        let report = UserLanguageCategoryAudit.auditRootStrings([jargon])

        XCTAssertTrue(report.containsFinding("user-language-category.ridge"))
        XCTAssertTrue(report.containsFinding("user-language-category.lane"))
        XCTAssertTrue(report.containsFinding("user-language-category.pocket"))
        XCTAssertTrue(report.containsFinding("user-language-category.open-layer"))
        XCTAssertTrue(report.containsFinding("user-language-category.this-week-shows"))
        XCTAssertTrue(report.containsFinding("user-language-category.free-time-shows"))
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
            "docs/design/red_fixtures/time/current_failed_lifeshape_field.md",
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

    func testCurrentRootObjectImplementationPassesRenderedProductAcceptanceAudits() throws {
        let files = try currentRootObjectAcceptanceFiles()

        let singleOwnerReport = SingleOwnerAudit.audit(files)
        XCTAssertTrue(singleOwnerReport.passed, failureMessage(for: singleOwnerReport))

        let dominanceReport = ProductObjectDominanceAudit.auditRootObjectComposition(files)
        XCTAssertTrue(dominanceReport.passed, failureMessage(for: dominanceReport))

        let reportPanelReport = RootReportPanelAudit.audit(files)
        XCTAssertTrue(reportPanelReport.passed, failureMessage(for: reportPanelReport))

        let projectionTruthReport = ProjectionTruthAudit.audit(files)
        XCTAssertTrue(projectionTruthReport.passed, failureMessage(for: projectionTruthReport))

        let languageReport = UserLanguageCategoryAudit.auditRootStrings(files)
        XCTAssertTrue(languageReport.passed, failureMessage(for: languageReport))
    }

    private func failureMessage(for report: LifeShapeAuditReport) -> String {
        report.findings
            .map { "\($0.id) \($0.path): \($0.detail)" }
            .joined(separator: "\n")
    }

    private func currentRootObjectAcceptanceFiles() throws -> [LifeShapeSourceFile] {
        let root = repoRoot()
        let paths = [
            "Native/Ambitions/App/AmbitionsRootStageSurfaceHost.swift",
            "Native/Ambitions/App/AppShellActivatedCaptureSeam.swift",
            "Native/Ambitions/Composer/Capture/CaptureAtmosphereComposer.swift",
            "Native/Ambitions/Composer/Capture/CaptureObjectView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldCanvas.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualField.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldVisualFieldSupport.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldModels.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/MotionCurrentFieldView.swift",
            "Native/Ambitions/DesignSystem/ProductObjects/MotionCurrentLaneViews.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeFieldProjection.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeSemanticProjection.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeModels.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeSuiteState.swift",
            "Native/Ambitions/Projection/SurfaceLenses/TimeLifeShapeDrillDownProjection.swift",
            "Native/Ambitions/Stage/Chrome/StageDockRail.swift",
            "Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift",
            "Native/Ambitions/Stage/Motion/StageMotionState.swift",
            "Native/Ambitions/Stage/Overlays/QuietCommandCaptureOverlay.swift",
            "Native/Ambitions/Surfaces/Goals/GoalsObjectView.swift",
            "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            "Native/Ambitions/Surfaces/Time/TimeObjectView.swift",
            "Native/Ambitions/Surfaces/Time/WeeklyReviewScreen.swift",
            "Native/Ambitions/Surfaces/You/YouObjectView.swift",
            "Native/Ambitions/Surfaces/You/YouRootSurface.swift",
        ]

        return try paths.map { path in
            try LifeShapeSourceFile(
                path: path,
                contents: String(contentsOf: root.appendingPathComponent(path), encoding: .utf8)
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
