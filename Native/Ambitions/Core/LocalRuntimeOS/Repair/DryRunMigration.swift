import Foundation

let dryRunMigrationSchemaVersion = "storage_migration_foundation.native.v1"

enum DryRunMigrationReviewState: String, Sendable, Equatable, Hashable {
    case noMigrationRequired = "no_migration_required"
    case readyForUserReview = "ready_for_user_review"
    case blocked = "blocked"
}

enum DryRunMigrationBlockerKind: String, Sendable, Equatable, Hashable {
    case sourceLedgerInvalid = "source_ledger_invalid"
    case targetLedgerInvalid = "target_ledger_invalid"
    case migrationPlanInvalid = "migration_plan_invalid"
    case invariantCheckFailed = "invariant_check_failed"
    case invariantBlocker = "invariant_blocker"
    case backupPreparationFailed = "backup_preparation_failed"
    case backupBlocked = "backup_blocked"
    case missingBackupPackage = "missing_backup_package"
    case dryRunFailed = "dry_run_failed"
    case dryRunAuthorizedDurableMutation = "dry_run_authorized_durable_mutation"
    case recoveryAuthorizedMigrationExecution = "recovery_authorized_migration_execution"
    case recoveryAuthorizedDestructiveReset = "recovery_authorized_destructive_reset"
}

struct DryRunMigrationBlocker: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: DryRunMigrationBlockerKind
    let message: String

    init(kind: DryRunMigrationBlockerKind, id: String, message: String) {
        self.kind = kind
        self.id = "\(kind.rawValue).\(id)"
        self.message = message
    }
}

enum MigrationCompactionHookKind: String, Sendable, Equatable, Hashable, CaseIterable {
    case portableBackupRetentionReview = "portable_backup_retention_review"
    case derivedProjectionRebuildReview = "derived_projection_rebuild_review"
    case supersededRecordPruneReview = "superseded_record_prune_review"
}

struct MigrationCompactionHook: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: MigrationCompactionHookKind
    let subjectPlanEntryIDs: [String]
    let reviewRequired: Bool
    let executionAllowed: Bool
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let notes: String
}

struct MigrationSchemaManifest: Sendable, Equatable, Hashable {
    let schemaVersion: String
    let sourceLedgerSchemaVersion: String
    let targetLedgerSchemaVersion: String
    let migrationPlanSchemaVersion: String
    let sourceEntryCount: Int
    let targetEntryCount: Int
    let migrationPlanEntryCount: Int
    let mutationEntryCount: Int
    let sourceSwiftDataTypeNames: [String]
    let targetSwiftDataTypeNames: [String]
    let portableSnapshotVersions: [String]
}

struct MigrationResetReview: Sendable, Equatable, Hashable {
    let id: String
    let dryRunMode: PortableImportMode?
    let wouldResetLocalStore: Bool
    let requiresExplicitConfirmation: Bool
    let durableMutationAllowed: Bool
    let destructiveResetAllowed: Bool
    let sourceRecordID: String
    let receiptID: String
    let replayTraceID: String
    let summary: String
}

struct DryRunMigrationReport: Sendable, Equatable {
    let schemaVersion: String
    let reviewID: String
    let createdAt: String
    let reviewState: DryRunMigrationReviewState
    let schemaManifest: MigrationSchemaManifest
    let sourceLedgerIssues: [SchemaLedgerIssue]
    let targetLedgerIssues: [SchemaLedgerIssue]
    let migrationPlan: MigrationPlan
    let migrationPlanIssues: [MigrationPlanIssue]
    let invariantReport: StoreInvariantReport?
    let backupReport: PreMigrationBackupReport?
    let dryRunReport: PortableImportDryRunReport?
    let systemProofs: [RepairProof]
    let readiness: RepairPlan
    let recoveryAssessment: RuntimeDoctorAssessment
    let resetReview: MigrationResetReview
    let compactionHooks: [MigrationCompactionHook]
    let blockers: [DryRunMigrationBlocker]
    let migrationExecutionAllowed: Bool
    let destructiveResetAllowed: Bool

    var requiresUserReview: Bool {
        readiness.issues.contains { issue in
            guard case let .missingProof(_, gate, _) = issue else {
                return false
            }
            return gate == .userReview
        }
    }

