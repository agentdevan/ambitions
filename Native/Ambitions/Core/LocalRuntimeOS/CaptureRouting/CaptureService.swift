import Foundation

struct CreateCaptureRequest: Sendable, Equatable {
    let requestedID: String?
    let rawText: String
    let sourceType: CaptureSourceType?
    let linkedGoalID: String?
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?
    let kind: CaptureKind?
    let route: CaptureRoute?
    let triageStatus: CaptureTriageStatus?
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let recommendationExplanationIDs: [String]

    init(
        rawText: String,
        requestedID: String? = nil,
        sourceType: CaptureSourceType? = nil,
        linkedGoalID: String? = nil,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil,
        kind: CaptureKind? = nil,
        route: CaptureRoute? = nil,
        triageStatus: CaptureTriageStatus? = nil,
        commitmentKind: NowCommitmentKind? = nil,
        deadlineText: String? = nil,
        deadlineKind: CaptureDeadlineKind = .none,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints = CapturePriorityHints(),
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        recommendationExplanationIDs: [String] = []
    ) {
        self.rawText = rawText
        self.requestedID = requestedID
        self.sourceType = sourceType
        self.linkedGoalID = linkedGoalID
        self.triage = triage
        self.revisitAfter = revisitAfter
        self.kind = kind
        self.route = route
        self.triageStatus = triageStatus
        self.commitmentKind = commitmentKind
        self.deadlineText = deadlineText
        self.deadlineKind = deadlineKind
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.recommendationExplanationIDs = recommendationExplanationIDs
    }
}

struct CaptureStateUpdateRequest: Sendable, Equatable {
    let id: String
    let status: CaptureStatus
    let triage: CaptureTriageMetadata?
    let revisitAfter: String?
    let kind: CaptureKind?
    let route: CaptureRoute?
    let triageStatus: CaptureTriageStatus?
    let commitmentKind: NowCommitmentKind?
    let deadlineText: String?
    let deadlineKind: CaptureDeadlineKind?
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints?
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let correctionActions: [CaptureCorrectionAction]?
    let recommendationExplanationIDs: [String]?

    init(
        id: String,
        status: CaptureStatus,
        triage: CaptureTriageMetadata? = nil,
        revisitAfter: String? = nil,
        kind: CaptureKind? = nil,
        route: CaptureRoute? = nil,
        triageStatus: CaptureTriageStatus? = nil,
        commitmentKind: NowCommitmentKind? = nil,
        deadlineText: String? = nil,
        deadlineKind: CaptureDeadlineKind? = nil,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints? = nil,
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        correctionActions: [CaptureCorrectionAction]? = nil,
        recommendationExplanationIDs: [String]? = nil
    ) {
        self.id = id
        self.status = status
        self.triage = triage
        self.revisitAfter = revisitAfter
        self.kind = kind
        self.route = route
        self.triageStatus = triageStatus
        self.commitmentKind = commitmentKind
        self.deadlineText = deadlineText
        self.deadlineKind = deadlineKind
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.correctionActions = correctionActions
        self.recommendationExplanationIDs = recommendationExplanationIDs
    }
}

struct CaptureRouteUpdateRequest: Sendable, Equatable {
    let id: String
    let kind: CaptureKind
    let route: CaptureRoute
    let deadlineText: String?
    let contextLensHint: NowContextLens?
    let priorityHints: CapturePriorityHints?
    let goalRelationship: CaptureGoalRelationship?
    let deliverableHint: String?
    let scopeItemHint: String?
    let waitingMetadata: CaptureWaitingMetadata?
    let assumptionSummary: String?
    let userCorrection: Bool

    init(
        id: String,
        kind: CaptureKind,
        route: CaptureRoute,
        deadlineText: String? = nil,
        contextLensHint: NowContextLens? = nil,
        priorityHints: CapturePriorityHints? = nil,
        goalRelationship: CaptureGoalRelationship? = nil,
        deliverableHint: String? = nil,
        scopeItemHint: String? = nil,
        waitingMetadata: CaptureWaitingMetadata? = nil,
        assumptionSummary: String? = nil,
        userCorrection: Bool = true
    ) {
        self.id = id
        self.kind = kind
        self.route = route
        self.deadlineText = deadlineText
        self.contextLensHint = contextLensHint
        self.priorityHints = priorityHints
        self.goalRelationship = goalRelationship
        self.deliverableHint = deliverableHint
        self.scopeItemHint = scopeItemHint
        self.waitingMetadata = waitingMetadata
        self.assumptionSummary = assumptionSummary
        self.userCorrection = userCorrection
    }
}

