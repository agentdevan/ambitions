import Foundation

extension RepositoryBackedTimeRitualsService {
    func todayState(goal: Goal, evidence: [ProgressEvidence], feedback: [GoalFeedbackEvent], cadenceDays: Int, now: Date) -> TimeRitualState {
        let dayStart = Calendar.current.startOfDay(for: now)
        let todayEvidence = evidence.filter { isSameDay($0.capturedAt, as: dayStart) }
        let todayFeedback = feedback.filter { isSameDay($0.base.occurredAt, as: dayStart) }

        if goal.state == .paused { return .notRelevant }
        if todayEvidence.contains(where: { $0.note == Self.completeNote || $0.evidenceKind == .stepCompleted || $0.evidenceKind == .ritualCompletion }) ||
            todayFeedback.contains(where: { if case .completed = $0 { return true } else { return false } }) {
            return .completed
        }
        if todayEvidence.contains(where: { $0.evidenceKind == .ritualMinimumVersion || $0.note?.hasPrefix(Self.minimumNotePrefix) == true }) { return .minimumDone }
        if todayEvidence.contains(where: { $0.evidenceKind == .ritualQuickLog || $0.note == Self.quickLogNote }) { return .partial }
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

    func rhythmLength(for dates: [Date], cadenceDays: Int, now: Date) -> Int {
        guard !dates.isEmpty else { return 0 }
        let sorted = dates.sorted(by: >)
        let anchor = Calendar.current.startOfDay(for: now)
        guard let first = sorted.first,
              let gap = Calendar.current.dateComponents([.day], from: first, to: anchor).day,
              gap <= cadenceDays else { return 0 }

        var rhythm = 1
        for pair in zip(sorted, sorted.dropFirst()) {
            let distance = Calendar.current.dateComponents([.day], from: pair.1, to: pair.0).day ?? cadenceDays + 1
            if distance <= cadenceDays {
                rhythm += 1
            } else {
                break
            }
        }
        return rhythm
    }

    func bestRhythmLength(for dates: [Date], cadenceDays: Int) -> Int {
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

    func heroTitle(for mode: TimeRitualsExperienceMode) -> String {
        switch mode {
        case .empty: "Consistency, once it exists"
        case .seeded: "Consistency that already lives in native data"
        case .active: "Consistency that stays calm"
        case .recovery: "Recovery is part of consistency"
        }
    }

    func heroSubtitle(for mode: TimeRitualsExperienceMode, totalRituals: Int, recoveryCount: Int) -> String {
        switch mode {
        case .empty:
            return "Rituals become real as soon as a recurring goal or routine exists. There is no detached subsystem behind this screen."
        case .seeded:
            return "Rituals are already reading from the same native goal, evidence, and feedback records that power Today and Goal Detail."
        case .active:
            return totalRituals == 1
                ? "One ritual loop is active. The goal is clarity and repeatability, not pressure."
                : "\(totalRituals) ritual loops are active. Fast logging keeps them lightweight enough to survive real days."
        case .recovery:
            return recoveryCount == 1
                ? "One loop needs a gentler restart. Ambitions keeps that visible without turning it punitive."
                : "\(recoveryCount) loops need recovery framing. The screen is prioritizing ease over guilt."
        }
    }

    func summaryDetail(mode: TimeRitualsExperienceMode, completedToday: Int, minimumToday: Int, recoveryCount: Int) -> String {
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

    func guidanceTitle(for mode: TimeRitualsExperienceMode) -> String {
        switch mode {
        case .empty: "How Rituals will wake up"
        case .seeded: "Why this feels native"
        case .active: "How to use the screen"
        case .recovery: "How to recover cleanly"
        }
    }

    func guidanceBody(for mode: TimeRitualsExperienceMode) -> String {
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

    func note(for status: TimeRitualState) -> String {
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

    func ritualSortDescriptor(now: Date) -> (TimeRitualContext, TimeRitualContext) -> Bool {
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

    func sortPriority(for status: TimeRitualState) -> Int {
        switch status {
        case .ready, .supportive: 0
        case .recovery, .needsEasierVersion: 1
        case .delayed, .skipped: 2
        case .partial, .minimumDone: 3
        case .completed: 4
        case .notRelevant: 5
        }
    }
}
