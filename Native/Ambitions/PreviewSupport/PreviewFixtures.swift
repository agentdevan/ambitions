import AmbitionsDesignSystem
import Foundation

struct ExternalBrainPreviewScenario: Sendable, Equatable, Identifiable {
    let id: String
    let title: String
    let surface: String
    let fixtureOwner: String
    let sourceTruth: String
    let commandIntent: ShellCommandIntent?
    let memoryQuery: String?
    let privacyBoundary: String
    let accessibilityExpectation: String
    let yellowLimit: String
    let expectedEvidence: [String]
}

struct PreviewFixtures: Sendable {
    let preferences: AppPreferences
    let todayDashboard: TodayDashboard
    let captures: [Capture]
    let goalsDashboard: GoalsDashboard
    let timeRitualsDashboard: TimeRitualsDashboard
    let insightsDashboard: InsightsDashboard
    let youDashboard: YouDashboard
    let externalBrainScenarios: [ExternalBrainPreviewScenario]

    static let `default` = PreviewFixtures(
        preferences: AppPreferences(
            preferredTab: .today,
            userDisplayName: "Preview User",
            appearancePreference: .system,
            accentFamily: .sage
        ),
        todayDashboard: TodayDashboard(
            title: "Steady execution, light load",
            subtitle: "Three deliberate steps are enough to keep momentum today.",
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
        timeRitualsDashboard: PreviewTimeRitualScenarios.seeded,
        insightsDashboard: PreviewFixtures.defaultInsightsDashboard,
        youDashboard: PreviewFixtures.defaultYouDashboard,
        externalBrainScenarios: PreviewFixtures.defaultExternalBrainScenarios
    )
}

func makePreviewSourceAtlasKnowledgeState() -> YouSourceAtlasKnowledgeState {
    YouSourceAtlasKnowledgeState(
        title: "Source Atlas & Goal Knowledge",
        subtitle: "What Ambitions used, why it used it, and where review or correction stays supported.",
        sections: [
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-goal-knowledge-sources",
                title: "Goal Knowledge Sources",
                subtitle: "What Ambitions reads before it shapes goal knowledge or a step path.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-goal-source-goals",
                        icon: "target",
                        title: "Goals repository",
                        usedWhat: "3 active goals, 4 total goals",
                        whyUsed: "Used to keep goal knowledge tied to the user-owned goal graph instead of a hidden profile.",
                        sourceName: "Goals",
                        sourceState: .locallyProven,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Goal Detail > Edit Goal",
                        reviewPath: "Open Goal Detail > Review Goal",
                        iconState: .selected
                    ),
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-goal-source-drafts",
                        icon: "square.and.pencil",
                        title: "Drafts and staged plans",
                        usedWhat: "1 draft, 1 staged plan",
                        whyUsed: "Used to explain which drafts can become steps and which ones still need review.",
                        sourceName: "Goal drafts",
                        sourceState: .current,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Goal Detail > Correct Draft",
                        reviewPath: "Open Goal Detail > Recompile",
                        iconState: .selected
                    )
                ],
                footer: "These rows stay local and inspectable. They do not imply a hidden profile or remote model."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-active-source-packs",
                title: "Active Source Packs",
                subtitle: "Local source bundles that are currently able to influence planning.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-pack-goals",
                        icon: "scope",
                        title: "Goal source pack",
                        usedWhat: "3 active goals feed the pack",
                        whyUsed: "Used to keep the current goal set available for planning and review.",
                        sourceName: "Goals + plans",
                        sourceState: .locallyProven,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Goals > Edit Pack",
                        reviewPath: "Open Goals > Review Pack",
                        iconState: .selected
                    ),
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-pack-replay",
                        icon: "arrow.clockwise",
                        title: "Replay source pack",
                        usedWhat: "2 replayable local events",
                        whyUsed: "Used to explain the current bridge receipt and replay posture.",
                        sourceName: "Replay receipts",
                        sourceState: .locallyProven,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .notUsed,
                        needsReview: false,
                        correctionPath: "Open Receipts > Correct Replay",
                        reviewPath: "Open Receipts > Review Replay",
                        iconState: .default
                    )
                ],
                footer: "Active means the bundle can still affect local planning. It is not a claim of official coverage."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-needs-review",
                title: "Needs Review",
                subtitle: "Source areas that should not be treated as settled yet.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-review-clarifications",
                        icon: "questionmark.circle",
                        title: "Clarification needed",
                        usedWhat: "1 draft still needs an answer",
                        whyUsed: "Clarification keeps source use honest instead of guessing.",
                        sourceName: "Draft clarifications",
                        sourceState: .sourceNeeded,
                        freshnessState: .unknown,
                        riskState: .medium,
                        runtimeUseState: .notUsed,
                        needsReview: true,
                        correctionPath: "Open Goal Detail > Answer Question",
                        reviewPath: "Open Goal Detail > Recompile",
                        iconState: .warning
                    )
                ],
                footer: "Review paths stay visible so unsupported or stale context does not look complete."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-unsupported-goal-areas",
                title: "Unsupported Goal Areas",
                subtitle: "Goal areas that currently lack enough source to drive a safe path.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-unsupported-none",
                        icon: "checkmark.shield",
                        title: "No unsupported goal areas",
                        usedWhat: "All visible goal areas have a usable local source path.",
                        whyUsed: "This section stays visible so unsupported areas would be obvious if they appear.",
                        sourceName: "Goal knowledge",
                        sourceState: .current,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Goal Detail > No Correction Needed",
                        reviewPath: "Open Goal Detail > Review Later",
                        iconState: .selected
                    )
                ],
                footer: "Unsupported does not mean blocked forever. It means this surface should show the gap."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-recent-goal-compilations",
                title: "Recent Goal Compilations",
                subtitle: "Recent compile output that can be inspected without turning You into a console.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-compilation-dream",
                        icon: "rectangle.stack.badge.plus",
                        title: "Launch review",
                        usedWhat: "Launch review plan",
                        whyUsed: "Used to compile a source-backed plan for the next step path.",
                        sourceName: "Drafts",
                        sourceState: .locallyProven,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Goal Detail > Correct Draft",
                        reviewPath: "Open Goal Detail > Review Compilation",
                        iconState: .selected
                    )
                ],
                footer: "Recent compilations stay local and reviewable through the owning goal surface."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-path-sources",
                title: "Path Sources",
                subtitle: "Source bundles that describe the path shape before a step is picked.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-path-source",
                        icon: "arrow.triangle.branch",
                        title: "Launch review / Plan",
                        usedWhat: "Two step path",
                        whyUsed: "Used to shape the path before step-level source is chosen.",
                        sourceName: "Launch review",
                        sourceState: .locallyProven,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Goal Detail > Edit Path",
                        reviewPath: "Open Goal Detail > Review Path",
                        iconState: .selected
                    )
                ],
                footer: "Path sources are a preview of the current route, not a silent plan change."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-step-sources",
                title: "Step Sources",
                subtitle: "Individual step-level sources and why they were used or rejected.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-step-source",
                        icon: "checklist",
                        title: "Morning check-in",
                        usedWhat: "Quick review step",
                        whyUsed: "Used to keep the current step path concrete.",
                        sourceName: "Launch review",
                        sourceState: .current,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .notUsed,
                        needsReview: false,
                        correctionPath: "Open Goal Detail > Edit Step",
                        reviewPath: "Open Goal Detail > Review Step",
                        iconState: .default
                    )
                ],
                footer: "Steps stay tied to their owning goal or draft and keep correction paths visible."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-corrections",
                title: "Corrections",
                subtitle: "Local correction signals that can change future goal knowledge.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-correction-teaching",
                        icon: "bubble.left.and.bubble.right",
                        title: "Teaching signals",
                        usedWhat: "2 teaching signal(s)",
                        whyUsed: "Used to correct future explanations where the user already taught Ambitions better context.",
                        sourceName: "Teaching",
                        sourceState: .locallyProven,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Goal Detail > Save Teaching",
                        reviewPath: "Open Goal Detail > Review Teaching",
                        iconState: .selected
                    )
                ],
                footer: "Corrections stay reviewable from the owning goal or capture surface."
            ),
            YouSourceAtlasKnowledgeSection(
                id: "preview-source-atlas-replay-receipts",
                title: "Replay Receipts",
                subtitle: "Replay receipts that explain the current Source Atlas bridge posture.",
                rows: [
                    makePreviewSourceAtlasKnowledgeRow(
                        id: "preview-receipt-generated",
                        icon: "arrow.clockwise",
                        title: "Replay generated",
                        usedWhat: "Replay receipts stayed local and inspectable.",
                        whyUsed: "event-ledger-count=2 · life-context-bundles=1",
                        sourceName: "Replay receipt",
                        sourceState: .locallyProven,
                        freshnessState: .current,
                        riskState: .low,
                        runtimeUseState: .usedToPlan,
                        needsReview: false,
                        correctionPath: "Open Receipts > Correct Replay",
                        reviewPath: "Open Receipts > Review Replay",
                        iconState: .selected
                    )
                ],
                footer: "Replay receipts are local and inspectable. They are not a release claim."
            )
        ],
        footer: "Goal Knowledge stays local-first, inspectable, and correction-aware."
    )
}

