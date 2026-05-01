import XCTest
@testable import Ambitions

final class CoreSurfaceIntegrationScenarioTests: XCTestCase {
    func testM01CatalogCoversRequiredIndispensabilityScenarios() {
        let ids = Set(CoreSurfaceIntegrationScenarioCatalog.scenarios.map(\.id))

        XCTAssertEqual(ids, [
            "meaningful-goal",
            "capture-place-thought",
            "disrupted-day-recovery",
            "overloaded-week",
            "proof-receipts-review",
            "what-ambitions-knows",
            "calendar-denied",
            "one-step-goal",
            "park-defer-drop",
            "week-away-return"
        ])
    }

    func testM01CatalogCoversGoldenLaunchLoopAndCanonicalSurfaces() {
        let coveredLoopSteps = Set(CoreSurfaceIntegrationScenarioCatalog.scenarios.flatMap(\.launchLoopSteps))
        let coveredSurfaces = Set(CoreSurfaceIntegrationScenarioCatalog.scenarios.flatMap(\.surfaces))

        XCTAssertEqual(coveredLoopSteps, Set(CoreSurfaceLaunchLoopStep.allCases))
        XCTAssertTrue(coveredSurfaces.isSuperset(of: [.today, .goals, .capture, .plan, .you]))
        XCTAssertTrue(coveredSurfaces.contains(.goalDetail))
        XCTAssertTrue(coveredSurfaces.contains(.reviews))
    }

    func testM01ManualChecklistIsHumanReadableAndEvidenceBased() {
        let checklist = CoreSurfaceIntegrationScenarioCatalog.manualChecklist
        let joined = checklist.joined(separator: " ")

        XCTAssertEqual(checklist.count, CoreSurfaceIntegrationScenarioCatalog.scenarios.count)
        XCTAssertTrue(joined.contains("Evidence:"))
        XCTAssertTrue(joined.contains("Needs a Place"))
        XCTAssertTrue(joined.contains("What Ambitions Knows"))
        XCTAssertTrue(joined.contains("No Tasks tab"))
        XCTAssertFalse(joined.localizedCaseInsensitiveContains("AI confidence"))
        XCTAssertFalse(joined.localizedCaseInsensitiveContains("top-level Insights"))
        XCTAssertFalse(joined.localizedCaseInsensitiveContains("top-level Habits"))
    }

    func testM01BlockerClassificationFeedsMaturityAndReleaseBatches() {
        let blockers = CoreSurfaceIntegrationScenarioCatalog.blockers
        let ownerBatches = blockers.map(\.ownerBatch).joined(separator: " ")

        XCTAssertTrue(ownerBatches.contains("M02"))
        XCTAssertTrue(ownerBatches.contains("M03"))
        XCTAssertTrue(ownerBatches.contains("M04"))
        XCTAssertTrue(ownerBatches.contains("M05-M07"))
        XCTAssertTrue(ownerBatches.contains("M08"))
        XCTAssertTrue(ownerBatches.contains("M09"))
        XCTAssertTrue(ownerBatches.contains("M10-M11"))
        XCTAssertTrue(ownerBatches.contains("R02"))
        XCTAssertTrue(ownerBatches.contains("R01"))
        XCTAssertTrue(ownerBatches.contains("R03-R05"))
        XCTAssertTrue(blockers.contains { $0.severity == .blocking })
        XCTAssertTrue(blockers.allSatisfy { $0.evidenceNeeded.isEmpty == false })
    }
}
