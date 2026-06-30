@testable import Ambitions
import Foundation
import SwiftData
import XCTest

final class CorePersistenceCanonicalOwnershipTests: XCTestCase {
    func testCanonicalPersistenceAndStorageOwnerFilesExist() {
        let root = repoRoot()
        for requiredPath in [
            "Native/Ambitions/Core/LocalRuntimeOS/Storage/ObjectStoreSwiftData.swift",
            "Native/Ambitions/Core/Persistence/StoreHealthCheck.swift",
        ] {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appendingPathComponent(requiredPath).path),
                "Missing canonical persistence/storage owner: \(requiredPath)"
            )
        }
    }

    func testObjectStoreSwiftDataOwnsSwiftDataSchemaAndReadWriteHealth() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        let report = await store.healthReport(checker: StoreHealthCheck(timestampProvider: { "2026-06-20T23:00:00Z" }))

        XCTAssertTrue(AmbitionsPersistenceStore.storedModelNames.contains("GoalRecord"))
        XCTAssertTrue(AmbitionsPersistenceStore.storedModelNames.contains("RuntimeSnapshotLedgerRecord"))
        XCTAssertEqual(report.schemaVersion, storeHealthCheckSchemaVersion)
        XCTAssertEqual(report.checkedAt, "2026-06-20T23:00:00Z")
        XCTAssertEqual(report.status, .green)
        XCTAssertTrue(report.readVerified)
        XCTAssertTrue(report.writeVerified)
        XCTAssertFalse(report.extensionSnapshotWriteVerified)
        XCTAssertEqual(report.invariantBlockerCount, 0)
        XCTAssertEqual(report.issues, [])
    }

    func testStoreHealthCheckDetectsInvariantFailuresAsCorruptStoreRisk() async throws {
        let store = try AmbitionsPersistenceStore(inMemory: true)
        try await store.write { context in
            context.insert(Self.orphanStepRecord())
        }

        let report = await StoreHealthCheck(timestampProvider: { "2026-06-20T23:00:00Z" }).check(store: store)
        let issueKinds = Set(report.issues.map(\.kind))

        XCTAssertEqual(report.status, .red)
        XCTAssertTrue(issueKinds.contains(.storageInvariantFailure))
        XCTAssertTrue(issueKinds.contains(.corruptStore))
        XCTAssertGreaterThan(report.invariantBlockerCount, 0)
    }

    func testStoreHealthCheckDetectsSchemaMismatchAndExtensionSnapshotFailure() async throws {
        struct SnapshotWriteError: Error {}

        let store = try AmbitionsPersistenceStore(inMemory: true)
        let report = await StoreHealthCheck(
            requiredModelNames: AmbitionsPersistenceStore.storedModelNames.union(["MissingRecord"]),
            timestampProvider: { "2026-06-20T23:00:00Z" }
        ).check(
            store: store,
            extensionSnapshotWriter: { throw SnapshotWriteError() }
        )
        let issueKinds = Set(report.issues.map(\.kind))

        XCTAssertEqual(report.status, .red)
        XCTAssertTrue(issueKinds.contains(.schemaMismatch))
        XCTAssertTrue(issueKinds.contains(.extensionSnapshotWriteFailure))
        XCTAssertFalse(report.extensionSnapshotWriteVerified)
    }
}

private extension CorePersistenceCanonicalOwnershipTests {
    func repoRoot() -> URL {
        var url = URL(fileURLWithPath: #filePath)
        while url.pathComponents.count > 1 {
            let candidate = url.appendingPathComponent("Native/Ambitions/Core/Persistence")
            if FileManager.default.fileExists(atPath: candidate.path) {
                return url
            }
            url.deleteLastPathComponent()
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    }

    static func orphanStepRecord() -> StepRecord {
        StepRecord(
            id: "step-orphan",
            goalID: "missing-goal",
            planID: "missing-plan",
            sectionID: "missing-section",
            orderIndex: 0,
            title: "Orphan step",
            summaryText: nil,
            typeRaw: StepType.actionUnit.rawValue,
            stateRaw: StepLifecycleState.planned.rawValue,
            ownerDisplayName: "User",
            ownerOwnershipRaw: "self",
            tempoRaw: GoalTempo.untimed.rawValue,
            timingTypeRaw: TimingType.logWhenDone.rawValue,
            startsOn: nil,
            dueAt: nil,
            targetBy: nil,
            windowStart: nil,
            windowEnd: nil,
            suggestedNextAt: nil,
            repeatEveryDays: nil,
            progressReviewCadenceDays: nil,
            dependencyStepIDsData: Data("[]".utf8),
            successSignalsData: Data("[]".utf8),
            actionabilityData: Data("{}".utf8),
            isOptional: false,
            isRepeatable: false,
            evidenceRequired: false,
            snapshotData: Data("{}".utf8)
        )
    }
}
