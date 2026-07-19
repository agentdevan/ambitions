import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func makeAtlasPreview(
        snapshot: Snapshot,
        cards: [GoalsAtlasSurfaceState],
        northStars: [NorthStar],
        oneStepGoals: [OneStepGoal]
    ) -> GoalAtlasPreviewState? {
        guard snapshot.goals.isEmpty == false else { return nil }
        let cardsByGoalID = Dictionary(uniqueKeysWithValues: cards.compactMap { card in
            card.target.goalID.map { ($0, card) }
        })
        let overview = LifeAreaAtlasProjector().overview(
            from: .init(
                goals: snapshot.goals,
                northStars: northStars,
                oneStepGoals: oneStepGoals
            )
        )
        let groups = overview.areas
            .filter { $0.counts.hasContent }
            .map { area -> GoalAtlasPreviewGroup in
                let orderedItems = (area.activeGoals + area.parkedGoals)
                    .sorted { lhs, rhs in
                        (cardsByGoalID[lhs.id]?.manualPriorityRank ?? Int.max) < (cardsByGoalID[rhs.id]?.manualPriorityRank ?? Int.max)
                    }
                    .prefix(3)
                    .map { goal in
                        let card = cardsByGoalID[goal.id]
                        return GoalAtlasPreviewItem(
                            id: goal.id,
                            title: goal.title,
                            subtitle: card?.nextVisibleStep.title ?? card?.phaseSummary ?? "Relationship data is still thin.",
                            state: card?.lifecycleState.visualState ?? .default
                        )
                    }
                return GoalAtlasPreviewGroup(
                    id: area.id.rawValue,
                    title: area.definition.displayName,
                    subtitle: "\(area.counts.activeGoalCount + area.counts.parkedGoalCount) goal\(area.counts.activeGoalCount + area.counts.parkedGoalCount == 1 ? "" : "s") connected here",
                    items: Array(orderedItems)
                )
            }
            .prefix(3)

        guard groups.isEmpty == false else { return nil }
        return GoalAtlasPreviewState(
            title: "Life areas",
            subtitle: "Life areas remain equal-weight; Thread Focus can inspect one goal thread without moving detail tools into the top level.",
            groups: Array(groups)
        )
    }


    func visualState(for posture: LifeAreaPosture) -> AmbitionVisualState {
        switch posture {
        case .active:
            return .selected
        case .needsAttention:
            return .warning
        case .light, .empty, .unavailable:
            return .default
        }
    }


    func visualState(for posture: NorthStarPosture) -> AmbitionVisualState {
        switch posture {
        case .activeDirection, .readyToShape:
            return .selected
        case .needsReview:
            return .warning
        case .dormant, .parked, .archived:
            return .default
        }
    }


    func visualState(for status: OneStepGoalStatus) -> AmbitionVisualState {
        switch status {
        case .ready, .today:
            return .selected
        case .waiting, .reviewLater:
            return .warning
        case .completed:
            return .success
        case .scheduled, .parked, .archived:
            return .default
        }
    }


    func visualState(for lifecycleState: GoalLifecycleState) -> AmbitionVisualState {
        switch lifecycleState {
        case .active:
            return .selected
        case .completed:
            return .success
        case .paused, .draft, .archived:
            return .default
        }
    }


    func activeStageTitle(for pathSummary: LifePathStateSummary?) -> String? {
        guard let pathSummary else { return nil }
        guard let activeStageID = pathSummary.activeStageID else {
            return pathSummary.orderedStages.first?.title
        }
        return pathSummary.orderedStages.first(where: { $0.id == activeStageID })?.title
    }


    func nextMilestoneTitle(for pathSummary: LifePathStateSummary?) -> String? {
        guard let pathSummary else { return nil }

        for stage in pathSummary.orderedStages {
            let milestones = pathSummary.stageMilestones[stage.id] ?? []
            if let next = milestones.first(where: { pathSummary.progression.completedMilestoneIDs.contains($0.id) == false }) {
                return next.title
            }
        }

        return nil
    }


    func buildDetailPresentation(
        from context: DetailContext,
        appState: AppStateSnapshot,
        priorityOrder: [String],
        applicableSignals: GoalTeachingApplicableSet?,
        runtimeIntelligenceContext: RuntimeGoalIntelligenceContext?
    ) -> GoalDetailPresentation {
        let sourceGoal = context.goal
        let sourceDraft = context.draft?.draft
        let effectiveMode = sourceGoal?.mode ?? sourceDraft?.mode ?? .project
        let renderState = renderState(goal: sourceGoal, draft: context.draft)
        let timing = sourceGoal?.timing ?? sourceDraft?.timing ?? GoalTiming(tempo: .untimed, timingType: .logWhenDone, startsOn: nil, dueAt: nil, targetBy: nil, windowStart: nil, windowEnd: nil, suggestedNextAt: nil, repeatEveryDays: nil, progressReviewCadenceDays: nil)
        let sections = (sourceGoal?.plan ?? context.draft?.stagedPlan)?.sections ?? []
        let allSteps = sections.flatMap(\.steps)
        let completedCount = allSteps.filter { $0.state == .completed }.count
        let progressValue = allSteps.isEmpty ? (renderState == .starter ? 0.16 : 0.04) : Double(completedCount) / Double(max(allSteps.count, 1))
        let minutes = context.evidence.compactMap(\.minutesInvested).reduce(0, +)
        let evidenceLabel = context.evidence.isEmpty ? "No evidence logged yet" : "\(minutes) minutes of visible evidence"
        let suggestions = Array(allSteps.filter { $0.state != .completed && $0.state != .cancelled }.prefix(3)).map { makeStepItem(step: $0, goalMode: effectiveMode) }
        let pathSummary = sourceGoal.map(LifeGraphResolver.pathStateSummary(for:)) ?? sourceDraft.map { LifeGraphResolver.pathStateSummary(for: $0, plan: context.draft?.stagedPlan) } ?? nil
        let learningSnapshot = sourceGoal.map {
            learningService.buildSnapshot(
                goals: [$0],
                evidence: context.evidence,
                feedback: context.feedback,
                now: .now
            )
        } ?? .empty
        let whyNow = sourceGoal.flatMap { goal in
            context.primaryStep.map { step in
                learningService.learnedStepInsight(
                    goal: goal,
                    step: step,
                    snapshot: learningSnapshot,
                    now: .now
                ).whyNow
            }
        }
        let explainability = runtimeIntelligenceContext?.explainability ?? context.draft?.metadata.map { metadata in
            explainabilityProjector.makeState(
                metadata: metadata,
                applicableSignals: applicableSignals,
                primaryStepID: context.primaryStep?.id,
                whyNow: whyNow
            )
        }
        let pathStages = makePathStages(
            pathSummary: pathSummary,
            sections: sections,
            renderState: renderState,
            includeSyntheticFallback: true
        )
        let sectionStates = sections.sorted { $0.orderIndex < $1.orderIndex }.map { section in
            GoalDetailSectionState(
                id: section.id,
                title: section.title,
                summary: section.summary ?? section.kind.rawValue.replacingOccurrences(of: "_", with: " "),
                kindLabel: section.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                steps: section.steps.map { makeStepItem(step: $0, goalMode: effectiveMode) }
            )
        }
        let progressLabel = allSteps.isEmpty ? "Structure forming" : "\(completedCount) of \(allSteps.count) steps landed"
        let sharedProgressNote = renderState == .clarification
            ? "Clarification comes before decomposition. Ambitions is surfacing the missing information instead of inventing urgency."
            : renderState == .blocked
                ? "The blocker is kept visible so the path can restart cleanly once the missing input arrives."
                : effectiveMode == .delegatedSupport
                    ? "Support goals stay non-punitive. Progress reflects what you can support, not what you can force."
                    : whyNow?.conciseReason ?? "The next step stays small enough to act on without losing the broader path."
        let strategicStatus = strategicStatus(
            renderState: renderState,
            pathSummary: pathSummary,
            progressValue: progressValue,
            progressLabel: progressLabel,
            manualPriorityLabel: manualPriorityLabel(for: context, appState: appState, priorityOrder: priorityOrder),
            supportModeActive: context.supportModeActive,
            whyNow: whyNow?.conciseReason
        )
        let nextMovement = nextMovementState(
            primaryStep: context.primaryStep,
            suggestions: suggestions,
            whyNow: whyNow?.conciseReason,
            goalMode: effectiveMode,
            renderState: renderState
        )
        let trajectory = trajectoryState(
            pathSummary: pathSummary,
            pathStages: pathStages,
            sections: sectionStates,
            evidenceLabel: evidenceLabel,
            timingNote: timingNote(for: timing, goalMode: effectiveMode),
            progressNote: sharedProgressNote
        )
        let recentMovement = recentMovementState(
            evidence: Array(context.evidence.prefix(3)),
            feedback: Array(context.feedback.prefix(3)),
            evidenceLabel: evidenceLabel
        )
        let missionControl = missionControlState(
            context: context,
            title: sourceGoal?.title ?? sourceDraft?.title ?? "Goal",
            renderState: renderState,
            timing: timing,
            pathSummary: pathSummary,
            pathStages: pathStages,
            sections: sectionStates,
            suggestions: suggestions,
            evidenceItems: Array(context.evidence.prefix(6)).map(makeEvidenceItem),
            proofBeads: Array(context.evidence.prefix(6)).map { makeProofSpineBead($0, now: .now) },
            feedbackItems: Array(context.feedback.prefix(6)).map(makeFeedbackItem),
            nextMovement: nextMovement,
            trajectory: trajectory,
            progressLabel: progressLabel,
            evidenceLabel: evidenceLabel,
            currentTruth: strategicStatus.summary
        )
        let pathIntelligence = context.draft?.metadata.map {
            DefaultPathIntelligenceProjector().project(
                compiledPath: $0.compiledPath,
                resourceGraph: $0.resourceGraph
            )
        }
        let pathBuilder = pathBuilderState(
            pathIntelligence: pathIntelligence,
            pathStages: pathStages,
            sections: sectionStates,
            missionControl: missionControl,
            nextMovement: nextMovement,
            renderState: renderState
        )

        return GoalDetailPresentation(
            target: context.target,
            headline: GoalDetailHeadline(
                eyebrow: effectiveMode == .delegatedSupport ? "Support Goal" : "Goal Detail",
                title: sourceGoal?.title ?? sourceDraft?.title ?? "Goal",
                subtitle: sourceGoal?.summary ?? sourceDraft?.summary ?? detailSubtitle(for: effectiveMode),
                renderState: renderState,
                modeLabel: effectiveMode.displayTitle,
                timingLabel: timingLabel(for: timing, goalMode: effectiveMode),
                supportLabel: context.supportModeActive ? "This path is framed around supporting \(context.actorName)." : nil
            ),
            outcome: sourceDraft?.summary ?? sourceGoal?.summary ?? detailSubtitle(for: effectiveMode),
            intent: intentText(mode: effectiveMode, actorName: context.actorName, renderState: renderState),
            progress: GoalDetailProgress(
                label: progressLabel,
                detail: renderState == .starter
                    ? "Starter-plan assumptions are being treated as provisional scaffolding."
                    : "Progress is reading the real persisted plan and evidence history.",
                value: progressValue,
                evidenceLabel: evidenceLabel
            ),
            strategicStatus: strategicStatus,
            nextMovement: nextMovement,
            trajectory: trajectory,
            timingNote: timingNote(for: timing, goalMode: effectiveMode),
            progressNote: sharedProgressNote,
            manualPriorityLabel: manualPriorityLabel(for: context, appState: appState, priorityOrder: priorityOrder),
            assumptions: context.draft?.assumptions.map(\.summary) ?? [],
            suggestions: suggestions,
            pathStages: pathStages,
            sections: sectionStates,
            clarification: clarificationState(from: context.draft),
            blocked: blockedState(from: context.draft),
            evidence: Array(context.evidence.prefix(6)).map(makeEvidenceItem),
            history: Array(context.feedback.prefix(6)).map(makeFeedbackItem),
            recentMovement: recentMovement,
            actions: detailActions(
                for: renderState,
                primaryStepAvailable: context.primaryStep != nil,
                canSwitchToUntimed: canSwitchToUntimed(mode: effectiveMode, timing: timing),
                supportModeActive: context.supportModeActive
            ),
            explainability: explainability,
            primaryStepID: context.primaryStep?.id,
            canSwitchToUntimed: canSwitchToUntimed(mode: effectiveMode, timing: timing),
            supportModeActive: context.supportModeActive,
            defaultLens: context.target.launchContext == .help || renderState == .clarification || renderState == .blocked ? .path : .tasks,
            missionControl: missionControl,
            pathBuilder: pathBuilder
        )
    }
}
