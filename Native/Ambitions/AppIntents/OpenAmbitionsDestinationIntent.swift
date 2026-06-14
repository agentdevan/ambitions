import AppIntents
import Foundation

enum AmbitionsAppShortcutDestination: String, CaseIterable, AppEnum {
    case today
    case goals
    case time = "plan"
    case captureInbox = "captures_inbox"
    case you
    case command
    case memoryLens = "memory_lens"
    case quickCapture = "quick_capture"
    case startNextStep = "start_next_step"
    case markDone = "mark_done"
    case saveTheDay = "save_the_day"
    case quickRecovery = "quick_recovery"
    case quickFocus = "quick_focus"
    case quickTimePatch = "quick_plan_patch"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Destination"
    static let typeDisplayName: LocalizedStringResource = "Destination"

    static var caseDisplayRepresentations: [AmbitionsAppShortcutDestination: DisplayRepresentation] {
        [
            .today: DisplayRepresentation(title: "Today"),
            .goals: DisplayRepresentation(title: "Goals"),
            .time: DisplayRepresentation(title: "Time"),
            .captureInbox: DisplayRepresentation(title: "Capture"),
            .you: DisplayRepresentation(title: "You"),
            .command: DisplayRepresentation(title: "Add something"),
            .memoryLens: DisplayRepresentation(title: "What Ambitions Knows"),
            .quickCapture: DisplayRepresentation(title: "Capture"),
            .startNextStep: DisplayRepresentation(title: "Start here"),
            .markDone: DisplayRepresentation(title: "Close the loop"),
            .saveTheDay: DisplayRepresentation(title: "Make today doable"),
            .quickRecovery: DisplayRepresentation(title: "Make today doable"),
            .quickFocus: DisplayRepresentation(title: "Start now"),
            .quickTimePatch: DisplayRepresentation(title: "Shape Time"),
        ]
    }

    var appRoute: AppExternalRoute {
        switch self {
        case .today:
            return .openTab(.today)
        case .goals:
            return .openTab(.goals)
        case .time:
            return .openTab(.time)
        case .captureInbox:
            return .openTimeRoute(.captureInbox)
        case .you:
            return .openTab(.you)
        case .command:
            return .presentOverlay(.commandSheet(entrySource: .appIntent))
        case .memoryLens:
            return .presentOverlay(.memoryLens(entrySource: .appIntent))
        case .quickCapture:
            return .presentOverlay(.commandSheet(intent: .quickCapture, entrySource: .appIntent, presentationContext: .quickCapture))
        case .startNextStep:
            return .openToday(.focus)
        case .markDone:
            return .openToday(.focus)
        case .saveTheDay:
            return .openToday(.recovery)
        case .quickRecovery:
            return .openToday(.recovery)
        case .quickFocus:
            return .openToday(.focus)
        case .quickTimePatch:
            return .openTab(.time)
        }
    }

    var displayTitle: String {
        switch self {
        case .today:
            return "Today"
        case .goals:
            return "Goals"
        case .time:
            return "Time"
        case .captureInbox:
            return "Capture"
        case .you:
            return "You"
        case .command:
            return "Add something"
        case .memoryLens:
            return "What Ambitions Knows"
        case .quickCapture:
            return "Capture"
        case .startNextStep:
            return "Start here"
        case .markDone:
            return "Close the loop"
        case .saveTheDay:
            return "Make today doable"
        case .quickRecovery:
            return "Make today doable"
        case .quickFocus:
            return "Start now"
        case .quickTimePatch:
            return "Shape Time"
        }
    }

    var routeURL: URL? {
        d25CommandDescriptor.routeURL
    }

    var isPFC18PublicLaunchCandidate: Bool {
        switch self {
        case .today, .goals, .time, .captureInbox, .you, .command, .memoryLens, .startNextStep, .markDone, .saveTheDay:
            return true
        case .quickCapture, .quickRecovery, .quickFocus, .quickTimePatch:
            return false
        }
    }
}

enum AmbitionsShortcutExecutionPosture: String, Sendable, Equatable {
    case opensAppOnly
    case queuesLocalCapture
    case requiresInAppConfirmation
}

struct AmbitionsShortcutCommandDescriptor: Sendable, Equatable {
    let destination: AmbitionsAppShortcutDestination
    let title: String
    let dialog: String
    let commandKind: AmbitionsCommandKind
    let actionName: ExternalSurfaceActionName
    let contractKind: ExternalSurfaceKind
    let executionPosture: AmbitionsShortcutExecutionPosture
    let producesReceipt: Bool
    let privacySummary: String
    let routeURL: URL?

