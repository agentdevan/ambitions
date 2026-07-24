import Foundation

enum RuntimeExternalEffectAuthorizationError: Error, Sendable, Equatable {
    case authorityDidNotCommit
}

enum RuntimeExternalEffectKind: String, Codable, Sendable, Equatable, Hashable {
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
    let commandID: String
    let localCommit: SideEffectLocalCommitEvidence
}

struct RuntimeExternalEffectCommandAuthorizer: Sendable {
    private let committer: RuntimeCommandMutationCommitter
    private let runtimeEvents: (any RuntimeEventStore)?
    private let pendingOperationStore: any PendingEventKitOperationStoring

    init(
        repositories: AppRepositories,
        pendingOperationStore: any PendingEventKitOperationStoring =
            FilePendingEventKitOperationStore.defaultStore()
    ) {
        runtimeEvents = repositories.runtimeEvents
        self.pendingOperationStore = pendingOperationStore
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
        let command = try command(for: resolvedRequest)
        let result = await commit(command: command, request: resolvedRequest)
        let authorityCommandID = commandID(for: resolvedRequest)
        guard let evidence = SideEffectLocalCommitEvidence(
            committedResult: result,
            committedAt: request.requestedAt,
            authorityCommandID: authorityCommandID,
            operationID: operationID
        ) else {
            try? await pendingOperationStore.complete(fingerprint: fingerprint, operationID: operationID)
            throw RuntimeExternalEffectAuthorizationError.authorityDidNotCommit
        }
        return RuntimeExternalEffectAuthorization(
            operationID: operationID,
            commandID: authorityCommandID,
            localCommit: evidence
        )
    }

    private func command(for request: RuntimeExternalEffectRequest) throws -> AmbitionsCommand {
        let timestamp = DomainTimestamp.string(from: request.requestedAt)
        let target = AmbitionsCommandTarget(
            goalID: request.goalID,
            stepID: request.stepID,
            destination: request.source == .today ? .today : .goalDetail
        )
        guard let operationID = RuntimeExternalOperationID(rawValue: request.operationID),
              operationID.rawValue == request.operationID else {
            throw RuntimeFoundationError.invalidIdentity(.externalOperation)
        }
        return AmbitionsCommand(
            id: commandID(for: request),
            source: request.source,
            typedPayload: .externalOperation(ExternalOperationCommand(
                operationID: operationID,
                kind: request.kind,
                target: target,
                title: request.title
            )),
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
                committedAt: DomainTimestamp.date(from: envelope.event.occurredAt) ?? request.requestedAt,
                authorityCommandID: commandID(for: request),
                operationID: request.operationID
            ) else { continue }
            return RuntimeExternalEffectAuthorization(
                operationID: request.operationID,
                commandID: commandID(for: request),
                localCommit: evidence
            )
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
