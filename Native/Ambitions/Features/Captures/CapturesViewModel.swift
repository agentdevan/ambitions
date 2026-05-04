import Foundation
import Observation

struct CapturesViewState: Sendable {
    let captures: [Capture]
    let activeGoalOptions: [CaptureGoalOption]

    func screenContractSnapshot(topLevelTabTitles: [String] = ScreenContractValidator.canonicalTopLevelTabs) -> ScreenContractImplementationSnapshot {
        ScreenContractImplementationSnapshot(
            screenID: .capture,
            firstScreenContent: [
                "Bottom composer",
                "Needs a Place",
                "Suggested routes",
                "Ready to Place",
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
                "Saved as Task · Today",
                "Saved to Needs a Place",
                "Attached as Proof"
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
}

struct CaptureDraftRouteChoice: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let routeType: SmartAttachmentRouteType
    let isSelected: Bool
}

struct CaptureDraftRoutePreview: Sendable, Equatable {
    let originalText: String
    let postInputStateTitle: String
    let receiptTitle: String
    let summary: String
    let routeProofTitle: String
    let routeProofDetail: String
    let destinationLabel: String
    let objectTypeLabel: String
    let appearanceLabel: String
    let consequenceLabel: String
    let privacyLabel: String
    let primaryActionTitle: String
    let changeActionTitle: String
    let safeActionTitle: String
    let semanticState: String
    let clarificationQuestion: String?
    let choices: [CaptureDraftRouteChoice]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String?

    var visibleCopy: String {
        ([
            originalText,
            postInputStateTitle,
            receiptTitle,
            summary,
            routeProofTitle,
            routeProofDetail,
            destinationLabel,
            objectTypeLabel,
            appearanceLabel,
            consequenceLabel,
            privacyLabel,
            primaryActionTitle,
            changeActionTitle,
            safeActionTitle,
            clarificationQuestion
        ].compactMap { $0 } + choices.map(\.title)).joined(separator: " ")
    }
}

@MainActor
@Observable
final class CapturesViewModel {
    var state: AsyncViewState<CapturesViewState>
    var actionMessage: CaptureActionMessage?
    var draftText = ""
    var draftError: String?
    var draftRoutePreview: CaptureDraftRoutePreview?
    private var selectedDraftRouteType: SmartAttachmentRouteType?
    private let smartAttachmentAdapter: SmartAttachmentCaptureAdapter

    init(
        state: AsyncViewState<CapturesViewState> = .loading,
        actionMessage: CaptureActionMessage? = nil,
        smartAttachmentAdapter: SmartAttachmentCaptureAdapter = SmartAttachmentCaptureAdapter()
    ) {
        self.state = state
        self.actionMessage = actionMessage
        self.smartAttachmentAdapter = smartAttachmentAdapter
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
                CapturesViewState(
                    captures: try await captureService.listCaptures(),
                    activeGoalOptions: try await activeGoalOptions(from: goalsService)
                )
            )
            refreshDraftRoutingPreview()
        } catch {
            state = .failed("Unable to load captures: \(error.localizedDescription)")
        }
    }

