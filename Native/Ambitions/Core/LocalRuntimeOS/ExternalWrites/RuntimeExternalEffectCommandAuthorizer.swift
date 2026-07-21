import Foundation

enum RuntimeExternalEffectAuthorizationError: Error, Sendable, Equatable {
    case authorityDidNotCommit
}

enum RuntimeExternalEffectKind: String, Sendable {
    case reminder
    case calendarEvent = "calendar_event"
}

struct RuntimeExternalEffectRequest: Sendable {
    let kind: RuntimeExternalEffectKind
    let source: AmbitionsCommandSource
    let goalID: String
    let stepID: String
    let title: String
    let requestedAt: Date
}

struct RuntimeExternalEffectCommandAuthorizer: Sendable {
    private let committer: RuntimeCommandMutationCommitter

    init(repositories: AppRepositories) {
        committer = RuntimeCommandMutationCommitter(
            commandJournal: repositories.commandJournal,
            commandExecutionRecords: repositories.commandExecutionRecords,
            runtimeEvents: repositories.runtimeEvents,
            projectionStore: repositories.projectionStore,
            searchIndex: repositories.searchIndex
        )
    }

    func authorize(_ request: RuntimeExternalEffectRequest) async throws -> SideEffectLocalCommitEvidence {
        let timestamp = DomainTimestamp.string(from: request.requestedAt)
        let command = AmbitionsCommand(
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
                metadata: ["externalEffectKind": request.kind.rawValue]
            ),
            createdAt: timestamp,
            requestedAt: timestamp,
            sourceSurface: request.source.rawValue,
            relations: AmbitionsCommandRelations(goalIDs: [request.goalID])
        )
        let result = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: request.requestedAt, sourceSurface: request.source.rawValue),
            plannedResult: AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "External effect request committed locally.",
                target: command.target,
                metadata: ["externalEffectKind": request.kind.rawValue]
            )
        )
        guard let evidence = SideEffectLocalCommitEvidence(
            committedResult: result,
            committedAt: request.requestedAt
        ) else {
            throw RuntimeExternalEffectAuthorizationError.authorityDidNotCommit
        }
        return evidence
    }

    private func commandID(for request: RuntimeExternalEffectRequest) -> String {
        let instant = Int64(request.requestedAt.timeIntervalSince1970 * 1_000)
        return [
            "external-effect",
            request.source.rawValue,
            request.kind.rawValue,
            request.goalID,
            request.stepID,
            String(instant)
        ].joined(separator: ".")
    }
}
