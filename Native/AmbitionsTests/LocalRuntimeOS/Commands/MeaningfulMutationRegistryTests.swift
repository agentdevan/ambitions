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

    func testRegistryRowsHaveUniqueSemanticIdentityAndExecutableProofIDs() {
        let descriptors = MeaningfulMutationRegistry.descriptors
        let writePaths = MeaningfulMutationRegistry.writePaths

        XCTAssertFalse(descriptors.isEmpty)
        XCTAssertFalse(writePaths.isEmpty)
        XCTAssertEqual(Set(descriptors.map(\.id)).count, descriptors.count)
        XCTAssertEqual(Set(descriptors.map(\.sourcePath)).count, descriptors.count)
        XCTAssertEqual(Set(writePaths.map(\.sourcePath)).count, writePaths.count)
        for descriptor in descriptors {
            XCTAssertFalse(descriptor.executorOwner.isEmpty, descriptor.sourcePath)
            XCTAssertFalse(descriptor.eventKind.isEmpty, descriptor.sourcePath)
            XCTAssertFalse(descriptor.projectionOwner.isEmpty, descriptor.sourcePath)
            XCTAssertFalse(descriptor.receiptOwner.isEmpty, descriptor.sourcePath)
            XCTAssertFalse(descriptor.replayTestID.isEmpty, descriptor.sourcePath)
            XCTAssertFalse(descriptor.proofTestIDs.isEmpty, descriptor.sourcePath)
        }
        for writePath in writePaths {
            XCTAssertFalse(writePath.proofTestID.isEmpty, writePath.sourcePath)
        }
    }
}
