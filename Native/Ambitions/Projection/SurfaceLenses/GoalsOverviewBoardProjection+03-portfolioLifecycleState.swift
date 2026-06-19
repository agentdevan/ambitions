import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

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
}
