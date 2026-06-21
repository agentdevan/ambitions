import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class MotionCurrentScreenTests: XCTestCase {
    func testAMB574MotionObjectStagePrimitiveContractReplacesLanePanels() throws {
        let contract = MotionObjectStagePrimitiveContract.current
        let root = repoRoot()
        let viewSource = try source("Native/Ambitions/Stage/Motion/StageMotionCurrentView.swift", root: root)
        let rendererSource = try source("Native/Ambitions/Stage/Motion/StageMotionRenderer.swift", root: root)
        let fieldSource = try source("Native/Ambitions/DesignSystem/ProductObjects/MotionCurrentFieldView.swift", root: root)
        let canvasSource = try source("Native/Ambitions/Rendering/CanvasPrimitives/MotionCurrentRenderer.swift", root: root)

        XCTAssertEqual(contract.primitiveID, "stage-motion-current")
        XCTAssertEqual(contract.ownerSurface, "Stage Motion")
        XCTAssertEqual(contract.productObject, "Stage Motion")
        XCTAssertEqual(contract.screenshotIdentifier, "StageMotionCurrent")
        XCTAssertTrue(contract.firstViewportAvoidsAnalyticsReportCardDashboardOutput)
        XCTAssertFalse(contract.reservesTabBarClearance)
        XCTAssertEqual(contract.sourceTrustLineOrder, ["context", "history", "review", "re-entry action"])
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("lane cards"))
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("trace pills"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertTrue(viewSource.contains("StageMotionLayer.current("))
        XCTAssertTrue(viewSource.contains("StageMotionRenderer(layer: layer"))
        XCTAssertTrue(rendererSource.contains("MotionCurrentField("))
        XCTAssertTrue(fieldSource.contains("ProofRelationshipTracePrimitiveLine("))
        XCTAssertTrue(fieldSource.contains("MotionFieldRhythmSpine("))
        XCTAssertTrue(canvasSource.contains("ProductMeaningCanvasEngine("))
        XCTAssertTrue(canvasSource.contains("motion.current.rhythm-spine"))
        XCTAssertFalse(rendererSource.contains(".safeAreaInset(edge: .bottom"))
        XCTAssertTrue(fieldSource.contains(".overlay(alignment: .leading)"))
        XCTAssertFalse(fieldSource.contains("theme.colors.canvasElevated.opacity(0.92)"))
        XCTAssertFalse(fieldSource.contains("theme.colors.canvas.opacity(0.96)"))
        XCTAssertFalse(rendererSource.contains("RoundedRectangle("))
        XCTAssertFalse(fieldSource.contains("MotionFieldGlyph"))
        XCTAssertFalse(fieldSource.contains("MotionTracePill"))
    }

    func testAMB574PrimitiveRegistryIncludesMotionObjectStageEntry() throws {
        let registryURL = repoRoot().appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md")
        guard FileManager.default.fileExists(atPath: registryURL.path) else {
            throw XCTSkip("Historical primitive registry is not retained in current repo truth.")
        }
        let registry = try String(contentsOf: registryURL, encoding: .utf8)

        XCTAssertTrue(registry.contains("| motion-object-stage | Promoted | Motion | Motion Current | AMB-574 |"))
        XCTAssertTrue(registry.contains("### motion-object-stage"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md"))
    }

    func testMotionCurrentProjectionContainsRequiredRootChildren() {
        let projection = MotionCurrentProjection.fixture

        XCTAssertEqual(projection.crown.title, "Motion Current")
        XCTAssertFalse(projection.field.title.isEmpty)
        XCTAssertEqual(Set(projection.lanes.map(\.id)), ["history", "recovery", "reentry"])
        XCTAssertEqual(projection.lanes.flatMap(\.items).count, 11)
        XCTAssertEqual(projection.affordance.items.map(\.label), ["Context", "History", "Review"])
        XCTAssertEqual(projection.dockActions.map(\.id), ["today", "goals", "time", "trust"])
    }

    func testMotionCurrentFieldKeepsEmptyStateStructured() {
        let field = MotionCurrentProjection.fixture.field

        XCTAssertTrue(field.title.localizedCaseInsensitiveContains("No proof yet"))
        XCTAssertTrue(field.summary.localizedCaseInsensitiveContains("holding the thread"))
        XCTAssertTrue(field.source.localizedCaseInsensitiveContains("source"))
        XCTAssertTrue(field.proof.localizedCaseInsensitiveContains("Proof"))
        XCTAssertTrue(field.receipt.localizedCaseInsensitiveContains("Review"))
        XCTAssertTrue(field.control.localizedCaseInsensitiveContains("Inspect source"))
    }

    func testMotionRenderStatesExposeScreenshotProofFields() {
        let states = Set(MotionCurrentRenderState.allCases)

        XCTAssertEqual(states, [.emptyStructure, .proofAvailable, .recoveryActive, .reentryAvailable, .sourceUnavailable])

        for state in MotionCurrentRenderState.allCases {
            let field = MotionCurrentProjection.fixture(renderState: state).field
            XCTAssertFalse(field.title.isEmpty, "Missing title for \(state.rawValue)")
            XCTAssertFalse(field.summary.isEmpty, "Missing summary for \(state.rawValue)")
            XCTAssertFalse(field.source.isEmpty, "Missing source for \(state.rawValue)")
            XCTAssertFalse(field.proof.isEmpty, "Missing proof for \(state.rawValue)")
            XCTAssertFalse(field.receipt.isEmpty, "Missing receipt for \(state.rawValue)")
            XCTAssertFalse(field.control.isEmpty, "Missing control for \(state.rawValue)")
        }
    }

    func testMotionLanesStaySemanticWithoutCardStackStateNames() {
        let projection = MotionCurrentProjection.fixture
        let laneTitles = projection.lanes.map(\.title)
        let allCopy = projection.allUserFacingCopy

        XCTAssertEqual(laneTitles, ["What moved", "What needs recovery", "Where to return"])
        XCTAssertEqual(MotionCurrentProjection.fixture.lanes.map(\.rhythmTitle), ["What moved", "What needs recovery", "Where to return"])
        XCTAssertFalse(allCopy.localizedCaseInsensitiveContains("No Motion " + "Yet"))
        XCTAssertFalse(allCopy.localizedCaseInsensitiveContains("seg" + "mented"))
        XCTAssertFalse(allCopy.localizedCaseInsensitiveContains("Pick" + "er"))
    }

    func testMotionLanesContainRequiredCurrentStates() {
        let states = Set(MotionCurrentProjection.fixture.lanes.flatMap(\.items).map(\.id))
        let requiredStates: Set<String> = [
            "no-proof-yet",
            "proof-available",
            "proof-transferred",
            "recovery-active",
            "recovery-complete",
            "stalled-returnable",
            "reentry-available",
            "source-unavailable",
            "receipt-linked",
            "life-area-development",
            "changed-object"
        ]

        XCTAssertEqual(states, requiredStates)
    }

    func testEachMotionCurrentStateTracesSourceProofAndReceipt() {
        let items = MotionCurrentProjection.fixture.lanes.flatMap(\.items)

        for item in items {
            XCTAssertFalse(item.source.isEmpty, "Source trace missing for \(item.id)")
            XCTAssertFalse(item.proof.isEmpty, "Proof trace missing for \(item.id)")
            XCTAssertFalse(item.receipt.isEmpty, "Receipt trace missing for \(item.id)")
            XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Source"))
            XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Proof"))
            XCTAssertTrue(item.accessibilitySummary.localizedCaseInsensitiveContains("Receipt"))
        }
    }

    func testMotionSemanticMirrorCoversRequiredStageConsequences() {
        let layer = StageMotionLayer.current(
            projection: MotionCurrentProjection.fixture(renderState: .recoveryActive),
            reduceMotionEnabled: true
        )
        let mirror = layer.accessibilityPlan.semanticMirror

        XCTAssertEqual(Set(mirror.consequenceMirrors.map(\.kind)), Set(MotionConsequenceKind.allCases))
        XCTAssertTrue(mirror.hasRequiredBehaviorConsequences)
        XCTAssertTrue(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("Completion"))
        XCTAssertTrue(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("Blocked"))
        XCTAssertTrue(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("Recovery"))
        XCTAssertTrue(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("Re-entry"))
        XCTAssertTrue(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("Undo"))
        XCTAssertTrue(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("Protected boundary"))
        XCTAssertFalse(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("dashboard"))
        XCTAssertFalse(mirror.accessibleConsequenceSummary.localizedCaseInsensitiveContains("destination"))
    }

    func testRecoveryAndReentryAvoidFailureFraming() {
        let allCopy = MotionCurrentProjection.fixture.allUserFacingCopy.lowercased()
        let forbiddenTerms = [
            "fail" + "ure",
            "fail" + "ed",
            "sh" + "ame",
            "over" + "due"
        ]

        for term in forbiddenTerms {
            XCTAssertFalse(
                allCopy.contains(term),
                "Forbidden recovery/re-entry framing appears in fixture copy: \(term)"
            )
        }
    }

    func testMotionCurrentCopyAvoidsForbiddenSurfaceFraming() {
        let allCopy = MotionCurrentProjection.fixture.allUserFacingCopy.lowercased()
        let forbiddenTerms = [
            "ana" + "lytics",
            "dash" + "board",
            "sc" + "ore",
            "str" + "eak",
            "activity" + " feed",
            "X" + "P",
            "product" + "ivity",
            "progress" + " chart"
        ].map { $0.lowercased() }

        for term in forbiddenTerms {
            XCTAssertFalse(
                allCopy.contains(term),
                "Forbidden Motion framing appears in fixture copy: \(term)"
            )
        }
    }

    func testMotionCurrentAffordanceKeepsRuntimeInspectionPathVisible() {
        let projection = MotionCurrentProjection.fixture
        let affordanceCopy = projection.affordance.items
            .map { "\($0.label) \($0.value)" }
            .joined(separator: "\n")

        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Context"))
        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("History"))
        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Review"))
        XCTAssertTrue(projection.crown.chips.contains { $0.title == "Local" })
        XCTAssertTrue(projection.crown.chips.contains { $0.title == "Source-led" })
        XCTAssertTrue(projection.crown.chips.contains { $0.title == "Review" })
    }

    func testAMB965MotionReconstructionExposesProofReceiptAndReentryActions() throws {
        let source = try source("Native/Ambitions/DesignSystem/ProductObjects/MotionCurrentFieldView.swift", root: repoRoot())
        let allCopy = MotionCurrentProjection.fixture.allUserFacingCopy

        XCTAssertTrue(source.contains("motion.current.action.inspect-proof"))
        XCTAssertTrue(source.contains("motion.current.action.open-receipt"))
        XCTAssertTrue(source.contains("motion.current.action.reenter-thread"))
        XCTAssertTrue(MotionCurrentProjection.fixture(renderState: .emptyStructure).field.title.localizedCaseInsensitiveContains("No proof yet"))
        XCTAssertTrue(MotionCurrentProjection.fixture(renderState: .proofAvailable).field.title.localizedCaseInsensitiveContains("Proof available"))
        XCTAssertTrue(MotionCurrentProjection.fixture(renderState: .recoveryActive).field.title.localizedCaseInsensitiveContains("Recovery active"))
        XCTAssertTrue(MotionCurrentProjection.fixture(renderState: .reentryAvailable).field.title.localizedCaseInsensitiveContains("Re-entry available"))
        XCTAssertTrue(allCopy.localizedCaseInsensitiveContains("Stalled but returnable"))
        XCTAssertTrue(allCopy.localizedCaseInsensitiveContains("Re-entry available"))
        XCTAssertTrue(allCopy.localizedCaseInsensitiveContains("Receipt linked"))
    }
}

private extension MotionCurrentProjection {
    var allUserFacingCopy: String {
        var parts: [String] = [
            crown.eyebrow,
            crown.title,
            crown.summary,
            field.title,
            field.summary,
            field.source,
            field.proof,
            field.receipt,
            field.control,
            affordance.title
        ]

        parts.append(contentsOf: crown.chips.map(\.title))
        for lane in lanes {
            parts.append(contentsOf: [lane.title, lane.status, lane.summary])
            parts.append(contentsOf: lane.markers.map(\.title))
            for item in lane.items {
                parts.append(contentsOf: [item.title, item.stateLabel, item.source, item.proof, item.receipt])
            }
        }
        for item in affordance.items {
            parts.append(contentsOf: [item.label, item.value])
        }
        parts.append(contentsOf: dockActions.map(\.title))
        return parts.joined(separator: "\n")
    }
}

private extension MotionCurrentScreenTests {
    func source(_ relativePath: String, root: URL) throws -> String {
        try String(contentsOf: root.appendingPathComponent(relativePath), encoding: .utf8)
    }

    func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
