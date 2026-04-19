import Foundation

enum RescheduleTrigger: String, Sendable, Equatable {
    case delay
    case skip
    case stuck
    case askForSmallerStep = "ask_for_smaller_step"
}

enum RescheduleDeferRecommendation: String, Sendable, Equatable {
    case none
    case laterToday = "later_today"
    case laterThisWeek = "later_this_week"
    case someday

    var timingAdjustment: GoalTimingAdjustment? {
        switch self {
        case .none:
            return nil
        case .laterToday:
            return .laterToday
        case .laterThisWeek:
            return .laterThisWeek
        case .someday:
            return .someday
        }
    }

    var indicatesDeferral: Bool {
        switch self {
        case .none, .laterToday:
            return false
        case .laterThisWeek, .someday:
            return true
        }
    }
}

struct RescheduleScopeRecommendation: Sendable, Equatable {
    let summary: String
    let note: String
}

struct RescheduleEngineInput: Sendable {
    let stepID: String
    let timing: GoalTiming
    let feedbackHistory: [GoalFeedbackEvent]
    let trigger: RescheduleTrigger
    let fallbackMicroStep: String
    let now: Date
}

struct RescheduleDecision: Sendable, Equatable {
    let trigger: RescheduleTrigger
    let suggestedTime: String?
    let deferRecommendation: RescheduleDeferRecommendation
    let smallerStep: RescheduleScopeRecommendation?
    let recommendationConfidence: RecommendationConfidence
    let rationale: String

    var timingAdjustment: GoalTimingAdjustment? {
        deferRecommendation.timingAdjustment
    }
}

struct RescheduleEngine: GoalRescheduling {
    private struct Signals {
        let delayedCount: Int
        let recentMissCount: Int
        let consecutiveMissCount: Int
    }

    func decide(_ input: RescheduleEngineInput) -> RescheduleDecision {
        let signals = signals(for: input)
        var deferRecommendation = deferRecommendation(for: input, signals: signals)
        if input.timing.tempo == .ongoing, deferRecommendation == .someday {
            deferRecommendation = .laterThisWeek
        }

        let needsSmallerStep = needsSmallerStepRecommendation(for: input.trigger, signals: signals)
        let fallback = normalizedFallbackMicroStep(input.fallbackMicroStep)
        let smallerStep = needsSmallerStep
            ? RescheduleScopeRecommendation(
                summary: "Reduce the next pass to: \(fallback)",
                note: "Keep the next attempt session-sized and explicit."
            )
            : nil

        let rationale = rationale(for: input.trigger, deferRecommendation: deferRecommendation, signals: signals, includesSmallerStep: smallerStep != nil)
        let suggestedTime = suggestedTime(for: deferRecommendation, now: input.now)

        return RescheduleDecision(
            trigger: input.trigger,
            suggestedTime: suggestedTime,
            deferRecommendation: deferRecommendation,
            smallerStep: smallerStep,
            recommendationConfidence: recommendationConfidence(
                for: deferRecommendation,
                hasSmallerStep: smallerStep != nil
            ),
            rationale: rationale
        )
    }
}

private extension RescheduleEngine {
    private func signals(for input: RescheduleEngineInput) -> Signals {
        let stepEvents = sortedStepEvents(input.feedbackHistory, stepID: input.stepID)
        let now = input.now
        let recentWindowStart = now.addingTimeInterval(-7 * 24 * 60 * 60)
        var delayedCount = 0
        var recentMissCount = 0

        for event in stepEvents {
            guard let occurredAt = parseDate(event.base.occurredAt), occurredAt <= now else { continue }
            if case .delayed = event {
                delayedCount += 1
            }
            if isMiss(event), occurredAt >= recentWindowStart {
                recentMissCount += 1
            }
        }

        var consecutiveMissCount = 0
        for event in stepEvents.reversed() {
            guard let occurredAt = parseDate(event.base.occurredAt), occurredAt <= now else { continue }
            if case .completed = event {
                break
            }
            if isMiss(event) {
                consecutiveMissCount += 1
            }
        }

        return Signals(
            delayedCount: delayedCount,
            recentMissCount: recentMissCount,
            consecutiveMissCount: consecutiveMissCount
        )
    }

