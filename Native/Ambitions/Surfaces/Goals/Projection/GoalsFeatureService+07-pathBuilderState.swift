import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func pathBuilderState(
        pathIntelligence: PathIntelligenceProjection?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        missionControl: GoalDetailMissionControlState,
        nextMovement: GoalDetailNextMovement?,
        renderState: GoalRenderState
    ) -> GoalPathBuilderState? {
        guard pathIntelligence != nil || pathStages.isEmpty == false || sections.isEmpty == false else { return nil }

        let phaseStates = pathBuilderPhases(
            pathIntelligence: pathIntelligence,
            pathStages: pathStages,
            sections: sections,
            renderState: renderState
        )
        let forks = pathBuilderForks(from: pathIntelligence)
        let proofRequirements = pathBuilderProofRequirements(
            pathIntelligence: pathIntelligence,
            missionControl: missionControl
        )
        let todayTitle = pathIntelligence?.dailyConnection.nextStepTitle
            ?? nextMovement?.title
            ?? missionControl.primaryNextMove.title
        let todaySummary = pathIntelligence?.dailyConnection.proofHint
            ?? pathIntelligence?.dailyConnection.fallbackHint
            ?? nextMovement?.summary
            ?? missionControl.primaryNextMove.detail
        let breadcrumbLabels = Array((missionControl.breadcrumb.labels + ["Path Builder"]).prefix(4))
        let budget = "Bounded path shape: \(phaseStates.count) phases, \(forks.count) route options, \(proofRequirements.count) proof checks."

        return GoalPathBuilderState(
            title: "Path Builder",
            subtitle: "A long-range view that still keeps the next step visible.",
            breadcrumbLabels: breadcrumbLabels,
            phases: phaseStates,
            forks: forks,
            proofRequirements: proofRequirements,
            todayConnectionTitle: todayTitle,
            todayConnectionSummary: todaySummary.isEmpty ? "Keep one believable next step visible before widening the path shape." : todaySummary,
            planConnectionSummary: "Goal path should only protect the next believable window; wider changes still need review.",
            decisionReceiptSummary: missionControl.decisions.items.first?.summary
                ?? "Path changes should leave a decision or proof trail before they reshape the plan.",
            roadmapListTitle: "Path list",
            roadmapListSummary: "The same phases are available as a plain list for review.",
            performanceBudgetSummary: budget,
            accessibilityLabel: "Path Builder",
            accessibilityValue: "\(phaseStates.count) phases, \(forks.count) forks, \(proofRequirements.count) proof checks. Next step: \(todayTitle).",
            accessibilityHint: "Review the path shape as phases, route options, proof, and the next step before changing the path."
        )
    }


    func pathBuilderPhases(
        pathIntelligence: PathIntelligenceProjection?,
        pathStages: [GoalPathStage],
        sections: [GoalDetailSectionState],
        renderState: GoalRenderState
    ) -> [GoalPathBuilderPhaseState] {
        let stageStateByID = Dictionary(uniqueKeysWithValues: pathStages.map { ($0.id, $0) })

        if let pathIntelligence, pathIntelligence.stages.isEmpty == false {
            return pathIntelligence.stages.prefix(6).map { stage in
                let matchingState = stageStateByID[stage.id]
                let dependency = stage.waitingStateSummary
                    ?? stage.dependencySummaries.first
                    ?? stage.prerequisiteHints.first
                    ?? "No blocking dependency visible."
                let proof = pathIntelligence.proofRequirements.first(where: { $0.stageID == stage.id })?.summary
                    ?? stage.readinessHints.first
                    ?? "Proof can be added when this phase creates a visible signal."

                return GoalPathBuilderPhaseState(
                    id: stage.id,
                    title: stage.title,
                    summary: stage.summary,
                    dependencySummary: dependency,
                    proofSummary: proof,
                    statusLabel: matchingState?.statusLabel ?? stage.kind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                    state: matchingState?.state ?? renderState.visualState
                )
            }
        }

        if pathStages.isEmpty == false {
            return pathStages.prefix(6).map { stage in
                GoalPathBuilderPhaseState(
                    id: stage.id,
                    title: stage.title,
                    summary: stage.summary,
                    dependencySummary: stage.highlight ?? "No blocking dependency visible.",
                    proofSummary: "Attach proof when this phase creates a visible signal.",
                    statusLabel: stage.statusLabel,
                    state: stage.state
                )
            }
        }

        return sections.prefix(6).map { section in
            GoalPathBuilderPhaseState(
                id: section.id,
                title: section.title,
                summary: section.summary,
                dependencySummary: section.steps.first?.timingLabel ?? "No blocking dependency visible.",
                proofSummary: section.steps.contains(where: { $0.summary.localizedCaseInsensitiveContains("proof") })
                    ? "This phase already asks for proof."
                    : "Attach proof when this phase creates a visible signal.",
                statusLabel: section.kindLabel,
                state: section.steps.contains(where: { $0.statusLabel.localizedCaseInsensitiveContains("blocked") }) ? .warning : .default
            )
        }
    }


    func pathBuilderForks(from pathIntelligence: PathIntelligenceProjection?) -> [GoalPathBuilderForkState] {
        let comparisons = (pathIntelligence?.forkComparisons ?? []).prefix(3).map { fork in
            GoalPathBuilderForkState(
                id: fork.id,
                title: fork.forkTitle,
                summary: fork.tradeoffSummary,
                basisSummary: fork.comparisonBasis.prefix(2).joined(separator: " "),
                decisionPrompt: fork.decisionPrompt,
                freshnessLabel: freshnessTitle(fork.freshnessLabel),
                state: fork.freshnessLabel == .current ? .selected : .warning
            )
        }

        if comparisons.isEmpty == false {
            return comparisons
        }

        return (pathIntelligence?.futureSelfScenarios ?? [])
            .filter { $0.kind != .continueCurrentPath }
            .prefix(2)
            .map { scenario in
                GoalPathBuilderForkState(
                    id: "path-builder-\(scenario.id)",
                    title: scenario.title,
                    summary: scenario.summary,
                    basisSummary: scenario.notPredictionLabel,
                    decisionPrompt: "Choose, edit, or park this fork from Goal Detail before it shapes Today.",
                    freshnessLabel: "May Need Review",
                    state: .warning
                )
            }
    }


    func pathBuilderProofRequirements(
        pathIntelligence: PathIntelligenceProjection?,
        missionControl: GoalDetailMissionControlState
    ) -> [GoalPathBuilderProofState] {
        let projectedProof = (pathIntelligence?.proofRequirements ?? []).prefix(4).map { proof in
            GoalPathBuilderProofState(
                id: proof.id,
                title: proof.proofKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
                summary: proof.summary,
                handoffLabel: handoffTitle(proof.handoffSurface),
                state: .default
            )
        }

        if projectedProof.isEmpty == false {
            return projectedProof
        }

        return missionControl.proofRail.items.prefix(4).map { item in
            GoalPathBuilderProofState(
                id: item.id,
                title: item.title,
                summary: item.subtitle,
                handoffLabel: "Proof",
                state: item.state
            )
        }
    }


    func freshnessTitle(_ freshness: PathIntelligenceFreshnessLabel) -> String {
        switch freshness {
        case .current:
            return "Current"
        case .mayNeedReview:
            return "May Need Review"
        case .basedOnOlderContext:
            return "Based on Older Context"
        }
    }


    func handoffTitle(_ surface: PathIntelligenceHandoffSurface) -> String {
        switch surface {
        case .today:
            return "Today"
        case .plan:
            return "Path"
        case .goalDetail:
            return "Goal Detail"
        case .proof:
            return "Proof"
        }
    }
}
