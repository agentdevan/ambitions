import AmbitionsDesignSystem
import Foundation

enum PreviewGoalsScenarios {
    static let activeTarget = GoalRouteTarget(goalID: "goal-native", draftID: "draft-native")
    static let starterTarget = GoalRouteTarget(goalID: "goal-learning", draftID: "draft-learning")
    static let clarificationTarget = GoalRouteTarget(draftID: "draft-clarify")
    static let blockedTarget = GoalRouteTarget(draftID: "draft-blocked", launchContext: .help)
    static let supportTarget = GoalRouteTarget(goalID: "goal-support", draftID: "draft-support")
    static let completedTarget = GoalRouteTarget(goalID: "goal-detail-completed")
    static let parkedTarget = GoalRouteTarget(goalID: "goal-detail-parked")
    static let cancelledTarget = GoalRouteTarget(goalID: "goal-detail-cancelled")

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

    static let previewMaturitySummary = GoalPortfolioMaturitySummary(
        title: "Portfolio maturity",
        subtitle: "A qualitative read on scope, proof, stuck work, and what should happen next.",
        scopeSignal: GoalPortfolioMaturitySignal(id: "scope", title: "Scope needs review", detail: "4 live ambitions are active; choose what should stay protected.", state: .warning),
        stuckWorkSignal: GoalPortfolioMaturitySignal(id: "stuck-work", title: "Stuck work is visible", detail: "1 waiting or blocked · 2 crowded or stalled", state: .warning),
        proofSignal: GoalPortfolioMaturitySignal(id: "proof", title: "Proof is thin", detail: "2 live ambitions need a proof point before momentum is easy to trust.", state: .default),
        nextStepSignal: GoalPortfolioMaturitySignal(id: "next-step", title: "Next steps are clear", detail: "Every live ambition has a current next visible step.", state: .selected),
        archiveLearning: [
            "Finish launch checklist: completed with proof visible.",
            "Park the old weekly board: parked so attention can stay honest."
        ],
        accessibilityLabel: "Portfolio maturity",
        accessibilityValue: "Scope needs review. Stuck work is visible. Proof is thin. Next steps are clear.",
        accessibilityHint: "Review scope, stuck work, proof, and next-step clarity before adding more goals."
    )

