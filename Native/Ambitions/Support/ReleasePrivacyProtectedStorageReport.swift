import Foundation

enum AFEP023FieldCategory: String, CaseIterable, Sendable, Equatable {
    case today = "Today"
    case goals = "Goals"
    case capture = "Capture"
    case time = "Time"
    case you = "You"
    case continuitySnapshots = "continuity snapshots"
    case scheduleBlocks = "schedule blocks"
    case runtimeSnapshots = "runtime snapshots"
    case actionHistory = "action history"
    case evidenceRecords = "evidence records"
    case corrections = "corrections"
    case userSystemProfile = "user system profile"
}

enum AFEP023ProtectedStorageClass: String, CaseIterable, Sendable, Equatable {
    case appGroup = "App Group"
    case keychain = "Keychain"
    case protectedLocalFile = "protected local file"
    case swiftDataLocalStore = "SwiftData local store"
    case inMemoryProjection = "in-memory projection"
}

struct AFEP023MutationPolicy: Sendable, Equatable {
    let exportSummary: String
    let resetSummary: String
    let deleteSummary: String
    let redactionSummary: String
    let rollbackSummary: String
    let allowsExternalRawProjection: Bool
    let localOnlyDefault: Bool
}

struct AFEP023FieldPolicyEnvelope: Identifiable, Sendable, Equatable {
    let id: String
    let category: AFEP023FieldCategory
    let storageClass: AFEP023ProtectedStorageClass
    let fieldPolicy: AFEPFieldPolicy
    let localInputAnchor: String
    let actionHistoryAnchor: String
    let continuationHistoryAnchor: String
    let userInspectionPolicy: String
    let mutationPolicy: AFEP023MutationPolicy
    let continuityPolicy: String

    var isConservativelyProtected: Bool {
        fieldPolicy.isConservativelyProtected &&
            mutationPolicy.localOnlyDefault &&
            mutationPolicy.allowsExternalRawProjection == false
    }
}

struct AFEP023StorageClassPolicy: Identifiable, Sendable, Equatable {
    let id: String
    let storageClass: AFEP023ProtectedStorageClass
    let purpose: String
    let simulatorSafe: Bool
    let runtimeWiringEnabled: Bool
    let rollbackSummary: String
}

struct AFEP023PrivacyManifestAlignmentReport: Sendable, Equatable {
    let manifestPath: String
    let trackingDeclared: Bool
    let collectedDataTypesDeclared: Int
    let accessedAPITypesDeclared: Int
    let alignedWithCurrentManifest: Bool
    let evidenceSummary: String
}

struct AFEP023RollbackGate: Sendable, Equatable {
    let available: Bool
    let restoresConservativeAFRIPolicy: Bool
    let rollbackSummary: String
}

struct AFEP023ClaimLock: Sendable, Equatable {
    let publicPrivacyApprovalUnlocked: Bool
    let legalApprovalUnlocked: Bool
    let releaseApprovalUnlocked: Bool
    let privacyCertificationUnlocked: Bool
    let noClaimBoundary: String
}

struct AFEP023ProtectedStorageArchitecturePacket: Sendable, Equatable {
    let schemaVersion: String
    let fieldPolicies: [AFEP023FieldPolicyEnvelope]
    let storageClassPolicies: [AFEP023StorageClassPolicy]
    let privacyManifestAlignment: AFEP023PrivacyManifestAlignmentReport
    let rollbackGate: AFEP023RollbackGate
    let claimLock: AFEP023ClaimLock
    let localInputAnchors: [String]
    let actionHistoryAnchors: [String]
    let continuationHistoryAnchors: [String]
    let userInspectionPolicy: String
    let noRuntimeStorageAccess: Bool
    let noCloudBackendDependency: Bool
    let noExternalRawProjection: Bool
    let releaseBoundarySummary: String

