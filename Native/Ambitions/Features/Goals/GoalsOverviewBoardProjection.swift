import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {
    func makeAtlasCard(
        from item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsAtlasSurfaceState {
        let posture = classifyPosture(for: item, snapshot: snapshot, learningSummary: learningSummary)
        let pathSummary = pathSummary(for: item, snapshot: snapshot)
        let phaseSummary = activeStageTitle(for: pathSummary)
            ?? item.shellSummary?.pathSummary
            ?? item.progressLabel
        let milestoneSummary = milestoneSummary(for: item, pathSummary: pathSummary)
        let sourceGoal = item.target.goalID.flatMap { goalID in snapshot.goals.first(where: { $0.id == goalID }) }
        let sourceDraft = item.target.draftID.flatMap { draftID in snapshot.drafts.first(where: { $0.id == draftID }) }
        let goalEvidence = item.target.goalID.map { goalID in snapshot.evidence.filter { $0.goalID == goalID } } ?? []
        let lifecycleState = portfolioLifecycleState(
            item: item,
            goal: sourceGoal,
            draft: sourceDraft,
            pathSummary: pathSummary,
            learningSummary: learningSummary,
            evidence: goalEvidence
        )
        let proofSummary = proofSummary(for: item, evidence: goalEvidence)
        let nextVisibleStep = nextVisibleStep(for: item, goal: sourceGoal, draft: sourceDraft)
        let weather = weatherState(
            lifecycleState: lifecycleState,
            posture: posture,
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            pathSummary: pathSummary
        )
        let momentumIntegrity = momentumIntegrity(
            lifecycleState: lifecycleState,
            posture: posture,
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            evidence: goalEvidence
        )

        return GoalsAtlasSurfaceState(
            id: item.id,
            target: item.target,
            title: item.title,
            subtitle: item.subtitle,
            modeLabel: item.modeLabel,
            posture: posture,
            renderState: item.renderState,
            progressValue: item.progressValue,
            progressLabel: item.progressLabel,
            timingLabel: item.timingLabel,
            weekRelationship: weekRelationship(for: item, learningSummary: learningSummary),
            phaseSummary: phaseSummary,
            milestoneSummary: milestoneSummary,
            pressureSummary: pressureSummary(for: item, lifecycleState: lifecycleState, posture: posture, proofSummary: proofSummary, learningSummary: learningSummary),
            nextStepHint: item.nextStepHint,
            lifecycleState: lifecycleState,
            weather: weather,
            weatherSummary: weatherSummary(for: weather, lifecycleState: lifecycleState, posture: posture, proofSummary: proofSummary, nextVisibleStep: nextVisibleStep),
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            momentumIntegrity: momentumIntegrity,
            supportLabel: item.supportLabel,
            priorityLabel: directionLabel(for: item, lifecycleState: lifecycleState, posture: posture),
            manualPriorityRank: item.manualPriorityRank,
            shellSummary: item.shellSummary
        )
    }

    func makeBoardCard(
        from item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsBoardCardState {
        makeAtlasCard(from: item, snapshot: snapshot, learningSummary: learningSummary)
    }

    func classifyPosture(
        for item: GoalListItem,
        snapshot: Snapshot,
        learningSummary: GoalLearningSummary?
    ) -> GoalsAtlasPosture {
        switch item.renderState {
        case .clarification, .blocked:
            return .atRisk
        case .onHold:
            return .lowerPriority
        case .achieved:
            return .achieved
        case .starter, .active:
            break
        }

        let freshnessWarning = item.shellSummary?.indicators.contains(where: { $0.kind == .freshness && $0.state == .warning }) == true
        let contradictionFlag = item.shellSummary?.indicators.contains(where: { $0.kind == .contradiction }) == true
        let pathSummary = pathSummary(for: item, snapshot: snapshot)
        let blockedPath = pathSummary?.blockedPrerequisites.isEmpty == false
            || (pathSummary?.readiness.gapCount ?? 0) > 0
        let timelineRisk = learningSummary?.timelineRisk.riskScore ?? 0
        let driftCount = learningSummary?.driftTriggers.count ?? 0

        if freshnessWarning || contradictionFlag || blockedPath {
            return .atRisk
        }

        if item.manualPriorityRank >= 2 && item.urgencyScore >= 0.48 && item.momentumScore <= 0.56 {
            return .crowded
        }

        if timelineRisk >= 0.85 {
            return .atRisk
        }

        if item.manualPriorityRank == 0 && driftCount == 0 && item.urgencyScore >= 0.55 {
            return .active
        }

        if item.momentumScore < 0.24 {
            return .stalled
        }

        if item.momentumScore < 0.42 && item.manualPriorityRank > 0 {
            return .stalled
        }

        if driftCount > 0 && item.progressValue < 0.35 {
            return .stalled
        }

        return .active
    }

    func pathSummary(for item: GoalListItem, snapshot: Snapshot) -> LifePathStateSummary? {
        pathSummary(for: item.target, snapshot: snapshot)
    }

    func pathSummary(for target: GoalRouteTarget, snapshot: Snapshot) -> LifePathStateSummary? {
        if let goalID = target.goalID,
           let goal = snapshot.goals.first(where: { $0.id == goalID }) {
            return LifeGraphResolver.pathStateSummary(for: goal)
        }

        if let draftID = target.draftID,
           let draft = snapshot.drafts.first(where: { $0.id == draftID }) {
            return LifeGraphResolver.pathStateSummary(for: draft.draft, plan: draft.stagedPlan)
        }

        return nil
    }

    func milestoneSummary(for item: GoalListItem, pathSummary: LifePathStateSummary?) -> String {
        if let pathSummary {
            let completed = pathSummary.progression.completedMilestoneIDs.count
            let total = pathSummary.progression.totalMilestoneCount
            if total > 0 {
                return "\(completed)/\(total) milestones visible"
            }
        }

        return item.progressLabel
    }

    func weekRelationship(for item: GoalListItem, learningSummary: GoalLearningSummary?) -> String {
        if item.renderState == .clarification || item.renderState == .blocked {
            return "This week needs a clarifying step before more planning."
        }

        if let risk = learningSummary?.timelineRisk.riskScore, risk >= 0.7 {
            return "This week is carrying real deadline pressure."
        }

        if item.manualPriorityRank == 0 {
            return "This week this goal is carrying the strongest directional weight."
        }

        if item.momentumScore >= 0.6 {
            return "This week momentum is visible and worth protecting."
        }

        if item.momentumScore < 0.4 {
            return "This week needs a small visible signal to stay alive."
        }

        return "This week can stay steady without opening more planning."
    }

    func pressureSummary(
        for item: GoalListItem,
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsAtlasPosture,
        proofSummary: GoalProofSummary,
        learningSummary: GoalLearningSummary?
    ) -> String {
        switch posture {
        case .atRisk:
            if lifecycleState == .blocked {
                return [learningSummary?.timelineRisk.reasons.first, item.shellSummary?.explanationSummary, "This goal is blocked and needs direct attention before progress can continue."]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            if lifecycleState == .waiting {
                return [learningSummary?.timelineRisk.reasons.first, item.shellSummary?.explanationSummary, "This goal is waiting on a readiness answer before the path is believable again."]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            return learningSummary?.timelineRisk.reasons.first
                ?? item.shellSummary?.explanationSummary
                ?? "Risk is high enough that this goal needs direct attention."
        case .crowded:
            return "This goal is still alive, but nearby priorities are compressing the attention it can hold."
        case .stalled:
            return learningSummary?.driftTriggers.first?.summary
                ?? "Recent movement is thin, so this goal is drifting and needs one visible signal."
        case .active:
            if proofSummary.count == 0 {
                return item.shellSummary?.explanationSummary
                    ?? "The path is live, but proof is still thin enough to deserve attention."
            }
            return item.shellSummary?.explanationSummary
                ?? "The path still has believable momentum."
        case .lowerPriority:
            return lifecycleState == .completed
                ? "This goal is completed and preserved in history."
                : "This goal is intentionally quieter right now."
        case .achieved:
            return "This loop is closed and no longer competing for attention."
        }
    }

    func portfolioLifecycleState(
        item: GoalListItem,
        goal: Goal?,
        draft: PersistedGoalDraft?,
        pathSummary: LifePathStateSummary?,
        learningSummary: GoalLearningSummary?,
        evidence: [ProgressEvidence]
    ) -> GoalPortfolioLifecycleState {
        if item.renderState == .blocked || draft?.latestResultKind == .blocked {
            return .blocked
        }

        if item.renderState == .clarification {
            return .active
        }

        if let goal {
            switch goal.state {
            case .completed:
                return .completed
            case .archived:
                return goal.plan?.sections.flatMap(\.steps).contains(where: { $0.state == .completed }) == true ? .previous : .cancelledDropped
            case .paused:
                return .parked
            case .draft:
                return .future
            case .active:
                break
            }

            if goal.plan?.sections.flatMap(\.steps).contains(where: { $0.state == .blocked }) == true ||
                pathSummary?.blockedPrerequisites.isEmpty == false {
                return .blocked
            }

            if hasFutureStart(goal.timing) {
                return .future
            }
        }

        if pathSummary?.readiness.gapCount ?? 0 > 0 {
            return .waiting
        }

        if learningSummary?.timelineRisk.riskScore ?? 0 >= 0.8,
           item.manualPriorityRank == 0 {
            return .protected
        }

        if item.manualPriorityRank == 0,
           item.urgencyScore >= 0.58,
           item.renderState == .active {
            return .protected
        }

        if item.mode == .maintenance || item.mode == .learning || item.mode == .exploration {
            if item.manualPriorityRank > 1 && evidence.isEmpty {
                return .passive
            }
        }

        if item.renderState == .onHold {
            return .passive
        }

        return item.renderState == .starter ? .passive : .active
    }

    func proofSummary(for item: GoalListItem, evidence: [ProgressEvidence]) -> GoalProofSummary {
        let sortedEvidence = evidence.sorted { lhs, rhs in
            (parseDate(lhs.capturedAt) ?? .distantPast) > (parseDate(rhs.capturedAt) ?? .distantPast)
        }
        let count = sortedEvidence.count
        let latest = sortedEvidence.first
        let title: String
        let detail: String
        let visualState: AmbitionVisualState

        if count == 0 {
            title = "No proof yet"
            detail = "Needs evidence"
            visualState = .default
        } else if let latest {
            title = count == 1 ? "1 proof point" : "\(count) proof points"
            detail = "Last proof: \(proofTitle(for: latest))"
            visualState = .selected
        } else {
            title = "Proof building"
            detail = "Receipts available"
            visualState = .selected
        }

        return GoalProofSummary(
            title: title,
            detail: detail,
            count: count,
            latestTitle: latest.map(proofTitle(for:)),
            visualState: visualState
        )
    }

    func nextVisibleStep(for item: GoalListItem, goal: Goal?, draft: PersistedGoalDraft?) -> GoalNextVisibleStep {
        let step = (goal?.plan ?? draft?.stagedPlan)?.sections
            .flatMap(\.steps)
            .first { $0.state != .completed && $0.state != .cancelled }

        if let step {
            let effort = step.actionability.fallbackMicroStep.isEmpty ? nil : step.actionability.fallbackMicroStep
            let timing = nextStepTimingLabel(for: step.timing)
            let proof = step.evidenceRequired ? "proof useful" : nil
            return GoalNextVisibleStep(
                title: step.title,
                detail: [effort, timing, proof].compactMap { $0 }.joined(separator: " · "),
                isAvailable: true
            )
        }

        let hint = item.nextStepHint.trimmingCharacters(in: .whitespacesAndNewlines)
        if hint.isEmpty == false, hint.lowercased().contains("open detail") == false {
            return GoalNextVisibleStep(title: hint, detail: "Ready to clarify", isAvailable: true)
        }

        return GoalNextVisibleStep(title: "Needs a next step", detail: "Ready to clarify", isAvailable: false)
    }

    func weatherState(
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsAtlasPosture,
        proofSummary: GoalProofSummary,
        nextVisibleStep: GoalNextVisibleStep,
        pathSummary: LifePathStateSummary?
    ) -> GoalWeatherState {
        if lifecycleState == .protected {
            return .protected
        }
        if lifecycleState == .blocked || posture == .atRisk || pathSummary?.blockedPrerequisites.isEmpty == false {
            return .stormy
        }
        if proofSummary.count == 0 {
            return .foggy
        }
        if nextVisibleStep.isAvailable == false || nextVisibleStep.title.lowercased().contains("clarify") {
            return .cloudy
        }
        return .clear
    }

    func weatherSummary(
        for weather: GoalWeatherState,
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsAtlasPosture,
        proofSummary: GoalProofSummary,
        nextVisibleStep: GoalNextVisibleStep
    ) -> String {
        switch weather {
        case .clear:
            return lifecycleState == .protected ? "Proof and the next step are visible, and the goal should stay protected." : "Proof and the next step are visible."
        case .cloudy:
            return lifecycleState == .waiting ? "Progress exists, but readiness still needs an answer." : "Progress exists, but the next step needs more shape."
        case .stormy:
            if lifecycleState == .blocked {
                return "A blocker is visible."
            }
            if lifecycleState == .waiting {
                return "The goal is waiting on a readiness answer."
            }
            return posture == .atRisk ? "Risk is visible." : "Pressure needs attention."
        case .foggy:
            return proofSummary.count == 0 ? "Proof is still missing." : "Clarity is still forming."
        case .protected:
            return "This goal should be defended from distraction."
        }
    }

    func momentumIntegrity(
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsAtlasPosture,
        proofSummary: GoalProofSummary,
        nextVisibleStep: GoalNextVisibleStep,
        evidence: [ProgressEvidence]
    ) -> GoalMomentumIntegrity {
        if lifecycleState == .blocked {
            return GoalMomentumIntegrity(title: "Blocked", detail: "Do not treat activity as progress until the blocker moves.", visualState: .warning)
        }
        if lifecycleState == .waiting {
            return GoalMomentumIntegrity(title: "Waiting", detail: "Momentum depends on an outside answer, date, or condition.", visualState: .warning)
        }
        if lifecycleState == .parked {
            return GoalMomentumIntegrity(title: "Parked", detail: "Intentionally quiet for later.", visualState: .default)
        }
        if lifecycleState == .protected {
            return GoalMomentumIntegrity(title: "Kept in view", detail: "Keep the next step visible.", visualState: .selected)
        }
        if proofSummary.count > 0 && nextVisibleStep.isAvailable {
            return GoalMomentumIntegrity(title: "Building proof", detail: "Evidence and a next step both exist.", visualState: .selected)
        }
        if proofSummary.count == 0 && nextVisibleStep.isAvailable {
            return GoalMomentumIntegrity(title: "Needs proof", detail: "The next step is clear; evidence has not landed yet.", visualState: .default)
        }
        if posture == .stalled || evidence.isEmpty {
            return GoalMomentumIntegrity(title: "Losing shape", detail: "Add one concrete next step or proof point.", visualState: .warning)
        }
        return GoalMomentumIntegrity(title: "Clear next step", detail: "Momentum can stay simple.", visualState: .selected)
    }

    func hasFutureStart(_ timing: GoalTiming) -> Bool {
        guard let startsOn = parseDate(timing.startsOn) else { return false }
        return startsOn > Date()
    }

    func directionLabel(
        for item: GoalListItem,
        lifecycleState: GoalPortfolioLifecycleState,
        posture: GoalsAtlasPosture
    ) -> String {
        switch lifecycleState {
        case .protected:
            return "Protected direction"
        case .waiting:
            return "Waiting direction"
        case .blocked:
            return "Blocked direction"
        case .completed:
            return "Completed direction"
        case .cancelledDropped:
            return "Closed direction"
        case .parked:
            return "Parked direction"
        case .previous:
            return "Previous direction"
        case .future:
            return "Future direction"
        case .active, .passive:
            break
        }

        switch posture {
        case .active:
            return "Active direction"
        case .crowded:
            return "Crowded direction"
        case .stalled:
            return "Stalled direction"
        case .atRisk:
            return "At-risk direction"
        case .lowerPriority:
            return "Held direction"
        case .achieved:
            return "Completed direction"
        }
    }

    func nextStepTimingLabel(for timing: GoalTiming) -> String? {
        if let suggested = timing.suggestedNextAt ?? timing.startsOn,
           let date = parseDate(suggested) {
            let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
            if days <= 0 { return "today" }
            if days <= 7 { return "soon" }
            return "later"
        }
        return nil
    }

    func proofTitle(for evidence: ProgressEvidence) -> String {
        if let note = evidence.note?.trimmingCharacters(in: .whitespacesAndNewlines),
           note.isEmpty == false {
            return note
        }

        return switch evidence.evidenceKind {
        case .stepCompleted: "Completed step"
        case .habitCompletion: "Ritual completion"
        case .habitMinimumVersion: "Minimum version"
        case .habitQuickLog: "Quick log"
        case .sessionLogged: "Session logged"
        case .reflectionLogged: "Reflection"
        case .delegatedUpdate: "Delegated update"
        case .observationLogged: "Observation"
        case .milestoneReached: "Milestone reached"
        }
    }

    func atlasPriorityDescriptor(lhs: GoalsAtlasSurfaceState, rhs: GoalsAtlasSurfaceState) -> Bool {
        if lhs.posture != rhs.posture {
            let order: [GoalsAtlasPosture] = [.atRisk, .crowded, .stalled, .active, .lowerPriority, .achieved]
            return (order.firstIndex(of: lhs.posture) ?? order.count) < (order.firstIndex(of: rhs.posture) ?? order.count)
        }

        if lhs.manualPriorityRank != rhs.manualPriorityRank {
            return lhs.manualPriorityRank < rhs.manualPriorityRank
        }

        return lhs.progressValue > rhs.progressValue
    }

    func recentMovementDescriptor(lhs: GoalsAtlasSurfaceState, rhs: GoalsAtlasSurfaceState) -> Bool {
        if lhs.progressValue == rhs.progressValue {
            return lhs.manualPriorityRank < rhs.manualPriorityRank
        }

        return lhs.progressValue > rhs.progressValue
    }

    func boardPriorityDescriptor(lhs: GoalsBoardCardState, rhs: GoalsBoardCardState) -> Bool {
        atlasPriorityDescriptor(lhs: lhs, rhs: rhs)
    }
}
