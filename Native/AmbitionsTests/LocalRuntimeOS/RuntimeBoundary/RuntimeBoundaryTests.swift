@testable import Ambitions
import XCTest

final class RuntimeBoundaryTests: XCTestCase {
    func testRuntimeBoundaryCanonicalOwnerFilesExistAndOldBoundaryOwnersAreRemoved() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/PrivateLifeRuntimeBoundary.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/CapabilityMatrix.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/NetworkEgressPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/LocalOnlyMode.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/AccountBoundary.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/SourceAtlasBoundary.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/PrivacyBoundary.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/SourceAtlasNoPrivateGraphEgressAudit.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary/SourceAtlasPublicArtifactBoundary.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing RuntimeBoundary owner file: \(requiredPath)"
            )
        }

        for retiredPath in [
            removedRuntimeOwnerPath("PrivacyBoundary.swift"),
            removedRuntimeOwnerPath("SourceAtlasAccessBoundary.swift"),
            removedRuntimeOwnerPath("SourceAtlasNoPrivateGraphEgressAudit.swift"),
            "Native/Ambitions/Core/Persistence/SourceAtlasPublicArtifactPrivacyBoundary.swift",
        ] {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(retiredPath).path),
                "Retired RuntimeBoundary path still exists: \(retiredPath)"
            )
        }
    }

    func testLocalOnlyModeAndCapabilityMatrixBlockHostedRuntimeDependencies() {
        let boundary = PrivateLifeRuntimeBoundary.localOnly
        let localOnlyMode = boundary.localOnlyMode
        let matrix = AmbitionsRuntimeCapabilities.currentLocalRuntime.capabilityMatrix

        XCTAssertTrue(boundary.isLocalOnly)
        XCTAssertTrue(localOnlyMode.isSatisfied)
        XCTAssertTrue(localOnlyMode.offlineCoreAvailable)
        XCTAssertFalse(localOnlyMode.accountRequiredForCoreValue)
        XCTAssertTrue(matrix.isLocalOnlySatisfied)
        XCTAssertTrue(matrix.decision(for: .offlineCoreRuntime).permitted)
        XCTAssertTrue(matrix.decision(for: .sourceAtlasPublicReference).permitted)
        XCTAssertFalse(matrix.decision(for: .hostedPrivateLifeGraph).permitted)
        XCTAssertFalse(matrix.decision(for: .remoteIntelligenceBackend).permitted)
        XCTAssertFalse(matrix.decision(for: .externalCloudLLMDependency).permitted)
        XCTAssertFalse(matrix.decision(for: .externalSideEffectsInsideUnitOfWork).permitted)
    }

    func testAccountBoundaryDoesNotGateOfflineCoreOrPermitPrivateGraphSync() {
        let boundary = AccountBoundary()

        let offlineCore = boundary.resolve(AccountBoundaryRequest(capability: .offlineCoreRuntime, sessionState: .noAccount))
        let accountIdentity = boundary.resolve(AccountBoundaryRequest(capability: .accountIdentity, sessionState: .noAccount))
        let privateGraphSync = boundary.resolve(AccountBoundaryRequest(capability: .privateGraphSync, sessionState: .signedIn))

        XCTAssertTrue(offlineCore.permitted)
        XCTAssertTrue(offlineCore.offlineCoreAvailable)
        XCTAssertFalse(offlineCore.requiresAccountProviderFlow)
        XCTAssertFalse(offlineCore.touchesPrivateLifeGraph)

        XCTAssertFalse(accountIdentity.permitted)
        XCTAssertTrue(accountIdentity.offlineCoreAvailable)
        XCTAssertEqual(accountIdentity.issues, [.noAccount])

        XCTAssertFalse(privateGraphSync.permitted)
        XCTAssertTrue(privateGraphSync.touchesPrivateLifeGraph)
        XCTAssertEqual(privateGraphSync.issues, [.privateGraphSyncForbidden, .hostedPrivateGraphForbidden])
    }

    func testNetworkEgressPolicyPermitsOnlyPublicReferenceAndAccountIdentityRequests() {
        let policy = NetworkEgressPolicy()

        let publicReference = policy.evaluate(NetworkEgressRequest(
            destination: .r2PublicReference,
            purpose: .publicReferenceFreshness,
            payloadClass: .publicReference,
            identifier: "public-pack",
            inspectedValue: "pack_id=public-sports manifest_version=manifest.v1 sha256=\(String(repeating: "a", count: 64))"
        ))
        let accountIdentity = policy.evaluate(NetworkEgressRequest(
            destination: .accountIdentity,
            purpose: .accountAuthentication,
            payloadClass: .accountCredential,
            identifier: "account-auth",
            inspectedValue: "provider=apple nonce=local_ephemeral"
        ))
        let privateR2 = policy.evaluate(NetworkEgressRequest(
            destination: .r2PublicReference,
            purpose: .privateLifeGraphStorage,
            payloadClass: .privateLifeGraph,
            identifier: "private-graph",
            inspectedValue: "private_graph_id=node-1 goal_text=private"
        ))
        let hostedGraph = policy.evaluate(NetworkEgressRequest(
            destination: .hostedPrivateLifeGraph,
            purpose: .privateLifeGraphStorage,
            payloadClass: .privateLifeGraph,
            identifier: "hosted-private-graph",
            inspectedValue: "private_graph_id=node-1"
        ))
        let cloudLLM = policy.evaluate(NetworkEgressRequest(
            destination: .externalCloudLLM,
            purpose: .remoteInference,
            payloadClass: .privateRuntimeData,
            identifier: "remote-llm",
            inspectedValue: "capture_text=private"
        ))

        XCTAssertTrue(publicReference.permitted)
        XCTAssertFalse(publicReference.touchesPrivateLifeGraph)
        XCTAssertEqual(publicReference.findings, [])
        XCTAssertTrue(accountIdentity.permitted)
        XCTAssertFalse(accountIdentity.touchesPrivateLifeGraph)

        XCTAssertFalse(privateR2.permitted)
        XCTAssertTrue(privateR2.touchesPrivateLifeGraph)
        XCTAssertTrue(privateR2.issues.contains(.privateGraphPayloadForbidden))
        XCTAssertTrue(privateR2.issues.contains(.privateGraphMarkerDetected))
        XCTAssertFalse(hostedGraph.permitted)
        XCTAssertTrue(hostedGraph.issues.contains(.hostedPrivateGraphForbidden))
        XCTAssertFalse(cloudLLM.permitted)
        XCTAssertTrue(cloudLLM.issues.contains(.externalCloudLLMForbidden))
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/RuntimeBoundary")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
