import Foundation

struct RepositoryBackedHabitsService: HabitsServicing {
    let repositories: AppRepositories

    func loadDashboard(now: Date) async throws -> HabitsDashboard {
        let snapshot = try await loadSnapshot()
        return makeDashboard(snapshot: snapshot, now: now)
    }

    func performAction(_ request: HabitActionRequest, now: Date) async throws -> HabitActionResponse {
        guard var goal = try await repositories.goals.goal(id: request.target.goalID),
              let step = goal.plan?.sections.flatMap(\.steps).first(where: { $0.id == request.target.stepID }) else {
            return HabitActionResponse(
                message: HabitInlineMessage(
                    title: "Ritual moved",
                    body: "That routine is no longer available in the current native snapshot.",
                    state: .warning
                )
            )
        }

        let cadenceDays = HabitGoalSemantics.cadenceDays(goal: goal, step: step)
        var feedback = try await repositories.feedback.listEvents(goalID: goal.id)
        let timestamp = Self.iso.string(from: now)
        let base = GoalFeedbackEventBase(
            id: "habit-\(request.kind.rawValue)-\(UUID().uuidString)",
            stepID: step.id,
            occurredAt: timestamp,
            note: note(for: request.kind, step: step)
        )

        let message: HabitInlineMessage

        switch request.kind {
        case .complete:
            feedback.append(.completed(base: base, actualDuration: stepMinutes(for: goal.mode), effortLevel: .low, confidenceDelta: 0.06))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "habit-evidence-\(UUID().uuidString)",
                    goalID: goal.id,
                    stepID: step.id,
                    evidenceKind: .habitCompletion,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.16,
                    confidenceDelta: 0.06,
                    minutesInvested: stepMinutes(for: goal.mode),
                    note: Self.completeNote
                )
            ])
            goal = advance(goal: goal, step: step, now: now, cadenceDays: cadenceDays)
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(
                title: "Ritual logged",
                body: "Today's full version is recorded. The rhythm stays active without pretending the loop is finished forever.",
                state: .success
            )
        case .minimumVersion:
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "habit-evidence-\(UUID().uuidString)",
                    goalID: goal.id,
                    stepID: step.id,
                    evidenceKind: .habitMinimumVersion,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.08,
                    confidenceDelta: 0.03,
                    minutesInvested: 5,
                    note: "\(Self.minimumNotePrefix)\(step.actionability.fallbackMicroStep)"
                )
            ])
            goal = advance(goal: goal, step: step, now: now, cadenceDays: cadenceDays)
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(
                title: "Minimum version counts",
                body: step.actionability.fallbackMicroStep,
                state: .success
            )
        case .quickLog:
            try await repositories.evidence.saveEvidence([
                ProgressEvidence(
                    id: "habit-evidence-\(UUID().uuidString)",
                    goalID: goal.id,
                    stepID: step.id,
                    evidenceKind: .habitQuickLog,
                    source: .manual,
                    capturedAt: timestamp,
                    progressDelta: 0.05,
                    confidenceDelta: 0.02,
                    minutesInvested: 10,
                    note: Self.quickLogNote
                )
            ])
            message = HabitInlineMessage(
                title: "Signal captured",
                body: "Progress was logged without forcing a full completion label.",
                state: .selected
            )
        case .delay:
            feedback.append(.delayed(base: base, timingAdjustment: .laterToday, date: nil))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            goal = update(goal: goal, stepID: step.id) { current in
                stepCopy(from: current, timing: shiftedTiming(current.timing, now: now, adjustment: .laterToday))
            }
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(
                title: "Delayed without drama",
                body: "The routine stays live, but the system is no longer treating it like it had to happen right now.",
                state: .selected
            )
        case .skip:
            feedback.append(.skipped(base: base, reasonCode: .notNow))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            goal = update(goal: goal, stepID: step.id) { current in
                stepCopy(from: current, timing: HabitGoalSemantics.advancedTiming(from: current.timing, now: now, cadenceDays: cadenceDays))
            }
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(
                title: "Skipped, still okay",
                body: "Today's window was intentionally let go. The next cadence point is already in place.",
                state: .warning
            )
        case .needsEasierVersion:
            feedback.append(.askedForSmallerVersion(base: base))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            message = HabitInlineMessage(
                title: "Easier version noted",
                body: "Use this minimum version next: \(step.actionability.fallbackMicroStep)",
                state: .selected
            )
        case .markNotRelevant:
            feedback.append(.notRelevant(base: base))
            try await repositories.feedback.saveEvents(feedback, goalID: goal.id)
            goal = Goal(
                schemaVersion: goal.schemaVersion,
                id: goal.id,
                revision: goal.revision + 1,
                createdAt: goal.createdAt,
                updatedAt: timestamp,
                state: .paused,
                title: goal.title,
                summary: goal.summary,
                mode: goal.mode,
                relationshipKind: goal.relationshipKind,
                actor: goal.actor,
                parentGoalID: goal.parentGoalID,
                childGoalIDs: goal.childGoalIDs,
                supportGoalIDs: goal.supportGoalIDs,
                tags: goal.tags,
                timing: goal.timing,
                planningStrategy: goal.planningStrategy,
                progressStrategy: goal.progressStrategy,
                plan: goal.plan,
                lifeGraph: goal.lifeGraph
            )
            try await repositories.goals.saveGoals([goal])
            message = HabitInlineMessage(
                title: "Plan flagged for review",
                body: "This routine has been softened out of the active loop until the ritual plan is corrected.",
                state: .warning
            )
        case .openDetail:
            message = HabitInlineMessage(
                title: "Opening ritual context",
                body: "This ritual is linked back to the full goal context so cadence, support language, and replanning all stay aligned.",
                state: .selected
            )
        }

        return HabitActionResponse(message: message)
    }
}