    var isFailSafeGreen: Bool {
        blockers.isEmpty
            && migrationExecutionAllowed == false
            && destructiveResetAllowed == false
            && resetReview.destructiveResetAllowed == false
            && resetReview.durableMutationAllowed == false
            && recoveryAssessment.receipt.migrationExecutionAllowed == false
            && recoveryAssessment.receipt.destructiveResetAllowed == false
            && compactionHooks.allSatisfy { $0.reviewRequired && $0.executionAllowed == false }
    }

    init(
        schemaVersion: String = dryRunMigrationSchemaVersion,
        reviewID: String,
        createdAt: String,
        reviewState: DryRunMigrationReviewState,
        schemaManifest: MigrationSchemaManifest,
        sourceLedgerIssues: [SchemaLedgerIssue],
        targetLedgerIssues: [SchemaLedgerIssue],
        migrationPlan: MigrationPlan,
        migrationPlanIssues: [MigrationPlanIssue],
        invariantReport: StoreInvariantReport?,
        backupReport: PreMigrationBackupReport?,
        dryRunReport: PortableImportDryRunReport?,
        systemProofs: [RepairProof],
        readiness: RepairPlan,
        recoveryAssessment: RuntimeDoctorAssessment,
        resetReview: MigrationResetReview,
        compactionHooks: [MigrationCompactionHook],
        blockers: [DryRunMigrationBlocker],
        migrationExecutionAllowed: Bool = false,
        destructiveResetAllowed: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.reviewID = reviewID
        self.createdAt = createdAt
        self.reviewState = reviewState
        self.schemaManifest = schemaManifest
        self.sourceLedgerIssues = sourceLedgerIssues
        self.targetLedgerIssues = targetLedgerIssues
        self.migrationPlan = migrationPlan
        self.migrationPlanIssues = migrationPlanIssues
        self.invariantReport = invariantReport
        self.backupReport = backupReport
        self.dryRunReport = dryRunReport
        self.systemProofs = systemProofs.sorted { $0.id < $1.id }
        self.readiness = readiness
        self.recoveryAssessment = recoveryAssessment
        self.resetReview = resetReview
        self.compactionHooks = compactionHooks.sorted { $0.id < $1.id }
        self.blockers = blockers.sorted { $0.id < $1.id }
        self.migrationExecutionAllowed = migrationExecutionAllowed
        self.destructiveResetAllowed = destructiveResetAllowed
    }
}

struct DryRunMigration: Sendable {
    let snapshotService: any PortableSnapshotServicing
    let invariantReportProvider: @Sendable () async throws -> StoreInvariantReport
    let planner: MigrationPlanner
    let ledgerValidator: SchemaLedgerValidator
    let planValidator: MigrationPlanValidator
    let readinessEvaluator: RepairPlanEngine
    let recoveryCoordinator: RuntimeDoctor
    let timestampProvider: @Sendable () -> String
    let idProvider: @Sendable () -> String

    init(
        snapshotService: any PortableSnapshotServicing,
        invariantReportProvider: @escaping @Sendable () async throws -> StoreInvariantReport,
        planner: MigrationPlanner = MigrationPlanner(),
        ledgerValidator: SchemaLedgerValidator = SchemaLedgerValidator(),
        planValidator: MigrationPlanValidator = MigrationPlanValidator(),
        readinessEvaluator: RepairPlanEngine = RepairPlanEngine(),
        recoveryCoordinator: RuntimeDoctor? = nil,
        timestampProvider: @escaping @Sendable () -> String = { DomainTimestamp.string(from: .now) },
        idProvider: @escaping @Sendable () -> String = { UUID().uuidString }
    ) {
        self.snapshotService = snapshotService
        self.invariantReportProvider = invariantReportProvider
        self.planner = planner
        self.ledgerValidator = ledgerValidator
        self.planValidator = planValidator
        self.readinessEvaluator = readinessEvaluator
        self.timestampProvider = timestampProvider
        self.idProvider = idProvider
        self.recoveryCoordinator = recoveryCoordinator ?? RuntimeDoctor(
            timestampProvider: timestampProvider,
            idProvider: idProvider
        )
    }

