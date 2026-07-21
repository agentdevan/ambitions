import Foundation

struct ShellCommandExecutionResult: Sendable, Equatable {
    let title: String?
    let destination: ShellCommandDestination?
    let createdCaptureID: String?
    let pipelineTrace: StageActionPipelineTrace?

    init(
        title: String? = nil,
        destination: ShellCommandDestination? = nil,
        createdCaptureID: String? = nil,
        pipelineTrace: StageActionPipelineTrace? = nil
    ) {
        self.title = title
        self.destination = destination
        self.createdCaptureID = createdCaptureID
        self.pipelineTrace = pipelineTrace
    }
}

@MainActor
protocol ShellCommandRouting: AnyObject {
    func presentCommandSheet(
        intent: ShellCommandIntent?,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext
    )
    func presentMemoryLens(
        intent: ShellCommandIntent?,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext,
        query: String,
        goalID: String?,
        captureID: String?
    )
    func presentCreateGoal(source: ShellCommandEntrySource, seedText: String, captureID: String?)
    func route(to destination: ShellCommandDestination, source: ShellCommandEntrySource)
    @discardableResult
    func route(searchResult result: MemoryLensResult, source: ShellCommandEntrySource) -> ShellTrustedSearchHandoff
    func execute(
        intent: ShellCommandIntent,
        text: String,
        goalID: String?,
        captureID: String?,
        source: ShellCommandEntrySource,
        selectedCaptureRouteType: SmartAttachmentRouteType?,
        now: Date
    ) async -> ShellCommandExecutionResult
}

extension ShellCommandRouting {
    func presentCreateGoal(source: ShellCommandEntrySource) {
        presentCreateGoal(source: source, seedText: "", captureID: nil)
    }
}

@MainActor
final class DefaultShellCommandRouter: ShellCommandRouting {
    private let navigation: StageStore
    private let commandExecutor: any CommandExecuting
    private let smartAttachmentAdapter: SmartAttachmentCaptureAdapter

    init(
        navigation: StageStore,
        commandExecutor: any CommandExecuting,
        smartAttachmentAdapter: SmartAttachmentCaptureAdapter = SmartAttachmentCaptureAdapter(),
    ) {
        self.navigation = navigation
        self.commandExecutor = commandExecutor
        self.smartAttachmentAdapter = smartAttachmentAdapter
    }

    func presentCommandSheet(
        intent: ShellCommandIntent? = nil,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .neutral
    ) {
        navigation.presentCommandSheet(
            intent: intent,
            source: source,
            presentationContext: presentationContext
        )
    }

    func presentMemoryLens(
        intent: ShellCommandIntent? = .memoryLens,
        source: ShellCommandEntrySource,
        presentationContext: ShellCommandPresentationContext = .recall,
        query: String = "",
        goalID: String? = nil,
        captureID: String? = nil
    ) {
        navigation.presentMemoryLens(
            intent: intent,
            source: source,
            presentationContext: presentationContext,
            query: query,
            goalID: goalID,
            captureID: captureID
        )
    }

    func presentCreateGoal(
        source: ShellCommandEntrySource,
        seedText: String = "",
        captureID: String? = nil
    ) {
        navigation.presentCreateGoal(source: source, seedText: seedText, captureID: captureID)
    }

    func route(to destination: ShellCommandDestination, source: ShellCommandEntrySource) {
        switch destination {
        case let .tab(tab):
            navigation.selectTab(tab)
        case let .goal(goalID):
            navigation.openGoalDetail(goalID: goalID)
        case let .timeRoute(target):
            navigation.openTimeRoute(target)
        case let .youRoute(target):
            navigation.openYouRoute(target)
        case let .overlay(overlay):
            navigation.presentOverlay(
                ShellOverlayState(
                    kind: overlay.kind,
                    intent: overlay.intent,
                    entrySource: source,
                    presentationContext: overlay.presentationContext,
                    query: overlay.query,
                    goalID: overlay.goalID,
                    captureID: overlay.captureID
                )
            )
        }
        navigation.recordRoute(
            title: destination.displayLabel,
            source: source,
            presentationContext: .recall,
            destination: destination,
            receiptBody: receiptBody(for: destination, source: source)
        )
    }

