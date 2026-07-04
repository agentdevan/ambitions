import XCTest
@testable import Ambitions

final class OverlayLensesCanonicalOwnershipTests: XCTestCase {
    func testRequiredOverlayLensFilesExistAtFeatureLocalPaths() throws {
        let root = repoRoot()
        let required = [
            "Native/Ambitions/Projection/Contracts/OverlayProjectionContracts.swift",
            "Native/Ambitions/Composer/Capture/Projection/CaptureLens.swift",
            "Native/Ambitions/Stage/Overlays/Projection/SearchLens.swift",
            "Native/Ambitions/Stage/Overlays/Projection/ClosureLens.swift",
            "Native/Ambitions/Trust/Projection/InspectionLens.swift"
        ]

        for path in required {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
        XCTAssertEqual(try swiftFiles(under: root.appendingPathComponent("Native/Ambitions/Projection/OverlayLenses")), [])
    }

    func testOverlayLensContractsAreRealProjectionOwners() {
        let contracts = [
            CaptureLens.contract,
            SearchLens.contract,
            ClosureLens.contract,
            InspectionLens.contract
        ]

        XCTAssertEqual(contracts.map(\.kind), [.capture, .search, .closure, .inspection])
        XCTAssertEqual(
            contracts.map(\.ownerLayer),
            ["Composer/Capture/Projection", "Stage/Overlays/Projection", "Stage/Overlays/Projection", "Trust/Projection"]
        )
        for contract in contracts {
            XCTAssertTrue(contract.satisfiesFinalCanon, contract.kind.rawValue)
            XCTAssertFalse(contract.projectionInputs.isEmpty)
            XCTAssertFalse(contract.failureStates.isEmpty)
        }
    }

    func testCaptureLensProjectsPlacementReviewState() {
        let capture = Capture(
            id: "capture-overlay-lens",
            createdAt: "2026-06-20T12:00:00Z",
            updatedAt: "2026-06-20T12:00:00Z",
            rawText: "Ask Jordan about Saturday logistics",
            sourceType: .shellComposer,
            status: .needsTriage,
            linkedGoalID: nil,
            triage: CaptureTriageMetadata(destination: .attachToGoal)
        )

        let report = CaptureLens.project(capture.placementReviewState)

        XCTAssertTrue(report.isProductionReady)
        XCTAssertTrue(report.primarySummary.contains("Needs a Place"))
        XCTAssertTrue(report.trustSummary.localizedCaseInsensitiveContains("local"))
    }

    func testSearchClosureAndInspectionLensesProjectExistingRuntimeModels() {
        let searchReport = SearchLens.project(PreviewFixtures.default.youDashboard.everythingSearch)
        let closure = TodayActionClosureSheetState.step(
            title: "Send the update",
            context: "Today",
            target: TodayActionTarget(goalID: "goal", stepID: "step")
        )
        let closureReport = ClosureLens.project(closure)
        let inspectionReport = InspectionLens.project(ActionReceiptHistoryProjection(records: []).search())

        XCTAssertTrue(searchReport.isProductionReady)
        XCTAssertTrue(closureReport.isProductionReady)
        XCTAssertTrue(inspectionReport.isProductionReady)
        XCTAssertTrue(closureReport.trustSummary.localizedCaseInsensitiveContains("local"))
        XCTAssertTrue(inspectionReport.trustSummary.localizedCaseInsensitiveContains("local"))
    }

    private func repoRoot() -> URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    private func swiftFiles(under root: URL) throws -> [String] {
        guard let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return try enumerator.compactMap { item in
            guard let url = item as? URL else { return nil }
            let values = try url.resourceValues(forKeys: [.isRegularFileKey])
            return values.isRegularFile == true && url.pathExtension == "swift" ? url.lastPathComponent : nil
        }.sorted()
    }
}