    private func deferRecommendation(for input: RescheduleEngineInput, signals: Signals) -> RescheduleDeferRecommendation {
        switch input.trigger {
        case .delay:
            if signals.consecutiveMissCount >= 4 || signals.recentMissCount >= 5 || signals.delayedCount >= 4 {
                return .someday
            }
            if signals.consecutiveMissCount >= 2 || signals.recentMissCount >= 3 {
                return .laterThisWeek
            }
            return .laterToday
        case .skip:
            if signals.consecutiveMissCount >= 3 || signals.recentMissCount >= 4 {
                return .someday
            }
            return .laterThisWeek
        case .stuck:
            if signals.consecutiveMissCount >= 3 || signals.recentMissCount >= 4 {
                return .laterThisWeek
            }
            return .laterToday
        case .askForSmallerStep:
            if signals.consecutiveMissCount >= 2 || signals.recentMissCount >= 3 {
                return .laterThisWeek
            }
            return .laterToday
        }
    }

    private func needsSmallerStepRecommendation(for trigger: RescheduleTrigger, signals: Signals) -> Bool {
        switch trigger {
        case .stuck, .askForSmallerStep:
            return true
        case .delay, .skip:
            return signals.consecutiveMissCount >= 2 || signals.recentMissCount >= 3
        }
    }

    private func rationale(
        for trigger: RescheduleTrigger,
        deferRecommendation: RescheduleDeferRecommendation,
        signals: Signals,
        includesSmallerStep: Bool
    ) -> String {
        let action = switch trigger {
        case .delay: "Delay signal"
        case .skip: "Skip signal"
        case .stuck: "Stuck signal"
        case .askForSmallerStep: "Smaller-step request"
        }

        let timingClause = switch deferRecommendation {
        case .none: "keeps timing unchanged."
        case .laterToday: "suggests a same-day retry window."
        case .laterThisWeek: "defers the next attempt later this week."
        case .someday: "defers the next attempt to a lower-pressure future slot."
        }

        let scopeClause = includesSmallerStep ? " Scope is reduced to a minimum version." : ""
        return "\(action) with \(signals.consecutiveMissCount) consecutive misses and \(signals.recentMissCount) recent misses \(timingClause)\(scopeClause)"
    }

    func suggestedTime(for recommendation: RescheduleDeferRecommendation, now: Date) -> String? {
        let shifted: Date
        switch recommendation {
        case .none:
            return nil
        case .laterToday:
            shifted = now.addingTimeInterval(2 * 60 * 60)
        case .laterThisWeek:
            shifted = now.addingTimeInterval(2 * 24 * 60 * 60)
        case .someday:
            shifted = now.addingTimeInterval(7 * 24 * 60 * 60)
        }

        let rounded = ceil(shifted.timeIntervalSince1970 / 900) * 900
        return DomainTimestamp.string(from: Date(timeIntervalSince1970: rounded))
    }

    func sortedStepEvents(_ events: [GoalFeedbackEvent], stepID: String) -> [GoalFeedbackEvent] {
        events
            .filter { $0.stepID == stepID }
            .sorted { lhs, rhs in
                let lhsDate = parseDate(lhs.base.occurredAt) ?? .distantPast
                let rhsDate = parseDate(rhs.base.occurredAt) ?? .distantPast
                if lhsDate != rhsDate {
                    return lhsDate < rhsDate
                }
                return lhs.base.id < rhs.base.id
            }
    }

    func isMiss(_ event: GoalFeedbackEvent) -> Bool {
        switch event {
        case .skipped, .delayed, .confused, .tooBig, .notRelevant, .askedForSmallerVersion:
            return true
        case .completed, .edited, .tooEasy, .askedWhyThisMatters:
            return false
        }
    }

    func normalizedFallbackMicroStep(_ fallback: String) -> String {
        let trimmed = fallback.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Do one minimum viable pass and log it." : trimmed
    }

    func parseDate(_ value: String) -> Date? {
        DomainTimestamp.date(from: value)
    }

    private func recommendationConfidence(
        for recommendation: RescheduleDeferRecommendation,
        hasSmallerStep: Bool
    ) -> RecommendationConfidence {
        if recommendation == .laterThisWeek || recommendation == .someday || hasSmallerStep {
            return .high
        }
        return .medium
    }
}
