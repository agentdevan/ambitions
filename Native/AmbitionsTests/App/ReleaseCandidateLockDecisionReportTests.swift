import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class ReleaseCandidateLockDecisionReportTests: XCTestCase {
    func testR05RecordsCandidatePreparedHumanApprovalRequired() {
        XCTAssertEqual(
            ReleaseCandidateLockDecisionReport.lockStatus,
            .candidatePreparedHumanApprovalRequired
        )
        XCTAssertEqual(
            ReleaseCandidateLockDecisionReport.lockStatus.rawValue,
            "Candidate prepared; human approval required"
        )
        XCTAssertEqual(
            ReleaseCandidateLockDecisionReport.releasePosture,
            .investorDemoPreparedWithLimitations
        )
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.postureSummary.contains("not TestFlight-ready"))
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.postureSummary.contains("App Store submission-ready"))
    }

    func testR05NamesEvidenceBlockersAndDeferrals() {
        XCTAssertEqual(ReleaseCandidateLockDecisionReport.satisfiedEvidence.count, 3)
        XCTAssertEqual(ReleaseCandidateLockDecisionReport.blockers.count, 6)
        XCTAssertEqual(ReleaseCandidateLockDecisionReport.deferrals.count, 2)
        XCTAssertEqual(
            Set(ReleaseCandidateLockDecisionReport.blockers.map(\.id)),
            [
                "human-approval",
                "physical-device-smoke",
                "manual-accessibility",
                "signed-archive-store-validation",
                "external-platform-proof",
                "store-material-assets"
            ]
        )
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.blockers.allSatisfy { $0.state == .blockedByMissingHumanOrDeviceProof })
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.deferrals.allSatisfy { $0.state == .deferredByRoadmapDecision })
    }

    func testR05DoesNotPublishUnsupportedReleaseClaims() {
        let forbidden = [
            "RC locked",
            "App Store ready",
            "TestFlight ready",
            "real-device verified",
            "fully accessible",
            "accessibility verified",
            "cloud sync enabled",
            "account required"
        ]

        let searchable = ([ReleaseCandidateLockDecisionReport.postureSummary] + ReleaseCandidateLockDecisionReport.allItems.flatMap { item in
            [item.title, item.evidence, item.nextAction]
        }).joined(separator: " ")

        for phrase in forbidden {
            XCTAssertFalse(
                searchable.localizedCaseInsensitiveContains(phrase),
                "R05 decision report must not contain unsupported phrase \(phrase)"
            )
        }
    }

    func testR05KeepsAppStoreAndAccessibilityPosturesGatedByPriorReports() {
        XCTAssertEqual(ReleaseExternalTruthReadinessPacket.appStoreSubmissionPosture, .notReady)
        XCTAssertEqual(ReleaseDeviceQAReadinessReport.testFlightPosture, .candidateAfterDeviceSmoke)
        XCTAssertTrue(AccessibilityClaimsLock.publishableClaims.isEmpty)
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.blockers.contains { $0.id == "manual-accessibility" })
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.blockers.contains { $0.id == "signed-archive-store-validation" })
    }
}