func makePreviewSourceAtlasKnowledgeRow(
    id: String,
    icon: String,
    title: String,
    usedWhat: String,
    whyUsed: String,
    sourceName: String,
    sourceState: SourceAtlasRequirementSourceState,
    freshnessState: SourceAtlasRequirementFreshnessState,
    riskState: SourceAtlasRequirementRiskState,
    runtimeUseState: YouSourceAtlasKnowledgeRuntimeUseState,
    needsReview: Bool,
    correctionPath: String,
    reviewPath: String,
    iconState: AmbitionVisualState
) -> YouSourceAtlasKnowledgeRow {
    let reviewNeedLabel = needsReview ? "Needs Review" : "No Review Needed"
    return YouSourceAtlasKnowledgeRow(
        id: id,
        icon: icon,
        title: title,
        usedWhat: usedWhat,
        whyUsed: whyUsed,
        sourceName: sourceName,
        sourceStateLabel: sourceAtlasStateLabel(sourceState),
        freshnessStateLabel: sourceAtlasFreshnessLabel(freshnessState),
        riskStateLabel: sourceAtlasRiskLabel(riskState),
        runtimeUseState: runtimeUseState,
        reviewNeedLabel: reviewNeedLabel,
        correctionPath: correctionPath,
        reviewPath: reviewPath,
        state: iconState,
        accessibilityLabel: title,
        accessibilityValue: "\(usedWhat). \(whyUsed). Source \(sourceName). Source state \(sourceAtlasStateLabel(sourceState)). Freshness \(sourceAtlasFreshnessLabel(freshnessState)). Risk \(sourceAtlasRiskLabel(riskState)). \(runtimeUseState.label). \(reviewNeedLabel). Correction path \(correctionPath). Review path \(reviewPath).",
        accessibilityHint: "Shows what Ambitions used, why it used it, and how to review or correct the source path."
    )
}

func sourceAtlasStateLabel(_ state: SourceAtlasRequirementSourceState) -> String {
    switch state {
    case .unknown:
        return "Unknown"
    case .sourceNeeded:
        return "Context needed"
    case .stale:
        return "Stale"
    case .contradicted:
        return "Contradicted"
    case .revoked:
        return "Revoked"
    case .locallyProven:
        return "Locally proven"
    case .official:
        return "Official"
    case .officialCurrent:
        return "Official current"
    case .current:
        return "Current"
    }
}

func sourceAtlasFreshnessLabel(_ state: SourceAtlasRequirementFreshnessState) -> String {
    switch state {
    case .current:
        return "Current"
    case .stale:
        return "Stale"
    case .unknown:
        return "Unknown"
    }
}

func sourceAtlasRiskLabel(_ state: SourceAtlasRequirementRiskState) -> String {
    switch state {
    case .low:
        return "Low risk"
    case .medium:
        return "Medium risk"
    case .high:
        return "High risk"
    case .unknown:
        return "Unknown risk"
    }
}
