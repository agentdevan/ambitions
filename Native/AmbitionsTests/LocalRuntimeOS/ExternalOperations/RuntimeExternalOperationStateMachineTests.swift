import AmbitionsRuntimeSQLite
@testable import Ambitions
import Foundation
import XCTest

final class RuntimeExternalOperationStateMachineTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_000)

    func testDecodedByteBudgetChargesSQLiteValuesExactlyAndFailsClosed() async throws {
        let root = FileManager.default.temporaryDirectory
            .appendingPathComponent("runtime-external-budget-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: root) }
        let database = try SQLiteDatabase(url: root.appendingPathComponent("Runtime.sqlite"))

        try await database.transaction(.deferred) { database in
            func assertCharge(_ sql: String, expectedBytes: Int, value: SQLiteValue) throws {
                var budget = RuntimeExternalOperationDecodedByteBudget(
                    maximumBytes: expectedBytes + 1
                )
                let rows = try budget.query(sql, database: database)
                XCTAssertEqual(rows.map(\.values), [[value]])
                XCTAssertEqual(budget.remainingBytes, 1)
            }

            try assertCharge("SELECT NULL", expectedBytes: 1, value: .null)
            try assertCharge("SELECT 7", expectedBytes: 8, value: .integer(7))
            try assertCharge("SELECT 1.5", expectedBytes: 8, value: .real(1.5))
            try assertCharge("SELECT 'é'", expectedBytes: 2, value: .text("é"))
            try assertCharge("SELECT X'010203'", expectedBytes: 3, value: .blob(Data([1, 2, 3])))

            var orderedBudget = RuntimeExternalOperationDecodedByteBudget(maximumBytes: 16)
            let ordered = try orderedBudget.query(
                "SELECT 2 AS ordinal UNION ALL SELECT 1 ORDER BY ordinal",
                database: database
            )
            XCTAssertEqual(ordered.compactMap { row in
                guard case let .integer(value) = row.value(named: "ordinal") else { return nil }
                return value
            }, [1, 2])
            XCTAssertEqual(orderedBudget.remainingBytes, 0)

            var insufficient = RuntimeExternalOperationDecodedByteBudget(maximumBytes: 7)
            XCTAssertThrowsError(try insufficient.query("SELECT 7", database: database)) { error in
                XCTAssertEqual((error as? SQLiteQueryBudgetExceeded)?.limit, .decodedBytes)
            }
            XCTAssertEqual(insufficient.remainingBytes, 7)
        }
    }

    func testAtomicClaimBeginSuccessAndTerminalImmutability() throws {
        let pending = try state(.pending, .notAttempted, version: 1)
        let lease = try self.lease()
        let claimed = try state(
            .claimed, .notAttempted, version: 2, purpose: .execute, lease: lease
        )
        XCTAssertTrue(RuntimeExternalOperationCodec.validTransition(
            from: pending, to: claimed, attemptID: nil
        ))
        let attemptID = try XCTUnwrap(RuntimeExternalAttemptID(rawValue: "attempt-1"))
        let executing = try state(
            .executing, .notAttempted, version: 3, attempts: 1,
            purpose: .execute, lease: lease
        )
        XCTAssertTrue(RuntimeExternalOperationCodec.validTransition(
            from: claimed, to: executing, attemptID: attemptID
        ))
        let succeeded = try state(
            .succeeded, .confirmedPresent, version: 4, attempts: 1,
            reference: "event-1", updatedAt: now.addingTimeInterval(2)
        )
        XCTAssertTrue(RuntimeExternalOperationCodec.validTransition(
            from: executing, to: succeeded, attemptID: attemptID
        ))
        XCTAssertFalse(RuntimeExternalOperationCodec.validTransition(
            from: succeeded,
            to: try state(.pending, .notAttempted, version: 5, attempts: 1),
            attemptID: nil
        ))
    }

    func testWrongVersionWrongLeaseAndDoubleBeginAreRejectedByTransitionFence() throws {
        let pending = try state(.pending, .notAttempted, version: 1)
        let lease = try self.lease()
        let skippedVersion = try state(
            .claimed, .notAttempted, version: 3, purpose: .execute, lease: lease
        )
        XCTAssertFalse(RuntimeExternalOperationCodec.validTransition(
            from: pending, to: skippedVersion, attemptID: nil
        ))
        let claimed = try state(
            .claimed, .notAttempted, version: 2, purpose: .execute, lease: lease
        )
        let wrongLease = try RuntimeExternalLease(
            token: XCTUnwrap(RuntimeExternalLeaseToken(rawValue: "wrong")),
            owner: lease.owner, acquiredAt: lease.acquiredAt, expiresAt: lease.expiresAt
        )
        let executing = try state(
            .executing, .notAttempted, version: 3, attempts: 1,
            purpose: .execute, lease: wrongLease
        )
        XCTAssertFalse(RuntimeExternalOperationCodec.validTransition(
            from: claimed, to: executing,
            attemptID: XCTUnwrap(RuntimeExternalAttemptID(rawValue: "attempt-1"))
        ))
        XCTAssertFalse(RuntimeExternalOperationCodec.validTransition(
            from: claimed, to: claimed, attemptID: nil
        ))
    }

    func testExpiryProducesSyntheticIndeterminateOutcomeAndRequiresReconciliation() throws {
        let attemptID = try XCTUnwrap(RuntimeExternalAttemptID(rawValue: "attempt-expired"))
        let operationID = try XCTUnwrap(RuntimeExternalOperationID(rawValue: "operation-1"))
        let provider = RuntimeExternalProviderRouting.providerID(for: .reminder)
        let expiredAt = now.addingTimeInterval(300)
        let outcome = RuntimeExternalOperationCodec.leaseExpiryOutcome(
            attemptID: attemptID, operationID: operationID,
            providerID: provider, at: expiredAt
        )
        XCTAssertEqual(outcome.kind, .leaseExpiredWithoutOutcome)
        XCTAssertEqual(outcome.effectDisposition, .indeterminate)
        XCTAssertEqual(outcome.reasonCode, .leaseExpiredAfterAttemptStart)
    }

    func testCreateAndCancellationReconciliationInvertPresenceSemantics() throws {
        let attemptID = try XCTUnwrap(RuntimeExternalAttemptID(rawValue: "attempt-reconcile"))
        let operationID = try XCTUnwrap(RuntimeExternalOperationID(rawValue: "operation-1"))
        let provider = RuntimeExternalProviderRouting.providerID(for: .calendarEvent)
        let reference = try XCTUnwrap(RuntimeExternalProviderReference(rawValue: "calendar-1"))
        XCTAssertEqual(
            RuntimeExternalOperationCodec.outcome(
                attemptID: attemptID, operationID: operationID, providerID: provider,
                reconciliation: .found(reference), action: .create, at: now
            ).kind,
            .confirmedPresence
        )
        XCTAssertEqual(
            RuntimeExternalOperationCodec.outcome(
                attemptID: attemptID, operationID: operationID, providerID: provider,
                reconciliation: .found(reference), action: .compensateRemoval, at: now
            ).kind,
            .cancellationSourceStillPresent
        )
        XCTAssertEqual(
            RuntimeExternalOperationCodec.outcome(
                attemptID: attemptID, operationID: operationID, providerID: provider,
                reconciliation: .confirmedAbsent, action: .compensateRemoval, at: now
            ).kind,
            .reconciledCancellationAbsent
        )
        for result in [
            RuntimeExternalProviderReconciliationOutcome.ambiguous,
            .incompatible,
        ] {
            XCTAssertEqual(
                RuntimeExternalOperationCodec.outcome(
                    attemptID: attemptID, operationID: operationID, providerID: provider,
                    reconciliation: result, action: .compensateRemoval, at: now
                ).effectDisposition,
                .indeterminate
            )
        }
    }

    func testAttemptDigestContractIncludesActionSourceAndCreationAuthority() {
        let source = try? String(contentsOfFile:
            #filePath.replacingOccurrences(
                of: "Native/AmbitionsTests/LocalRuntimeOS/ExternalOperations/RuntimeExternalOperationStateMachineTests.swift",
                with: "Native/Ambitions/Core/LocalRuntimeOS/ExternalOperations/RuntimeExternalOperationStore.swift"
            )
        )
        XCTAssertTrue(source?.contains("prior.creationDigest") == true)
        XCTAssertTrue(source?.contains("graph.creation.payload.action.rawValue") == true)
        XCTAssertTrue(source?.contains("sourceProviderReference?.rawValue") == true)
        XCTAssertTrue(source?.range(of: "insertAttempt(attempt", options: [])?.lowerBound != nil)
    }

    func testReadAndReceiptBudgetsCoverOneOperationAndBoundedReceiptFanout() {
        XCTAssertGreaterThan(RuntimeExternalOperationLimits.maximumGraphBytesPerOperation, 0)
        XCTAssertEqual(
            RuntimeExternalOperationLimits.maximumReceiptGraphBytes,
            RuntimeExternalOperationLimits.maximumOperationsPerReceipt *
                RuntimeExternalOperationLimits.maximumGraphBytesPerOperation
        )
        XCTAssertEqual(
            RuntimeExternalOperationLimits.maximumPageGraphBytes,
            (RuntimeExternalOperationLimits.maximumPageSize + 1) *
                RuntimeExternalOperationLimits.maximumGraphBytesPerOperation
        )
        XCTAssertLessThanOrEqual(
            RuntimeExternalOperationLimits.maximumOperationsPerReceipt,
            RuntimeCompensationLimits.maximumExternalOperations
        )
    }

    private func state(
        _ status: RuntimeExternalWorkflowStatus,
        _ disposition: RuntimeExternalEffectDisposition,
        version: UInt64,
        attempts: Int = 0,
        purpose: RuntimeExternalAttemptPurpose? = nil,
        lease: RuntimeExternalLease? = nil,
        reference: String? = nil,
        updatedAt: Date? = nil
    ) throws -> RuntimeCanonicalExternalOperation {
        let operationID = try XCTUnwrap(RuntimeExternalOperationID(rawValue: "operation-1"))
        let provider = RuntimeExternalProviderRouting.providerID(for: .reminder)
        return RuntimeCanonicalExternalOperation(
            operationID: operationID,
            creationDigest: String(repeating: "a", count: 64),
            providerID: provider,
            workflowStatus: status,
            effectDisposition: disposition,
            statusVersion: version,
            policyVersion: 1,
            attemptCount: attempts,
            nextAttemptAt: nil,
            claimPurpose: purpose,
            lease: lease,
            externalReference: try reference.map { try XCTUnwrap(RuntimeExternalProviderReference(rawValue: $0)) },
            reasonCode: nil,
            reasonFingerprint: nil,
            createdAt: now,
            updatedAt: updatedAt ?? now.addingTimeInterval(Double(version - 1))
        )
    }

    private func lease() throws -> RuntimeExternalLease {
        RuntimeExternalLease(
            token: try XCTUnwrap(RuntimeExternalLeaseToken(rawValue: "lease-1")),
            owner: try XCTUnwrap(RuntimeExternalLeaseOwner(rawValue: "executor-1")),
            acquiredAt: now.addingTimeInterval(1),
            expiresAt: now.addingTimeInterval(301)
        )
    }
}