    func prepareReview(
        from sourceLedger: SchemaLedger,
        to targetLedger: SchemaLedger = .current,
        selection: PortableExportSelection = .all,
        dryRunMode: PortableImportMode = .replaceLocalStore,
        recoverySignals: [CorruptionQuarantineSignal] = []
    ) async -> DryRunMigrationReport {
        let reviewID = idProvider()
        let createdAt = timestampProvider()
        let plan = planner.plan(from: sourceLedger, to: targetLedger)
        let sourceLedgerIssues = ledgerValidator.validate(sourceLedger)
        let targetLedgerIssues = ledgerValidator.validate(targetLedger)
        let planIssues = planValidator.validate(plan)
        var blockers = blockersForLedgerAndPlan(
            sourceLedgerIssues: sourceLedgerIssues,
            targetLedgerIssues: targetLedgerIssues,
            migrationPlanIssues: planIssues
        )

        let invariantReport = await loadInvariantReport(blockers: &blockers)
        var backupReport: PreMigrationBackupReport?
        var dryRunReport: PortableImportDryRunReport?
        var systemProofs: [RepairProof] = []

        let hasMutation = plan.mutationEntries.isEmpty == false
        if hasMutation {
            if invariantReport?.isGreen == true {
                systemProofs += proofs(
                    kind: .storageInvariantCheck,
                    plan: plan,
                    reviewID: reviewID,
                    summary: "Storage invariant check completed without blockers."
                )
            }

            if sourceLedgerIssues.isEmpty && targetLedgerIssues.isEmpty && planIssues.isEmpty && invariantReport != nil {
                backupReport = await prepareBackup(
                    plan: plan,
                    selection: selection,
                    invariantReport: invariantReport,
                    reviewID: reviewID,
                    blockers: &blockers
                )
            }

            if backupReport?.isGreen == true, let receipt = backupReport?.receipt {
                systemProofs += proofs(
                    kind: .preMigrationBackupReceipt,
                    plan: plan,
                    reviewID: reviewID,
                    summary: "Pre-migration backup Receipt \(receipt.id) exists and migration execution remains blocked."
                )
            }

            if backupReport?.isGreen == true, let backupPackage = backupReport?.backupPackage {
                dryRunReport = await dryRunRestore(
                    backupPackage,
                    mode: dryRunMode,
                    blockers: &blockers
                )
            } else if backupReport != nil {
                blockers.append(DryRunMigrationBlocker(
                    kind: .missingBackupPackage,
                    id: "portable_snapshot",
                    message: "A migration mutation review requires a portable backup package before dry-run validation."
                ))
            }

            if let dryRunReport, dryRunReport.durableMutationAllowed == false {
                systemProofs += proofs(
                    kind: .stagedDryRunResult,
                    plan: plan,
                    reviewID: reviewID,
                    summary: "Portable snapshot dry run completed without durable mutation."
                )
                systemProofs += proofs(
                    kind: .restoreRollbackPlan,
                    plan: plan,
                    reviewID: reviewID,
                    summary: "Recovery remains review-only and destructive reset is not authorized."
                )
                systemProofs += proofs(
                    kind: .releaseClaimBlockerAcknowledgement,
                    plan: plan,
                    reviewID: reviewID,
                    summary: "Migration/release readiness claims remain blocked pending explicit user review and later proof."
                )
            }
        }

        let readiness = readinessEvaluator.evaluate(plan: plan, proofs: systemProofs)
        let recoveryAssessment = recoveryCoordinator.assess(
            plan: plan,
            readiness: readiness,
            preMigrationBackup: backupReport?.receipt,
            recoverySignals: recoverySignals
        )
        appendRecoveryAuthorizationBlockers(recoveryAssessment, to: &blockers)

        let resetReview = makeResetReview(
            reviewID: reviewID,
            dryRunReport: dryRunReport
        )
        let compactionHooks = makeCompactionHooks(
            reviewID: reviewID,
            plan: plan
        )

        return DryRunMigrationReport(
            reviewID: reviewID,
            createdAt: createdAt,
            reviewState: reviewState(
                hasMutation: hasMutation,
                blockers: blockers
            ),
            schemaManifest: schemaManifest(
                sourceLedger: sourceLedger,
                targetLedger: targetLedger,
                plan: plan
            ),
            sourceLedgerIssues: sourceLedgerIssues,
            targetLedgerIssues: targetLedgerIssues,
            migrationPlan: plan,
            migrationPlanIssues: planIssues,
            invariantReport: invariantReport,
            backupReport: backupReport,
            dryRunReport: dryRunReport,
            systemProofs: systemProofs,
            readiness: readiness,
            recoveryAssessment: recoveryAssessment,
            resetReview: resetReview,
            compactionHooks: compactionHooks,
            blockers: blockers
        )
    }
}