private extension RepositoryBackedHabitsService {
    struct Snapshot {
        let goals: [Goal]
        let drafts: [PersistedGoalDraft]
        let evidence: [ProgressEvidence]
        let feedback: [GoalFeedbackEvent]
        let appState: AppStateSnapshot
    }

    struct HabitContext {
        let goal: Goal
        let draftID: String?
        let step: Step
        let status: HabitTodayState
        let currentStreak: Int
        let bestStreak: Int
        let consistency: Double
        let recoveryCount: Int
    }

    func loadSnapshot() async throws -> Snapshot {
        async let goals = repositories.goals.listHabitGoals()
        async let drafts = repositories.drafts.listDrafts()
        async let evidence = repositories.evidence.listEvidence(goalID: nil)
        async let feedback = repositories.feedback.listEvents(goalID: nil)
        async let appState = repositories.appState.loadState()

        return try await Snapshot(
            goals: goals,
            drafts: drafts,
            evidence: evidence,
            feedback: feedback,
            appState: appState
        )
    }

    func makeDashboard(snapshot: Snapshot, now: Date) -> HabitsDashboard {
        let draftIDsByGoal: [String: String] = Dictionary(uniqueKeysWithValues: snapshot.drafts.compactMap { draft in
            guard let goalID = draft.plannedGoalID else { return nil }
            return (goalID, draft.id)
        })

        let contexts = snapshot.goals.compactMap { goal -> HabitContext? in
            guard goal.state == .active || goal.state == .paused else { return nil }
            guard let step = HabitGoalSemantics.preferredStep(in: goal) else { return nil }
            guard HabitGoalSemantics.isHabitLike(goal: goal, step: step) else { return nil }

            let goalEvidence = snapshot.evidence.filter { $0.goalID == goal.id }
            let stepIDs: Set<String> = Set(goal.plan?.sections.flatMap(\.steps).map(\.id) ?? [])
            let goalFeedback = snapshot.feedback.filter { stepIDs.contains($0.stepID) }
            let cadenceDays = HabitGoalSemantics.cadenceDays(goal: goal, step: step)
            let positive = positiveDates(from: goalEvidence, feedback: goalFeedback)

            return HabitContext(
                goal: goal,
                draftID: draftIDsByGoal[goal.id],
                step: step,
                status: todayState(goal: goal, evidence: goalEvidence, feedback: goalFeedback, cadenceDays: cadenceDays, now: now),
                currentStreak: streakLength(for: positive, cadenceDays: cadenceDays, now: now),
                bestStreak: bestStreakLength(for: positive, cadenceDays: cadenceDays),
                consistency: consistencyRatio(for: positive, cadenceDays: cadenceDays, now: now),
                recoveryCount: recoveredSlipCount(positiveDates: positive, feedback: goalFeedback, cadenceDays: cadenceDays)
            )
        }

        let activeContexts = contexts.filter { ![.recovery, .skipped, .needsEasierVersion, .notRelevant].contains($0.status) }
        let recoveryContexts = contexts.filter { !activeContexts.map(\.goal.id).contains($0.goal.id) }
        let totalHabits = contexts.count
        let completedToday = contexts.filter { $0.status == .completed }.count
        let minimumToday = contexts.filter { $0.status == .minimumDone }.count
        let recoveryCount = recoveryContexts.count
        let bestStreak = contexts.map(\.bestStreak).max() ?? 0
        let seeded = snapshot.appState.lastSeedVersion == DemoSeedPipeline.seedVersion

        let mode: HabitsExperienceMode = {
            if contexts.isEmpty { return .empty }
            if recoveryCount > 0 && activeContexts.isEmpty { return .recovery }
            if seeded { return .seeded }
            return .active
        }()

        return HabitsDashboard(
            mode: mode,
            title: heroTitle(for: mode),
            subtitle: heroSubtitle(for: mode, totalHabits: totalHabits, recoveryCount: recoveryCount),
            summaryLabel: "\(completedToday + minimumToday) of \(max(totalHabits, 1)) rituals touched today",
            summaryDetail: summaryDetail(mode: mode, completedToday: completedToday, minimumToday: minimumToday, recoveryCount: recoveryCount),
            stats: [
                MetricSummary(id: "habit-stat-complete", title: "Completed", value: "\(completedToday)", detail: "Full versions today", icon: "checkmark.circle.fill"),
                MetricSummary(id: "habit-stat-minimum", title: "Minimum versions", value: "\(minimumToday)", detail: "Counted without overreach", icon: "leaf.circle"),
                MetricSummary(id: "habit-stat-recovery", title: "Recovery", value: "\(recoveryCount)", detail: "Loops needing care", icon: "arrow.uturn.backward.circle"),
                MetricSummary(id: "habit-stat-streak", title: "Best streak", value: "\(bestStreak)", detail: "Current dashboard range", icon: "flame.fill")
            ],
            habits: activeContexts.sorted(by: habitSortDescriptor(now: now)).map(makeHabitSummary),
            recoveryHabits: recoveryContexts.sorted(by: habitSortDescriptor(now: now)).map(makeHabitSummary),
            streak: StreakSummary(
                title: recoveryCount > 0 ? "Consistency survives misses" : "Rhythm is compounding",
                subtitle: recoveryCount > 0
                    ? "Recovery is being shown as part of the system, not as a scarlet letter."
                    : "Streaks stay useful here because they explain consistency without turning into pressure theater.",
                stats: [
                    MetricSummary(id: "streak-current", title: "Current streak", value: "\(contexts.map(\.currentStreak).max() ?? 0)", detail: "Best live rhythm", icon: "flame"),
                    MetricSummary(id: "streak-consistency", title: "Consistency", value: "\(Int((contexts.map(\.consistency).reduce(0, +) / Double(max(contexts.count, 1))) * 100))%", detail: "Last 14 days", icon: "checkmark.seal"),
                    MetricSummary(id: "streak-recovery", title: "Recovered slips", value: "\(contexts.map(\.recoveryCount).reduce(0, +))", detail: "Recent rebounds", icon: "waveform.path.ecg")
                ],
                recoveryNote: recoveryCount > 0
                    ? "When a day gets disrupted, the next step should get easier and clearer, not louder."
                    : "Keep the loop small enough that it still fits on the days with less margin."
            ),
            guidanceTitle: guidanceTitle(for: mode),
            guidanceBody: guidanceBody(for: mode),
            emptyTitle: mode == .empty ? "No rituals are live yet" : nil,
            emptyMessage: mode == .empty
                ? "As soon as a recurring goal or routine exists in the native planner, Rituals will read it directly from the same repository Today and Goals use."
                : nil
        )
    }

