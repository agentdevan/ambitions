import Foundation

struct SmartAttachmentResult: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let input: SmartAttachmentInput
    let semanticExtraction: CaptureSemanticExtraction
    let goalRelevanceScan: GoalRelevanceScan?
    let resultState: SmartAttachmentResultState
    let confidence: SmartAttachmentConfidenceBand
    let selectedCandidate: SmartAttachmentCandidate?
    let suggestedCandidate: SmartAttachmentCandidate?
    let clarification: SmartAttachmentClarification?
    let receiptLine: String
    let explanation: String?
    let actions: [SmartAttachmentActionLabel]
    let privacyLevel: ActionReceiptPrivacyLevel
    let failureReason: String?
    let schemaVersion: String

    init(
        id: String,
        input: SmartAttachmentInput,
        resultState: SmartAttachmentResultState,
        confidence: SmartAttachmentConfidenceBand,
        selectedCandidate: SmartAttachmentCandidate? = nil,
        suggestedCandidate: SmartAttachmentCandidate? = nil,
        clarification: SmartAttachmentClarification? = nil,
        semanticExtraction: CaptureSemanticExtraction? = nil,
        goalRelevanceScan: GoalRelevanceScan? = nil,
        receiptLine: String,
        explanation: String? = nil,
        actions: [SmartAttachmentActionLabel],
        privacyLevel: ActionReceiptPrivacyLevel = .privateItem,
        failureReason: String? = nil,
        schemaVersion: String = smartAttachmentSchemaVersion
    ) {
        self.id = SmartAttachmentRouteTarget.normalizedRequired(id)
        self.input = input
        self.semanticExtraction = semanticExtraction ?? CaptureSemanticExtraction.extract(
            from: input,
            routeType: selectedCandidate?.target.routeType,
            selectedCandidate: selectedCandidate,
            clarification: clarification
        )
        self.goalRelevanceScan = goalRelevanceScan
        self.resultState = resultState
        self.confidence = confidence
        self.selectedCandidate = selectedCandidate
        self.suggestedCandidate = suggestedCandidate
        self.clarification = clarification
        self.receiptLine = SmartAttachmentRouteTarget.normalizedRequired(receiptLine)
        self.explanation = SmartAttachmentRouteTarget.normalizedOptional(explanation)
        self.actions = Self.orderedUnique(actions)
        self.privacyLevel = privacyLevel
        self.failureReason = SmartAttachmentRouteTarget.normalizedOptional(failureReason)
        self.schemaVersion = schemaVersion
    }

    static func orderedUnique(_ actions: [SmartAttachmentActionLabel]) -> [SmartAttachmentActionLabel] {
        var ordered = [SmartAttachmentActionLabel]()
        for action in actions where ordered.contains(action) == false {
            ordered.append(action)
        }
        return ordered
    }

    var captureKind: CaptureKind {
        selectedCandidate?.target.routeType.captureKind ?? .raw
    }

    var captureRoute: CaptureRoute {
        selectedCandidate?.target.routeType.captureRoute ?? .captureInbox
    }

    var triageStatus: CaptureTriageStatus {
        switch confidence {
        case .high, .medium:
            return .assumedRoute
        case .low, .needsClarification, .unavailableFailed:
            return .needsTriage
        }
    }

    var savesToNeedsPlace: Bool {
        resultState == .savedToNeedsPlace || selectedCandidate?.target.isNeedsPlace == true
    }

    var captureAssumptionSummary: String {
        if savesToNeedsPlace {
            return "Saved to Needs a Place because the route was not safe to infer."
        }
        if let explanation {
            return explanation
        }
        return "Smart Attachment chose a conservative local route."
    }

    var semanticClarificationQuestion: String? {
        semanticExtraction.semanticClarificationQuestion
    }

    func receiptProjection(detail: SmartAttachmentPrivacyProjection) -> SmartAttachmentReceiptProjection {
        let shouldRedact = detail == .redacted || privacyLevel.requiresRedactionByDefault
        let redactedTitle = privacyLevel == .unavailable ? "Detail hidden" : "Private item"
        let title = shouldRedact ? redactedTitle : receiptLine
        let summary = shouldRedact ? redactedTitle : (explanation ?? receiptLine)
        let accessibilityValue = shouldRedact ? "Detail hidden" : "\(confidence.userFacingLabel). \(receiptLine)"

        return SmartAttachmentReceiptProjection(
            title: title,
            summary: summary,
            accessibilityLabel: "Smart Attachment result",
            accessibilityValue: accessibilityValue,
            accessibilityHint: actions.isEmpty ? nil : actions.map(\.title).joined(separator: ", "),
            actionTitles: actions.map(\.title),
            privacyLevel: shouldRedact ? .redacted : privacyLevel,
            isRedacted: shouldRedact
        )
    }

    func actionReceipt(captureID: String, occurredAt: String) -> ActionReceipt {
        let captureObject = LifeGraphObjectReference(
            kind: .capture,
            id: captureID,
            label: input.rawText,
            sourceDomain: .capture
        )
        let targetObject = selectedCandidate?.target.objectReference
        let affectedObjects = [captureObject, targetObject].compactMap { $0 }
        let resultState: ActionReceiptResultState
        switch self.resultState {
        case .attached:
            resultState = .attached
        case .savedStandalone, .savedToNeedsPlace:
            resultState = .created
        case .needsClarification:
            resultState = .needsConfirmation
        case .failedSafely:
            resultState = .failedSafely
        }
        let factKind: ActionReceiptChangedFactKind = self.resultState == .attached ? .attachedCaptureToGoal : .createdCapture
        let safeFailure = self.resultState == .failedSafely
            ? ActionReceiptSafeFailure(
                whatFailed: "Smart Attachment",
                whyFailed: failureReason,
                unchangedFacts: ["No calendar, sync, account, cloud, external service, or unsupported app data was changed."],
                nextSafeAction: ActionReceiptNextAction(kind: .dismiss, title: "Keep")
            )
            : nil

        return ActionReceipt(
            id: "receipt.smart-attachment.\(id)",
            resultState: resultState,
            title: receiptLine,
            summary: explanation ?? receiptLine,
            sourceDomain: .capture,
            occurredAt: occurredAt,
            affectedObjects: affectedObjects,
            changedFacts: [
                ActionReceiptChangedFact(
                    id: "fact.smart-attachment.\(id)",
                    kind: factKind,
                    object: captureObject,
                    summary: receiptLine
                )
            ],
            why: ActionReceiptWhyExplanation(body: explanation),
            nextAction: ActionReceiptNextAction(kind: .correctAssumption, title: "Change", destination: .captureInbox, target: captureObject),
            correctionAvailability: .availableWithReason,
            undoAvailability: .notSupportedYet,
            safetyState: self.resultState == .failedSafely ? .safeFailure : .normal,
            safeFailure: safeFailure,
            sourceObject: captureObject
        )
    }
}

