import AmbitionsDesignSystem
import Foundation

enum PreviewGoalsScenarios {
    static let activeTarget = GoalRouteTarget(goalID: "goal-native", draftID: "draft-native")
    static let starterTarget = GoalRouteTarget(goalID: "goal-learning", draftID: "draft-learning")
    static let clarificationTarget = GoalRouteTarget(draftID: "draft-clarify")
    static let blockedTarget = GoalRouteTarget(draftID: "draft-blocked", launchContext: .help)
    static let supportTarget = GoalRouteTarget(goalID: "goal-support", draftID: "draft-support")

    static let overview = GoalsOverview(
        title: "Goals",
        subtitle: "The native Goals screen should feel like the place where the roadmap becomes understandable, not like a backlog dump.",
        contextPills: ["4 active", "2 need care", "Seeded native data"],
        isSeeded: true,
        filterSummaries: [
            GoalsFilterSummary(filter: .active, count: 5),
            GoalsFilterSummary(filter: .onHold, count: 1),
            GoalsFilterSummary(filter: .achieved, count: 1),
        ],
        items: [
            GoalListItem(id: "goal-native", target: activeTarget, title: "Ship the native Goals vertical", subtitle: "Replace the placeholder goal flow with the real SwiftUI destination.", mode: .project, renderState: .active, progressValue: 0.46, progressLabel: "5/11 steps complete", statusLabel: "In motion", timingLabel: "Due 2026-05-01", nextStepHint: "Wire Goal Detail into Today route actions", modeLabel: "Project", supportLabel: nil, relevanceScore: 0.94, momentumScore: 0.72, urgencyScore: 0.83, manualPriorityRank: 0, updatedAt: "2026-04-14T12:00:00Z"),
            GoalListItem(id: "goal-learning", target: starterTarget, title: "Learn advanced vocal mixing", subtitle: "A learning track that should stay untimed and evidence-based.", mode: .learning, renderState: .starter, progressValue: 0.22, progressLabel: "Starter assumptions in play", statusLabel: "Starter path", timingLabel: "Untimed", nextStepHint: "Record one rough pass and note what still sounds muddy", modeLabel: "Learning", supportLabel: nil, relevanceScore: 0.81, momentumScore: 0.41, urgencyScore: 0.28, manualPriorityRank: 1, updatedAt: "2026-04-14T11:00:00Z"),
            GoalListItem(id: "goal-support", target: supportTarget, title: "Help Maya rebuild a reading rhythm", subtitle: "Supportive structure that keeps Maya as the owner of execution.", mode: .delegatedSupport, renderState: .active, progressValue: 0.31, progressLabel: "2/7 support steps landed", statusLabel: "In motion", timingLabel: "Support window open", nextStepHint: "Set up one calm reading check-in", modeLabel: "Support", supportLabel: "Support for Maya", relevanceScore: 0.78, momentumScore: 0.55, urgencyScore: 0.49, manualPriorityRank: 2, updatedAt: "2026-04-14T10:00:00Z"),
            GoalListItem(id: "draft-clarify", target: clarificationTarget, title: "Break this down for someone else", subtitle: "The planner needs one missing detail before the path is trustworthy.", mode: .delegatedSupport, renderState: .clarification, progressValue: 0.08, progressLabel: "Needs planning input", statusLabel: "Needs clarity", timingLabel: "Support when helpful", nextStepHint: "Who is this actually for?", modeLabel: "Support", supportLabel: "Support goal", relevanceScore: 0.9, momentumScore: 0.2, urgencyScore: 0.76, manualPriorityRank: 3, updatedAt: "2026-04-14T09:30:00Z"),
            GoalListItem(id: "draft-blocked", target: blockedTarget, title: "Plan a freelance pivot", subtitle: "The planner is blocked until the real constraint is clarified.", mode: .exploration, renderState: .blocked, progressValue: 0.05, progressLabel: "Needs planning input", statusLabel: "Blocked", timingLabel: "Flexible window", nextStepHint: "Clarify what decision this exploration actually needs to support", modeLabel: "Exploration", supportLabel: nil, relevanceScore: 0.89, momentumScore: 0.18, urgencyScore: 0.71, manualPriorityRank: 4, updatedAt: "2026-04-14T09:00:00Z"),
            GoalListItem(id: "goal-pause", target: GoalRouteTarget(goalID: "goal-pause"), title: "Refresh the onboarding copy", subtitle: "Useful, but deliberately paused until the goals flow lands.", mode: .maintenance, renderState: .onHold, progressValue: 0.12, progressLabel: "Paused at 1/6 steps", statusLabel: "On hold", timingLabel: "Every 7 days", nextStepHint: "Revisit after the goals milestone lands", modeLabel: "Maintenance", supportLabel: nil, relevanceScore: 0.42, momentumScore: 0.16, urgencyScore: 0.12, manualPriorityRank: 5, updatedAt: "2026-04-13T16:00:00Z"),
            GoalListItem(id: "goal-done", target: GoalRouteTarget(goalID: "goal-done"), title: "Build the native Today screen", subtitle: "The first native surface already shipped.", mode: .achievement, renderState: .achieved, progressValue: 1, progressLabel: "11/11 steps complete", statusLabel: "Achieved", timingLabel: "Due 2026-04-12", nextStepHint: "Document the handoff to Goals and Habits", modeLabel: "Achievement", supportLabel: nil, relevanceScore: 0.3, momentumScore: 0.94, urgencyScore: 0.08, manualPriorityRank: 6, updatedAt: "2026-04-12T18:00:00Z"),
        ],
        emptyTitle: "No goals yet",
        emptyMessage: "Once a goal or planning draft exists, this screen will immediately explain the path, not just dump tasks."
    )

