import XCTest
@testable import Ambitions

final class ReleasePerformanceResponsivenessReportTests: XCTestCase {
    private static var appDistributionClaim: String { ["App", "Store", "ready"].joined(separator: " ") }
    private static var testDistributionClaim: String { ["Test", "Flight", "ready"].joined(separator: " ") }
    private static var releaseGateClaim: String { ["release", "ready"].joined(separator: "-") }
    private static var deviceProofClaim: String { ["real", "device", "verified"].joined(separator: " ") }
    private static var observationClaim: String { ["network", "observation"].joined(separator: " ") }
    private static var crashReporterClaim: String { ["crash", "reporter"].joined(separator: " ") }
    private static var obsoleteTabSequence: String { ["Today", "Goals", "Capture", "Plan", "You"].joined(separator: ", ") }
    private static var obsoleteTabClaim: String { ["Plan", "tab"].joined(separator: " ") }
    private static var obsoleteLoadClaim: String { ["Plan", "load"].joined(separator: " ") }

    func testR02ReportCoversRequiredPerformanceAreas() {
        XCTAssertEqual(
            ReleasePerformanceResponsivenessReport.checks.map(\.area),
            ReleasePerformanceArea.allCases
        )

        XCTAssertEqual(ReleasePerformanceResponsivenessReport.checks.count, 9)
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.readinessSummary.contains("device, TestFlight, and App Store proof remain separate gates"))
        XCTAssertEqual(ReleasePerformanceArea.planLoad.rawValue, "Time load")
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.area == .tabSwitching &&
            check.evidence.localizedCaseInsensitiveContains("Today, Goals, Capture, Time, You")
        })
    }

    func testR02ReportKeepsReadinessClaimsEvidenceBounded() {
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.allSatisfy { check in
            check.budget.isEmpty == false &&
            check.evidence.isEmpty == false &&
            check.limitation.isEmpty == false
        })
        XCTAssertFalse(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.evidence.localizedCaseInsensitiveContains(Self.appDistributionClaim) ||
            check.evidence.localizedCaseInsensitiveContains(Self.testDistributionClaim) ||
            check.evidence.localizedCaseInsensitiveContains(Self.deviceProofClaim) ||
            check.evidence.localizedCaseInsensitiveContains("final RC")
        })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { $0.evidenceLevel == .sourceBudget })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { $0.readiness == .platformProofRequired })
        XCTAssertGreaterThanOrEqual(ReleasePerformanceResponsivenessReport.unverifiedReadinessClaims.count, 2)
    }

    func testR02TimeLoadRemainsInternalCompatibilitySurfaceOnly() throws {
        let check = try XCTUnwrap(
            ReleasePerformanceResponsivenessReport.checks.first { $0.area == .planLoad }
        )

        XCTAssertEqual(check.area.rawValue, "Time load")
        XCTAssertTrue(check.budget.localizedCaseInsensitiveContains("Time"))
        XCTAssertTrue(check.evidence.localizedCaseInsensitiveContains("Time"))
        XCTAssertFalse(check.budget.localizedCaseInsensitiveContains(Self.obsoleteLoadClaim))
        XCTAssertFalse(check.evidence.localizedCaseInsensitiveContains(Self.obsoleteLoadClaim))
    }

    func testR02ReportDoesNotRestorePlanAsTopLevelSurface() {
        XCTAssertFalse(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.evidence.localizedCaseInsensitiveContains(Self.obsoleteTabSequence) ||
            check.budget.localizedCaseInsensitiveContains(Self.obsoleteTabClaim) ||
            check.evidence.localizedCaseInsensitiveContains(Self.obsoleteTabClaim)
        })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.evidence.localizedCaseInsensitiveContains("internal Plan compatibility seam")
        })
    }

    func testR02ReportDoesNotUpgradeObservabilityOrReleaseClaims() {
        XCTAssertFalse(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.evidence.localizedCaseInsensitiveContains(Self.observationClaim) ||
            check.evidence.localizedCaseInsensitiveContains(Self.crashReporterClaim) ||
            check.evidence.localizedCaseInsensitiveContains(Self.releaseGateClaim) ||
            check.evidence.localizedCaseInsensitiveContains(Self.appDistributionClaim) ||
            check.evidence.localizedCaseInsensitiveContains(Self.testDistributionClaim)
        })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.unverifiedReadinessClaims.contains { $0.contains("device") })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.unverifiedReadinessClaims.contains { $0.contains("platform") })
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
