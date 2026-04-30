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

enum RecoveryPosture: String, Sendable, Equatable {
    case gentle
    case steady
    case unblock
    case wait
}

enum RecoveryWaitingState: String, Sendable, Equatable {
    case blockedByDependency = "blocked_by_dependency"
    case waitingOnExternal = "waiting_on_external"
    case notReady = "not_ready"
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
    let planningEvaluation: PlanningEvaluation?
    let stepState: StepLifecycleState
    let incompleteDependencyCount: Int
    let pathStateSummary: LifePathStateSummary?
    let learningSummary: GoalLearningSummary?
    let sharedLifeSummary: SharedLifeGoalSummary?

    init(
        stepID: String,
        timing: GoalTiming,
        feedbackHistory: [GoalFeedbackEvent],
        trigger: RescheduleTrigger,
        fallbackMicroStep: String,
        now: Date,
        planningEvaluation: PlanningEvaluation? = nil,
        stepState: StepLifecycleState = .planned,
        incompleteDependencyCount: Int = 0,
        pathStateSummary: LifePathStateSummary? = nil,
        learningSummary: GoalLearningSummary? = nil,
        sharedLifeSummary: SharedLifeGoalSummary? = nil
    ) {
        self.stepID = stepID
        self.timing = timing
        self.feedbackHistory = feedbackHistory
        self.trigger = trigger
        self.fallbackMicroStep = fallbackMicroStep
        self.now = now
        self.planningEvaluation = planningEvaluation
        self.stepState = stepState
        self.incompleteDependencyCount = incompleteDependencyCount
        self.pathStateSummary = pathStateSummary
        self.learningSummary = learningSummary
        self.sharedLifeSummary = sharedLifeSummary
    }
}

struct RescheduleDecision: Sendable, Equatable {
    let trigger: RescheduleTrigger
    let causeOfDrift: CauseOfDrift?
    let posture: RecoveryPosture
    let waitingState: RecoveryWaitingState?
    let suggestedTime: String?
    let deferRecommendation: RescheduleDeferRecommendation
    let smallerStep: RescheduleScopeRecommendation?
    let recoverySummary: String?
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
        let causeOfDrift = primaryCauseOfDrift(for: input)
        let waitingState = waitingState(for: input, causeOfDrift: causeOfDrift)
        var deferRecommendation = deferRecommendation(for: input, signals: signals, waitingState: waitingState)
        if input.timing.tempo == .ongoing, deferRecommendation == .someday {
            deferRecommendation = .laterThisWeek
        }
        deferRecommendation = adjustedDeferRecommendation(base: deferRecommendation, input: input)

        let needsSmallerStep = needsSmallerStepRecommendation(
            for: input,
            trigger: input.trigger,
            signals: signals,
            causeOfDrift: causeOfDrift,
            waitingState: waitingState
        )
        let fallback = normalizedFallbackMicroStep(input.fallbackMicroStep)
        let smallerStep = needsSmallerStep
            ? RescheduleScopeRecommendation(
                summary: waitingState == .notReady
                    ? "Use a readiness-sized pass first: \(fallback)"
                    : "Reduce the next pass to: \(fallback)",
                note: waitingState == .notReady
                    ? "Prepare the missing context before retrying the full step."
                    : "Keep the next attempt session-sized and explicit."
            )
            : nil

        let posture = posture(
            for: input,
            causeOfDrift: causeOfDrift,
            waitingState: waitingState,
            smallerStep: smallerStep
        )
        let rationale = rationale(
            for: input,
            trigger: input.trigger,
            causeOfDrift: causeOfDrift,
            posture: posture,
            waitingState: waitingState,
            deferRecommendation: deferRecommendation,
            signals: signals,
            includesSmallerStep: smallerStep != nil
        )
        let suggestedTime = suggestedTime(for: deferRecommendation, now: input.now)
        let recoverySummary = recoverySummary(for: input, waitingState: waitingState, smallerStep: smallerStep)

