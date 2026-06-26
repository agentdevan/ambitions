import XCTest
@testable import Ambitions

final class SourceAtlasOfflineNoAccountScenarioTests: XCTestCase {
    func testOfflineNoAccountKeepsPrivateLifeRuntimeLocalAndCoreSurfacesAvailable() {
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .offline,
                cachedPublicArtifactAvailable: false,
                lastKnownGoodAvailable: false,
                bundledPublicArtifactAvailable: true
            )
        )

        XCTAssertEqual(access.route, .bundledLocal)
        XCTAssertTrue(access.issues.contains(.offline))
        XCTAssertFalse(access.permitsRemotePublicReference)
        XCTAssertTrue(access.permitsPublicCacheRead)
        XCTAssertFalse(access.coreLocalPlanningBlocked)
        XCTAssertFalse(access.privateRuntimeDataTouched)
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.privateLifeRuntimeBoundary, .localOnly)
        XCTAssertEqual(AmbitionsRuntimeCapabilities.currentLocalRuntime.syncBackendKind, .localOnly)
        XCTAssertFalse(AmbitionsRuntimeCapabilities.currentLocalRuntime.hasRemoteIntelligenceBackend)
    }

    func testOfflineNoAccountWithoutAnySourceAtlasPackReturnsHonestUnavailableStateOnlyForReferenceUpdate() {
        let access = SourceAtlasAccessBoundary().resolve(
            SourceAtlasAccessRequest(
                artifactTier: .publicFreshness,
                accountSessionState: .noAccount,
                entitlementState: .bundledOnly,
                networkReachability: .offline,
                cachedPublicArtifactAvailable: false,
                lastKnownGoodAvailable: false,
                bundledPublicArtifactAvailable: false
            )
        )

        XCTAssertEqual(access.route, .unavailable)
        XCTAssertEqual(access.issues, [.offline, .noCachedPublicReference])
        XCTAssertEqual(access.unavailableStateTitle, "Reference update unavailable")
        XCTAssertTrue(access.unavailableStateDetail.contains("without an account"))
        XCTAssertFalse(access.coreLocalPlanningBlocked)
        XCTAssertFalse(access.privateRuntimeDataTouched)
    }
}
