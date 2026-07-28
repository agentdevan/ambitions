import Foundation

extension AmbitionsCommandExecutor {
    func executeProfileCommand(
        _ command: AmbitionsCommand,
        profile: ProfileCommand
    ) -> AmbitionsCommandExecutionResult {
        guard profile.action == .updatePreferences,
              let preferences = profile.preferences,
              preferences.reviewCadenceDays > 0,
              preferences.localOnlyModeEnabled else {
            return blockedResult(for: .invalid, command: command)
        }
        return AmbitionsCommandExecutionResult(
            status: .succeeded,
            summary: "You preferences accepted for local runtime commit.",
            route: .you,
            target: profile.target,
            metadata: [
                "preferredTab": preferences.preferredTab.canonicalTopLevelTab.rawValue,
                "appearancePreference": preferences.appearancePreference.rawValue,
                "accentFamily": preferences.accentFamily.rawValue,
                "reviewCadenceDays": String(preferences.reviewCadenceDays),
                "localOnlyModeEnabled": "true",
                "profileMaterialization": "pending_authority_commit",
            ]
        )
    }

    func executeImportDeletionCommand(
        _ command: AmbitionsCommand,
        deletion: ImportDeletionCommand
    ) -> AmbitionsCommandExecutionResult {
        switch deletion.action {
        case .deleteObject, .forgetMemory:
            return AmbitionsCommandExecutionResult(
                status: .succeeded,
                summary: "Confirmed local data control accepted for runtime commit.",
                route: .you,
                target: deletion.target,
                metadata: [
                    "destructiveControl": deletion.action.rawValue,
                    "destructiveMaterialization": "pending_authority_commit",
                ]
            )
        case .prepareExport, .performExport:
            return unsupportedTypedResult(command, validation: command.validationState)
        }
    }
}