    static let detailScenarios: [String: GoalDetailPresentation] = [
        activeTarget.id: GoalDetailPresentation(
            target: activeTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Ship the native Goals vertical", subtitle: "Replace the placeholder goal flow with the real SwiftUI destination.", renderState: .active, modeLabel: "Project", timingLabel: "Due 2026-05-01", supportLabel: nil),
            outcome: "Ship a production-quality native Goals surface that becomes Today's real open-detail destination.",
            intent: "Understand the path, the next move, and the evidence that proves it is moving.",
            progress: GoalDetailProgress(label: "5 of 11 steps landed", detail: "Progress is reading the real persisted plan and evidence history.", value: 0.46, evidenceLabel: "85 minutes of visible evidence"),
            timingNote: "The deadline is real, but the path should still stay session-sized.",
            progressNote: "The next step stays small enough to act on without losing the broader path.",
            assumptions: [],
            suggestions: [
                GoalDetailStepItem(id: "s1", title: "Wire Goal Detail into Today route actions", summary: "Replace the Today placeholder and land on the real goal target.", timingLabel: "Due 2026-04-15", statusLabel: "Planned", state: .selected),
                GoalDetailStepItem(id: "s2", title: "Finish inline replanning actions", summary: "Persist smaller-step, stuck, and timing-softening behavior.", timingLabel: "Due 2026-04-16", statusLabel: "Planned", state: .default),
            ],
            pathStages: [
                GoalPathStage(id: "p1", title: "Structure", summary: "Route, list, and detail foundations", stepCountLabel: "4 steps", highlight: "Wire Goal Detail into Today route actions", state: .selected),
                GoalPathStage(id: "p2", title: "Finish quality", summary: "Previews, polish, and verification", stepCountLabel: "3 steps", highlight: "Run focused compile checks", state: .default),
            ],
            sections: [
                GoalDetailSectionState(id: "sec-1", title: "Now", summary: "The highest-leverage work still open.", kindLabel: "Active Steps", steps: [
                    GoalDetailStepItem(id: "s1", title: "Wire Goal Detail into Today route actions", summary: "Replace the Today placeholder and land on the real goal target.", timingLabel: "Due 2026-04-15", statusLabel: "Planned", state: .selected),
                    GoalDetailStepItem(id: "s2", title: "Finish inline replanning actions", summary: "Persist smaller-step, stuck, and timing-softening behavior.", timingLabel: "Due 2026-04-16", statusLabel: "Planned", state: .default),
                ]),
                GoalDetailSectionState(id: "sec-2", title: "Path", summary: "Broader structure beyond the next move.", kindLabel: "Upcoming", steps: [
                    GoalDetailStepItem(id: "s3", title: "Refine previews for blocked and clarification states", summary: "Keep the states calm, premium, and explicit.", timingLabel: "Due 2026-04-17", statusLabel: "Planned", state: .default),
                ]),
            ],
            clarification: nil,
            blocked: nil,
            evidence: [
                GoalEvidenceItem(id: "e1", title: "Today route state proved out", subtitle: "Session Logged", timestamp: "2026-04-14T11:40:00Z", state: .success),
                GoalEvidenceItem(id: "e2", title: "Goal list structure drafted", subtitle: "Session Logged", timestamp: "2026-04-14T10:25:00Z", state: .success),
            ],
            history: [
                GoalFeedbackItem(id: "h1", title: "Asked for smaller step", subtitle: "Reduce the first route task to one deterministic pass.", timestamp: "2026-04-13T15:00:00Z", state: .selected),
            ],
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success),
                GoalDetailActionState(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default),
                GoalDetailActionState(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected),
                GoalDetailActionState(kind: .imStuck, title: "I'm stuck", systemImage: "lifepreserver", state: .warning),
                GoalDetailActionState(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default),
            ],
            primaryStepID: "s1",
            canSwitchToUntimed: false,
            supportModeActive: false,
            defaultLens: .tasks
        ),
        starterTarget.id: GoalDetailPresentation(
            target: starterTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Learn advanced vocal mixing", subtitle: "A learning track that should stay untimed and evidence-based.", renderState: .starter, modeLabel: "Learning", timingLabel: "Untimed", supportLabel: nil),
            outcome: "Build confidence by learning through small, visible experiments rather than deadline pressure.",
            intent: "Stay oriented to signal and learning, not just task completion.",
            progress: GoalDetailProgress(label: "Starter path in motion", detail: "Starter-plan assumptions are being treated as temporary scaffolding.", value: 0.22, evidenceLabel: "No evidence logged yet"),
            timingNote: "This goal is intentionally untimed, so progress is visible without an artificial countdown.",
            progressNote: "Starter plans are allowed to be provisional while the system learns what actually helps.",
            assumptions: ["A single rough pass is enough signal.", "You do not need the whole system figured out before the first session."],
            suggestions: [
                GoalDetailStepItem(id: "ls1", title: "Record one rough pass", summary: "Capture one take and note the muddiest frequency area.", timingLabel: "Untimed", statusLabel: "Planned", state: .selected),
            ],
            pathStages: [
                GoalPathStage(id: "lp1", title: "Starter path", summary: "Low-pressure first signal", stepCountLabel: "2 steps", highlight: "Record one rough pass", state: .selected),
            ],
            sections: [
                GoalDetailSectionState(id: "lsec1", title: "Starter path", summary: "Short, safe first moves.", kindLabel: "Overview", steps: [
                    GoalDetailStepItem(id: "ls1", title: "Record one rough pass", summary: "Capture one take and note the muddiest frequency area.", timingLabel: "Untimed", statusLabel: "Planned", state: .selected),
                ]),
            ],
            clarification: nil,
            blocked: nil,
            evidence: [],
            history: [],
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success),
                GoalDetailActionState(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected),
                GoalDetailActionState(kind: .breakThisDownSmaller, title: "Break it down", systemImage: "rectangle.split.3x1", state: .selected),
                GoalDetailActionState(kind: .switchToUntimed, title: "Switch to untimed", systemImage: "calendar.badge.minus", state: .default),
            ],
            primaryStepID: "ls1",
            canSwitchToUntimed: false,
            supportModeActive: false,
            defaultLens: .path
        ),
        clarificationTarget.id: GoalDetailPresentation(
            target: clarificationTarget,
            headline: GoalDetailHeadline(eyebrow: "Support Goal", title: "Break this down for someone else", subtitle: "The planner needs one missing detail before the path is trustworthy.", renderState: .clarification, modeLabel: "Support", timingLabel: "Support when helpful", supportLabel: "This path is framed around supporting someone else."),
            outcome: "Build a support plan that helps without taking ownership away from the other person.",
            intent: "The system is protecting plan quality by showing what still needs to be clarified.",
            progress: GoalDetailProgress(label: "Clarification first", detail: "Progress is paused until the missing context is explicit.", value: 0.05, evidenceLabel: "No evidence logged yet"),
            timingNote: "Support goals should suggest windows, not impose pressure.",
            progressNote: "Clarification comes before decomposition. Ambitions is surfacing the missing information instead of inventing urgency.",
            assumptions: [],
            suggestions: [],
            pathStages: [],
            sections: [],
            clarification: GoalClarificationState(title: "Clarification needed", subtitle: "Ambitions is pausing decomposition until these questions are answered cleanly.", questions: [
                TodayClarificationQuestionState(id: "cq1", prompt: "Who is this actually for?", rationale: "The planner needs to know whose work is being supported.", gentleDefault: "If unclear, assume you are supporting without taking ownership."),
                TodayClarificationQuestionState(id: "cq2", prompt: "What visible outcome would matter most?", rationale: "A single success definition leads to a cleaner path.", gentleDefault: "Start with the smallest visible improvement you would notice."),
            ]),
            blocked: nil,
            evidence: [],
            history: [],
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .showSupportMode, title: "Support mode", systemImage: "person.2.fill", state: .selected),
            ],
            primaryStepID: nil,
            canSwitchToUntimed: false,
            supportModeActive: true,
            defaultLens: .path
        ),
        blockedTarget.id: GoalDetailPresentation(
            target: blockedTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Plan a freelance pivot", subtitle: "The planner is blocked until the real constraint is clarified.", renderState: .blocked, modeLabel: "Exploration", timingLabel: "Flexible window", supportLabel: nil),
            outcome: "Explore whether freelancing is worth pursuing without pretending the path is already clear.",
            intent: "The blocker is explicit so you can resolve the actual constraint instead of performing progress.",
            progress: GoalDetailProgress(label: "Blocked state", detail: "The planner kept the constraint explicit instead of inventing fake tasks.", value: 0.04, evidenceLabel: "No evidence logged yet"),
            timingNote: "The window matters, but the path still stays flexible.",
            progressNote: "The blocker is kept visible so the path can restart cleanly once the missing input arrives.",
            assumptions: [],
            suggestions: [],
            pathStages: [],
            sections: [],
            clarification: nil,
            blocked: GoalBlockedState(title: "Blocked planning state", subtitle: "The planner kept the blocker explicit instead of generating performative tasks.", blockers: ["The decision you are trying to make is still vague.", "The exploration needs one success criterion before decomposition."]),
            evidence: [],
            history: [],
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
            ],
            primaryStepID: nil,
            canSwitchToUntimed: true,
            supportModeActive: false,
            defaultLens: .path
        ),
        supportTarget.id: GoalDetailPresentation(
            target: supportTarget,
            headline: GoalDetailHeadline(eyebrow: "Support Goal", title: "Help Maya rebuild a reading rhythm", subtitle: "Supportive structure that keeps Maya as the owner of execution.", renderState: .active, modeLabel: "Support", timingLabel: "Support window open", supportLabel: "This path is framed around supporting Maya."),
            outcome: "Create consistent reading support for Maya without turning the relationship into compliance work.",
            intent: "Support Maya with structure that stays collaborative and non-punitive.",
            progress: GoalDetailProgress(label: "2 of 7 support steps landed", detail: "Progress is reading the real persisted plan and evidence history.", value: 0.31, evidenceLabel: "45 minutes of visible evidence"),
            timingNote: "Support goals should suggest windows, not impose pressure.",
            progressNote: "Support goals stay non-punitive. Progress reflects what you can support, not what you can force.",
            assumptions: [],
            suggestions: [
                GoalDetailStepItem(id: "ss1", title: "Set up one calm reading check-in", summary: "Invite Maya to choose the time and the book.", timingLabel: "Support window open", statusLabel: "Planned", state: .selected),
            ],
            pathStages: [
                GoalPathStage(id: "sp1", title: "Support rhythm", summary: "Create repeatable, calm support loops", stepCountLabel: "3 steps", highlight: "Set up one calm reading check-in", state: .selected),
            ],
            sections: [
                GoalDetailSectionState(id: "ssec1", title: "Support rhythm", summary: "Actions you can take without taking ownership away.", kindLabel: "Supporting Work", steps: [
                    GoalDetailStepItem(id: "ss1", title: "Set up one calm reading check-in", summary: "Invite Maya to choose the time and the book.", timingLabel: "Support window open", statusLabel: "Planned", state: .selected),
                ]),
            ],
            clarification: nil,
            blocked: nil,
            evidence: [
                GoalEvidenceItem(id: "se1", title: "Last check-in felt collaborative", subtitle: "Delegated Update", timestamp: "2026-04-13T18:00:00Z", state: .success),
            ],
            history: [],
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success),
                GoalDetailActionState(kind: .showSupportMode, title: "Support mode", systemImage: "person.2.fill", state: .selected),
            ],
            primaryStepID: "ss1",
            canSwitchToUntimed: true,
            supportModeActive: true,
            defaultLens: .path
        ),
    ]
}
