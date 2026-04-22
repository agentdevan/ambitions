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
    func presentCreateGoal(source: ShellCommandEntrySource)
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

@MainActor
final class DefaultShellCommandRouter: ShellCommandRouting {
    private let navigation: AppNavigationModel
    private let captureService: any CaptureServicing

    init(
        navigation: AppNavigationModel,
        captureService: any CaptureServicing
    ) {
        self.navigation = navigation
        self.captureService = captureService
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

    func presentCreateGoal(source: ShellCommandEntrySource) {
        navigation.presentCreateGoal(source: source)
    }

    func route(to destination: ShellCommandDestination, source: ShellCommandEntrySource) {
        switch destination {
        case let .tab(tab):
            navigation.selectTab(tab)
        case let .goal(goalID):
            navigation.openGoalDetail(goalID: goalID)
        case let .planRoute(target):
            navigation.openPlanRoute(target)
        case let .insightsRoute(target):
            navigation.openInsightsRoute(target)
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
                let capture = try await captureService.createCapture(
                    CreateCaptureRequest(rawText: trimmed),
                    now: now
                )
                navigation.openCapturesInbox()
                return ShellCommandExecutionResult(
                    title: "Capture saved",
                    destination: .planRoute(.capturesInbox),
                    createdCaptureID: capture.id
                )
            } catch {
                return ShellCommandExecutionResult(title: error.localizedDescription)
            }
        case .newGoal:
            presentCreateGoal(source: source)
            return ShellCommandExecutionResult(destination: .overlay(.createGoal(entrySource: source)))
        case .quickPlanPatch, .openWeek:
            navigation.selectTab(.plan)
            return ShellCommandExecutionResult(destination: .tab(.plan))
        case .quickRecovery:
            navigation.selectToday(entryContext: .recovery)
            return ShellCommandExecutionResult(destination: .tab(.today))
        case .quickFocus:
            navigation.selectToday(entryContext: .focus)
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
            return ShellCommandExecutionResult(destination: .goal(goalID))
        case .openCapture:
            _ = captureID
            navigation.openCapturesInbox()
            return ShellCommandExecutionResult(destination: .planRoute(.capturesInbox))
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
}
