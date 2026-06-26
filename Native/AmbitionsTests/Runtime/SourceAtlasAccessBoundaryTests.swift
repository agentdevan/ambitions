import XCTest
@testable import Ambitions

final class SourceAtlasAccessBoundaryTests: XCTestCase {
    func testNoAccountOfflineBundledCoreKeepsLocalPlanningUnblocked() {
        let decision = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .bundledCore,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .offline,
                bundledPublicArtifactAvailable: true
            )
        )

        XCTAssertEqual(decision.route, .bundledLocal)
        XCTAssertTrue(decision.issues.isEmpty)
        XCTAssertFalse(decision.permitsRemotePublicReference)
        XCTAssertTrue(decision.permitsPublicCacheRead)
        XCTAssertFalse(decision.coreLocalPlanningBlocked)
        XCTAssertFalse(decision.privateRuntimeDataTouched)
    }

    func testSignedInEntitledOnlineMayRequestRemotePublicReference() {
        let decision = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .signedIn,
                entitlementState: .entitled,
                networkReachability: .online,
                cachedPublicArtifactAvailable: true
            )
        )

        XCTAssertEqual(decision.route, .remotePublicReference)
        XCTAssertTrue(decision.issues.isEmpty)
        XCTAssertTrue(decision.permitsRemotePublicReference)
        XCTAssertFalse(decision.permitsPublicCacheRead)
        XCTAssertFalse(decision.coreLocalPlanningBlocked)
        XCTAssertFalse(decision.privateRuntimeDataTouched)
    }

    func testExpiredEntitlementFallsBackToCachedPublicArtifact() {
        let decision = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .signedIn,
                entitlementState: .expired,
                networkReachability: .online,
                cachedPublicArtifactAvailable: true
            )
        )

        XCTAssertEqual(decision.route, .cachedPublic)
        XCTAssertEqual(decision.issues, [.entitlementExpired])
        XCTAssertFalse(decision.permitsRemotePublicReference)
        XCTAssertTrue(decision.permitsPublicCacheRead)
        XCTAssertFalse(decision.coreLocalPlanningBlocked)
    }

    func testNoAccountEntitlementPackUsesHonestUnavailableStateWithoutAccountWallingCore() {
        let decision = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .noAccount,
                entitlementState: .denied,
                networkReachability: .offline,
                cachedPublicArtifactAvailable: false,
                lastKnownGoodAvailable: false,
                bundledPublicArtifactAvailable: false
            )
        )

        XCTAssertEqual(decision.route, .unavailable)
        XCTAssertEqual(decision.issues, [.noAccount, .entitlementDenied, .offline, .noCachedPublicReference])
        XCTAssertFalse(decision.permitsRemotePublicReference)
        XCTAssertFalse(decision.permitsPublicCacheRead)
        XCTAssertFalse(decision.coreLocalPlanningBlocked)
        XCTAssertFalse(decision.privateRuntimeDataTouched)
        XCTAssertEqual(decision.unavailableStateTitle, "Reference update unavailable")
        XCTAssertTrue(decision.unavailableStateDetail.contains("local planning"))
    }

    func testSignOutTransitionKeepsPublicCacheSeparateFromPrivateRuntimeData() {
        let signedIn = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .signedIn,
                entitlementState: .entitled,
                networkReachability: .online,
                cachedPublicArtifactAvailable: true
            )
        )
        let signedOut = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .entitlementReferencePack,
                accountSessionState: .signedOut,
                entitlementState: .bundledOnly,
                networkReachability: .offline,
                cachedPublicArtifactAvailable: true
            )
        )

        XCTAssertEqual(signedIn.route, .remotePublicReference)
        XCTAssertEqual(signedOut.route, .cachedPublic)
        XCTAssertEqual(signedOut.issues, [.signedOut, .entitlementDenied, .offline])
        XCTAssertFalse(signedOut.coreLocalPlanningBlocked)
        XCTAssertFalse(signedOut.privateRuntimeDataTouched)
    }
}
