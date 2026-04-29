import AmbitionsDesignSystem
import Foundation

struct PreviewFixtures: Sendable {
    let preferences: AppPreferences
    let todayDashboard: TodayDashboard
    let captures: [Capture]
    let goalsDashboard: GoalsDashboard
    let habitsDashboard: HabitsDashboard
    let insightsDashboard: InsightsDashboard
    let profileDashboard: ProfileDashboard

    static let `default` = PreviewFixtures(
        preferences: AppPreferences(
            preferredTab: .today,
            userDisplayName: "Preview User",
            appearancePreference: .system,
            accentFamily: .sage
        ),
        todayDashboard: TodayDashboard(
            title: "Steady execution, light load",
            subtitle: "Three deliberate moves are enough to keep momentum today.",
            completionLabel: "58% aligned",
            targets: [
                DashboardProgressItem(id: "today-1", title: "Tighten external-surface truth", detail: "Keep docs, You, and previews aligned", progress: 0.82, trailingValue: "82%", statusLabel: "In flight"),
                DashboardProgressItem(id: "today-2", title: "Review validation coverage", detail: "Keep routing, trust copy, and EventKit checks current", progress: 0.45, trailingValue: "45%", statusLabel: "Queued"),
                DashboardProgressItem(id: "today-3", title: "Prepare release notes", detail: "Make local build and test guidance reproducible", progress: 0.67, trailingValue: "67%", statusLabel: "Ready")
            ],
            focus: FocusSession(
                headline: "Keep the hardening pass honest",
                subtitle: "Reduce drift, keep scope tight, and only certify what we can prove",
                reason: "The fastest way to protect trust is to align copy, validation, and release notes with the product that actually ships today.",
                durationLabel: "45 min block",
                energyLabel: "Confidence",
                progress: 0.74,
                supportSteps: [
                    "Refresh external-surface status copy where it drifted.",
                    "Keep previews obviously non-production but current.",
                    "Use the existing build and test seams before widening scope."
                ]
            ),
            freeTime: FreeTimeSuggestion(
                title: "Recovery window available",
                subtitle: "You have margin after the validation pass.",
                windowLabel: "30 min free",
                suggestionTitle: "Review the conservative trust notes",
                suggestionDetail: "Use the spare window to confirm which external surfaces are proven here and which still need manual follow-up."
            )
        ),
        captures: [
            Capture(
                id: "preview-capture-1",
                createdAt: "2026-04-15T09:20:00Z",
                updatedAt: "2026-04-15T09:20:00Z",
                rawText: "Capture the repo-truth drift before the next docs pass.",
                sourceType: .todayQuickCapture,
                status: .goalBound,
                linkedGoalID: "goal-native",
                triage: CaptureTriageMetadata(destination: .attachToGoal, hint: "Keep with the hardening pass.")
            ),
            Capture(
                id: "preview-capture-2",
                createdAt: "2026-04-15T08:15:00Z",
                updatedAt: "2026-04-15T08:30:00Z",
                rawText: "Review the notification handoff copy before the next hardening pass.",
                sourceType: .notification,
                status: .seed,
                linkedGoalID: nil,
                triage: CaptureTriageMetadata(destination: .saveAsSeed),
                revisitAfter: "2026-04-22T09:00:00Z"
            )
        ],
        goalsDashboard: GoalsDashboard(
            title: "Active ambitions",
            subtitle: "Three outcome tracks are currently shaping the week.",
            goals: [
                GoalSummary(id: "goal-native", title: "Close the hardening pass", subtitle: "Repo truth, validation coverage, and release readiness", progressLabel: "Hardening", statusLabel: "Highest leverage"),
                GoalSummary(id: "goal-learning", title: "Learn advanced vocal mixing", subtitle: "A learning track that stays untimed and evidence-based", progressLabel: "Starter path", statusLabel: "In motion"),
                GoalSummary(id: "goal-support", title: "Help Maya rebuild a reading rhythm", subtitle: "Supportive structure that keeps Maya as the owner", progressLabel: "Support rhythm", statusLabel: "Active")
            ],
            milestone: MilestonePrompt(
                title: "Keep the next validation step obvious",
                subtitle: "The app already ships the current shell; this pass keeps trust and release notes aligned.",
                prompt: "Once the truth sweep is clean, rerun the native validation flow and keep any remaining platform claims conservative.",
                confidenceLabel: "Clear next step"
            )
        ),
        habitsDashboard: PreviewHabitsScenarios.seeded,
        insightsDashboard: InsightsDashboard(
            title: "Reflection OS",
            subtitle: "A calm narrative read on what your behavior is teaching the system right now.",
            posture: InsightsPostureSummary(
                title: "Adaptation is helping the plan stay believable",
                detail: "Corrections and smaller versions are turning into visible follow-through instead of churn.",
                label: "Adapting",
                visualState: .selected
            ),
            hero: InsightsHeroState(
                eyebrow: "What you are learning",
                title: "Adaptation is helping the plan stay believable",
                subtitle: "Reflection stays calm, specific, and close to the work instead of drifting into analytics theater.",
                dominantTruth: "Smaller versions are carrying momentum more reliably than bigger plans.",
                editorialSummary: "What changed recently is not just activity volume. The system is learning which lighter asks still create proof.",
                trustWhisper: "This changed after recent feedback and still has visible proof.",
                postureLabel: "Adapting",
                visualState: .selected,
                contextPills: [
                    InsightsHeroPill(id: "preview-hero-1", title: "2 more than last week", icon: "calendar", visualState: .default),
                    InsightsHeroPill(id: "preview-hero-2", title: "4 visible wins", icon: "checkmark.circle.fill", visualState: .success),
                    InsightsHeroPill(id: "preview-hero-3", title: "1 friction signal", icon: "waveform.path.ecg", visualState: .warning),
                    InsightsHeroPill(id: "preview-hero-4", title: "More proof than last week", icon: "arrow.up.right", visualState: .selected)
                ],
                primaryAction: InsightsHeroAction(
                    title: "Open deeper history",
                    subtitle: "Review the evidence and corrections carrying the current read.",
                    systemImage: "clock.arrow.circlepath",
                    visualState: .selected,
                    goalTarget: nil,
                    planRoute: nil,
                    insightsRoute: .history
                )
            ),
            continuityRibbon: InsightsContinuityRibbon(
                title: "Smaller versions are keeping the plan believable",
                detail: "That learning should stay visible when you move back into shaping.",
                icon: "leaf.fill",
                visualState: .selected,
                goalTarget: nil,
                planRoute: .weeklyReview,
                insightsRoute: nil
            ),
            stats: [
                MetricSummary(id: "insight-1", title: "Follow-through", value: "4", detail: "Completions and minimum versions this week", icon: "checkmark.circle"),
                MetricSummary(id: "insight-2", title: "Consistency", value: "63%", detail: "Ritual rhythm this week", icon: "repeat"),
                MetricSummary(id: "insight-3", title: "Adaptation", value: "Building", detail: "How quickly corrections turned back into movement", icon: "arrow.triangle.branch"),
                MetricSummary(id: "insight-4", title: "Needs care", value: "1", detail: "Open clarification or blocked drafts", icon: "lifepreserver")
            ],
            summary: "Recent adaptation works best when the next step stays small, explicit, and grounded in visible evidence.",
            changeSummaries: [
                InsightsChangeSummary(id: "insight-change-1", title: "Plan changes", detail: "Feedback is actively changing how the plan is being carried this week.", valueLabel: "2", icon: "arrow.triangle.branch", visualState: .selected),
                InsightsChangeSummary(id: "insight-change-2", title: "Drift and friction", detail: "Recent friction is the clearest reason some work needs gentler scope.", valueLabel: "1", icon: "waveform.path.ecg", visualState: .warning),
                InsightsChangeSummary(id: "insight-change-3", title: "Goals needing care", detail: "One active area still needs clarification before it can be trusted fully.", valueLabel: "1", icon: "lifepreserver", visualState: .warning),
                InsightsChangeSummary(id: "insight-change-4", title: "Visible follow-through", detail: "Completions and minimum versions are carrying the most useful signal right now.", valueLabel: "4", icon: "checkmark.circle", visualState: .success)
            ],
            goalStatuses: [
                InsightsGoalStatusItem(id: "insight-goal-1", target: GoalRouteTarget(goalID: "goal-native"), title: "Close the hardening pass", summary: "This goal has visible evidence this week, which keeps its current path grounded in real follow-through.", statusLabel: "Believable", visualState: .success),
                InsightsGoalStatusItem(id: "insight-goal-2", target: GoalRouteTarget(goalID: "goal-growth"), title: "Retention loop", summary: "Recent friction suggests the current version of the work needs a smaller or clearer next move.", statusLabel: "Adjusting", visualState: .selected)
            ],
            comparePeriod: InsightsComparePeriodState(
                title: "Compare periods",
                subtitle: "Compact contrast keeps the reflection layer grounded without turning the screen into a BI panel.",
                summary: "The system is seeing steadier proof than last week without a matching rise in friction.",
                metrics: [
                    InsightsCompareMetric(id: "preview-compare-1", title: "Visible follow-through", currentLabel: "4", previousLabel: "2", deltaLabel: "2 more than last week", visualState: .success),
                    InsightsCompareMetric(id: "preview-compare-2", title: "Friction", currentLabel: "1", previousLabel: "2", deltaLabel: "1 softer than last week", visualState: .selected),
                    InsightsCompareMetric(id: "preview-compare-3", title: "Adaptation", currentLabel: "2", previousLabel: "1", deltaLabel: "1 more visible adaptation", visualState: .selected)
                ]
            ),
            patternClusters: [
                InsightsPatternCluster(id: "preview-pattern-1", title: "Momentum", summary: "Momentum is strongest when the next step stays small enough to be seen clearly.", emphasisLabel: "Building", deltaLabel: "2 more visible than last week", visualState: .success, points: [
                    TrendPoint(id: "pm1", label: "M", value: 0.32),
                    TrendPoint(id: "pm2", label: "T", value: 0.44),
                    TrendPoint(id: "pm3", label: "W", value: 0.58),
                    TrendPoint(id: "pm4", label: "T", value: 0.61),
                    TrendPoint(id: "pm5", label: "F", value: 0.79),
                    TrendPoint(id: "pm6", label: "S", value: 0.48),
                    TrendPoint(id: "pm7", label: "S", value: 0.73)
                ], goalTarget: GoalRouteTarget(goalID: "goal-native"), planRoute: nil),
                InsightsPatternCluster(id: "preview-pattern-2", title: "Drift", summary: "Drift is showing up as friction around one active area, not as a full portfolio collapse.", emphasisLabel: "Needs room", deltaLabel: "1 lighter than last week", visualState: .warning, points: [
                    TrendPoint(id: "pd1", label: "M", value: 0.62),
                    TrendPoint(id: "pd2", label: "T", value: 0.44),
                    TrendPoint(id: "pd3", label: "W", value: 0.52),
                    TrendPoint(id: "pd4", label: "T", value: 0.35),
                    TrendPoint(id: "pd5", label: "F", value: 0.41),
                    TrendPoint(id: "pd6", label: "S", value: 0.26),
                    TrendPoint(id: "pd7", label: "S", value: 0.29)
                ], goalTarget: GoalRouteTarget(goalID: "goal-growth"), planRoute: .weeklyReview),
                InsightsPatternCluster(id: "preview-pattern-3", title: "Adaptation", summary: "The plan is learning through lighter versions rather than pretending the first draft was perfect.", emphasisLabel: "Adapting", deltaLabel: "1 more active than last week", visualState: .selected, points: [
                    TrendPoint(id: "pa1", label: "M", value: 0.18),
                    TrendPoint(id: "pa2", label: "T", value: 0.24),
                    TrendPoint(id: "pa3", label: "W", value: 0.46),
                    TrendPoint(id: "pa4", label: "T", value: 0.58),
                    TrendPoint(id: "pa5", label: "F", value: 0.66),
                    TrendPoint(id: "pa6", label: "S", value: 0.49),
                    TrendPoint(id: "pa7", label: "S", value: 0.62)
                ], goalTarget: nil, planRoute: .weeklyReview)
            ],
            reviewConstellation: InsightsReviewConstellationState(
                title: "Review constellation",
                subtitle: "A small set of signals worth carrying across review, goal detail, and plan.",
                items: [
                    InsightsReviewConstellationItem(id: "preview-constellation-1", title: "Close the hardening pass", summary: "This goal has visible evidence this week, which keeps its current path grounded in real follow-through.", signalLabel: "Believable", visualState: .success, goalTarget: GoalRouteTarget(goalID: "goal-native"), planRoute: nil),
                    InsightsReviewConstellationItem(id: "preview-constellation-2", title: "Retention loop", summary: "Recent friction suggests the current version of the work needs a smaller or clearer next move.", signalLabel: "Adjusting", visualState: .selected, goalTarget: GoalRouteTarget(goalID: "goal-growth"), planRoute: nil),
                    InsightsReviewConstellationItem(id: "preview-constellation-3", title: "The week needs a calmer shape", summary: "Open Plan to remove pressure, protect what still fits, and keep reflection attached to the real week.", signalLabel: "Shape next", visualState: .warning, goalTarget: nil, planRoute: .weeklyReview)
                ]
            ),
            historyLayer: InsightsHistoryLayerState(
                title: "History and reflection",
                subtitle: "The summary layer stays quick. The deeper timeline is here when you need proof of what changed.",
                summaryTitle: "Recent history is carrying the current read",
                summaryDetail: "The system is seeing steadier proof than last week without a matching rise in friction.",
                previewItems: [
                    InsightsTimelineItem(id: "preview-timeline-1", title: "Completed deep work block", subtitle: "Close the hardening pass", timestamp: "40 min ago", icon: "checkmark.circle.fill", badge: "Win", visualState: .success, goalTarget: GoalRouteTarget(goalID: "goal-native"), planRoute: nil),
                    InsightsTimelineItem(id: "preview-timeline-2", title: "Step was shrunk", subtitle: "Retention loop", timestamp: "Yesterday", icon: "arrow.triangle.branch", badge: "Adapted", visualState: .selected, goalTarget: GoalRouteTarget(goalID: "goal-growth"), planRoute: .weeklyReview),
                    InsightsTimelineItem(id: "preview-timeline-3", title: "Help requested", subtitle: "Retention loop", timestamp: "2 days ago", icon: "lifepreserver", badge: "Help", visualState: .warning, goalTarget: GoalRouteTarget(goalID: "goal-growth"), planRoute: .weeklyReview)
                ],
                timelineItems: [
                    InsightsTimelineItem(id: "preview-timeline-1", title: "Completed deep work block", subtitle: "Close the hardening pass", timestamp: "40 min ago", icon: "checkmark.circle.fill", badge: "Win", visualState: .success, goalTarget: GoalRouteTarget(goalID: "goal-native"), planRoute: nil),
                    InsightsTimelineItem(id: "preview-timeline-2", title: "Step was shrunk", subtitle: "Retention loop", timestamp: "Yesterday", icon: "arrow.triangle.branch", badge: "Adapted", visualState: .selected, goalTarget: GoalRouteTarget(goalID: "goal-growth"), planRoute: .weeklyReview),
                    InsightsTimelineItem(id: "preview-timeline-3", title: "Help requested", subtitle: "Retention loop", timestamp: "2 days ago", icon: "lifepreserver", badge: "Help", visualState: .warning, goalTarget: GoalRouteTarget(goalID: "goal-growth"), planRoute: .weeklyReview),
                    InsightsTimelineItem(id: "preview-timeline-4", title: "Updated release validation notes", subtitle: "Close the hardening pass", timestamp: "3 days ago", icon: "sparkles", badge: nil, visualState: .default, goalTarget: GoalRouteTarget(goalID: "goal-native"), planRoute: nil)
                ]
            ),
            trendTitle: "Pattern truth",
            trendSubtitle: "Microcharts support the read. They do not replace it.",
            timeframeLabel: "This week",
            trendPoints: [
                TrendPoint(id: "mon", label: "M", value: 0.48),
                TrendPoint(id: "tue", label: "T", value: 0.56),
                TrendPoint(id: "wed", label: "W", value: 0.68),
                TrendPoint(id: "thu", label: "T", value: 0.61),
                TrendPoint(id: "fri", label: "F", value: 0.79),
                TrendPoint(id: "sat", label: "S", value: 0.52),
                TrendPoint(id: "sun", label: "S", value: 0.73)
            ],
            trendSummary: "Execution improved once the week narrowed to one clear hardening pass.",
            activitiesTitle: "Recent signals",
            activitiesSubtitle: "Recent evidence, decisions, and changes that explain the current readout.",
            activities: [
                ActivitySummary(id: "activity-1", title: "Completed deep work block", subtitle: "Close the hardening pass", timestamp: "40 min ago", icon: "checkmark.circle.fill", badge: "Win"),
                ActivitySummary(id: "activity-2", title: "Step was shrunk", subtitle: "Retention loop", timestamp: "Yesterday", icon: "arrow.triangle.branch", badge: "Adapted"),
                ActivitySummary(id: "activity-3", title: "Updated release validation notes", subtitle: "Close the hardening pass", timestamp: "3 days ago", icon: "sparkles", badge: nil)
            ]
        ),
        profileDashboard: ProfileDashboard(
            hero: ProfileHeroState(
                title: "Preview User's system",
                subtitle: "Configuration, trust, and optional personalization stay calm and explicit here.",
                dominantTruth: "Appearance is curated, trust is local-first, and optional context remains inspectable.",
                supportingTruth: "System configuration stays separate from workflow. Optional context stays inspectable, local-first, and reversible.",
                trustWhisper: "Current trust posture: Ambitions is running in explicit local-only mode. Notifications are not requested for local reminders.",
                status: .selected,
                pills: [
                    ProfileStatusPill(id: "profile-pill-appearance", title: "System mode with Sage", icon: "paintpalette", state: .selected),
                    ProfileStatusPill(id: "profile-pill-sync", title: "Ambitions is running in explicit local-only mode.", icon: "lock.shield", state: .selected),
                    ProfileStatusPill(id: "profile-pill-context", title: "6 context signals on device", icon: "waveform.path.ecg", state: .default)
                ],
                stats: [
                    MetricSummary(id: "profile-1", title: "Open goals", value: "3", detail: "In active review", icon: "target"),
                    MetricSummary(id: "profile-2", title: "Tracked rituals", value: "6", detail: "Current set", icon: "repeat"),
                    MetricSummary(id: "profile-3", title: "Review cadence", value: "Weekly", detail: "Sunday reset", icon: "calendar"),
                    MetricSummary(id: "profile-4", title: "Context signals", value: "6", detail: "Evidence, feedback, and teaching", icon: "sparkles")
                ]
            ),
            systemCenter: ProfileSystemCenterState(
                title: "You",
                subtitle: "Profile, memory, reviews, trust, privacy, integrations, and settings stay grouped here without adding more top-level tabs.",
                sections: [
                    ProfileSystemCenterSection(
                        id: "profile-system-personal",
                        title: "Personal setup",
                        footer: nil,
                        items: [
                            ProfileSystemCenterItem(id: "profile-system-profile", title: "Profile", subtitle: "Name, default landing tab, and review cadence for this device.", icon: "person.crop.circle", statusLabel: "Stored locally", semanticState: .neutral, accessibilityHint: "Shows identity and default setup status."),
                            ProfileSystemCenterItem(id: "profile-system-personalization", title: "Personalization", subtitle: "Tone, recovery posture, planning strictness, and confirmation defaults remain calm and conservative.", icon: "slider.horizontal.3", statusLabel: "Local defaults", semanticState: .trust, accessibilityHint: "Summarizes local personalization controls."),
                            ProfileSystemCenterItem(id: "profile-system-appearance", title: "Appearance", subtitle: "Mode and accent choices use the shared Ambitions theme.", icon: "paintpalette", statusLabel: "System mode with Sage", semanticState: .success, accessibilityHint: "Shows current appearance preference."),
                            ProfileSystemCenterItem(id: "profile-system-settings", title: "Settings", subtitle: "Routine preferences stay here as You-owned controls, not as new tabs.", icon: "gearshape", statusLabel: "Grouped", semanticState: .neutral, accessibilityHint: "Shows grouped settings posture.")
                        ]
                    ),
                    ProfileSystemCenterSection(
                        id: "profile-system-memory-trust",
                        title: "Memory and trust",
                        footer: "Trust Center and What Ambitions Knows deepen later. This map stays honest about current support.",
                        items: [
                            ProfileSystemCenterItem(id: "profile-system-memory", title: "Memory / What Ambitions Knows", subtitle: "Local evidence, captures, corrections, and recent ledger signals that can explain recommendations.", icon: "brain.head.profile", statusLabel: "6 local", semanticState: .trust, accessibilityHint: "Shows local memory signal availability."),
                            ProfileSystemCenterItem(id: "profile-system-reviews", title: "Reviews", subtitle: "Recovery Review and Life OS Receipt stay under You and Plan contexts.", icon: "rectangle.stack.badge.play", statusLabel: "Based on recent actions", semanticState: .review, accessibilityHint: "Shows current review readiness."),
                            ProfileSystemCenterItem(id: "profile-system-analytics", title: "Analytics", subtitle: "Contextual summaries stay inside You and goal surfaces instead of becoming an Insights tab.", icon: "chart.line.uptrend.xyaxis", statusLabel: "Contextual", semanticState: .neutral, accessibilityHint: "Shows that analytics are contextual, not a top-level surface."),
                            ProfileSystemCenterItem(id: "profile-system-trust", title: "Trust & Explanations", subtitle: "Receipts, corrections, and why-this language stay inspectable and confirmation-gated.", icon: "checkmark.shield", statusLabel: "User controlled", semanticState: .trust, accessibilityHint: "Shows trust and explanation posture."),
                            ProfileSystemCenterItem(id: "profile-system-privacy", title: "Privacy", subtitle: "Sensitive details stay local-first and should remain hideable on external surfaces.", icon: "hand.raised", statusLabel: "Local-first", semanticState: .protected, accessibilityHint: "Shows privacy posture."),
                            ProfileSystemCenterItem(id: "profile-system-sync-export", title: "Sync / Export", subtitle: "Sync is not connected. Export and disaster recovery remain labeled until proof drills are complete.", icon: "externaldrive", statusLabel: "Ambitions is running in explicit local-only mode.", semanticState: .caution, accessibilityHint: "Shows local-only sync and export readiness.")
                        ]
                    ),
                    ProfileSystemCenterSection(
                        id: "profile-system-access",
                        title: "Access and integrations",
                        footer: "Optional system edges stay explicit.",
                        items: [
                            ProfileSystemCenterItem(id: "profile-system-integrations", title: "Integrations", subtitle: "Calendar, reminders, widgets, Live Activities, Shortcuts, and Share Extension status remain bounded.", icon: "rectangle.connected.to.line.below", statusLabel: "Not requested", semanticState: .calendarDerived, accessibilityHint: "Shows integration permission status."),
                            ProfileSystemCenterItem(id: "profile-system-notifications", title: "Notifications", subtitle: "Local reminders require explicit notification permission and are not needed to use the app.", icon: "bell.badge", statusLabel: "Not requested", semanticState: .neutral, accessibilityHint: "Shows notification permission status."),
                            ProfileSystemCenterItem(id: "profile-system-accessibility", title: "Accessibility", subtitle: "Internal checklist evidence exists; public claims are locked until manual verification is recorded.", icon: "figure", statusLabel: "Claims locked", semanticState: .accessibilityUnverified, accessibilityHint: "Shows accessibility verification status.")
                        ]
                    )
                ],
                footer: "You keeps settings, history, trust, and controls together. Deeper detail remains in the owning surfaces until the supporting controls are ready."
            ),
            controlRoom: ProfileControlRoomState(
                title: "Control room",
                subtitle: "A short map of the trust areas you can inspect without turning You into a settings dump.",
                entries: [
                    ProfileControlRoomEntry(id: "profile-control-constitution", title: "Personal Operating Constitution", subtitle: "Recommendation posture, recovery tone, planning strictness, and confirmation rules.", icon: "scroll", statusLabel: "Local defaults", state: .selected),
                    ProfileControlRoomEntry(id: "profile-control-memory", title: "What Ambitions Knows", subtitle: "Local evidence, feedback, corrections, captures, and event history Ambitions can explain and let you correct.", icon: "brain.head.profile", statusLabel: "Stored on this device", state: .default),
                    ProfileControlRoomEntry(id: "profile-control-corrections", title: "Corrections and assumptions", subtitle: "Assumptions can be corrected through existing teaching and explanation paths.", icon: "checkmark.bubble", statusLabel: "2 active", state: .success),
                    ProfileControlRoomEntry(id: "profile-control-receipts", title: "Receipts and audit posture", subtitle: "Reviews turns local receipts, recovery, proof, and corrections into a calm receipt layer.", icon: "doc.text.magnifyingglass", statusLabel: "Ready to review", state: .default)
                ],
                footer: "Open detail from the owning surfaces for deep review. This page stays oriented around trust, control, and next-safe status."
            ),
            constitution: ProfileConstitutionState(
                title: "Personal Operating Constitution",
                subtitle: "The local rules Ambitions uses to stay useful without becoming pushy or silent.",
                postureSummary: "Calm, conservative, correction-aware, and local-first by default.",
                rules: [
                    ProfileConstitutionRule(id: "constitution-local-first", title: "Start from local truth", detail: "Goals, captures, evidence, corrections, and recent ledger events are read from this device. Sync is not currently connected.", statusLabel: "Stored on this device", state: .selected),
                    ProfileConstitutionRule(id: "constitution-recovery-tone", title: "Recover without shame", detail: "Delays, skips, and smaller-version requests are treated as recovery context, not blame.", statusLabel: "Calm recovery", state: .success),
                    ProfileConstitutionRule(id: "constitution-calendar", title: "Ask before calendar writes", detail: "Calendar access is explicit and Plan-owned. Calendar writes require confirmation and are never silent.", statusLabel: "Not requested", state: .warning)
                ],
                footer: "These are current local defaults, not a broad account/preferences system. Deeper Constitution maturity remains future-owned."
            ),
            memoryControls: ProfileMemoryControlState(
                title: "What Ambitions Knows",
                subtitle: "Local memory areas Ambitions can use, what each one is for, and where you can correct it.",
                items: [
                    SettingsItem(id: "profile-memory-ledger", title: "Event Ledger", subtitle: "Recent meaningful actions and changes can support explanations. Full raw history stays off this top-level surface.", icon: "list.bullet.rectangle", valueLabel: "2 recent"),
                    SettingsItem(id: "profile-memory-evidence", title: "Proof and feedback", subtitle: "Progress evidence and feedback help Ambitions avoid relying only on intention.", icon: "checkmark.seal", valueLabel: "4 local"),
                    SettingsItem(id: "profile-memory-corrections", title: "Corrections and teaching", subtitle: "User-confirmed corrections can adjust future explanations where existing teaching signals support it.", icon: "slider.horizontal.3", valueLabel: "2 local"),
                    SettingsItem(id: "profile-memory-forget", title: "Forget or clear memory", subtitle: "Destructive memory deletion is not exposed here because safe review, confirmation, and undo coverage are not complete.", icon: "trash.slash", valueLabel: "Unavailable")
                ],
                groups: [
                    ProfileMemoryGroup(
                        id: "memory-group-current",
                        title: "Current local memory",
                        subtitle: "Used only from local Ambitions records available in this runtime.",
                        footer: "Current does not mean permanent. It means the source is active in the local app right now.",
                        items: [
                            ProfileMemoryItem(
                                id: "memory-item-ledger",
                                title: "Recent actions and changes",
                                detail: "2 recent local events are available for explanation and review context.",
                                sourceLabel: "Event Ledger",
                                freshness: .current,
                                usedFor: "Used for Why Changed, reviews, recovery summaries, and receipt context.",
                                privacyLabel: "Private by default",
                                actions: [
                                    ProfileMemoryAction(id: "inspect-ledger", title: "Inspect", statusLabel: "Available", detail: "Review happens through receipts, reviews, and owning surfaces.", state: .success),
                                    ProfileMemoryAction(id: "delete-ledger", title: "Delete", statusLabel: "Not exposed", detail: "Raw destructive deletion waits for a safe confirmation and undo boundary.", state: .warning)
                                ],
                                accessibilityLabel: "Recent actions and changes memory",
                                accessibilityValue: "Current. Private by default.",
                                accessibilityHint: "Shows what the event ledger is used for and why deletion is not exposed here."
                            ),
                            ProfileMemoryItem(
                                id: "memory-item-proof-feedback",
                                title: "Proof and feedback",
                                detail: "4 proof or feedback records can ground progress and review language.",
                                sourceLabel: "Proof and feedback",
                                freshness: .current,
                                usedFor: "Used for progress summaries, review receipts, and avoiding intention-only recommendations.",
                                privacyLabel: "Detail hidden in compact views",
                                actions: [
                                    ProfileMemoryAction(id: "update-proof", title: "Update this", statusLabel: "Use owning surface", detail: "Proof and feedback stay corrected from Goal Detail, Capture, or Review context.", state: .default),
                                    ProfileMemoryAction(id: "pause-proof", title: "Pause use", statusLabel: "Review later", detail: "Pause is represented as a review need here until a safe preference exists.", state: .warning)
                                ],
                                accessibilityLabel: "Proof and feedback memory",
                                accessibilityValue: "Current. Detail hidden in compact views.",
                                accessibilityHint: "Shows what proof and feedback memory is used for and where it can be corrected."
                            )
                        ]
                    ),
                    ProfileMemoryGroup(
                        id: "memory-group-corrections",
                        title: "Corrections and review signals",
                        subtitle: "User-corrected context is kept explicit and source-tied.",
                        footer: "No sensitive identity categories are inferred here.",
                        items: [
                            ProfileMemoryItem(
                                id: "memory-item-corrections",
                                title: "Corrections and teaching",
                                detail: "2 local teaching signals can influence future explanation language.",
                                sourceLabel: "Manual corrections",
                                freshness: .current,
                                usedFor: "Used for Why Changed, lighter-version preferences, and future recommendations that cite local evidence.",
                                privacyLabel: "Correctable",
                                actions: [
                                    ProfileMemoryAction(id: "correct-teaching", title: "Correct", statusLabel: "Available", detail: "Corrections stay tied to existing teaching and explanation paths.", state: .success),
                                    ProfileMemoryAction(id: "delete-teaching", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning)
                                ],
                                accessibilityLabel: "Corrections and teaching memory",
                                accessibilityValue: "Current. Correctable.",
                                accessibilityHint: "Shows how corrections affect future explanations and why deletion requires confirmation."
                            )
                        ]
                    )
                ],
                narrativeMemories: [
                    ProfileNarrativeMemory(
                        id: "narrative-memory-corrections",
                        title: "You corrected how Ambitions reads something",
                        summary: "2 manual corrections can change future explanation language where the original artifact still exists.",
                        sourceLabel: "Manual corrections",
                        freshness: .current,
                        usedFor: "Used for Why Changed, recommendation wording, and future review prompts that cite the correction.",
                        sensitiveStatusLabel: "No sensitive inference",
                        actions: [
                            ProfileMemoryAction(id: "narrative-correct", title: "Correct", statusLabel: "Use owning surface", detail: "Goal Detail, Capture, and explanation controls remain the supported correction paths.", state: .success),
                            ProfileMemoryAction(id: "narrative-delete", title: "Delete", statusLabel: "Needs confirmation", detail: "Deletion is not claimed until safe review, confirmation, and undo coverage exist.", state: .warning),
                            ProfileMemoryAction(id: "narrative-pause", title: "Pause use", statusLabel: "Review later", detail: "Pause is shown as a review need until a safe preference exists.", state: .warning)
                        ],
                        accessibilityLabel: "Narrative memory from corrections",
                        accessibilityValue: "Current. Manual corrections. Sensitive categories are not inferred.",
                        accessibilityHint: "Shows what this narrative memory uses and which correction, delete, and pause controls are safe or blocked."
                    )
                ],
                conservativePatterns: [
                    ProfileMemoryPattern(
                        id: "memory-pattern-corrections",
                        title: "Correction-shaped learning",
                        summary: "Only user-confirmed correction signals are treated as learning here.",
                        sourceLabel: "2 manual",
                        reviewLabel: "Review before reuse",
                        state: .success
                    )
                ],
                recoverySummary: "Memory can be reviewed and corrected from the owning surfaces. Broad delete, forget, and pause controls remain confirmation-gated or future-owned.",
                footer: "What Ambitions Knows is local, inspectable, and correctable through existing safe seams. Broad forgetting and deletion remain manual/future until the safe boundary can prove the result."
            ),
            assumptionCorrections: ProfileAssumptionCorrectionState(
                title: "Corrections and assumptions",
                subtitle: "Ambitions should be teachable without asking you to understand its internals.",
                items: [
                    SettingsItem(id: "profile-correction-active", title: "Active corrections", subtitle: "Existing teaching signals are the current correction path.", icon: "checkmark.bubble", valueLabel: "2 active"),
                    SettingsItem(id: "profile-correction-availability", title: "You can correct this", subtitle: "Goal Detail explanations and existing teaching flows remain the supported place to correct assumptions.", icon: "pencil.and.list.clipboard", valueLabel: "Supported where shown")
                ],
                footer: "This is an entry point into existing correction systems, not a second memory model or a full Correction Review."
            ),
            automationBoundary: ProfileAutomationBoundaryState(
                title: "What Ambitions will not do silently",
                subtitle: "The safe automation policy keeps external, broad, destructive, and unsupported changes confirmation-gated or blocked.",
                rules: [
                    ProfileConstitutionRule(id: "automation-calendar", title: "No silent calendar changes", detail: "Calendar changes must be confirmed from Plan.", statusLabel: "Requires confirmation", state: .warning),
                    ProfileConstitutionRule(id: "automation-reflow", title: "No silent broad reflow", detail: "This would change more than one part of the plan.", statusLabel: "Requires confirmation", state: .warning),
                    ProfileConstitutionRule(id: "automation-memory", title: "No unsupported forgetting", detail: "No memory was forgotten.", statusLabel: "Blocked safely", state: .warning)
                ],
                footer: "This describes policy decisions only. It does not execute calendar writes, sync resolution, deletion, or undo."
            ),
            receiptAudit: ProfileReceiptAuditState(
                title: "Receipts and audit posture",
                subtitle: "A compact trust summary of what can explain actions today. Reviews now turns these signals into a calm receipt layer.",
                items: [
                    SettingsItem(id: "profile-receipts-domain", title: "Receipts", subtitle: "Receipts can summarize what changed, why, correction availability, safe fallback, and undo status where supported.", icon: "doc.text.magnifyingglass", valueLabel: "3 policy examples"),
                    SettingsItem(id: "profile-receipts-review", title: "Reviews v1", subtitle: "Recovery Review and Life OS Receipt summarize local events, receipts, proof, and corrections without creating a top-level Insights tab.", icon: "rectangle.stack.badge.play", valueLabel: "Ready to review")
                ],
                footer: "Receipts are exposed here as trust posture, not as a full history browser."
            ),
            reviews: ProfileReviewsState(
                projection: ReviewsV1Projector().project(
                    ReviewsV1ProjectionInput(
                        generatedAt: "2026-04-27T12:00:00Z",
                        timeframeLabel: "Recent local review",
                        eventLedgerEntries: [
                            EventLedgerEntry(
                                id: "preview-review-completed",
                                kind: .actionCompleted,
                                occurredAt: "2026-04-27T11:00:00Z",
                                source: .today,
                                title: "Completed deep work block",
                                summary: "A meaningful action closed with local proof.",
                                tone: .positive
                            ),
                            EventLedgerEntry(
                                id: "preview-review-recovery",
                                kind: .recoveryAccepted,
                                occurredAt: "2026-04-27T10:00:00Z",
                                source: .plan,
                                title: "Recovery path accepted",
                                summary: "A smaller next move was selected without changing Calendar.",
                                tone: .recovering
                            )
                        ],
                        proofEvidence: [
                            ProgressEvidence(
                                id: "preview-proof-review",
                                goalID: "goal-native",
                                stepID: "step-native",
                                evidenceKind: .stepCompleted,
                                source: .manual,
                                capturedAt: "2026-04-27T11:02:00Z",
                                progressDelta: nil,
                                confidenceDelta: nil,
                                minutesInvested: 45,
                                note: "Validated the review surface copy."
                            )
                        ],
                        calendarStatusLabel: "Not requested"
                    )
                ),
                title: "Reviews",
                subtitle: "Recovery Review and Life OS Receipt for what happened, what changed, and what should carry forward.",
                footer: "Reviews uses existing local ledgers, receipts, proof, and correction signals. It does not restore Insights as a tab or claim live sync, account systems, or verified accessibility."
            ),
            appearanceStudio: ProfileAppearanceStudioState(
                title: "Appearance Studio",
                subtitle: "Curated, authored control over mode and accent so the shell feels personal without turning into a skin chooser.",
                previewSummary: "Preview the current palette against system-style hierarchy before you save.",
                modeOptions: [
                    ProfileAppearanceOption(id: "appearance-system", title: "System", subtitle: "Follow the device while keeping Ambitions hierarchy intact.", preference: .system),
                    ProfileAppearanceOption(id: "appearance-light", title: "Light", subtitle: "Use the warm light palette full time.", preference: .light),
                    ProfileAppearanceOption(id: "appearance-dark", title: "Dark", subtitle: "Use the flagship dark palette full time.", preference: .dark)
                ],
                accentOptions: [
                    ProfileAccentOption(id: "accent-sage", title: "Sage", subtitle: "Quiet, grounded, and balanced.", family: .sage),
                    ProfileAccentOption(id: "accent-blue-gray", title: "Blue Gray", subtitle: "Cooler and architectural.", family: .blueGray),
                    ProfileAccentOption(id: "accent-muted-gold", title: "Muted Gold", subtitle: "Warm emphasis with restrained glow.", family: .mutedGold),
                    ProfileAccentOption(id: "accent-copper", title: "Copper", subtitle: "Richer warmth for stronger highlights.", family: .copper),
                    ProfileAccentOption(id: "accent-sand", title: "Sand", subtitle: "Soft neutral warmth with gentle contrast.", family: .sand)
                ],
                previewSwatches: [
                    ProfilePreviewSwatch(id: "preview-now", title: "Current shell", subtitle: "How the core hierarchy will render after save.", eyebrow: "System", accentFamily: .sage, appearancePreference: .system, state: .selected),
                    ProfilePreviewSwatch(id: "preview-trust", title: "Trust calm", subtitle: "Trust status keeps a quieter layer than hero actions.", eyebrow: "Trust", accentFamily: .sage, appearancePreference: .system, state: .default),
                    ProfilePreviewSwatch(id: "preview-context", title: "Context optionality", subtitle: "Optional context stays helpful, not invasive.", eyebrow: "Context", accentFamily: .sage, appearancePreference: .system, state: .default)
                ],
                footer: "Appearance changes use the existing shared theme system. Save keeps the choice for the next launch; leaving without saving preserves the current persisted default."
            ),
            trustCenter: ProfileTrustCenterState(
                title: "Trust Center",
                subtitle: "Trust should read as configuration truth, not a debug console. The pulse below stays calm and human-readable.",
                pulse: ProfileTrustPulseState(
                    title: "Sync pulse",
                    subtitle: "Local-first and stable",
                    detail: "Portable continuity stays explicit and local-first in this build. Future cloud or continuity productization remains deferred.",
                    state: .selected
                ),
                items: [
                    SettingsItem(id: "profile-trust-sync", title: "System trust posture", subtitle: "The current runtime runs from on-device storage, portable backup/restore, and no implied live cloud backend.", icon: "lock.shield", valueLabel: "Ambitions is running in explicit local-only mode."),
                    SettingsItem(id: "profile-trust-notifications", title: "Notification pulse", subtitle: "Local reminder scheduling exists on the current runtime. Authorization stays explicit here so ambient trust never feels hidden.", icon: "bell.badge", valueLabel: "Not requested"),
                    SettingsItem(id: "profile-trust-routing", title: "System status", subtitle: "\(ExternalSurfaceTruth.verifiedRoutingTruth). External routes stay on canonical destinations, and ambient surfaces preserve local-first continuity language.", icon: "arrow.triangle.branch", valueLabel: "Calm")
                ],
                sections: [
                    ProfileTrustCenterSection(
                        id: "trust-center-status",
                        title: "Status and boundaries",
                        footer: "These rows describe current runtime truth.",
                        routes: [
                            ProfileTrustCenterRoute(id: "trust-route-local-data", title: "Local data status", subtitle: "Goals, captures, proof, corrections, receipts, and reviews read from this device.", icon: "internaldrive", statusLabel: "Stored on this device", semanticState: .trust, accessibilityHint: "Shows local storage trust status."),
                            ProfileTrustCenterRoute(id: "trust-route-calendar", title: "Calendar boundary", subtitle: "Calendar awareness is Plan-owned. Writes require confirmation.", icon: "calendar.badge.clock", statusLabel: "Not requested", semanticState: .calendarDerived, accessibilityHint: "Shows calendar permission and write boundary."),
                            ProfileTrustCenterRoute(id: "trust-route-external-surfaces", title: "External surfaces", subtitle: "External surfaces must use privacy snapshots and fallback routes.", icon: "rectangle.3.group", statusLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview, semanticState: .caution, accessibilityHint: "Shows external-surface verification status.")
                        ]
                    ),
                    ProfileTrustCenterSection(
                        id: "trust-center-receipts",
                        title: "Receipts, corrections, and explanations",
                        footer: "Receipt rows summarize policy and action history without exposing raw logs by default.",
                        routes: [
                            ProfileTrustCenterRoute(id: "trust-route-receipts", title: "Receipts", subtitle: "Receipts say what happened, what changed, why, and what can be corrected or undone.", icon: "doc.text.magnifyingglass", statusLabel: "3 examples", semanticState: .review, accessibilityHint: "Shows receipt history posture."),
                            ProfileTrustCenterRoute(id: "trust-route-corrections", title: "Correction routes", subtitle: "Supported corrections stay tied to existing Goal Detail, Capture, teaching, and explanation seams.", icon: "checkmark.bubble", statusLabel: "2 local", semanticState: .trust, accessibilityHint: "Shows correction availability."),
                            ProfileTrustCenterRoute(id: "trust-route-undo", title: "Undo rules", subtitle: "Local undo is shown only where safe.", icon: "arrow.uturn.backward", statusLabel: "No silent undo", semanticState: .caution, accessibilityHint: "Shows undo safety posture.")
                        ]
                    ),
                    ProfileTrustCenterSection(
                        id: "trust-center-privacy-future",
                        title: "Privacy and future-owned capabilities",
                        footer: "Unavailable states stay visible.",
                        routes: [
                            ProfileTrustCenterRoute(id: "trust-route-privacy", title: "Privacy defaults", subtitle: "Sensitive details should be hidden on compact and external surfaces unless the user chooses otherwise.", icon: "hand.raised", statusLabel: "Private by default", semanticState: .protected, accessibilityHint: "Shows privacy-safe display posture."),
                            ProfileTrustCenterRoute(id: "trust-route-sync-export", title: "Sync / Export truth", subtitle: "Sync is not connected. Export and import proof remain future-owned.", icon: "externaldrive", statusLabel: "Ambitions is running in explicit local-only mode.", semanticState: .caution, accessibilityHint: "Shows sync and export truth."),
                            ProfileTrustCenterRoute(id: "trust-route-accessibility-claims", title: "Accessibility claims", subtitle: "Internal evidence exists. Public claims stay locked until manual VoiceOver, Dynamic Type, Reduce Motion, contrast, and motor review is recorded.", icon: "figure", statusLabel: "Claims locked", semanticState: .accessibilityUnverified, accessibilityHint: "Shows accessibility claim status.")
                        ]
                    )
                ],
                receiptSummaries: [
                    ActionReceiptDisplaySummary(id: "preview-receipt-calendar", title: "Calendar write blocked", summary: "No calendar change happened because confirmation is required.", resultState: .needsConfirmation, occurredAt: "2026-04-27T12:10:00Z", sourceDomain: .plan, undoAvailability: .requiresConfirmation, correctionAvailability: .availableWithReason, nextActionTitle: "Review in Plan", safetyState: .confirmationRequired),
                    ActionReceiptDisplaySummary(id: "preview-receipt-memory", title: "Memory deletion blocked", summary: "No memory was forgotten because safe review and undo are incomplete.", resultState: .failedSafely, occurredAt: "2026-04-27T12:09:00Z", sourceDomain: .you, undoAvailability: .unsafe, correctionAvailability: .unavailable, nextActionTitle: nil, safetyState: .safeFailure)
                ],
                footer: "This establishes the trust framing layer only. Deeper continuity and sync-trust productization remain future-owned, so this surface stays truthful about what exists today."
            ),
            contextVault: ProfileContextVaultState(
                title: "Context Vault",
                subtitle: "Optional personal context is inspectable here before later compliance work deepens policy and export surfaces.",
                items: [
                    ProfileContextVaultItem(id: "profile-vault-signals", title: "Signals in use", subtitle: "These are the current categories the app can already read from its native repositories.", icon: "tray.full", detail: "2 evidence records, 2 feedback events, 2 teaching signals"),
                    ProfileContextVaultItem(id: "profile-vault-planning", title: "Planning memory", subtitle: "Clarifications, blocked drafts, and open captures stay visible so future intelligence work remains auditable.", icon: "rectangle.stack.badge.person.crop", detail: "1 draft signal, 1 open capture"),
                    ProfileContextVaultItem(id: "profile-vault-identity", title: "Personal defaults", subtitle: "Name, launch defaults, and appearance stay separate from the execution surfaces they influence.", icon: "person.text.rectangle", detail: "Preview User")
                ],
                policyItems: [
                    ProfileSignalPolicyItem(id: "profile-policy-optional", title: "Optional by design", detail: "Context is there to improve fit and trust. It is not required to use the core planning system.", state: .default),
                    ProfileSignalPolicyItem(id: "profile-policy-local", title: "Local-first posture", detail: "Signals stay on device in this build and should remain inspectable before any future continuity expansion.", state: .selected),
                    ProfileSignalPolicyItem(id: "profile-policy-explicit", title: "Inspectable and understandable", detail: "The app should be able to explain what signal types exist without feeling invasive or technical.", state: .default)
                ],
                footer: "This is a foundation layer, not a full privacy admin surface. It prepares future compliance and trust work without inventing unfinished flows early."
            ),
            integrationsSection: ProfileSectionGroup(
                title: "Integrations and permissions",
                subtitle: "Only the system edges that materially affect trust or routing belong here.",
                items: [
                    SettingsItem(id: "profile-integration-notifications", title: "Notifications", subtitle: "Authorization: Not requested yet. Local reminders stay on-device and bounded to the current runtime.", icon: "bell.badge", valueLabel: "Not requested"),
                    SettingsItem(id: "profile-integration-reminders", title: "Reminders integration", subtitle: "Reminder write paths exist on the current EventKit seam. Authorization stays explicit so scheduling trust is legible.", icon: "checklist", valueLabel: "Not requested"),
                    SettingsItem(id: "profile-integration-calendar", title: "Calendar integration", subtitle: "Calendar event creation and conflict detection exist on the shared EventKit seam. Read depth depends on authorization level.", icon: "calendar.badge.clock", valueLabel: "Not requested"),
                    SettingsItem(id: "profile-integration-widgets", title: "Widgets and Live Activity", subtitle: "\(ExternalSurfaceTruth.productizedNeedsPlatformReview). Widgets and Live Activity read the shared external snapshot, Now State Lease, and local-first continuity posture.", icon: "rectangle.3.group", valueLabel: ExternalSurfaceTruth.productizedNeedsPlatformReview),
                    SettingsItem(id: "profile-integration-shortcuts", title: "Navigation shortcuts", subtitle: "\(ExternalSurfaceTruth.availableButNeedsManualVerification). App Intents stay navigation-only and keep canonical routing ownership.", icon: "sparkles.rectangle.stack", valueLabel: ExternalSurfaceTruth.availableButNeedsManualVerification),
                    SettingsItem(id: "profile-integration-share", title: "Share Extension", subtitle: "\(ExternalSurfaceTruth.notShippedInThisBuild). Share intake remains deferred until a dedicated extension target and handoff path exist.", icon: "square.and.arrow.up", valueLabel: ExternalSurfaceTruth.notShippedInThisBuild)
                ],
                footer: "Notification and integration status should answer whether anything important needs attention without turning You into an admin checklist."
            ),
            defaultsSection: ProfileSectionGroup(
                title: "Personal defaults",
                subtitle: "These choices shape the shell, not the truth of your goals or day.",
                items: [
                    SettingsItem(id: "profile-default-tab", title: "Default landing tab", subtitle: "Used on the next cold launch so re-entry starts where you prefer.", icon: "square.grid.2x2", valueLabel: "Today"),
                    SettingsItem(id: "profile-default-review", title: "Review cadence", subtitle: "How often the app frames a planning reset using the current local planning loop.", icon: "clock.arrow.circlepath", valueLabel: "Weekly"),
                    SettingsItem(id: "profile-default-storage", title: "Storage mode", subtitle: "Goals, captures, evidence, and teaching signals persist through the native on-device repositories.", icon: "internaldrive", valueLabel: "Local-only")
                ],
                footer: nil
            ),
            accountSection: ProfileSectionGroup(
                title: "Account and billing",
                subtitle: "This build stays explicit about what is not configured yet so You never implies hidden account requirements.",
                items: [
                    SettingsItem(id: "profile-account-mode", title: "Account mode", subtitle: "No sign-in or cloud account is required for the current shipping native experience.", icon: "person.crop.circle", valueLabel: "On-device only"),
                    SettingsItem(id: "profile-account-billing", title: "Billing", subtitle: "Subscriptions, digital unlocks, and purchase flows are not active product scope in this build.", icon: "creditcard", valueLabel: "Not active")
                ],
                footer: "Future account or monetization work should land only when canon and release-compliance truth explicitly activate it."
            ),
            notificationAuthorization: ProfileNotificationAuthorization(
                statusLabel: "Not requested",
                detail: "Not requested yet.",
                canRequestAuthorization: true,
                actionTitle: "Enable notifications"
            ),
            preferences: ProfilePreferencesState(preferredTab: .today, appearancePreference: .system, accentFamily: .sage, reviewCadenceDays: 7, localOnlyModeEnabled: true)
        )
    )
}