struct AttachCaptureToGoalRequest: Sendable, Equatable {
    let captureID: String
    let goalID: String

    init(captureID: String, goalID: String) {
        self.captureID = captureID
        self.goalID = goalID
    }
}

struct TurnCaptureIntoGoalRequest: Sendable, Equatable {
    let captureID: String
    let mode: GoalMode?

    init(captureID: String, mode: GoalMode? = nil) {
        self.captureID = captureID
        self.mode = mode
    }
}

struct CaptureGoalBinding: Sendable, Equatable {
    let capture: Capture
    let target: GoalRouteTarget
    let unitOfWorkReceipt: AppUnitOfWorkReceipt?

    init(
        capture: Capture,
        target: GoalRouteTarget,
        unitOfWorkReceipt: AppUnitOfWorkReceipt? = nil
    ) {
        self.capture = capture
        self.target = target
        self.unitOfWorkReceipt = unitOfWorkReceipt
    }
}

struct CaptureDraftRouteChoice: Identifiable, Sendable, Equatable {
    let id: String
    let title: String
    let routeType: SmartAttachmentRouteType
    let isSelected: Bool
}

struct CaptureDraftRoutePreview: Sendable, Equatable {
    let originalText: String
    let placementShelfTitle: String
    let postInputStateTitle: String
    let receiptTitle: String
    let summary: String
    let understoodLabel: String
    let suggestedPlacementLabel: String
    let mayAffectLabel: String
    let approvalNeededLabel: String
    let changeableLabels: [String]
    let safeFallbackLabel: String
    let routeProofTitle: String
    let routeProofDetail: String
    let destinationLabel: String
    let objectTypeLabel: String
    let appearanceLabel: String
    let consequenceLabel: String
    let privacyLabel: String
    let localSourceLabel: String
    let correctionLabel: String
    let receiptSeamLabel: String
    let resolverFoldTitle: String
    let resolverWhyLabel: String
    let correctionReceiptLabel: String
    let correctionControlLabels: [String]
    let primaryActionTitle: String
    let changeActionTitle: String
    let safeActionTitle: String
    let stagedInputs: [CaptureStagedInputProjection]
    let semanticState: String
    let clarificationQuestion: String?
    let choices: [CaptureDraftRouteChoice]
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String?
    let planInsertionCandidate: PlanInsertionCandidate?

    var visibleCopy: String {
        var parts = [
            originalText,
            placementShelfTitle,
            postInputStateTitle,
            receiptTitle,
            summary,
            understoodLabel,
            suggestedPlacementLabel,
            mayAffectLabel,
            approvalNeededLabel,
            routeProofTitle,
            routeProofDetail,
            destinationLabel,
            objectTypeLabel,
            appearanceLabel,
            consequenceLabel,
            privacyLabel,
            localSourceLabel,
            correctionLabel,
            receiptSeamLabel,
            resolverFoldTitle,
            resolverWhyLabel,
            correctionReceiptLabel,
            primaryActionTitle,
            changeActionTitle,
            safeActionTitle,
            safeFallbackLabel,
            clarificationQuestion
        ].compactMap { $0 } + changeableLabels + correctionControlLabels + choices.map(\.title)
        parts.append(contentsOf: stagedInputs.map(\.visibleCopy))
        if let planInsertionCandidate {
            parts.append(contentsOf: [
                planInsertionCandidate.receiptProjection.title,
                planInsertionCandidate.receiptProjection.summary,
                planInsertionCandidate.statusLabel
            ])
            parts.append(contentsOf: planInsertionCandidate.approvalOptionTitles)
        }
        return parts.joined(separator: " ")
    }

    var atmosphereComposerInspectionSummary: String {
        [
            "Started: \(localSourceLabel)",
            "History: \(receiptSeamLabel)",
            "Reason: \(resolverWhyLabel)",
            "Draft: \(stagedInputs.map(\.kind.title).joined(separator: " / "))",
            "Placement stays inspectable and correctable before saving."
        ].joined(separator: " · ")
    }

    var atmosphereComposerCompactInspectionSummary: String {
        "Placement, draft state, and reason stay visible before saving."
    }
}
