import XCTest
@testable import Ambitions

final class MeaningfulMutationRegistryTests: XCTestCase {
    func testRegistryRowsHaveUniqueIdentityAndExplicitClassification() {
        let descriptors = MeaningfulMutationRegistry.descriptors
        let writePaths = MeaningfulMutationRegistry.writePaths

        XCTAssertFalse(descriptors.isEmpty)
        XCTAssertEqual(Set(descriptors.map(\.id)).count, descriptors.count)
        XCTAssertEqual(Set(descriptors.map(\.sourcePath)).count, descriptors.count)
        XCTAssertEqual(Set(writePaths.map(\.sourcePath)).count, writePaths.count)
        XCTAssertEqual(descriptors.count, MeaningfulMutationRegistry.declaredMutationRowCount)
        XCTAssertEqual(writePaths.count, MeaningfulMutationRegistry.declaredWritePathRowCount)
        for descriptor in descriptors {
            XCTAssertFalse(descriptor.rationale.isEmpty, descriptor.sourcePath)
        }
        for writePath in writePaths {
            XCTAssertFalse(writePath.rationale.isEmpty, writePath.sourcePath)
        }
    }

    func testRegistryMakesNoExecutableLineageClaimBeforeTerminalValidation() {
        for descriptor in MeaningfulMutationRegistry.descriptors {
            XCTAssertEqual(descriptor.status, .unproven, descriptor.sourcePath)
            XCTAssertNil(descriptor.executorOwner, descriptor.sourcePath)
            XCTAssertTrue(descriptor.durableStores.isEmpty, descriptor.sourcePath)
            XCTAssertNil(descriptor.eventKind, descriptor.sourcePath)
            XCTAssertNil(descriptor.projectionOwner, descriptor.sourcePath)
            XCTAssertNil(descriptor.receiptOwner, descriptor.sourcePath)
            XCTAssertNil(descriptor.replayTestID, descriptor.sourcePath)
            XCTAssertTrue(descriptor.proofTestIDs.isEmpty, descriptor.sourcePath)
        }
        for writePath in MeaningfulMutationRegistry.writePaths {
            XCTAssertEqual(writePath.status, .unproven, writePath.sourcePath)
            XCTAssertNil(writePath.executorOwner, writePath.sourcePath)
            XCTAssertTrue(writePath.durableStores.isEmpty, writePath.sourcePath)
            XCTAssertNil(writePath.eventKind, writePath.sourcePath)
            XCTAssertNil(writePath.projectionOwner, writePath.sourcePath)
            XCTAssertNil(writePath.receiptOwner, writePath.sourcePath)
            XCTAssertNil(writePath.replayTestID, writePath.sourcePath)
            XCTAssertTrue(writePath.proofTestIDs.isEmpty, writePath.sourcePath)
        }
    }

    func testRegistrySourceRequiresExplicitStatusAndRationaleForEveryRow() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let repositoryRoot = testFile
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
        let registryURL = repositoryRoot.appendingPathComponent(
            "Ambitions/Core/LocalRuntimeOS/Commands/MeaningfulMutationRegistry.swift"
        )
        let source = try String(contentsOf: registryURL, encoding: .utf8)
        let rows = source.split(separator: "\n").filter {
            $0.contains("mutation(id:") || $0.contains("writePath(sourcePath:")
        }

        XCTAssertFalse(rows.isEmpty)
        for row in rows {
            XCTAssertTrue(row.contains("status:"), String(row))
            XCTAssertTrue(row.contains("rationale:"), String(row))
        }
    }
}
