import Foundation

enum StorageMigrationProofKind: String, CaseIterable, Sendable, Equatable, Hashable {
    case storageInvariantCheck = "storage_invariant_check"
    case preMigrationBackupReceipt = "pre_migration_backup_receipt"
    case stagedDryRunResult = "staged_dry_run_result"
    case restoreRollbackPlan = "restore_rollback_plan"
    case userReviewApproval = "user_review_approval"
    case releaseClaimBlockerAcknowledgement = "release_claim_blocker_acknowledgement"
}

enum StorageMigrationPlanIssueKind: String, Sendable, Equatable, Hashable, Codable {
    case unsupportedPlanSchema = "unsupported_plan_schema"
    case unsupportedSourceLedger = "unsupported_source_ledger"
    case unsupportedTargetLedger = "unsupported_target_ledger"
    case duplicatePlanEntryID = "duplicate_plan_entry_id"
    case mutationMissingSafetyGate = "mutation_missing_safety_gate"
    case migrationExecutionAuthorized = "migration_execution_authorized"
}

enum StorageMigrationExecutionReadinessIssueKind: String, Sendable, Equatable, Hashable, Codable {
    case validatorIssue = "validator_issue"
    case missingProof = "missing_proof"
    case duplicateProofID = "duplicate_proof_id"
    case mutationPlanHasNoMutation = "mutation_plan_has_no_mutation"
}

struct StorageMigrationProof: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let kind: StorageMigrationProofKind
    let subjectEntryID: String?
    let producedBy: String
    let producedAt: String
    let summary: String

    init(
        id: String,
        kind: StorageMigrationProofKind,
        subjectEntryID: String? = nil,
        producedBy: String,
        producedAt: String,
        summary: String
    ) {
        self.id = id
        self.kind = kind
        self.subjectEntryID = subjectEntryID
        self.producedBy = producedBy
        self.producedAt = producedAt
        self.summary = summary
    }
}

enum StorageMigrationExecutionReadinessIssue: Sendable, Equatable, Hashable {
    case validatorIssue(StorageMigrationPlanIssue)
    case missingProof(entryID: String, gate: StorageMigrationPlanGate, expectedProofKind: StorageMigrationProofKind)
    case duplicateProofID(String)
    case mutationPlanHasNoMutation

    var kind: StorageMigrationExecutionReadinessIssueKind {
        switch self {
        case .validatorIssue:
            return .validatorIssue
        case .missingProof:
            return .missingProof
        case .duplicateProofID:
            return .duplicateProofID
        case .mutationPlanHasNoMutation:
            return .mutationPlanHasNoMutation
        }
    }

    var validatorIssueKind: StorageMigrationPlanIssueKind? {
        guard case let .validatorIssue(issue) = self else {
            return nil
        }
        return issue.kind
    }
}

struct StorageMigrationExecutionReadiness: Sendable, Equatable {
    let issues: [StorageMigrationExecutionReadinessIssue]
    let proofIDsByEntryID: [String: Set<String>]

    var isGreen: Bool {
        issues.isEmpty
    }

    var canRequestMigrationExecution: Bool {
        isGreen
    }
}

struct StorageMigrationExecutionReadinessEvaluator: Sendable {
    private let validator: StorageMigrationPlanValidator

    init(validator: StorageMigrationPlanValidator = StorageMigrationPlanValidator()) {
        self.validator = validator
    }

    func evaluate(
        plan: StorageMigrationPlan,
        proofs: [StorageMigrationProof]
    ) -> StorageMigrationExecutionReadiness {
        var issues = validator.validate(plan).map(StorageMigrationExecutionReadinessIssue.validatorIssue)
        let duplicateProofIDs = Dictionary(grouping: proofs, by: \.id)
            .filter { $0.value.count > 1 }
            .keys
            .sorted()
        duplicateProofIDs.forEach { issues.append(.duplicateProofID($0)) }

        guard plan.mutationEntries.isEmpty == false else {
            issues.append(.mutationPlanHasNoMutation)
            return StorageMigrationExecutionReadiness(
                issues: issues,
                proofIDsByEntryID: [:]
            )
        }

        let proofsByEntryID = Dictionary(grouping: proofs.filter { $0.subjectEntryID != nil }) { proof in
            proof.subjectEntryID ?? ""
        }
        var proofIDsByEntryID: [String: Set<String>] = [:]

        for entry in plan.mutationEntries {
            let entryProofs = proofsByEntryID[entry.id, default: []]
            proofIDsByEntryID[entry.id] = Set(entryProofs.map(\.id))
            let proofKinds = Set(entryProofs.map(\.kind))

            for gate in entry.requiredGates.sorted(by: { $0.rawValue < $1.rawValue }) {
                let expectedKind = Self.proofKind(for: gate)
                if proofKinds.contains(expectedKind) == false {
                    issues.append(
                        .missingProof(
                            entryID: entry.id,
                            gate: gate,
                            expectedProofKind: expectedKind
                        )
                    )
                }
            }
        }

        return StorageMigrationExecutionReadiness(
            issues: issues,
            proofIDsByEntryID: proofIDsByEntryID
        )
    }

    static func proofKind(for gate: StorageMigrationPlanGate) -> StorageMigrationProofKind {
        switch gate {
        case .storageInvariantCheck:
            return .storageInvariantCheck
        case .preMigrationBackup:
            return .preMigrationBackupReceipt
        case .stagedDryRun:
            return .stagedDryRunResult
        case .restoreRollbackPlan:
            return .restoreRollbackPlan
        case .userReview:
            return .userReviewApproval
        case .releaseClaimBlocked:
            return .releaseClaimBlockerAcknowledgement
        }
    }
}

extension StorageMigrationPlanIssue {
    var kind: StorageMigrationPlanIssueKind {
        switch self {
        case .unsupportedPlanSchema:
            return .unsupportedPlanSchema
        case .unsupportedSourceLedger:
            return .unsupportedSourceLedger
        case .unsupportedTargetLedger:
            return .unsupportedTargetLedger
        case .duplicatePlanEntryID:
            return .duplicatePlanEntryID
        case .mutationMissingSafetyGate:
            return .mutationMissingSafetyGate
        case .migrationExecutionAuthorized:
            return .migrationExecutionAuthorized
        }
    }
}