        return RescheduleDecision(
            trigger: input.trigger,
            causeOfDrift: causeOfDrift,
            posture: posture,
            waitingState: waitingState,
            suggestedTime: suggestedTime,
            deferRecommendation: deferRecommendation,
            smallerStep: smallerStep,
            recoverySummary: recoverySummary,
            recommendationConfidence: recommendationConfidence(
                waitingState: waitingState,
                for: deferRecommendation,
                hasSmallerStep: smallerStep != nil,
                planningEvaluation: input.planningEvaluation
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

    private func primaryCauseOfDrift(for input: RescheduleEngineInput) -> CauseOfDrift? {
        let stepEvents = sortedStepEvents(input.feedbackHistory, stepID: input.stepID)
        for event in stepEvents.reversed() {
            if let cause = event.causeOfDrift {
                return cause
            }
        }

        switch input.trigger {
        case .delay, .skip:
            return .timingPressure
        case .stuck:
            return .unclearAction
        case .askForSmallerStep:
            return .oversizedStep
        }
    }

    private func waitingState(for input: RescheduleEngineInput, causeOfDrift: CauseOfDrift?) -> RecoveryWaitingState? {
        if causeOfDrift == .externalDependency {
            return .waitingOnExternal
        }
        if causeOfDrift == .notReady {
            return .notReady
        }
        if input.pathStateSummary?.readiness.gapCount ?? 0 > 0 {
            return .notReady
        }
        if input.pathStateSummary?.blockedPrerequisites.isEmpty == false {
            return .blockedByDependency
        }
        if input.stepState == .blocked || input.incompleteDependencyCount > 0 {
            return .blockedByDependency
        }
        return nil
    }

    private func deferRecommendation(
        for input: RescheduleEngineInput,
        signals: Signals,
        waitingState: RecoveryWaitingState?
    ) -> RescheduleDeferRecommendation {
        switch waitingState {
        case .waitingOnExternal:
            return .laterThisWeek
        case .blockedByDependency:
            return input.incompleteDependencyCount >= 2 ? .laterThisWeek : .laterToday
        case .notReady:
            return signals.consecutiveMissCount >= 2 ? .laterThisWeek : .laterToday
        case .none:
            break
        }

        switch input.trigger {
        case .delay:
            if input.planningEvaluation?.fragilityLevel == .high {
                return .laterThisWeek
            }
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

    private func needsSmallerStepRecommendation(
        for input: RescheduleEngineInput,
        trigger: RescheduleTrigger,
        signals: Signals,
        causeOfDrift: CauseOfDrift?,
        waitingState: RecoveryWaitingState?
    ) -> Bool {
        if waitingState == .waitingOnExternal || waitingState == .blockedByDependency {
            return false
        }
        if waitingState == .notReady {
            return true
        }
        if causeOfDrift == .oversizedStep || input.planningEvaluation?.fragilityLevel == .high {
            return true
        }

        switch trigger {
        case .stuck, .askForSmallerStep:
            return true
        case .delay, .skip:
            return signals.consecutiveMissCount >= 2 || signals.recentMissCount >= 3
        }
    }

    private func posture(
        for input: RescheduleEngineInput,
        causeOfDrift: CauseOfDrift?,
        waitingState: RecoveryWaitingState?,
        smallerStep: RescheduleScopeRecommendation?
    ) -> RecoveryPosture {
        switch waitingState {
        case .waitingOnExternal:
            return .wait
        case .blockedByDependency:
            return .unblock
        case .notReady:
            return .gentle
        case .none:
            break
        }

        if input.planningEvaluation?.fragilityLevel == .high || smallerStep != nil {
            return .gentle
        }
        if input.sharedLifeSummary?.careContextActive == true || (input.sharedLifeSummary?.pressureScore ?? 0) >= 0.6 {
            return .gentle
        }
        if [.oversizedStep, .missingContext, .unclearAction, .missingEvidence, .notReady].contains(causeOfDrift) {
            return .gentle
        }
        return .steady
    }

    private func recoverySummary(
        for input: RescheduleEngineInput,
        waitingState: RecoveryWaitingState?,
        smallerStep: RescheduleScopeRecommendation?
    ) -> String? {
        let fallback = normalizedFallbackMicroStep(input.fallbackMicroStep)

        switch waitingState {
        case .blockedByDependency:
            if let prerequisite = input.pathStateSummary?.blockedPrerequisites.first {
                return "Finish the blocking prerequisite before retrying this step: \(prerequisite.title)."
            }
            return "Finish the blocking prerequisite before retrying this step."
        case .waitingOnExternal:
            return "Keep this waiting until the external dependency clears."
        case .notReady:
            if let gap = input.pathStateSummary?.readiness.gapSignals.first {
                return "Use a readiness-sized pass first: \(gap.title)."
            }
            return "Use a readiness-sized pass first: \(fallback)"
        case .none:
            if let smallerStep {
                return smallerStep.summary
            }
            if input.sharedLifeSummary?.careContextActive == true {
                return "Keep the next step gentle enough to support the current care context."
            }
            return nil
        }
    }

    private func rationale(
        for input: RescheduleEngineInput,
        trigger: RescheduleTrigger,
        causeOfDrift: CauseOfDrift?,
        posture: RecoveryPosture,
        waitingState: RecoveryWaitingState?,
        deferRecommendation: RescheduleDeferRecommendation,
        signals: Signals,
        includesSmallerStep: Bool
    ) -> String {
        switch waitingState {
        case .blockedByDependency:
            let count = max(1, input.incompleteDependencyCount)
            return "\(count) prerequisite step\(count == 1 ? "" : "s") still need completion."
        case .waitingOnExternal:
            return "An external dependency is still blocking this step."
        case .notReady:
            return "This step needs a lower-pressure readiness pass first."
        case .none:
            break
        }

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
        let causeClause: String = {
            guard let causeOfDrift else { return "" }
            return " Cause: \(causeOfDrift.rawValue)."
        }()
        let postureClause = posture == .gentle ? " Recovery stays gentle." : ""
        let learnedClause: String = {
            guard let learningSummary = input.learningSummary,
                  learningSummary.historicalFit.confidence == .high,
                  learningSummary.historicalFit.score <= 0.3 else {
                return ""
            }
            return " Observed fit is weak in this window."
        }()
        let sharedClause: String = {
            guard let sharedLifeSummary = input.sharedLifeSummary,
                  sharedLifeSummary.pressureScore >= 0.55 else {
                return ""
            }
            return " Shared-life coordination is also active."
        }()
        return "\(action) with \(signals.consecutiveMissCount) consecutive misses and \(signals.recentMissCount) recent misses \(timingClause)\(scopeClause)\(causeClause)\(postureClause)\(learnedClause)\(sharedClause)"
    }

    private func adjustedDeferRecommendation(
        base: RescheduleDeferRecommendation,
        input: RescheduleEngineInput
    ) -> RescheduleDeferRecommendation {
        guard base == .none || base == .laterToday else { return base }
        if let sharedLifeSummary = input.sharedLifeSummary,
           sharedLifeSummary.careContextActive,
           base == .laterToday,
           sharedLifeSummary.pressureScore >= 0.7 {
            return .laterThisWeek
        }
        guard let learningSummary = input.learningSummary,
              learningSummary.historicalFit.confidence == .high,
              learningSummary.historicalFit.score <= 0.3,
              learningSummary.driftTriggers.contains(where: {
                  $0.window == focusWindow(for: input.now) && $0.occurrenceCount >= 2
              }) else {
            return base
        }
        return .laterThisWeek
    }

    private func focusWindow(for date: Date) -> FocusWindowBucket {
        let hour = Calendar(identifier: .gregorian).component(.hour, from: date)
        switch hour {
        case 5..<12:
            return .morning
        case 12..<18:
            return .afternoon
        default:
            return .evening
        }
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
        waitingState: RecoveryWaitingState?,
        for recommendation: RescheduleDeferRecommendation,
        hasSmallerStep: Bool,
        planningEvaluation: PlanningEvaluation?
    ) -> RecommendationConfidence {
        if waitingState != nil || recommendation == .laterThisWeek || recommendation == .someday || hasSmallerStep {
            return .high
        }
        if planningEvaluation?.recommendationConfidence == .low || planningEvaluation?.fragilityLevel == .high {
            return .medium
        }
        return .medium
    }
}
