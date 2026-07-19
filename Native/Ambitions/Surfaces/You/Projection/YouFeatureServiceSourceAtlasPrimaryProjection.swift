import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeSourceAtlasKnowledgeState(snapshot: Snapshot) -> YouSourceAtlasKnowledgeState {
        YouSourceAtlasKnowledgeState(
            title: "Source Atlas & Goal Knowledge",
            subtitle: "What Ambitions used, why it used it, and where review or correction stays supported.",
            sections: [
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-goal-knowledge-sources",
                    title: "Goal Knowledge Sources",
                    subtitle: "What Ambitions reads before it shapes goal knowledge or a step path.",
                    rows: makeGoalKnowledgeSourceRows(snapshot: snapshot),
                    footer: "These rows stay local and inspectable. They do not imply a hidden profile or remote model."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-active-source-packs",
                    title: "Active Source Packs",
                    subtitle: "Local source bundles that are currently able to influence planning.",
                    rows: makeActiveSourcePackRows(snapshot: snapshot),
                    footer: "Active means the bundle can still affect local planning. It is not a claim of official coverage."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-needs-review",
                    title: "Needs Review",
                    subtitle: "Source areas that should not be treated as settled yet.",
                    rows: makeNeedsReviewRows(snapshot: snapshot),
                    footer: "Review paths stay visible so unsupported or stale context does not look complete."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-unsupported-goal-areas",
                    title: "Unsupported Goal Areas",
                    subtitle: "Goal areas that currently lack enough source to drive a safe path.",
                    rows: makeUnsupportedGoalAreaRows(snapshot: snapshot),
                    footer: "Unsupported does not mean blocked forever. It means this surface should show the gap."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-recent-goal-compilations",
                    title: "Recent Goal Compilations",
                    subtitle: "Recent compile output that can be inspected without turning You into a console.",
                    rows: makeRecentGoalCompilationRows(snapshot: snapshot),
                    footer: "Recent compilations stay local and reviewable through the owning goal surface."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-path-sources",
                    title: "Path Sources",
                    subtitle: "Source bundles that describe the path shape before a step is picked.",
                    rows: makePathSourceRows(snapshot: snapshot),
                    footer: "Path sources are a preview of the current route, not a silent plan change."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-step-sources",
                    title: "Step Sources",
                    subtitle: "Individual step-level sources and why they were used or rejected.",
                    rows: makeStepSourceRows(snapshot: snapshot),
                    footer: "Steps stay tied to their owning goal or draft and keep correction paths visible."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-corrections",
                    title: "Corrections",
                    subtitle: "Local correction signals that can change future goal knowledge.",
                    rows: makeSourceAtlasCorrectionRows(snapshot: snapshot),
                    footer: "Corrections stay reviewable from the owning goal or capture surface."
                ),
                YouSourceAtlasKnowledgeSection(
                    id: "source-atlas-replay-receipts",
                    title: "Replay Receipts",
                    subtitle: "Replay receipts that explain the current Source Atlas bridge posture.",
                    rows: makeReplayReceiptRows(snapshot: snapshot),
                    footer: "Replay receipts are local and inspectable. They are not a release claim."
                )
            ],
            footer: "Goal Knowledge stays local-first, inspectable, and correction-aware."
        )
    }

    func makeGoalKnowledgeSourceRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let blockedDraftCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let hasEvidence = snapshot.evidence.isEmpty == false || snapshot.feedback.isEmpty == false
        let hasEventLedger = snapshot.eventLedger.isEmpty == false
        let hasLifeContext = snapshot.lifeContextBundles.isEmpty == false

        return [
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-goals",
                icon: "target",
                title: "Goals repository",
                usedWhat: activeGoals.isEmpty ? "No active goals yet." : "\(activeGoals.count) active goals, \(snapshot.goals.count) total goals",
                whyUsed: "Used to keep goal knowledge tied to the user-owned goal graph instead of a hidden profile.",
                sourceName: "Goals",
                sourceState: activeGoals.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: activeGoals.isEmpty ? .unknown : .current,
                riskState: activeGoals.isEmpty ? .medium : .low,
                runtimeUseState: activeGoals.isEmpty ? .notUsed : .usedToPlan,
                needsReview: activeGoals.isEmpty,
                correctionPath: "Open Goal Detail > Edit Goal",
                reviewPath: "Open Goal Detail > Review Goal",
                iconState: activeGoals.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-drafts",
                icon: "square.and.pencil",
                title: "Drafts and staged plans",
                usedWhat: snapshot.drafts.isEmpty ? "No draft compilations yet." : "\(snapshot.drafts.count) drafts, \(snapshot.drafts.filter { $0.stagedPlan != nil }.count) staged plans",
                whyUsed: "Used to explain which drafts can become steps and which ones still need review.",
                sourceName: "Goal drafts",
                sourceState: snapshot.drafts.isEmpty ? .sourceNeeded : .current,
                freshnessState: snapshot.drafts.isEmpty ? .unknown : .current,
                riskState: blockedDraftCount > 0 || clarificationCount > 0 ? .medium : .low,
                runtimeUseState: snapshot.drafts.contains(where: { $0.stagedPlan != nil && $0.latestResultKind != .blocked }) ? .usedToPlan : .notUsed,
                needsReview: blockedDraftCount > 0 || clarificationCount > 0 || snapshot.drafts.isEmpty,
                correctionPath: "Open Goal Detail > Correct Draft",
                reviewPath: "Open Goal Detail > Recompile",
                iconState: blockedDraftCount > 0 ? .warning : .default
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-evidence",
                icon: "checkmark.seal",
                title: "Evidence and feedback",
                usedWhat: hasEvidence ? "\(snapshot.evidence.count) evidence records, \(snapshot.feedback.count) feedback events" : "No evidence or feedback yet.",
                whyUsed: "Used to avoid intention-only planning and to keep recommendations grounded in proof.",
                sourceName: "Evidence",
                sourceState: hasEvidence ? .locallyProven : .sourceNeeded,
                freshnessState: hasEvidence ? .current : .unknown,
                riskState: hasEvidence ? .low : .medium,
                runtimeUseState: hasEvidence ? .usedToPlan : .notUsed,
                needsReview: hasEvidence == false,
                correctionPath: "Open Goal Detail > Add Evidence",
                reviewPath: "Open Goal Detail > Review Evidence",
                iconState: hasEvidence ? .selected : .warning
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-captures",
                icon: "tray.full",
                title: "Captured items",
                usedWhat: snapshot.captures.isEmpty ? "No open captures." : "\(snapshot.captures.filter { $0.status != .archived }.count) open captures, \(snapshot.captures.count) total captures",
                whyUsed: "Used to surface unresolved intent and keep the capture queue visible to planning.",
                sourceName: "Capture",
                sourceState: snapshot.captures.isEmpty ? .sourceNeeded : .current,
                freshnessState: snapshot.captures.isEmpty ? .unknown : .current,
                riskState: snapshot.captures.contains(where: { $0.status != .archived }) ? .medium : .low,
                runtimeUseState: snapshot.captures.contains(where: { $0.status != .archived }) ? .usedToPlan : .notUsed,
                needsReview: snapshot.captures.contains(where: { $0.status != .archived }) || snapshot.captures.isEmpty,
                correctionPath: "Open Capture > Route Capture",
                reviewPath: "Open Capture > Review Capture",
                iconState: snapshot.captures.contains(where: { $0.status != .archived }) ? .selected : .default
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-teaching",
                icon: "bubble.left.and.bubble.right",
                title: "Teaching signals",
                usedWhat: snapshot.teachingSignals.isEmpty ? "No teaching signals yet." : "\(snapshot.teachingSignals.count) teaching signals",
                whyUsed: "Used to correct explanation language and keep future goal knowledge source-tied.",
                sourceName: "Corrections",
                sourceState: snapshot.teachingSignals.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: snapshot.teachingSignals.isEmpty ? .unknown : .current,
                riskState: snapshot.teachingSignals.isEmpty ? .medium : .low,
                runtimeUseState: snapshot.teachingSignals.isEmpty ? .notUsed : .usedToPlan,
                needsReview: snapshot.teachingSignals.isEmpty,
                correctionPath: "Open Goal Detail > Save Teaching",
                reviewPath: "Open Goal Detail > Review Teaching",
                iconState: snapshot.teachingSignals.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-ledger",
                icon: "list.bullet.rectangle",
                title: "Event ledger",
                usedWhat: hasEventLedger ? "\(snapshot.eventLedger.count) recent ledger entries" : "No recent ledger entries.",
                whyUsed: "Used to explain what changed and to keep replay evidence local.",
                sourceName: "Event Ledger",
                sourceState: hasEventLedger ? .locallyProven : .sourceNeeded,
                freshnessState: hasEventLedger ? .current : .unknown,
                riskState: hasEventLedger ? .low : .medium,
                runtimeUseState: hasEventLedger ? .usedToPlan : .notUsed,
                needsReview: hasEventLedger == false,
                correctionPath: "Open Goal Detail > Review History",
                reviewPath: "Open Goal Detail > Replay History",
                iconState: hasEventLedger ? .selected : .default
            ),
            makeSourceAtlasKnowledgeRow(
                id: "goal-source-life-context",
                icon: "person.2",
                title: "Life context bundles",
                usedWhat: hasLifeContext ? "\(snapshot.lifeContextBundles.count) local context bundle(s)" : "No life context bundle yet.",
                whyUsed: "Used to fit goals to the user's real life before a path or step is accepted.",
                sourceName: "Life Context",
                sourceState: hasLifeContext ? .locallyProven : .sourceNeeded,
                freshnessState: hasLifeContext ? .current : .unknown,
                riskState: hasLifeContext ? .medium : .unknown,
                runtimeUseState: hasLifeContext ? .usedToPlan : .notUsed,
                needsReview: hasLifeContext == false,
                correctionPath: "Open Life Context > Correct Facts",
                reviewPath: "Open Life Context > Review Context",
                iconState: hasLifeContext ? .selected : .warning
            )
        ]
    }

    func makeActiveSourcePackRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let activeGoals = snapshot.goals.filter { $0.state == .active }
        let goalsWithPlans = snapshot.goals.filter { $0.plan != nil }
        let totalPlannedSteps = goalsWithPlans.flatMap { $0.plan?.sections ?? [] }.flatMap(\.steps).count

        return [
            makeSourceAtlasKnowledgeRow(
                id: "pack-goals",
                icon: "scope",
                title: "Goal source pack",
                usedWhat: activeGoals.isEmpty ? "No active goal pack yet." : "\(activeGoals.count) active goals feed the pack",
                whyUsed: "Used to keep the current goal set available for planning and review.",
                sourceName: "Goals + plans",
                sourceState: activeGoals.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: activeGoals.isEmpty ? .unknown : .current,
                riskState: activeGoals.isEmpty ? .medium : .low,
                runtimeUseState: activeGoals.isEmpty ? .notUsed : .usedToPlan,
                needsReview: activeGoals.isEmpty,
                correctionPath: "Open Goals > Edit Pack",
                reviewPath: "Open Goals > Review Pack",
                iconState: activeGoals.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "pack-paths",
                icon: "arrow.triangle.branch",
                title: "Path source pack",
                usedWhat: goalsWithPlans.isEmpty ? "No path pack yet." : "\(goalsWithPlans.count) goals with plans",
                whyUsed: "Used to keep the path shape visible before a step is accepted.",
                sourceName: "Goal plans",
                sourceState: goalsWithPlans.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: goalsWithPlans.isEmpty ? .unknown : .current,
                riskState: goalsWithPlans.isEmpty ? .medium : .low,
                runtimeUseState: goalsWithPlans.isEmpty ? .notUsed : .usedToPlan,
                needsReview: goalsWithPlans.isEmpty,
                correctionPath: "Open Goal Detail > Edit Path",
                reviewPath: "Open Goal Detail > Review Path",
                iconState: goalsWithPlans.isEmpty ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "pack-steps",
                icon: "checklist",
                title: "Step source pack",
                usedWhat: totalPlannedSteps == 0 ? "No step pack yet." : "\(totalPlannedSteps) planned step(s)",
                whyUsed: "Used to keep step-level planning local and inspectable.",
                sourceName: "Goal path steps",
                sourceState: totalPlannedSteps == 0 ? .sourceNeeded : .locallyProven,
                freshnessState: totalPlannedSteps == 0 ? .unknown : .current,
                riskState: totalPlannedSteps == 0 ? .medium : .low,
                runtimeUseState: totalPlannedSteps == 0 ? .notUsed : .usedToPlan,
                needsReview: totalPlannedSteps == 0,
                correctionPath: "Open Goal Detail > Edit Steps",
                reviewPath: "Open Goal Detail > Review Steps",
                iconState: totalPlannedSteps == 0 ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "pack-replay",
                icon: "arrow.clockwise",
                title: "Replay source pack",
                usedWhat: snapshot.eventLedger.isEmpty ? "No replay pack yet." : "\(snapshot.eventLedger.count) replayable local event(s)",
                whyUsed: "Used to explain the current bridge receipt and replay posture.",
                sourceName: "Replay receipts",
                sourceState: snapshot.eventLedger.isEmpty ? .sourceNeeded : .locallyProven,
                freshnessState: snapshot.eventLedger.isEmpty ? .unknown : .current,
                riskState: snapshot.eventLedger.isEmpty ? .medium : .low,
                runtimeUseState: snapshot.eventLedger.isEmpty ? .notUsed : .usedToPlan,
                needsReview: snapshot.eventLedger.isEmpty,
                correctionPath: "Open Receipts > Correct Replay",
                reviewPath: "Open Receipts > Review Replay",
                iconState: snapshot.eventLedger.isEmpty ? .warning : .selected
            )
        ]
    }

    func makeNeedsReviewRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let blockedDraftCount = snapshot.drafts.filter { $0.latestResultKind == .blocked }.count
        let clarificationCount = snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count
        let goalsWithoutPlans = snapshot.goals.filter { $0.plan == nil && $0.state == .active }.count
        let staleSignals = snapshot.eventLedger.isEmpty || snapshot.evidence.isEmpty

        var rows: [YouSourceAtlasKnowledgeRow] = []

        if blockedDraftCount > 0 {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-blocked-drafts",
                    icon: "exclamationmark.triangle",
                    title: "Blocked drafts",
                    usedWhat: "\(blockedDraftCount) blocked draft(s)",
                    whyUsed: "These drafts need review before they can become a source-backed path.",
                    sourceName: "Drafts",
                    sourceState: .sourceNeeded,
                    freshnessState: .stale,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Fix Draft",
                    reviewPath: "Open Goal Detail > Review Blocker",
                    iconState: .warning
                )
            )
        }

        if clarificationCount > 0 {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-clarifications",
                    icon: "questionmark.circle",
                    title: "Clarification needed",
                    usedWhat: "\(clarificationCount) draft(s) still need an answer",
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
            )
        }

        if goalsWithoutPlans > 0 {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-goals-without-plans",
                    icon: "circle.dashed",
                    title: "Goals without plans",
                    usedWhat: "\(goalsWithoutPlans) active goal(s) have no plan yet",
                    whyUsed: "Goal knowledge stays incomplete until a plan or source pack exists.",
                    sourceName: "Goals",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .high,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Add Path",
                    reviewPath: "Open Goal Detail > Review Goal",
                    iconState: .warning
                )
            )
        }

        if staleSignals {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-stale-signals",
                    icon: "clock.arrow.circlepath",
                    title: "Stale local signals",
                    usedWhat: snapshot.eventLedger.isEmpty ? "No ledger replay yet." : "Evidence or ledger freshness needs another check.",
                    whyUsed: "This row stays visible when the local proof chain is still thin.",
                    sourceName: "Evidence / ledger",
                    sourceState: .stale,
                    freshnessState: .stale,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Receipts > Refresh Evidence",
                    reviewPath: "Open Receipts > Review Freshness",
                    iconState: .warning
                )
            )
        }

        if rows.isEmpty {
            rows.append(
                makeSourceAtlasKnowledgeRow(
                    id: "review-none",
                    icon: "checkmark.seal",
                    title: "No current review gaps",
                    usedWhat: "No source area currently needs review.",
                    whyUsed: "The section stays visible so review gaps do not disappear from You.",
                    sourceName: "Local source atlas",
                    sourceState: .current,
                    freshnessState: .current,
                    riskState: .low,
                    runtimeUseState: .notUsed,
                    needsReview: false,
                    correctionPath: "Open Goal Detail > Correct If Needed",
                    reviewPath: "Open Goal Detail > Review Later",
                    iconState: .success
                )
            )
        }

        return rows
    }

}
