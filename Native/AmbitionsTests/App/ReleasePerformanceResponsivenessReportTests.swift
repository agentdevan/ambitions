import XCTest
@testable import Ambitions

final class ReleasePerformanceResponsivenessReportTests: XCTestCase {
    func testR02ReportCoversRequiredPerformanceAreas() {
        XCTAssertEqual(
            ReleasePerformanceResponsivenessReport.checks.map(\.area),
            ReleasePerformanceArea.allCases
        )

        XCTAssertEqual(ReleasePerformanceResponsivenessReport.checks.count, 9)
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.readinessSummary.contains("device and TestFlight proof remain separate gates"))
    }

    func testR02ReportKeepsReadinessClaimsEvidenceBounded() {
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.allSatisfy { check in
            check.budget.isEmpty == false &&
            check.evidence.isEmpty == false &&
            check.limitation.isEmpty == false
        })
        XCTAssertFalse(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.evidence.localizedCaseInsensitiveContains("App Store ready") ||
            check.evidence.localizedCaseInsensitiveContains("TestFlight ready") ||
            check.evidence.localizedCaseInsensitiveContains("real-device verified") ||
            check.evidence.localizedCaseInsensitiveContains("final RC")
        })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { $0.evidenceLevel == .sourceBudget })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { $0.readiness == .platformProofRequired })
        XCTAssertGreaterThanOrEqual(ReleasePerformanceResponsivenessReport.unverifiedReadinessClaims.count, 2)
    }

    func testR02ExternalSnapshotPerformanceStaysPlatformLimited() throws {
        let check = try XCTUnwrap(
            ReleasePerformanceResponsivenessReport.checks.first { $0.area == .externalSnapshots }
        )

        XCTAssertEqual(check.readiness, .platformProofRequired)
        XCTAssertEqual(check.evidenceLevel, .automatedSimulator)
        XCTAssertTrue(check.budget.localizedCaseInsensitiveContains("lightweight"))
        XCTAssertTrue(check.limitation.localizedCaseInsensitiveContains("device"))
        XCTAssertTrue(check.limitation.localizedCaseInsensitiveContains("platform"))
    }
}