extension SmartAttachmentResult {
    var planInsertionCandidate: PlanInsertionCandidate? {
        PlanInsertionCandidate.make(
            from: SmartAttachmentCaptureDecision(result: self, selectedRouteType: selectedCandidate?.target.routeType)
        )
    }

    var reclassificationProjection: SmartAttachmentReclassificationProjection {
        let actionTitles = reclassificationActionTitles
        let undoSummary = "Undo is not applied automatically; use Change before saving or reclassify after placement."
        let correctionAvailability: ActionReceiptCorrectionAvailability = actionTitles.isEmpty ? .unavailable : .availableWithReason
        let rollbackSummary = savesToNeedsPlace
            ? "Rollback keeps the capture in Needs a Place with the original text preserved."
            : "Rollback returns the capture to Needs a Place and preserves the original text and receipt."

        return SmartAttachmentReclassificationProjection(
            receiptTitle: receiptLine,
            undoAvailability: .notSupportedYet,
            undoSummary: undoSummary,
            correctionAvailability: correctionAvailability,
            reclassificationActions: actionTitles,
            rollbackSummary: rollbackSummary,
            accessibilitySummary: "\(receiptLine). Undo not supported yet. \(correctionAvailability.isAvailable ? "Correction available." : "No correction action available.")"
        )
    }

