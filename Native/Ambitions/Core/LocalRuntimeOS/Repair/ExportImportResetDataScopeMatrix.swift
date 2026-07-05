import Foundation

enum ExportImportResetScopeKind: String, Codable, Sendable, Equatable {
    case portableCategory = "portable_category"
    case excludedExternalScope = "excluded_external_scope"
}

enum ExportImportResetImportSemantics: String, Codable, Sendable, Equatable {
    case replacesLocalStoreAfterConfirmedReset = "replaces_local_store_after_confirmed_reset"
    case mergesAfterConflictReport = "merges_after_conflict_report"
    case excludedFromPortableImport = "excluded_from_portable_import"
}

enum ExportImportResetProofCeiling: String, Codable, Sendable, Equatable {
    case sourceInvariantOnly = "source_invariant_only"
}

struct ExportImportResetModeSemantics: Codable, Sendable, Equatable {
    let mode: PortableImportMode
    let wouldResetLocalStore: Bool
    let requiresExplicitConfirmation: Bool
    let conflictReportRequired: Bool
    let durableDryRunMutationAllowed: Bool
    let destructiveResetAllowed: Bool
    let sourceContractFiles: [String]
    let safetySummary: String
}

struct ExportImportResetDataScopeRow: Identifiable, Codable, Sendable, Equatable {
    let id: String
    let title: String
    let kind: ExportImportResetScopeKind
    let category: PortableExportCategory?
    let storedDataKinds: [String]
    let includedInPortablePackage: Bool
    let privacyClass: AFEPStoragePrivacyClass?
    let indexingPolicy: AFEPIndexingPolicy?
    let exportPolicy: AFEPExportPolicy?
    let measurementEvidenceState: AFEPMeasurementEvidenceState?
    let containsSensitiveUserText: Bool
    let userReviewRequired: Bool
    let previewRule: String
    let detail: String
    let replaceModeSemantics: ExportImportResetImportSemantics
    let mergeModeSemantics: ExportImportResetImportSemantics
    let replaceModeMayResetLocalStore: Bool
    let mergeModeMayResetLocalStore: Bool
    let requiresExplicitConfirmationBeforeReset: Bool
    let destructiveResetAllowed: Bool
    let durableDryRunMutationAllowed: Bool
    let sourceContractFiles: [String]
    let proofCeiling: ExportImportResetProofCeiling
    let nonClaimBoundary: String
}

enum ExportImportResetDataScopeMatrix {
    static let schemaVersion = "export_import_reset_scope_matrix.v1"

    static let portableCategoryRows: [ExportImportResetDataScopeRow] = PortableExportCategory.allCases.map {
        makePortableCategoryRow(for: $0)
    }

    static let excludedScopeRows: [ExportImportResetDataScopeRow] = [
        makeExcludedScopeRow(
            id: "excluded.raw-calendar-events",
            title: "Raw calendar events",
            detail: "Ambitions exports local derived planning context, not raw calendar event titles.",
            sourceContractFiles: [
                "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotContracts.swift",
                "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotService.swift"
            ]
        ),
        makeExcludedScopeRow(
            id: "excluded.cloud-sync-account",
            title: "Cloud sync or account data",
            detail: "No cloud account, sync payload, or hosted private storage is part of the local portable package.",
            sourceContractFiles: [
                "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotContracts.swift",
                "docs/truth/PRIVATE_LIFE_ORCHESTRATION_TRUTH.md"
            ]
        ),
        makeExcludedScopeRow(
            id: "excluded.external-rendered-state",
            title: "Rendered widget or Live Activity state",
            detail: "External surfaces rebuild from safe local snapshots; rendered platform state is not portable user data.",
            sourceContractFiles: [
                "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotContracts.swift",
                "Native/Ambitions/Projection/ExternalSnapshots/ExternalSurfaceScopeAllowlist.swift"
            ]
        )
    ]

    static var rows: [ExportImportResetDataScopeRow] {
        portableCategoryRows + excludedScopeRows
    }

    static func row(for category: PortableExportCategory) -> ExportImportResetDataScopeRow? {
        portableCategoryRows.first { $0.category == category }
    }

    static func excludedRow(id: String) -> ExportImportResetDataScopeRow? {
        excludedScopeRows.first { $0.id == id }
    }