    @discardableResult
    func route(searchResult result: MemoryLensResult, source: ShellCommandEntrySource) -> ShellTrustedSearchHandoff {
        let handoff = result.trustedSearchHandoff(source: source)
        guard handoff.isTrusted else {
            navigation.recordRoute(
                title: "Search result held",
                source: source,
                presentationContext: .recall,
                destination: .overlay(.memoryLens(entrySource: source)),
                receiptBody: handoff.body
            )
            return handoff
        }

        route(to: result.destination, source: source)
        navigation.setContinuityReceipt(ShellContinuityReceipt(
            title: "Search opened",
            body: handoff.body,
            source: source,
            destinationLabel: result.destination.displayLabel
        ))
        return handoff
    }

    func execute(
        intent: ShellCommandIntent,
        text: String = "",
        goalID: String? = nil,
        captureID: String? = nil,
        source: ShellCommandEntrySource,
        selectedCaptureRouteType: SmartAttachmentRouteType? = nil,
        now: Date = .now
    ) async -> ShellCommandExecutionResult {
        switch intent {
        case .quickCapture:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false else {
                return ShellCommandExecutionResult(
                    title: "Capture needs text",
                    pipelineTrace: intent.productRuntimePipelineTrace(
                        commandValidation: .blocked("Capture save requires non-empty user text."),
                        runtimeMutation: .blocked("No capture is saved when command validation fails."),
                        visibleMutation: .blocked("No visible product mutation is shown for an invalid save."),
                        proofReceipt: .unavailable("No proof or receipt is created for a blocked capture save."),
                        accessibility: .satisfied("Blocked command returns a user-facing fallback message."),
                        fallbackUndo: .satisfied("The previous Capture state remains unchanged.")
                    )
                )
            }

            let sourceType = appShellCaptureSourceType(for: source)
            let decision = smartAttachmentAdapter.decision(
                rawText: trimmed,
                sourceType: sourceType,
                sourceSurface: source.displayTitle,
                selectedRouteType: selectedCaptureRouteType
            ) ?? fallbackDecision(for: trimmed, source: source)
            let command = AmbitionsCommand(
                id: DomainIdentifier.prefixed("shell.capture.command"),
                kind: .quickCapture,
                source: ambitionsCommandSource(for: source),
                payload: AmbitionsCommandPayload(
                    rawText: trimmed,
                    destinationRoute: decision.result.captureRoute.rawValue,
                    metadata: captureCommandMetadata(
                        sourceType: sourceType,
                        routeType: decision.routeType,
                        source: source
                    )
                ),
                createdAt: DomainTimestamp.string(from: now),
                actor: .user,
                sourceSurface: source.displayTitle,
                privacy: .privateUserText
            )
            let commandResult = await commandExecutor.execute(
                command,
                context: CommandExecutionContext(
                    now: now,
                    actor: .user,
                    sourceSurface: source.displayTitle
                )
            )
            guard commandResult.status == .succeeded, let captureID = commandResult.target?.captureID else {
                return ShellCommandExecutionResult(
                    title: commandResult.summary,
                    pipelineTrace: intent.productRuntimePipelineTrace(
                        commandValidation: .satisfied("Capture save command has non-empty user text."),
                        runtimeMutation: .blocked("Shared command executor did not commit a Capture mutation."),
                        visibleMutation: .blocked("No saved Capture mutation is claimed after command failure."),
                        proofReceipt: .unavailable("No proof or receipt is created when command execution fails."),
                        accessibility: .satisfied("Failure returns a user-facing fallback message."),
                        fallbackUndo: .satisfied("The previous Capture state remains unchanged.")
                    )
                )
            }

            let destination = captureComposerDestination(source: source)
            if navigation.isActivatedCaptureComposerVisible == false {
                navigation.openCaptureComposer(source: source)
            }
            navigation.recordRoute(
                title: commandResult.summary,
                source: source,
                presentationContext: .quickCapture,
                destination: destination,
                receiptBody: "Saved locally in Capture. Placement stays editable."
            )
            return ShellCommandExecutionResult(
                title: commandResult.summary,
                destination: destination,
                createdCaptureID: captureID,
                pipelineTrace: intent.productRuntimePipelineTrace(
                    commandValidation: .satisfied("Capture save command has non-empty user text."),
                    runtimeMutation: .satisfied("Shared command executor created local capture \(captureID)."),
                    visibleMutation: .satisfied("Stage opened the global Capture composer after save."),
                    proofReceipt: commandResult.metadata["commandReceiptID"] == nil
                        ? .unavailable("Command executor returned no command receipt metadata.")
                        : .satisfied("Command executor persisted receipt \(commandResult.metadata["commandReceiptID"] ?? "")."),
                    accessibility: .satisfied("Capture composer opens with an accessible route label."),
                    fallbackUndo: .satisfied("Placement remains editable if the route proposal is wrong.")
                )
            )
        case .newGoal:
            presentCreateGoal(source: source)
            return ShellCommandExecutionResult(
                destination: .overlay(.createGoal(entrySource: source)),
                pipelineTrace: intent.shellPipelineTrace()
            )
        case .quickTimePatch, .openWeek:
            navigation.selectTab(.time)
            navigation.recordRoute(
                title: intent.title,
                source: source,
                presentationContext: .time,
                destination: .tab(.time),
                receiptBody: "Returned to Time from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .tab(.time), pipelineTrace: intent.shellPipelineTrace())
        case .quickRecovery:
            navigation.selectToday(entryContext: .recovery)
            navigation.recordRoute(
                title: intent.title,
                source: source,
                presentationContext: .recovery,
                destination: .tab(.today),
                receiptBody: "Recovery context opened from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .tab(.today), pipelineTrace: intent.shellPipelineTrace())
        case .quickFocus:
            navigation.selectToday(entryContext: .focus)
            navigation.recordRoute(
                title: intent.title,
                source: source,
                presentationContext: .focus,
                destination: .tab(.today),
                receiptBody: "Focus context opened from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .tab(.today), pipelineTrace: intent.shellPipelineTrace())
        case .openGoal:
            guard let goalID, goalID.isEmpty == false else {
                presentMemoryLens(
                    intent: .openGoal,
                    source: source,
                    presentationContext: .recall
                )
                return ShellCommandExecutionResult(
                    destination: .overlay(.memoryLens(intent: .openGoal, entrySource: source)),
                    pipelineTrace: intent.shellPipelineTrace(
                        routeState: .satisfied("Missing goal target opens Search instead of pretending to mutate runtime."),
                        fallback: .satisfied("Search fallback asks for a source-grounded target.")
                    )
                )
            }
            navigation.openGoalDetail(goalID: goalID)
            navigation.recordRoute(
                title: "Open goal",
                source: source,
                presentationContext: .recall,
                destination: .goal(goalID),
                receiptBody: "Opened Goal Detail from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .goal(goalID), pipelineTrace: intent.shellPipelineTrace())
        case .openCapture:
            _ = captureID
            let destination = captureComposerDestination(source: source)
            navigation.presentGlobalCaptureComposer(source: source)
            navigation.recordRoute(
                title: "Open Capture",
                source: source,
                presentationContext: .quickCapture,
                destination: destination,
                receiptBody: "Opened the global Capture composer from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: destination, pipelineTrace: intent.shellPipelineTrace())
        case .memoryLens:
            presentMemoryLens(
                intent: .memoryLens,
                source: source,
                presentationContext: .recall,
                query: text,
                goalID: goalID,
                captureID: captureID
            )
            return ShellCommandExecutionResult(
                destination: .overlay(.memoryLens(entrySource: source, query: text, goalID: goalID, captureID: captureID)),
                pipelineTrace: intent.shellPipelineTrace()
            )
        }
    }

    private func receiptBody(for destination: ShellCommandDestination, source: ShellCommandEntrySource) -> String? {
        switch source {
        case .widget, .notification, .shareExtension, .appIntent, .external, .deepLink:
            return "Opened \(destination.displayLabel) from \(source.displayTitle) with source context preserved."
        case .shellCompose, .shellUtility, .goalsCreate, .todayQuickCapture, .goalsQuickCapture, .timeQuickCapture, .youQuickCapture, .globalCaptureComposer:
            return nil
        }
    }

}