    static let detailScenarios: [String: GoalDetailPresentation] = [
        activeTarget.id: GoalDetailPresentation(
            target: activeTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Close the hardening pass", subtitle: "Tighten repo truth, validation coverage, and release readiness without widening scope.", renderState: .active, modeLabel: "Project", timingLabel: "Due 2026-05-01", supportLabel: nil),
            outcome: "Keep the shipped app truthful, validated, and ready for a narrower release-readiness pass.",
            intent: "Understand the next hardening step and the proof that the app's claims still hold.",
            progress: GoalDetailProgress(label: "5 of 11 steps landed", detail: "Progress is tracked through current plan steps, docs cleanup, and validation results.", value: 0.46, evidenceLabel: "85 minutes of visible evidence"),
            strategicStatus: GoalDetailStrategicStatus(title: "Path is in motion", summary: "You are in the hardening closeout stage with the next step already surfaced.", supportingDetail: "Manual priority #1 • 46% visible progress"),
            nextMovement: GoalDetailNextMovement(title: "Refresh release docs and trust copy", summary: "Keep You, README, and manual notes aligned with current verified behavior.", timingLabel: "Due 2026-04-15", rationale: "This keeps the release-readiness path honest before broader validation closes out.", state: .selected),
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Truth and trust", phaseSummary: "Repo truth, conservative copy, and release notes are the current chamber.", milestoneSummary: "Refresh release docs and trust copy", momentumSummary: "1 of 2 visible milestones are already moving.", timelineSummary: "The deadline is real, but the path should still stay session-sized. The next step stays small enough to act on without losing the broader path."),
            timingNote: "The deadline is real, but the path should still stay session-sized.",
            progressNote: "The next step stays small enough to act on without losing the broader path.",
            manualPriorityLabel: "Manual priority #1",
            assumptions: [],
            suggestions: [
                GoalDetailStepItem(id: "s1", title: "Refresh release docs and trust copy", summary: "Keep You, README, and manual notes aligned with current verified behavior.", timingLabel: "Due 2026-04-15", statusLabel: "Planned", state: .selected),
                GoalDetailStepItem(id: "s2", title: "Rerun the native validation flow", summary: "Use the existing build and test seams and keep unresolved platform claims conservative.", timingLabel: "Due 2026-04-16", statusLabel: "Planned", state: .default),
            ],
            pathStages: [
                GoalPathStage(id: "p1", title: "Truth and trust", summary: "Repo truth, conservative copy, and release notes", stepCountLabel: "4 steps", position: .current, statusLabel: "Current", highlight: "Refresh release docs and trust copy", state: .selected),
                GoalPathStage(id: "p2", title: "Validation closeout", summary: "Focused verification and manual follow-up notes", stepCountLabel: "3 steps", position: .upcoming, statusLabel: "Upcoming", highlight: "Review manual platform checks", state: .default),
            ],
            sections: [
                GoalDetailSectionState(id: "sec-1", title: "Now", summary: "The highest-leverage work still open.", kindLabel: "Active Steps", steps: [
                    GoalDetailStepItem(id: "s1", title: "Refresh release docs and trust copy", summary: "Keep You, README, and manual notes aligned with current verified behavior.", timingLabel: "Due 2026-04-15", statusLabel: "Planned", state: .selected),
                    GoalDetailStepItem(id: "s2", title: "Rerun the native validation flow", summary: "Use the existing build and test seams and keep unresolved platform claims conservative.", timingLabel: "Due 2026-04-16", statusLabel: "Planned", state: .default),
                ]),
                GoalDetailSectionState(id: "sec-2", title: "Path", summary: "Broader structure beyond the next step.", kindLabel: "Upcoming", steps: [
                    GoalDetailStepItem(id: "s3", title: "Review manual platform checks", summary: "Keep widgets, shortcuts, and notification notes honest about what still needs hands-on verification.", timingLabel: "Due 2026-04-17", statusLabel: "Planned", state: .default),
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
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "Recent movement is visible without turning the screen into a history audit.", items: [
                GoalDetailRecentMovementItem(id: "rm1", title: "Today route state proved out", subtitle: "Session Logged", timestamp: "2026-04-14T11:40:00Z", categoryLabel: "Evidence", state: .success),
                GoalDetailRecentMovementItem(id: "rm2", title: "Asked for smaller step", subtitle: "Reduce the first route task to one deterministic pass.", timestamp: "2026-04-13T15:00:00Z", categoryLabel: "Adjustment", state: .selected),
            ]),
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success),
                GoalDetailActionState(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default),
                GoalDetailActionState(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected),
                GoalDetailActionState(kind: .imStuck, title: "I'm stuck", systemImage: "lifepreserver", state: .warning),
                GoalDetailActionState(kind: .askWhyThisMatters, title: "Why this matters", systemImage: "questionmark.circle", state: .default),
            ],
            explainability: trustHeavyExplainabilityState(),
            primaryStepID: "s1",
            canSwitchToUntimed: false,
            supportModeActive: false,
            defaultLens: .tasks,
            missionControl: previewMissionControl(
                title: "Close the hardening pass",
                currentTruth: "You are in the hardening closeout stage with the next step already surfaced.",
                nextTitle: "Refresh release docs and trust copy",
                proofItems: [
                    GoalEvidenceItem(id: "e1", title: "Today route state proved out", subtitle: "Session Logged", timestamp: "2026-04-14T11:40:00Z", state: .success),
                    GoalEvidenceItem(id: "e2", title: "Goal list structure drafted", subtitle: "Session Logged", timestamp: "2026-04-14T10:25:00Z", state: .success),
                ],
                timelineKind: .current
            )
        ),
        starterTarget.id: GoalDetailPresentation(
            target: starterTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Learn advanced vocal mixing", subtitle: "A learning track that should stay untimed and evidence-based.", renderState: .starter, modeLabel: "Learning", timingLabel: "Untimed", supportLabel: nil),
            outcome: "Build confidence by learning through small, visible experiments rather than deadline pressure.",
            intent: "Stay oriented to signal and learning, not just step completion.",
            progress: GoalDetailProgress(label: "Starter path in motion", detail: "Starter-plan assumptions are being treated as temporary scaffolding.", value: 0.22, evidenceLabel: "No evidence logged yet"),
            strategicStatus: GoalDetailStrategicStatus(title: "Starter path is taking shape", summary: "The path is still provisional, but the first layer already shows where the learning loop stands.", supportingDetail: "Manual priority #2 • 22% visible progress"),
            nextMovement: GoalDetailNextMovement(title: "Record one rough pass", summary: "Capture one take and note the muddiest frequency area.", timingLabel: "Untimed", rationale: "Early signal matters more than polishing the whole system before the first attempt.", state: .selected),
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Starter path", phaseSummary: "Low-pressure first signal", milestoneSummary: "Record one rough pass", momentumSummary: "No evidence logged yet", timelineSummary: "This goal is intentionally untimed, so progress is visible without an artificial countdown. Starter plans are allowed to be provisional while the system learns what actually helps."),
            timingNote: "This goal is intentionally untimed, so progress is visible without an artificial countdown.",
            progressNote: "Starter plans are allowed to be provisional while the system learns what actually helps.",
            manualPriorityLabel: "Manual priority #2",
            assumptions: ["A single rough pass is enough signal.", "You do not need the whole system figured out before the first session."],
            suggestions: [
                GoalDetailStepItem(id: "ls1", title: "Record one rough pass", summary: "Capture one take and note the muddiest frequency area.", timingLabel: "Untimed", statusLabel: "Planned", state: .selected),
            ],
            pathStages: [
                GoalPathStage(id: "lp1", title: "Starter path", summary: "Low-pressure first signal", stepCountLabel: "2 steps", position: .current, statusLabel: "Current", highlight: "Record one rough pass", state: .selected),
            ],
            sections: [
                GoalDetailSectionState(id: "lsec1", title: "Starter path", summary: "Short, safe first steps.", kindLabel: "Overview", steps: [
                    GoalDetailStepItem(id: "ls1", title: "Record one rough pass", summary: "Capture one take and note the muddiest frequency area.", timingLabel: "Untimed", statusLabel: "Planned", state: .selected),
                ]),
            ],
            clarification: nil,
            blocked: nil,
            evidence: [],
            history: [],
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "No evidence logged yet", items: []),
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success),
                GoalDetailActionState(kind: .askForSmallerStep, title: "Smaller step", systemImage: "scissors", state: .selected),
                GoalDetailActionState(kind: .breakThisDownSmaller, title: "Break it down", systemImage: "rectangle.split.3x1", state: .selected),
                GoalDetailActionState(kind: .switchToUntimed, title: "Switch to untimed", systemImage: "calendar.badge.minus", state: .default),
            ],
            explainability: starterExplainabilityState(),
            primaryStepID: "ls1",
            canSwitchToUntimed: false,
            supportModeActive: false,
            defaultLens: .path,
            missionControl: previewMissionControl(
                title: "Learn advanced vocal mixing",
                currentTruth: "The path is still provisional, but the first learning signal is visible.",
                nextTitle: "Record one rough pass",
                proofItems: [],
                timelineKind: .current
            )
        ),
        clarificationTarget.id: GoalDetailPresentation(
            target: clarificationTarget,
            headline: GoalDetailHeadline(eyebrow: "Support Goal", title: "Break this down for someone else", subtitle: "The planner needs one missing detail before the path is trustworthy.", renderState: .clarification, modeLabel: "Support", timingLabel: "Support when helpful", supportLabel: "This path is framed around supporting someone else."),
            outcome: "Build a support plan that helps without taking ownership away from the other person.",
            intent: "The system is protecting plan quality by showing what still needs to be clarified.",
            progress: GoalDetailProgress(label: "Clarification first", detail: "Progress is paused until the missing context is explicit.", value: 0.05, evidenceLabel: "No evidence logged yet"),
            strategicStatus: GoalDetailStrategicStatus(title: "Clarification is the real work right now", summary: "The screen is leading with missing truth so the path can become believable before more decomposition.", supportingDetail: "Manual priority #4 • 5% visible progress"),
            nextMovement: GoalDetailNextMovement(title: "Answer the missing question", summary: "Goal Detail is waiting on one real clarification before it treats the path as trustworthy.", timingLabel: "Before new planning", rationale: "Clarifying the truth matters more than generating more tactics here.", state: .warning),
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Clarification", phaseSummary: "The planner is paused until the missing truth is explicit.", milestoneSummary: "Confirm who this support path is really for", momentumSummary: "No evidence logged yet", timelineSummary: "Support goals should suggest windows, not impose pressure. Clarification comes before decomposition. Ambitions is surfacing the missing information instead of inventing urgency."),
            timingNote: "Support goals should suggest windows, not impose pressure.",
            progressNote: "Clarification comes before decomposition. Ambitions is surfacing the missing information instead of inventing urgency.",
            manualPriorityLabel: "Manual priority #4",
            assumptions: [],
            suggestions: [],
            pathStages: [],
            sections: [],
            clarification: GoalClarificationState(title: "Clarification needed", subtitle: "Ambitions is pausing decomposition until these questions are answered cleanly.", questions: [
                GoalClarificationQuestionState(id: "cq1", field: .executorIdentity, prompt: "Who is this actually for?", rationale: "The planner needs to know whose work is being supported.", gentleDefault: "If unclear, assume you are supporting without taking ownership.", existingAnswer: nil),
                GoalClarificationQuestionState(id: "cq2", field: .successDefinition, prompt: "What visible outcome would matter most?", rationale: "A single success definition leads to a cleaner path.", gentleDefault: "Start with the smallest visible improvement you would notice.", existingAnswer: nil),
            ]),
            blocked: nil,
            evidence: [],
            history: [],
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "No evidence logged yet", items: []),
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .showSupportMode, title: "Support mode", systemImage: "person.2.fill", state: .selected),
            ],
            explainability: nil,
            primaryStepID: nil,
            canSwitchToUntimed: false,
            supportModeActive: true,
            defaultLens: .path,
            missionControl: previewMissionControl(
                title: "Break this down for someone else",
                currentTruth: "The real work is answering the missing support question before planning continues.",
                nextTitle: "Answer the missing question",
                proofItems: [],
                timelineKind: .current,
                riskTitle: "Needs a next step"
            )
        ),
        blockedTarget.id: GoalDetailPresentation(
            target: blockedTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Plan a freelance pivot", subtitle: "The planner is blocked until the real constraint is clarified.", renderState: .blocked, modeLabel: "Exploration", timingLabel: "Flexible window", supportLabel: nil),
            outcome: "Explore whether freelancing is worth pursuing without pretending the path is already clear.",
            intent: "The blocker is explicit so you can resolve the actual constraint instead of performing progress.",
            progress: GoalDetailProgress(label: "Blocked state", detail: "The planner kept the constraint explicit instead of inventing fake steps.", value: 0.04, evidenceLabel: "No evidence logged yet"),
            strategicStatus: GoalDetailStrategicStatus(title: "The path is waiting on a real blocker", summary: "The current stage is visible, but Ambitions is keeping the blocker explicit instead of faking momentum.", supportingDetail: "Manual priority #5 • 4% visible progress"),
            nextMovement: GoalDetailNextMovement(title: "Resolve the blocker", summary: "Unblock the constraint before asking the screen for more decomposition.", timingLabel: "As soon as reality changes", rationale: "Ambitions is refusing to turn uncertainty into performative activity.", state: .warning),
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Blocked planning state", phaseSummary: "The planner kept the constraint explicit instead of generating performative steps.", milestoneSummary: "Define one real success criterion", momentumSummary: "No evidence logged yet", timelineSummary: "The window matters, but the path still stays flexible. The blocker is kept visible so the path can restart cleanly once the missing input arrives."),
            timingNote: "The window matters, but the path still stays flexible.",
            progressNote: "The blocker is kept visible so the path can restart cleanly once the missing input arrives.",
            manualPriorityLabel: "Manual priority #5",
            assumptions: [],
            suggestions: [],
            pathStages: [],
            sections: [],
            clarification: nil,
            blocked: GoalBlockedState(title: "Blocked planning state", subtitle: "The planner kept the blocker explicit instead of generating performative steps.", blockers: ["The decision you are trying to make is still vague.", "The exploration needs one success criterion before decomposition."]),
            evidence: [],
            history: [],
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "No evidence logged yet", items: []),
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
            ],
            explainability: nil,
            primaryStepID: nil,
            canSwitchToUntimed: true,
            supportModeActive: false,
            defaultLens: .path,
            missionControl: previewMissionControl(
                title: "Plan a freelance pivot",
                currentTruth: "The current stage is visible, but the blocker should stay explicit.",
                nextTitle: "Resolve the blocker",
                proofItems: [],
                timelineKind: .waiting,
                riskTitle: "Blocked"
            )
        ),
        supportTarget.id: GoalDetailPresentation(
            target: supportTarget,
            headline: GoalDetailHeadline(eyebrow: "Support Goal", title: "Help Maya rebuild a reading rhythm", subtitle: "Supportive structure that keeps Maya as the owner of execution.", renderState: .active, modeLabel: "Support", timingLabel: "Support window open", supportLabel: "This path is framed around supporting Maya."),
            outcome: "Create consistent reading support for Maya without turning the relationship into compliance work.",
            intent: "Support Maya with structure that stays collaborative and non-punitive.",
            progress: GoalDetailProgress(label: "2 of 7 support steps landed", detail: "Progress is reading the real persisted plan and evidence history.", value: 0.31, evidenceLabel: "45 minutes of visible evidence"),
            strategicStatus: GoalDetailStrategicStatus(title: "Support path is in motion", summary: "You are in the support rhythm stage, with the next step already surfaced.", supportingDetail: "Manual priority #3 • 31% visible progress"),
            nextMovement: GoalDetailNextMovement(title: "Set up one calm reading check-in", summary: "Invite Maya to choose the time and the book.", timingLabel: "Support window open", rationale: "This keeps the support path collaborative without taking ownership away from Maya.", state: .selected),
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Support rhythm", phaseSummary: "Create repeatable, calm support loops", milestoneSummary: "Set up one calm reading check-in", momentumSummary: "45 minutes of visible evidence", timelineSummary: "Support goals should suggest windows, not impose pressure. Support goals stay non-punitive. Progress reflects what you can support, not what you can force."),
            timingNote: "Support goals should suggest windows, not impose pressure.",
            progressNote: "Support goals stay non-punitive. Progress reflects what you can support, not what you can force.",
            manualPriorityLabel: "Manual priority #3",
            assumptions: [],
            suggestions: [
                GoalDetailStepItem(id: "ss1", title: "Set up one calm reading check-in", summary: "Invite Maya to choose the time and the book.", timingLabel: "Support window open", statusLabel: "Planned", state: .selected),
            ],
            pathStages: [
                GoalPathStage(id: "sp1", title: "Support rhythm", summary: "Create repeatable, calm support loops", stepCountLabel: "3 steps", position: .current, statusLabel: "Current", highlight: "Set up one calm reading check-in", state: .selected),
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
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "Recent movement is visible without turning the screen into a history audit.", items: [
                GoalDetailRecentMovementItem(id: "srm1", title: "Last check-in felt collaborative", subtitle: "Delegated Update", timestamp: "2026-04-13T18:00:00Z", categoryLabel: "Evidence", state: .success),
            ]),
            actions: [
                GoalDetailActionState(kind: .showPath, title: "Show the path", systemImage: "square.split.2x2", state: .default),
                GoalDetailActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success),
                GoalDetailActionState(kind: .showSupportMode, title: "Support mode", systemImage: "person.2.fill", state: .selected),
            ],
            explainability: supportExplainabilityState(),
            primaryStepID: "ss1",
            canSwitchToUntimed: true,
            supportModeActive: true,
            defaultLens: .path,
            missionControl: previewMissionControl(
                title: "Help Maya rebuild a reading rhythm",
                currentTruth: "The support path is in motion and stays collaborative.",
                nextTitle: "Set up one calm reading check-in",
                proofItems: [
                    GoalEvidenceItem(id: "se1", title: "Last check-in felt collaborative", subtitle: "Delegated Update", timestamp: "2026-04-13T18:00:00Z", state: .success),
                ],
                timelineKind: .current
            )
        ),
        completedTarget.id: GoalDetailPresentation(
            target: completedTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Stabilize the five-tab shell", subtitle: "The shell loop is closed and preserved as learning.", renderState: .achieved, modeLabel: "Achievement", timingLabel: "Completed", supportLabel: nil),
            outcome: "The shell is complete.",
            intent: "Keep the completed story readable without competing for attention.",
            progress: GoalDetailProgress(label: "Complete", detail: "Closed work stays visible.", value: 1, evidenceLabel: "Proof visible"),
            strategicStatus: GoalDetailStrategicStatus(title: "Completed", summary: "This goal is complete and no longer needs a next step.", supportingDetail: "Closed loop"),
            nextMovement: nil,
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Completed", phaseSummary: "The loop is closed.", milestoneSummary: "All milestones landed", momentumSummary: "Proof visible", timelineSummary: "Completed goals stay part of the story."),
            timingNote: "Completed",
            progressNote: "Closed work stays visible.",
            manualPriorityLabel: "Archive",
            assumptions: [],
            suggestions: [],
            pathStages: [],
            sections: [],
            clarification: nil,
            blocked: nil,
            evidence: [],
            history: [],
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "Closed loop", items: []),
            actions: [],
            explainability: nil,
            primaryStepID: nil,
            canSwitchToUntimed: false,
            supportModeActive: false,
            defaultLens: .path,
            missionControl: previewMissionControl(title: "Stabilize the five-tab shell", currentTruth: "This goal is complete and preserved.", nextTitle: "No next step needed", proofItems: [], timelineKind: .completed)
        ),
        parkedTarget.id: GoalDetailPresentation(
            target: parkedTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Refresh the onboarding copy", subtitle: "Useful later, deliberately quiet now.", renderState: .onHold, modeLabel: "Maintenance", timingLabel: "Parked", supportLabel: nil),
            outcome: "Keep this parked until the current goals flow is settled.",
            intent: "Do not let quiet work compete with live direction.",
            progress: GoalDetailProgress(label: "Parked", detail: "Paused work is not failure.", value: 0.12, evidenceLabel: "No proof yet"),
            strategicStatus: GoalDetailStrategicStatus(title: "Parked", summary: "This goal is intentionally quiet.", supportingDetail: "Archive"),
            nextMovement: nil,
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Parked", phaseSummary: "Intentionally quiet.", milestoneSummary: "Revisit later", momentumSummary: "No proof yet", timelineSummary: "Parked goals remain findable."),
            timingNote: "Parked",
            progressNote: "Paused work is not failure.",
            manualPriorityLabel: "Archive",
            assumptions: [],
            suggestions: [],
            pathStages: [],
            sections: [],
            clarification: nil,
            blocked: nil,
            evidence: [],
            history: [],
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "No recent movement", items: []),
            actions: [],
            explainability: nil,
            primaryStepID: nil,
            canSwitchToUntimed: false,
            supportModeActive: false,
            defaultLens: .path,
            missionControl: previewMissionControl(title: "Refresh the onboarding copy", currentTruth: "This goal is intentionally quiet.", nextTitle: "Revisit later", proofItems: [], timelineKind: .parked)
        ),
        cancelledTarget.id: GoalDetailPresentation(
            target: cancelledTarget,
            headline: GoalDetailHeadline(eyebrow: "Goal Detail", title: "Retire stale experiment", subtitle: "Closed because it no longer fits the current direction.", renderState: .onHold, modeLabel: "Exploration", timingLabel: "Cancelled", supportLabel: nil),
            outcome: "The experiment is closed.",
            intent: "Preserve what changed without treating it as active work.",
            progress: GoalDetailProgress(label: "Cancelled", detail: "Closed without a next step.", value: 0, evidenceLabel: "No proof yet"),
            strategicStatus: GoalDetailStrategicStatus(title: "Cancelled", summary: "This goal is closed and should not compete for attention.", supportingDetail: "Archive"),
            nextMovement: nil,
            trajectory: GoalDetailTrajectoryState(phaseTitle: "Cancelled", phaseSummary: "Closed exploration.", milestoneSummary: "No next milestone", momentumSummary: "No proof yet", timelineSummary: "Cancelled goals remain part of the record."),
            timingNote: "Cancelled",
            progressNote: "Closed without a next step.",
            manualPriorityLabel: "Archive",
            assumptions: [],
            suggestions: [],
            pathStages: [],
            sections: [],
            clarification: nil,
            blocked: nil,
            evidence: [],
            history: [],
            recentMovement: GoalDetailRecentMovementState(title: "Recent movement", summary: "No recent movement", items: []),
            actions: [],
            explainability: nil,
            primaryStepID: nil,
            canSwitchToUntimed: false,
            supportModeActive: false,
            defaultLens: .path,
            missionControl: previewMissionControl(title: "Retire stale experiment", currentTruth: "This goal is closed and preserved.", nextTitle: "No next step needed", proofItems: [], timelineKind: .cancelled)
        ),
    ]

    private static func previewMissionControl(
        title: String,
        currentTruth: String,
        nextTitle: String,
        proofItems: [GoalEvidenceItem],
        timelineKind: GoalDetailTimelineItemKind,
        riskTitle: String = "No major visible risk"
    ) -> GoalDetailMissionControlState {
        let hasProof = proofItems.isEmpty == false
        let riskIsCalm = riskTitle == "No major visible risk"
        let nextAvailable = nextTitle != "No next step needed"
        let proofHeadline = hasProof ? "\(proofItems.count) proof point\(proofItems.count == 1 ? "" : "s")" : "No proof yet"
        let proofBeads = proofItems.map { item in
            ProofBead(
                id: item.id,
                title: item.title,
                summary: item.subtitle,
                sourceLabel: "Source: Preview proof",
                freshness: .fresh,
                privacyLabel: "Preview proof stays local.",
                timestampLabel: item.timestamp,
                correctionLabel: "Correction can be reviewed from the proof source."
            )
        }
        let riskItems = riskIsCalm ? [] : [
            GoalDetailRiskState(
                id: "preview-risk-\(title)",
                title: riskTitle,
                summary: "This goal needs review before more planning.",
                state: .warning
            )
        ]
        let archiveState = GoalDetailArchiveState(
            title: timelineKind == .completed ? "Completed" : timelineKind == .cancelled ? "Archived" : timelineKind == .parked ? "Parked" : "Archive ready",
            statusLabel: timelineKind == .completed ? "Completed" : timelineKind == .cancelled ? "Closed" : timelineKind == .parked ? "Review later" : "Active",
            summary: timelineKind == .completed ? "This goal is complete and preserved." : timelineKind == .cancelled ? "This goal is closed without being treated as failure." : timelineKind == .parked ? "This goal is intentionally quiet for now." : "Archive learning will appear when this goal is parked, completed, or closed.",
            learning: timelineKind == .completed ? "Latest proof stays attached when available." : "Nothing needs to be archived right now.",
            state: timelineKind == .completed ? .success : timelineKind == .parked ? .default : .selected
        )
        return GoalDetailMissionControlState(
            currentTruth: currentTruth,
            primaryNextMove: GoalNextVisibleStep(
                title: nextTitle,
                detail: nextAvailable ? "Keep this as the primary contained Step." : "This goal is not asking for action.",
                isAvailable: nextAvailable
            ),
            sourceLabel: "Based on this goal",
            proofBoundaryLabel: hasProof ? "Proof stays attached to this goal" : "Proof is visible when saved",
            ownershipLabel: "You own the path",
            breadcrumb: GoalDetailBreadcrumbState(title: "Path", labels: ["Career", title], fallbackUsed: false),
            lanes: [
                GoalDetailMissionLaneState(kind: .overview, title: "Overview", headline: timelineKind.title, summary: currentTruth, detail: "Next: \(nextTitle)", badgeTitle: "State", systemImage: "rectangle.and.text.magnifyingglass", state: .selected),
                GoalDetailMissionLaneState(kind: .path, title: "Path", headline: "Current phase", summary: "Next milestone: \(nextTitle)", detail: "Preview path data is bounded to this goal.", badgeTitle: "Current", systemImage: "point.topleft.down.curvedto.point.bottomright.up", state: .selected),
                GoalDetailMissionLaneState(kind: .steps, title: "Steps", headline: nextTitle, summary: nextAvailable ? "Keep this as the primary contained Step." : "No action is needed right now.", detail: "", badgeTitle: nextAvailable ? "Next step" : "Closed", systemImage: "scope", state: nextAvailable ? .selected : .default),
                GoalDetailMissionLaneState(kind: .proof, title: "Proof", headline: proofHeadline, summary: hasProof ? "Evidence is visible." : "Needs evidence", detail: proofItems.first.map { "Latest: \($0.title)" } ?? "No proof has been recorded for this goal yet.", badgeTitle: hasProof ? "Evidence visible" : "No proof yet", systemImage: "checkmark.seal", state: hasProof ? .selected : .default),
                GoalDetailMissionLaneState(kind: .decisions, title: "Decisions", headline: "No decisions yet", summary: "Decision trail stays here when this goal changes.", detail: "", badgeTitle: "No decisions", systemImage: "arrow.triangle.branch", state: .default),
                GoalDetailMissionLaneState(kind: .risks, title: "Risks", headline: riskItems.first?.title ?? "No major risk visible", summary: riskItems.first?.summary ?? "Nothing in this preview is asking for rescue.", detail: "", badgeTitle: riskIsCalm ? "Calm" : "Needs review", systemImage: "exclamationmark.triangle", state: riskIsCalm ? .success : .warning),
                GoalDetailMissionLaneState(kind: .archive, title: "Archive", headline: archiveState.title, summary: archiveState.summary, detail: archiveState.learning, badgeTitle: archiveState.statusLabel, systemImage: "archivebox", state: archiveState.state),
            ],
            timeline: GoalDetailTimelineState(
                title: "Storyline",
                subtitle: "A compact read on what happened, what is current, and what is only a possible next step.",
                items: [
                    GoalDetailTimelineItemState(id: "started-\(title)", kind: .started, title: "Started", summary: "Preview start", timestamp: nil, state: .default, isFuture: false),
                    GoalDetailTimelineItemState(id: "current-\(title)", kind: timelineKind, title: timelineKind.title, summary: currentTruth, timestamp: nil, state: timelineKind == .completed ? .success : timelineKind == .waiting ? .warning : .default, isFuture: false),
                    GoalDetailTimelineItemState(id: "next-\(title)", kind: .next, title: nextTitle, summary: nextAvailable ? "Possible next step." : "No future certainty is claimed.", timestamp: nil, state: nextAvailable ? .selected : .default, isFuture: nextAvailable),
                ]
            ),
            assumptions: [
                GoalDetailAssumptionState(id: "next-step", title: "This goal has a next step.", status: nextAvailable ? "Visible" : "Closed", whyItMatters: "The screen should lead with one step, not a long step dump.", correctionLabel: nextAvailable ? "Change next step" : nil, state: nextAvailable ? .selected : .default),
                GoalDetailAssumptionState(id: "proof", title: "This goal has enough proof.", status: hasProof ? "Proof visible" : "No proof yet", whyItMatters: "Progress should be backed by something observable.", correctionLabel: "Add proof later", state: hasProof ? .selected : .default),
            ],
            proofRail: GoalDetailProofRailState(title: "Proof", subtitle: hasProof ? "Proof keeps source, freshness, privacy, correction, and review visible." : "Evidence will appear here when it is recorded.", items: proofItems, spineBeads: proofBeads, emptyTitle: "No proof yet", emptyMessage: "Add proof later when there is something real to show."),
            decisions: GoalDetailDecisionsState(title: "Decisions", subtitle: "Decision trail stays here when this goal changes.", items: [], emptyTitle: "No decisions yet", emptyMessage: "When you change, park, or explain this goal, the reason will stay visible here."),
            risks: GoalDetailRisksState(title: "Risks", subtitle: riskItems.isEmpty ? "No major risk is visible from this goal data." : "Risks stay explicit so recovery can stay calm.", items: riskItems, emptyTitle: "No major risk visible", emptyMessage: "Nothing in this goal is asking for rescue right now."),
            archive: archiveState,
            receipts: GoalDetailReceiptsState(title: "What changed", subtitle: "Goal-related receipts stay visible here when the current data source provides them.", items: [], emptyTitle: "No receipts yet", emptyMessage: "Receipts will appear here after goal changes are recorded.")
        )
    }

    private static func trustHeavyExplainabilityState() -> GoalExplainabilityState {
        GoalExplainabilityState(
            whisper: GoalTrustWhisperState(
                title: "Trust whisper",
                subtitle: "This recommendation is leading because the release-readiness path is tight and the copy drift is still fresh.",
                pillLine: "Likely fit • Waiting on newer input • Some source context needs review",
                pills: [
                    GoalTrustWhisperPillState(id: "confidence", title: "Likely fit", icon: "checkmark.shield", state: .selected),
                    GoalTrustWhisperPillState(id: "freshness", title: "Waiting on newer input", icon: "clock.badge.exclamationmark", state: .warning),
                    GoalTrustWhisperPillState(id: "sources", title: "Some source context needs review", icon: "text.magnifyingglass", state: .warning),
                    GoalTrustWhisperPillState(id: "contradictions", title: "1 conflict needs review", icon: "exclamationmark.bubble", state: .warning)
                ]
            ),
            whyThis: GoalWhyThisState(
                compactSummary: "The release-readiness path is still being shaped around the smallest truthful documentation fix.",
                lines: [
                    "Interpretation: Docs and trust copy are still the leverage point.",
                    "Path: Refreshing copy unlocks cleaner validation and calmer handoff.",
                    "Now: Newer platform checks could still change what the app should claim."
                ]
            ),
            sourceAudit: GoalSourceAuditSectionState(rows: [
                GoalSourceAuditRowState(
                    id: "source-1",
                    resourceID: "resource-1",
                    title: "Manual platform verification notes",
                    subtitle: "Unsigned release evidence",
                    detailLabels: ["Provenance: Manual", "Trust: Medium", "Freshness: Stale"],
                    state: .warning
                ),
                GoalSourceAuditRowState(
                    id: "source-2",
                    resourceID: "resource-2",
                    title: "You trust copy",
                    subtitle: "Repo-local source of truth",
                    detailLabels: ["Provenance: Local", "Trust: High", "Freshness: Fresh"],
                    state: .default
                )
            ]),
            freshness: GoalFreshnessState(
                posture: .stale,
                postureLabel: "Stale",
                severityLabel: "Warning",
                detailLabels: ["Flag: manual_follow_up"]
            ),
            confidence: GoalConfidenceState(
                understandingConfidence: .medium,
                pathConfidence: .medium,
                detailLabels: ["Understanding: Medium", "Path: Medium", "Uncertainty: manual verification"]
            ),
            contradictions: [
                GoalContradictionSummaryState(
                    id: "contradiction-1",
                    code: .inputTimingConflict,
                    title: "Outdated verification",
                    summary: "The release note and the latest manual follow-up no longer fully agree.",
                    severityLabel: "Blocking",
                    state: .warning
                )
            ],
            correctionControls: [
                GoalCorrectionControlState(
                    id: "control-1",
                    title: "Update this assumption",
                    subtitle: "The release note should stay conservative until the next manual check lands.",
                    kind: .dismissContradiction,
                    artifactKind: .contradictionShape,
                    teachingSignalKind: .contradictionDispositionCorrection,
                    payload: .contradictionDisposition(
                        GoalTeachingContradictionDispositionCorrection(correctedDisposition: .dismissed)
                    ),
                    target: GoalTeachingCaptureTarget(
                        artifactKind: .contradictionShape,
                        candidateID: "candidate-1",
                        stageID: "stage-1",
                        contradictionCode: .inputTimingConflict,
                        contradictionArtifactRefs: []
                    ),
                    state: .warning
                )
            ],
            appliedTeachingBadges: [
                GoalAppliedTeachingBadgeState(
                    id: "badge-1",
                    signalID: "signal-1",
                    title: "Support Not Relevant",
                    subtitle: "Previous correction kept copy conservative.",
                    state: .selected
                )
            ]
        )
    }

    private static func starterExplainabilityState() -> GoalExplainabilityState {
        GoalExplainabilityState(
            whisper: GoalTrustWhisperState(
                title: "Trust whisper",
                subtitle: "This starter path is deliberately light because the first real signal matters more than overexplaining.",
                pillLine: "Needs confirmation • Updated recently • Source context looks stable",
                pills: [
                    GoalTrustWhisperPillState(id: "confidence", title: "Needs confirmation", icon: "checkmark.shield", state: .warning),
                    GoalTrustWhisperPillState(id: "freshness", title: "Updated recently", icon: "clock.arrow.circlepath", state: .success),
                    GoalTrustWhisperPillState(id: "sources", title: "Source context looks stable", icon: "text.magnifyingglass", state: .success),
                    GoalTrustWhisperPillState(id: "contradictions", title: "No conflicts surfaced", icon: "checkmark.circle", state: .success)
                ]
            ),
            whyThis: GoalWhyThisState(
                compactSummary: "The first experiment stays small so the goal can learn from real evidence instead of imaginary certainty.",
                lines: [
                    "Interpretation: Learning goals should start with low-pressure signal.",
                    "Path: One rough pass will teach more than overplanning."
                ]
            ),
            sourceAudit: GoalSourceAuditSectionState(rows: []),
            freshness: GoalFreshnessState(posture: .currentEnough, postureLabel: "Fresh", severityLabel: "Light", detailLabels: ["Flag: none"]),
            confidence: GoalConfidenceState(understandingConfidence: .low, pathConfidence: .low, detailLabels: ["Understanding: Low", "Path: Low"]),
            contradictions: [],
            correctionControls: [],
            appliedTeachingBadges: []
        )
    }

    private static func supportExplainabilityState() -> GoalExplainabilityState {
        GoalExplainabilityState(
            whisper: GoalTrustWhisperState(
                title: "Trust whisper",
                subtitle: "This support path is leading with collaborative posture so the plan stays helpful without taking ownership.",
                pillLine: "Strong fit • Updated recently • Source context looks stable",
                pills: [
                    GoalTrustWhisperPillState(id: "confidence", title: "Strong fit", icon: "checkmark.shield", state: .success),
                    GoalTrustWhisperPillState(id: "freshness", title: "Updated recently", icon: "clock.arrow.circlepath", state: .success),
                    GoalTrustWhisperPillState(id: "sources", title: "Source context looks stable", icon: "text.magnifyingglass", state: .success),
                    GoalTrustWhisperPillState(id: "contradictions", title: "No conflicts surfaced", icon: "checkmark.circle", state: .success)
                ]
            ),
            whyThis: GoalWhyThisState(
                compactSummary: "The next step stays collaborative because support goals should keep the other person as the real owner.",
                lines: [
                    "Interpretation: This is a support path, not delegated compliance.",
                    "Path: A calm check-in preserves momentum without pressure."
                ]
            ),
            sourceAudit: GoalSourceAuditSectionState(rows: []),
            freshness: GoalFreshnessState(posture: .currentEnough, postureLabel: "Fresh", severityLabel: "Light", detailLabels: ["Flag: none"]),
            confidence: GoalConfidenceState(understandingConfidence: .high, pathConfidence: .high, detailLabels: ["Understanding: High", "Path: High"]),
            contradictions: [],
            correctionControls: [],
            appliedTeachingBadges: []
        )
    }

    private static func card(
        id: String,
        target: GoalRouteTarget,
        title: String,
        subtitle: String,
        modeLabel: String,
        posture: GoalsBoardPosture,
        renderState: GoalRenderState,
        progressValue: Double,
        progressLabel: String,
        timingLabel: String,
        weekRelationship: String,
        phaseSummary: String,
        milestoneSummary: String,
        pressureSummary: String,
        nextStepHint: String,
        lifecycleState: GoalPortfolioLifecycleState = .active,
        weather: GoalWeatherState = .clear,
        proofSummary: GoalProofSummary = GoalProofSummary(title: "2 proof points", detail: "Last proof: Goal list structure drafted", count: 2, latestTitle: "Goal list structure drafted", visualState: .selected),
        momentumIntegrity: GoalMomentumIntegrity = GoalMomentumIntegrity(title: "Building proof", detail: "Evidence and a next step both exist.", visualState: .selected),
        supportLabel: String? = nil,
        priorityLabel: String
    ) -> GoalsBoardCardState {
        let nextVisibleStep = GoalNextVisibleStep(title: nextStepHint, detail: "soon · proof useful", isAvailable: true)
        return GoalsBoardCardState(
            id: id,
            target: target,
            title: title,
            subtitle: subtitle,
            modeLabel: modeLabel,
            posture: posture,
            renderState: renderState,
            progressValue: progressValue,
            progressLabel: progressLabel,
            timingLabel: timingLabel,
            weekRelationship: weekRelationship,
            phaseSummary: phaseSummary,
            milestoneSummary: milestoneSummary,
            pressureSummary: pressureSummary,
            nextStepHint: nextStepHint,
            lifecycleState: lifecycleState,
            weather: weather,
            weatherSummary: weather == .clear ? "Proof and the next step are visible." : "This goal needs attention.",
            proofSummary: proofSummary,
            nextVisibleStep: nextVisibleStep,
            momentumIntegrity: momentumIntegrity,
            supportLabel: supportLabel,
            priorityLabel: priorityLabel,
            manualPriorityRank: Int(priorityLabel.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) ?? 0,
            shellSummary: nil
        )
    }
}
