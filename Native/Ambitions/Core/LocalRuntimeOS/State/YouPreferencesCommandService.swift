import AmbitionsDesignSystem
import Foundation

protocol YouPreferencesCommanding: Sendable {
    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard
}

struct YouPreferencesCommandService: YouPreferencesCommanding {
    let repositories: AppRepositories
    let loadDashboard: @Sendable () async throws -> YouDashboard
    let committer: RuntimeCommandMutationCommitter
    let commandIDProvider: @Sendable () -> String

    init(
        repositories: AppRepositories,
        loadDashboard: @escaping @Sendable () async throws -> YouDashboard,
        commandIDProvider: @escaping @Sendable () -> String = {
            "you-preferences-command-\(UUID().uuidString.lowercased())"
        }
    ) {
        self.repositories = repositories
        self.loadDashboard = loadDashboard
        self.commandIDProvider = commandIDProvider
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
        let plan = YouPreferencesCommandPlan(
            preferences: preferences,
            commandID: commandIDProvider(),
            now: now
        )
        let appStateRepository = repositories.appState

        let result = await committer.commit(
            command: plan.command,
            context: CommandExecutionContext(now: now, actor: .user, sourceSurface: "you"),
            plannedResult: plan.result,
            materialization: RuntimeCommandMaterialization(
                statusMetadataKey: "appStateMaterialization"
            ) { committedResult in
                let desired = try YouPreferencesMaterializationValues(committedResult: committedResult)
                var state = try await appStateRepository.loadState()
                state.preferredTab = desired.preferredTab
                state.appearancePreference = desired.appearancePreference
                state.accentFamily = desired.accentFamily
                state.reviewCadenceDays = desired.reviewCadenceDays
                state.localOnlyModeEnabled = desired.localOnlyModeEnabled

                try await appStateRepository.saveState(state)
                return [
                    "appStateID": state.id,
                    "preferredTab": state.preferredTab.rawValue,
                    "appearancePreference": state.appearancePreference.rawValue,
                    "accentFamily": state.accentFamily.rawValue,
                    "reviewCadenceDays": String(state.reviewCadenceDays),
                    "localOnlyModeEnabled": state.localOnlyModeEnabled ? "true" : "false"
                ]
            }
        )

        if result.status == .succeeded || result.status == .noOp,
           result.metadata["appStateMaterialization"] == "saved_post_authority" {
            return try await loadDashboard()
        }
        if RuntimeTransactionCommitPolicy.hasCommittedEvidence(result) {
            throw YouPreferencesCommandError.commandMaterializationNeedsRecovery(result.summary)
        }
        throw YouPreferencesCommandError.commandDidNotCommit(result.summary)
    }
}

private struct YouPreferencesCommandPlan: Sendable {
    let command: AmbitionsCommand
    let result: AmbitionsCommandExecutionResult

    init(preferences: YouPreferencesUpdate, commandID: String, now: Date) {
        let metadata = [
            "preferredTab": preferences.preferredTab.canonicalTopLevelTab.rawValue,
            "appearancePreference": preferences.appearancePreference.rawValue,
            "accentFamily": preferences.accentFamily.rawValue,
            "reviewCadenceDays": String(max(1, preferences.reviewCadenceDays)),
            "localOnlyModeEnabled": "true"
        ]
        let target = AmbitionsCommandTarget(destination: .you)
        let content = AmbitionsCommandPayload(title: "Update You preferences")
        command = AmbitionsCommand(
            id: commandID,
            source: .you,
            typedPayload: .profile(ProfileCommand(
                action: .updatePreferences,
                target: target,
                content: RuntimeCommandContent(content),
                preferences: ProfilePreferencesCommandValues(
                    preferredTab: preferences.preferredTab.canonicalTopLevelTab,
                    appearancePreference: preferences.appearancePreference,
                    accentFamily: preferences.accentFamily,
                    reviewCadenceDays: max(1, preferences.reviewCadenceDays),
                    localOnlyModeEnabled: true
                )
            )),
            createdAt: DomainTimestamp.string(from: now),
            actor: .user,
            sourceSurface: "you",
            privacy: .standard
        )
        result = AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "You preferences saved locally.",
            route: .you,
            target: command.target,
            metadata: metadata
        )
    }
}

enum YouPreferencesCommandError: LocalizedError, Sendable, Equatable {
    case commandDidNotCommit(String)
    case commandMaterializationNeedsRecovery(String)

    var errorDescription: String? {
        switch self {
        case .commandDidNotCommit(let summary):
            return summary
        case .commandMaterializationNeedsRecovery(let summary):
            return "\(summary) App state materialization needs recovery before Ambitions can show the saved dashboard."
        }
    }
}

private struct YouPreferencesMaterializationValues: Sendable {
    let preferredTab: AmbitionsSurface
    let appearancePreference: AppAppearancePreference
    let accentFamily: AmbitionAccentFamily
    let reviewCadenceDays: Int
    let localOnlyModeEnabled: Bool

    init(committedResult: AmbitionsCommandExecutionResult) throws {
        let metadata = committedResult.metadata
        guard let preferredTabValue = metadata["preferredTab"],
              let preferredTab = AmbitionsSurface(rawValue: preferredTabValue),
              let appearanceValue = metadata["appearancePreference"],
              let appearancePreference = AppAppearancePreference(rawValue: appearanceValue),
              let accentValue = metadata["accentFamily"],
              let accentFamily = AmbitionAccentFamily(rawValue: accentValue),
              let cadenceValue = metadata["reviewCadenceDays"],
              let reviewCadenceDays = Int(cadenceValue),
              reviewCadenceDays > 0,
              metadata["localOnlyModeEnabled"] == "true" else {
            throw YouPreferencesMaterializationError.invalidCommittedMetadata
        }
        self.preferredTab = preferredTab.canonicalTopLevelTab
        self.appearancePreference = appearancePreference
        self.accentFamily = accentFamily
        self.reviewCadenceDays = reviewCadenceDays
        self.localOnlyModeEnabled = true
    }
}

private enum YouPreferencesMaterializationError: Error {
    case invalidCommittedMetadata
}
