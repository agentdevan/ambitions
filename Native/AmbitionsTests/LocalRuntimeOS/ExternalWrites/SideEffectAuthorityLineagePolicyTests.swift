import XCTest
@testable import Ambitions

extension ExternalWritesTests {
    func testGenericRuntimeReceiptDoesNotRequireAuthorityLineage() async throws {
        let localCommit = try await runtimeLocalCommit(id: "generic-runtime-receipt")
        let request = makeRequest(id: "generic", localCommit: localCommit)

        let decision = SideEffectPolicyEngine().evaluate(request)

        XCTAssertTrue(decision.mayAttemptExternalWrite)
        XCTAssertTrue(decision.blockedFacts.isEmpty)
    }

    func testRequiredAuthorityLineageAllowsExactMatch() async throws {
        let localCommit = try await runtimeLocalCommit(
            id: "event-kit-lineage-match",
            authorityCommandID: "authority.command",
            operationID: "operation-id"
        )
        let request = makeRequest(
            id: "event-kit.lineage-match",
            commandID: "authority.command",
            operationID: "operation-id",
            authorityLineageRequirement: .required,
            localCommit: localCommit
        )

        let decision = SideEffectPolicyEngine().evaluate(request)

        XCTAssertTrue(decision.mayAttemptExternalWrite)
        XCTAssertTrue(decision.blockedFacts.isEmpty)
    }

    func testRequiredAuthorityLineageDeniesMissingAndMismatchedEvidence() async throws {
        let localCommit = try await runtimeLocalCommit(
            id: "event-kit-lineage-denial",
            authorityCommandID: "authority.command",
            operationID: "operation-a"
        )
        let requests = [
            makeRequest(
                id: "event-kit.lineage-missing",
                authorityLineageRequirement: .required,
                localCommit: localCommit
            ),
            makeRequest(
                id: "event-kit.lineage-mismatch",
                commandID: "authority.command",
                operationID: "operation-b",
                authorityLineageRequirement: .required,
                localCommit: localCommit
            )
        ]

        for request in requests {
            let decision = SideEffectPolicyEngine().evaluate(request)

            XCTAssertFalse(decision.mayAttemptExternalWrite, request.id)
            XCTAssertEqual(decision.blockedFacts, [Self.lineageMismatchFact], request.id)
        }
    }
}

private extension ExternalWritesTests {
    static let lineageMismatchFact =
        "External side effect authority evidence does not match the requested command and operation."

    func runtimeLocalCommit(
        id: String,
        authorityCommandID: String = "",
        operationID: String = ""
    ) async throws -> SideEffectLocalCommitEvidence {
        let coordinator = RuntimeTransactionCoordinator(eventStore: InMemoryRuntimeEventStore())
        let occurredAt = try XCTUnwrap(DomainTimestamp.date(from: "2026-04-25T12:00:00Z"))
        let command = AmbitionsCommand(
            id: id,
            kind: .startStepSession,
            source: .today,
            target: AmbitionsCommandTarget(goalID: "goal-1", stepID: "step-1"),
            payload: AmbitionsCommandPayload(title: "Open step"),
            createdAt: "2026-04-25T12:00:00Z"
        )
        let outcome = try await coordinator.commit(
            command: command,
            beforeSnapshot: "today.before",
            afterSnapshot: "today.after",
            targetSurface: .today,
            occurredAt: occurredAt
        )
        return SideEffectLocalCommitEvidence(
            runtimeReceipt: outcome.receipt,
            authorityCommandID: authorityCommandID,
            operationID: operationID
        )
    }

    func makeRequest(
        id: String,
        commandID: String? = nil,
        operationID: String? = nil,
        authorityLineageRequirement: SideEffectAuthorityLineageRequirement = .notRequired,
        localCommit: SideEffectLocalCommitEvidence
    ) -> SideEffectOutboxRequest {
        SideEffectOutboxRequest(
            id: "side-effect.\(id)",
            effectKind: .calendar,
            actionKind: .writeCalendarBlock,
            sourceDomain: .time,
            commandID: commandID,
            operationID: operationID,
            requestedAt: Date(timeIntervalSince1970: 1_714_000_000),
            externalEffect: true,
            requiresConfirmation: false,
            commitRequirement: .localCommitRequired,
            authorityLineageRequirement: authorityLineageRequirement,
            localCommit: localCommit,
            requestedStatus: .queued,
            requestedBoundary: .externalEffect
        )
    }
}
