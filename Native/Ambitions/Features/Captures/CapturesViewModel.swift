import Foundation
import Observation

struct CapturesViewState: Sendable {
    let captures: [Capture]
    let activeGoalOptions: [CaptureGoalOption]
}

struct CaptureGoalOption: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
}

struct CaptureActionMessage: Sendable, Equatable {
    let title: String
    let body: String
}

@MainActor
@Observable
final class CapturesViewModel {
    var state: AsyncViewState<CapturesViewState>
    var actionMessage: CaptureActionMessage?
    var draftText = ""
    var draftError: String?

    init(
        state: AsyncViewState<CapturesViewState> = .loading,
        actionMessage: CaptureActionMessage? = nil
    ) {
        self.state = state
        self.actionMessage = actionMessage
    }

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(viewState):
            return "loaded:\(viewState.captures.count):\(viewState.activeGoalOptions.count)"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    func load(captureService: any CaptureServicing, goalsService: any GoalsServicing) async {
        do {
            state = .loaded(
                CapturesViewState(
                    captures: try await captureService.listCaptures(),
                    activeGoalOptions: try await activeGoalOptions(from: goalsService)
                )
            )
        } catch {
            state = .failed("Unable to load captures: \(error.localizedDescription)")
        }
    }

    func createQuickCapture(captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else {
            draftError = "Write the thing first. It can be messy."
            return
        }

        do {
            let capture = try await captureService.createCapture(
                CreateCaptureRequest(rawText: text, sourceType: .todayQuickCapture),
                now: now
            )
            draftText = ""
            draftError = nil
            actionMessage = CaptureActionMessage(title: receiptTitle(for: capture), body: capture.assumptionSummary ?? "Saved to Needs a Place.")
            await load(captureService: captureService, goalsService: goalsService)
        } catch {
            draftError = error.localizedDescription
        }
    }

    func saveAsSeed(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.updateCaptureState(
                CaptureStateUpdateRequest(
                    id: id,
                    status: .seed,
                    triage: CaptureTriageMetadata(destination: .saveAsSeed),
                    kind: .goalSeed,
                    route: .captureInbox,
                    triageStatus: .userCorrected,
                    assumptionSummary: "This is saved as a seed instead of active work."
                ),
                now: now
            )
            actionMessage = CaptureActionMessage(title: "Saved as seed", body: "This capture can wait without getting lost.")
            return nil
        }
    }

    func archive(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.updateCaptureState(
                CaptureStateUpdateRequest(
                    id: id,
                    status: .archived,
                    triage: CaptureTriageMetadata(destination: .archive)
                ),
                now: now
            )
            actionMessage = CaptureActionMessage(title: "Archived", body: "This capture is out of the active inbox.")
            return nil
        }
    }

    func routeToPlan(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.routeToPlanSeed(id: id, now: now)
            actionMessage = CaptureActionMessage(title: "Saved as Plan · This Week", body: "This is represented for Plan without scheduling it yet.")
            return nil
        }
    }

    func markWaiting(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.markAsWaiting(id: id, waitingMetadata: nil, now: now)
            actionMessage = CaptureActionMessage(title: "Marked waiting", body: "This is parked until someone or something unblocks it.")
            return nil
        }
    }

    func markOptionalSomeday(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.markAsOptionalSomeday(id: id, now: now)
            actionMessage = CaptureActionMessage(title: "Parked for someday", body: "This will not compete with active commitments.")
            return nil
        }
    }

    func markDeliverableSeed(id: String, text: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.markAsDeliverableSeed(id: id, deliverableHint: text, now: now)
            actionMessage = CaptureActionMessage(title: "Saved as deliverable seed", body: "This is ready for future goal container work without building that UI here.")
            return nil
        }
    }

    func attachToGoal(
        captureID: String,
        goalID: String,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        now: Date = .now
    ) async -> GoalRouteTarget? {
        await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            guard let binding = try await captureService.attachCaptureToGoal(
                AttachCaptureToGoalRequest(captureID: captureID, goalID: goalID),
                now: now
            ) else {
                actionMessage = CaptureActionMessage(title: "Capture not found", body: "Refresh captures and try again.")
                return nil
            }
            actionMessage = CaptureActionMessage(title: "Attached to goal", body: "The capture now belongs with that goal.")
            return binding.target
        }
    }

    func turnIntoGoal(
        captureID: String,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        now: Date = .now
    ) async -> GoalRouteTarget? {
        await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            guard let binding = try await captureService.turnCaptureIntoGoal(
                TurnCaptureIntoGoalRequest(captureID: captureID),
                now: now
            ) else {
                actionMessage = CaptureActionMessage(title: "Capture not found", body: "Refresh captures and try again.")
                return nil
            }
            actionMessage = CaptureActionMessage(title: "Goal created", body: "The capture is now connected to a new goal.")
            return binding.target
        }
    }

    private func performAndReload(
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        now: Date,
        action: () async throws -> GoalRouteTarget?
    ) async -> GoalRouteTarget? {
        do {
            let target = try await action()
            await load(captureService: captureService, goalsService: goalsService)
            return target
        } catch {
            actionMessage = CaptureActionMessage(title: "Capture action failed", body: error.localizedDescription)
            await load(captureService: captureService, goalsService: goalsService)
            return nil
        }
    }

    private func receiptTitle(for capture: Capture) -> String {
        switch capture.route {
        case .captureInbox:
            return "Saved to Needs a Place"
        case .planSeed:
            return "Saved as Task · Today"
        case .goalSeed:
            return "Saved as Goal · Creative"
        case .goalAttachment:
            return "Attached as Proof"
        case .waiting:
            return "Saved as Waiting"
        case .deliverableSeed:
            return "Saved as Idea"
        case .optionalSomeday:
            return "Saved as Idea"
        case .archive:
            return "Saved to Needs a Place"
        }
    }

    private func activeGoalOptions(from goalsService: any GoalsServicing) async throws -> [CaptureGoalOption] {
        try await goalsService.loadOverview().items
            .filter { $0.renderState == .active }
            .map { item in
                CaptureGoalOption(
                    id: item.id,
                    title: item.title,
                    subtitle: item.statusLabel
                )
            }
    }
}
