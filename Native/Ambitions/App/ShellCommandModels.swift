import Foundation

enum ShellOverlayKind: String, Hashable, Identifiable, Sendable, Codable {
    case quietCommandSheet = "quiet-command-sheet"
    case memoryLens = "memory-lens"
    case createGoal = "create-goal"

    var id: String { rawValue }
}

enum ShellCommandIntent: String, CaseIterable, Hashable, Identifiable, Sendable, Codable {
    case quickCapture = "quick_capture"
    case newGoal = "new_goal"
    case quickTimePatch = "quick_time_patch"
    case quickRecovery = "quick_recovery"
    case quickFocus = "quick_focus"
    case openGoal = "open_goal"
    case openWeek = "open_week"
    case openCapture = "open_capture"
    case memoryLens = "memory_lens"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .quickCapture: "Capture"
        case .newGoal: "New goal"
        case .quickTimePatch: "Shape Time"
        case .quickRecovery: "Recover"
        case .quickFocus: "Start here"
        case .openGoal: "Open goal"
        case .openWeek: "Open week"
        case .openCapture: "Open capture"
        case .memoryLens: "Search Ambitions"
        }
    }

    var subtitle: String {
        switch self {
        case .quickCapture: "Capture what changed, then decide where it belongs."
        case .newGoal: "Open Goal setup without leaving the native shell path."
        case .quickTimePatch: "Land in Time to reshape the current week."
        case .quickRecovery: "Return to Today with recovery posture in view."
        case .quickFocus: "Return to Today and center the recommended step."
        case .openGoal: "Find and open one goal in its canonical destination."
        case .openWeek: "Open Time as the canonical week surface."
        case .openCapture: "Open Capture."
        case .memoryLens: "Search goals, captures, steps, settings, and recent changes."
        }
    }

    var systemImage: String {
        switch self {
        case .quickCapture: "square.and.pencil"
        case .newGoal: "plus"
        case .quickTimePatch: "calendar.badge.clock"
        case .quickRecovery: "arrow.uturn.left.circle"
        case .quickFocus: "scope"
        case .openGoal: "target"
        case .openWeek: "calendar"
        case .openCapture: "tray.full"
        case .memoryLens: "magnifyingglass"
        }
    }

    var overlayKind: ShellOverlayKind {
        switch self {
        case .openGoal, .openCapture, .openWeek, .memoryLens:
            return .memoryLens
        case .newGoal:
            return .createGoal
        case .quickCapture, .quickTimePatch, .quickRecovery, .quickFocus:
            return .quietCommandSheet
        }
    }

    var presentationContext: ShellCommandPresentationContext {
        switch self {
        case .quickCapture, .openCapture:
            .quickCapture
        case .newGoal:
            .createGoal
        case .quickTimePatch, .openWeek:
            .time
        case .quickRecovery:
            .recovery
        case .quickFocus:
            .focus
        case .openGoal, .memoryLens:
            .recall
        }
    }

    var externalBrainCommandContract: ShellExternalBrainCommandContract {
        switch self {
        case .quickCapture:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .quickCapture,
                destination: .overlay(.commandSheet(intent: .quickCapture, entrySource: .shellCompose, presentationContext: .quickCapture)),
                sourceOfTruth: "Capture",
                safetySummary: "Creates a local capture with context the user can review.",
                fallbackSummary: "If capture persistence is unavailable, leave the command blocked.",
                touchesUserText: true
            )
        case .newGoal:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: nil,
                destination: .overlay(.createGoal(entrySource: .shellCompose)),
                sourceOfTruth: "Goals",
                safetySummary: "Opens the existing goal setup surface without silently creating a goal.",
                fallbackSummary: "If seeded context is missing, open goal setup empty.",
                touchesUserText: true
            )
        case .quickTimePatch, .openWeek:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: .tab(.time),
                sourceOfTruth: "Time",
                safetySummary: "Routes to Time without writing calendar or reshaping the week.",
                fallbackSummary: "If route context is missing, open Time root."
            )
        case .quickRecovery, .quickFocus:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: .tab(.today),
                sourceOfTruth: "Today",
                safetySummary: "Routes to Today with posture context only.",
                fallbackSummary: "If posture context is unavailable, open Today normally."
            )
        case .openGoal:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: nil,
                sourceOfTruth: "Goals",
                safetySummary: "Opens a known goal or asks Search for a source-grounded target.",
                fallbackSummary: "If no goal identifier is present, open Search."
            )
        case .openCapture:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: .openDestination,
                destination: .overlay(.commandSheet(intent: .quickCapture, entrySource: .shellUtility, presentationContext: .quickCapture)),
                sourceOfTruth: "Capture",
                safetySummary: "Opens Capture without mutating saved captures.",
                fallbackSummary: "If capture context is missing, open the global Capture composer."
            )
        case .memoryLens:
            ShellExternalBrainCommandContract(
                intent: self,
                commandKind: nil,
                destination: .overlay(.memoryLens(entrySource: .shellUtility)),
                sourceOfTruth: "Personal context",
                safetySummary: "Searches source-grounded context without creating durable memory.",
                fallbackSummary: "If query context is empty, open Search in recall mode.",
                touchesUserText: true
            )
        }
    }

    var stageActionTaxonomy: StageActionTaxonomy {
        switch self {
        case .quickCapture:
            return .productRuntime
        case .newGoal, .quickTimePatch, .quickRecovery, .quickFocus, .openGoal, .openWeek, .openCapture, .memoryLens:
            return .shellNavigationOverlay
        }
    }

    func shellPipelineTrace(
        routeState: StageActionPipelineRequirement = .satisfied("Shell route or overlay state changed visibly."),
        accessibility: StageActionPipelineRequirement = .satisfied("Shell action keeps an accessible route label."),
        fallback: StageActionPipelineRequirement? = nil
    ) -> StageActionPipelineTrace {
        StageActionPipelineTrace.shellNavigationOverlay(
            inventoryID: "shell.\(rawValue)",
            commandKind: externalBrainCommandContract.commandKind,
            shellRouteChange: routeState,
            accessibilityAnnouncement: accessibility,
            fallbackUndo: fallback ?? .satisfied(externalBrainCommandContract.fallbackSummary),
            scopedFlowIDs: shellScopedFlowIDs,
            knownIssueIDs: shellKnownIssueIDs
        )
    }

    func productRuntimePipelineTrace(
        commandValidation: StageActionPipelineRequirement,
        runtimeMutation: StageActionPipelineRequirement,
        visibleMutation: StageActionPipelineRequirement,
        proofReceipt: StageActionPipelineRequirement,
        accessibility: StageActionPipelineRequirement,
        fallbackUndo: StageActionPipelineRequirement
    ) -> StageActionPipelineTrace {
        StageActionPipelineTrace.productRuntime(
            inventoryID: "shell.\(rawValue)",
            commandKind: externalBrainCommandContract.commandKind ?? .quickCapture,
            commandValidation: commandValidation,
            runtimeMutation: runtimeMutation,
            visibleMutation: visibleMutation,
            proofReceipt: proofReceipt,
            accessibilityAnnouncement: accessibility,
            fallbackUndo: fallbackUndo,
            scopedFlowIDs: shellScopedFlowIDs,
            knownIssueIDs: shellKnownIssueIDs
        )
    }

    private var shellScopedFlowIDs: [String] {
        switch self {
        case .quickCapture:
            return StageActionPipelineInventory.captureSaveFlowIDs
        case .memoryLens, .openGoal, .openCapture:
            return StageActionPipelineInventory.shellSearchInspectionFlowIDs
        case .newGoal:
            return ["SCG006-F05"]
        case .quickTimePatch, .openWeek:
            return StageActionPipelineInventory.timeHandoffFlowIDs
        case .quickRecovery, .quickFocus:
            return ["SCG006-F07"]
        }
    }

    private var shellKnownIssueIDs: [String] {
        switch self {
        case .quickCapture:
            return StageActionPipelineInventory.captureKnownIssueIDs
        case .memoryLens, .openGoal, .openCapture:
            return StageActionPipelineInventory.searchInspectionKnownIssueIDs
        case .newGoal:
            return ["AMB-ISSUE-0004", "AMB-ISSUE-0005"]
        case .quickTimePatch, .openWeek:
            return StageActionPipelineInventory.timeHandoffKnownIssueIDs
        case .quickRecovery, .quickFocus:
            return StageActionPipelineInventory.todayKnownIssueIDs
        }
    }
}

