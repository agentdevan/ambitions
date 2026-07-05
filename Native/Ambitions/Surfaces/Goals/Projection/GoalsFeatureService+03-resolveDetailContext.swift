import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func resolveDetailContext(target: GoalRouteTarget, snapshot: Snapshot) throws -> DetailContext {
        let draft = snapshot.drafts.first { draft in
            if let draftID = target.draftID, draft.id == draftID {
                return true
            }
            if let goalID = target.goalID, draft.plannedGoalID == goalID {
                return true
            }
            return false
        }

        let resolvedGoalID = target.goalID ?? draft?.plannedGoalID
        let goal = resolvedGoalID.flatMap { goalID in
            snapshot.goals.first(where: { $0.id == goalID })
        }

        guard goal != nil || draft != nil else {
            throw GoalsFeatureError.notFound
        }

        let evidence = resolvedGoalID.map { goalID in
            snapshot.evidence.filter { $0.goalID == goalID }
        } ?? []

        let feedback: [GoalFeedbackEvent] = goal.map { currentGoal in
            let stepIDs = Set(currentGoal.plan?.sections.flatMap(\.steps).map(\.id) ?? [])
            return snapshot.feedback.filter { stepIDs.contains($0.stepID) }
        } ?? []

        return DetailContext(target: target, goal: goal, draft: draft, evidence: evidence, feedback: feedback)
    }


    func makeGoalListItem(
        goal: Goal,
        draft: PersistedGoalDraft?,
        evidence: [ProgressEvidence],
        feedback: [GoalFeedbackEvent],
        learningSummary: GoalLearningSummary?,
        underrepresentedSignal: UnderrepresentedGoalSignal?,
        manualPosition: Int,
        shellSummary: GoalShellSummaryState?
    ) -> GoalListItem {
        let steps = goal.plan?.sections.flatMap(\.steps) ?? []
        let completed = steps.filter { $0.state == .completed }.count
        let firstActive = steps.first(where: { $0.state != .completed && $0.state != .cancelled })
        let progressValue = steps.isEmpty ? 0.08 : Double(completed) / Double(max(steps.count, 1))
        let renderState = renderState(goal: goal, draft: draft)
        let evidenceCount = evidence.filter { $0.goalID == goal.id }.count
        let frictionCount = feedback.filter { event in
            switch event {
            case .skipped, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
                return true
            default:
                return false
            }
        }.count
        let urgencyScore = urgencyScore(for: goal.timing, mode: goal.mode)
        let momentumScore = min(0.98, max(0.12, progressValue + Double(evidenceCount) * 0.08 - Double(frictionCount) * 0.04))
        let historicalFit = learningSummary?.historicalFit.score ?? 0.5
        let underrepresentedBoost = underrepresentedSignal.map { min(0.12, $0.pressureScore * 0.1) } ?? 0
        let timelineRiskBoost = learningSummary.map { min(0.12, $0.timelineRisk.riskScore * 0.08) } ?? 0
        let relevanceScore = min(
            0.99,
            max(
                0.1,
                urgencyScore * 0.4
                    + momentumScore * 0.28
                    + historicalFit * 0.2
                    + underrepresentedBoost
                    + timelineRiskBoost
                    + (renderState == .clarification || renderState == .blocked ? 0.18 : 0.04)
            )
        )

        return GoalListItem(
            id: goal.id,
            target: GoalRouteTarget(goalID: goal.id, draftID: draft?.id),
            title: goal.title,
            subtitle: goal.summary ?? detailSubtitle(for: goal.mode),
            mode: goal.mode,
            renderState: renderState,
            progressValue: progressValue,
            progressLabel: steps.isEmpty ? "Path forming" : "\(completed)/\(steps.count) steps complete",
            statusLabel: renderState.title,
            timingLabel: timingLabel(for: goal.timing, goalMode: goal.mode),
            nextStepHint: firstActive?.title ?? "Open detail to confirm the next step",
            modeLabel: goal.mode.displayTitle,
            supportLabel: goal.mode == .delegatedSupport ? "Support for \(goal.actor.displayName)" : nil,
            relevanceScore: relevanceScore,
            momentumScore: momentumScore,
            urgencyScore: urgencyScore,
            manualPriorityRank: manualPosition,
            updatedAt: goal.updatedAt,
            shellSummary: shellSummary
        )
    }


    func makeDraftListItem(
        draft: PersistedGoalDraft,
        manualPosition: Int,
        shellSummary: GoalShellSummaryState?
    ) -> GoalListItem {
        let renderState: GoalRenderState
        switch draft.latestResultKind {
        case .clarificationRequired:
            renderState = .clarification
        case .blocked:
            renderState = .blocked
        case .starterPlanned:
            renderState = .starter
        default:
            renderState = .active
        }

        let nextHint: String
        if let question = draft.clarification?.questions.first {
            nextHint = question.prompt
        } else if let blocker = draft.blockers.first {
            nextHint = blocker.reason
        } else if let step = draft.stagedPlan?.sections.flatMap(\.steps).first {
            nextHint = step.title
        } else {
            nextHint = "Open detail to finish shaping the path"
        }

        return GoalListItem(
            id: draft.id,
            target: GoalRouteTarget(draftID: draft.id),
            title: draft.draft.title,
            subtitle: draft.draft.summary ?? detailSubtitle(for: draft.draft.mode),
            mode: draft.draft.mode,
            renderState: renderState,
            progressValue: draft.latestResultKind == .starterPlanned ? 0.22 : 0.05,
            progressLabel: renderState == .starter ? "Starter assumptions in play" : "Needs planning input",
            statusLabel: renderState.title,
            timingLabel: timingLabel(for: draft.draft.timing, goalMode: draft.draft.mode),
            nextStepHint: nextHint,
            modeLabel: draft.draft.mode.displayTitle,
            supportLabel: draft.draft.mode == .delegatedSupport ? "Support for \(draft.draft.actor.displayName)" : nil,
            relevanceScore: renderState == .blocked ? 0.92 : 0.78,
            momentumScore: renderState == .starter ? 0.38 : 0.2,
            urgencyScore: renderState == .blocked ? 0.9 : 0.64,
            manualPriorityRank: manualPosition,
            updatedAt: draft.updatedAt,
            shellSummary: shellSummary
        )
    }


    func overviewShellSummaries(
        snapshot: Snapshot,
        now: Date
    ) async throws -> [String: GoalShellSummaryState] {
        guard let goalIntelligenceService else { return [:] }

        var requestKeys: [String] = []
        var requests: [RuntimeGoalIntelligenceRequest] = []
        requestKeys.reserveCapacity(snapshot.goals.count + snapshot.drafts.count)
        requests.reserveCapacity(snapshot.goals.count + snapshot.drafts.count)

        for goal in snapshot.goals {
            let draft = snapshot.drafts.first(where: { $0.plannedGoalID == goal.id })
            requestKeys.append(goal.id)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(goalID: goal.id, draftID: draft?.id),
                    primaryStepID: shellPrimaryStepID(goal: goal, draft: draft),
                    includeWhyNow: true
                )
            )
        }

        for draft in snapshot.drafts where draft.plannedGoalID == nil {
            requestKeys.append(draft.id)
            requests.append(
                RuntimeGoalIntelligenceRequest(
                    target: GoalRouteTarget(draftID: draft.id),
                    primaryStepID: shellPrimaryStepID(goal: nil, draft: draft),
                    includeWhyNow: true
                )
            )
        }

        let contexts = try await goalIntelligenceService.loadContexts(requests, now: now)
        let projector = GoalShellSummaryProjector()
        return Dictionary(uniqueKeysWithValues: zip(requestKeys, contexts).compactMap { key, context in
            guard let context else { return nil }
            return (key, projector.makeState(from: context))
        })
    }


    func shellPrimaryStepID(goal: Goal?, draft: PersistedGoalDraft?) -> String? {
        let steps = (goal?.plan ?? draft?.stagedPlan)?.sections.flatMap(\.steps) ?? []
        return steps.first(where: { $0.state != .completed && $0.state != .cancelled })?.id ?? steps.first?.id
    }


    func overviewAttentionPills(items: [GoalListItem]) -> [String] {
        let freshnessAttention = items.filter { item in
            item.shellSummary?.indicators.contains(where: { $0.kind == .freshness && $0.state == .warning }) == true
        }.count
        let contradictionAttention = items.filter { item in
            item.shellSummary?.indicators.contains(where: { $0.kind == .contradiction }) == true
        }.count
        let correctionAttention = items.filter { item in
            item.shellSummary?.indicators.contains(where: { $0.kind == .correction }) == true
        }.count

        return [
            freshnessAttention > 0 ? "\(freshnessAttention) freshness attention" : nil,
            contradictionAttention > 0 ? "\(contradictionAttention) contradiction attention" : nil,
            correctionAttention > 0 ? "\(correctionAttention) taught paths" : nil
        ]
        .compactMap { $0 }
    }


    func makeWeekPressureSummary(
        activeCount: Int,
        pressuredCount: Int,
        crowdedCount: Int,
        stalledCount: Int
    ) -> GoalsWeekPressureSummary {
        let title: String
        let subtitle: String
        let pill: GoalsHeroPillState

        switch pressuredCount {
        case 0:
            title = "Direction pressure is calm"
            subtitle = "The atlas can stay oriented around active ambitions instead of rescue work."
            pill = GoalsHeroPillState(title: "Calm week", icon: "leaf", state: .success)
        case 1:
            title = "One goal is carrying the week"
            subtitle = "A single pressure point is shaping the atlas and should stay visible."
            pill = GoalsHeroPillState(title: "Focused pressure", icon: "scope", state: .selected)
        default:
            title = "Pressure is spreading across the atlas"
            subtitle = "Multiple goals are competing for week-level attention."
            pill = GoalsHeroPillState(title: "Compressed week", icon: "exclamationmark.triangle", state: .warning)
        }

        return GoalsWeekPressureSummary(
            title: title,
            subtitle: subtitle,
            leadingMetric: "\(activeCount) active",
            trailingMetric: "\(crowdedCount + stalledCount) stretching thin",
            pill: pill
        )
    }


    func makeHeroState(
        seeded: Bool,
        activeDirectionCards: [GoalsAtlasSurfaceState],
        pressuredCards: [GoalsAtlasSurfaceState],
        items: [GoalListItem],
        weekPressureSummary: GoalsWeekPressureSummary
    ) -> GoalsAtlasHeroState {
        let dominantTruth: String
        if let primary = activeDirectionCards.first {
            dominantTruth = "\(primary.title) is the clearest live ambition right now."
        } else if let pressured = pressuredCards.first {
            dominantTruth = "\(pressured.title) is shaping your direction because pressure is outrunning movement."
        } else {
            dominantTruth = "Your direction is ready for one live ambition."
        }

        let pressureSummary = pressuredCards.first?.pressureSummary ?? weekPressureSummary.subtitle
        let attentionPills = overviewAttentionPills(items: items).map {
            GoalsHeroPillState(title: $0, icon: "sparkle.magnifyingglass", state: .warning)
        }

        return GoalsAtlasHeroState(
            eyebrow: "Your Direction",
            title: "Your Direction",
            subtitle: seeded
                ? "Starter and live goals stay grouped by life area, proof, and Today connection instead of an ordered list."
                : "Live goals, drafts, and evidence stay grouped by life area and direction pressure instead of list sorting.",
            dominantTruth: dominantTruth,
            pressureSummary: pressureSummary,
            contextPills: [
                GoalsHeroPillState(title: weekPressureSummary.leadingMetric, icon: "scope", state: .selected),
                GoalsHeroPillState(title: weekPressureSummary.trailingMetric, icon: "wind", state: pressuredCards.isEmpty ? .default : .warning),
                GoalsHeroPillState(title: seeded ? "Starter data loaded" : "Live native data", icon: "sparkles", state: seeded ? .celebration : .selected)
            ],
            attentionPills: attentionPills
        )
    }
}
