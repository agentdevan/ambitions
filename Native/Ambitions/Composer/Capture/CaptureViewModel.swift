import Foundation
import Observation

struct CaptureViewState: Sendable {
    let captures: [Capture]
    let activeGoalOptions: [CaptureGoalOption]

    func screenContractSnapshot(topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .capture,
            firstScreenContent: [
                "Field-first Capture",
                "Needs a place",
                "Ready to place",
                "Grow into goal",
                "Changeable route receipt"
            ],
            panels: [
                .capture,
                .smartAttachmentReceipt,
                .receipt,
                .trust
            ],
            actions: [
                .save,
                .attach,
                .changeRoute,
                .keepStandalone
            ],
            drillDowns: ["Review first", "Object details", "Route settings"],
            copySamples: [
                "What should be held for review?",
                "Start here",
                "Create goal",
                "Shape time",
                "Close with proof",
                "Inspect what Ambitions knows",
                "Saved for Today",
                "Saved for review",
                "Save for review",
                "Attached as Proof",
                "Grow into goal"
            ],
            topLevelTabTitles: topLevelTabTitles,
            supportsDensityBehavior: true,
            supportsPanelSizeBehavior: true,
            hasAccessibilitySummary: true,
            hasPrivacySafeState: true,
            hasGestureAlternative: true
        )
    }
}

struct CaptureGoalOption: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let subtitle: String
}

struct CaptureActionMessage: Sendable, Equatable {
    let title: String
    let body: String

    var accessibilityAnnouncement: String {
        "\(title). \(body)"
    }

    var proofArtifactID: String {
        "capture-proof-\(title.lowercased().filter { $0.isLetter || $0.isNumber })"
    }
}

@MainActor
@Observable
final class CaptureViewModel {
    var state: AsyncViewState<CaptureViewState>
    var actionMessage: CaptureActionMessage?
    var draftText = ""
    var draftError: String?
    var draftRoutePreview: CaptureDraftRoutePreview?
    var isProposalPresented = false
    private var draftID = DomainIdentifier.prefixed("shell.capture.draft")
    private var selectedDraftRouteType: SmartAttachmentRouteType?
    private let draftRouteService: CaptureDraftRouteService

    init(
        state: AsyncViewState<CaptureViewState> = .loading,
        actionMessage: CaptureActionMessage? = nil,
        draftRouteService: CaptureDraftRouteService = CaptureDraftRouteService()
    ) {
        self.state = state
        self.actionMessage = actionMessage
        self.draftRouteService = draftRouteService
    }