struct ShellExternalBrainCommandContract: Hashable, Sendable {
    let intent: ShellCommandIntent
    let commandKind: AmbitionsCommandKind?
    let destination: ShellCommandDestination?
    let sourceOfTruth: String
    let safetySummary: String
    let fallbackSummary: String
    let requiresUserConfirmation: Bool
    let writesCalendar: Bool
    let createsDurableMemory: Bool
    let touchesUserText: Bool

    init(
        intent: ShellCommandIntent,
        commandKind: AmbitionsCommandKind?,
        destination: ShellCommandDestination?,
        sourceOfTruth: String,
        safetySummary: String,
        fallbackSummary: String,
        requiresUserConfirmation: Bool = false,
        writesCalendar: Bool = false,
        createsDurableMemory: Bool = false,
        touchesUserText: Bool = false
    ) {
        self.intent = intent
        self.commandKind = commandKind
        self.destination = destination
        self.sourceOfTruth = sourceOfTruth
        self.safetySummary = safetySummary
        self.fallbackSummary = fallbackSummary
        self.requiresUserConfirmation = requiresUserConfirmation
        self.writesCalendar = writesCalendar
        self.createsDurableMemory = createsDurableMemory
        self.touchesUserText = touchesUserText
    }

    var isSafeForExternalBrainCommandSurface: Bool {
        writesCalendar == false && createsDurableMemory == false
    }
}