    var isWellFormed: Bool {
        schemaVersion.isEmpty == false &&
            fieldPolicies.count == AFEP023FieldCategory.allCases.count &&
            Set(fieldPolicies.map(\.category)) == Set(AFEP023FieldCategory.allCases) &&
            fieldPolicies.allSatisfy(\.isConservativelyProtected) &&
            storageClassPolicies.count == AFEP023ProtectedStorageClass.allCases.count &&
            storageClassPolicies.allSatisfy { $0.simulatorSafe && $0.runtimeWiringEnabled == false } &&
            privacyManifestAlignment.trackingDeclared == false &&
            privacyManifestAlignment.collectedDataTypesDeclared == 0 &&
            privacyManifestAlignment.accessedAPITypesDeclared == 0 &&
            privacyManifestAlignment.alignedWithCurrentManifest &&
            rollbackGate.available &&
            rollbackGate.restoresConservativeAFRIPolicy &&
            claimLock.publicPrivacyApprovalUnlocked == false &&
            claimLock.legalApprovalUnlocked == false &&
            claimLock.releaseApprovalUnlocked == false &&
            claimLock.privacyCertificationUnlocked == false &&
            localInputAnchors.isEmpty == false &&
            actionHistoryAnchors.isEmpty == false &&
            continuationHistoryAnchors.isEmpty == false &&
            userInspectionPolicy.isEmpty == false &&
            noRuntimeStorageAccess &&
            noCloudBackendDependency &&
            noExternalRawProjection &&
            releaseBoundarySummary.isEmpty == false
    }
}

enum ReleasePrivacyProtectedStorageReport {
    static let schemaVersion = "release_privacy_protected_storage_report.afep023.native.v1"

    static let storageClassPolicies: [AFEP023StorageClassPolicy] = [
        AFEP023StorageClassPolicy(
            id: "storage.app-group",
            storageClass: .appGroup,
            purpose: "Policy-only continuity envelope for shared-surface state; never a raw user-data dump.",
            simulatorSafe: true,
            runtimeWiringEnabled: false,
            rollbackSummary: "Remove the policy envelope and return to local-only surface ownership."
        ),
        AFEP023StorageClassPolicy(
            id: "storage.keychain",
            storageClass: .keychain,
            purpose: "Local trust controls and profile secrets that must stay device-local.",
            simulatorSafe: true,
            runtimeWiringEnabled: false,
            rollbackSummary: "Restore conservative local-only trust controls and keep secrets out of projections."
        ),
        AFEP023StorageClassPolicy(
            id: "storage.protected-local-file",
            storageClass: .protectedLocalFile,
            purpose: "Protected export and evidence file policy for local-only artifacts.",
            simulatorSafe: true,
            runtimeWiringEnabled: false,
            rollbackSummary: "Keep export artifacts local and redacted, with no cloud or hosted storage path."
        ),
        AFEP023StorageClassPolicy(
            id: "storage.swiftdata-local-store",
            storageClass: .swiftDataLocalStore,
            purpose: "Primary durable local store for user-owned app data.",
            simulatorSafe: true,
            runtimeWiringEnabled: false,
            rollbackSummary: "Preserve the existing local SwiftData store contract without migration changes."
        ),
        AFEP023StorageClassPolicy(
            id: "storage.in-memory-projection",
            storageClass: .inMemoryProjection,
            purpose: "Ephemeral runtime projection only; never a durable storage target.",
            simulatorSafe: true,
            runtimeWiringEnabled: false,
            rollbackSummary: "Keep runtime projections ephemeral and inspectable without persistence."
        )
    ]

