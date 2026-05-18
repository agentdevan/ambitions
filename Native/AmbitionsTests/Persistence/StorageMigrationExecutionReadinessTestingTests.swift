import Testing
@testable import Ambitions

struct StorageMigrationExecutionReadinessTestingTests {
    @Test func readinessRequiresProofForEveryMutationSafetyGate() throws {
        let plan = Self.versionChangePlan()
        let mutation = try #require(plan.mutationEntries.first)

        let readiness = StorageMigrationExecutionReadinessEvaluator().evaluate(
            plan: plan,
            proofs: []
        )

        #expect(readiness.isGreen == false)
        #expect(readiness.canRequestMigrationExecution == false)

        for gate in StorageMigrationPlanEntry.requiredMutationGates {
            let expectedKind = StorageMigrationExecutionReadinessEvaluator.proofKind(for: gate)
            #expect(
                readiness.issues.contains(
                    .missingProof(
                        entryID: mutation.id,
                        gate: gate,
                        expectedProofKind: expectedKind
                    )
                )
            )
        }
    }

    @Test func readinessTurnsGreenOnlyWhenAllMutationProofKindsExist() throws {
        let plan = Self.versionChangePlan()
        let mutation = try #require(plan.mutationEntries.first)
        let proofs = Self.completeProofs(for: mutation)

        let readiness = StorageMigrationExecutionReadinessEvaluator().evaluate(
            plan: plan,
            proofs: proofs
        )

        #expect(readiness.isGreen)
        #expect(readiness.canRequestMigrationExecution)
        #expect(readiness.proofIDsByEntryID[mutation.id]?.count == StorageMigrationPlanEntry.requiredMutationGates.count)
    }

    @Test func readinessRejectsDuplicateProofIdentifiers() throws {
        let plan = Self.versionChangePlan()
        let mutation = try #require(plan.mutationEntries.first)
        let duplicateProof = StorageMigrationProof(
            id: "duplicate-proof",
            kind: .preMigrationBackupReceipt,
            subjectEntryID: mutation.id,
            producedBy: "swift-testing-fixture",
            producedAt: "2026-05-13T00:00:00Z",
            summary: "Duplicate proof fixture."
        )

        let readiness = StorageMigrationExecutionReadinessEvaluator().evaluate(
            plan: plan,
            proofs: [duplicateProof, duplicateProof]
        )

        #expect(readiness.isGreen == false)
        #expect(readiness.issues.contains(.duplicateProofID("duplicate-proof")))
        #expect(readiness.issues.contains { $0.kind == .duplicateProofID })
    }

    @Test func noMutationPlanCannotRequestMigrationExecution() {
        let plan = StorageMigrationPlanScaffold().plan(
            from: StorageSchemaVersionLedger.current,
            to: StorageSchemaVersionLedger.current
        )

        let readiness = StorageMigrationExecutionReadinessEvaluator().evaluate(
            plan: plan,
            proofs: []
        )

        #expect(readiness.isGreen == false)
        #expect(readiness.canRequestMigrationExecution == false)
        #expect(readiness.issues.contains(.mutationPlanHasNoMutation))
        #expect(readiness.issues.contains { $0.kind == .mutationPlanHasNoMutation })
    }

    @Test func validatorIssuesExposeDeterministicFailureKinds() {
        let plan = StorageMigrationPlan(
            schemaVersion: "storage_migration_plan_scaffold.native.v0",
            sourceLedgerSchemaVersion: StorageSchemaVersionLedger.current.schemaVersion,
            targetLedgerSchemaVersion: StorageSchemaVersionLedger.current.schemaVersion,
            entries: StorageSchemaVersionLedger.current.entries.map { entry in
                StorageMigrationPlanEntry(
                    id: "migration.no_change.\(entry.id)",
                    sourceEntryID: entry.id,
                    targetEntryID: entry.id,
                    storedTypeName: entry.storedTypeName,
                    action: .noChange,
                    fromVersion: entry.currentVersion,
                    toVersion: entry.currentVersion,
                    requiredGates: [],
                    notes: "No change test fixture."
                )
            }
        )

        let readiness = StorageMigrationExecutionReadinessEvaluator().evaluate(
            plan: plan,
            proofs: []
        )

        #expect(readiness.issues.contains { issue in
            issue.kind == .validatorIssue && issue.validatorIssueKind == .unsupportedPlanSchema
        })
    }

    private static func versionChangePlan() -> StorageMigrationPlan {
        let target = StorageSchemaVersionLedger(
            entries: StorageSchemaVersionLedger.current.entries.map { entry in
                guard entry.id == "swiftdata.goal_record" else { return entry }
                return StorageSchemaVersionEntry(
                    id: entry.id,
                    family: entry.family,
                    owner: entry.owner,
                    storedTypeName: entry.storedTypeName,
                    currentVersion: "goal_engine.native.v2",
                    versionEvidence: "Swift Testing fixture target version.",
                    migrationReadiness: .migrationPlanRequired,
                    rollbackRequirement: .rollbackPlanRequired,
                    notes: entry.notes
                )
            }
        )

        return StorageMigrationPlanScaffold().plan(
            from: StorageSchemaVersionLedger.current,
            to: target
        )
    }

    private static func completeProofs(for entry: StorageMigrationPlanEntry) -> [StorageMigrationProof] {
        StorageMigrationPlanEntry.requiredMutationGates.map { gate in
            let kind = StorageMigrationExecutionReadinessEvaluator.proofKind(for: gate)
            return StorageMigrationProof(
                id: "proof.\(entry.id).\(kind.rawValue)",
                kind: kind,
                subjectEntryID: entry.id,
                producedBy: "swift-testing-fixture",
                producedAt: "2026-05-13T00:00:00Z",
                summary: "Proof fixture for \(kind.rawValue)."
            )
        }
    }
}