    func makeHabitSummary(_ context: HabitContext) -> HabitSummary {
        let target = HabitActionTarget(goalID: context.goal.id, stepID: context.step.id, draftID: context.draftID)
        return HabitSummary(
            id: context.goal.id,
            target: target,
            title: context.goal.title,
            subtitle: context.step.summary ?? context.goal.summary ?? context.step.actionability.completionDefinition,
            cadenceLabel: HabitGoalSemantics.cadenceLabel(goal: context.goal, step: context.step),
            streakLabel: context.currentStreak == 0 ? "Restart gently today" : "\(context.currentStreak)-day streak",
            consistencyLabel: context.bestStreak > context.currentStreak
                ? "\(Int(context.consistency * 100))% consistency • best \(context.bestStreak)"
                : "\(Int(context.consistency * 100))% consistency",
            progress: context.consistency,
            progressLabel: "\(Int(context.consistency * 100))% consistency",
            status: context.status,
            note: note(for: context.status),
            minimumVersionLabel: HabitGoalSemantics.minimumVersionText(for: context.step),
            supportLabel: context.goal.mode == .delegatedSupport ? "Support \(context.goal.actor.displayName) without making them the task." : nil,
            actions: actions(for: context, target: target)
        )
    }

    func actions(for context: HabitContext, target: HabitActionTarget) -> [HabitActionState] {
        var items: [HabitActionState] = [
            HabitActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
            HabitActionState(kind: .minimumVersion, title: "Minimum version", systemImage: "leaf", state: .selected, target: target),
            HabitActionState(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .default, target: target),
            HabitActionState(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default, target: target),
            HabitActionState(kind: .skip, title: "Skip", systemImage: "forward.fill", state: .warning, target: target),
            HabitActionState(kind: .needsEasierVersion, title: "Need easier version", systemImage: "scissors", state: .selected, target: target),
            HabitActionState(kind: .markNotRelevant, title: "Plan is wrong", systemImage: "nosign", state: .warning, target: target),
            HabitActionState(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
        ]

        if context.status == .completed || context.status == .minimumDone {
            items.removeAll(where: { $0.kind == .complete || $0.kind == .minimumVersion })
        }

        return items
    }

    func todayState(goal: Goal, evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent], cadenceDays: Int, now: Date) -> HabitTodayState {
        let dayStart = Calendar.current.startOfDay(for: now)
        let todayEvidence = evidence.filter { isSameDay($0.capturedAt, as: dayStart) }
        let todayFeedback = feedback.filter { isSameDay($0.base.occurredAt, as: dayStart) }

        if goal.state == .paused { return .notRelevant }
        if todayEvidence.contains(where: { $0.note == Self.completeNote || $0.evidenceKind == .stepCompleted || $0.evidenceKind == .habitCompletion }) ||
            todayFeedback.contains(where: { if case .completed = $0 { return true } else { return false } }) {
            return .completed
        }
        if todayEvidence.contains(where: { $0.evidenceKind == .habitMinimumVersion || $0.note?.hasPrefix(Self.minimumNotePrefix) == true }) { return .minimumDone }
        if todayEvidence.contains(where: { $0.evidenceKind == .habitQuickLog || $0.note == Self.quickLogNote }) { return .partial }
        if todayFeedback.contains(where: { if case .notRelevant = $0 { return true } else { return false } }) { return .notRelevant }
        if todayFeedback.contains(where: { if case .askedForSmallerVersion = $0 { return true } else { return false } }) { return .needsEasierVersion }
        if todayFeedback.contains(where: { if case .skipped = $0 { return true } else { return false } }) { return .skipped }
        if todayFeedback.contains(where: { if case .delayed = $0 { return true } else { return false } }) { return .delayed }
        if goal.mode == .delegatedSupport { return .supportive }

        let positive = positiveDates(from: evidence, feedback: feedback)
        guard let lastPositive = positive.sorted().last else { return .ready }
        let daysSince = Calendar.current.dateComponents([.day], from: lastPositive, to: dayStart).day ?? 0
        return daysSince > cadenceDays ? .recovery : .ready
    }