    var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case let .loaded(viewState):
            return "loaded:\(viewState.captures.count):\(viewState.activeGoalOptions.count):\(draftRoutePreview?.receiptTitle ?? "preview:none")"
        case let .failed(message):
            return "failed:\(message)"
        }
    }

    func load(captureService: any CaptureServicing, goalsService: any GoalsServicing) async {
        do {
            state = .loaded(
                CaptureViewState(
                    captures: try await captureService.listCaptures(),
                    activeGoalOptions: try await activeGoalOptions(from: goalsService)
                )
            )
            refreshDraftRoutingPreview()
        } catch {
            state = .failed("Unable to load Capture: \(error.localizedDescription)")
        }
    }

    func updateDraftText(_ text: String) {
        if text != draftText {
            draftID = DomainIdentifier.prefixed("shell.capture.draft")
        }
        draftText = text
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            selectedDraftRouteType = nil
            draftRoutePreview = nil
            isProposalPresented = false
            return
        }
        isProposalPresented = false
        refreshDraftRoutingPreview()
    }

    func selectDraftRoute(_ routeType: SmartAttachmentRouteType) {
        if routeType != selectedDraftRouteType {
            selectedDraftRouteType = routeType
            draftID = DomainIdentifier.prefixed("shell.capture.draft")
        }
        refreshDraftRoutingPreview()
    }

    func presentProposal() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else {
            draftError = "Write one real thing first."
            return
        }
        refreshDraftRoutingPreview()
        isProposalPresented = draftRoutePreview != nil
    }

    func cancelProposal() {
        isProposalPresented = false
    }

    func createQuickCapture(captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else {
            draftError = "Write one real thing first."
            return
        }

        do {
            let decision = draftRouteService.draftRouteDecision(
                for: text,
                sourceType: .todayQuickCapture,
                sourceSurface: "Capture",
                selectedDraftRouteType: selectedDraftRouteType,
                candidates: smartAttachmentCandidates()
            )
            let capture = try await captureService.createCapture(
                decision.createCaptureRequest(rawText: text, sourceType: .todayQuickCapture),
                now: now
            )
            draftText = ""
            draftError = nil
            selectedDraftRouteType = nil
            draftRoutePreview = nil
            isProposalPresented = false
            actionMessage = CaptureActionMessage(title: receiptTitle(for: capture, fallback: decision.receiptLine), body: capture.assumptionSummary ?? decision.summary)
            await load(captureService: captureService, goalsService: goalsService)
        } catch {
            draftError = error.localizedDescription
        }
    }

    func createQuickCapture(
        commandRouter: any ShellCommandRouting,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        source: ShellCommandEntrySource = .globalCaptureComposer,
        now: Date = .now
    ) async {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else {
            draftError = "Write one real thing first."
            return
        }

        let decision = draftRouteService.draftRouteDecision(
            for: text,
            sourceType: appShellCaptureSourceType(for: source),
            sourceSurface: source.displayTitle,
            selectedDraftRouteType: selectedDraftRouteType,
            candidates: smartAttachmentCandidates()
        )
        let result = await commandRouter.execute(
            intent: .quickCapture,
            text: text,
            goalID: nil,
            captureID: nil,
            source: source,
            selectedCaptureRouteType: selectedDraftRouteType ?? decision.routeType,
            draftID: draftID,
            now: now
        )

        guard let title = result.title, result.createdCaptureID != nil else {
            draftError = result.title ?? "Capture could not be saved."
            return
        }

        draftText = ""
        draftID = DomainIdentifier.prefixed("shell.capture.draft")
        draftError = nil
        selectedDraftRouteType = nil
        draftRoutePreview = nil
        isProposalPresented = false
        actionMessage = CaptureActionMessage(
            title: title,
            body: "Saved locally through Capture. Placement stays editable."
        )
        await load(captureService: captureService, goalsService: goalsService)
    }

    func saveToNeedsPlace(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = id
        _ = captureService
        _ = goalsService
        _ = now
        actionMessage = unavailableMutationMessage(
            "Saving a capture back to Needs a Place requires a typed capture-triage command with receipt and recovery evidence."
        )
    }

    func archive(id: String) async {
        _ = id
        actionMessage = unavailableMutationMessage(
            "Archiving requires a capture command that materializes only after its runtime receipt is committed."
        )
    }

    func routeToTime(id: String) async {
        _ = id
        actionMessage = unavailableMutationMessage(
            "Routing to Time requires a capture command that materializes only after its runtime receipt is committed."
        )
    }

    func markWaiting(id: String) async {
        _ = id
        actionMessage = unavailableMutationMessage(
            "Marking a capture waiting requires a capture command that materializes only after its runtime receipt is committed."
        )
    }

    func markOptionalSomeday(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = id
        _ = captureService
        _ = goalsService
        _ = now
        actionMessage = unavailableMutationMessage(
            "Saving a capture for later requires a typed optional-someday command with receipt and recovery evidence."
        )
    }

    func markDeliverableSeed(id: String, text: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = id
        _ = text
        _ = captureService
        _ = goalsService
        _ = now
        actionMessage = unavailableMutationMessage(
            "Saving a capture as an idea requires a typed deliverable-seed command with receipt and recovery evidence."
        )
    }

    func attachToGoal(
        captureID: String,
        goalID: String,
        goalTitle: String,
        captureGoalHandoffCommands: CaptureGoalHandoffService,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        now: Date = .now
    ) async -> GoalRouteTarget? {
        let outcome = await captureGoalHandoffCommands.perform(
            CaptureGoalHandoffRequest(captureID: captureID, goalID: goalID),
            now: now
        )
        guard outcome.isAttached else {
            actionMessage = CaptureActionMessage(title: "Attach did not finish", body: "Refresh this capture and try again.")
            return nil
        }
        actionMessage = CaptureActionMessage(title: "Attached as Proof · \(goalTitle)", body: "The capture now belongs with that goal.")
        await load(captureService: captureService, goalsService: goalsService)
        return GoalRouteTarget(goalID: goalID)
    }

    func turnIntoGoal(
        captureID: String,
        captureService: any CaptureServicing,
        goalsService: any GoalsServicing,
        now: Date = .now
    ) async -> GoalRouteTarget? {
        _ = captureID
        _ = captureService
        _ = goalsService
        _ = now
        actionMessage = unavailableMutationMessage(
            "Turning a capture into a goal requires an atomic typed capture-to-goal creation command."
        )
        return nil
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
            actionMessage = CaptureActionMessage(title: "Save did not finish", body: error.localizedDescription)
            await load(captureService: captureService, goalsService: goalsService)
            return nil
        }
    }

    private func unavailableMutationMessage(_ detail: String) -> CaptureActionMessage {
        CaptureActionMessage(title: "Action not available yet", body: detail)
    }

    private func receiptTitle(for capture: Capture, fallback: String? = nil) -> String {
        if let fallback { return fallback }
        switch capture.route {
        case .captureInbox:
            return "Saved for review"
        case .timeSeed:
            return "Saved as Step · Today"
        case .goalSeed:
            return "Saved as Goal · Creative"
        case .goalAttachment:
            return "Attached as Proof"
        case .proofItem:
            return "Saved as Proof"
        case .constraintItem:
            return "Saved as Constraint"
        case .waiting:
            return "Saved as Waiting"
        case .deliverableSeed:
            return "Saved as Idea"
        case .optionalSomeday:
            return "Saved as Idea"
        case .archive:
            return "Saved for review"
        }
    }

    private func refreshDraftRoutingPreview() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        draftRoutePreview = draftRouteService.makeDraftRoutePreview(
            for: text,
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture",
            selectedDraftRouteType: selectedDraftRouteType,
            candidates: smartAttachmentCandidates(),
            localSourceLabel: "Typed in Capture"
        )
    }

    private func smartAttachmentCandidates() -> [SmartAttachmentDestinationCandidate] {
        guard case let .loaded(viewState) = state else { return [] }
        return viewState.activeGoalOptions.map { option in
            SmartAttachmentDestinationCandidate(
                id: option.id,
                label: option.title,
                destinationKind: .existingGoal,
                supportedRouteTypes: [.goal, .task, .proofItem],
                placementLabel: option.subtitle
            )
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
