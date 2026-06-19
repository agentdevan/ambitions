import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedGoalsService {

    func detailSubtitle(for mode: GoalMode) -> String {
        switch mode {
        case .achievement:
            return "Outcome-focused work with a clearer finish line."
        case .project:
            return "A structured build with parallel moving parts."
        case .habit:
            return "A repeatable loop that matters over time."
        case .learning:
            return "Skill growth without fake urgency."
        case .exploration:
            return "A path for learning by testing, not by pretending certainty."
        case .maintenance:
            return "Steady upkeep that works best when it stays calm."
        case .recovery:
            return "Gentle forward motion that should not punish your energy."
        case .delegatedSupport:
            return "Supportive structure for someone else's path."
        }
    }


    func intentText(mode: GoalMode, actorName: String, renderState: GoalRenderState) -> String {
        switch renderState {
        case .clarification:
            return "The system is protecting plan quality by showing what still needs to be clarified."
        case .blocked:
            return "The blocker is explicit so you can resolve the actual constraint instead of performing progress."
        default:
            switch mode {
            case .delegatedSupport:
                return "Support \(actorName) with structure that stays collaborative and non-punitive."
            case .learning, .exploration:
                return "Stay oriented to signal and learning, not just step completion."
            case .recovery:
                return "Keep the next step gentle enough that it still happens."
            default:
                return "Understand the path, the next step, and the evidence that proves it is moving."
            }
        }
    }


    func timingNote(for timing: GoalTiming, goalMode: GoalMode) -> String {
        switch goalMode {
        case .delegatedSupport:
            return "Support goals should suggest windows, not impose pressure."
        default:
            switch timing.tempo {
            case .untimed:
                return "This goal is intentionally untimed, so progress is visible without an artificial countdown."
            case .ongoing:
                return "Cadence matters more than a hard finish line here."
            case .targetWindow:
                return "The window matters, but the path still stays flexible."
            case .deadlineBased:
                return "The deadline is real, but the path should still stay session-sized."
            }
        }
    }


    func makeStepItem(step: Step, goalMode: GoalMode) -> GoalDetailStepItem {
        GoalDetailStepItem(
            id: step.id,
            title: step.title,
            summary: step.summary ?? step.actionability.fallbackMicroStep,
            timingLabel: timingLabel(for: step.timing, goalMode: goalMode),
            statusLabel: step.state.rawValue.capitalized,
            state: stepVisualState(step.state)
        )
    }


    func makeEvidenceItem(_ evidence: ProgressEvidence) -> GoalEvidenceItem {
        GoalEvidenceItem(
            id: evidence.id,
            title: evidence.note ?? "Progress signal recorded",
            subtitle: evidence.evidenceKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
            timestamp: evidence.capturedAt,
            state: .success
        )
    }


    func makeProofSpineBead(_ evidence: ProgressEvidence, now: Date) -> ProofBead {
        let freshness = proofFreshness(for: evidence, now: now)
        let correctionLabel = evidence.source == .imported || evidence.source == .migration
            ? "Correction available after import review."
            : "Correction can be reviewed from the proof source."
        let staleReviewLabel = freshness == .stale || freshness == .partial
            ? "Review before recommendations use this proof."
            : nil

        return ProofBead(
            id: evidence.id,
            title: evidence.note ?? "Progress signal recorded",
            summary: evidence.evidenceKind.rawValue.replacingOccurrences(of: "_", with: " ").capitalized,
            sourceLabel: "Source: \(proofSourceTitle(evidence.source))",
            freshness: freshness,
            privacyLabel: proofPrivacyLabel(evidence.source),
            timestampLabel: evidence.capturedAt,
            correctionLabel: correctionLabel,
            staleReviewLabel: staleReviewLabel
        )
    }


    func proofFreshness(for evidence: ProgressEvidence, now: Date) -> SourceFreshnessState {
        switch evidence.source {
        case .aiSuggested:
            return .stale
        case .imported, .migration, .derived:
            return .partial
        case .manual:
            guard
                let capturedAt = ISO8601DateFormatter().date(from: evidence.capturedAt),
                let staleThreshold = Calendar.current.date(byAdding: .day, value: -30, to: now)
            else {
                return .partial
            }

            return capturedAt < staleThreshold ? .stale : .fresh
        }
    }


    func proofSourceTitle(_ source: EvidenceSource) -> String {
        switch source {
        case .manual:
            return "Manual save"
        case .migration:
            return "Migration"
        case .imported:
            return "Imported file"
        case .derived:
            return "Derived local state"
        case .aiSuggested:
            return "Suggested draft"
        }
    }


    func proofPrivacyLabel(_ source: EvidenceSource) -> String {
        switch source {
        case .manual:
            return "Private to this goal unless the user exports it."
        case .migration, .imported:
            return "Imported proof stays local until export or sync is explicitly enabled."
        case .derived:
            return "Derived proof stays on device and needs review before reuse."
        case .aiSuggested:
            return "Suggested proof is not treated as verified user evidence."
        }
    }


    func makeFeedbackItem(_ feedback: GoalFeedbackEvent) -> GoalFeedbackItem {
        let title: String
        let subtitle: String
        let state: AmbitionVisualState

        switch feedback {
        case let .completed(base, _, _, _):
            title = "Completed"
            subtitle = base.note ?? "Completion captured."
            state = .success
        case let .skipped(base, _):
            title = "Skipped"
            subtitle = base.note ?? "Rescheduled."
            state = .warning
        case let .delayed(base, _, _):
            title = "Delayed"
            subtitle = base.note ?? "Pressure softened."
            state = .selected
        case let .edited(base, text):
            title = "Rewritten"
            subtitle = text.isEmpty ? (base.note ?? "Step language changed.") : text
            state = .selected
        case let .confused(base, _):
            title = "Stuck signal"
            subtitle = base.note ?? "The next step was unclear."
            state = .warning
        case let .tooBig(base):
            title = "Too big"
            subtitle = base.note ?? "The current step needs to shrink."
            state = .warning
        case let .tooEasy(base):
            title = "Too easy"
            subtitle = base.note ?? "The current step may not generate enough signal."
            state = .default
        case let .notRelevant(base):
            title = "Not relevant"
            subtitle = base.note ?? "The path needs a relevance check."
            state = .warning
        case let .askedForSmallerVersion(base):
            title = "Asked for smaller step"
            subtitle = base.note ?? "A smaller version was requested."
            state = .selected
        case let .askedWhyThisMatters(base):
            title = "Asked why"
            subtitle = base.note ?? "The plan needs a clearer rationale."
            state = .default
        }

        return GoalFeedbackItem(id: feedback.base.id, title: title, subtitle: subtitle, timestamp: feedback.base.occurredAt, state: state)
    }


    func note(for kind: GoalDetailActionKind, step: Step) -> String {
        switch kind {
        case .complete:
            return "Completed from Goal Detail."
        case .delay:
            return "Delayed from Goal Detail."
        case .skip:
            return "Skipped from Goal Detail without punitive language."
        case .createReminder:
            return "Created reminder from Goal Detail."
        case .createCalendarEvent:
            return "Created calendar event from Goal Detail."
        case .askForSmallerStep:
            return "Asked for a smaller version from Goal Detail."
        case .askWhyThisMatters:
            return "Asked why this matters from Goal Detail."
        case .markNotRelevant:
            return "Marked not relevant from Goal Detail."
        case .breakThisDownSmaller:
            return "Asked to break this down smaller."
        case .imStuck:
            return "Marked as stuck from Goal Detail."
        case .showPath, .switchToUntimed, .showSupportMode:
            return step.title
        case .raisePriority:
            return "Raised manual priority from Goal Detail."
        case .lowerPriority:
            return "Lowered manual priority from Goal Detail."
        }
    }


    func explainabilitySignals(for context: DetailContext) async throws -> GoalTeachingApplicableSet? {
        if let runtimeContext = try await goalIntelligenceContext(
            for: context,
            primaryStepID: context.primaryStep?.id,
            includeWhyNow: false,
            now: .now
        ) {
            return runtimeContext.applicableSignals
        }
        guard let metadata = context.draft?.metadata else { return nil }
        let goalID = context.goal?.id ?? context.draft?.plannedGoalID ?? metadata.context.goalID
        guard let goalID else { return nil }
        return try await teachingService.applicableSignals(goalID: goalID, metadata: metadata)
    }


    func goalIntelligenceContext(
        for context: DetailContext,
        primaryStepID: String?,
        includeWhyNow: Bool,
        now: Date
    ) async throws -> RuntimeGoalIntelligenceContext? {
        guard let goalIntelligenceService else { return nil }
        return try await goalIntelligenceService.loadContext(
            RuntimeGoalIntelligenceRequest(
                target: context.target,
                primaryStepID: primaryStepID,
                includeWhyNow: includeWhyNow
            ),
            now: now
        )
    }


    func correctionMessage(for signal: GoalTeachingSignal) -> String {
        switch signal.kind {
        case .requirementRelevanceCorrection:
            return "That support relevance correction is now stored through the canonical teaching layer."
        case .contradictionDispositionCorrection:
            return "That contradiction disposition is now stored through the canonical teaching layer."
        case .energyFitCorrection:
            return "That energy-fit correction is now stored through the canonical teaching layer."
        case .interpretationCorrection, .goalSubjectCorrection, .classificationCorrection:
            return "That correction is now stored through the canonical teaching layer."
        }
    }


    func rescheduleDecision(
        for kind: GoalDetailActionKind,
        goal: Goal,
        step: Step,
        history: [GoalFeedbackEvent],
        now: Date
    ) -> RescheduleDecision? {
        guard let trigger = rescheduleTrigger(for: kind) else { return nil }
        return rescheduleEngine.decide(
            RescheduleEngineInput(
                stepID: step.id,
                timing: step.timing,
                feedbackHistory: history,
                trigger: trigger,
                fallbackMicroStep: step.actionability.fallbackMicroStep,
                now: now,
                planningEvaluation: goal.plan?.evaluation,
                stepState: step.state,
                incompleteDependencyCount: incompleteDependencyCount(in: goal, for: step),
                pathStateSummary: LifeGraphResolver.pathStateSummary(for: goal),
                learningSummary: learningService.buildSnapshot(
                    goals: [goal],
                    evidence: [],
                    feedback: history,
                    now: now
                ).goalSummaries[goal.id]
            )
        )
    }
}
