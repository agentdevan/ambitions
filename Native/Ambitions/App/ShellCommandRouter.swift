import AmbitionsPresentationContracts
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
    // swiftlint:disable:next function_parameter_count
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
    // swiftlint:disable:next function_parameter_count
    func execute(
        intent: ShellCommandIntent,
        text: String,
        goalID: String?,
        captureID: String?,
        source: ShellCommandEntrySource,
        selectedCaptureRouteType: SmartAttachmentRouteType?,
        draftID: String?,
        now: Date
    ) async -> ShellCommandExecutionResult
}

extension ShellCommandRouting {
    func presentCreateGoal(source: ShellCommandEntrySource) {
        presentCreateGoal(source: source, seedText: "", captureID: nil)
    }

    // swiftlint:disable:next function_parameter_count
    func execute(
        intent: ShellCommandIntent,
        text: String,
        goalID: String?,
        captureID: String?,
        source: ShellCommandEntrySource,
        selectedCaptureRouteType: SmartAttachmentRouteType?,
        now: Date
    ) async -> ShellCommandExecutionResult {
        await execute(
            intent: intent,
            text: text,
            goalID: goalID,
            captureID: captureID,
            source: source,
            selectedCaptureRouteType: selectedCaptureRouteType,
            draftID: nil,
            now: now
        )
    }
}

@MainActor
final class DefaultShellCommandRouter: ShellCommandRouting {
    private let navigation: StageStore
    private let intentSender: any FlagshipIntentSending
    private let smartAttachmentAdapter: SmartAttachmentCaptureAdapter

    init(
        navigation: StageStore,
        intentSender: any FlagshipIntentSending,
        smartAttachmentAdapter: SmartAttachmentCaptureAdapter = SmartAttachmentCaptureAdapter(),
    ) {
        self.navigation = navigation
        self.intentSender = intentSender
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
        draftID: String? = nil,
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
            let saveAttemptID = draftID ?? DomainIdentifier.prefixed("shell.capture.draft")
            guard let entryPoint = FlagshipQuickCaptureEntryPoint(rawValue: source.rawValue),
                  let typedSource = FlagshipCaptureSourceType(rawValue: sourceType.rawValue),
                  let typedRoute = FlagshipQuickCaptureRoute(rawValue: decision.routeType.rawValue) else {
                return rejectedQuickCaptureResult(
                    intent: intent,
                    title: "Capture source is unavailable."
                )
            }
            let intentResult = await intentSender.send(
                .quickCapture(
                    draftID: saveAttemptID,
                    text: trimmed,
                    placementID: decision.result.captureRoute.rawValue,
                    context: FlagshipQuickCaptureContext(
                        entryPoint: entryPoint,
                        sourceType: typedSource,
                        sourceSurface: source.displayTitle,
                        route: typedRoute,
                        requestedAt: now
                    )
                ),
                idempotencyKey: saveAttemptID,
                expectedRevision: nil
            )
            let receipt: FlagshipReceiptReference
            let projectionReady: Bool
            switch intentResult {
            case let .committedProjectionReady(reference):
                receipt = reference
                projectionReady = true
            case let .committedCatchUpRequired(reference):
                receipt = reference
                projectionReady = false
            case let .rejectedBeforeMutation(code, _):
                return rejectedQuickCaptureResult(
                    intent: intent,
                    title: code
                )
            case .revisionConflict,
                 .externalEffectPending,
                 .externalEffectReconciled,
                 .externalEffectFailed:
                return rejectedQuickCaptureResult(
                    intent: intent,
                    title: "Capture could not be saved."
                )
            }
            guard let captureID = receipt.affectedObjects.first(where: { $0.kind == .capture })?.id else {
                return rejectedQuickCaptureResult(
                    intent: intent,
                    title: "Capture proof is still unavailable."
                )
            }

            let destination = captureComposerDestination(source: source)
            if navigation.isActivatedCaptureComposerVisible == false {
                navigation.openCaptureComposer(source: source)
            }
            navigation.recordRoute(
                title: receipt.summary ?? "Saved locally",
                source: source,
                presentationContext: .quickCapture,
                destination: destination,
                receiptBody: "Saved locally in Capture. Placement stays editable."
            )
            return ShellCommandExecutionResult(
                title: receipt.summary ?? "Saved locally",
                destination: destination,
                createdCaptureID: captureID,
                pipelineTrace: intent.productRuntimePipelineTrace(
                    commandValidation: .satisfied("Capture save command has non-empty user text."),
                    runtimeMutation: .satisfied("Typed runtime intent committed local capture \(captureID)."),
                    visibleMutation: .satisfied("Stage opened the global Capture composer after save."),
                    proofReceipt: .satisfied(
                        projectionReady
                            ? "Runtime persisted receipt \(receipt.id) with ready projection cursors."
                            : "Runtime persisted receipt \(receipt.id); projection catch-up remains explicit."
                    ),
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

    private func rejectedQuickCaptureResult(
        intent: ShellCommandIntent,
        title: String
    ) -> ShellCommandExecutionResult {
        ShellCommandExecutionResult(
            title: title,
            pipelineTrace: intent.productRuntimePipelineTrace(
                commandValidation: .satisfied("Capture save command has non-empty user text."),
                runtimeMutation: .blocked("Typed runtime intent did not return complete committed authority."),
                visibleMutation: .blocked("No saved Capture mutation is claimed without complete authority evidence."),
                proofReceipt: .unavailable("No complete receipt and Capture identity were returned."),
                accessibility: .satisfied("Failure returns a user-facing fallback message."),
                fallbackUndo: .satisfied("The previous Capture state remains unchanged.")
            )
        )
    }
}
