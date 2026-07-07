import Foundation

extension SmartAttachmentResult {
    func captureRuntimeReceipt(
        timestamp: String,
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse,
        receiptKinds: [CaptureRuntimeReceiptKind]
    ) -> CaptureRuntimeReceipt {
        let privacyRedactions = captureRuntimePrivacyRedactions(correction: correction, futureUse: futureUse)
        let capturedText = captureRuntimeCapturedText(redactions: privacyRedactions)
        let detected = captureRuntimeDetectedSummary(
            correction: correction,
            futureUse: futureUse,
            receiptKinds: receiptKinds
        )
        let stagedInputs = CaptureStagedInputProjection.supported(sourceSurface: input.sourceContext?.sourceSurface)
        let whereItWent = captureRuntimeWhereItWent(correction: correction, futureUse: futureUse)
        let whatItMayAffect = captureRuntimeWhatItMayAffect(futureUse: futureUse, correction: correction)
        let whatWasNotUsed = captureRuntimeWhatWasNotUsed(correction: correction, futureUse: futureUse)
        let approvalNeeded = captureRuntimeApprovalNeeded(correction: correction, futureUse: futureUse)

        return CaptureRuntimeReceipt(
            id: "capture-runtime-receipt.\(id).\(timestamp).\(receiptKind(for: correction, futureUse: futureUse).rawValue)",
            kind: receiptKind(for: correction, futureUse: futureUse),
            whatWasCaptured: capturedText,
            whatWasDetected: detected,
            stagedInputs: stagedInputs,
            whereItWent: whereItWent,
            whatItMayAffect: whatItMayAffect,
            whatWasNotUsed: whatWasNotUsed,
            whyApprovalWasNeeded: approvalNeeded,
            timestamp: timestamp,
            privacyRedactions: privacyRedactions,
            undoAvailability: undoAvailability(for: correction)
        )
    }


    func captureRuntimeReceiptKinds(
        futureUse: CaptureRuntimeFutureUse,
        correction: CaptureRuntimeCorrectionInput?
    ) -> [CaptureRuntimeReceiptKind] {
        var kinds = [CaptureRuntimeReceiptKind.captureExtracted]
        if clarification != nil {
            kinds.append(.captureNeedsClarification)
        }
        if goalRelevanceScan?.highConfidenceMatches.isEmpty == false || selectedCandidate?.target.destinationKind == .existingGoal {
            kinds.append(.captureMatchedGoal)
        }
        if let scan = goalRelevanceScan, scan.weakMatches.isEmpty == false, scan.highConfidenceMatches.isEmpty, scan.mediumConfidenceMatches.isEmpty {
            kinds.append(.captureWeakMatchRejected)
        }
        if futureUse.canAffectFutureRouting {
            kinds.append(.captureSavedAsFutureContext)
        }
        if let routeType = selectedCandidate?.target.routeType, routeType.captureRoute == .timeSeed {
            kinds.append(.captureProposedForTime)
        }
        if selectedCandidate?.target.destinationKind == .existingPlan {
            kinds.append(.captureAddedToTime)
        }
        if selectedCandidate?.target.destinationKind == .existingGoal && selectedCandidate?.target.routeType == .proofItem {
            kinds.append(.captureAttachedToGoal)
        }
        if selectedCandidate?.target.routeType == .proofItem {
            kinds.append(.captureSavedAsProof)
        }
        if futureUse.canAffectFutureRouting == false || correction?.kind == .doNotUseForPlanning || correction?.kind == .saveOnlyAsNote || correction?.kind == .deleteContext {
            kinds.append(.captureRuntimeUsePaused)
        }
        if correction != nil {
            kinds.append(.captureCorrectionApplied)
        }
        kinds.append(.captureReplayGenerated)
        return Array(Set(kinds)).sorted { lhs, rhs in
            lhs.recognitionOrder < rhs.recognitionOrder
        }
    }


    func captureRuntimeProposedDestinations(
        correction: CaptureRuntimeCorrectionInput?
    ) -> [CaptureRuntimeProposedDestination] {
        var proposals = [CaptureRuntimeProposedDestination]()
        if let selectedCandidate {
            let selectedTargetID = selectedCandidate.target.destinationID ?? selectedCandidate.target.id
            proposals.append(
                CaptureRuntimeProposedDestination(
                    id: "proposal.\(id).selected.\(selectedTargetID)",
                    title: selectedCandidate.target.destinationLabel ?? selectedCandidate.target.routeType.userFacingLabel,
                    routeType: selectedCandidate.target.routeType.rawValue,
                    destinationKind: selectedCandidate.target.destinationKind.rawValue,
                    score: selectedCandidate.score,
                    evidenceLabels: selectedCandidate.evidenceLabels,
                    needsApproval: goalRelevanceScan?.forcedAttachmentBlocked == true,
                    wasSelected: true,
                    notes: selectedCandidate.target.displaySegments
                )
            )
        }
        if let suggestedCandidate,
           suggestedCandidate.target.destinationID != selectedCandidate?.target.destinationID {
            proposals.append(
                CaptureRuntimeProposedDestination(
                    id: "proposal.\(id).suggested.\(suggestedCandidate.target.destinationID ?? suggestedCandidate.target.id)",
                    title: suggestedCandidate.target.destinationLabel ?? suggestedCandidate.target.routeType.userFacingLabel,
                    routeType: suggestedCandidate.target.routeType.rawValue,
                    destinationKind: suggestedCandidate.target.destinationKind.rawValue,
                    score: suggestedCandidate.score,
                    evidenceLabels: suggestedCandidate.evidenceLabels,
                    needsApproval: goalRelevanceScan?.forcedAttachmentBlocked == true,
                    wasSelected: false,
                    notes: suggestedCandidate.target.displaySegments
                )
            )
        }
        if let correction,
           let goalID = correction.goalID,
           correction.kind == .wrongGoal || correction.kind == .attachToDifferentGoal {
            proposals.append(
                CaptureRuntimeProposedDestination(
                    id: "proposal.\(id).correction.goal.\(goalID)",
                    title: correction.note ?? "Different goal",
                    routeType: SmartAttachmentRouteType.goal.rawValue,
                    destinationKind: SmartAttachmentDestinationKind.existingGoal.rawValue,
                    score: nil,
                    evidenceLabels: [],
                    needsApproval: true,
                    wasSelected: false,
                    notes: ["Future routing corrected to a different goal."]
                )
            )
        }
        return Array(
            Dictionary(grouping: proposals, by: \.id).compactMap { $0.value.first }
        ).sorted { lhs, rhs in
            lhs.id < rhs.id
        }
    }