    func positiveDates(from evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent]) -> [Date] {
        let evidenceDates = evidence.compactMap { evidence in startOfDay(for: evidence.capturedAt) }
        let feedbackDates = feedback.compactMap { event -> Date? in
            if case .completed = event { return startOfDay(for: event.base.occurredAt) }
            return nil
        }
        return Array(Set(evidenceDates + feedbackDates)).sorted()
    }

    func streakLength(for dates: [Date], cadenceDays: Int, now: Date) -> Int {
        guard !dates.isEmpty else { return 0 }
        let sorted = dates.sorted(by: >)
        let anchor = Calendar.current.startOfDay(for: now)
        guard let first = sorted.first,
              let gap = Calendar.current.dateComponents([.day], from: first, to: anchor).day,
              gap <= cadenceDays else { return 0 }

        var streak = 1
        for pair in zip(sorted, sorted.dropFirst()) {
            let distance = Calendar.current.dateComponents([.day], from: pair.1, to: pair.0).day ?? cadenceDays + 1
            if distance <= cadenceDays {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }

    func bestStreakLength(for dates: [Date], cadenceDays: Int) -> Int {
        guard !dates.isEmpty else { return 0 }
        let sorted = dates.sorted()
        var longest = 1
        var current = 1
        for pair in zip(sorted, sorted.dropFirst()) {
            let distance = Calendar.current.dateComponents([.day], from: pair.0, to: pair.1).day ?? cadenceDays + 1
            if distance <= cadenceDays {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    func consistencyRatio(for dates: [Date], cadenceDays: Int, now: Date) -> Double {
        let expectedWindows = max(1, Int(ceil(14.0 / Double(cadenceDays))))
        let cutoff = Calendar.current.date(byAdding: .day, value: -13, to: Calendar.current.startOfDay(for: now)) ?? now
        let recentCount = dates.filter { $0 >= cutoff }.count
        return min(1, Double(recentCount) / Double(expectedWindows))
    }

    func recoveredSlipCount(positiveDates: [Date], feedback: [GoalFeedbackEvent], cadenceDays: Int) -> Int {
        let sortedPositive = positiveDates.sorted()
        return feedback.reduce(into: 0) { count, event in
            guard case .skipped = event, let skipDate = startOfDay(for: event.base.occurredAt) else { return }
            if sortedPositive.contains(where: { logged in
                let delta = Calendar.current.dateComponents([.day], from: skipDate, to: logged).day ?? cadenceDays + 2
                return logged >= skipDate && delta <= cadenceDays + 1
            }) {
                count += 1
            }
        }
    }

    func heroTitle(for mode: HabitsExperienceMode) -> String {
        switch mode {
        case .empty: "Consistency, once it exists"
        case .seeded: "Consistency that already lives in native data"
        case .active: "Consistency that stays calm"
        case .recovery: "Recovery is part of consistency"
        }
    }

    func heroSubtitle(for mode: HabitsExperienceMode, totalHabits: Int, recoveryCount: Int) -> String {
        switch mode {
        case .empty:
            return "Rituals become real as soon as a recurring goal or routine exists. There is no detached subsystem behind this screen."
        case .seeded:
            return "Rituals are already reading from the same native goal, evidence, and feedback records that power Today and Goal Detail."
        case .active:
            return totalHabits == 1
                ? "One ritual loop is active. The goal is clarity and repeatability, not pressure."
                : "\(totalHabits) ritual loops are active. Fast logging keeps them lightweight enough to survive real days."
        case .recovery:
            return recoveryCount == 1
                ? "One loop needs a gentler restart. Ambitions keeps that visible without turning it punitive."
                : "\(recoveryCount) loops need recovery framing. The screen is prioritizing ease over guilt."
        }
    }

    func summaryDetail(mode: HabitsExperienceMode, completedToday: Int, minimumToday: Int, recoveryCount: Int) -> String {
        _ = completedToday
        switch mode {
        case .empty:
            return "When planning adds recurring structure, Rituals will translate it into a quick daily interaction surface automatically."
        case .seeded, .active:
            if recoveryCount == 0 {
                return minimumToday > 0
                    ? "Minimum versions are already being counted as real wins today."
                    : "The screen is emphasizing only the steps that help today's rhythm stay alive."
            }
            return "Some rituals need recovery framing, but the rest can stay quick and obvious."
        case .recovery:
            return "Recovery is leading the screen today so the next action gets easier instead of louder."
        }
    }

    func guidanceTitle(for mode: HabitsExperienceMode) -> String {
        switch mode {
        case .empty: "How Rituals will wake up"
        case .seeded: "Why this feels native"
        case .active: "How to use the screen"
        case .recovery: "How to recover cleanly"
        }
    }

    func guidanceBody(for mode: HabitsExperienceMode) -> String {
        switch mode {
        case .empty:
            "Rituals are waiting on recurring structure from the native planner and goal engine, not on a separate tracker."
        case .seeded:
            "Every card here is derived from live native goal records, steps, evidence, and feedback, with starter data only filling the gap before personal history builds up."
        case .active:
            "Use full completion when the routine really landed, minimum version when the smallest valid version happened, and quick log when signal matters more than ceremony."
        case .recovery:
            "If a loop is slipping, mark that it needs an easier version first. Recovery should change the size of the ask before it changes your self-story."
        }
    }

    func note(for status: HabitTodayState) -> String {
        switch status {
        case .completed: "Today's full version is already in the log."
        case .minimumDone: "The minimum version counted today. That still keeps the rhythm alive."
        case .partial: "Partial signal is recorded, so you do not need to start from zero mentally."
        case .delayed: "This was delayed to soften pressure, not to create debt."
        case .skipped: "A skipped day is visible here so the next repetition can restart cleanly."
        case .recovery: "This loop wants a gentler restart or a smaller ask."
        case .needsEasierVersion: "The plan is asking for a smaller version before it asks for more consistency."
        case .notRelevant: "The routine was flagged because the current ritual plan no longer fits."
        case .supportive: "This ritual is framed as supportive structure, not as control over someone else."
        case .ready: "The next repetition is still small enough to do quickly."
        }
    }

    func habitSortDescriptor(now: Date) -> (HabitContext, HabitContext) -> Bool {
        { lhs, rhs in
            let lhsPriority = sortPriority(for: lhs.status)
            let rhsPriority = sortPriority(for: rhs.status)
            if lhsPriority != rhsPriority { return lhsPriority < rhsPriority }
            let lhsDate = parseDate(lhs.step.timing.suggestedNextAt) ?? parseDate(lhs.goal.updatedAt) ?? now
            let rhsDate = parseDate(rhs.step.timing.suggestedNextAt) ?? parseDate(rhs.goal.updatedAt) ?? now
            if lhsDate != rhsDate { return lhsDate < rhsDate }
            return lhs.goal.title < rhs.goal.title
        }
    }

    func sortPriority(for status: HabitTodayState) -> Int {
        switch status {
        case .ready, .supportive: 0
        case .recovery, .needsEasierVersion: 1
        case .delayed, .skipped: 2
        case .partial, .minimumDone: 3
        case .completed: 4
        case .notRelevant: 5
        }
    }

    func note(for action: HabitActionKind, step: Step) -> String {
        switch action {
        case .complete: "Completed from Rituals."
        case .skip: "Skipped from Rituals without punitive language."
        case .delay: "Delayed from Rituals to soften pressure."
        case .minimumVersion: "Minimum version completed from Rituals."
        case .quickLog: "Quick log from Rituals."
        case .openDetail: step.title
        case .needsEasierVersion: "Asked for an easier version from Rituals."
        case .markNotRelevant: "Marked ritual plan as not relevant from Rituals."
        }
    }

    func advance(goal: Goal, step: Step, now: Date, cadenceDays: Int) -> Goal {
        update(goal: goal, stepID: step.id) { current in
            stepCopy(from: current, timing: HabitGoalSemantics.advancedTiming(from: current.timing, now: now, cadenceDays: cadenceDays))
        }
    }

    func update(goal: Goal, stepID: String, transform: (Step) -> Step) -> Goal {
        let updatedSections = goal.plan?.sections.map { section in
            PlanSection(
                id: section.id,
                goalID: section.goalID,
                title: section.title,
                summary: section.summary,
                kind: section.kind,
                orderIndex: section.orderIndex,
                steps: section.steps.map { $0.id == stepID ? transform($0) : $0 }
            )
        }

        let updatedPlan = goal.plan.map { plan in
            GoalPlan(
                id: plan.id,
                goalID: plan.goalID,
                version: plan.version,
                generatedAt: plan.generatedAt,
                summary: plan.summary,
                strategy: plan.strategy,
                sections: updatedSections ?? plan.sections,
                assumptions: plan.assumptions,
                lint: plan.lint
            )
        }

        return Goal(
            schemaVersion: goal.schemaVersion,
            id: goal.id,
            revision: goal.revision + 1,
            createdAt: goal.createdAt,
            updatedAt: Self.iso.string(from: .now),
            state: goal.state,
            title: goal.title,
            summary: goal.summary,
            mode: goal.mode,
            relationshipKind: goal.relationshipKind,
            actor: goal.actor,
            parentGoalID: goal.parentGoalID,
            childGoalIDs: goal.childGoalIDs,
            supportGoalIDs: goal.supportGoalIDs,
            tags: goal.tags,
            timing: goal.timing,
            planningStrategy: goal.planningStrategy,
            progressStrategy: goal.progressStrategy,
            plan: updatedPlan,
            lifeGraph: goal.lifeGraph
        )
    }

    func stepCopy(from step: Step, timing: GoalTiming) -> Step {
        Step(
            id: step.id,
            sectionID: step.sectionID,
            title: step.title,
            summary: step.summary,
            type: step.type,
            state: step.state,
            owner: step.owner,
            timing: timing,
            dependencyStepIDs: step.dependencyStepIDs,
            isOptional: step.isOptional,
            isRepeatable: step.isRepeatable,
            evidenceRequired: step.evidenceRequired,
            successSignals: step.successSignals,
            actionability: step.actionability
        )
    }

    func shiftedTiming(_ timing: GoalTiming, now: Date, adjustment: GoalTimingAdjustment) -> GoalTiming {
        let shiftedDate = Calendar.current.date(byAdding: .hour, value: 4, to: now) ?? now
        let shiftedValue = adjustment == .removeDeadline ? nil : Self.iso.string(from: shiftedDate)
        return GoalTiming(
            tempo: adjustment == .removeDeadline ? .untimed : timing.tempo,
            timingType: adjustment == .removeDeadline ? .logWhenDone : .suggestedNext,
            startsOn: timing.startsOn,
            dueAt: nil,
            targetBy: nil,
            windowStart: timing.windowStart,
            windowEnd: timing.windowEnd,
            suggestedNextAt: shiftedValue,
            repeatEveryDays: timing.repeatEveryDays,
            progressReviewCadenceDays: timing.progressReviewCadenceDays
        )
    }

    func stepMinutes(for mode: GoalMode) -> Int {
        switch mode {
        case .recovery: 10
        case .delegatedSupport: 12
        default: 20
        }
    }

    func startOfDay(for value: String) -> Date? {
        guard let date = parseDate(value) else { return nil }
        return Calendar.current.startOfDay(for: date)
    }

    func isSameDay(_ value: String, as referenceDayStart: Date) -> Bool {
        guard let date = parseDate(value) else { return false }
        return Calendar.current.isDate(date, inSameDayAs: referenceDayStart)
    }

    func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value)
    }

    static let completeNote = "Ritual completion from Rituals."
    static let quickLogNote = "Quick log from Rituals."
    static let minimumNotePrefix = "Minimum version from Rituals: "

    static let iso: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    static let isoFallback: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
}
