import AppIntents
import Foundation

struct CreateAmbitionsCaptureIntent: AppIntent {
    static let title: LocalizedStringResource = "Capture in Ambitions"
    static let description = IntentDescription("Save something to Ambitions so it has a place.")
    static let openAppWhenRun = true

    @Parameter(title: "Capture")
    var text: String

    init() {}

    init(text: String) {
        self.text = text
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let now = Date()
        let request: ExternalCreationRequest
        do {
            request = try Self.makeCaptureRequest(text: text, now: now, id: "intent-\(UUID().uuidString)")
        } catch {
            return .result(dialog: "Capture needs text.")
        }

        try await AppIntentBridge(recorder: nil).enqueueExternalCreation(request, acceptedAt: now)

        await MainActor.run {
            if let url = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .captureComposer,
                origin: .appIntent
            ) {
                AppIntentLaunchRouter.shared.queue(url)
            }
        }

        return .result(dialog: IntentDialog("Saved locally to Capture. Open Ambitions to review the receipt."))
    }

    static func makeCaptureRequest(text: String, now: Date, id: String) throws -> ExternalCreationRequest {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw SharedExternalCreationStoreError.emptyText
        }

        return ExternalCreationRequest(
            id: id,
            createdAt: ISO8601DateFormatter().string(from: now),
            text: trimmed,
            source: .appIntent,
            landing: .captureComposer
        )
    }
}

struct CreateAmbitionsGoalDraftIntent: AppIntent {
    static let title: LocalizedStringResource = "Draft Goal in Ambitions"
    static let description = IntentDescription("Save a goal draft locally for review in Ambitions.")
    static let openAppWhenRun = true

    @Parameter(title: "Goal")
    var title: String

    init() {}

    init(title: String) {
        self.title = title
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let now = Date()
        let request: ExternalCreationRequest
        do {
            request = try Self.makeGoalDraftRequest(title: title, now: now, id: "intent-goal-\(UUID().uuidString)")
        } catch {
            return .result(dialog: "Goal draft needs text.")
        }

        try await AppIntentBridge(recorder: nil).enqueueExternalCreation(request, acceptedAt: now)

        await MainActor.run {
            if let url = AmbitionsDeepActionShortcut.goalDraft.descriptor().routeURL {
                AppIntentLaunchRouter.shared.queue(url)
            }
        }

        return .result(dialog: IntentDialog("Saved locally as a goal draft. Open Ambitions to review the receipt."))
    }

    static func makeGoalDraftRequest(title: String, now: Date, id: String) throws -> ExternalCreationRequest {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            throw SharedExternalCreationStoreError.emptyText
        }

        return ExternalCreationRequest(
            id: id,
            createdAt: ISO8601DateFormatter().string(from: now),
            text: trimmed,
            source: .appIntent,
            landing: .createGoal
        )
    }
}
