import Foundation

let dataClassProtectionMatrixSchemaVersion = "data_class_protection_matrix.native.v1"

enum DataClassProtectionArtifact: String, Codable, Sendable, Equatable, CaseIterable {
    case privateRuntimeArtifacts = "private_runtime_artifacts"
    case publicReferenceCache = "public_reference_cache"
    case appGroupSnapshots = "app_group_snapshots"
    case portableExports = "portable_exports"
    case diagnosticsBundles = "diagnostics_bundles"
}

struct DataClassProtectionRequirement: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let artifact: DataClassProtectionArtifact
    let title: String
    let runtimePrivacyClass: RuntimePrivacyClass
    let storagePrivacyClass: AFEPStoragePrivacyClass
    let destinations: [StoragePrivacyBoundaryDestination]
    let surfaces: [SensitiveSurface]
    let fileProtectionLevel: PrivacyFileProtectionLevel
    let localAuthRequiredForInspection: Bool
    let encryptedBlobVaultRequired: Bool
    let userReviewRequiredBeforeExternalUse: Bool
    let redactionRequiredOutsideLocalInspection: Bool
    let publicReferenceAllowed: Bool
    let sourcePolicyFiles: [String]
    let proofCeiling: String
}

struct DataClassProtectionMatrix: Codable, Sendable, Equatable {
    let schemaVersion: String
    let requirements: [DataClassProtectionRequirement]

    static let current = DataClassProtectionMatrix(
        schemaVersion: dataClassProtectionMatrixSchemaVersion,
        requirements: [
            DataClassProtectionRequirement(
                id: "data_class.private_runtime_artifacts",
                artifact: .privateRuntimeArtifacts,
                title: "Private runtime artifacts",
                runtimePrivacyClass: .privateUserText,
                storagePrivacyClass: .privateSensitive,
                destinations: [.localStore, .receiptReplayInspection, .whatAmbitionsKnows],
                surfaces: [.localInspection, .encryptedVault],
                fileProtectionLevel: .complete,
                localAuthRequiredForInspection: true,
                encryptedBlobVaultRequired: true,
                userReviewRequiredBeforeExternalUse: true,
                redactionRequiredOutsideLocalInspection: true,
                publicReferenceAllowed: false,
                sourcePolicyFiles: [
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/FileProtectionPolicy.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/LocalAuthGate.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/EncryptedBlobVault.swift"
                ],
                proofCeiling: Self.sourceInvariantOnly
            ),
            DataClassProtectionRequirement(
                id: "data_class.public_reference_cache",
                artifact: .publicReferenceCache,
                title: "Public reference cache",
                runtimePrivacyClass: .publicMetadata,
                storagePrivacyClass: .publicMetadata,
                destinations: [.localIndex],
                surfaces: [.searchIndex],
                fileProtectionLevel: .standard,
                localAuthRequiredForInspection: false,
                encryptedBlobVaultRequired: false,
                userReviewRequiredBeforeExternalUse: false,
                redactionRequiredOutsideLocalInspection: false,
                publicReferenceAllowed: true,
                sourcePolicyFiles: [
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/FileProtectionPolicy.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/StoragePrivacySecurityBoundary.swift"
                ],
                proofCeiling: Self.sourceInvariantOnly
            ),
            DataClassProtectionRequirement(
                id: "data_class.app_group_snapshots",
                artifact: .appGroupSnapshots,
                title: "App Group snapshots",
                runtimePrivacyClass: .standard,
                storagePrivacyClass: .systemOwned,
                destinations: [.localStore],
                surfaces: [.widgetSnapshot, .notificationContent],
                fileProtectionLevel: .completeUntilFirstUserAuthentication,
                localAuthRequiredForInspection: false,
                encryptedBlobVaultRequired: false,
                userReviewRequiredBeforeExternalUse: false,
                redactionRequiredOutsideLocalInspection: true,
                publicReferenceAllowed: false,
                sourcePolicyFiles: [
                    "Native/Ambitions/Core/LocalRuntimeOS/Storage/AppGroupSnapshotStore.swift",
                    "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceSnapshotWriter.swift"
                ],
                proofCeiling: Self.sourceInvariantOnly
            ),
            DataClassProtectionRequirement(
                id: "data_class.portable_exports",
                artifact: .portableExports,
                title: "Portable exports",
                runtimePrivacyClass: .privateSensitive,
                storagePrivacyClass: .privateSensitive,
                destinations: [.portableExport, .supportBundle],
                surfaces: [.portableExport],
                fileProtectionLevel: .complete,
                localAuthRequiredForInspection: true,
                encryptedBlobVaultRequired: true,
                userReviewRequiredBeforeExternalUse: true,
                redactionRequiredOutsideLocalInspection: true,
                publicReferenceAllowed: false,
                sourcePolicyFiles: [
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/ExportPolicy.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotContracts.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/Repair/ExportImportResetDataScopeMatrix.swift"
                ],
                proofCeiling: Self.sourceInvariantOnly
            ),
            DataClassProtectionRequirement(
                id: "data_class.diagnostics_bundles",
                artifact: .diagnosticsBundles,
                title: "Diagnostics bundles",
                runtimePrivacyClass: .privateSensitive,
                storagePrivacyClass: .privateSensitive,
                destinations: [.supportBundle],
                surfaces: [.diagnosticsExport],
                fileProtectionLevel: .complete,
                localAuthRequiredForInspection: true,
                encryptedBlobVaultRequired: true,
                userReviewRequiredBeforeExternalUse: true,
                redactionRequiredOutsideLocalInspection: true,
                publicReferenceAllowed: false,
                sourcePolicyFiles: [
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/RedactionEngine.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/PrivacySecurity/PrivacyExternalBoundaryGate.swift"
                ],
                proofCeiling: Self.sourceInvariantOnly
            )
        ]
    )

    func requirement(for artifact: DataClassProtectionArtifact) -> DataClassProtectionRequirement? {
        requirements.first { $0.artifact == artifact }
    }

    private static let sourceInvariantOnly = "source_invariant_only"
}
