@testable import Ambitions
import XCTest

final class RepairOwnershipTests: XCTestCase {
    func testRepairOwnerFilesExistUnderCanonicalLocalRuntimeOSOwnerAndOldOwnerIsGone() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/SchemaLedger.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/MigrationDSL.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/MigrationPlanner.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/DryRunMigration.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/PreMigrationBackup.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/StoreInvariantChecker.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/CorruptionQuarantine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/RuntimeDoctor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/RuntimeDoctorRepairOperator.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/RuntimeDoctorRepairTypes.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/RuntimeDoctorHealthReaders.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/RuntimeDoctorRepairPlans.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/RepairPlanEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/RestoreRollback.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotContracts.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableAppSnapshot.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableStoredGoalFeedbackEvent.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotService.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceOperations.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/Repair/PortableSnapshotServiceReferenceWarnings.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }

        let retiredOwnerPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair",
            "Native/AmbitionsTests/LocalRuntimeOS/MigrationRepair",
        ]

        for path in retiredOwnerPaths {
            XCTAssertFalse(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path),
                "Repair source and tests must be owned by Core/LocalRuntimeOS/Repair."
            )
        }
    }

    func testOldPersistenceRepairOwnersAreRemoved() throws {
        let root = try repoRoot()
        let removedPaths = [
            "Native/Ambitions/Core/Persistence/StorageSchemaVersionLedger.swift",
            "Native/Ambitions/Core/Persistence/StorageMigrationPlanScaffold.swift",
            "Native/Ambitions/Core/Persistence/StorageMigrationExecutionReadiness.swift",
            "Native/Ambitions/Core/Persistence/PreMigrationBackup.swift",
            "Native/Ambitions/Core/Persistence/StorageInvariantChecker.swift",
            "Native/Ambitions/Core/Persistence/StorageMigrationRecovery.swift",
            "Native/Ambitions/Core/Persistence/PortableRestoreRollback.swift",
            "Native/Ambitions/Core/Persistence/StorageMigrationFoundation.swift",
            "Native/Ambitions/Core/Persistence/PortableSnapshotContracts.swift",
            "Native/Ambitions/Core/Persistence/PortableSnapshotContracts+02-PortableAppSnapshot.swift",
            "Native/Ambitions/Core/Persistence/PortableSnapshotContracts+03-PortableStoredGoalFeedbackEvent.swift",
            "Native/Ambitions/Core/Persistence/PortableSnapshotService.swift",
            "Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService.swift",
            "Native/Ambitions/Core/Persistence/PortableSnapshotService+02-PortableSnapshotService+03-referenceWarnings.swift",
        ]

        for path in removedPaths {
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testRepairComponentsRemainNonExecutableUntilReviewProofExists() {
        let plan = MigrationPlanner().plan(from: .seededHistoricalV0, to: .current)
        let repairPlan = RepairPlanEngine().evaluate(plan: plan, proofs: [])
        let quarantine = CorruptionQuarantine(
            timestampProvider: { "2026-06-30T10:55:00Z" },
            idProvider: { "quarantine-test" }
        ).evaluate(signals: [
            CorruptionQuarantineSignal(
                id: "decode",
                kind: .decodeFailure,
                message: "Fixture decode failure."
            )
        ])

        XCTAssertTrue(MigrationDSL.requiresMutationReview(.versionChange))
        XCTAssertEqual(MigrationDSL.requiredMutationGates, MigrationPlanEntry.requiredMutationGates)
        XCTAssertFalse(plan.executionAllowed)
        XCTAssertFalse(repairPlan.canRequestMigrationExecution)
        XCTAssertTrue(quarantine.quarantineRequired)
        XCTAssertFalse(quarantine.destructiveResetAllowed)
        XCTAssertEqual(quarantine.sourceRecordID, "SourceRecord.corruption-quarantine.quarantine-test")
        XCTAssertEqual(quarantine.receiptID, "Receipt.corruption-quarantine.quarantine-test")
        XCTAssertEqual(quarantine.replayTraceID, "ReplayTrace.corruption-quarantine.quarantine-test")
    }

    private func repoRoot() throws -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            url.deleteLastPathComponent()
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("project.yml").path) {
                return url
            }
        }
        throw NSError(domain: "RepairOwnershipTests", code: 1)
    }
}
