import XCTest
@testable import Ambitions

final class MeaningfulMutationRegistryTests: XCTestCase {
    func testKnownSyntheticTimeMutationEntryPointsAreRegisteredAsUnproven() {
        let expected = [
            "TimeViewModel.performLifeShapeMutation",
            "TimeViewModel.approveProtectedPlacementReview",
            "TimeViewModel.undoLastLifeShapeMutation",
        ]
        let registered = Set(
            MeaningfulMutationRegistry.descriptors
                .filter { $0.status == .unproven }
                .map(\.sourcePath)
        )
        let missing = expected.filter { registered.contains($0) == false }

        XCTAssertTrue(
            missing.isEmpty,
            "Unproven Time mutation entry points missing from the registry: \(missing.joined(separator: ", "))"
        )
    }

    func testRegistryRowsHaveUniqueIdentityExplicitClassificationAndRationale() {
        let descriptors = MeaningfulMutationRegistry.descriptors
        let writePaths = MeaningfulMutationRegistry.writePaths

        XCTAssertFalse(descriptors.isEmpty)
        XCTAssertFalse(writePaths.isEmpty)
        XCTAssertEqual(Set(descriptors.map(\.id)).count, descriptors.count)
        XCTAssertEqual(Set(descriptors.map(\.sourcePath)).count, descriptors.count)
        XCTAssertEqual(Set(writePaths.map(\.sourcePath)).count, writePaths.count)
        XCTAssertEqual(descriptors.count, MeaningfulMutationRegistry.declaredMutationRowCount)
        XCTAssertEqual(writePaths.count, MeaningfulMutationRegistry.declaredWritePathRowCount)
        for descriptor in descriptors {
            XCTAssertFalse(descriptor.rationale.isEmpty, descriptor.sourcePath)
            if [.durable, .projectionOnly, .adapter].contains(descriptor.status) {
                XCTAssertNotNil(descriptor.executorOwner, descriptor.sourcePath)
                XCTAssertNotNil(descriptor.eventKind, descriptor.sourcePath)
                XCTAssertNotNil(descriptor.projectionOwner, descriptor.sourcePath)
                XCTAssertNotNil(descriptor.receiptOwner, descriptor.sourcePath)
                XCTAssertNotNil(descriptor.replayTestID, descriptor.sourcePath)
                XCTAssertFalse(descriptor.proofTestIDs.isEmpty, descriptor.sourcePath)
            }
            if descriptor.status == .durable {
                XCTAssertFalse(descriptor.durableStores.isEmpty, descriptor.sourcePath)
            }
        }
        for writePath in writePaths {
            XCTAssertFalse(writePath.rationale.isEmpty, writePath.sourcePath)
        }
    }

    func testCaptureViewModelSemanticEntryPointsAreExhaustivelyRegistered() {
        let expected = [
            "CaptureViewModel.markWaiting",
            "CaptureViewModel.markOptionalSomeday",
            "CaptureViewModel.markDeliverableSeed",
            "CaptureViewModel.attachToGoal",
            "CaptureViewModel.turnIntoGoal",
        ]
        let registered = Set(MeaningfulMutationRegistry.descriptors.map(\.sourcePath))

        XCTAssertEqual(expected.filter { registered.contains($0) == false }, [])
    }

    func testShellAndExternalResultMutationEntryPointsAreRegisteredUnproven() {
        let expected = [
            "AppShellActivatedCaptureSeam.saveCapture",
            "EventKitOutbox.recordCalendarResult",
        ]
        let registered = Set(
            MeaningfulMutationRegistry.descriptors
                .filter { $0.status == .unproven }
                .map(\.sourcePath)
        )

        XCTAssertEqual(expected.filter { registered.contains($0) == false }, [])
    }

    func testUnprovenRowsDoNotClaimGenericExecutableLineage() {
        for descriptor in MeaningfulMutationRegistry.descriptors where descriptor.status == .unproven {
            XCTAssertNil(descriptor.executorOwner, descriptor.sourcePath)
            XCTAssertTrue(descriptor.durableStores.isEmpty, descriptor.sourcePath)
            XCTAssertNil(descriptor.eventKind, descriptor.sourcePath)
            XCTAssertNil(descriptor.projectionOwner, descriptor.sourcePath)
            XCTAssertNil(descriptor.receiptOwner, descriptor.sourcePath)
            XCTAssertNil(descriptor.replayTestID, descriptor.sourcePath)
            XCTAssertTrue(descriptor.proofTestIDs.isEmpty, descriptor.sourcePath)
        }
        for writePath in MeaningfulMutationRegistry.writePaths where writePath.status != .previewOnly {
            XCTAssertEqual(writePath.status, .unproven, writePath.sourcePath)
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
