import AmbitionsDesignSystem
import XCTest
@testable import Ambitions

final class ReleaseExternalTruthReadinessPacketTests: XCTestCase {
    func testR04PacketCoversAllExternalTruthAreas() {
        XCTAssertEqual(
            ReleaseExternalTruthReadinessPacket.items.map(\.area),
            ReleaseExternalTruthArea.allCases
        )
        XCTAssertEqual(ReleaseExternalTruthReadinessPacket.items.count, 10)
        XCTAssertTrue(ReleaseExternalTruthReadinessPacket.readinessSummary.contains("R04 prepares"))
        XCTAssertTrue(ReleaseExternalTruthReadinessPacket.readinessSummary.contains("R05"))
    }

    func testR04KeepsSubmissionClaimsBlockedUntilHumanAndDeviceGates() {
        XCTAssertEqual(ReleaseExternalTruthReadinessPacket.appStoreSubmissionPosture, .notReady)
        XCTAssertEqual(ReleaseExternalTruthReadinessPacket.investorDemoPosture, .preparedWithLimitations)
        XCTAssertGreaterThanOrEqual(ReleaseExternalTruthReadinessPacket.blockedItems.count, 4)
        XCTAssertTrue(ReleaseExternalTruthReadinessPacket.items.contains { $0.area == .screenshots && $0.state == .needsHumanAsset })
        XCTAssertTrue(ReleaseExternalTruthReadinessPacket.items.contains { $0.area == .supportContact && $0.state == .needsHumanAsset })
        XCTAssertTrue(ReleaseExternalTruthReadinessPacket.items.contains { $0.area == .accessibilityClaims && $0.state == .blockedUntilManualProof })
        XCTAssertTrue(ReleaseExternalTruthReadinessPacket.items.contains { $0.area == .platformClaims && $0.state == .blockedUntilDeviceProof })
    }

    func testR04PacketUsesTimeAsCanonicalTopLevelSurfaceAndDoesNotReintroducePlan() {
        for item in ReleaseExternalTruthReadinessPacket.items {
            let searchable = [
                item.preparedStatement,
                item.evidence,
                item.limitation
            ].joined(separator: " ")

            XCTAssertFalse(
                searchable.localizedCaseInsensitiveContains(["Today", "Goals", "Capture", "Plan", "and You"].joined(separator: ", ")),
                "\(item.id) should not name Plan as a top-level surface"
            )
            XCTAssertFalse(
                searchable.localizedCaseInsensitiveContains("Plan " + "tab"),
                "\(item.id) should not name Plan as a tab"
            )
        }

        XCTAssertTrue(
            ReleaseExternalTruthReadinessPacket.items.contains { item in
                [item.preparedStatement, item.evidence, item.limitation]
                    .joined(separator: " ")
                    .localizedCaseInsensitiveContains("Today, Goals, Time, Motion, and You")
            }
        )
    }

    func testR04CopyAvoidsUnsupportedReleaseClaims() {
        let forbiddenPhrases = [
            "AI" + " confidence",
            "server-side AI",
            "cloud sync",
            "iCloud sync",
            "account required",
            "App Store" + " ready",
            "TestFlight" + " ready",
            "real-device" + " verified",
            "fully" + " accessible",
            "accessibility verified",
            "RC locked"
        ]

        for item in ReleaseExternalTruthReadinessPacket.items {
            let searchable = [
                item.preparedStatement,
                item.evidence,
                item.limitation
            ].joined(separator: " ")

            for phrase in forbiddenPhrases {
                XCTAssertFalse(
                    searchable.localizedCaseInsensitiveContains(phrase),
                    "\(item.id) should not contain unsupported phrase \(phrase)"
                )
            }
        }
    }

    func testR04PrivacyAndAccessibilityClaimsMapToCurrentEvidence() throws {
        let privacy = try XCTUnwrap(
            ReleaseExternalTruthReadinessPacket.items.first { $0.area == .privacyLabels }
        )
        XCTAssertTrue(privacy.preparedStatement.localizedCaseInsensitiveContains("local-first"))
        XCTAssertTrue(privacy.evidence.contains("PrivacyInfo.xcprivacy"))
        XCTAssertTrue(privacy.limitation.localizedCaseInsensitiveContains("App Store Connect"))

        let accessibility = try XCTUnwrap(
            ReleaseExternalTruthReadinessPacket.items.first { $0.area == .accessibilityClaims }
        )
        XCTAssertTrue(accessibility.evidence.contains("AccessibilityClaimsLock.publishableClaims empty"))
        XCTAssertEqual(accessibility.state, .blockedUntilManualProof)
        XCTAssertTrue(AccessibilityClaimsLock.publishableClaims.isEmpty)
    }

    func testR04DemoStoryUsesGoldenLaunchLoopWithoutCreatingNewTopLevelSurfaces() throws {
        let demo = try XCTUnwrap(
            ReleaseExternalTruthReadinessPacket.items.first { $0.area == .investorDemo }
        )

        XCTAssertTrue(demo.preparedStatement.contains("Capture"))
        XCTAssertTrue(demo.preparedStatement.contains("Goal"))
        XCTAssertTrue(demo.preparedStatement.contains("Time"))
        XCTAssertTrue(demo.preparedStatement.contains("Motion"))
        XCTAssertTrue(demo.preparedStatement.contains("Today"))
        XCTAssertTrue(demo.preparedStatement.contains("You"))
        XCTAssertFalse(demo.preparedStatement.contains("use Plan"))
        XCTAssertFalse(demo.preparedStatement.localizedCaseInsensitiveContains("Insights" + " tab"))
        XCTAssertFalse(demo.preparedStatement.localizedCaseInsensitiveContains("Tasks tab"))
        XCTAssertFalse(demo.preparedStatement.localizedCaseInsensitiveContains("Calendar tab"))
    }
}
