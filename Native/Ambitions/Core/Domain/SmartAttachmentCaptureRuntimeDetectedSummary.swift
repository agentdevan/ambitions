import Foundation

extension SmartAttachmentResult {

    func captureRuntimeDetectedSummary(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse,
        receiptKinds: [CaptureRuntimeReceiptKind]
    ) -> [String] {
        var detected = [String]()
        detected.append("activity=\(semanticExtraction.activity.userFacingLabel)")
        if let object = semanticExtraction.object, object.isEmpty == false {
            detected.append("object=\(object)")
        }
        if let expression = semanticExtraction.dateTimeExpression, expression.isEmpty == false {
            detected.append("time=\(expression)")
        }
        if semanticExtraction.goalDomainHints.isEmpty == false {
            detected.append("goal-hints=\(semanticExtraction.goalDomainHints.map(\.userFacingLabel).joined(separator: ", "))")
        }
        if goalRelevanceScan?.hasAnyRelevantMatch == true {
            detected.append("goal-relevance=match")
        }
        if clarification != nil {
            detected.append("ambiguity=needs-clarification")
        }
        if futureUse.canAffectFutureRouting {
            detected.append("future-use=allowed")
        } else {
            detected.append("future-use=paused")
        }
        if correction != nil {
            detected.append("correction=\(correction?.kind.rawValue ?? "")")
        }
        detected.append("receipt-kind=\(receiptKinds.last?.rawValue ?? receiptRuntimeFallbackKind.rawValue)")
        return Array(Set(detected)).sorted()
    }


    func captureRuntimeWhereItWent(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> String {
        if let correction {
            switch correction.kind {
            case .wrongActivity:
                return "Corrected activity"
            case .wrongTime:
                return "Corrected time"
            case .wrongGoal, .attachToDifferentGoal:
                return "Corrected goal"
            case .doNotUseForPlanning:
                return "Planning paused"
            case .saveOnlyAsNote:
                return "Note only"
            case .deleteContext:
                return "Context deleted"
            }
        }

        if selectedCandidate?.target.routeType == .proofItem {
            return "Proof"
        }
        if selectedCandidate?.target.destinationKind == .existingGoal {
            return "Goal"
        }
        if selectedCandidate?.target.routeType.captureRoute == .timeSeed {
            return "Time"
        }
        if futureUse.canAffectFutureRouting {
            return "Future context"
        }
        return "Needs a Place"
    }


    func captureRuntimeWhatItMayAffect(
        futureUse: CaptureRuntimeFutureUse,
        correction: CaptureRuntimeCorrectionInput?
    ) -> [String] {
        var values = [String]()
        if futureUse.canAffectFutureRouting {
            values.append("future routing")
        }
        if futureUse.preferredGoalID != nil {
            values.append("goal routing")
        }
        if futureUse.preferredTimeLabel != nil {
            values.append("time routing")
        }
        if futureUse.preferredActivityLabel != nil {
            values.append("activity routing")
        }
        if correction?.kind == .doNotUseForPlanning || correction?.kind == .saveOnlyAsNote {
            values.append("planning")
        }
        if correction?.kind == .deleteContext {
            values.append("future use")
        }
        return Array(Set(values)).sorted()
    }


    func captureRuntimeWhatWasNotUsed(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> [String] {
        var values = [String]()
        if clarification != nil {
            values.append("unclear route")
        }
        if goalRelevanceScan?.weakMatches.isEmpty == false {
            values.append("weak goal matches")
        }
        if correction?.kind == .wrongActivity {
            values.append("original activity guess")
        }
        if correction?.kind == .wrongTime {
            values.append("original time guess")
        }
        if correction?.kind == .wrongGoal || correction?.kind == .attachToDifferentGoal {
            values.append("original goal guess")
        }
        if correction?.kind == .doNotUseForPlanning || correction?.kind == .saveOnlyAsNote {
            values.append("planning")
        }
        if correction?.kind == .deleteContext || futureUse.canAffectFutureRouting == false {
            values.append("future runtime use")
        }
        return Array(Set(values)).sorted()
    }


    func captureRuntimePrivacyRedactions(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> [String] {
        var values = [String]()
        if privacyLevel.requiresRedactionByDefault {
            values.append("raw capture text")
        }
        if futureProofContextCandidate?.runtimeUseAllowed == false {
            values.append("sensitive future context")
        }
        if futureProofContextCandidate?.sourceLabel.isEmpty == false {
            values.append("source label")
        }
        if goalRelevanceScan?.forcedAttachmentBlocked == true {
            values.append("goal attachment details")
        }
        if correction?.kind == .attachToDifferentGoal || correction?.kind == .wrongGoal {
            values.append("goal correction note")
        }
        if futureUse.canAffectFutureRouting == false {
            values.append("future routing note")
        }
        return Array(Set(values)).sorted()
    }


    func captureRuntimeApprovalNeeded(
        correction: CaptureRuntimeCorrectionInput?,
        futureUse: CaptureRuntimeFutureUse
    ) -> String? {
        if let scan = goalRelevanceScan, scan.forcedAttachmentBlocked {
            return scan.explanation
        }
        if futureProofContextCandidate?.runtimeUseAllowed == false {
            return "Sensitive context stays review-gated before runtime use."
        }
        if correction?.kind == .attachToDifferentGoal {
            return "Attaching to a different goal must stay user-confirmed."
        }
        if correction?.kind == .doNotUseForPlanning {
            return "Planning use is paused by the user."
        }
        if futureUse.canAffectFutureRouting == false {
            return "Future runtime use is paused."
        }
        return nil
    }


    func undoAvailability(for correction: CaptureRuntimeCorrectionInput?) -> ActionReceiptUndoAvailability {
        guard correction != nil else {
            return .notSupportedYet
        }
        switch correction?.kind {
        case .deleteContext, .doNotUseForPlanning, .saveOnlyAsNote:
            return .availableLocal
        case .wrongActivity, .wrongTime, .wrongGoal, .attachToDifferentGoal:
            return .requiresConfirmation
        case nil:
            return .notSupportedYet
        }
    }


    func receiptKind(
        for correction: CaptureRuntimeCorrectionInput?,
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


    func captureRuntimeDecisionSummary(
        correction: CaptureRuntimeCorrectionInput?
    ) -> String {
        if let correction {
            switch correction.kind {
            case .wrongActivity:
                return "Corrected activity"
            case .wrongTime:
                return "Corrected time"
            case .wrongGoal, .attachToDifferentGoal:
                return "Corrected goal"
            case .doNotUseForPlanning:
                return "Do not use for planning"
            case .saveOnlyAsNote:
                return "Save only as note"
            case .deleteContext:
                return "Delete context"
            }
        }

        if let selectedCandidate {
            return captureRuntimeReceiptLine(for: selectedCandidate.target, state: resultState)
        }
        return receiptLine
    }


    var receiptRuntimeFallbackKind: CaptureRuntimeReceiptKind {
        .captureReplayGenerated
    }


    func captureRuntimeReceiptLine(for target: SmartAttachmentRouteTarget, state: SmartAttachmentResultState) -> String {
        if state == .attached, target.routeType == .proofItem {
            return "Attached as Proof · \(target.destinationLabel ?? "Goal")"
        }
        if target.isNeedsPlace {
            return "Saved to Needs a Place"
        }
        if target.routeType == .proofItem {
            return "Saved as Proof · \(target.destinationLabel ?? "Goal")"
        }
        return "Saved as \(target.displaySegments.joined(separator: " · "))"
    }
}
