@testable import Ambitions
import XCTest

final class MigrationRepairOwnershipTests: XCTestCase {
    func testMigrationRepairOwnerFilesExistUnderCanonicalLocalRuntimeOSOwner() throws {
        let root = try repoRoot()
        let requiredPaths = [
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/SchemaLedger.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/MigrationDSL.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/MigrationPlanner.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/DryRunMigration.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/PreMigrationBackup.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/StoreInvariantChecker.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/CorruptionQuarantine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RuntimeDoctor.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RepairPlanEngine.swift",
            "Native/Ambitions/Core/LocalRuntimeOS/MigrationRepair/RestoreRollback.swift",
        ]

        for path in requiredPaths {
            XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testOldPersistenceMigrationRepairOwnersAreRemoved() throws {
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
        ]

        for path in removedPaths {
            XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent(path).path), path)
        }
    }

    func testMigrationRepairComponentsRemainNonExecutableUntilReviewProofExists() {
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
        throw NSError(domain: "MigrationRepairOwnershipTests", code: 1)
    }
}