    var requiresConfirmation: Bool {
        executionPosture == .requiresInAppConfirmation
    }
}

extension AmbitionsAppShortcutDestination {
    var d25CommandDescriptor: AmbitionsShortcutCommandDescriptor {
        let routeURL = Self.url(for: appRoute)
        switch self {
        case .today:
            return descriptor(
                title: "Today",
                dialog: "Opening Today in Ambitions.",
                commandKind: .openDestination,
                actionName: .openToday,
                routeURL: routeURL
            )
        case .goals:
            return descriptor(
                title: "Goals",
                dialog: "Opening Goals in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .time, .quickTimePatch:
            return descriptor(
                title: displayTitle,
                dialog: "Opening Time in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .captureInbox:
            return descriptor(
                title: "Capture",
                dialog: "Opening Capture in Ambitions.",
                commandKind: .openDestination,
                actionName: .openCapturesInbox,
                routeURL: routeURL
            )
        case .you:
            return descriptor(
                title: "You",
                dialog: "Opening You in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .command:
            return descriptor(
                title: "Add something",
                dialog: "Opening the quiet add sheet in Ambitions.",
                commandKind: .openDestination,
                actionName: .open,
                routeURL: routeURL
            )
        case .memoryLens:
            return descriptor(
                title: "What Ambitions Knows",
                dialog: "Opening What Ambitions Knows.",
                commandKind: .openDestination,
                actionName: .openMemoryLens,
                routeURL: routeURL
            )
        case .quickCapture:
            return descriptor(
                title: "Capture",
                dialog: "Opening Capture in Ambitions.",
                commandKind: .quickCapture,
                actionName: .openCapturesInbox,
                executionPosture: .queuesLocalCapture,
                producesReceipt: true,
                routeURL: routeURL
            )
        case .startNextStep, .quickFocus:
            return descriptor(
                title: displayTitle,
                dialog: "Opening the recommended step in Ambitions.",
                commandKind: .startStepSession,
                actionName: .openToday,
                routeURL: routeURL
            )
        case .markDone:
            return descriptor(
                title: "Close the loop",
                dialog: "Open Ambitions to close the loop.",
                commandKind: .completeAction,
                actionName: .complete,
                executionPosture: .requiresInAppConfirmation,
                producesReceipt: true,
                routeURL: routeURL
            )
        case .saveTheDay, .quickRecovery:
            return descriptor(
                title: displayTitle,
                dialog: "Open Ambitions to make today doable.",
                commandKind: .recoverAction,
                actionName: .openToday,
                executionPosture: .requiresInAppConfirmation,
                producesReceipt: true,
                routeURL: routeURL
            )
        }
    }

    private func descriptor(
        title: String,
        dialog: String,
        commandKind: AmbitionsCommandKind,
        actionName: ExternalSurfaceActionName,
        executionPosture: AmbitionsShortcutExecutionPosture = .opensAppOnly,
        producesReceipt: Bool = false,
        routeURL: URL?
    ) -> AmbitionsShortcutCommandDescriptor {
        let contract = ExternalSurfaceContractRegistry.contract(for: .appIntents)
        return AmbitionsShortcutCommandDescriptor(
            destination: self,
            title: title,
            dialog: dialog,
            commandKind: commandKind,
            actionName: actionName,
            contractKind: contract.kind,
            executionPosture: executionPosture,
            producesReceipt: producesReceipt,
            privacySummary: contract.hidesSensitiveDetailsByDefault
                ? ExternalSurfacePrivacySnapshotPolicy.safeDefault.sensitiveDetailLabel
                : "Shortcut details follow your Ambitions privacy settings.",
            routeURL: routeURL
        )
    }

    private static func url(for appRoute: AppExternalRoute) -> URL? {
        guard var components = AppExternalRouteTranslator().deepLinkURL(for: appRoute).flatMap({
            URLComponents(url: $0, resolvingAgainstBaseURL: false)
        }) else {
            return nil
        }
        var queryItems = components.queryItems ?? []
        if queryItems.contains(where: { $0.name == "origin" }) == false {
            queryItems.append(URLQueryItem(name: "origin", value: ExternalSurfaceOrigin.appIntent.rawValue))
        }
        components.queryItems = queryItems
        return components.url
    }
}

struct OpenAmbitionsDestinationIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Ambitions"
    static let description = IntentDescription("Open Today, Goals, Time, Motion, You, global Capture, or another Ambitions surface.")
    static let openAppWhenRun = true

    @Parameter(title: "Destination")
    var destination: AmbitionsAppShortcutDestination

    init() {}

    init(destination: AmbitionsAppShortcutDestination) {
        self.destination = destination
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard let url = destination.routeURL else {
            return .result(dialog: "Ambitions could not open that destination.")
        }

        await MainActor.run {
            AppIntentLaunchRouter.shared.queue(url)
        }
        return .result(dialog: IntentDialog(stringLiteral: destination.d25CommandDescriptor.dialog))
    }
}

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
        let request: ExternalCreationRequest
        do {
            request = try Self.makeCaptureRequest(text: text, now: Date(), id: "intent-\(UUID().uuidString)")
        } catch {
            return .result(dialog: "Capture needs text.")
        }

        try SharedExternalCreationStore().append(request)

        await MainActor.run {
            if let url = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .captureInbox,
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
            landing: .captureInbox
        )
    }
}

