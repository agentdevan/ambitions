import Foundation
import XCTest
@testable import Ambitions

final class ReleasePrivacyProtectedStorageReportTests: XCTestCase {
    func testAFEP023PacketCoversEveryRequiredFieldCategory() {
        let packet = ReleasePrivacyProtectedStorageReport.packet

        XCTAssertEqual(packet.fieldPolicies.map(\.category), AFEP023FieldCategory.allCases)
        XCTAssertEqual(packet.fieldPolicies.count, AFEP023FieldCategory.allCases.count)
        XCTAssertTrue(packet.isWellFormed)
        XCTAssertTrue(packet.fieldPolicies.allSatisfy(\.isConservativelyProtected))
        XCTAssertTrue(packet.fieldPolicies.allSatisfy { $0.mutationPolicy.allowsExternalRawProjection == false })
        XCTAssertTrue(packet.fieldPolicies.allSatisfy { $0.mutationPolicy.localOnlyDefault })
    }

    func testAFEP023StorageClassPoliciesStaySimulatorSafeAndRuntimeUnwired() {
        let storagePolicies = ReleasePrivacyProtectedStorageReport.packet.storageClassPolicies

        XCTAssertEqual(
            storagePolicies.map(\.storageClass),
            AFEP023ProtectedStorageClass.allCases
        )
        XCTAssertTrue(storagePolicies.allSatisfy { $0.simulatorSafe && $0.runtimeWiringEnabled == false })
        XCTAssertTrue(storagePolicies.contains { $0.storageClass == .appGroup })
        XCTAssertTrue(storagePolicies.contains { $0.storageClass == .keychain })
        XCTAssertTrue(storagePolicies.contains { $0.storageClass == .protectedLocalFile })
        XCTAssertTrue(storagePolicies.contains { $0.storageClass == .swiftDataLocalStore })
        XCTAssertTrue(storagePolicies.contains { $0.storageClass == .inMemoryProjection })
    }

    func testAFEP023ManifestAlignmentMatchesCheckedInPrivacyManifest() throws {
        let manifest = try loadPrivacyManifest()
        let packet = ReleasePrivacyProtectedStorageReport.packet
        let alignment = packet.privacyManifestAlignment

        XCTAssertEqual(manifest["NSPrivacyTracking"] as? Bool, false)
        XCTAssertEqual((manifest["NSPrivacyCollectedDataTypes"] as? [Any])?.count, 0)
        XCTAssertEqual((manifest["NSPrivacyAccessedAPITypes"] as? [Any])?.count, 0)
        XCTAssertTrue(alignment.alignedWithCurrentManifest)
        XCTAssertEqual(alignment.trackingDeclared, false)
        XCTAssertEqual(alignment.collectedDataTypesDeclared, 0)
        XCTAssertEqual(alignment.accessedAPITypesDeclared, 0)
        XCTAssertTrue(alignment.evidenceSummary.contains("no tracking"))
        XCTAssertTrue(packet.noCloudBackendDependency)
        XCTAssertTrue(packet.noExternalRawProjection)
        XCTAssertTrue(packet.noRuntimeStorageAccess)
    }

    func testAFEP023PacketKeepsLocalInputActionHistoryAndContinuationAnchorsVisible() {
        let packet = ReleasePrivacyProtectedStorageReport.packet

        XCTAssertTrue(packet.localInputAnchors.contains("Capture composer intake"))
        XCTAssertTrue(packet.localInputAnchors.contains("Start Here / Reality Meridian"))
        XCTAssertTrue(packet.actionHistoryAnchors.contains("Action receipt history"))
        XCTAssertTrue(packet.actionHistoryAnchors.contains("Correction history"))
        XCTAssertTrue(packet.continuationHistoryAnchors.contains("Relaunch continuity snapshots"))
        XCTAssertTrue(packet.userInspectionPolicy.contains("redacted"))
        XCTAssertTrue(packet.releaseBoundarySummary.contains("pure support/report scaffold"))
    }

    func testAFEP023RollbackGateRestoresConservativeDefaultsWithoutUnlockingClaims() {
        let packet = ReleasePrivacyProtectedStorageReport.packet

        XCTAssertTrue(packet.rollbackGate.available)
        XCTAssertTrue(packet.rollbackGate.restoresConservativeAFRIPolicy)
        XCTAssertTrue(packet.rollbackGate.rollbackSummary.contains("conservative local-only privacy defaults"))
        XCTAssertFalse(packet.claimLock.publicPrivacyApprovalUnlocked)
        XCTAssertFalse(packet.claimLock.legalApprovalUnlocked)
        XCTAssertFalse(packet.claimLock.releaseApprovalUnlocked)
        XCTAssertFalse(packet.claimLock.privacyCertificationUnlocked)
        XCTAssertTrue(packet.claimLock.noClaimBoundary.contains("does not unlock public, legal, release, or privacy certification claims"))
    }

    func testAFEP023SpecificSensitiveFieldsRemainLocalOnlyOrRedacted() throws {
        let packet = ReleasePrivacyProtectedStorageReport.packet

        let youField = try XCTUnwrap(packet.fieldPolicies.first { $0.category == .you })
        let captureField = try XCTUnwrap(packet.fieldPolicies.first { $0.category == .capture })
        let continuityField = try XCTUnwrap(packet.fieldPolicies.first { $0.category == .continuitySnapshots })

        XCTAssertEqual(youField.storageClass, .keychain)
        XCTAssertEqual(youField.fieldPolicy.privacyClass, .privateSensitive)
        XCTAssertEqual(youField.fieldPolicy.exportPolicy, .redacted)
        XCTAssertFalse(youField.mutationPolicy.allowsExternalRawProjection)

        XCTAssertEqual(captureField.storageClass, .protectedLocalFile)
        XCTAssertEqual(captureField.fieldPolicy.exportPolicy, .redacted)
        XCTAssertFalse(captureField.mutationPolicy.allowsExternalRawProjection)

        XCTAssertEqual(continuityField.storageClass, .inMemoryProjection)
        XCTAssertEqual(continuityField.fieldPolicy.privacyClass, .localOnly)
        XCTAssertFalse(continuityField.mutationPolicy.allowsExternalRawProjection)
    }

    private func loadPrivacyManifest() throws -> [String: Any] {
        let manifestURL = try privacyManifestURL()
        let data = try Data(contentsOf: manifestURL)
        var format = PropertyListSerialization.PropertyListFormat.xml
        let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: &format)
        guard let dictionary = plist as? [String: Any] else {
            XCTFail("Expected PrivacyInfo.xcprivacy to decode as a dictionary")
            return [:]
        }
        return dictionary
    }

    private func privacyManifestURL() throws -> URL {
        let testFileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = testFileURL
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        let manifestURL = repoRoot.appendingPathComponent("Native/Ambitions/Resources/PrivacyInfo.xcprivacy")
        guard FileManager.default.fileExists(atPath: manifestURL.path) else {
            throw NSError(domain: "AFEP023Tests", code: 1, userInfo: [NSLocalizedDescriptionKey: "Privacy manifest not found at \(manifestURL.path)"])
        }
        return manifestURL
    }
}
