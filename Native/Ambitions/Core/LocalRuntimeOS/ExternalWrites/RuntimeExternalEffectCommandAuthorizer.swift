import Foundation

enum RuntimeExternalEffectAuthorizationError: Error, Sendable, Equatable {
    case authorityDidNotCommit
}

enum RuntimeExternalEffectKind: String, Sendable {
    case reminder
    case calendarEvent = "calendar_event"
}

struct RuntimeExternalEffectRequest: Sendable {
    let operationID: String
    let kind: RuntimeExternalEffectKind
    let source: AmbitionsCommandSource
    let goalID: String
    let stepID: String
    let title: String
    let requestedAt: Date
}

struct RuntimeExternalEffectAuthorization: Sendable {
    let operationID: String
    let localCommit: SideEffectLocalCommitEvidence
}

struct RuntimeExternalEffectCommandAuthorizer: Sendable {
    private let committer: RuntimeCommandMutationCommitter
    private let runtimeEvents: (any RuntimeEventStore)?
    private let pendingOperationStore: any PendingEventKitOperationStoring

    init(repositories: AppRepositories) {
        runtimeEvents = repositories.runtimeEvents
        pendingOperationStore = FilePendingEventKitOperationStore.defaultStore()
        committer = RuntimeCommandMutationCommitter(
            commandJournal: repositories.commandJournal,
            commandExecutionRecords: repositories.commandExecutionRecords,
            runtimeEvents: repositories.runtimeEvents,
            projectionStore: repositories.projectionStore,
            searchIndex: repositories.searchIndex
        )
    }

    func authorize(_ request: RuntimeExternalEffectRequest) async throws -> RuntimeExternalEffectAuthorization {
        let fingerprint = FilePendingEventKitOperationStore.fingerprint(
            kind: request.kind.rawValue,
            goalID: request.goalID,
            stepID: request.stepID
        )
        let operationID = try await pendingOperationStore.resolve(
            fingerprint: fingerprint,
            proposedOperationID: request.operationID
        )
        guard UUID(uuidString: operationID) != nil else {
            throw RuntimeExternalEffectAuthorizationError.authorityDidNotCommit
        }
        let resolvedRequest = RuntimeExternalEffectRequest(
            operationID: operationID,
            kind: request.kind,
            source: request.source,
            goalID: request.goalID,
            stepID: request.stepID,
            title: request.title,
            requestedAt: request.requestedAt
        )
        if let recovered = try await recoveredAuthorization(for: resolvedRequest) {
            return recovered
        }
        let command = command(for: resolvedRequest)
        let result = await commit(command: command, request: resolvedRequest)
        guard let evidence = SideEffectLocalCommitEvidence(
            committedResult: result,
            committedAt: request.requestedAt
        ) else {
            try? await pendingOperationStore.complete(fingerprint: fingerprint, operationID: operationID)
            throw RuntimeExternalEffectAuthorizationError.authorityDidNotCommit
        }
        return RuntimeExternalEffectAuthorization(operationID: operationID, localCommit: evidence)
    }

    private func command(for request: RuntimeExternalEffectRequest) -> AmbitionsCommand {
        let timestamp = DomainTimestamp.string(from: request.requestedAt)
        return AmbitionsCommand(
            id: commandID(for: request),
            kind: .scheduleItem,
            source: request.source,
            target: AmbitionsCommandTarget(
                goalID: request.goalID,
                stepID: request.stepID,
                destination: request.source == .today ? .today : .goalDetail
            ),
            payload: AmbitionsCommandPayload(
                title: request.title,
                metadata: externalEffectMetadata(for: request)
            ),
            createdAt: timestamp,
            requestedAt: timestamp,
            sourceSurface: request.source.rawValue,
            relations: AmbitionsCommandRelations(goalIDs: [request.goalID])
        )
    }

    private func commit(
        command: AmbitionsCommand,
        request: RuntimeExternalEffectRequest
    ) async -> AmbitionsCommandExecutionResult {
        await committer.commit(
            command: command,
            context: CommandExecutionContext(now: request.requestedAt, sourceSurface: request.source.rawValue),
            plannedResult: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "External effect request committed locally.",
                target: command.target,
                metadata: externalEffectMetadata(for: request)
            )
        )
    }

    private func externalEffectMetadata(for request: RuntimeExternalEffectRequest) -> [String: String] {
        [
            "externalEffectKind": request.kind.rawValue,
            "externalEffectOperationID": request.operationID
        ]
    }

    private func recoveredAuthorization(
        for request: RuntimeExternalEffectRequest
    ) async throws -> RuntimeExternalEffectAuthorization? {
        guard let runtimeEvents else { return nil }
        let events = try await runtimeEvents.fetchEvents(matching: .commandID(commandID(for: request)), limit: nil)
        for envelope in events.reversed() {
            guard case let .commandExecution(payload) = envelope.event.payload,
                  payload.resultStatus == .succeeded,
                  payload.resultMetadata["externalEffectKind"] == request.kind.rawValue,
                  payload.resultMetadata["externalEffectOperationID"] == request.operationID else { continue }
            let result = AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: payload.resultSummary,
                target: envelope.event.target,
                metadata: payload.resultMetadata
            )
            guard let evidence = SideEffectLocalCommitEvidence(
                committedResult: result,
                committedAt: DomainTimestamp.date(from: envelope.event.occurredAt) ?? request.requestedAt
            ) else { continue }
            return RuntimeExternalEffectAuthorization(operationID: request.operationID, localCommit: evidence)
        }
        return nil
    }

    private func commandID(for request: RuntimeExternalEffectRequest) -> String {
        return [
            "external-effect",
            request.source.rawValue,
            request.kind.rawValue,
            request.goalID,
            request.stepID,
            request.operationID
        ].joined(separator: ".")
    }
}