    static let fieldPolicies: [AFEP023FieldPolicyEnvelope] = [
        makePolicy(
            category: .today,
            storageClass: .swiftDataLocalStore,
            fieldName: "today_surface",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            localInputAnchor: "Start Here receipt and current-step context",
            actionHistoryAnchor: "Today step closure history",
            continuationHistoryAnchor: "Relaunch continuity for the active day",
            userInspectionPolicy: "Inspect in You as a redacted local summary, never as raw export.",
            mutationSummary: "Export stays redacted; reset restores conservative local defaults; delete requires explicit user action; raw projection stays off.",
            continuityPolicy: "Continuity is local and inspectable; no external raw surface projection is allowed."
        ),
        makePolicy(
            category: .goals,
            storageClass: .swiftDataLocalStore,
            fieldName: "goals_surface",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            localInputAnchor: "Goal detail and Atlas direction receipts",
            actionHistoryAnchor: "Goal edits and closure history",
            continuationHistoryAnchor: "Goal continuity snapshots on relaunch",
            userInspectionPolicy: "Inspect via local goal summaries and redacted proof, not raw exported fields.",
            mutationSummary: "Goals remain local-first, redacted on export, and reversible only through user-directed local reset or delete.",
            continuityPolicy: "Goal continuity remains local and rerunnable without external projection."
        ),
        makePolicy(
            category: .capture,
            storageClass: .protectedLocalFile,
            fieldName: "capture_surface",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            localInputAnchor: "Capture composer intake and placement review",
            actionHistoryAnchor: "Capture placement and cleanup history",
            continuationHistoryAnchor: "Capture recovery on relaunch",
            userInspectionPolicy: "Inspect only through user-reviewed capture summaries with private details hidden.",
            mutationSummary: "Capture export is redacted, local reset is conservative, delete is explicit, and raw projection is disallowed.",
            continuityPolicy: "Captured text and placement remain local until the user reviews a redacted export."
        ),
        makePolicy(
            category: .time,
            storageClass: .appGroup,
            fieldName: "time_surface",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            localInputAnchor: "Availability, schedule, and protected time anchors",
            actionHistoryAnchor: "Schedule adjustments and reflow history",
            continuationHistoryAnchor: "LifeShape relaunch continuity anchors",
            userInspectionPolicy: "Inspect schedule reality as redacted local context, not as raw mirrored state.",
            mutationSummary: "Time policies keep schedule reality local, redacted, and recoverable without cloud or hosted continuity.",
            continuityPolicy: "Shared-surface continuity is policy-only; runtime projection stays local and redacted."
        ),
        makePolicy(
            category: .you,
            storageClass: .keychain,
            fieldName: "you_surface",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            localInputAnchor: "User system profile and trust controls",
            actionHistoryAnchor: "User preference and trust-change history",
            continuationHistoryAnchor: "Settings continuity after relaunch",
            userInspectionPolicy: "Inspect profile and trust settings locally in a Settings-style surface; do not export raw secrets.",
            mutationSummary: "Profile data stays device-local, export is redacted, and destructive delete requires explicit user action.",
            continuityPolicy: "User-system continuity remains local-first with no raw projection to external surfaces."
        ),
        makePolicy(
            category: .continuitySnapshots,
            storageClass: .inMemoryProjection,
            fieldName: "continuity_snapshots",
            privacyClass: .localOnly,
            exportPolicy: .redacted,
            localInputAnchor: "Relaunch continuity and source-context receipts",
            actionHistoryAnchor: "Continuity replay history",
            continuationHistoryAnchor: "Resume and restore anchors",
            userInspectionPolicy: "Inspect as a summarized local continuity receipt only.",
            mutationSummary: "Continuity snapshots are ephemeral projections, redacted on export, and discarded on reset.",
            continuityPolicy: "Ephemeral continuity never becomes a durable storage surface."
        ),
        makePolicy(
            category: .scheduleBlocks,
            storageClass: .protectedLocalFile,
            fieldName: "schedule_blocks",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            localInputAnchor: "Schedule and availability anchors",
            actionHistoryAnchor: "Reflow and wait-state history",
            continuationHistoryAnchor: "Next-session scheduling continuity",
            userInspectionPolicy: "Inspect schedule blocks locally with private details redacted in export review.",
            mutationSummary: "Schedule blocks stay local, reset clears conservative cache state, delete is user-confirmed, and raw projection stays off.",
            continuityPolicy: "Schedule continuity remains local and inspectable without external raw data."
        ),
        makePolicy(
            category: .runtimeSnapshots,
            storageClass: .inMemoryProjection,
            fieldName: "runtime_snapshots",
            privacyClass: .replayRestricted,
            exportPolicy: .redacted,
            localInputAnchor: "Runtime context and provenance anchors",
            actionHistoryAnchor: "Runtime replay and receipt history",
            continuationHistoryAnchor: "Resume-safe runtime snapshot anchors",
            userInspectionPolicy: "Inspect runtime snapshots only as redacted local summaries.",
            mutationSummary: "Runtime snapshots are ephemeral, redacted, and never externally projectable raw.",
            continuityPolicy: "Runtime snapshots support local replay only; they are not a durable export target."
        ),
        makePolicy(
            category: .actionHistory,
            storageClass: .swiftDataLocalStore,
            fieldName: "action_history",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            localInputAnchor: "Action closure receipts and step outcomes",
            actionHistoryAnchor: "Historical action receipts",
            continuationHistoryAnchor: "Cross-launch action continuity",
            userInspectionPolicy: "Inspect action history as redacted receipts in the local trust and review surfaces.",
            mutationSummary: "Action history stays local, redacted on export, and is only reset or deleted through explicit user action.",
            continuityPolicy: "Action history is the inspection trail, not a raw external projection."
        ),
        makePolicy(
            category: .evidenceRecords,
            storageClass: .protectedLocalFile,
            fieldName: "evidence_records",
            privacyClass: .proofRestricted,
            exportPolicy: .redacted,
            localInputAnchor: "Proof and evidence anchors",
            actionHistoryAnchor: "Evidence capture and review history",
            continuationHistoryAnchor: "Proof continuity across relaunch",
            userInspectionPolicy: "Inspect evidence only through redacted proof summaries.",
            mutationSummary: "Evidence records stay local and redacted; reset and delete are explicit and user-directed.",
            continuityPolicy: "Evidence is locally inspectable but not raw-projectable."
        ),
        makePolicy(
            category: .corrections,
            storageClass: .protectedLocalFile,
            fieldName: "corrections",
            privacyClass: .lineageRestricted,
            exportPolicy: .redacted,
            localInputAnchor: "Correction and learn-from-history anchors",
            actionHistoryAnchor: "Correction history and tombstones",
            continuationHistoryAnchor: "Correction continuity and relaunch learning",
            userInspectionPolicy: "Inspect corrections as redacted lineage notes, not as raw learning payloads.",
            mutationSummary: "Corrections remain local, are redacted on export, and can be reset to conservative defaults.",
            continuityPolicy: "Correction history informs local continuation only."
        ),
        makePolicy(
            category: .userSystemProfile,
            storageClass: .keychain,
            fieldName: "user_system_profile",
            privacyClass: .privateSensitive,
            exportPolicy: .redacted,
            localInputAnchor: "Profile, trust, and system preference anchors",
            actionHistoryAnchor: "Profile edits and trust changes",
            continuationHistoryAnchor: "Profile continuity across relaunch",
            userInspectionPolicy: "Inspect profile settings locally; never export raw secrets or private identifiers.",
            mutationSummary: "User system profile data stays local and redacted, with explicit delete and conservative reset only.",
            continuityPolicy: "Profile continuity stays device-local and inspectable in You."
        )
    ]

