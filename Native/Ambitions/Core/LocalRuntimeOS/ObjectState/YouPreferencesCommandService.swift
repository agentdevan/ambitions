import AmbitionsDesignSystem
import Foundation

protocol YouPreferencesCommanding: Sendable {
    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard
}

struct YouPreferencesCommandService: YouPreferencesCommanding {
    let repositories: AppRepositories
    let loadDashboard: @Sendable () async throws -> YouDashboard
    let committer: RuntimeCommandMutationCommitter

    init(
        repositories: AppRepositories,
        loadDashboard: @escaping @Sendable () async throws -> YouDashboard
    ) {
        self.repositories = repositories
        self.loadDashboard = loadDashboard
        self.committer = RuntimeCommandMutationCommitter(
            commandJournal: repositories.commandJournal,
            commandExecutionRecords: repositories.commandExecutionRecords,
            runtimeEvents: repositories.runtimeEvents,
            projectionStore: repositories.projectionStore,
            searchIndex: repositories.searchIndex
        )
    }

    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard {
        precondition(preferences.reviewCadenceDays >= 0, "Review cadence days cannot be negative.")

        let now = Date()
        let command = AmbitionsCommand(
            id: "you.preferences.command.\(Int(now.timeIntervalSince1970))",
            kind: .updateUserPreferences,
            source: .you,
            target: AmbitionsCommandTarget(destination: .you),
            payload: AmbitionsCommandPayload(
                title: "Update You preferences",
                metadata: [
                    "preferredTab": preferences.preferredTab.rawValue,
                    "appearancePreference": preferences.appearancePreference.rawValue,
                    "accentFamily": preferences.accentFamily.rawValue,
                    "reviewCadenceDays": String(max(1, preferences.reviewCadenceDays)),
                    "localOnlyModeEnabled": "true",
                ]
            ),
            createdAt: DomainTimestamp.string(from: now),
            actor: .user,
            sourceSurface: "you",
            privacy: .standard
        )

        let result = await committer.commit(
            command: command,
            context: CommandExecutionContext(now: now, actor: .user, sourceSurface: "you")
        ) {
            var state = try await repositories.appState.loadState()
            state.preferredTab = preferences.preferredTab.canonicalTopLevelTab
            state.appearancePreference = preferences.appearancePreference
            state.accentFamily = preferences.accentFamily
            state.reviewCadenceDays = max(1, preferences.reviewCadenceDays)
            state.localOnlyModeEnabled = true

            try await repositories.appState.saveState(state)
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "You preferences saved locally.",
                route: .you,
                target: command.target,
                metadata: [
                    "preferredTab": state.preferredTab.rawValue,
                    "appearancePreference": state.appearancePreference.rawValue,
                    "accentFamily": state.accentFamily.rawValue,
                    "reviewCadenceDays": String(state.reviewCadenceDays),
                    "localOnlyModeEnabled": state.localOnlyModeEnabled ? "true" : "false",
                ]
            )
        }

        if result.status == .succeeded || result.status == .noOp {
            return try await loadDashboard()
        }
        throw YouPreferencesCommandError.commandDidNotCommit(result.summary)
    }
}

enum YouPreferencesCommandError: LocalizedError, Sendable, Equatable {
    case commandDidNotCommit(String)

    var errorDescription: String? {
        switch self {
        case .commandDidNotCommit(let summary):
            return summary
        }
    }
}
