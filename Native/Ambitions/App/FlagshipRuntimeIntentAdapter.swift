import AmbitionsPresentationContracts
import CryptoKit
import Foundation

struct FlagshipRuntimeIntentAdapter: FlagshipIntentSending {
    private let runtimeCommandClient: RuntimeCommandClient

    init(runtimeCommandClient: RuntimeCommandClient) {
        self.runtimeCommandClient = runtimeCommandClient
    }

    func send(
        _ intent: FlagshipIntent,
        idempotencyKey: String,
        expectedRevision: Int64?
    ) async -> FlagshipIntentResult {
        guard expectedRevision == nil else {
            return .rejectedBeforeMutation(
                code: "quick_capture_revision_not_supported",
                recoveryAction: .refreshAndRetry
            )
        }

        switch intent {
        case let .quickCapture(draftID, text, placementID, context):
            return await sendQuickCapture(
                draftID: draftID,
                text: text,
                placementID: placementID,
                context: context,
                idempotencyKey: idempotencyKey
            )
        case .createGoal,
             .updateGoal,
             .schedule,
             .correctHistory,
             .semanticUndo,
             .retryExternalEffect:
            return .rejectedBeforeMutation(
                code: "intent_family_not_routed_through_legacy_shell",
                recoveryAction: .editIntent
            )
        }
    }

    private func sendQuickCapture(
        draftID: String,
        text: String,
        placementID: String?,
        context: FlagshipQuickCaptureContext,
        idempotencyKey: String
    ) async -> FlagshipIntentResult {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDraftID = draftID.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = idempotencyKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedText.isEmpty == false,
              trimmedDraftID.isEmpty == false,
              trimmedKey.isEmpty == false else {
            return .rejectedBeforeMutation(
                code: "quick_capture_invalid_draft",
                recoveryAction: .editIntent
            )
        }

        let command = AmbitionsCommand(
            id: Self.commandID(for: trimmedKey),
            kind: .quickCapture,
            source: context.entryPoint.commandSource,
            payload: AmbitionsCommandPayload(
                rawText: trimmedText,
                destinationRoute: placementID,
                metadata: [
                    ExternalCreationCommandMetadataKey.sourceType: context.sourceType.rawValue,
                    "captureEntryPoint": context.entryPoint.rawValue,
                    "captureRouteType": context.route.rawValue,
                    "captureCommandPath": "shell_command_router",
                    "flagshipDraftID": trimmedDraftID
                ]
            ),
            createdAt: DomainTimestamp.string(from: context.requestedAt),
            actor: .user,
            sourceSurface: context.sourceSurface,
            privacy: .privateUserText
        )
        let result = await runtimeCommandClient.execute(
            command,
            CommandExecutionContext(
                now: context.requestedAt,
                actor: .user,
                sourceSurface: context.sourceSurface
            )
        )
        return Self.mapQuickCaptureResult(result, commandID: command.id)
    }

    private static func commandID(for idempotencyKey: String) -> String {
        let digest = SHA256.hash(data: Data(idempotencyKey.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
        return "shell.capture.command-\(digest)"
    }

    private static func mapQuickCaptureResult(
        _ result: AmbitionsCommandExecutionResult,
        commandID: String
    ) -> FlagshipIntentResult {
        guard result.status == .succeeded else {
            let recoveryAction: FlagshipRecoveryAction = result.status == .blocked ? .editIntent : .refreshAndRetry
            return .rejectedBeforeMutation(
                code: result.summary,
                recoveryAction: recoveryAction
            )
        }
        let returnedReceiptID = result.metadata["commandReceiptID"]?.nonEmpty
        let returnedCaptureID = (result.target?.captureID ?? result.metadata["captureID"])?.nonEmpty
        let receiptID = returnedReceiptID ?? "command.receipt.\(commandID)"
        let captureID = returnedCaptureID ?? "capture.\(commandID)"
        let projectionCursors = projectionCursors(from: result.metadata)
        let requiresCatchUp = result.metadata["captureMaterialization"] == "needs_recovery" ||
            projectionCursors.isEmpty ||
            returnedReceiptID == nil ||
            returnedCaptureID == nil
        let receipt = FlagshipReceiptReference(
            id: receiptID,
            projectionCursors: projectionCursors,
            recoveryAction: requiresCatchUp ? .waitForProjection : nil,
            semanticUndoEligible: false,
            summary: result.summary,
            affectedObjects: [
                FlagshipObjectReference(kind: .capture, id: captureID)
            ]
        )
        return requiresCatchUp
            ? .committedCatchUpRequired(receipt)
            : .committedProjectionReady(receipt)
    }

    private static func projectionCursors(from metadata: [String: String]) -> [String: String] {
        guard let countValue = metadata["runtimeProjectionCursorCount"],
              let expectedCount = Int(countValue),
              expectedCount > 0,
              let ids = metadata["runtimeProjectionCursorIDs"]?.split(separator: ",").map(String.init),
              let sequences = metadata["runtimeProjectionCursorSequences"]?.split(separator: ",").map(String.init),
              let checksums = metadata["runtimeProjectionCursorChecksums"]?.split(separator: ",").map(String.init),
              ids.count == expectedCount,
              sequences.count == expectedCount,
              checksums.count == expectedCount else {
            return [:]
        }

        return Dictionary(uniqueKeysWithValues: zip(ids.indices, ids).map { index, id in
            (id, "\(sequences[index]):\(checksums[index])")
        })
    }
}

private extension String {
    var nonEmpty: String? {
        isEmpty ? nil : self
    }
}

private extension FlagshipQuickCaptureEntryPoint {
    var commandSource: AmbitionsCommandSource {
        switch self {
        case .todayQuickCapture:
            .today
        case .goalsCreate, .goalsQuickCapture:
            .goals
        case .timeQuickCapture:
            .time
        case .youQuickCapture:
            .you
        case .appIntent:
            .appIntent
        case .notification:
            .notification
        case .widget:
            .widget
        case .deepLink, .shareExtension:
            .deepLink
        case .shellCompose, .shellUtility, .globalCaptureComposer, .external:
            .capture
        }
    }
}
