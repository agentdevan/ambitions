import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func goalDetailTimeline(
        context: DetailContext,
        renderState: GoalRenderState,
        pathStages: [GoalPathStage],
        evidenceItems: [GoalEvidenceItem],
        feedbackItems: [GoalFeedbackItem],
        nextMovement: GoalDetailNextMovement?,
        progressLabel: String
    ) -> GoalDetailTimelineState {
        var items: [GoalDetailTimelineItemState] = [
            GoalDetailTimelineItemState(
                id: "started",
                kind: .started,
                title: "Started",
                summary: context.goal?.createdAt ?? context.draft?.createdAt ?? "Start date is not available.",
                timestamp: context.goal?.createdAt ?? context.draft?.createdAt,
                state: .default,
                isFuture: false
            )
        ]

        if let previous = pathStages.first(where: { $0.position == .completed }) {
            items.append(GoalDetailTimelineItemState(id: "previous-\(previous.id)", kind: .previous, title: previous.title, summary: previous.summary, timestamp: nil, state: previous.state, isFuture: false))
        }
        if let current = pathStages.first(where: { $0.position == .current || $0.position == .blocked }) ?? pathStages.first {
            items.append(GoalDetailTimelineItemState(id: "current-\(current.id)", kind: current.position == .blocked ? .waiting : .current, title: current.title, summary: current.highlight ?? current.summary, timestamp: nil, state: current.state, isFuture: false))
        }
        if let proof = evidenceItems.first {
            items.append(GoalDetailTimelineItemState(id: "proof-\(proof.id)", kind: .proof, title: proof.title, summary: proof.subtitle, timestamp: proof.timestamp, state: proof.state, isFuture: false))
        }
        if let decision = feedbackItems.first {
            items.append(GoalDetailTimelineItemState(id: "decision-\(decision.id)", kind: .decision, title: decision.title, summary: decision.subtitle, timestamp: decision.timestamp, state: decision.state, isFuture: false))
        }
        if renderState == .onHold {
            items.append(GoalDetailTimelineItemState(id: "parked", kind: .parked, title: "Parked", summary: "This goal is intentionally quiet.", timestamp: nil, state: .default, isFuture: false))
        }
        if renderState == .achieved || context.goal?.state == .completed {
            items.append(GoalDetailTimelineItemState(id: "completed", kind: .completed, title: "Completed", summary: progressLabel, timestamp: context.goal?.updatedAt, state: .success, isFuture: false))
        }
        if context.goal?.state == .archived && renderState != .achieved {
            items.append(GoalDetailTimelineItemState(id: "cancelled", kind: .cancelled, title: "Cancelled", summary: "This goal is closed without being treated as active work.", timestamp: context.goal?.updatedAt, state: .default, isFuture: false))
        }
        if let nextMovement, renderState != .achieved, context.goal?.state != .archived {
            items.append(GoalDetailTimelineItemState(id: "next", kind: .next, title: nextMovement.title, summary: nextMovement.summary, timestamp: nil, state: nextMovement.state, isFuture: true))
        }

        return GoalDetailTimelineState(
            title: "Storyline",
            subtitle: "A compact read on what happened, what is current, and what is only a possible next step.",
            items: Array(items.prefix(7))
        )
    }


    func goalDetailAssumptions(
        context: DetailContext,
        renderState: GoalRenderState,
        timing: GoalTiming,
        evidenceItems: [GoalEvidenceItem],
        suggestions: [GoalDetailStepItem],
        risks: [GoalDetailRiskState]
    ) -> [GoalDetailAssumptionState] {
        var assumptions: [GoalDetailAssumptionState] = [
            GoalDetailAssumptionState(
                id: "next-step",
                title: "This goal has a next step.",
                status: suggestions.isEmpty ? "Needs review" : "Visible",
                whyItMatters: "The screen should lead with one step, not a long step dump.",
                correctionLabel: suggestions.isEmpty ? "Review next step" : "Change next step",
                state: suggestions.isEmpty ? .warning : .selected
            ),
            GoalDetailAssumptionState(
                id: "proof",
                title: "This goal has enough proof.",
                status: evidenceItems.isEmpty ? "No evidence yet" : "Evidence visible",
                whyItMatters: "Progress should be backed by something observable.",
                correctionLabel: "Add proof later",
                state: evidenceItems.isEmpty ? .default : .selected
            ),
            GoalDetailAssumptionState(
                id: "blocked",
                title: "This goal is not blocked.",
                status: risks.contains(where: { $0.id == "risk-blocked" }) ? "Blocked" : "No blocker visible",
                whyItMatters: "Blocked goals need a clearing step before more planning.",
                correctionLabel: risks.contains(where: { $0.id == "risk-blocked" }) ? "Review blocker" : nil,
                state: risks.contains(where: { $0.id == "risk-blocked" }) ? .warning : .success
            ),
            GoalDetailAssumptionState(
                id: "timing",
                title: "This timing is still believable.",
                status: timing.dueAt == nil && timing.targetBy == nil ? "Untimed" : "Needs review",
                whyItMatters: "Dates should not create fake pressure.",
                correctionLabel: timing.dueAt == nil && timing.targetBy == nil ? nil : "Review timing",
                state: timing.dueAt == nil && timing.targetBy == nil ? .default : .warning
            ),
            GoalDetailAssumptionState(
                id: "active",
                title: "This goal is active, not parked.",
                status: renderState == .onHold ? "Parked" : renderState == .achieved ? "Completed" : "Active",
                whyItMatters: "Closed or parked goals should not compete with live direction.",
                correctionLabel: renderState == .onHold ? "Review parked state" : nil,
                state: renderState == .onHold ? .default : renderState == .achieved ? .success : .selected
            )
        ]

        assumptions.append(contentsOf: context.draft?.assumptions.prefix(2).map { assumption in
            GoalDetailAssumptionState(
                id: "draft-\(assumption.id)",
                title: assumption.summary,
                status: "Provisional",
                whyItMatters: "Starter assumptions should stay visible until corrected by real use.",
                correctionLabel: "Correct later",
                state: .default
            )
        } ?? [])

        return Array(assumptions.prefix(7))
    }
}