enum AmbitionsDeepActionShortcut: String, CaseIterable, AppEnum {
    case capture
    case goalDraft = "goal_draft"
    case openCurrentStep = "open_current_step"
    case startCurrentStep = "start_current_step"
    case guardedCloseStep = "guarded_close_step"
    case showReceipt = "show_receipt"
    case inspectLocalKnowledge = "inspect_local_knowledge"

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Ambitions Action"
    static let typeDisplayName: LocalizedStringResource = "Ambitions Action"

    static var caseDisplayRepresentations: [AmbitionsDeepActionShortcut: DisplayRepresentation] {
        [
            .capture: DisplayRepresentation(title: "Capture"),
            .goalDraft: DisplayRepresentation(title: "Draft goal"),
            .openCurrentStep: DisplayRepresentation(title: "Open step"),
            .startCurrentStep: DisplayRepresentation(title: "Start now"),
            .guardedCloseStep: DisplayRepresentation(title: "Close step"),
            .showReceipt: DisplayRepresentation(title: "Show receipt"),
            .inspectLocalKnowledge: DisplayRepresentation(title: "What Ambitions Knows"),
        ]
    }
}

struct AmbitionsDeepActionDescriptor: Sendable, Equatable {
    let action: AmbitionsDeepActionShortcut
    let commandKind: AmbitionsCommandKind
    let routeURL: URL?
    let executionPosture: AmbitionsShortcutExecutionPosture
    let producesReceipt: Bool
    let privacySummary: String

    var requiresConfirmation: Bool {
        executionPosture == .requiresInAppConfirmation
    }
}

extension AmbitionsDeepActionShortcut {
    func descriptor(
        goalID: String? = nil,
        stepID: String? = nil,
        receiptID: String? = nil,
        knowledgeQuery: String? = nil
    ) -> AmbitionsDeepActionDescriptor {
        let contract = ExternalSurfaceContractRegistry.contract(for: .appIntents)
        return AmbitionsDeepActionDescriptor(
            action: self,
            commandKind: commandKind,
            routeURL: routeURL(goalID: goalID, stepID: stepID, receiptID: receiptID, knowledgeQuery: knowledgeQuery),
            executionPosture: executionPosture,
            producesReceipt: producesReceipt,
            privacySummary: contract.hidesSensitiveDetailsByDefault
                ? ExternalSurfacePrivacySnapshotPolicy.safeDefault.sensitiveDetailLabel
                : "Shortcut details follow your Ambitions privacy settings."
        )
    }

    private var commandKind: AmbitionsCommandKind {
        switch self {
        case .capture:
            return .quickCapture
        case .goalDraft:
            return .createGoal
        case .openCurrentStep, .showReceipt, .inspectLocalKnowledge:
            return .openDestination
        case .startCurrentStep:
            return .startStepSession
        case .guardedCloseStep:
            return .completeAction
        }
    }

    private var executionPosture: AmbitionsShortcutExecutionPosture {
        switch self {
        case .capture, .goalDraft:
            return .queuesLocalCapture
        case .guardedCloseStep:
            return .requiresInAppConfirmation
        case .openCurrentStep, .startCurrentStep, .showReceipt, .inspectLocalKnowledge:
            return .opensAppOnly
        }
    }

