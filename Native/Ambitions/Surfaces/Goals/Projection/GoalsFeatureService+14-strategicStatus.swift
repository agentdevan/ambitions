import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func strategicStatus(
        renderState: GoalRenderState,
        pathSummary: LifePathStateSummary?,
        progressValue: Double,
        progressLabel: String,
        manualPriorityLabel: String,
        supportModeActive: Bool,
        whyNow: String?
    ) -> GoalDetailStrategicStatus {
        let title: String = {
            switch renderState {
            case .active:
                return supportModeActive ? "Support path is in motion" : "Path is in motion"
            case .starter:
                return "Starter path is taking shape"
            case .clarification:
                return "Clarification is the real work right now"
            case .blocked:
                return "The path is waiting on a real blocker"
            case .onHold:
                return "This goal is intentionally quieter"
            case .achieved:
                return "This goal is complete"
            }
        }()

        let summary: String = {
            if let pathSummary {
                if renderState == .blocked || (!pathSummary.blockedPrerequisites.isEmpty || pathSummary.readiness.gapCount > 0) {
                    return "The current stage is visible, but Ambitions is keeping the blocker explicit instead of faking momentum."
                }
                if let activeStage = pathSummary.orderedStages.first(where: { $0.id == pathSummary.activeStageID }) {
                    return "You are in \(activeStage.title), with \(progressLabel.lowercased()) and the next step already surfaced."
                }
            }

            switch renderState {
            case .clarification:
                return "The screen is leading with missing truth so the path can become believable before more decomposition."
            case .blocked:
                return "The constraint is staying visible until the path can restart cleanly."
            case .starter:
                return "The structure is intentionally provisional so early signal can reshape the plan."
            case .achieved:
                return "The path is closed and no longer asking for more movement."
            case .onHold:
                return "This goal is paused without losing the strategic framing."
            case .active:
                return "The path is active and oriented around the smallest step that still changes the goal."
            }
        }()

        return GoalDetailStrategicStatus(
            title: title,
            summary: summary,
            supportingDetail: whyNow ?? "\(manualPriorityLabel) • \(Int(progressValue * 100))% visible progress"
        )
    }


    func nextMovementState(
        primaryStep: Step?,
        suggestions: [GoalDetailStepItem],
        whyNow: String?,
        goalMode: GoalMode,
        renderState: GoalRenderState
    ) -> GoalDetailNextMovement? {
        if let primaryStep {
            return GoalDetailNextMovement(
                title: primaryStep.title,
                summary: primaryStep.summary ?? primaryStep.actionability.fallbackMicroStep,
                timingLabel: timingLabel(for: primaryStep.timing, goalMode: goalMode),
                rationale: whyNow ?? "This is the smallest step that keeps the broader path honest.",
                state: stepVisualState(primaryStep.state)
            )
        }

        if let suggestion = suggestions.first {
            return GoalDetailNextMovement(
                title: suggestion.title,
                summary: suggestion.summary,
                timingLabel: suggestion.timingLabel,
                rationale: whyNow ?? "This is the calmest next step still available from the current plan.",
                state: suggestion.state
            )
        }

        switch renderState {
        case .clarification:
            return GoalDetailNextMovement(
                title: "Answer the missing question",
                summary: "Goal Detail is waiting on one real clarification before it treats the path as trustworthy.",
                timingLabel: "Before new planning",
                rationale: "Clarifying the truth matters more than generating more tactics here.",
                state: .warning
            )
        case .blocked:
            return GoalDetailNextMovement(
                title: "Resolve the blocker",
                summary: "Unblock the constraint before asking the screen for more decomposition.",
                timingLabel: "As soon as reality changes",
                rationale: "Ambitions is refusing to turn uncertainty into performative activity.",
                state: .warning
            )
        case .achieved:
            return nil
        case .starter, .active, .onHold:
            return nil
        }
    }


    func trajectoryState(
        pathSummary: LifePathStateSummary?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        evidenceLabel: String,
        timingNote: String,
        progressNote: String
    ) -> GoalDetailTrajectoryState {
        let activeStage = pathStages.first(where: { $0.position == .current || $0.position == .blocked })
        let phaseTitle = activeStage?.title ?? sections.first?.title ?? "Path overview"
        let phaseSummary = activeStage?.summary ?? sections.first?.summary ?? "The current path is still forming."
        let milestoneSummary = activeStage?.highlight ?? pathStages.first(where: { $0.position == .upcoming })?.highlight ?? "No milestone highlight yet"
        let momentumSummary: String = {
            if let pathSummary {
                let completed = pathSummary.progression.completedMilestoneIDs.count
                let total = pathSummary.progression.totalMilestoneCount
                if total > 0 {
                    return "\(completed) of \(total) milestones are already visible."
                }
            }

            return evidenceLabel
        }()

        return GoalDetailTrajectoryState(
            phaseTitle: phaseTitle,
            phaseSummary: phaseSummary,
            milestoneSummary: milestoneSummary,
            momentumSummary: momentumSummary,
            timelineSummary: "\(timingNote) \(progressNote)"
        )
    }


    func recentMovementState(
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        evidenceLabel: String
    ) -> GoalDetailRecentMovementState {
        let evidenceItems = evidence.prefix(2).map { evidence in
            GoalDetailRecentMovementItem(
                id: "evidence-\(evidence.id)",
                title: evidence.note ?? "Progress signal recorded",
                subtitle: evidence.evidenceKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                timestamp: evidence.capturedAt,
                categoryLabel: "Evidence",
                state: .success
            )
        }
        let feedbackItems = feedback.prefix(2).map { feedback in
            let item = makeFeedbackItem(feedback)
            return GoalDetailRecentMovementItem(
                id: "feedback-\(item.id)",
                title: item.title,
                subtitle: item.subtitle,
                timestamp: item.timestamp,
                categoryLabel: "Adjustment",
                state: item.state
            )
        }
        let items = Array((evidenceItems + feedbackItems).prefix(4))
        let summary = items.isEmpty ? evidenceLabel : "Recent movement is visible without turning the screen into a history audit."

        return GoalDetailRecentMovementState(
            title: "Recent movement",
            summary: summary,
            items: items
        )
    }


    func makePathStages(
        pathSummary: LifePathStateSummary?,
        sections: [PlanSection],
        renderState: GoalRenderState,
        includeSyntheticFallback: Bool = false
    ) -> [GoalPathStage] {
        if let pathSummary, pathSummary.orderedStages.isEmpty == false {
            return pathSummary.orderedStages.map { stage in
                let milestones = pathSummary.stageMilestones[stage.id] ?? []
                let isCompleted = pathSummary.progression.completedStageIDs.contains(stage.id)
                let isActive = pathSummary.activeStageID == stage.id
                let isBlocked = isActive && (!pathSummary.blockedPrerequisites.isEmpty || pathSummary.readiness.gapCount > 0)
                let highlight = milestones.first(where: { pathSummary.progression.completedMilestoneIDs.contains($0.id) == false })?.title
                    ?? (isBlocked ? pathSummary.blockedPrerequisites.first?.title ?? pathSummary.readiness.gapSignals.first?.title : nil)
                let position: GoalPathStagePosition = isCompleted ? .completed : (isBlocked ? .blocked : (isActive ? .current : .upcoming))

                return GoalPathStage(
                    id: stage.id,
                    title: stage.title,
                    summary: stage.summary ?? "Path stage",
                    stepCountLabel: "\(milestones.count) milestone\(milestones.count == 1 ? "" : "s")",
                    position: position,
                    statusLabel: position.title,
                    highlight: highlight,
                    state: isCompleted ? .success : (isBlocked ? .warning : (isActive ? renderState.visualState : .default))
                )
            }
        }

        let sortedSections = sections.sorted { $0.orderIndex < $1.orderIndex }
        if includeSyntheticFallback && sortedSections.isEmpty {
            let position: GoalPathStagePosition
            let title: String
            let summary: String
            let highlight: String?

            switch renderState {
            case .active:
                position = .current
                title = "Current path"
                summary = "Movement is already live; stay with the next visible step instead of rebuilding the whole plan."
                highlight = "Keep the next step visible"
            case .starter:
                position = .current
                title = "Starter path"
                summary = "The path is still taking shape, but there is enough signal to make the first step visible now."
                highlight = "Take the first visible step"
            case .clarification:
                position = .current
                title = "Clarify the path"
                summary = "The path stays provisional until the missing truth is answered clearly."
                highlight = "Answer the missing question"
            case .blocked:
                position = .blocked
                title = "Blocked path"
                summary = "A real blocker is preventing movement, so the next step is to clear the obstruction rather than force progress."
                highlight = "Resolve the blocker"
            case .onHold:
                position = .upcoming
                title = "Held path"
                summary = "The direction is intentionally quiet for now, but the path remains visible for clean re-entry later."
                highlight = "Re-enter when the timing is real"
            case .achieved:
                position = .completed
                title = "Completed path"
                summary = "The path is closed because the outcome has already landed."
                highlight = "Outcome landed"
            }

            return [
                GoalPathStage(
                    id: "synthetic-\(renderState.rawValue)-path-stage",
                    title: title,
                    summary: summary,
                    stepCountLabel: "Path marker",
                    position: position,
                    statusLabel: position.title,
                    highlight: highlight,
                    state: position == .completed ? .success : renderState.visualState
                )
            ]
        }

        return sortedSections.enumerated().map { index, section in
            let isCompleted = section.steps.allSatisfy { $0.state == .completed }
            let hasActiveStep = section.steps.contains { $0.state != .completed && $0.state != .cancelled }
            let position: GoalPathStagePosition = isCompleted ? .completed : (hasActiveStep && index == 0 ? .current : .upcoming)
            return GoalPathStage(
                id: section.id,
                title: section.title,
                summary: section.summary ?? section.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                stepCountLabel: "\(section.steps.count) step\(section.steps.count == 1 ? "" : "s")",
                position: position,
                statusLabel: position.title,
                highlight: section.steps.first(where: { $0.state != .completed && $0.state != .cancelled })?.title,
                state: isCompleted ? .success : (position == .current ? renderState.visualState : .default)
            )
        }
    }


    func rescheduleTrigger(for kind: GoalDetailActionKind) -> RescheduleTrigger? {
        switch kind {
        case .delay:
            return .delay
        case .skip:
            return .skip
        case .askForSmallerStep, .breakThisDownSmaller:
            return .askForSmallerStep
        case .imStuck:
            return .stuck
        case .complete, .createReminder, .createCalendarEvent, .askWhyThisMatters, .markNotRelevant, .showPath, .switchToUntimed, .showSupportMode, .raisePriority, .lowerPriority:
            return nil
        }
    }


    func adjustmentPayload(
        draft: PersistedGoalDraft,
        goal: Goal,
        step: Step,
        history: [GoalFeedbackEvent]
    ) -> GoalAdaptivePlanAdjustmentPayload? {
        guard let currentResult = adaptiveResult(from: draft, goal: goal) else { return nil }

        return adaptationService.recommendPlanAdjustment(
            input: GoalAdaptivePlanInput(
                currentResult: currentResult,
                selectedStep: step,
                feedbackHistory: history
            )
        )
    }
}
