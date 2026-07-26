@testable import Ambitions
import Foundation
import XCTest

final class RuntimeExternalOperationContractTests: XCTestCase {
    func testV7CatalogIsFullExactAndHasNoLegacyWriteAuthority() {
        let sql = CanonicalRuntimeExternalOperationSchemaPlan.fullGenerationStatements
            .joined(separator: "\n")
        XCTAssertFalse(sql.isEmpty)
        XCTAssertTrue(sql.contains("runtime_external_operation_creations"))
        XCTAssertTrue(sql.contains("runtime_external_operation_current_fenced_transition"))
        XCTAssertTrue(sql.contains("missing external transition invalidation"))
        XCTAssertTrue(sql.contains("runtime_external_operation_creations_bind_receipt_command_event"))
        XCTAssertTrue(sql.contains("runtime_command_idempotency_require_complete_receipt"))
        XCTAssertFalse(sql.contains("CREATE TABLE runtime_pending_external_operations"))
        XCTAssertFalse(sql.contains("CREATE TABLE runtime_external_operations"))
        XCTAssertFalse(sql.contains("GENERATED ALWAYS"))
    }

    func testRetryPolicyIsBoundedAndJitterDeterministic() throws {
        let policy = try RuntimeExternalRetryPolicy(
            maximumAttempts: 3, baseDelay: 10, maximumDelay: 40, jitterFraction: 0.2
        )
        let now = Date(timeIntervalSince1970: 1_000)
        XCTAssertEqual(policy.decision(afterAttempt: 3, now: now, deterministicUnitInterval: 0.5), .exhausted)
        XCTAssertEqual(policy.decision(afterAttempt: 0, now: now, deterministicUnitInterval: 0.5), .invalidInput)
        XCTAssertEqual(
            policy.decision(afterAttempt: 1, now: now, deterministicUnitInterval: 0.5),
            .schedule(Date(timeIntervalSince1970: 1_010))
        )
    }

    func testPersistedRetryPolicyVersionResolvesOneImmutableConfiguration() throws {
        let canonical = try RuntimeExternalRetryPolicyAuthority.resolve(version: 1)
        XCTAssertEqual(canonical.version, RuntimeExternalRetryPolicyAuthority.currentVersion)
        XCTAssertEqual(
            try RuntimeExternalRetryPolicyAuthority.requireExact(canonical, persistedVersion: 1),
            canonical
        )
        let sameVersionDifferentBehavior = try RuntimeExternalRetryPolicy(
            version: 1,
            maximumAttempts: 3,
            baseDelay: 10,
            maximumDelay: 40,
            jitterFraction: 0.2
        )
        XCTAssertThrowsError(try RuntimeExternalRetryPolicyAuthority.requireExact(
            sameVersionDifferentBehavior,
            persistedVersion: 1
        ))
        XCTAssertThrowsError(try RuntimeExternalRetryPolicyAuthority.resolve(version: 2))
    }

    func testOutcomeAuthorityIsAnExhaustiveActionAndPurposeWhitelist() {
        let allowed: [
            RuntimeCanonicalExternalOperationPayload.Action:
                [RuntimeExternalAttemptPurpose: Set<RuntimeExternalAttemptOutcomeKind>]
        ] = [
            .create: [
                .execute: [
                    .confirmedSuccess, .rejectedBeforeEffect, .retryableBeforeEffect,
                    .permissionUnavailableBeforeEffect, .indeterminate,
                    .leaseExpiredWithoutOutcome,
                ],
                .reconcile: [
                    .confirmedPresence, .confirmedAbsence, .ambiguousReconciliation,
                    .incompatibleProviderState, .leaseExpiredWithoutOutcome,
                ],
            ],
            .compensateRemoval: [
                .execute: [
                    .confirmedCancellation, .cancellationRetryableBeforeEffect,
                    .cancellationUnsupported, .permissionUnavailableBeforeEffect,
                    .indeterminate, .leaseExpiredWithoutOutcome,
                ],
                .reconcile: [
                    .cancellationSourceStillPresent, .reconciledCancellationAbsent,
                    .ambiguousReconciliation, .incompatibleProviderState,
                    .leaseExpiredWithoutOutcome,
                ],
            ],
        ]
        for action in [
            RuntimeCanonicalExternalOperationPayload.Action.create,
            .compensateRemoval,
        ] {
            for purpose in [RuntimeExternalAttemptPurpose.execute, .reconcile] {
                for kind in RuntimeExternalAttemptOutcomeKind.allCases {
                    XCTAssertEqual(
                        RuntimeExternalOperationCodec.permitsOutcome(
                            action: action, purpose: purpose, kind: kind
                        ),
                        allowed[action]?[purpose]?.contains(kind) == true,
                        "Unexpected whitelist result for \(action)/\(purpose)/\(kind)"
                    )
                }
            }
        }
    }

