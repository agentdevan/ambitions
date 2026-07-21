import XCTest
@testable import Ambitions

final class MeaningfulMutationRegistryTests: XCTestCase {
    func testTimeMutationEntryPointsRequireDurableRuntimeLineage() {
        let expected = Set([
            "TimeViewModel.performLifeShapeMutation",
            "TimeViewModel.approveProtectedPlacementReview",
            "TimeViewModel.undoLastLifeShapeMutation"
        ])
        let registered = MeaningfulMutationRegistry.descriptors.filter { expected.contains($0.sourcePath) }

        XCTAssertEqual(Set(registered.map(\.sourcePath)), expected)
        for descriptor in registered {
            XCTAssertEqual(descriptor.status, .durable, descriptor.sourcePath)
            XCTAssertEqual(descriptor.executorOwner, "AmbitionsCommandExecutor", descriptor.sourcePath)
            XCTAssertTrue(descriptor.durableStores.contains("EventStoreSQLite"), descriptor.sourcePath)
            XCTAssertTrue(descriptor.durableStores.contains("LifeCalendarStore"), descriptor.sourcePath)
            XCTAssertNotNil(descriptor.eventKind, descriptor.sourcePath)
            XCTAssertEqual(descriptor.projectionOwner, "RepositoryBackedTimeService", descriptor.sourcePath)
            XCTAssertEqual(descriptor.receiptOwner, "RuntimeCommitReceipt", descriptor.sourcePath)
            XCTAssertNotNil(descriptor.replayTestID, descriptor.sourcePath)
            XCTAssertFalse(descriptor.proofTestIDs.isEmpty, descriptor.sourcePath)
        }
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
            "CaptureViewModel.turnIntoGoal"
        ]
        let registered = Set(MeaningfulMutationRegistry.descriptors.map(\.sourcePath))

        XCTAssertEqual(expected.filter { registered.contains($0) == false }, [])
    }

    func testShellAndExternalResultMutationEntryPointsAreRegisteredUnproven() {
        let expected = [
            "AppShellActivatedCaptureSeam.saveCapture",
            "EventKitOutbox.recordCalendarResult",
            "ShareViewController.save"
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
        for writePath in MeaningfulMutationRegistry.writePaths {
            if [.durable, .projectionOnly, .adapter].contains(writePath.status) {
                XCTAssertFalse(writePath.proofTestIDs.isEmpty, writePath.sourcePath)
            } else if writePath.status != .previewOnly {
                XCTAssertEqual(writePath.status, .unproven, writePath.sourcePath)
                XCTAssertTrue(writePath.proofTestIDs.isEmpty, writePath.sourcePath)
            }
        }
    }

    func testTodayGoalStepActionDurableDescriptorUsesLiveSwiftDataMaterializerIdentity() throws {
        let descriptor = try XCTUnwrap(
            MeaningfulMutationRegistry.descriptors.first { $0.id == "today.goal-step-action" }
        )

        XCTAssertEqual(descriptor.sourcePath, "SwiftDataTodayGoalStepActionMaterializer.materialize")
        XCTAssertEqual(descriptor.status, .durable)
        XCTAssertEqual(descriptor.replayTestID, "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce")
        XCTAssertFalse(descriptor.proofTestIDs.isEmpty)
    }

    func testRepositoryTodayGoalStepActionMaterializerHasDistinctProjectionOnlyDescriptor() throws {
        let durableDescriptor = try XCTUnwrap(
            MeaningfulMutationRegistry.descriptors.first { $0.id == "today.goal-step-action" }
        )
        let repositoryDescriptor = try XCTUnwrap(
            MeaningfulMutationRegistry.descriptors.first {
                $0.sourcePath == "RepositoryTodayGoalStepActionMaterializer.materialize"
            }
        )

        XCTAssertEqual(repositoryDescriptor.id, "today.goal-step-action.repository-materializer")
        XCTAssertNotEqual(repositoryDescriptor.id, durableDescriptor.id)
        XCTAssertEqual(repositoryDescriptor.status, .projectionOnly)
        XCTAssertEqual(repositoryDescriptor.executorOwner, durableDescriptor.executorOwner)
        XCTAssertEqual(repositoryDescriptor.eventKind, durableDescriptor.eventKind)
        XCTAssertEqual(repositoryDescriptor.projectionOwner, durableDescriptor.projectionOwner)
        XCTAssertEqual(repositoryDescriptor.receiptOwner, durableDescriptor.receiptOwner)
        XCTAssertEqual(repositoryDescriptor.replayTestID, durableDescriptor.replayTestID)
        XCTAssertEqual(
            Set(repositoryDescriptor.proofTestIDs),
            Set([
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testEveryHandledKindReopensAndReplaysExactAuthorityOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testDuplicateCompleteCommitsOneSemanticEventAndMaterializesOnce",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testAllHandledKindsProduceDeterministicPlansWithoutPreAuthorityWrites",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testJournalFailureLeavesAllDerivedStoresUnchanged",
                "AmbitionsTests/TodayDurableActionMutationIntegrationTests/testQuickLogRepositoryFallbackIsIdempotent"
            ])
        )
        XCTAssertTrue(repositoryDescriptor.rationale.contains("fallback"))
        XCTAssertTrue(repositoryDescriptor.rationale.contains("in-memory"))
    }

    func testSwiftDataTodayGoalStepActionWritePathIsEvidenceBackedProjectionOnly() throws {
        let descriptor = try XCTUnwrap(
            MeaningfulMutationRegistry.descriptors.first { $0.id == "today.goal-step-action" }
        )
        let writePath = try XCTUnwrap(
            MeaningfulMutationRegistry.writePaths.first {
                $0.sourcePath == "Native/Ambitions/Core/LocalRuntimeOS/Storage/TodayGoalStepActionMaterializer.swift"
            }
        )

        XCTAssertEqual(writePath.status, .projectionOnly)
        XCTAssertEqual(writePath.executorOwner, descriptor.executorOwner)
        XCTAssertEqual(writePath.eventKind, descriptor.eventKind)
        XCTAssertEqual(writePath.projectionOwner, descriptor.projectionOwner)
        XCTAssertEqual(writePath.receiptOwner, descriptor.receiptOwner)
        XCTAssertEqual(writePath.replayTestID, descriptor.replayTestID)
        XCTAssertEqual(Set(writePath.proofTestIDs), Set(descriptor.proofTestIDs))
        XCTAssertEqual(MeaningfulMutationRegistry.writePaths.filter { $0.status == .unproven }.count, 50)
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
