import XCTest
@testable import Ambitions

final class LifeShapeAntiFakeAuditTests: XCTestCase {
    func testFixtureAuditRejectsReleasePreviewScenarioAndDemoInputs() {
        let bad = LifeShapeSourceFile(
            path: "Native/Ambitions/Quality/SnapshotMatrix.swift",
            contents: """
            enum SnapshotMatrix {
                static let states = ScenarioCatalog.requiredSurfaceStates
                let clock = PreviewClock()
                let bucket = DemoLifeShapeBucket()
            }
            #if DEBUG
            let debugClock = PreviewClock()
            #endif
            """
        )

        let report = LifeShapeFixtureAudit.auditReleaseSources([bad])

        XCTAssertTrue(report.containsFinding("fixture.scenariocatalog"))
        XCTAssertTrue(report.containsFinding("fixture.previewclock"))
        XCTAssertTrue(report.containsFinding("fixture.demolifeshapebucket"))
    }

    func testFixtureAuditIgnoresDebugOnlyPreviewInputs() {
        let debugOnly = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            contents: """
            #if DEBUG
            let clock = PreviewClock()
            let states = ScenarioCatalog.requiredSurfaceStates
            #endif
            """
        )

        XCTAssertTrue(LifeShapeFixtureAudit.auditReleaseSources([debugOnly]).passed)
    }

    func testConstructionAuditBlocksLifeShapeConstructionFromUIOwners() {
        let bad = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            contents: "let bucket = LifeShapeBucket(input: rawUIState)\nlet projection = LifeShapeProjection(bucket)"
        )
        let allowed = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/Projection/TimeLens.swift",
            contents: "let projection = LifeShapeProjection(bucket)"
        )

        let report = LifeShapeConstructionAudit.auditUIConstruction([bad, allowed])

        XCTAssertTrue(report.containsFinding("construction.lifeshapebucket"))
        XCTAssertTrue(report.containsFinding("construction.lifeshapeprojection"))
        XCTAssertFalse(report.findings.contains { $0.path.contains("TimeLens.swift") })
    }

    func testDerivationAuditRequiresInputRuleClockFallbackAndAccessibilityContract() {
        let bad = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/Projection/TimeLifeShapeModels.swift",
            contents: "struct LifeShapeFieldState { let segments: [LifeShapeSegment] }"
        )
        let good = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/Projection/TimeLifeShapeModels.swift",
            contents: """
            struct LifeShapeProjection {}
            struct LifeShapeBucket {}
            enum LifeShapeReadingKind {}
            enum LifeShapeLayer {}
            enum LifeShapeHorizon {}
            enum LifeShapeBucketBuilder {
                let inputRefs: [String]
                let ruleIDs: [String]
                let clockDerivation: String
                let fallbackState: String?
                let LifeShapeConfidence: String
                let accessibilitySummary: String
            }
            """
        )

        XCTAssertEqual(
            LifeShapeDerivationAudit.auditModelContract([bad]).findings.count,
            LifeShapeDerivationAudit.requiredContractTokens.count
        )
        XCTAssertTrue(LifeShapeDerivationAudit.auditModelContract([good]).passed)
    }

    func testFakePrecisionAuditRejectsRootTimeJargonAndScoreLanguage() {
        let bad = LifeShapeSourceFile(
            path: "Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldReflow.swift",
            contents: """
            Text("Productivity score 82%")
            Text("Runtime source receipt")
            Text("Preview changes")
            """
        )

        let report = LifeShapeFakePrecisionAudit.auditRootTimeCopy([bad])

        XCTAssertTrue(report.containsFinding("fake-precision.productivity"))
        XCTAssertTrue(report.containsFinding("fake-precision.score"))
        XCTAssertTrue(report.containsFinding("fake-precision.percent"))
        XCTAssertTrue(report.containsFinding("fake-precision.runtime"))
        XCTAssertTrue(report.containsFinding("fake-precision.source"))
        XCTAssertTrue(report.containsFinding("fake-precision.receipt"))
        XCTAssertTrue(report.containsFinding("fake-precision.preview-changes"))
        XCTAssertEqual(ForbiddenLanguageAudit.rootTimeViolation(in: "Runtime source receipt"), "runtime")
    }

    func testMutationAuditRequiresFullPrimaryActionMutationContract() {
        let bad = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            contents: """
            func handleReflowDecision(_ option: TimeReflowDecisionOptionState) {
                openGoal(option.target)
            }
            """
        )
        let good = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            contents: LifeShapeMutationAudit.requiredMutationTokens.joined(separator: "\n") + "\nTimeReflowDecisionActionKind"
        )

        let report = LifeShapeMutationAudit.auditPrimaryActionSource([bad])

        XCTAssertEqual(Set(report.findings.map(\.id)), Set([
            "mutation.missing-RuntimeMutation",
            "mutation.missing-StageMutation",
            "mutation.missing-MutationProof",
            "mutation.missing-MutationAccessibilityAnnouncement",
            "mutation.missing-MutationUndo"
        ]))
        XCTAssertTrue(LifeShapeMutationAudit.auditPrimaryActionSource([good]).passed)
    }

    func testTodayCouplingAuditRequiresSourceAndFocusedTestProof() {
        let source = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/TimeSurface.swift",
            contents: "func apply(_ action: TimeReflowDecisionActionKind) { let mutation = StageMutation.self }"
        )
        let tests = LifeShapeSourceFile(
            path: "Native/AmbitionsTests/Time/TimeMutationTests.swift",
            contents: "func testTimeMutationSavesProof() { XCTAssertTrue(true) }"
        )

        XCTAssertTrue(
            LifeShapeTodayCouplingAudit.auditMutationCouplingSource([source])
                .containsFinding("today-coupling.missing-affected-today-proof")
        )
        XCTAssertTrue(
            LifeShapeTodayCouplingAudit.auditFocusedTests([tests])
                .containsFinding("today-coupling.missing-focused-test")
        )
    }

    func testSemanticAuditRequiresDerivationAndAccessibilityMeaning() {
        let bad = LifeShapeSourceFile(
            path: "Native/Ambitions/Surfaces/Time/Projection/TimeLifeShapeModels.swift",
            contents: "struct LifeShapeSemanticMark { let semanticMeaning: String }"
        )

        let report = LifeShapeSemanticAudit.auditSemanticMarkContract([bad])

        XCTAssertTrue(report.containsFinding("semantic.missing-accessibilitySummary"))
        XCTAssertTrue(report.containsFinding("semantic.missing-inputRefs"))
        XCTAssertTrue(report.containsFinding("semantic.missing-ruleIDs"))
    }

    func testCurrentTimeBaselineDocumentsKnownRedFindings() throws {
        let root = repoRoot()
        let timeSurface = try source("Native/Ambitions/Surfaces/Time/TimeSurface.swift", root: root)
        let lifeShapeModels = try source("Native/Ambitions/Surfaces/Time/Projection/TimeLifeShapeModels.swift", root: root)
        let lifeShapeProjection = try source("Native/Ambitions/Surfaces/Time/Projection/TimeLifeShapeFieldProjection.swift", root: root)
        let reflowView = try source("Native/Ambitions/DesignSystem/ProductObjects/LifeShapeFieldReflow.swift", root: root)
        let snapshotMatrix = try source("Native/Ambitions/Quality/SnapshotMatrix.swift", root: root)
        let baselineFiles = [
            LifeShapeSourceFile(path: "TimeSurface.swift", contents: timeSurface),
            LifeShapeSourceFile(path: "TimeLifeShapeModels.swift", contents: lifeShapeModels),
            LifeShapeSourceFile(path: "TimeLifeShapeFieldProjection.swift", contents: lifeShapeProjection),
            LifeShapeSourceFile(path: "LifeShapeFieldReflow.swift", contents: reflowView),
            LifeShapeSourceFile(path: "SnapshotMatrix.swift", contents: snapshotMatrix)
        ]

        XCTAssertTrue(LifeShapeFixtureAudit.auditReleaseSources(baselineFiles).containsFinding("fixture.scenariocatalog"))
        XCTAssertFalse(LifeShapeDerivationAudit.auditModelContract(baselineFiles).passed)
        XCTAssertFalse(LifeShapeFakePrecisionAudit.auditRootTimeCopy(baselineFiles).passed)
        XCTAssertFalse(LifeShapeMutationAudit.auditPrimaryActionSource(baselineFiles).passed)
        XCTAssertFalse(LifeShapeTodayCouplingAudit.auditMutationCouplingSource(baselineFiles).passed)
        XCTAssertTrue(LifeShapeSemanticAudit.auditSemanticMarkContract(baselineFiles).passed)
    }

    func testDynamicTypeLifeShapeAuditRequiresScenarioAndReadableProof() {
        let report = DynamicTypeAudit.auditLifeShapeAccessibilityMode(
            hasXXXLScenario: false,
            hasReadablePrimaryObjectProof: false
        )

        XCTAssertTrue(report.containsFinding("dynamic-type.missing-xxxl-scenario"))
        XCTAssertTrue(report.containsFinding("dynamic-type.missing-readable-primary-object-proof"))
    }

    private func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
import AmbitionsTimeFoundation
