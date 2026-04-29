import XCTest
@testable import Ambitions

final class ReleaseDeviceQAReadinessReportTests: XCTestCase {
    func testR03ReportCoversRequiredDeviceReadinessScopes() {
        XCTAssertEqual(
            ReleaseDeviceQAReadinessReport.checks.map(\.scope),
            ReleaseDeviceQAScope.allCases
        )
        XCTAssertEqual(ReleaseDeviceQAReadinessReport.checks.count, 10)
        XCTAssertTrue(ReleaseDeviceQAReadinessReport.readinessSummary.contains("R04 is next"))
    }

    func testR03KeepsTestFlightGatedOnPhysicalDeviceProof() throws {
        XCTAssertEqual(ReleaseDeviceQAReadinessReport.testFlightPosture, .candidateAfterDeviceSmoke)
        XCTAssertTrue(ReleaseDeviceQAReadinessReport.checks.contains { $0.scope == .realDeviceSmoke && $0.evidenceState == .deviceRequired })
        XCTAssertTrue(ReleaseDeviceQAReadinessReport.checks.contains { $0.scope == .externalSurfaces && $0.evidenceState == .deviceRequired })
        XCTAssertFalse(ReleaseDeviceQAReadinessReport.checks.contains { check in
            check.evidence.localizedCaseInsensitiveContains("TestFlight ready") ||
            check.evidence.localizedCaseInsensitiveContains("App Store ready") ||
            check.evidence.localizedCaseInsensitiveContains("real-device verified") ||
            check.evidence.localizedCaseInsensitiveContains("RC locked")
        })
    }

    func testR03RepresentativeScenarioFixturesStayFixtureOnlyAndSurfaceBounded() {
        XCTAssertEqual(
            ReleaseDeviceQAReadinessReport.representativeScenarios.map(\.domain),
            ["Family / shared life", "Career", "Creative project", "Finance / life admin", "Home / life admin"]
        )
        XCTAssertTrue(ReleaseDeviceQAReadinessReport.representativeScenarios.allSatisfy { scenario in
            scenario.surfaces.isEmpty == false &&
            scenario.guardrail.isEmpty == false &&
            scenario.guardrail.localizedCaseInsensitiveContains("ready") == false &&
            scenario.guardrail.localizedCaseInsensitiveContains("verified") == false
        })
        XCTAssertFalse(ReleaseDeviceQAReadinessReport.representativeScenarios.contains { scenario in
            scenario.guardrail.localizedCaseInsensitiveContains("Tasks tab") == false &&
            scenario.scenario.localizedCaseInsensitiveContains("best path")
        })
    }
}