    private var producesReceipt: Bool {
        switch self {
        case .capture, .goalDraft, .guardedCloseStep:
            return true
        case .openCurrentStep, .startCurrentStep, .showReceipt, .inspectLocalKnowledge:
            return false
        }
    }

    private func routeURL(
        goalID: String?,
        stepID: String?,
        receiptID: String?,
        knowledgeQuery: String?
    ) -> URL? {
        switch self {
        case .capture:
            return Self.url(for: .openTimeRoute(.captureInbox))
        case .goalDraft:
            return Self.url(for: .presentOverlay(.commandSheet(entrySource: .appIntent)))
        case .openCurrentStep, .guardedCloseStep:
            return Self.stepRouteURL(goalID: goalID, stepID: stepID) ?? Self.url(for: .openToday(.focus))
        case .startCurrentStep:
            return Self.url(for: .openToday(.focus))
        case .showReceipt:
            return Self.url(
                for: .presentOverlay(.memoryLens(
                    entrySource: .appIntent,
                    query: receiptID.map { "receipt:\($0)" } ?? ""
                ))
            )
        case .inspectLocalKnowledge:
            return Self.url(
                for: .presentOverlay(.memoryLens(
                    entrySource: .appIntent,
                    query: knowledgeQuery ?? ""
                ))
            )
        }
    }

    private static func stepRouteURL(goalID: String?, stepID: String?) -> URL? {
        guard let goalID = nonEmpty(goalID),
              let url = url(for: .openGoalDetail(goalID: goalID)),
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }
        var queryItems = components.queryItems ?? []
        if let stepID = nonEmpty(stepID) {
            queryItems.append(URLQueryItem(name: "stepID", value: stepID))
        }
        components.queryItems = queryItems
        return components.url
    }

    private static func url(for appRoute: AppExternalRoute) -> URL? {
        guard var components = AppExternalRouteTranslator().deepLinkURL(for: appRoute).flatMap({
            URLComponents(url: $0, resolvingAgainstBaseURL: false)
        }) else {
            return nil
        }
        var queryItems = components.queryItems ?? []
        if queryItems.contains(where: { $0.name == "origin" }) == false {
            queryItems.append(URLQueryItem(name: "origin", value: ExternalSurfaceOrigin.appIntent.rawValue))
        }
        components.queryItems = queryItems
        return components.url
    }

    private static func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
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
        let request: ExternalCreationRequest
        do {
            request = try Self.makeGoalDraftRequest(title: title, now: Date(), id: "intent-goal-\(UUID().uuidString)")
        } catch {
            return .result(dialog: "Goal draft needs text.")
        }

        try SharedExternalCreationStore().append(request)

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

struct OpenAmbitionsCurrentStepIntent: AppIntent {
    static let title: LocalizedStringResource = "Open Ambitions Step"
    static let description = IntentDescription("Open a current step in Ambitions without exposing step text in Shortcuts.")
    static let openAppWhenRun = true

    @Parameter(title: "Goal ID")
    var goalID: String

    @Parameter(title: "Step ID")
    var stepID: String

    init() {}

    init(goalID: String, stepID: String) {
        self.goalID = goalID
        self.stepID = stepID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .openCurrentStep,
            goalID: goalID,
            stepID: stepID,
            dialog: "Opening the step in Ambitions."
        )
    }
}

struct StartAmbitionsCurrentStepIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Ambitions Step"
    static let description = IntentDescription("Open Ambitions to Start now for the current recommended step.")
    static let openAppWhenRun = true

    @Parameter(title: "Goal ID")
    var goalID: String

    @Parameter(title: "Step ID")
    var stepID: String

    init() {}

    init(goalID: String, stepID: String) {
        self.goalID = goalID
        self.stepID = stepID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .startCurrentStep,
            goalID: goalID,
            stepID: stepID,
            dialog: "Opening Start now in Ambitions."
        )
    }
}

struct GuardedCloseAmbitionsStepIntent: AppIntent {
    static let title: LocalizedStringResource = "Close Ambitions Step"
    static let description = IntentDescription("Open Ambitions to confirm step closure and record a receipt.")
    static let openAppWhenRun = true

    @Parameter(title: "Goal ID")
    var goalID: String

    @Parameter(title: "Step ID")
    var stepID: String

    init() {}