private extension DryRunMigration {
    func blockersForLedgerAndPlan(
        sourceLedgerIssues: [SchemaLedgerIssue],
        targetLedgerIssues: [SchemaLedgerIssue],
        migrationPlanIssues: [MigrationPlanIssue]
    ) -> [DryRunMigrationBlocker] {
        sourceLedgerIssues.map {
            DryRunMigrationBlocker(
                kind: .sourceLedgerInvalid,
                id: "\($0)",
                message: "Source storage schema ledger must validate before migration review: \($0)."
            )
        }
        + targetLedgerIssues.map {
            DryRunMigrationBlocker(
                kind: .targetLedgerInvalid,
                id: "\($0)",
                message: "Target storage schema ledger must validate before migration review: \($0)."
            )
        }
        + migrationPlanIssues.map {
            DryRunMigrationBlocker(
                kind: .migrationPlanInvalid,
                id: "\($0)",
                message: "Migration plan must validate before backup, dry-run, or recovery review: \($0)."
            )
        }
    }

    func loadInvariantReport(blockers: inout [DryRunMigrationBlocker]) async -> StoreInvariantReport? {
        do {
            let report = try await invariantReportProvider()
            for issue in report.issues where issue.severity == .blocker {
                blockers.append(DryRunMigrationBlocker(
                    kind: .invariantBlocker,
                    id: issue.id,
                    message: issue.message
                ))
            }
            return report
        } catch {
            blockers.append(DryRunMigrationBlocker(
                kind: .invariantCheckFailed,
                id: "storage_invariant_checker",
                message: "Storage invariant check did not complete; migration review remains closed: \(String(describing: error))."
            ))
            return nil
        }
    }

    func prepareBackup(
        plan: MigrationPlan,
        selection: PortableExportSelection,
        invariantReport: StoreInvariantReport?,
        reviewID: String,
        blockers: inout [DryRunMigrationBlocker]
    ) async -> PreMigrationBackupReport? {
        guard let invariantReport else {
            return nil
        }

        let backupService = PreMigrationBackup(
            snapshotService: snapshotService,
            invariantReportProvider: { invariantReport },
            timestampProvider: timestampProvider,
            idProvider: { "pre-migration-backup.\(reviewID)" }
        )

        do {
            let report = try await backupService.prepareBackup(
                for: plan,
                selection: selection
            )
            for blocker in report.blockers {
                blockers.append(DryRunMigrationBlocker(
                    kind: .backupBlocked,
                    id: blocker.id,
                    message: blocker.message
                ))
            }
            return report
        } catch {
            blockers.append(DryRunMigrationBlocker(
                kind: .backupPreparationFailed,
                id: "pre_migration_backup",
                message: "Pre-migration backup did not complete; migration review remains closed: \(String(describing: error))."
            ))
            return nil
        }
    }

    func dryRunRestore(
        _ snapshot: PortableAppSnapshot,
        mode: PortableImportMode,
        blockers: inout [DryRunMigrationBlocker]
    ) async -> PortableImportDryRunReport? {
        do {
            let report = try await snapshotService.dryRunImportSnapshot(snapshot, mode: mode)
            if report.durableMutationAllowed {
                blockers.append(DryRunMigrationBlocker(
                    kind: .dryRunAuthorizedDurableMutation,
                    id: mode.rawValue,
                    message: "Storage migration dry run must not authorize durable mutation."
                ))
            }
            return report
        } catch {
            blockers.append(DryRunMigrationBlocker(
                kind: .dryRunFailed,
                id: mode.rawValue,
                message: "Storage migration dry run did not complete; migration review remains closed: \(String(describing: error))."
            ))
            return nil
        }
    }

    func appendRecoveryAuthorizationBlockers(
        _ assessment: RuntimeDoctorAssessment,
        to blockers: inout [DryRunMigrationBlocker]
    ) {
        if assessment.receipt.migrationExecutionAllowed {
            blockers.append(DryRunMigrationBlocker(
                kind: .recoveryAuthorizedMigrationExecution,
                id: assessment.receipt.id,
                message: "Storage recovery assessment must not authorize migration execution in AMB-1565."
            ))
        }

        if assessment.receipt.destructiveResetAllowed {
            blockers.append(DryRunMigrationBlocker(
                kind: .recoveryAuthorizedDestructiveReset,
                id: assessment.receipt.id,
                message: "Storage recovery assessment must not authorize destructive reset in AMB-1565."
            ))
        }
    }

