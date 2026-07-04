import XCTest
@testable import Ambitions

final class ReleaseFrontendProofGateTests: XCTestCase {
    func testAMB1750ClassifiesFrontendReleaseQualityAsYellowUntilProofExists() {
        XCTAssertEqual(ReleaseFrontendProofGate.currentStatus, .yellow)
        XCTAssertFalse(ReleaseFrontendProofGate.acceptedYellowCountsAsGreen)
        XCTAssertFalse(ReleaseFrontendProofGate.visualGreenClaimAllowed)
        XCTAssertFalse(ReleaseFrontendProofGate.appStoreFrontendClaimAllowed)
        XCTAssertTrue(ReleaseFrontendProofGate.deviceSensitiveClaimsRequireDeviceEvidence)
        XCTAssertEqual(ReleaseFrontendProofGate.validationFailures(), [])
    }

    func testAMB1750RequiresEveryFrontendScreenshotScopeBeforeGreen() {
        XCTAssertEqual(
            Set(ReleaseFrontendProofGate.requiredScreenshotScopes),
            [
                "root_shell",
                "capture",
                "today",
                "goals",
                "time",
                "you",
                "inspection_details",
                "empty_error_offline_states"
            ]
        )

        let screenshot = ReleaseFrontendProofGate.requirements.first { $0.kind == .screenshot }
        XCTAssertEqual(screenshot?.state, .indexedNotRun)
        XCTAssertTrue(screenshot?.releaseBlocker.localizedCaseInsensitiveContains("frontend Green") == true)
    }

    func testAMB1750RequiresAccessibilityDynamicTypeReduceMotionAndDeviceEvidence() {
        XCTAssertEqual(
            Set(ReleaseFrontendProofGate.requirements.map(\.kind)),
            Set(FrontendReleaseProofKind.allCases)
        )

        let statesByKind = Dictionary(
            uniqueKeysWithValues: ReleaseFrontendProofGate.requirements.map { ($0.kind, $0.state) }
        )
        XCTAssertEqual(statesByKind[.accessibility], .requiredMissing)
        XCTAssertEqual(statesByKind[.dynamicType], .requiredMissing)
        XCTAssertEqual(statesByKind[.reduceMotion], .requiredMissing)
        XCTAssertEqual(statesByKind[.device], .blockedUntilDeviceEvidence)
    }

    func testAMB1750LinksSiblingFrontendRecoveryAsReleaseDependency() {
        XCTAssertTrue(ReleaseFrontendProofGate.releaseDependencyIssues.contains("AMB-1749"))
        XCTAssertTrue(ReleaseFrontendProofGate.releaseDependencyIssues.contains("AMB-1744"))
        XCTAssertTrue(ReleaseFrontendProofGate.releaseDependencyIssues.contains("AMB-1743"))
        XCTAssertTrue(ReleaseFrontendProofGate.releaseDependencyIssues.contains("AMB-1733"))
        XCTAssertTrue(ReleaseFrontendProofGate.releaseDependencyIssues.contains("AMB-1751"))
        XCTAssertTrue(
            ReleaseFrontendProofGate.requirements.contains {
                $0.kind == .siblingDependency &&
                    $0.releaseBlocker.localizedCaseInsensitiveContains("sibling frontend recovery")
            }
        )
    }

    func testAMB1750DoesNotPublishUnsupportedFrontendReleaseClaims() {
        let searchable = ([ReleaseFrontendProofGate.releaseSummary] + ReleaseFrontendProofGate.requirements.flatMap { requirement in
            [
                requirement.requiredScope,
                requirement.evidence,
                requirement.releaseBlocker
            ]
        }).joined(separator: " ")

        let forbidden = [
            "App Store" + " ready",
            "TestFlight" + " ready",
            "device" + " verified",
            "accessibility" + " verified",
            "fully" + " accessible",
            "Visual Green" + " achieved",
            "Release Green" + " achieved"
        ]

        for phrase in forbidden {
            XCTAssertFalse(
                searchable.localizedCaseInsensitiveContains(phrase),
                "AMB-1750 frontend release gate must not contain unsupported phrase \(phrase)"
            )
        }
    }

    func testAMB1750FeedsExistingReleasePackets() {
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.blockers.contains { $0.id == "frontend-visual-app-store-proof" })
        XCTAssertTrue(ReleaseCandidateLockDecisionReport.postureSummary.localizedCaseInsensitiveContains("frontend quality remains Yellow"))
        XCTAssertTrue(ReleaseExternalTruthReadinessPacket.readinessSummary.localizedCaseInsensitiveContains("frontend quality"))
    }
}
