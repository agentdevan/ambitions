import XCTest
@testable import AmbitionsNativeVisualFoundry

final class YouNativeCalibrationFixtureTests: XCTestCase {
    private let fixture = YouNativeCalibrationFixture.flagship

    func testFixturePreservesIdentityOrderAndConciseRootTruth() throws {
        XCTAssertEqual(
            fixture.domains.map(\.id),
            [
                .identityAndLocalData,
                .personalization,
                .privacyAndData,
                .appearance,
                .notificationsAndAttention,
                .connectionsAndPermissions,
                .accessibilityAndInteraction,
                .appBehavior,
                .aboutAmbitions
            ]
        )
        XCTAssertEqual(
            try XCTUnwrap(fixture.domain(.identityAndLocalData)).summary,
            "On this iPhone · No account"
        )
        XCTAssertEqual(
            try XCTUnwrap(fixture.domain(.personalization)).summary,
            "Today · Review every 7 days"
        )
        XCTAssertEqual(
            try XCTUnwrap(fixture.domain(.privacyAndData)).summary,
            "Stored locally"
        )
        XCTAssertEqual(
            try XCTUnwrap(fixture.domain(.appearance)).summary,
            "System"
        )
        XCTAssertEqual(
            try XCTUnwrap(fixture.domain(.notificationsAndAttention)).summary,
            "Allowed"
        )
    }

    func testFixtureKeepsCapabilityAndProvenanceBoundariesExact() {
        XCTAssertEqual(
            fixture.permissionFamilies,
            [.calendar, .reminders, .notifications, .contextualLocalAuthentication]
        )
        XCTAssertEqual(
            fixture.personalizationTruthStates,
            [
                .personEntered,
                .confirmed,
                .suggested,
                .inferred,
                .uncertain,
                .historical,
                .superseded,
                .removed
            ]
        )
        XCTAssertFalse(fixture.hasAmbitionsAccount)
        XCTAssertFalse(fixture.supportsCloudContinuity)
        XCTAssertFalse(fixture.supportsSubscriptions)
        XCTAssertFalse(fixture.supportsBroadDataCommands)
    }

    func testAppearanceFixtureKeepsTheAccentMismatchExplicit() {
        XCTAssertEqual(fixture.appearance.current, .system)
        XCTAssertEqual(fixture.appearance.availableModes, [.system, .light, .dark])
        XCTAssertEqual(fixture.appearance.provisionalAccent.name, "Violet–indigo")
        XCTAssertFalse(fixture.appearance.provisionalAccent.matchesProductionEnum)
        XCTAssertEqual(
            fixture.appearance.provisionalAccent.posture,
            "Visual-authority target · Production enum unresolved"
        )
    }
}
