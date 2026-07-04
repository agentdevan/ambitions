import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedYouService {
    func makeUnsupportedGoalAreaRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let unsupportedGoals = snapshot.goals
            .filter { $0.plan == nil && $0.state != .archived }
            .sorted(by: goalSourceOrdering)

        if unsupportedGoals.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "unsupported-none",
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
            ]
        }

        return unsupportedGoals.prefix(3).map { goal in
            makeSourceAtlasKnowledgeRow(
                id: "unsupported-\(goal.id)",
                icon: "slash.circle",
                title: goal.title,
                usedWhat: goal.summary ?? "No summary recorded.",
                whyUsed: "This goal area still needs a source-backed plan before it can drive a safe path.",
                sourceName: "Goal \(goal.mode.rawValue.replacingOccurrences(of: "_", with: " "))",
                sourceState: .sourceNeeded,
                freshnessState: .unknown,
                riskState: .high,
                runtimeUseState: .notUsed,
                needsReview: true,
                correctionPath: "Open Goal Detail > Add Source",
                reviewPath: "Open Goal Detail > Rebuild Path",
                iconState: .warning
            )
        }
    }

    func makeRecentGoalCompilationRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let recentDrafts = snapshot.drafts.sorted {
            if $0.updatedAt != $1.updatedAt {
                return $0.updatedAt > $1.updatedAt
            }
            return $0.id > $1.id
        }.prefix(3)

        if recentDrafts.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "compilation-none",
                    icon: "rectangle.stack",
                    title: "No recent compilations yet",
                    usedWhat: "No draft compilation exists to inspect yet.",
                    whyUsed: "This row stays visible so the missing compiler output is explicit.",
                    sourceName: "Goal compiler",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goals > Create Draft",
                    reviewPath: "Open Goals > Review Setup",
                    iconState: .warning
                )
            ]
        }

        return recentDrafts.map { draft in
            let hasPlan = draft.stagedPlan != nil
            return makeSourceAtlasKnowledgeRow(
                id: "compilation-\(draft.id)",
                icon: "rectangle.stack.badge.plus",
                title: draft.draft.title,
                usedWhat: draft.stagedPlan?.summary ?? draft.draft.summary ?? "No plan summary recorded.",
                whyUsed: hasPlan ? "Used to compile a source-backed plan for the next step path." : "This draft needs more source before it can become a step path.",
                sourceName: "Drafts",
                sourceState: hasPlan ? .locallyProven : .sourceNeeded,
                freshnessState: hasPlan ? .current : .unknown,
                riskState: hasPlan ? .low : .medium,
                runtimeUseState: hasPlan ? .usedToPlan : .notUsed,
                needsReview: draft.latestResultKind != nil || hasPlan == false,
                correctionPath: "Open Goal Detail > Correct Draft",
                reviewPath: "Open Goal Detail > Review Compilation",
                iconState: hasPlan ? .selected : .warning
            )
        }
    }

    func makePathSourceRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let plannedGoals = snapshot.goals
            .filter { $0.plan != nil }
            .sorted(by: goalSourceOrdering)
        let sections = plannedGoals.flatMap { goal -> [(goal: Goal, section: PlanSection)] in
            guard let plan = goal.plan else { return [] }
            return plan.sections
                .sorted(by: planSectionOrdering)
                .map { (goal, $0) }
        }.prefix(3)

        if sections.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "path-source-none",
                    icon: "arrow.triangle.branch",
                    title: "No path sources yet",
                    usedWhat: "No plan section is available to inspect.",
                    whyUsed: "The path source surface stays visible so missing route source is explicit.",
                    sourceName: "Goal plans",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Add Path",
                    reviewPath: "Open Goal Detail > Review Path",
                    iconState: .warning
                )
            ]
        }

        return sections.map { goal, section in
            makeSourceAtlasKnowledgeRow(
                id: "path-source-\(goal.id)-\(section.id)",
                icon: "arrow.triangle.branch",
                title: "\(goal.title) / \(section.title)",
                usedWhat: section.summary ?? "\(section.steps.count) step(s)",
                whyUsed: "Used to shape the path before step-level source is chosen.",
                sourceName: goal.title,
                sourceState: .locallyProven,
                freshnessState: .current,
                riskState: section.steps.contains(where: { $0.evidenceRequired }) ? .medium : .low,
                runtimeUseState: .usedToPlan,
                needsReview: false,
                correctionPath: "Open Goal Detail > Edit Path",
                reviewPath: "Open Goal Detail > Review Path",
                iconState: .selected
            )
        }
    }

    func makeStepSourceRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let steps = snapshot.goals
            .sorted(by: goalSourceOrdering)
            .flatMap { goal -> [(goal: Goal, section: PlanSection, step: Step)] in
                guard let plan = goal.plan else { return [] }
                return plan.sections
                    .sorted(by: planSectionOrdering)
                    .flatMap { section in
                        section.steps
                            .sorted(by: stepSourceOrdering)
                            .map { step in (goal: goal, section: section, step: step) }
                    }
            }
            .prefix(4)

        if steps.isEmpty {
            return [
                makeSourceAtlasKnowledgeRow(
                    id: "step-source-none",
                    icon: "checklist",
                    title: "No step sources yet",
                    usedWhat: "No step has source detail yet.",
                    whyUsed: "This row stays visible so step source gaps remain obvious.",
                    sourceName: "Plan steps",
                    sourceState: .sourceNeeded,
                    freshnessState: .unknown,
                    riskState: .medium,
                    runtimeUseState: .notUsed,
                    needsReview: true,
                    correctionPath: "Open Goal Detail > Add Step",
                    reviewPath: "Open Goal Detail > Review Steps",
                    iconState: .warning
                )
            ]
        }

        return steps.map { source in
            let step = source.step
            let isActive = step.state == .active || step.state == .planned
            let reviewNeeded = step.state == .blocked || step.evidenceRequired
            return makeSourceAtlasKnowledgeRow(
                id: "step-source-\(step.id)",
                icon: "checklist",
                title: step.title,
                usedWhat: step.summary ?? step.type.rawValue.replacingOccurrences(of: "_", with: " "),
                whyUsed: step.evidenceRequired ? "Used because this step needs proof-aware planning." : "Used to keep the current step path concrete.",
                sourceName: "\(source.goal.title) / \(source.section.title)",
                sourceState: isActive ? .current : .locallyProven,
                freshnessState: step.state == .blocked ? .stale : .current,
                riskState: step.evidenceRequired || step.state == .blocked ? .medium : .low,
                runtimeUseState: isActive ? .usedToPlan : .notUsed,
                needsReview: reviewNeeded,
                correctionPath: "Open Goal Detail > Edit Step",
                reviewPath: "Open Goal Detail > Review Step",
                iconState: reviewNeeded ? .warning : .selected
            )
        }
    }

    func makeSourceAtlasCorrectionRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let correctionCount = snapshot.teachingSignals.count
        let feedbackCount = snapshot.feedback.count

        return [
            makeSourceAtlasKnowledgeRow(
                id: "correction-teaching",
                icon: "bubble.left.and.bubble.right",
                title: "Teaching signals",
                usedWhat: correctionCount == 0 ? "No correction signal yet." : "\(correctionCount) teaching signal(s)",
                whyUsed: "Used to correct future explanations where the user already taught Ambitions better context.",
                sourceName: "Teaching",
                sourceState: correctionCount == 0 ? .sourceNeeded : .locallyProven,
                freshnessState: correctionCount == 0 ? .unknown : .current,
                riskState: correctionCount == 0 ? .medium : .low,
                runtimeUseState: correctionCount == 0 ? .notUsed : .usedToPlan,
                needsReview: correctionCount == 0,
                correctionPath: "Open Goal Detail > Save Teaching",
                reviewPath: "Open Goal Detail > Review Teaching",
                iconState: correctionCount == 0 ? .warning : .selected
            ),
            makeSourceAtlasKnowledgeRow(
                id: "correction-feedback",
                icon: "checkmark.bubble",
                title: "Feedback events",
                usedWhat: feedbackCount == 0 ? "No feedback event yet." : "\(feedbackCount) feedback event(s)",
                whyUsed: "Used to keep correction language and goal knowledge honest after execution.",
                sourceName: "Feedback",
                sourceState: feedbackCount == 0 ? .sourceNeeded : .locallyProven,
                freshnessState: feedbackCount == 0 ? .unknown : .current,
                riskState: feedbackCount == 0 ? .medium : .low,
                runtimeUseState: feedbackCount == 0 ? .notUsed : .usedToPlan,
                needsReview: feedbackCount == 0,
                correctionPath: "Open Goal Detail > Add Feedback",
                reviewPath: "Open Goal Detail > Review Feedback",
                iconState: feedbackCount == 0 ? .warning : .selected
            )
        ]
    }

    func makeReplayReceiptRows(snapshot: Snapshot) -> [YouSourceAtlasKnowledgeRow] {
        let receipts = makeSourceAtlasReplayReceipts(snapshot: snapshot)

        return receipts.map { receipt in
            let reviewNeeded = receipt.kind == .sourceAtlasPackRejected ||
                receipt.kind == .sourceAtlasPublicContextRejected ||
                receipt.kind == .sourceAtlasFreshnessBlocked ||
                receipt.kind == .sourceAtlasUnsupportedGoalFallback
            return makeSourceAtlasKnowledgeRow(
                id: "receipt-\(receipt.id)",
                icon: "arrow.clockwise",
                title: sourceAtlasReceiptTitle(for: receipt.kind),
                usedWhat: receipt.summary,
                whyUsed: receipt.details.isEmpty ? "Replay receipts stay visible so the bridge path can be checked." : receipt.details.joined(separator: " · "),
                sourceName: "Replay receipt",
                sourceState: .locallyProven,
                freshnessState: .current,
                riskState: reviewNeeded ? .medium : .low,
                runtimeUseState: reviewNeeded ? .notUsed : .usedToPlan,
                needsReview: reviewNeeded,
                correctionPath: "Open Receipts > Correct Replay",
                reviewPath: "Open Receipts > Review Replay",
                iconState: reviewNeeded ? .warning : .selected
            )
        }
    }

    func sourceAtlasReceiptTitle(for kind: SourceAtlasBridgeReceiptKind) -> String {
        switch kind {
        case .sourceAtlasIntentMatched:
            return "Intent matched"
        case .sourceAtlasPackSelected:
            return "Pack selected"
        case .sourceAtlasPackRejected:
            return "Pack rejected"
        case .sourceAtlasPublicContextVerified:
            return "Public context verified"
        case .sourceAtlasPublicContextApplied:
            return "Public context applied"
        case .sourceAtlasPublicContextRejected:
            return "Public context rejected"
        case .sourceAtlasPathComposed:
            return "Path composed"
        case .sourceAtlasPathRejected:
            return "Path rejected"
        case .sourceAtlasStepCandidatesExpanded:
            return "Step candidates expanded"
        case .sourceAtlasUnsupportedGoalFallback:
            return "Unsupported goal fallback"
        case .sourceAtlasFreshnessBlocked:
            return "Freshness blocked"
        case .sourceAtlasUserCorrectionApplied:
            return "User correction applied"
        case .sourceAtlasReplayGenerated:
            return "Replay generated"
        }
    }

}