    func captureRuntimeFutureUse(
        futureProof: FutureProofContextCandidate?,
        runtimeFactoring: CaptureRuntimeFactoringCandidate?,
        hasSelectedCandidate: Bool,
        correction: CaptureRuntimeCorrectionInput?
    ) -> CaptureRuntimeFutureUse {
        var notes = [String]()
        var canAffectFutureRouting = hasSelectedCandidate || futureProof != nil || runtimeFactoring != nil
        var preferredGoalID: String?
        var preferredTimeLabel: String?
        var preferredActivityLabel: String?

        if let futureProof {
            notes.append(contentsOf: futureProof.potentialFutureUses)
            canAffectFutureRouting = canAffectFutureRouting || futureProof.runtimeUseAllowed
        }
        if let runtimeFactoring {
            notes.append(runtimeFactoring.reason)
            canAffectFutureRouting = canAffectFutureRouting || runtimeFactoring.runtimeUseAllowed
        }

        guard let correction else {
            return CaptureRuntimeFutureUse(
                canAffectFutureRouting: canAffectFutureRouting,
                preferredGoalID: preferredGoalID,
                preferredTimeLabel: preferredTimeLabel,
                preferredActivityLabel: preferredActivityLabel,
                routingNotes: notes,
                localOnly: true
            )
        }

        notes.append(correction.kind.userFacingSummary)
        switch correction.kind {
        case .wrongActivity:
            preferredActivityLabel = correction.activityLabel ?? correction.note
            canAffectFutureRouting = true
            notes.append("Future routing should prefer the corrected activity.")
        case .wrongTime:
            preferredTimeLabel = correction.timeLabel ?? correction.note
            canAffectFutureRouting = true
            notes.append("Future routing should prefer the corrected time.")
        case .wrongGoal, .attachToDifferentGoal:
            preferredGoalID = correction.goalID
            canAffectFutureRouting = true
            notes.append("Future routing should prefer the corrected goal.")
        case .doNotUseForPlanning:
            canAffectFutureRouting = false
            notes.append("Do not use this capture for planning.")
        case .saveOnlyAsNote:
            canAffectFutureRouting = false
            notes.append("Save only as note.")
        case .deleteContext:
            canAffectFutureRouting = false
            notes.append("Delete context and stop future use.")
        }

        return CaptureRuntimeFutureUse(
            canAffectFutureRouting: canAffectFutureRouting,
            preferredGoalID: preferredGoalID,
            preferredTimeLabel: preferredTimeLabel,
            preferredActivityLabel: preferredActivityLabel,
            routingNotes: notes,
            localOnly: true
        )
    }


    func captureRuntimeUseStatus(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> CaptureRuntimeUseStatus {
        switch correction?.kind {
        case .deleteContext:
            return .deleted
        case .saveOnlyAsNote:
            return .noteOnly
        case .doNotUseForPlanning:
            return .paused
        case .wrongActivity, .wrongTime, .wrongGoal, .attachToDifferentGoal:
            return .active
        case nil:
            break
        }

        if resultState == .needsClarification {
            return .blocked
        }
        if futureUse.canAffectFutureRouting == false {
            return .paused
        }
        return .active
    }


    func captureRuntimeReceiptKind(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> CaptureRuntimeReceiptKind {
        if correction != nil {
            return .captureCorrectionApplied
        }
        if captureRuntimeUseStatus(correction: correction, futureUse: futureUse) == .paused {
            return .captureRuntimeUsePaused
        }
        if resultState == .needsClarification {
            return .captureNeedsClarification
        }
        if selectedCandidate?.target.routeType == .proofItem {
            return .captureSavedAsProof
        }
        if selectedCandidate?.target.destinationKind == .existingGoal && goalRelevanceScan?.forcedAttachmentBlocked == true {
            return .captureAttachedToGoal
        }
        if selectedCandidate?.target.routeType.captureRoute == .timeSeed {
            return .captureProposedForTime
        }
        if futureUse.canAffectFutureRouting {
            return .captureSavedAsFutureContext
        }
        return .captureReplayGenerated
    }


    func captureRuntimeCapturedText(redactions: [String]) -> String {
        guard redactions.contains("raw capture text") == false else {
            return "[redacted]"
        }
        return input.rawText
    }
}
