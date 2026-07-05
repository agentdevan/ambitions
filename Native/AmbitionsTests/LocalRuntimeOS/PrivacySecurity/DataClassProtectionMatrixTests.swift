import XCTest
@testable import Ambitions

final class DataClassProtectionMatrixTests: XCTestCase {
    func testMatrixCoversCurrentDataClassesNamedByProtectionScope() {
        let matrix = DataClassProtectionMatrix.current

        XCTAssertEqual(matrix.schemaVersion, dataClassProtectionMatrixSchemaVersion)
        XCTAssertEqual(matrix.requirements.map(\.artifact), DataClassProtectionArtifact.allCases)
        XCTAssertEqual(Set(matrix.requirements.map(\.id)).count, matrix.requirements.count)
    }

    func testMatrixAgreesWithFileProtectionAndLocalAuthPoliciesForRepresentativeObjects() throws {
        let matrix = DataClassProtectionMatrix.current
        let filePolicy = FileProtectionPolicy()

        for requirement in matrix.requirements where requirement.artifact != .appGroupSnapshots {
            let object = PrivacyClassifiedObject(
                id: requirement.id,
                family: requirement.artifact.rawValue,
                title: requirement.title,
                privacyClass: requirement.runtimePrivacyClass
            )
            let fileDecision = filePolicy.decision(for: object)
            let localAuthDecision = LocalAuthGate().evaluate(
                LocalAuthGateRequest(
                    id: requirement.id,
                    object: object,
                    surface: .localInspection,
                    availability: .available,
                    authenticationSatisfied: false
                )
            )

            XCTAssertEqual(fileDecision.protectionLevel, requirement.fileProtectionLevel, requirement.id)
            XCTAssertEqual(fileDecision.requiresEncryptedBlobVault, requirement.encryptedBlobVaultRequired, requirement.id)
            XCTAssertEqual(localAuthDecision.required, requirement.localAuthRequiredForInspection, requirement.id)
            XCTAssertEqual(requirement.localAuthRequiredForInspection, requirement.runtimePrivacyClass.requiresLocalAuthentication, requirement.id)
        }
    }

    func testAppGroupSnapshotRequirementMatchesConcreteStorePolicy() throws {
        let requirement = try XCTUnwrap(DataClassProtectionMatrix.current.requirement(for: .appGroupSnapshots))

        XCTAssertEqual(requirement.fileProtectionLevel.rawValue, AppGroupSnapshotStore.snapshotFileProtectionPolicy)
        XCTAssertEqual(requirement.runtimePrivacyClass, .standard)
        XCTAssertEqual(requirement.storagePrivacyClass, .systemOwned)
        XCTAssertFalse(requirement.localAuthRequiredForInspection)
        XCTAssertFalse(requirement.encryptedBlobVaultRequired)
        XCTAssertTrue(requirement.redactionRequiredOutsideLocalInspection)
        XCTAssertTrue(requirement.sourcePolicyFiles.contains("Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift"))
        XCTAssertTrue(requirement.sourcePolicyFiles.contains("Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift"))
    }

    func testPrivatePortableAndDiagnosticsClassesStayReviewAuthAndVaultBound() throws {
        let privateArtifacts: [DataClassProtectionArtifact] = [
            .privateRuntimeArtifacts,
            .portableExports,
            .diagnosticsBundles
        ]

        for artifact in privateArtifacts {
            let requirement = try XCTUnwrap(DataClassProtectionMatrix.current.requirement(for: artifact))

            XCTAssertEqual(requirement.fileProtectionLevel, .complete, requirement.id)
            XCTAssertTrue(requirement.localAuthRequiredForInspection, requirement.id)
            XCTAssertTrue(requirement.encryptedBlobVaultRequired, requirement.id)
            XCTAssertTrue(requirement.userReviewRequiredBeforeExternalUse, requirement.id)
            XCTAssertTrue(requirement.redactionRequiredOutsideLocalInspection, requirement.id)
            XCTAssertFalse(requirement.publicReferenceAllowed, requirement.id)
        }
    }

    func testPublicReferenceCacheStaysPublicAndDoesNotRequireLocalAuthOrVault() throws {
        let requirement = try XCTUnwrap(DataClassProtectionMatrix.current.requirement(for: .publicReferenceCache))
        let object = PrivacyClassifiedObject(
            id: requirement.id,
            family: requirement.artifact.rawValue,
            title: requirement.title,
            privacyClass: requirement.runtimePrivacyClass
        )
        let surfaceDecision = SensitiveSurfacePolicy().decision(
            for: object,
            surface: .searchIndex,
            userReviewed: false,
            localAuthenticationSatisfied: false
        )

        XCTAssertEqual(requirement.runtimePrivacyClass, .publicMetadata)
        XCTAssertEqual(requirement.storagePrivacyClass, .publicMetadata)
        XCTAssertEqual(requirement.fileProtectionLevel, .standard)
        XCTAssertFalse(requirement.localAuthRequiredForInspection)
        XCTAssertFalse(requirement.encryptedBlobVaultRequired)
        XCTAssertFalse(requirement.redactionRequiredOutsideLocalInspection)
        XCTAssertTrue(requirement.publicReferenceAllowed)
        XCTAssertEqual(requirement.destinations, [.localIndex])
        XCTAssertEqual(requirement.surfaces, [.searchIndex])
        XCTAssertTrue(surfaceDecision.allowed)
        XCTAssertFalse(surfaceDecision.requiresLocalAuthentication)
    }
}
