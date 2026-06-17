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
    private static var observatoryLabel: String { releasePerformanceObservatoryLabel }

    func testR02ReportCoversRequiredPerformanceAreas() {
        XCTAssertEqual(
            ReleasePerformanceResponsivenessReport.checks.map(\.area),
            ReleasePerformanceArea.allCases
        )

        XCTAssertEqual(ReleasePerformanceResponsivenessReport.checks.count, 10)
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.readinessSummary.contains("device, TestFlight, and App Store validation remain separate gates"))
        XCTAssertEqual(ReleasePerformanceArea.planLoad.rawValue, "Time load")
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.area == .tabSwitching &&
            check.evidence.localizedCaseInsensitiveContains("Today, Goals, Time, You")
        })
        XCTAssertTrue(ReleasePerformanceResponsivenessReport.checks.contains { check in
            check.area == .observatoryFoundation &&
            check.evidence.localizedCaseInsensitiveContains("AFEP-004") &&
            check.evidence.localizedCaseInsensitiveContains("false-by-default public-release claim locks")
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

    func testAFEP022ObservatoryRegistryCoversCanonicalSurfacesAndBudgetLinks() {
        let plans = ReleasePerformanceObservatoryRegistry.canonicalSurfacePlans

        XCTAssertEqual(plans.map(\.surface), [.today, .goals, .time, .you])
        XCTAssertEqual(Set(plans.map(\.surface)).count, 4)
        XCTAssertTrue(plans.allSatisfy(\.isWellFormed))
        XCTAssertTrue(plans.allSatisfy { $0.claimLock.allowsClaim == false })
        XCTAssertTrue(plans.allSatisfy { plan in
            plan.budgetLinks.contains { $0.kind == .afep004LocalProjection } &&
            plan.budgetLinks.contains { $0.kind == .repositoryBudget } &&
            plan.validationPacket.observatoryLabel == Self.observatoryLabel &&
            plan.validationPacket.sourceRecordReference.localizedCaseInsensitiveContains("SourceRecord") &&
            plan.validationPacket.receiptReference.localizedCaseInsensitiveContains("Receipt") &&
            plan.validationPacket.replayTraceReference.localizedCaseInsensitiveContains("ReplayTrace") &&
            plan.validationPacket.state == .skipped &&
            plan.validationPacket.isWellFormed
        })

        let metricKinds = Set(plans.flatMap(\.metricKinds))
        XCTAssertEqual(
            metricKinds,
            [
                .queryBudget,
                .render,
                .launch,
                .scroll,
                .backgroundMaintenance,
                .memory,
                .wakeup,
                .energyImpact
            ]
        )
    }

    func testAFEP022ObservatoryFallbackPlansStayDeferableAndLegible() throws {
        let plan = try XCTUnwrap(
            ReleasePerformanceObservatoryRegistry.canonicalSurfacePlans.first(where: { $0.surface == .time })
        )

        XCTAssertTrue(plan.degradationPlan.isWellFormed)
        XCTAssertTrue(plan.degradationPlan.keepsElevatedVisualsOptional)
        XCTAssertTrue(plan.degradationPlan.keepsExpensiveRenderPathsOptional)
        XCTAssertTrue(plan.degradationPlan.defersBackgroundWork)
        XCTAssertTrue(plan.degradationPlan.preservesPrimaryAction)
        XCTAssertTrue(plan.degradationPlan.keepsUserExperienceLegible)
        XCTAssertTrue(plan.degradationPlan.fallbackSummary.localizedCaseInsensitiveContains("deferred"))
        XCTAssertTrue(plan.validationPacket.knownLimitation.localizedCaseInsensitiveContains("measured validation"))
    }

    func testAFEP022ClaimLockRequiresMeasuredValidationBeforeOpening() {
        let locked = ReleasePerformanceClaimLock(
            id: "afep022.locked",
            currentEvidenceLevel: .sourceBudget,
            currentValidationState: .skipped,
            currentMeasuredValidationExists: false,
            lockReason: "Measured validation is still pending."
        )

        let unlocked = ReleasePerformanceClaimLock(
            id: "afep022.unlocked",
            currentEvidenceLevel: .manualDeviceRequired,
            currentValidationState: .passed,
            currentMeasuredValidationExists: true,
            lockReason: "Current measured validation is present."
        )

        XCTAssertFalse(locked.allowsClaim)
        XCTAssertTrue(unlocked.allowsClaim)
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
