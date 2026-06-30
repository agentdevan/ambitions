import Testing
@testable import Ambitions

struct RepairPlanTestingTests {
    @Test func readinessRequiresProofForEveryMutationSafetyGate() throws {
        let plan = Self.versionChangePlan()
        let mutation = try #require(plan.mutationEntries.first)

        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )

        #expect(readiness.isGreen == false)
        #expect(readiness.canRequestMigrationExecution == false)

        for gate in MigrationPlanEntry.requiredMutationGates {
            let expectedKind = RepairPlanEngine.proofKind(for: gate)
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

        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: proofs
        )

        #expect(readiness.isGreen)
        #expect(readiness.canRequestMigrationExecution)
        #expect(readiness.proofIDsByEntryID[mutation.id]?.count == MigrationPlanEntry.requiredMutationGates.count)
    }

    @Test func readinessRejectsDuplicateProofIdentifiers() throws {
        let plan = Self.versionChangePlan()
        let mutation = try #require(plan.mutationEntries.first)
        let duplicateProof = MigrationRepairProof(
            id: "duplicate-proof",
            kind: .preMigrationBackupReceipt,
            subjectEntryID: mutation.id,
            producedBy: "swift-testing-fixture",
            producedAt: "2026-05-13T00:00:00Z",
            summary: "Duplicate proof fixture."
        )

        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: [duplicateProof, duplicateProof]
        )

        #expect(readiness.isGreen == false)
        #expect(readiness.issues.contains(.duplicateProofID("duplicate-proof")))
        #expect(readiness.issues.contains { $0.kind == .duplicateProofID })
    }

    @Test func noMutationPlanCannotRequestMigrationExecution() {
        let plan = MigrationPlanner().plan(
            from: SchemaLedger.current,
            to: SchemaLedger.current
        )

        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )

        #expect(readiness.isGreen == false)
        #expect(readiness.canRequestMigrationExecution == false)
        #expect(readiness.issues.contains(.mutationPlanHasNoMutation))
        #expect(readiness.issues.contains { $0.kind == .mutationPlanHasNoMutation })
    }

    @Test func validatorIssuesExposeDeterministicFailureKinds() {
        let plan = MigrationPlan(
            schemaVersion: "migration_repair_dsl.native.v0",
            sourceLedgerSchemaVersion: SchemaLedger.current.schemaVersion,
            targetLedgerSchemaVersion: SchemaLedger.current.schemaVersion,
            entries: SchemaLedger.current.entries.map { entry in
                MigrationPlanEntry(
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

        let readiness = RepairPlanEngine().evaluate(
            plan: plan,
            proofs: []
        )

        #expect(readiness.issues.contains { issue in
            issue.kind == .validatorIssue && issue.validatorIssueKind == .unsupportedPlanSchema
        })
    }

    private static func versionChangePlan() -> MigrationPlan {
        let target = SchemaLedger(
            entries: SchemaLedger.current.entries.map { entry in
                guard entry.id == "swiftdata.goal_record" else { return entry }
                return SchemaLedgerEntry(
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

        return MigrationPlanner().plan(
            from: SchemaLedger.current,
            to: target
        )
    }

    private static func completeProofs(for entry: MigrationPlanEntry) -> [MigrationRepairProof] {
        MigrationPlanEntry.requiredMutationGates.map { gate in
            let kind = RepairPlanEngine.proofKind(for: gate)
            return MigrationRepairProof(
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
