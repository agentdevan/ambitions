import Foundation

struct ShellCommandExecutionResult: Sendable, Equatable {
    let title: String?
    let destination: ShellCommandDestination?
    let createdCaptureID: String?

    init(title: String? = nil, destination: ShellCommandDestination? = nil, createdCaptureID: String? = nil) {
        self.title = title
        self.destination = destination
        self.createdCaptureID = createdCaptureID
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
    func execute(
        intent: ShellCommandIntent,
        text: String,
        goalID: String?,
        captureID: String?,
        source: ShellCommandEntrySource,
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
    private let navigation: AppNavigationModel
    private let captureService: any CaptureServicing
    private let smartAttachmentAdapter: SmartAttachmentCaptureAdapter

    init(
        navigation: AppNavigationModel,
        captureService: any CaptureServicing,
        smartAttachmentAdapter: SmartAttachmentCaptureAdapter = SmartAttachmentCaptureAdapter()
    ) {
        self.navigation = navigation
        self.captureService = captureService
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
            if tab == .capture {
                navigation.presentCaptureCompatibilityRoute(source: source)
                return
            }
            navigation.selectTab(tab)
        case let .goal(goalID):
            navigation.openGoalDetail(goalID: goalID)
        case let .timeRoute(target):
            if target == .captureInbox {
                navigation.openCapturesInbox(source: source)
                return
            }
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

    func execute(
        intent: ShellCommandIntent,
        text: String = "",
        goalID: String? = nil,
        captureID: String? = nil,
        source: ShellCommandEntrySource,
        now: Date = .now
    ) async -> ShellCommandExecutionResult {
        switch intent {
        case .quickCapture:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.isEmpty == false else {
                return ShellCommandExecutionResult(title: "Capture needs text")
            }

            do {
                let decision = smartAttachmentAdapter.decision(
                    rawText: trimmed,
                    sourceType: captureSourceType(for: source),
                    sourceSurface: source.displayTitle
                )
                let capture = try await captureService.createCapture(
                    (decision ?? fallbackDecision(for: trimmed, source: source)).createCaptureRequest(
                        rawText: trimmed,
                        sourceType: captureSourceType(for: source)
                    ),
                    now: now
                )
                navigation.openCapturesInbox(source: source)
                navigation.recordRoute(
                    title: decision?.receiptLine ?? "Saved to Needs a Place",
                    source: source,
                    presentationContext: .quickCapture,
                    destination: .timeRoute(.captureInbox),
                    receiptBody: "Saved locally with a receipt you can change in Capture."
                )
                return ShellCommandExecutionResult(
                    title: decision?.receiptLine ?? "Saved to Needs a Place",
                    destination: .timeRoute(.captureInbox),
                    createdCaptureID: capture.id
                )
            } catch {
                return ShellCommandExecutionResult(title: error.localizedDescription)
            }
        case .newGoal:
            presentCreateGoal(source: source)
            return ShellCommandExecutionResult(destination: .overlay(.createGoal(entrySource: source)))
        case .quickTimePatch, .openWeek:
            navigation.selectTab(.time)
            navigation.recordRoute(
                title: intent.title,
                source: source,
                presentationContext: .time,
                destination: .tab(.time),
                receiptBody: "Returned to Time from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .tab(.time))
        case .quickRecovery:
            navigation.selectToday(entryContext: .recovery)
            navigation.recordRoute(
                title: intent.title,
                source: source,
                presentationContext: .recovery,
                destination: .tab(.today),
                receiptBody: "Recovery context opened from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .tab(.today))
        case .quickFocus:
            navigation.selectToday(entryContext: .focus)
            navigation.recordRoute(
                title: intent.title,
                source: source,
                presentationContext: .focus,
                destination: .tab(.today),
                receiptBody: "Focus context opened from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .tab(.today))
        case .openGoal:
            guard let goalID, goalID.isEmpty == false else {
                presentMemoryLens(
                    intent: .openGoal,
                    source: source,
                    presentationContext: .recall
                )
                return ShellCommandExecutionResult(destination: .overlay(.memoryLens(intent: .openGoal, entrySource: source)))
            }
            navigation.openGoalDetail(goalID: goalID)
            navigation.recordRoute(
                title: "Open goal",
                source: source,
                presentationContext: .recall,
                destination: .goal(goalID),
                receiptBody: "Opened the canonical Goal Detail from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .goal(goalID))
        case .openCapture:
            _ = captureID
            navigation.openCapturesInbox(source: source)
            navigation.recordRoute(
                title: "Open capture",
                source: source,
                presentationContext: .recall,
                destination: .timeRoute(.captureInbox),
                receiptBody: "Opened Capture from \(source.displayTitle)."
            )
            return ShellCommandExecutionResult(destination: .timeRoute(.captureInbox))
        case .memoryLens:
            presentMemoryLens(
                intent: .memoryLens,
                source: source,
                presentationContext: .recall,
                query: text,
                goalID: goalID,
                captureID: captureID
            )
            return ShellCommandExecutionResult(destination: .overlay(.memoryLens(entrySource: source, query: text, goalID: goalID, captureID: captureID)))
        }
    }

    private func receiptBody(for destination: ShellCommandDestination, source: ShellCommandEntrySource) -> String? {
        switch source {
        case .widget, .notification, .shareExtension, .appIntent, .external, .deepLink:
            return "Opened \(destination.displayLabel) from \(source.displayTitle) with source context preserved."
        case .shellCompose, .shellUtility, .goalsCreate, .todayQuickCapture, .goalsQuickCapture, .timeQuickCapture, .motionQuickCapture, .youQuickCapture, .capturesScreen:
            return nil
        }
    }

    private func captureSourceType(for source: ShellCommandEntrySource) -> CaptureSourceType? {
        switch source {
        case .todayQuickCapture:
            return .todayQuickCapture
        case .appIntent:
            return .appIntent
        case .notification:
            return .notification
        case .shareExtension:
            return .shareExtensionText
        case .shellCompose, .shellUtility, .goalsCreate, .goalsQuickCapture, .timeQuickCapture, .motionQuickCapture, .youQuickCapture, .capturesScreen, .deepLink, .widget, .external:
            return nil
        }
    }

    private func fallbackDecision(for text: String, source: ShellCommandEntrySource) -> SmartAttachmentCaptureDecision {
        SmartAttachmentCaptureAdapter().decision(
            rawText: text,
            sourceType: captureSourceType(for: source),
            sourceSurface: source.displayTitle,
            selectedRouteType: .idea
        )!
    }
}