    static let privacyManifestAlignment = AFEP023PrivacyManifestAlignmentReport(
        manifestPath: "Native/Ambitions/Resources/PrivacyInfo.xcprivacy",
        trackingDeclared: false,
        collectedDataTypesDeclared: 0,
        accessedAPITypesDeclared: 0,
        alignedWithCurrentManifest: true,
        evidenceSummary: "The checked-in manifest currently declares no tracking, no collected data, and no accessed API reasons."
    )

    static let rollbackGate = AFEP023RollbackGate(
        available: true,
        restoresConservativeAFRIPolicy: true,
        rollbackSummary: "Rollback returns the repo to conservative local-only privacy defaults by removing this scaffold only; production storage behavior remains unchanged."
    )

    static let claimLock = AFEP023ClaimLock(
        publicPrivacyApprovalUnlocked: false,
        legalApprovalUnlocked: false,
        releaseApprovalUnlocked: false,
        privacyCertificationUnlocked: false,
        noClaimBoundary: "This report defines local privacy architecture only. It does not unlock public, legal, release, or privacy certification claims."
    )

    static let packet = AFEP023ProtectedStorageArchitecturePacket(
        schemaVersion: schemaVersion,
        fieldPolicies: fieldPolicies,
        storageClassPolicies: storageClassPolicies,
        privacyManifestAlignment: privacyManifestAlignment,
        rollbackGate: rollbackGate,
        claimLock: claimLock,
        localInputAnchors: [
            "Capture composer intake",
            "Start Here / Reality Meridian",
            "LifeShape schedule anchors",
            "You system profile anchors"
        ],
        actionHistoryAnchors: [
            "Action receipt history",
            "Closure receipts",
            "Correction history",
            "Evidence review history"
        ],
        continuationHistoryAnchors: [
            "Relaunch continuity snapshots",
            "Resume-safe local projections",
            "Returning-user continuity"
        ],
        userInspectionPolicy: "Inspect only through local, user-controlled, redacted summaries; raw sensitive fields are not externally projectable.",
        noRuntimeStorageAccess: true,
        noCloudBackendDependency: true,
        noExternalRawProjection: true,
        releaseBoundarySummary: "AFEP-023 is a pure support/report scaffold. It classifies local privacy architecture, preserves conservative defaults, and keeps release claims locked."
    )

