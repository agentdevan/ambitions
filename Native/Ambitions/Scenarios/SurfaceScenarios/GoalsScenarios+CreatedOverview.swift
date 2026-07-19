import AmbitionsDesignSystem
import Foundation

extension PreviewGoalsScenarios {
    static let createdOverview = GoalsOverview(
        hero: GoalsBoardHeroState(
            eyebrow: "Direction Board",
            title: "Goals",
            subtitle: "A freshly created goal should feel grounded immediately instead of landing in a flat list.",
            dominantTruth: "Build a calmer weekly review ritual is the only live direction right now.",
            pressureSummary: "The path is still shallow, but the first week signal is already visible.",
            contextPills: [
                GoalsHeroPillState(title: "1 active", icon: "scope", state: .selected),
                GoalsHeroPillState(title: "0 stretching thin", icon: "leaf", state: .success),
                GoalsHeroPillState(title: "Live preview data", icon: "sparkles", state: .selected),
            ],
            attentionPills: []
        ),
        heroPrimaryAction: GoalsBoardPrimaryAction(
            kind: .openGoal,
            title: "Open Build a calmer weekly review ritual",
            subtitle: "The first path is already visible and ready for detail.",
            systemImage: "arrow.up.right.circle",
            target: GoalRouteTarget(goalID: "goal-created", draftID: "draft-created"),
            state: .selected
        ),
        bands: [
            GoalsBoardBand(
                kind: .activeDirection,
                title: "Active direction",
                subtitle: "The ambitions that are truly alive and still have believable momentum this week.",
                cards: [
                    card(
                        id: "goal-created",
                        target: GoalRouteTarget(goalID: "goal-created", draftID: "draft-created"),
                        title: "Build a calmer weekly review ritual",
                        subtitle: "A freshly created goal with an immediate deterministic micro-plan.",
                        modeLabel: "Project",
                        posture: .active,
                        renderState: .active,
                        progressValue: 0.08,
                        progressLabel: "3 starter steps created",
                        timingLabel: "Untimed",
                        weekRelationship: "This week this goal is carrying the strongest directional weight.",
                        phaseSummary: "Starter path",
                        milestoneSummary: "0/3 milestones visible",
                        pressureSummary: "The path still has believable momentum.",
                        nextStepHint: "Define scope",
                        priorityLabel: "Priority #1"
                    )
                ]
            ),
            GoalsBoardBand(kind: .pressure, title: "Pressure points", subtitle: "Nothing is loudly off-track right now.", cards: []),
            GoalsBoardBand(kind: .recentMovement, title: "Recent movement", subtitle: "Visible momentum so you can see which ambitions are actually moving.", cards: [])
        ],
        horizonLadder: GoalsHorizonLadderState(
            title: "Horizon ladder",
            subtitle: "A shallow read on where the live goals sit in their phase or path.",
            rungs: [
                GoalsHorizonLadderRung(
                    id: "goal-created",
                    target: GoalRouteTarget(goalID: "goal-created", draftID: "draft-created"),
                    title: "Build a calmer weekly review ritual",
                    summary: "Starter path",
                    milestoneLabel: "0/3 milestones",
                    signalLabel: "Path is moving",
                    highlight: "Define scope",
                    state: .selected
                )
            ]
        ),
        weekPressureSummary: GoalsWeekPressureSummary(
            title: "Direction pressure is calm",
            subtitle: "The board can stay oriented around one live ambition instead of rescue work.",
            leadingMetric: "1 active",
            trailingMetric: "0 stretching thin",
            pill: GoalsHeroPillState(title: "Calm week", icon: "leaf", state: .success)
        ),
        lowerPriority: GoalsLowerPriorityState(
            title: "Lower-priority and closed loops",
            subtitle: "Paused or already-closed goals stay available without competing with live direction pressure.",
            disclosureTitle: "Show quieter goals",
            cards: []
        ),
        lifecycleRail: [
            GoalLifecycleRailSegment(id: "previous", title: "Previous", count: 0, subtitle: "History will stay visible here", state: .default),
            GoalLifecycleRailSegment(id: "active", title: "Active", count: 1, subtitle: "Currently shaping attention", state: .selected),
            GoalLifecycleRailSegment(id: "future", title: "Future", count: 0, subtitle: "No scheduled future goals", state: .default),
        ],
        stateChips: [
            GoalStateChipState(lifecycleState: .protected, count: 1),
            GoalStateChipState(lifecycleState: .waiting, count: 0),
            GoalStateChipState(lifecycleState: .blocked, count: 0),
            GoalStateChipState(lifecycleState: .parked, count: 0),
            GoalStateChipState(lifecycleState: .completed, count: 0),
            GoalStateChipState(lifecycleState: .cancelledDropped, count: 0),
        ],
        atlasPreview: GoalAtlasPreviewState(
            title: "Goal Atlas preview",
            subtitle: "A lightweight grouping by life area. Full path mapping stays owned by later batches.",
            groups: [
                GoalAtlasPreviewGroup(id: "personal_growth", title: "Personal growth", subtitle: "1 goal connected here", items: [
                    GoalAtlasPreviewItem(id: "goal-created", title: "Build a calmer weekly review ritual", subtitle: "Define scope", state: .selected),
                ])
            ]
        ),
        archiveSummary: GoalPortfolioArchiveSummary(
            title: "Archive is quiet",
            subtitle: "Completed, parked, and cancelled goals will remain part of your progress history.",
            chips: [
                GoalStateChipState(lifecycleState: .parked, count: 0),
                GoalStateChipState(lifecycleState: .completed, count: 0),
                GoalStateChipState(lifecycleState: .cancelledDropped, count: 0),
            ],
            learningLines: ["Archive learning will appear after a goal is completed, parked, or closed."]
        ),
        maturitySummary: .empty,
        items: [],
        isSeeded: false,
        emptyTitle: "No goals yet",
        emptyMessage: "Once a goal or planning draft exists, this screen will immediately explain the path, not just dump steps."
    )
}