    var reviewBundle: SmartAttachmentReviewBundle {
        let cluster = SmartAttachmentCaptureCluster(
            id: "cluster.\(id)",
            title: clusterTitle,
            summary: clusterSummary,
            evidenceLabels: suggestedCandidate?.evidenceLabels ?? selectedCandidate?.evidenceLabels ?? [],
            itemCount: 1
        )
        let signals = openLoopSignals
        let actionTitles = actions.map(\.title).sorted()

        return SmartAttachmentReviewBundle(
            id: "review-bundle.\(id)",
            title: reviewBundleTitle,
            summary: reviewBundleSummary(openLoopCount: signals.count),
            clusters: [cluster],
            openLoopSignals: signals,
            actionTitles: actionTitles,
            accessibilitySummary: accessibilityReviewSummary(openLoopCount: signals.count, actionTitles: actionTitles)
        )
    }

    var reclassificationActionTitles: [String] {
        guard resultState != .failedSafely else { return [] }
        return actions.filter { action in
            switch action {
            case .change, .task, .goal, .idea, .proof, .waiting, .plan, .attach, .keepStandalone:
                return true
            case .retry, .copy:
                return false
            }
        }
        .map(\.title)
        .sorted()
    }

    var reviewBundleTitle: String {
        if savesToNeedsPlace || resultState == .needsClarification {
            return "Needs a Place review"
        }
        if suggestedCandidate != nil {
            return "Route review"
        }
        return "Placed capture review"
    }

    var clusterTitle: String {
        if savesToNeedsPlace || resultState == .needsClarification {
            return "Unplaced capture"
        }
        if selectedCandidate?.target.routeType == .proofItem {
            return "Proof candidate"
        }
        return selectedCandidate?.target.routeType.userFacingLabel ?? "Capture"
    }

    var clusterSummary: String {
        if savesToNeedsPlace || resultState == .needsClarification {
            return "Held safely until the user chooses where it belongs."
        }
        if let destination = selectedCandidate?.target.displaySegments.joined(separator: " · "), destination.isEmpty == false {
            return "Locally grouped by \(destination)."
        }
        return "Locally grouped by conservative capture route."
    }

    var openLoopSignals: [SmartAttachmentOpenLoopSignal] {
        var signals = [SmartAttachmentOpenLoopSignal]()
        if let scan = goalRelevanceScan, scan.forcedAttachmentBlocked {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).goal-approval",
                    title: "Goal attachment needs approval",
                    reason: scan.explanation,
                    requiresUserChoice: true
                )
            )
        }
        if let scan = goalRelevanceScan,
           scan.hasAnyRelevantMatch == false,
           resultState != .needsClarification,
           let reason = scan.noMatchReason {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).goal-no-match",
                    title: "No goal match found",
                    reason: reason,
                    requiresUserChoice: false
                )
            )
        }
        if savesToNeedsPlace || resultState == .needsClarification {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).route-choice",
                    title: "Route needs a choice",
                    reason: clarification?.question ?? "The route was not safe to infer.",
                    requiresUserChoice: true
                )
            )
        }
        if let suggestedCandidate {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).suggested-attachment",
                    title: "Suggested attachment available",
                    reason: "Local wording also matched \(suggestedCandidate.target.destinationLabel ?? "an existing item").",
                    requiresUserChoice: true
                )
            )
        }
        if resultState == .failedSafely {
            signals.append(
                SmartAttachmentOpenLoopSignal(
                    id: "open-loop.\(id).safe-failure",
                    title: "Capture kept safely",
                    reason: failureReason ?? "No route was applied.",
                    requiresUserChoice: false
                )
            )
        }
        return signals
    }

    func reviewBundleSummary(openLoopCount: Int) -> String {
        if openLoopCount == 0 {
            return "No open review loop is required before saving this local route."
        }
        return "\(openLoopCount) open review loop\(openLoopCount == 1 ? "" : "s") kept explicit before placement."
    }

    func accessibilityReviewSummary(openLoopCount: Int, actionTitles: [String]) -> String {
        let actions = actionTitles.isEmpty ? "No actions" : actionTitles.joined(separator: ", ")
        return "\(reviewBundleTitle). \(openLoopCount) open loop\(openLoopCount == 1 ? "" : "s"). Actions: \(actions)."
    }
}