    static func modeSemantics(for mode: PortableImportMode) -> ExportImportResetModeSemantics {
        switch mode {
        case .replaceLocalStore:
            return ExportImportResetModeSemantics(
                mode: mode,
                wouldResetLocalStore: true,
                requiresExplicitConfirmation: true,
                conflictReportRequired: false,
                durableDryRunMutationAllowed: false,
                destructiveResetAllowed: false,
                sourceContractFiles: [
                    "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceOperations.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableAppSnapshot.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/Repair/DryRunMigration.swift"
                ],
                safetySummary: "Replace-local-store import may reset local storage only after explicit review; dry run never mutates."
            )
        case .mergeWithConflictReport:
            return ExportImportResetModeSemantics(
                mode: mode,
                wouldResetLocalStore: false,
                requiresExplicitConfirmation: false,
                conflictReportRequired: true,
                durableDryRunMutationAllowed: false,
                destructiveResetAllowed: false,
                sourceContractFiles: [
                    "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceOperations.swift",
                    "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableAppSnapshot.swift"
                ],
                safetySummary: "Merge import reports conflicts and does not reset local storage."
            )
        }
    }

    private static func makePortableCategoryRow(
        for category: PortableExportCategory
    ) -> ExportImportResetDataScopeRow {
        ExportImportResetDataScopeRow(
            id: category.rawValue,
            title: category.title,
            kind: .portableCategory,
            category: category,
            storedDataKinds: storedDataKinds(for: category),
            includedInPortablePackage: true,
            privacyClass: category.privacyClass,
            indexingPolicy: category.indexingPolicy,
            exportPolicy: category.exportPolicy,
            measurementEvidenceState: category.measurementEvidenceState,
            containsSensitiveUserText: category.containsSensitiveUserText,
            userReviewRequired: category.exportPolicy == .exportReviewOnly,
            previewRule: category.previewRule,
            detail: category.detail,
            replaceModeSemantics: .replacesLocalStoreAfterConfirmedReset,
            mergeModeSemantics: .mergesAfterConflictReport,
            replaceModeMayResetLocalStore: true,
            mergeModeMayResetLocalStore: false,
            requiresExplicitConfirmationBeforeReset: true,
            destructiveResetAllowed: false,
            durableDryRunMutationAllowed: false,
            sourceContractFiles: [
                "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotContracts.swift",
                "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceOperations.swift"
            ],
            proofCeiling: .sourceInvariantOnly,
            nonClaimBoundary: nonClaimBoundary
        )
    }

    private static func makeExcludedScopeRow(
        id: String,
        title: String,
        detail: String,
        sourceContractFiles: [String]
    ) -> ExportImportResetDataScopeRow {
        ExportImportResetDataScopeRow(
            id: id,
            title: title,
            kind: .excludedExternalScope,
            category: nil,
            storedDataKinds: [],
            includedInPortablePackage: false,
            privacyClass: nil,
            indexingPolicy: nil,
            exportPolicy: nil,
            measurementEvidenceState: nil,
            containsSensitiveUserText: false,
            userReviewRequired: false,
            previewRule: "Excluded from portable package preview.",
            detail: detail,
            replaceModeSemantics: .excludedFromPortableImport,
            mergeModeSemantics: .excludedFromPortableImport,
            replaceModeMayResetLocalStore: false,
            mergeModeMayResetLocalStore: false,
            requiresExplicitConfirmationBeforeReset: false,
            destructiveResetAllowed: false,
            durableDryRunMutationAllowed: false,
            sourceContractFiles: sourceContractFiles,
            proofCeiling: .sourceInvariantOnly,
            nonClaimBoundary: nonClaimBoundary
        )
    }

    private static func storedDataKinds(for category: PortableExportCategory) -> [String] {
        switch category {
        case .goalsAndPlans:
            return ["Goal", "PersistedGoalDraft"]
        case .captures:
            return ["Capture"]
        case .proof:
            return ["ProgressEvidence"]
        case .receipts:
            return [
                "GoalFeedbackEvent",
                "ActionReceiptHistoryRecord",
                "EntityRevisionTombstone",
                "EntityRevisionTombstoneLineageView"
            ]
        case .memory:
            return ["GoalTeachingSignal"]
        case .settings:
            return ["AppStateSnapshot"]
        }
    }

    private static let nonClaimBoundary = "Source invariant only; not destructive migration, restore readiness, privacy/legal, device, or release proof."
}