    init(goalID: String, stepID: String) {
        self.goalID = goalID
        self.stepID = stepID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .guardedCloseStep,
            goalID: goalID,
            stepID: stepID,
            dialog: "Open Ambitions to confirm closure and save the receipt."
        )
    }
}

struct ShowAmbitionsReceiptIntent: AppIntent {
    static let title: LocalizedStringResource = "Show Ambitions Receipt"
    static let description = IntentDescription("Open the local receipt inspection surface in Ambitions.")
    static let openAppWhenRun = true

    @Parameter(title: "Receipt ID")
    var receiptID: String

    init() {}

    init(receiptID: String) {
        self.receiptID = receiptID
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .showReceipt,
            receiptID: receiptID,
            dialog: "Opening the receipt in Ambitions."
        )
    }
}

struct InspectAmbitionsLocalKnowledgeIntent: AppIntent {
    static let title: LocalizedStringResource = "Inspect What Ambitions Knows"
    static let description = IntentDescription("Open What Ambitions Knows for bounded local inspection.")
    static let openAppWhenRun = true

    @Parameter(title: "Topic")
    var topic: String

    init() {}

    init(topic: String) {
        self.topic = topic
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        return await Self.queue(
            .inspectLocalKnowledge,
            knowledgeQuery: topic,
            dialog: "Opening What Ambitions Knows."
        )
    }
}

private extension AppIntent {
    @MainActor
    static func queue(
        _ action: AmbitionsDeepActionShortcut,
        goalID: String? = nil,
        stepID: String? = nil,
        receiptID: String? = nil,
        knowledgeQuery: String? = nil,
        dialog: String
    ) -> some IntentResult & ProvidesDialog {
        guard let url = action.descriptor(
            goalID: goalID,
            stepID: stepID,
            receiptID: receiptID,
            knowledgeQuery: knowledgeQuery
        ).routeURL else {
            return .result(dialog: "Ambitions could not open that action.")
        }
        AppIntentLaunchRouter.shared.queue(url)
        return .result(dialog: IntentDialog(stringLiteral: dialog))
    }
}

struct AmbitionsShortcutsProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CreateAmbitionsCaptureIntent(),
            phrases: [
                "Capture in \(.applicationName)",
                "Add to \(.applicationName)",
            ],
            shortTitle: "Capture",
            systemImageName: "square.and.pencil"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .today),
            phrases: [
                "Open Today in \(.applicationName)",
                "Show Today in \(.applicationName)",
            ],
            shortTitle: "Open Today",
            systemImageName: "sun.max"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .goals),
            phrases: [
                "Open Goals in \(.applicationName)",
                "Show Goals in \(.applicationName)",
            ],
            shortTitle: "Open Goals",
            systemImageName: "target"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .time),
            phrases: [
                "Open Time in \(.applicationName)",
                "Show Time in \(.applicationName)",
            ],
            shortTitle: "Open Time",
            systemImageName: "calendar.badge.clock"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .captureInbox),
            phrases: [
                "Open Capture in \(.applicationName)",
                "Show Capture in \(.applicationName)",
            ],
            shortTitle: "Open Capture",
            systemImageName: "tray.full"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .memoryLens),
            phrases: [
                "Open what \(.applicationName) knows",
                "Show what \(.applicationName) knows",
            ],
            shortTitle: "What Ambitions Knows",
            systemImageName: "magnifyingglass"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .you),
            phrases: [
                "Open You in \(.applicationName)",
                "Show You in \(.applicationName)",
            ],
            shortTitle: "Open You",
            systemImageName: "person.crop.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .startNextStep),
            phrases: [
                "Start here in \(.applicationName)",
                "Start my recommended step in \(.applicationName)",
            ],
            shortTitle: "Start Here",
            systemImageName: "scope"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .markDone),
            phrases: [
                "Close the loop in \(.applicationName)",
                "Close my step in \(.applicationName)",
            ],
            shortTitle: "Close Loop",
            systemImageName: "checkmark.circle"
        )
        AppShortcut(
            intent: OpenAmbitionsDestinationIntent(destination: .saveTheDay),
            phrases: [
                "Make today doable in \(.applicationName)",
                "Open recovery in \(.applicationName)",
            ],
            shortTitle: "Make Doable",
            systemImageName: "arrow.uturn.left.circle"
        )
    }

    static var shortcutTileColor: ShortcutTileColor {
        .teal
    }
}
