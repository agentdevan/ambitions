import Foundation
import Observation

// AMBITIONS-QUALITY-EXTRACTION: CaptureViewModel still carries direct-service editing actions plus the AMB-1674 command-routed save path. A future Capture view-model slice should separate command save orchestration from post-save edit actions.

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
            drillDowns: ["Needs a Place", "Object details", "Route settings"],
            copySamples: [
                "What needs a place?",
                "Start here",
                "Create goal",
                "Shape time",
                "Close with proof",
                "Inspect what Ambitions knows",
                "Saved for Today",
                "Saved to Needs a Place",
                "Save to Needs a Place",
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
        selectedDraftRouteType = routeType
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
            now: now
        )

        guard let title = result.title, result.createdCaptureID != nil else {
            draftError = result.title ?? "Capture could not be saved."
            return
        }

        draftText = ""
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
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.updateCaptureState(
                CaptureStateUpdateRequest(
                    id: id,
                    status: .needsTriage,
                    triage: CaptureTriageMetadata(destination: .needsTriage, hint: "Held in Needs a Place until the route is clearer."),
                    kind: .raw,
                    route: .captureInbox,
                    triageStatus: .userCorrected,
                    assumptionSummary: "Held without pressure until you choose a clearer route."
                ),
                now: now
            )
            actionMessage = CaptureActionMessage(title: "Saved to Needs a Place", body: "Held without pressure until you choose a clearer route.")
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
            actionMessage = CaptureActionMessage(title: "Archived", body: "This capture is out of the active list.")
            return nil
        }
    }

    func routeToTime(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.routeToTimeSeed(id: id, now: now)
            actionMessage = CaptureActionMessage(title: "Saved as Step · Today", body: "This can become time work later; no calendar event was created.")
            return nil
        }
    }

    func markWaiting(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.markAsWaiting(id: id, waitingMetadata: nil, now: now)
            actionMessage = CaptureActionMessage(title: "Saved as Waiting", body: "This is parked until someone or something unblocks it.")
            return nil
        }
    }

    func markOptionalSomeday(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.markAsOptionalSomeday(id: id, now: now)
            actionMessage = CaptureActionMessage(title: "Review later", body: "This will not compete with active commitments.")
            return nil
        }
    }

    func markDeliverableSeed(id: String, text: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.markAsDeliverableSeed(id: id, deliverableHint: text, now: now)
            actionMessage = CaptureActionMessage(title: "Saved as Idea", body: "This stays findable without becoming scheduled work.")
            return nil
        }
    }

    func attachToGoal(
        captureID: String,
        goalID: String,
        goalTitle: String,
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
            actionMessage = CaptureActionMessage(title: "Attached as Proof · \(goalTitle)", body: "The capture now belongs with that goal.")
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
            actionMessage = CaptureActionMessage(title: "Saved as Goal · Creative", body: "The capture is now connected to a new goal.")
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
            actionMessage = CaptureActionMessage(title: "Save did not finish", body: error.localizedDescription)
            await load(captureService: captureService, goalsService: goalsService)
            return nil
        }
    }

    private func receiptTitle(for capture: Capture, fallback: String? = nil) -> String {
        if let fallback { return fallback }
        switch capture.route {
        case .captureInbox:
            return "Saved to Needs a Place"
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
            return "Saved to Needs a Place"
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
