import AmbitionsDesignSystem
import Foundation

extension PreviewGoalsScenarios {
    static let overview = GoalsOverview(
        hero: GoalsBoardHeroState(
            eyebrow: "Direction Board",
            title: "Goals",
            subtitle: "Preview goals should read like a living board, not a portfolio dump.",
            dominantTruth: "Close the hardening pass is the clearest live ambition right now.",
            pressureSummary: "Plan a freelance pivot is still blocked on one real constraint, so pressure is leaking into the board.",
            contextPills: [
                GoalsHeroPillState(title: "4 active", icon: "scope", state: .selected),
                GoalsHeroPillState(title: "2 stretching thin", icon: "wind", state: .warning),
                GoalsHeroPillState(title: "Preview data", icon: "sparkles", state: .celebration),
            ],
            attentionPills: [
                GoalsHeroPillState(title: "1 freshness attention", icon: "sparkle.magnifyingglass", state: .warning),
                GoalsHeroPillState(title: "1 contradiction attention", icon: "sparkle.magnifyingglass", state: .warning),
            ]
        ),
        heroPrimaryAction: GoalsBoardPrimaryAction(
            kind: .recoverGoal,
            title: "Recover Plan a freelance pivot",
            subtitle: "The exploration still needs a real decision target before the path is trustworthy.",
            systemImage: "lifepreserver",
            target: blockedTarget,
            state: .warning
        ),
        bands: [
            GoalsBoardBand(
                kind: .activeDirection,
                title: "Active direction",
                subtitle: "The ambitions that are truly alive and still have believable momentum this week.",
                cards: [
                    card(
                        id: "goal-native",
                        target: activeTarget,
                        title: "Close the hardening pass",
                        subtitle: "Tighten repo truth, validation coverage, and release readiness without widening scope.",
                        modeLabel: "Project",
                        posture: .active,
                        renderState: .active,
                        progressValue: 0.46,
                        progressLabel: "5/11 steps complete",
                        timingLabel: "Due 2026-05-01",
                        weekRelationship: "This week this goal is carrying the strongest directional weight.",
                        phaseSummary: "Truth and trust",
                        milestoneSummary: "2/5 milestones visible",
                        pressureSummary: "The path still has believable momentum.",
                        nextStepHint: "Refresh release docs and trust copy",
                        priorityLabel: "Priority #1"
                    ),
                    card(
                        id: "goal-support",
                        target: supportTarget,
                        title: "Help Maya rebuild a reading rhythm",
                        subtitle: "Supportive structure that keeps Maya as the owner of execution.",
                        modeLabel: "Support",
                        posture: .active,
                        renderState: .active,
                        progressValue: 0.31,
                        progressLabel: "2/7 support steps landed",
                        timingLabel: "Support window open",
                        weekRelationship: "This week can stay steady without opening Plan.",
                        phaseSummary: "Support rhythm",
                        milestoneSummary: "1/3 milestones visible",
                        pressureSummary: "The path still has believable momentum.",
                        nextStepHint: "Set up one calm reading check-in",
                        supportLabel: "Support for Maya",
                        priorityLabel: "Priority #3"
                    ),
                ]
            ),
            GoalsBoardBand(
                kind: .pressure,
                title: "Pressure points",
                subtitle: "Where pressure, crowding, or drift is starting to distort the direction board.",
                cards: [
                    card(
                        id: "draft-blocked",
                        target: blockedTarget,
                        title: "Plan a freelance pivot",
                        subtitle: "The planner is blocked until the real constraint is clarified.",
                        modeLabel: "Exploration",
                        posture: .atRisk,
                        renderState: .blocked,
                        progressValue: 0.05,
                        progressLabel: "Needs planning input",
                        timingLabel: "Flexible window",
                        weekRelationship: "This week needs a clarifying step before more planning.",
                        phaseSummary: "Constraint definition",
                        milestoneSummary: "0/2 milestones visible",
                        pressureSummary: "The exploration still needs a real decision target before it can become a believable path.",
                        nextStepHint: "Clarify what decision this exploration actually needs to support",
                        priorityLabel: "Priority #5"
                    ),
                    card(
                        id: "draft-clarify",
                        target: clarificationTarget,
                        title: "Break this down for someone else",
                        subtitle: "The planner needs one missing detail before the path is trustworthy.",
                        modeLabel: "Support",
                        posture: .crowded,
                        renderState: .clarification,
                        progressValue: 0.08,
                        progressLabel: "Needs planning input",
                        timingLabel: "Support when helpful",
                        weekRelationship: "This week needs a clarifying step before more planning.",
                        phaseSummary: "Executor clarity",
                        milestoneSummary: "0/1 milestones visible",
                        pressureSummary: "This goal is still alive, but portfolio pressure is squeezing it behind clearer work.",
                        nextStepHint: "Who is this actually for?",
                        supportLabel: "Support goal",
                        priorityLabel: "Priority #4"
                    ),
                ]
            ),
            GoalsBoardBand(
                kind: .recentMovement,
                title: "Recent movement",
                subtitle: "Visible momentum so you can see which ambitions are actually moving.",
                cards: [
                    card(
                        id: "goal-learning",
                        target: starterTarget,
                        title: "Learn advanced vocal mixing",
                        subtitle: "A learning track that should stay untimed and evidence-based.",
                        modeLabel: "Learning",
                        posture: .stalled,
                        renderState: .starter,
                        progressValue: 0.22,
                        progressLabel: "Starter assumptions in play",
                        timingLabel: "Untimed",
                        weekRelationship: "This week needs a small visible signal to stay alive.",
                        phaseSummary: "Starter path",
                        milestoneSummary: "0/2 milestones visible",
                        pressureSummary: "Recent movement is thin, so this goal is starting to drift out of view.",
                        nextStepHint: "Record one rough pass and note what still sounds muddy",
                        priorityLabel: "Priority #2"
                    )
                ]
            )
        ],
        horizonLadder: GoalsHorizonLadderState(
            title: "Horizon ladder",
            subtitle: "A shallow read on where the live goals sit in their phase or path.",
            rungs: [
                GoalsHorizonLadderRung(id: "goal-native", target: activeTarget, title: "Close the hardening pass", summary: "Truth and trust", milestoneLabel: "2/5 milestones", signalLabel: "Path is moving", highlight: "Refresh release docs and trust copy", state: .selected),
                GoalsHorizonLadderRung(id: "goal-support", target: supportTarget, title: "Help Maya rebuild a reading rhythm", summary: "Support rhythm", milestoneLabel: "1/3 milestones", signalLabel: "Path is moving", highlight: "Set up one calm reading check-in", state: .selected),
                GoalsHorizonLadderRung(id: "draft-blocked", target: blockedTarget, title: "Plan a freelance pivot", summary: "Constraint definition", milestoneLabel: "0/2 milestones", signalLabel: "Blocked signal visible", highlight: "Clarify the real decision target", state: .warning),
            ]
        ),
        weekPressureSummary: GoalsWeekPressureSummary(
            title: "Pressure is spreading across the board",
            subtitle: "Multiple goals are competing for week-level attention.",
            leadingMetric: "4 active",
            trailingMetric: "2 stretching thin",
            pill: GoalsHeroPillState(title: "Compressed week", icon: "exclamationmark.triangle", state: .warning)
        ),
        lowerPriority: GoalsLowerPriorityState(
            title: "Lower-priority and closed loops",
            subtitle: "Paused or already-closed goals stay available without competing with live direction pressure.",
            disclosureTitle: "Show quieter goals",
            cards: [
                card(
                    id: "goal-pause",
                    target: GoalRouteTarget(goalID: "goal-pause"),
                    title: "Refresh the onboarding copy",
                    subtitle: "Useful, but deliberately paused until the goals flow lands.",
                    modeLabel: "Maintenance",
                    posture: .lowerPriority,
                    renderState: .onHold,
                    progressValue: 0.12,
                    progressLabel: "Paused at 1/6 steps",
                    timingLabel: "Every 7 days",
                    weekRelationship: "This week can stay quiet.",
                    phaseSummary: "Paused maintenance",
                    milestoneSummary: "1/6 steps visible",
                    pressureSummary: "This goal is intentionally quieter right now.",
                    nextStepHint: "Revisit after the goals milestone lands",
                    priorityLabel: "Priority #6"
                ),
                card(
                    id: "goal-done",
                    target: GoalRouteTarget(goalID: "goal-done"),
                    title: "Stabilize the five-tab shell",
                    subtitle: "The current shell already reflects the shipped tab model.",
                    modeLabel: "Achievement",
                    posture: .achieved,
                    renderState: .achieved,
                    progressValue: 1,
                    progressLabel: "11/11 steps complete",
                    timingLabel: "Due 2026-04-12",
                    weekRelationship: "This loop is closed.",
                    phaseSummary: "Completed shell work",
                    milestoneSummary: "All milestones landed",
                    pressureSummary: "This loop is closed and no longer competing for attention.",
                    nextStepHint: "Keep routing and trust notes aligned",
                    priorityLabel: "Priority #7"
                ),
            ]
        ),
        lifecycleRail: [
            GoalLifecycleRailSegment(id: "previous", title: "Previous", count: 2, subtitle: "Closed or parked", state: .default),
            GoalLifecycleRailSegment(id: "active", title: "Active", count: 4, subtitle: "Currently shaping attention", state: .selected),
            GoalLifecycleRailSegment(id: "future", title: "Future", count: 0, subtitle: "No scheduled future goals", state: .default),
        ],
        stateChips: [
            GoalStateChipState(lifecycleState: .protected, count: 1),
            GoalStateChipState(lifecycleState: .waiting, count: 0),
            GoalStateChipState(lifecycleState: .blocked, count: 1),
            GoalStateChipState(lifecycleState: .parked, count: 1),
            GoalStateChipState(lifecycleState: .completed, count: 1),
            GoalStateChipState(lifecycleState: .cancelledDropped, count: 0),
        ],
        atlasPreview: GoalAtlasPreviewState(
            title: "Goal Atlas preview",
            subtitle: "A lightweight grouping by life area. Full path mapping stays owned by later batches.",
            groups: [
                GoalAtlasPreviewGroup(id: "career", title: "Career", subtitle: "2 goals connected here", items: [
                    GoalAtlasPreviewItem(id: "goal-native", title: "Close the hardening pass", subtitle: "Refresh release docs and trust copy", state: .selected),
                    GoalAtlasPreviewItem(id: "draft-blocked", title: "Plan a freelance pivot", subtitle: "Clarify the real decision target", state: .warning),
                ]),
                GoalAtlasPreviewGroup(id: "creativity", title: "Creativity", subtitle: "1 goal connected here", items: [
                    GoalAtlasPreviewItem(id: "goal-learning", title: "Learn advanced vocal mixing", subtitle: "Record one rough pass", state: .default),
                ]),
            ]
        ),
        archiveSummary: GoalPortfolioArchiveSummary(
            title: "2 goals in archive states",
            subtitle: "Completed, parked, and cancelled goals are preserved without being treated as failure.",
            chips: [
                GoalStateChipState(lifecycleState: .parked, count: 1),
                GoalStateChipState(lifecycleState: .completed, count: 1),
                GoalStateChipState(lifecycleState: .cancelledDropped, count: 0),
            ],
            learningLines: [
                "Finish launch checklist: completed with proof visible.",
                "Park the old weekly board: parked so attention can stay honest."
            ]
        ),
        maturitySummary: previewMaturitySummary,
        items: [],
        isSeeded: true,
        emptyTitle: "No goals yet",
        emptyMessage: "Once a goal or planning draft exists, this screen will immediately explain the path, not just dump steps."
    )
}
