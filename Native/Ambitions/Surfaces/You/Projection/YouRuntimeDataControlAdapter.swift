import Foundation

/// Typed admission boundary for You privacy and data controls. It deliberately
/// has no repository fallback: an unavailable selected runtime authority is a
/// blocked control, never a direct local deletion.
enum YouRuntimeDataControlRequest: Sendable, Equatable {
    case updatePreferences(YouPreferencesUpdate)
    case deleteObject(target: AmbitionsCommandTarget)
    case forgetMemory(target: AmbitionsCommandTarget)
}

struct YouRuntimeDestructiveConfirmation: Sendable, Equatable {
    let commandID: String
    let targetObjectIDs: [String]
    let confirmedAt: Date

    init(commandID: String, targetObjectIDs: [String], confirmedAt: Date) {
        self.commandID = commandID
        self.targetObjectIDs = Array(Set(targetObjectIDs.filter { $0.isEmpty == false })).sorted()
        self.confirmedAt = confirmedAt
    }
}

enum YouRuntimeDataControlError: Error, Equatable {
    case destructiveConfirmationRequired
    case unsupportedRequest
    case authorityRejected(String)
    case receiptEvidenceMissing
    case projectionEvidenceMissing
}

struct YouRuntimeDataControlCommit: Sendable, Equatable {
    let command: AmbitionsCommand
    let result: AmbitionsCommandExecutionResult
    let receiptID: String
    let projection: RuntimeProjectionSnapshot
}

/// This is intentionally separate from ephemeral editor state in
/// `YouViewModel`: tab selection while editing, sheet presentation, and other
/// UI-only state never enter a durable Profile command.
struct YouRuntimeDataControlAdapter: Sendable {
    private let runtimeClient: RuntimeCommandClient
    private let commandIDProvider: @Sendable () -> String

    init(
        runtimeClient: RuntimeCommandClient,
        commandIDProvider: @escaping @Sendable () -> String = {
            "you-control.\(UUID().uuidString.lowercased())"
        }
    ) {
        self.runtimeClient = runtimeClient
        self.commandIDProvider = commandIDProvider
    }

    func execute(
        _ request: YouRuntimeDataControlRequest,
        now: Date,
        confirmation: YouRuntimeDestructiveConfirmation? = nil
    ) async throws -> YouRuntimeDataControlCommit {
        let command = try makeCommand(request, now: now, confirmation: confirmation)
        let result = await runtimeClient.execute(
            command,
            CommandExecutionContext(now: now, actor: .user, sourceSurface: "you")
        )
        guard result.status == .succeeded else {
            throw YouRuntimeDataControlError.authorityRejected(
                result.metadata["blockedBy"] ?? result.metadata["rejectionType"] ?? result.summary
            )
        }
        guard RuntimeTransactionCommitPolicy.hasCommittedEvidence(result),
              let receiptID = result.metadata["runtimeReceiptID"],
              receiptID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              let disposition = result.metadata["runtimeTransactionDisposition"],
              RuntimeTransactionCommitDisposition(rawValue: disposition) != nil else {
            throw YouRuntimeDataControlError.receiptEvidenceMissing
        }
        let projectionRequest: RuntimeProjectionRequest = request.isDestructive ? .receipt : .you
        let projection: RuntimeProjectionSnapshot
        do {
            projection = try await runtimeClient.projection(projectionRequest)
        } catch {
            throw YouRuntimeDataControlError.projectionEvidenceMissing
        }
        guard projection.projectionID == projectionRequest.projectionID.rawValue,
              projection.eventSequence > 0,
              projection.cursorChecksum.isEmpty == false,
              Self.projection(projection, matchesCommittedCursorIn: result.metadata) else {
            throw YouRuntimeDataControlError.projectionEvidenceMissing
        }
        return YouRuntimeDataControlCommit(command: command, result: result, receiptID: receiptID, projection: projection)
    }

