import Foundation

struct CaptureDraftRouteService: Sendable {
    let smartAttachmentAdapter: SmartAttachmentCaptureAdapter

    init(smartAttachmentAdapter: SmartAttachmentCaptureAdapter = SmartAttachmentCaptureAdapter()) {
        self.smartAttachmentAdapter = smartAttachmentAdapter
    }

    func draftRouteDecision(
        for rawText: String,
        sourceType: CaptureSourceType,
        sourceSurface: String,
        selectedDraftRouteType: SmartAttachmentRouteType?,
        candidates: [SmartAttachmentDestinationCandidate] = []
    ) -> SmartAttachmentCaptureDecision {
        smartAttachmentAdapter.decision(
            rawText: rawText,
            sourceType: sourceType,
            sourceSurface: sourceSurface,
            selectedRouteType: selectedDraftRouteType,
            candidates: candidates
        ) ?? SmartAttachmentCaptureDecision(
            result: DefaultSmartAttachmentService().route(
                SmartAttachmentInput(
                    rawText: rawText,
                    sourceContext: SmartAttachmentSourceContext(
                        sourceType: sourceType,
                        sourceSurface: sourceSurface
                    )
                ),
                candidates: candidates,
                maxCandidateCount: 5
            ),
            selectedRouteType: nil
        )
    }

    func makeDraftRoutePreview(
        for rawText: String,
        sourceType: CaptureSourceType,
        sourceSurface: String,
        selectedDraftRouteType: SmartAttachmentRouteType?,
        candidates: [SmartAttachmentDestinationCandidate] = [],
        localSourceLabel: String
    ) -> CaptureDraftRoutePreview? {
        let trimmed = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return nil
        }
        let decision = draftRouteDecision(
            for: trimmed,
            sourceType: sourceType,
            sourceSurface: sourceSurface,
            selectedDraftRouteType: selectedDraftRouteType,
            candidates: candidates
        )
        return makeDraftRoutePreview(from: decision, localSourceLabel: localSourceLabel)
    }

    func makeDraftRoutePreview(from decision: SmartAttachmentCaptureDecision, localSourceLabel: String) -> CaptureDraftRoutePreview {
        let choices = clarificationChoices(from: decision)
        let placementPreview = decision.placementPreview
        let accessibilityValue = [
            decision.accessibilityValue,
            placementPreview.understoodLabel,
            placementPreview.suggestedPlacementLabel,
            placementPreview.mayAffectLabel,
            placementPreview.approvalNeededLabel,
            placementPreview.changeableLabels.joined(separator: ". "),
            placementPreview.safeFallbackLabel
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
        return CaptureDraftRoutePreview(
            originalText: placementPreview.originalText,
            placementShelfTitle: "Atmosphere Composer",
            postInputStateTitle: placementPreview.postInputStateTitle,
            receiptTitle: decision.receiptLine,
            summary: decision.summary,
            understoodLabel: placementPreview.understoodLabel,
            suggestedPlacementLabel: placementPreview.suggestedPlacementLabel,
            mayAffectLabel: placementPreview.mayAffectLabel,
            approvalNeededLabel: placementPreview.approvalNeededLabel,
            changeableLabels: placementPreview.changeableLabels,
            safeFallbackLabel: placementPreview.safeFallbackLabel,
            routeProofTitle: routeProofTitle(from: decision),
            routeProofDetail: routeProofDetail(from: decision),
            destinationLabel: placementPreview.suggestedDestination,
            objectTypeLabel: placementPreview.objectTypeLabel,
            appearanceLabel: placementPreview.appearanceLabel,
            consequenceLabel: placementPreview.consequenceLabel,
            privacyLabel: placementPreview.privacyLabel,
            localSourceLabel: localSourceLabel,
            correctionLabel: decision.selectedRouteType == nil ? "Correction: change the route before saving" : "Correction: route chosen by you",
            receiptSeamLabel: "Receipt seam: save creates a local capture receipt",
            resolverFoldTitle: "Resolver Fold",
            resolverWhyLabel: resolverWhyLabel(from: decision),
            correctionReceiptLabel: "Correction receipt: saved route changes are recorded locally and stay reviewable.",
            correctionControlLabels: correctionControlLabels(from: decision),
            primaryActionTitle: placementPreview.primaryActionTitle,
            changeActionTitle: placementPreview.changeActionTitle,
            safeActionTitle: placementPreview.safeActionTitle,
            stagedInputs: CaptureStagedInputProjection.supported(sourceSurface: "Capture"),
            semanticState: decision.result.resultState.rawValue,
            clarificationQuestion: decision.semanticClarificationQuestion ?? decision.clarification?.question,
            choices: choices,
            accessibilityLabel: decision.accessibilityLabel,
            accessibilityValue: accessibilityValue,
            accessibilityHint: decision.accessibilityHint,
            planInsertionCandidate: decision.planInsertionCandidate
        )
    }

    func resolverWhyLabel(from decision: SmartAttachmentCaptureDecision) -> String {
        if decision.selectedRouteType != nil {
            return "Local resolver: use the destination you chose."
        }
        return "Local resolver: \(decision.routeType.userFacingLabel) based on local text only."
    }

    func routeProofTitle(from decision: SmartAttachmentCaptureDecision) -> String {
        if decision.goalRelevanceScan?.forcedAttachmentBlocked == true {
            return "Goal attachment needs approval"
        }
        if decision.result.selectedCandidate?.target.isNeedsPlace == true {
            return "Needs your choice"
        }
        if decision.result.selectedCandidate?.isSuggestedAttachment == true {
            return "Suggested attachment available"
        }
        if decision.selectedRouteType != nil {
            return "Chosen by you"
        }
        return "Route evidence"
    }

    func routeProofDetail(from decision: SmartAttachmentCaptureDecision) -> String {
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

    func clarificationChoices(from decision: SmartAttachmentCaptureDecision) -> [CaptureDraftRouteChoice] {
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

    func fallbackRouteChoices(for decision: SmartAttachmentCaptureDecision) -> [SmartAttachmentRouteType] {
        switch decision.result.resultState {
        case .needsClarification, .savedToNeedsPlace:
            return [.task, .goal, .idea]
        case .attached, .savedStandalone, .failedSafely:
            return [.task, .goal, .idea]
        }
    }

    func correctionControlLabels(from decision: SmartAttachmentCaptureDecision) -> [String] {
        let notGoalLabel = decision.routeType == .goal
            ? "Not a goal: choose Step or Needs a Place."
            : "Not a goal: no Goal is created unless you choose Goal."
        return [
            "Place somewhere else: choose a route below.",
            notGoalLabel,
            "Not now: Decide later keeps it out of Today.",
            "Decide later: save to Needs a Place.",
            "Discard: clear the composer before saving.",
            "Archive: after saving, move it out of active review."
        ]
    }

    func routeChoiceTitle(for routeType: SmartAttachmentRouteType) -> String {
        switch routeType {
        case .task:
            return "Step"
        case .goal:
            return "Goal"
        case .idea:
            return "Needs a Place"
        default:
            return routeType.userFacingLabel
        }
    }
}
