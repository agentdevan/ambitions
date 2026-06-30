import CryptoKit
@testable import Ambitions
import XCTest

final class PrivacySecurityTests: XCTestCase {
    private let classifier = PrivacyClassifier()

    func testPrivacySecurityCanonicalOwnerFilesExistAndOldStorageBoundaryOwnerIsRemoved() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyClassifier.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/RedactionEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EgressFirewall.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/ExportPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/LocalAuthGate.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/FileProtectionPolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EncryptedBlobVault.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyManifestRuntimeMap.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/SensitiveSurfacePolicy.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/StoragePrivacySecurityBoundary.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing PrivacySecurity owner file: \(requiredPath)"
            )
        }

        XCTAssertFalse(
            FileManager.default.fileExists(atPath: root.appendingPathComponent("Native/Ambitions/Core/Persistence/StoragePrivacySecurityBoundary.swift").path)
        )
    }

    func testRedactionEngineHidesPrivateNotificationPayloadAndKeepsInspectionPath() {
        let object = privateObject()
        let result = RedactionEngine().redact(
            PrivacyRedactionRequest(
                object: object,
                surface: .notificationContent,
                title: "Call therapist",
                summary: "Discuss recovery details",
                metadata: ["goalID": "goal-1", "tone": "sensitive"],
                payload: ["rawNote": "Discuss recovery details"],
                userReviewed: true
            )
        )

        XCTAssertTrue(result.redactionApplied)
        XCTAssertEqual(result.visibleTitle, "Private life item")
        XCTAssertEqual(result.visibleSummary, "Details hidden. Open Ambitions to inspect locally.")
        XCTAssertEqual(result.metadataKeys, ["goalID", "tone"])
        XCTAssertEqual(result.payloadKeys, ["rawNote"])
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("Call therapist"))
        XCTAssertFalse(result.egressRecord.inspectedValue.contains("Discuss recovery details"))
        XCTAssertEqual(SourceAtlasNoPrivateGraphEgressAudit.validate([result.egressRecord]), [])
    }

    func testEgressFirewallBlocksPrivateR2AndPermitsPublicReferencePayload() {
        let firewall = EgressFirewall()
        let privateDecision = firewall.evaluate(
            PrivacyEgressAttempt(
                id: "private-r2",
                destination: .r2PublicReference,
                purpose: .publicReferenceFreshness,
                redactionRequest: PrivacyRedactionRequest(
                    object: privateObject(),
                    surface: .sourceAtlasPublicReference,
                    title: "Private goal",
                    summary: "Private plan",
                    payload: ["private": "value"],
                    userReviewed: true
                )
            )
        )

        XCTAssertFalse(privateDecision.permitted)
        XCTAssertFalse(privateDecision.receipt.permitted)
        XCTAssertTrue(privateDecision.receipt.issueCodes.contains(SensitiveSurfaceIssue.publicReferenceForbidden.rawValue))
        XCTAssertTrue(privateDecision.receipt.issueCodes.contains(NetworkEgressIssue.privateGraphPayloadForbidden.rawValue))

        let publicObject = PrivacyClassifiedObject(
            id: "source-pack-rule",
            family: "source_atlas",
            title: "Public source pack rule",
            privacyClass: .publicMetadata,
            containsUserText: false
        )
        let publicDecision = firewall.evaluate(
            PrivacyEgressAttempt(
                id: "public-r2",
                destination: .r2PublicReference,
                purpose: .publicReferenceFreshness,
                redactionRequest: PrivacyRedactionRequest(
                    object: publicObject,
                    surface: .sourceAtlasPublicReference,
                    title: "Public source pack rule",
                    summary: "Public manifest metadata",
                    metadata: ["pack": "public"],
                    userReviewed: true
                )
            )
        )

        XCTAssertTrue(publicDecision.permitted)
        XCTAssertTrue(publicDecision.receipt.permitted)
        XCTAssertFalse(publicDecision.redaction.redactionApplied)
        XCTAssertEqual(publicDecision.networkDecision.issues, [])
    }

    func testExportPolicyRequiresUserReviewAndPermitsReviewedPortableManifest() {
        let manifest = PortableExportManifest.make(
            selection: .all,
            goals: [],
            drafts: [],
            evidence: [],
            feedback: [],
            captures: [],
            teachingSignals: [],
            appState: .default
        )
        let records = StoragePrivacyBoundaryCatalog.records(from: manifest, userReviewed: true)
        let policy = ExportPolicy()

        let unreviewed = policy.evaluate(
            PrivacyExportRequest(
                id: "portable-unreviewed",
                destination: .portablePackage,
                records: records,
                userReviewed: false
            )
        )
        XCTAssertFalse(unreviewed.permitted)
        XCTAssertTrue(unreviewed.report.findings.map(\.issue).contains(.userReviewMissing))

        let reviewed = policy.evaluate(
            PrivacyExportRequest(
                id: "portable-reviewed",
                destination: .portablePackage,
                records: records,
                userReviewed: true
            )
        )
        XCTAssertTrue(reviewed.permitted)
        XCTAssertTrue(reviewed.receipt.permitted)
        XCTAssertFalse(reviewed.allowedProjectionIDs.isEmpty)
        XCTAssertTrue(reviewed.receipt.redactionApplied)
    }

    func testLocalAuthGateAndEncryptedBlobVaultProtectPrivatePayload() async throws {
        let object = privateObject()
        let gate = LocalAuthGate()

        let blocked = gate.evaluate(
            LocalAuthGateRequest(
                id: "private-inspection",
                object: object,
                surface: .localInspection,
                availability: .available,
                authenticationSatisfied: false
            )
        )
        XCTAssertTrue(blocked.required)
        XCTAssertFalse(blocked.permitted)
        XCTAssertTrue(blocked.issues.contains(.authenticationNotSatisfied))

        let allowed = gate.evaluate(
            LocalAuthGateRequest(
                id: "private-inspection",
                object: object,
                surface: .localInspection,
                availability: .available,
                authenticationSatisfied: true
            )
        )
        XCTAssertTrue(allowed.permitted)

        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("PrivacySecurityTests-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: root) }

        let blobStore = BlobStoreFileSystem(rootDirectory: root)
        let vault = EncryptedBlobVault(blobStore: blobStore)
        let key = SymmetricKey(size: .bits256)
        let plaintext = Data("private payload".utf8)
        let write = try await vault.sealAndWrite(
            id: "private-payload",
            object: object,
            plaintext: plaintext,
            contentType: "text/plain",
            key: key,
            keyID: "test-key",
            createdAt: "2026-06-30T10:30:00Z"
        )

        XCTAssertTrue(write.receipt.permitted)
        XCTAssertEqual(write.record.privacyClass, .privateUserText)
        XCTAssertEqual(write.record.blobRecord.protectionClass, .complete)

        let encryptedBytes = try await blobStore.read(id: write.record.blobRecord.id)
        XCTAssertNotEqual(encryptedBytes, plaintext)
        let opened = try await vault.open(write.record, key: key)
        XCTAssertEqual(opened, plaintext)
    }

    func testPrivacyManifestRuntimeMapPreservesLocalOnlyNoTrackingBoundary() {
        let decision = PrivacyManifestRuntimeMap().evaluate(
            PrivacyManifestRuntimeFacts(
                trackingEnabled: false,
                collectedDataTypeCount: 0,
                accessedAPITypeCount: 0
            )
        )

        XCTAssertTrue(decision.isSatisfied)
        XCTAssertTrue(decision.localOnlyRuntime)
        XCTAssertFalse(decision.trackingEnabled)
        XCTAssertEqual(decision.collectedDataTypeCount, 0)
    }

    private func privateObject() -> PrivacyClassifiedObject {
        classifier.classifyEvent(
            id: "private-goal-note",
            family: "goal",
            title: "Private goal note",
            privacy: .privateUserText,
            sourcePath: "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity"
        )
    }

    private func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }
}
