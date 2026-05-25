import XCTest
@testable import Ambitions

final class LocalScheduleBlockRepositoryTests: XCTestCase {
    func testFileRepositoryUpsertsExportsAndDeletesScheduleBlocksDeterministically() async throws {
        let (repository, root) = try makeRepository()
        defer { try? FileManager.default.removeItem(at: root) }

        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let laterBlock = ScheduledAmbitionsBlock(
            id: "local-schedule.block-2",
            title: "Later block",
            start: now.addingTimeInterval(1_800),
            end: now.addingTimeInterval(3_600),
            contextLens: .work,
            relatedGoalID: "goal-2",
            isUserConfirmed: true
        )
        let earlierBlock = ScheduledAmbitionsBlock(
            id: "local-schedule.block-1",
            title: "Earlier block",
            start: now,
            end: now.addingTimeInterval(1_200),
            contextLens: .personal,
            relatedGoalID: "goal-1",
            isUserConfirmed: true
        )

        let firstReceipts = try await repository.upsertBlock(laterBlock)
        let secondReceipts = try await repository.upsertBlock(earlierBlock)
        let loaded = try await repository.listBlocks()
        let loadedLater = try await repository.block(id: laterBlock.id)
        let export = try await repository.exportBlocks()
        let deleteReceipt = try await repository.deleteBlock(id: laterBlock.id)
        let afterDelete = try await repository.listBlocks()
        let loadedLaterBlock = try XCTUnwrap(loadedLater)

        XCTAssertEqual(firstReceipts, [laterBlock.localScheduleReceiptID(action: "save")])
        XCTAssertEqual(
            secondReceipts,
            [earlierBlock.localScheduleReceiptID(action: "save"), laterBlock.localScheduleReceiptID(action: "save")]
        )
        XCTAssertEqual(loaded, [earlierBlock, laterBlock])
        XCTAssertEqual(loadedLaterBlock, laterBlock)
        XCTAssertEqual(export.schemaVersion, localScheduleBlockRepositoryExportSchemaVersion)
        XCTAssertEqual(export.blocks, [earlierBlock, laterBlock])
        XCTAssertEqual(deleteReceipt, "Receipt.local-schedule.\(laterBlock.id).delete")
        XCTAssertEqual(afterDelete, [earlierBlock])
        XCTAssertEqual(laterBlock.localScheduleSourceRecordID, "SourceRecord.local-schedule.local-schedule.block-2")
        XCTAssertEqual(
            laterBlock.localScheduleReplayTraceID(action: "save"),
            "ReplayTrace.local-schedule.local-schedule.block-2.save"
        )
        XCTAssertTrue(laterBlock.localScheduleYouInspectionSummary.contains("What Ambitions knows"))
    }

    func testFileRepositoryImportsExportIntoFreshStoreWithoutChangingInspectableIdentity() async throws {
        let (sourceRepository, sourceRoot) = try makeRepository("source")
        let (destinationRepository, destinationRoot) = try makeRepository("destination")
        defer {
            try? FileManager.default.removeItem(at: sourceRoot)
            try? FileManager.default.removeItem(at: destinationRoot)
        }

        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let block = ScheduledAmbitionsBlock(
            id: "local-schedule.block-import",
            title: "Imported block",
            start: now,
            end: now.addingTimeInterval(1_800),
            contextLens: .all,
            relatedCaptureID: "capture-1",
            isUserConfirmed: true
        )

        try await sourceRepository.saveBlocks([block])
        let export = try await sourceRepository.exportBlocks()
        try await destinationRepository.importBlocks(export)

        let loaded = try await destinationRepository.listBlocks()
        let imported = try await destinationRepository.block(id: block.id)
        let importedBlock = try XCTUnwrap(imported)

        XCTAssertEqual(export.schemaVersion, localScheduleBlockRepositoryExportSchemaVersion)
        XCTAssertEqual(loaded, [block])
        XCTAssertEqual(importedBlock, block)
        XCTAssertEqual(importedBlock.localScheduleReceiptID(action: "save"), "Receipt.local-schedule.local-schedule.block-import.save")
        XCTAssertTrue(importedBlock.localScheduleYouInspectionSummary.contains("What Ambitions knows"))
    }

    func testFileRepositorySerializesConcurrentUpsertsWithoutDroppingBlocks() async throws {
        let (firstRepository, root) = try makeRepository()
        let secondRepository = FileLocalScheduleBlockRepository(fileURL: firstRepository.fileURL)
        defer { try? FileManager.default.removeItem(at: root) }

        let now = Date(timeIntervalSince1970: 1_714_000_000)
        let blocks = (0..<12).map { index in
            ScheduledAmbitionsBlock(
                id: "local-schedule.concurrent-\(index)",
                title: "Concurrent block \(index)",
                start: now.addingTimeInterval(TimeInterval(index * 900)),
                end: now.addingTimeInterval(TimeInterval((index + 1) * 900)),
                contextLens: index.isMultiple(of: 2) ? .work : .personal,
                relatedGoalID: "goal-\(index)",
                isUserConfirmed: true
            )
        }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for (index, block) in blocks.enumerated() {
                let repository = index.isMultiple(of: 2) ? firstRepository : secondRepository
                group.addTask {
                    _ = try await repository.upsertBlock(block)
                }
            }

            try await group.waitForAll()
        }

        let loaded = try await firstRepository.listBlocks()
        XCTAssertEqual(loaded, blocks)
        XCTAssertEqual(Set(loaded.map(\.id)).count, blocks.count)
    }
}

private extension LocalScheduleBlockRepositoryTests {
    func makeRepository(_ suffix: String = UUID().uuidString) throws -> (FileLocalScheduleBlockRepository, URL) {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("ambitions-local-schedule-repository-tests-\(suffix)")
        let fileURL = root.appendingPathComponent("local-schedule-blocks.json")
        return (FileLocalScheduleBlockRepository(fileURL: fileURL), root)
    }
}
