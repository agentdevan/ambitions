import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTimeService {
    func makeTimeWeeklyReviewState(snapshot: RepositoryBackedTimeService.Snapshot, now: Date) -> TimeWeeklyReviewState {
        let activeGoals = snapshot.goals.filter { $0.state == .active || $0.state == .paused }
        let openCaptures = snapshot.captures.filter { $0.status != .archived }
        let activeGoalSummaries = makeGoalSummaries(goals: activeGoals, feedback: snapshot.feedback, now: now)
        let missingGoalSummaries = activeGoalSummaries.filter { $0.contexts.isEmpty }
        let pressuredGoalSummary = pressuredGoalSummary(from: activeGoalSummaries)
        let ritualGoals = activeGoals.filter { goal in
            guard let step = TimeRitualGoalSemantics.preferredStep(in: goal) else { return goal.mode == .habit }
            return goal.mode == .habit || TimeRitualGoalSemantics.isRitualLike(goal: goal, step: step)
        }
        let weekDays = makeWeekDays(
            summaries: activeGoalSummaries,
            missingGoalSummaries: missingGoalSummaries,
            timeBlocks: snapshot.timeBlocks,
            now: now
        )
        let posture = postureState(
            evaluations: activeGoalSummaries.compactMap(\.evaluation),
            blockedCount: snapshot.drafts.filter { $0.latestResultKind == .blocked }.count,
            clarificationCount: snapshot.drafts.filter { $0.latestResultKind == .clarificationRequired }.count,
            openCaptureCount: openCaptures.count,
            weekDays: weekDays,
            mode: activeGoals.isEmpty && openCaptures.isEmpty ? .empty : .active
        )
        let carryForwardItems = makeWeeklyReviewCarryForwardItems(
            summaries: activeGoalSummaries,
            missingGoalSummaries: missingGoalSummaries,
            pressuredGoalSummary: pressuredGoalSummary,
            openCaptureCount: openCaptures.count
        )
        let splitPaneContext = makeWindowMagnetism(
            weekDays: weekDays,
            missingGoalSummaries: missingGoalSummaries,
            pressuredGoalSummary: pressuredGoalSummary
        )

        return TimeWeeklyReviewState(
            timeframeLabel: timeframeLabel(now: now),
            hero: WeeklyReviewHeroState(
                eyebrow: "Weekly Review",
                title: "Shape what carries forward",
                subtitle: "Weekly review now continues the same authored week workspace instead of becoming a detached ritual.",
                dominantTruth: posture.visualState == .warning
                    ? "The review should reduce strain first, then carry forward only the steps the next week can explain."
                    : "The review can keep what worked, leave room visible, and carry forward only the next believable steps.",
                continuityLabel: "Return to the week with a calmer shape, not a larger list.",
                contextPills: [
                    TimeHeroPillState(title: timeframeLabel(now: now), icon: "calendar", state: .default),
                    TimeHeroPillState(title: posture.label, icon: AmbitionsSurface.time.systemImage, state: posture.visualState),
                    TimeHeroPillState(title: "\(carryForwardItems.count) carry-forward lanes", icon: "arrow.triangle.branch", state: carryForwardItems.isEmpty ? .default : .selected)
                ]
            ),
            summaryTitle: "Why the next week should look different",
            summaryDetail: posture.visualState == .warning
                ? "Carryover, capture pressure, and overloaded days need gentler scope before the next week hardens."
                : "Keep the backbone that worked, then patch only the few things that still deserve a lane next week.",
            carryForwardItems: carryForwardItems,
            captureSummary: openCaptures.isEmpty
                ? "No open captures are demanding carry-forward attention."
                : "\(openCaptures.count) capture\(openCaptures.count == 1 ? "" : "s") still need a calm decision before the next week starts.",
            ritualSupportSummary: ritualGoals.isEmpty
                ? "No recurring loops are currently shaping the review."
                : "\(ritualGoals.count) routine\(ritualGoals.count == 1 ? "" : "s") should support the next week without crowding it.",
            returnActionTitle: "Return to Time",
            returnActionSubtitle: "Use the reshaped week, then adjust one goal or support route only if it still needs help.",
            returnTimeRoute: nil,
            splitPaneContext: splitPaneContext
        )
    }

}
