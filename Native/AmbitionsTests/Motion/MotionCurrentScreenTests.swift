import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class MotionCurrentScreenTests: XCTestCase {
    func testAMB574MotionObjectStagePrimitiveContractReplacesLanePanels() throws {
        let contract = MotionObjectStagePrimitiveContract.current
        let source = try String(
            contentsOf: repoRoot().appendingPathComponent("Native/Ambitions/Features/Motion/MotionCurrentScreen.swift"),
            encoding: .utf8
        )

        XCTAssertEqual(contract.primitiveID, "motion-object-stage")
        XCTAssertEqual(contract.ownerSurface, "Motion")
        XCTAssertEqual(contract.productObject, "Motion Current")
        XCTAssertEqual(contract.screenshotIdentifier, "MotionObjectStage")
        XCTAssertTrue(contract.firstViewportAvoidsAnalyticsReportCardDashboardOutput)
        XCTAssertTrue(contract.reservesTabBarClearance)
        XCTAssertEqual(contract.sourceTrustLineOrder, ["source", "proof", "receipt", "re-entry"])
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("lane cards"))
        XCTAssertTrue(contract.replacesFirstViewportStructures.contains("trace pills"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertTrue(source.contains("ProofRelationshipTracePrimitiveLine("))
        XCTAssertTrue(source.contains("fieldTexture"))
        XCTAssertTrue(source.contains(".safeAreaInset(edge: .bottom"))
        XCTAssertTrue(source.contains(".overlay(alignment: .leading)"))
        XCTAssertFalse(source.contains("RoundedRectangle("))
        XCTAssertFalse(source.contains("MotionTracePill"))
    }

    func testAMB574PrimitiveRegistryIncludesMotionObjectStageEntry() throws {
        let registry = try String(
            contentsOf: repoRoot().appendingPathComponent("docs/codex/ambitions_primitive_invention_registry.md"),
            encoding: .utf8
        )

        XCTAssertTrue(registry.contains("| motion-object-stage | Promoted | Motion | Motion Current | AMB-574 |"))
        XCTAssertTrue(registry.contains("### motion-object-stage"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/object-stage/AMB-574-motion-object-stage.md"))
    }

    func testMotionCurrentProjectionContainsRequiredRootChildren() {
        let projection = MotionCurrentProjection.fixture

        XCTAssertEqual(projection.crown.title, "Motion Current")
        XCTAssertFalse(projection.field.title.isEmpty)
        XCTAssertEqual(Set(projection.lanes.map(\.id)), ["proof", "recovery", "reentry"])
        XCTAssertEqual(projection.lanes.flatMap(\.items).count, 11)
        XCTAssertEqual(projection.affordance.items.map(\.label), ["Source", "Proof", "Receipt"])
        XCTAssertEqual(projection.dockActions.map(\.id), ["today", "goals", "time", "trust"])
    }

    func testMotionCurrentFieldKeepsEmptyStateStructured() {
        let field = MotionCurrentProjection.fixture.field

        XCTAssertTrue(field.summary.localizedCaseInsensitiveContains("structured"))
        XCTAssertTrue(field.source.localizedCaseInsensitiveContains("SourceRecord"))
        XCTAssertTrue(field.proof.localizedCaseInsensitiveContains("Proof"))
        XCTAssertTrue(field.receipt.localizedCaseInsensitiveContains("Receipt"))
        XCTAssertTrue(field.control.localizedCaseInsensitiveContains("control"))
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

        XCTAssertEqual(laneTitles, ["Proof lane", "Recovery lane", "Re-entry lane"])
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

        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Source"))
        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Proof"))
        XCTAssertTrue(affordanceCopy.localizedCaseInsensitiveContains("Receipt"))
        XCTAssertTrue(projection.crown.chips.contains { $0.title == "Local" })
        XCTAssertTrue(projection.crown.chips.contains { $0.title == "Receipt-aware" })
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
    func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }
}