    private static func makePolicy(
        category: AFEP023FieldCategory,
        storageClass: AFEP023ProtectedStorageClass,
        fieldName: String,
        privacyClass: AFEPStoragePrivacyClass,
        exportPolicy: AFEPExportPolicy,
        localInputAnchor: String,
        actionHistoryAnchor: String,
        continuationHistoryAnchor: String,
        userInspectionPolicy: String,
        mutationSummary: String,
        continuityPolicy: String
    ) -> AFEP023FieldPolicyEnvelope {
        AFEP023FieldPolicyEnvelope(
            id: "afep023.field.\(category.rawValue)",
            category: category,
            storageClass: storageClass,
            fieldPolicy: AFEPFieldPolicy(
                fieldName: fieldName,
                privacyClass: privacyClass,
                indexingPolicy: .notIndexed,
                exportPolicy: exportPolicy,
                measurementEvidenceState: .planned,
                notes: "AFEP-023 field-level privacy policy for \(category.rawValue)."
            ),
            localInputAnchor: localInputAnchor,
            actionHistoryAnchor: actionHistoryAnchor,
            continuationHistoryAnchor: continuationHistoryAnchor,
            userInspectionPolicy: userInspectionPolicy,
            mutationPolicy: AFEP023MutationPolicy(
                exportSummary: exportPolicy == .safe ? "Export may remain safe only when the field is already public or system-owned." : "Export requires redaction or user review before external projection.",
                resetSummary: "Reset restores conservative local-only defaults without changing production storage behavior.",
                deleteSummary: "Delete is explicit, user-directed, and local-only; no silent cloud or hosted deletion path exists.",
                redactionSummary: "Sensitive/private details stay redacted in exports and external projections.",
                rollbackSummary: "Rollback returns the policy back to conservative AFRI privacy defaults.",
                allowsExternalRawProjection: false,
                localOnlyDefault: true
            ),
            continuityPolicy: continuityPolicy
        )
    }
}