    private func makeCommand(
        _ request: YouRuntimeDataControlRequest,
        now: Date,
        confirmation: YouRuntimeDestructiveConfirmation?
    ) throws -> AmbitionsCommand {
        switch request {
        case let .updatePreferences(preferences):
            let commandID = commandIDProvider()
            return AmbitionsCommand(
                id: commandID,
                source: .you,
                typedPayload: .profile(ProfileCommand(
                    action: .updatePreferences,
                    target: AmbitionsCommandTarget(destination: .you),
                    content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Update You preferences")),
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
        case let .deleteObject(target), let .forgetMemory(target):
            guard let confirmation,
                  confirmation.commandID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
                  confirmation.targetObjectIDs == Self.targetObjectIDs(for: target) else {
                throw YouRuntimeDataControlError.destructiveConfirmationRequired
            }
            // The reviewed command identity is also the idempotency identity.
            let commandID = confirmation.commandID
            let action: ImportDeletionCommand.Action = switch request {
            case .deleteObject: .deleteObject
            case .forgetMemory: .forgetMemory
            case .updatePreferences: throw YouRuntimeDataControlError.unsupportedRequest
            }
            return AmbitionsCommand(
                id: commandID,
                source: .you,
                typedPayload: .importDeletion(ImportDeletionCommand(
                    action: action,
                    target: target,
                    content: RuntimeCommandContent(AmbitionsCommandPayload(title: "Confirmed local data control"))
                )),
                createdAt: DomainTimestamp.string(from: now),
                actor: .user,
                sourceSurface: "you",
                privacy: .sensitive
            )
        }
    }
}

/// Reachable preferences service for the SystemSurface bootstrap. It performs
/// the legacy app-state write only after the selected canonical runtime has
/// produced receipt and You-projection evidence; a v8 unavailable client
/// therefore cannot fall back to this derived materialization.
struct RuntimeSelectedYouPreferencesCommandService: YouPreferencesCommanding {
    let adapter: YouRuntimeDataControlAdapter
    let appStateRepository: any AppStateRepository
    let loadDashboard: @Sendable () async throws -> YouDashboard

    func saveYouPreferences(_ preferences: YouPreferencesUpdate) async throws -> YouDashboard {
        let commit = try await adapter.execute(.updatePreferences(preferences), now: Date())
        guard commit.result.metadata["profileMaterialization"] == "pending_authority_commit" else {
            throw YouRuntimeDataControlError.receiptEvidenceMissing
        }
        var state = try await appStateRepository.loadState()
        state.preferredTab = preferences.preferredTab.canonicalTopLevelTab
        state.appearancePreference = preferences.appearancePreference
        state.accentFamily = preferences.accentFamily
        state.reviewCadenceDays = max(1, preferences.reviewCadenceDays)
        state.localOnlyModeEnabled = true
        try await appStateRepository.saveState(state)
        return try await loadDashboard()
    }
}

private extension YouRuntimeDataControlAdapter {
    static func targetObjectIDs(for target: AmbitionsCommandTarget) -> [String] {
        Array(Set([
            target.goalID, target.captureID, target.timeID, target.stepID,
            target.deliverableID, target.scopeItemID, target.reviewID,
            target.recommendationID, target.explanationID,
        ].compactMap { $0 })).sorted()
    }

    static func projection(
        _ projection: RuntimeProjectionSnapshot,
        matchesCommittedCursorIn metadata: [String: String]
    ) -> Bool {
        let ids = metadata["runtimeMaterializedProjectionCursorIDs"]?
            .split(separator: ",")
            .map(String.init) ?? []
        let sequences = metadata["runtimeMaterializedProjectionCursorSequences"]?
            .split(separator: ",")
            .compactMap { Int64($0) } ?? []
        let checksums = metadata["runtimeMaterializedProjectionCursorChecksums"]?
            .split(separator: ",")
            .map(String.init) ?? []
        guard ids.count == sequences.count,
              ids.count == checksums.count,
              let index = ids.firstIndex(of: projection.projectionID) else {
            return false
        }
        return projection.eventSequence == sequences[index] &&
            projection.cursorChecksum == checksums[index]
    }
}

private extension YouRuntimeDataControlRequest {
    var isDestructive: Bool {
        switch self {
        case .deleteObject, .forgetMemory: true
        case .updatePreferences: false
        }
    }
}