    func testProviderRoutingAndReasonFingerprintDoNotPersistRawErrorText() throws {
        let provider = RuntimeExternalProviderRouting.providerID(for: .reminder)
        XCTAssertEqual(provider.rawValue, "apple.eventkit.reminders.v1")
        let first = RuntimeExternalReasonFingerprint.redacted(code: .providerRejected, providerID: provider)
        let second = RuntimeExternalReasonFingerprint.redacted(code: .providerRejected, providerID: provider)
        XCTAssertEqual(first, second)
        XCTAssertEqual(first.rawValue.count, 64)
        XCTAssertFalse(first.rawValue.contains("provider_rejected"))
    }

    func testCancellationAndReconciliationOutcomesAreActionAware() throws {
        let attempt = try XCTUnwrap(RuntimeExternalAttemptID(rawValue: "attempt-1"))
        let operation = try XCTUnwrap(RuntimeExternalOperationID(rawValue: "operation-1"))
        let provider = RuntimeExternalProviderRouting.providerID(for: .calendarEvent)
        let now = Date(timeIntervalSince1970: 1_000)
        let cancelled = RuntimeExternalOperationCodec.outcome(
            attemptID: attempt, operationID: operation, providerID: provider,
            cancellation: .confirmedCancellation, at: now
        )
        XCTAssertEqual(cancelled.kind, .confirmedCancellation)
        XCTAssertEqual(cancelled.effectDisposition, .confirmedAbsent)
        let reconciled = RuntimeExternalOperationCodec.outcome(
            attemptID: attempt, operationID: operation, providerID: provider,
            reconciliation: .confirmedAbsent, action: .compensateRemoval, at: now
        )
        XCTAssertEqual(reconciled.kind, .reconciledCancellationAbsent)
        XCTAssertEqual(reconciled.effectDisposition, .confirmedAbsent)
    }

    func testSchemaFencesCoverAtomicClaimStaleLeaseExpiryAndTerminalImmutability() {
        let sql = CanonicalRuntimeExternalOperationSchemaPlan.fullGenerationStatements
            .joined(separator: "\n")
        XCTAssertTrue(sql.contains("terminal external operation is immutable"))
        XCTAssertTrue(sql.contains("invalid external operation fence"))
        XCTAssertTrue(sql.contains("lease_expired_without_outcome"))
        XCTAssertTrue(sql.contains("UNIQUE (operation_id, source_status_version)"))
        XCTAssertTrue(sql.contains("UNIQUE (attempt_id, operation_id)"))
        XCTAssertTrue(sql.contains("runtime_external_operation_attempt_outcome_bind_start"))
        XCTAssertTrue(sql.contains("c.operation_action = 'create' AND a.purpose = 'execute'"))
        XCTAssertTrue(sql.contains("c.operation_action = 'compensate_removal' AND a.purpose = 'reconcile'"))
        XCTAssertFalse(sql.contains("NEW.outcome_kind NOT IN"))
        XCTAssertEqual(
            sql.components(separatedBy: "CHECK (policy_version = 1)").count - 1,
            3
        )
        XCTAssertFalse(sql.contains("policy_version > 0"))
        XCTAssertThrowsError(try RuntimeExternalRetryPolicyAuthority.resolve(version: 2))
    }
}