    func updateDraftText(_ text: String) {
        draftText = text
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            selectedDraftRouteType = nil
            draftRoutePreview = nil
            return
        }
        refreshDraftRoutingPreview()
    }

    func selectDraftRoute(_ routeType: SmartAttachmentRouteType) {
        selectedDraftRouteType = routeType
        refreshDraftRoutingPreview()
    }

    func createQuickCapture(captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else {
            draftError = "Write the thing first. It can be messy."
            return
        }

        do {
            let decision = routingDecision(for: text)
            let capture = try await captureService.createCapture(
                decision.createCaptureRequest(rawText: text, sourceType: .todayQuickCapture),
                now: now
            )
            draftText = ""
            draftError = nil
            selectedDraftRouteType = nil
            draftRoutePreview = nil
            actionMessage = CaptureActionMessage(title: receiptTitle(for: capture, fallback: decision.receiptLine), body: capture.assumptionSummary ?? decision.summary)
            await load(captureService: captureService, goalsService: goalsService)
        } catch {
            draftError = error.localizedDescription
        }
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

    func routeToPlan(id: String, captureService: any CaptureServicing, goalsService: any GoalsServicing, now: Date = .now) async {
        _ = await performAndReload(captureService: captureService, goalsService: goalsService, now: now) {
            _ = try await captureService.routeToPlanSeed(id: id, now: now)
            actionMessage = CaptureActionMessage(title: "Saved as Task · Today", body: "This can become plan work later; no calendar event was created.")
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

    private func refreshDraftRoutingPreview() {
        let text = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.isEmpty == false else {
            draftRoutePreview = nil
            return
        }
        draftRoutePreview = preview(from: routingDecision(for: text))
    }

    private func routingDecision(for text: String) -> SmartAttachmentCaptureDecision {
        smartAttachmentAdapter.decision(
            rawText: text,
            sourceType: .todayQuickCapture,
            sourceSurface: "Capture",
            selectedRouteType: selectedDraftRouteType,
            candidates: smartAttachmentCandidates()
        ) ?? SmartAttachmentCaptureDecision(
            result: DefaultSmartAttachmentService().route(
                SmartAttachmentInput(
                    rawText: text,
                    sourceContext: SmartAttachmentSourceContext(
                        sourceType: .todayQuickCapture,
                        sourceSurface: "Capture"
                    )
                ),
                candidates: [],
                maxCandidateCount: 5
            ),
            selectedRouteType: nil
        )
    }

    private func preview(from decision: SmartAttachmentCaptureDecision) -> CaptureDraftRoutePreview {
        let choices = clarificationChoices(from: decision)
        let placementPreview = decision.placementPreview
        return CaptureDraftRoutePreview(
            originalText: placementPreview.originalText,
            postInputStateTitle: placementPreview.postInputStateTitle,
            receiptTitle: decision.receiptLine,
            summary: decision.summary,
            routeProofTitle: routeProofTitle(from: decision),
            routeProofDetail: routeProofDetail(from: decision),
            destinationLabel: placementPreview.suggestedDestination,
            objectTypeLabel: placementPreview.objectTypeLabel,
            appearanceLabel: placementPreview.appearanceLabel,
            consequenceLabel: placementPreview.consequenceLabel,
            privacyLabel: placementPreview.privacyLabel,
            primaryActionTitle: placementPreview.primaryActionTitle,
            changeActionTitle: placementPreview.changeActionTitle,
            safeActionTitle: placementPreview.safeActionTitle,
            semanticState: decision.result.resultState.rawValue,
            clarificationQuestion: decision.clarification?.question,
            choices: choices,
            accessibilityLabel: decision.accessibilityLabel,
            accessibilityValue: decision.accessibilityValue,
            accessibilityHint: decision.accessibilityHint
        )
    }

    private func routeProofTitle(from decision: SmartAttachmentCaptureDecision) -> String {
        if decision.result.selectedCandidate?.target.isNeedsPlace == true {
            return "Route needs your choice"
        }
        if decision.result.selectedCandidate?.isSuggestedAttachment == true {
            return "Suggested attachment available"
        }
        if decision.selectedRouteType != nil {
            return "Chosen by you"
        }
        return "Route evidence"
    }

    private func routeProofDetail(from decision: SmartAttachmentCaptureDecision) -> String {
        if decision.result.selectedCandidate?.target.isNeedsPlace == true {
            return "No safe destination yet; the capture stays private and editable."
        }
        if let labels = decision.result.selectedCandidate?.evidenceLabels,
           labels.isEmpty == false {
            return labels.prefix(3).joined(separator: ", ")
        }
        if decision.selectedRouteType != nil {
            return "Manual route choice; you can still change it before saving."
        }
        return "Local text only; no calendar, network, account, or cloud route."
    }

    private func clarificationChoices(from decision: SmartAttachmentCaptureDecision) -> [CaptureDraftRouteChoice] {
        let sourceChoices = decision.clarification?.choices.map(\.routeType) ?? fallbackRouteChoices(for: decision)
        return Array(sourceChoices.prefix(3)).map { routeType in
            CaptureDraftRouteChoice(
                id: "draft-route.\(routeType.rawValue)",
                title: routeChoiceTitle(for: routeType),
                routeType: routeType,
                isSelected: routeType == decision.selectedRouteType
            )
        }
    }

    private func fallbackRouteChoices(for decision: SmartAttachmentCaptureDecision) -> [SmartAttachmentRouteType] {
        switch decision.result.resultState {
        case .needsClarification, .savedToNeedsPlace:
            return [.task, .goal, .idea]
        case .attached:
            return [.task, .goal, .idea]
        case .savedStandalone, .failedSafely:
            return [.task, .goal, .idea]
        }
    }

    private func routeChoiceTitle(for routeType: SmartAttachmentRouteType) -> String {
        switch routeType {
        case .task: "Task"
        case .goal: "Goal"
        case .idea: "Needs a Place"
        default: routeType.userFacingLabel
        }
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