    func proofs(
        kind: RepairProofKind,
        plan: MigrationPlan,
        reviewID: String,
        summary: String
    ) -> [RepairProof] {
        plan.mutationEntries.map { entry in
            RepairProof(
                id: "proof.\(reviewID).\(entry.id).\(kind.rawValue)",
                kind: kind,
                subjectEntryID: entry.id,
                producedBy: "DryRunMigration",
                producedAt: timestampProvider(),
                summary: summary
            )
        }
    }

    func makeResetReview(
        reviewID: String,
        dryRunReport: PortableImportDryRunReport?
    ) -> MigrationResetReview {
        MigrationResetReview(
            id: "storage-migration-reset-review.\(reviewID)",
            dryRunMode: dryRunReport?.mode,
            wouldResetLocalStore: dryRunReport?.wouldResetLocalStore ?? false,
            requiresExplicitConfirmation: dryRunReport?.safetySummary.requiresExplicitConfirmation ?? false,
            durableMutationAllowed: dryRunReport?.durableMutationAllowed ?? false,
            destructiveResetAllowed: false,
            sourceRecordID: "SourceRecord.storage-migration-reset.\(reviewID)",
            receiptID: "Receipt.storage-migration-reset.\(reviewID)",
            replayTraceID: "ReplayTrace.storage-migration-reset.\(reviewID)",
            summary: dryRunReport == nil
                ? "No reset dry run is required because no migration mutation is being reviewed."
                : "Reset remains dry-run only; durable mutation and destructive reset require explicit later authorization."
        )
    }

    func makeCompactionHooks(
        reviewID: String,
        plan: MigrationPlan
    ) -> [MigrationCompactionHook] {
        let mutationIDs = plan.mutationEntries.map(\.id).sorted()
        guard mutationIDs.isEmpty == false else {
            return []
        }

        return MigrationCompactionHookKind.allCases.map { kind in
            MigrationCompactionHook(
                id: "storage-migration-compaction.\(reviewID).\(kind.rawValue)",
                kind: kind,
                subjectPlanEntryIDs: mutationIDs,
                reviewRequired: true,
                executionAllowed: false,
                sourceRecordID: "SourceRecord.storage-migration-compaction.\(reviewID).\(kind.rawValue)",
                receiptID: "Receipt.storage-migration-compaction.\(reviewID).\(kind.rawValue)",
                replayTraceID: "ReplayTrace.storage-migration-compaction.\(reviewID).\(kind.rawValue)",
                notes: "Compaction hook is review-only in AMB-1565 and cannot silently mutate local data."
            )
        }
    }

    func schemaManifest(
        sourceLedger: SchemaLedger,
        targetLedger: SchemaLedger,
        plan: MigrationPlan
    ) -> MigrationSchemaManifest {
        MigrationSchemaManifest(
            schemaVersion: dryRunMigrationSchemaVersion,
            sourceLedgerSchemaVersion: sourceLedger.schemaVersion,
            targetLedgerSchemaVersion: targetLedger.schemaVersion,
            migrationPlanSchemaVersion: plan.schemaVersion,
            sourceEntryCount: sourceLedger.entries.count,
            targetEntryCount: targetLedger.entries.count,
            migrationPlanEntryCount: plan.entries.count,
            mutationEntryCount: plan.mutationEntries.count,
            sourceSwiftDataTypeNames: sourceLedger.swiftDataEntries.map(\.storedTypeName).sorted(),
            targetSwiftDataTypeNames: targetLedger.swiftDataEntries.map(\.storedTypeName).sorted(),
            portableSnapshotVersions: targetLedger.portableSnapshotEntries.map(\.currentVersion).sorted()
        )
    }

    func reviewState(
        hasMutation: Bool,
        blockers: [DryRunMigrationBlocker]
    ) -> DryRunMigrationReviewState {
        guard blockers.isEmpty else {
            return .blocked
        }
        return hasMutation ? .readyForUserReview : .noMigrationRequired
    }
}
