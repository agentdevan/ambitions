import AmbitionsDesignSystem
import Foundation
import XCTest

final class ClosureRecoveryPrimitiveFamilyTests: XCTestCase {
    func testAMB578ClosureRecoveryPrimitiveFamilyContract() {
        let contract = ClosureRecoveryPrimitiveFamilyContract.current

        XCTAssertEqual(contract.primitiveID, "closure-recovery-family")
        XCTAssertEqual(contract.ownerSurface, "Global action-state")
        XCTAssertEqual(contract.productObjects, ["Closure", "Recovery"])
        XCTAssertEqual(contract.stageName, "Closure / Recovery Primitive Family")
        XCTAssertEqual(contract.screenshotIdentifier, "ClosureRecoveryPrimitiveFamily")
        XCTAssertTrue(contract.replacesStructures.contains("generic closure panels"))
        XCTAssertTrue(contract.replacesStructures.contains("generic recovery panels"))
        XCTAssertTrue(contract.replacesStructures.contains("closure outcome cards"))
        XCTAssertEqual(contract.actionStateOrder, [
            "context",
            "outcome meaning",
            "recovery consequence",
            "review preview",
            "no silent mutation"
        ])
        XCTAssertTrue(contract.forbiddenPatterns.contains("punitive closure language"))
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Dynamic Type") })
        XCTAssertTrue(contract.accessibilityFallbacks.contains { $0.contains("Differentiate Without Color") })
        XCTAssertEqual(ClosureRecoveryPrimitiveRole.closure.semanticState, .review)
        XCTAssertEqual(ClosureRecoveryPrimitiveRole.recovery.semanticState, .recovery)
        XCTAssertEqual(ClosureRecoveryPrimitiveRole.receipt.semanticState, .trust)
    }

    func testAMB578ActiveClosureRecoverySurfacesUsePrimitiveFamily() throws {
        let root = repoRoot()
        let todayClosureSource = try source("Native/Ambitions/Stage/Overlays/TodayActionClosureSheet.swift", root: root)
        let todayPanelsSource = try source("Native/Ambitions/DesignSystem/ProductObjects/TodayPanels.swift", root: root)
        let habitsSource = try source("Native/Ambitions/DesignSystem/ProductObjects/TimeRitualViews.swift", root: root)
        let richPanelSource = try source("Sources/Components/RichPanelPrimitives.swift", root: root)
        let canonicalSource = try source("Sources/Components/AmbitionsV2CanonicalComponents.swift", root: root)
        let tactileSource = try source("Sources/Components/AmbitionsExtendedTactileKit.swift", root: root)
        let shellSource = try source("Sources/Components/ShellChromePrimitives.swift", root: root)

        XCTAssertTrue(todayClosureSource.contains("ClosureRecoveryPrimitiveStage("))
        XCTAssertTrue(todayClosureSource.contains("ClosureRecoveryPrimitiveLine("))
        XCTAssertTrue(todayPanelsSource.contains("TodayRecoveryBloomPrimitive"))
        XCTAssertTrue(todayPanelsSource.contains("ClosureRecoveryPrimitiveStage("))
        XCTAssertTrue(todayPanelsSource.contains("ClosureRecoveryPrimitiveLine("))
        XCTAssertTrue(habitsSource.contains("rituals.recovery-summary"))
        XCTAssertTrue(richPanelSource.contains("recovery-primitive-panel"))
        XCTAssertTrue(canonicalSource.contains("closure-check-in-panel"))
        XCTAssertTrue(tactileSource.contains("recovery-tide-strip"))
        XCTAssertTrue(shellSource.contains("action-closure-tray"))
        XCTAssertTrue(shellSource.contains("ClosureRecoveryPrimitiveLine("))

        XCTAssertFalse(richPanelSource.contains("panel = AmbitionRichPanel(configuration.with(kind: .recovery)"))
        XCTAssertFalse(canonicalSource.contains("AppCard(state: .warning)"))
        XCTAssertFalse(habitsSource.contains("AppCard {\n            VStack(alignment: .leading, spacing: theme.spacing.md)"))
        XCTAssertFalse(tactileSource.contains("RecoveryTideStrip: View {\n    @Environment(\\.ambitionTheme) private var theme"))
        XCTAssertFalse(shellSource.contains("theme.shell.receiptMaterial"))
    }

    func testAMB578PrimitiveRegistryIncludesClosureRecoveryFamilyEntry() throws {
        let registry = try source("docs/codex/ambitions_primitive_invention_registry.md", root: repoRoot())

        XCTAssertTrue(registry.contains("| closure-recovery-family | Promoted | Global action-state | Closure / Recovery | AMB-578 |"))
        XCTAssertTrue(registry.contains("### closure-recovery-family"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/action-state/AMB-578-closure-recovery-family.md"))
        XCTAssertTrue(registry.contains("artifacts/ambitions-ui-reconstruction/screenshots/closure-recovery-family-amb-578.png"))
    }

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
