import AmbitionsDesignSystem
import Foundation
import XCTest

final class HorizonCapacityPrimitiveFamilyTests: XCTestCase {
    func testAMB581HorizonCapacityPrimitiveFamilyContract() {
        let contract = HorizonCapacityPrimitiveFamilyContract.current

        XCTAssertEqual(contract.primitiveID, "horizon-capacity-family")
        XCTAssertEqual(contract.ownerSurface, "Time")
        XCTAssertEqual(contract.productObjects, ["Horizon", "Capacity", "LifeShape Field"])
        XCTAssertEqual(contract.stageName, "Horizon / Capacity Primitive Family")
        XCTAssertEqual(contract.screenshotIdentifier, "HorizonCapacityPrimitiveFamily")
        XCTAssertTrue(contract.replacesStructures.contains("generic horizon chips"))
        XCTAssertTrue(contract.replacesStructures.contains("horizon tab strips"))
        XCTAssertTrue(contract.replacesStructures.contains("capacity panels"))
        XCTAssertTrue(contract.replacesStructures.contains("continuity pills"))
        XCTAssertEqual(contract.relationshipOrder, [
            "selected horizon",
            "capacity fit",
            "protected/open time relationship",
            "source and receipt",
            "continuity",
            "no root navigation"
        ])
        XCTAssertTrue(contract.forbiddenPatterns.contains("root tab behavior"))
        XCTAssertTrue(contract.forbiddenPatterns.contains("generic horizon card"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertEqual(HorizonCapacityPrimitiveRole.horizon.semanticState, .review)
        XCTAssertEqual(HorizonCapacityPrimitiveRole.selectedHorizon.semanticState, .focus)
        XCTAssertEqual(HorizonCapacityPrimitiveRole.capacity.semanticState, .review)
        XCTAssertEqual(HorizonCapacityPrimitiveRole.receipt.semanticState, .trust)
        XCTAssertEqual(HorizonCapacityPrimitiveRole.noRootNavigation.semanticState, .protected)
    }

    func testAMB581ActiveTimeFieldUsesHorizonCapacityPrimitiveFamily() throws {
        let root = repoRoot()
        let timeFieldSource = try source("Native/Ambitions/Features/Time/TimeLifeShapeField.swift", root: root)

        XCTAssertTrue(timeFieldSource.contains("HorizonCapacityPrimitiveStage("))
        XCTAssertTrue(timeFieldSource.contains("HorizonCapacityPrimitiveLine("))
        XCTAssertTrue(timeFieldSource.contains("time.life-shape-field.horizon-control"))
        XCTAssertTrue(timeFieldSource.contains("time.life-shape-field.capacity-statement"))
        XCTAssertTrue(timeFieldSource.contains("time.life-shape-field.source-receipt"))
        XCTAssertTrue(timeFieldSource.contains("time.life-shape-field.continuity-dock"))
        XCTAssertTrue(timeFieldSource.contains("Day, Week, and Month shape capacity without becoming root navigation."))
        XCTAssertTrue(timeFieldSource.contains("Review before reflow"))

        XCTAssertFalse(timeFieldSource.contains("Text(horizon.title)\n                .font(theme.typography.caption.weight(selected ? .semibold : .regular))"))
        XCTAssertFalse(timeFieldSource.contains("Text(reading.capacityStatement)\n                    .font(theme.typography.bodyEmphasized)"))
        XCTAssertFalse(timeFieldSource.contains("TagPill(suite.calendarBoundaryLabel"))
        XCTAssertFalse(timeFieldSource.contains("Label(item, systemImage: continuityIcon(at: index))"))
    }

    func testAMB581OldHorizonCapacityCardsAreUnreachableFromActiveTimeBody() throws {
        let timeScreenSource = try source("Native/Ambitions/Features/Time/TimeScreen.swift", root: repoRoot())
        let activeBodySource = try activeTimeScreenBodySource(from: timeScreenSource)

        XCTAssertTrue(activeBodySource.contains("TimeLifeShapeField("))
        XCTAssertFalse(activeBodySource.contains("TimeLifeSuiteCard("))
        XCTAssertFalse(activeBodySource.contains("TimeCapacityEnvelopeCard("))
        XCTAssertFalse(activeBodySource.contains("TimeShapeDepthDisclosure("))
    }

    func testAMB581PrimitiveRegistryIncludesHorizonCapacityFamilyEntry() throws {
        let registry = try source("docs/codex/ambitions_primitive_invention_registry.md", root: repoRoot())

        XCTAssertTrue(registry.contains("| horizon-capacity-family | Promoted | Time | Horizon / Capacity | AMB-581 |"))
        XCTAssertTrue(registry.contains("### horizon-capacity-family"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/relationship-motion/AMB-581-horizon-capacity-family.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/horizon-capacity-family-amb-581.png"))
    }

    private func activeTimeScreenBodySource(from timeScreenSource: String) throws -> String {
        guard let start = timeScreenSource.range(of: "var body: some View"),
              let end = timeScreenSource.range(of: "private var shell:", range: start.lowerBound..<timeScreenSource.endIndex) else {
            throw XCTSkip("Active TimeScreen body source could not be located.")
        }
        return String(timeScreenSource[start.lowerBound..<end.lowerBound])
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
