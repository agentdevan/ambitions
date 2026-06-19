import Foundation

enum ShellCommandPresentationContext: String, Hashable, Sendable, Codable {
    case neutral
    case quickCapture
    case createGoal
    case recall
    case recovery
    case focus
    case time
}

struct ShellOverlayState: Hashable, Identifiable, Sendable, Codable {
    let kind: ShellOverlayKind
    let intent: ShellCommandIntent?
    let entrySource: ShellCommandEntrySource
    let presentationContext: ShellCommandPresentationContext
    let query: String
    let goalID: String?
    let captureID: String?

    init(
        kind: ShellOverlayKind,
        intent: ShellCommandIntent? = nil,
        entrySource: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral,
        query: String = "",
        goalID: String? = nil,
        captureID: String? = nil
    ) {
        self.kind = kind
        self.intent = intent
        self.entrySource = entrySource
        self.presentationContext = presentationContext
        self.query = query
        self.goalID = goalID
        self.captureID = captureID
    }

    var id: String {
        [
            kind.rawValue,
            intent?.rawValue ?? "intent:none",
            entrySource.rawValue,
            presentationContext.rawValue,
            query,
            goalID ?? "goal:none",
            captureID ?? "capture:none"
        ].joined(separator: "|")
    }

    var isActivatedCaptureComposer: Bool {
        kind == .quietCommandSheet && (intent == .quickCapture || presentationContext == .quickCapture)
    }

    static func commandSheet(
        intent: ShellCommandIntent? = nil,
        entrySource: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral
    ) -> ShellOverlayState {
        ShellOverlayState(
            kind: .quietCommandSheet,
            intent: intent,
            entrySource: entrySource,
            presentationContext: presentationContext
        )
    }

    static func memoryLens(
        intent: ShellCommandIntent? = .memoryLens,
        entrySource: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .recall,
        query: String = "",
        goalID: String? = nil,
        captureID: String? = nil
    ) -> ShellOverlayState {
        ShellOverlayState(
            kind: .memoryLens,
            intent: intent,
            entrySource: entrySource,
            presentationContext: presentationContext,
            query: query,
            goalID: goalID,
            captureID: captureID
        )
    }

    static func createGoal(
        entrySource: ShellCommandEntrySource,
        query: String = "",
        captureID: String? = nil
    ) -> ShellOverlayState {
        ShellOverlayState(
            kind: .createGoal,
            intent: .newGoal,
            entrySource: entrySource,
            presentationContext: .createGoal,
            query: query,
            captureID: captureID
        )
    }
}
