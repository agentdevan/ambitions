import Foundation

extension RepositoryBackedTimeRitualsService {
    func makeDashboard(snapshot: Snapshot, now: Date) -> TimeRitualsDashboard {
        let draftIDsByGoal: [String: String] = Dictionary(uniqueKeysWithValues: snapshot.drafts.compactMap { draft in
            guard let goalID = draft.plannedGoalID else { return nil }
            return (goalID, draft.id)
        })

        let contexts = snapshot.goals.compactMap { goal -> TimeRitualContext? in
            guard goal.state == .active || goal.state == .paused else { return nil }
            guard let step = TimeRitualGoalSemantics.preferredStep(in: goal) else { return nil }
            guard TimeRitualGoalSemantics.isRitualLike(goal: goal, step: step) else { return nil }

            let goalEvidence = snapshot.evidence.filter { $0.goalID == goal.id }
            let stepIDs: Set<String> = Set(goal.plan?.sections.flatMap(\.steps).map(\.id) ?? [])
            let goalFeedback = snapshot.feedback.filter { stepIDs.contains($0.stepID) }
            let cadenceDays = TimeRitualGoalSemantics.cadenceDays(goal: goal, step: step)
            let positive = positiveDates(from: goalEvidence, feedback: goalFeedback)

            return TimeRitualContext(
                goal: goal,
                draftID: draftIDsByGoal[goal.id],
                step: step,
                status: todayState(goal: goal, evidence: goalEvidence, feedback: goalFeedback, cadenceDays: cadenceDays, now: now),
                currentRhythm: rhythmLength(for: positive, cadenceDays: cadenceDays, now: now),
                bestRhythm: bestRhythmLength(for: positive, cadenceDays: cadenceDays),
                consistency: consistencyRatio(for: positive, cadenceDays: cadenceDays, now: now),
                recoveryCount: recoveredSlipCount(positiveDates: positive, feedback: goalFeedback, cadenceDays: cadenceDays)
            )
        }

        let activeContexts = contexts.filter { ![.recovery, .skipped, .needsEasierVersion, .notRelevant].contains($0.status) }
        let recoveryContexts = contexts.filter { !activeContexts.map(\.goal.id).contains($0.goal.id) }
        let totalRituals = contexts.count
        let completedToday = contexts.filter { $0.status == .completed }.count
        let minimumToday = contexts.filter { $0.status == .minimumDone }.count
        let recoveryCount = recoveryContexts.count
        let bestRhythm = contexts.map(\.bestRhythm).max() ?? 0
        let seeded = snapshot.appState.lastSeedVersion == DemoSeedPipeline.seedVersion

        let mode: TimeRitualsExperienceMode = {
            if contexts.isEmpty { return .empty }
            if recoveryCount > 0 && activeContexts.isEmpty { return .recovery }
            if seeded { return .seeded }
            return .active
        }()

        return TimeRitualsDashboard(
            mode: mode,
            title: heroTitle(for: mode),
            subtitle: heroSubtitle(for: mode, totalRituals: totalRituals, recoveryCount: recoveryCount),
            summaryLabel: "\(completedToday + minimumToday) of \(max(totalRituals, 1)) rituals touched today",
            summaryDetail: summaryDetail(mode: mode, completedToday: completedToday, minimumToday: minimumToday, recoveryCount: recoveryCount),
            stats: [
                MetricSummary(id: "ritual-stat-complete", title: "Completed", value: "\(completedToday)", detail: "Full versions today", icon: "checkmark.circle.fill"),
                MetricSummary(id: "ritual-stat-minimum", title: "Minimum versions", value: "\(minimumToday)", detail: "Counted without overreach", icon: "leaf.circle"),
                MetricSummary(id: "ritual-stat-recovery", title: "Recovery", value: "\(recoveryCount)", detail: "Loops needing care", icon: "arrow.uturn.backward.circle"),
                MetricSummary(id: "ritual-stat-rhythm", title: "Best rhythm", value: "\(bestRhythm)", detail: "Current rhythm window", icon: "flame.fill")
            ],
            rituals: activeContexts.sorted(by: ritualSortDescriptor(now: now)).map(makeTimeRitualSummary),
            recoveryRituals: recoveryContexts.sorted(by: ritualSortDescriptor(now: now)).map(makeTimeRitualSummary),
            momentum: TimeRitualMomentumSummary(
                title: recoveryCount > 0 ? "Consistency survives misses" : "Rhythm is compounding",
                subtitle: recoveryCount > 0
                    ? "Recovery is being shown as part of the system, not as a scarlet letter."
                    : "Rhythm stays useful here because it explains consistency without turning into pressure theater.",
                stats: [
                    MetricSummary(id: "rhythm-current", title: "Current rhythm", value: "\(contexts.map(\.currentRhythm).max() ?? 0)", detail: "Best live rhythm", icon: "flame"),
                    MetricSummary(id: "rhythm-consistency", title: "Consistency", value: "\(Int((contexts.map(\.consistency).reduce(0, +) / Double(max(contexts.count, 1))) * 100))%", detail: "Last 14 days", icon: "checkmark.seal"),
                    MetricSummary(id: "rhythm-recovery", title: "Recovered slips", value: "\(contexts.map(\.recoveryCount).reduce(0, +))", detail: "Recent rebounds", icon: "waveform.path.ecg")
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

    func makeTimeRitualSummary(_ context: TimeRitualContext) -> TimeRitualSummary {
        let target = TimeRitualActionTarget(goalID: context.goal.id, stepID: context.step.id, draftID: context.draftID)
        return TimeRitualSummary(
            id: context.goal.id,
            target: target,
            title: context.goal.title,
            subtitle: context.step.summary ?? context.goal.summary ?? context.step.actionability.completionDefinition,
            cadenceLabel: TimeRitualGoalSemantics.cadenceLabel(goal: context.goal, step: context.step),
            rhythmLabel: context.currentRhythm == 0 ? "Restart gently today" : "\(context.currentRhythm) steady days",
            consistencyLabel: context.bestRhythm > context.currentRhythm
                ? "\(Int(context.consistency * 100))% consistency • best \(context.bestRhythm)"
                : "\(Int(context.consistency * 100))% consistency",
            progress: context.consistency,
            progressLabel: "\(Int(context.consistency * 100))% consistency",
            status: context.status,
            note: note(for: context.status),
            minimumVersionLabel: TimeRitualGoalSemantics.minimumVersionText(for: context.step),
            supportLabel: context.goal.mode == .delegatedSupport ? "Support \(context.goal.actor.displayName) without making them the task." : nil,
            actions: actions(for: context, target: target)
        )
    }

    func actions(for context: TimeRitualContext, target: TimeRitualActionTarget) -> [TimeRitualActionState] {
        var items: [TimeRitualActionState] = [
            TimeRitualActionState(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target),
            TimeRitualActionState(kind: .minimumVersion, title: "Minimum version", systemImage: "leaf", state: .selected, target: target),
            TimeRitualActionState(kind: .quickLog, title: "Quick log", systemImage: "plus.bubble", state: .default, target: target),
            TimeRitualActionState(kind: .delay, title: "Delay", systemImage: "clock.arrow.circlepath", state: .default, target: target),
            TimeRitualActionState(kind: .skip, title: "Skip", systemImage: "forward.fill", state: .warning, target: target),
            TimeRitualActionState(kind: .needsEasierVersion, title: "Need easier version", systemImage: "scissors", state: .selected, target: target),
            TimeRitualActionState(kind: .markNotRelevant, title: "Routine is wrong", systemImage: "nosign", state: .warning, target: target),
            TimeRitualActionState(kind: .openDetail, title: "Open detail", systemImage: "arrow.right.circle", state: .default, target: target)
        ]

        if context.status == .completed || context.status == .minimumDone {
            items.removeAll(where: { $0.kind == .complete || $0.kind == .minimumVersion })
        }

        return items
    }
}
