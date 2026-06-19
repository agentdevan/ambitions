import AmbitionsDesignSystem
import Foundation

extension TodayExecutionProjector {
    func action(for action: NowAction?) -> TodayInlineAction? {
        guard let action else { return nil }
        let target = TodayActionTarget(goalID: action.reference?.goalID, stepID: action.reference?.stepID)
        switch action.kind {
        case .focus:
            return TodayInlineAction(kind: .startStepSession, title: "Start now", systemImage: "scope", state: .selected, target: target)
        case .completeAction:
            return TodayInlineAction(kind: .complete, title: "Complete", systemImage: "checkmark", state: .success, target: target)
        case .openGoal:
            return TodayInlineAction(kind: .openDetail, title: "Open Goal", systemImage: "arrow.right.circle", state: .default, target: target)
        case .openTime, .schedule:
            return openTimeAction()
        case .capture, .routeCommitment:
            return TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: target)
        case .recover:
            return TodayInlineAction(kind: .protectLater, title: "Recover", systemImage: "arrow.uturn.backward.circle", state: .selected, target: target)
        case .explain:
            return TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: target)
        case .wait:
            return TodayInlineAction(kind: .openTime, title: "View waiting", systemImage: "hourglass", state: .default, target: target)
        case .review, .none:
            return nil
        }
    }

    func action(for option: ExecutionRecoveryOption?, fallback: TodayInlineAction) -> TodayInlineAction {
        guard let option else { return fallback }
        let target = TodayActionTarget(goalID: option.relatedGoalID, draftID: nil)
        switch option.strategy {
        case .openTime, .protectDeadlineWork, .rescheduleLater, .acceptSlip:
            return TodayInlineAction(kind: .openTime, title: "Open Time", systemImage: "calendar", state: .selected, target: target)
        case .openCapture, .clarifyNextStep, .askForDecision:
            return TodayInlineAction(kind: .quickLog, title: "Open Capture", systemImage: "tray.and.arrow.down", state: .selected, target: target)
        case .openGoal, .reduceScope:
            return TodayInlineAction(kind: .openDetail, title: "Open Goal", systemImage: "arrow.right.circle", state: .selected, target: target)
        case .splitIntoSmallerStep, .doSmallestNextStep:
            return TodayInlineAction(kind: .split, title: "Smallest step", systemImage: "scissors", state: .selected, target: target)
        case .deferPassiveWork, .keepAsSomeday:
            return TodayInlineAction(kind: .defer, title: "Let it wait", systemImage: "clock", state: .default, target: target)
        case .moveToWaiting:
            return TodayInlineAction(kind: .openTime, title: "Keep waiting", systemImage: "hourglass", state: .default, target: target)
        }
    }

    func secondaryRecoveryActions(_ input: TodayExecutionProjectionInput, primary: TodayInlineAction) -> [TodayInlineAction] {
        let optionActions = input.resilienceAssessment.recoveryOptions.map { action(for: $0, fallback: primary) }
        return unique(optionActions + [openTimeAction(), TodayInlineAction(kind: .askWhyThisMatters, title: "Why recover?", systemImage: "questionmark.circle", state: .default, target: primary.target)], excluding: primary)
    }

    func secondaryStableActions(_ input: TodayExecutionProjectionInput, primary: TodayInlineAction) -> [TodayInlineAction] {
        unique([
            TodayInlineAction(kind: .askWhyThisMatters, title: "Why this?", systemImage: "questionmark.circle", state: .default, target: primary.target),
            openTimeAction(),
            input.legacySupport.quickCaptureAction,
        ].compactMap { $0 }, excluding: primary)
    }

    func unique(_ actions: [TodayInlineAction], excluding primary: TodayInlineAction) -> [TodayInlineAction] {
        var seen = Set([primary.id])
        return actions.filter { seen.insert($0.id).inserted }.prefix(3).map { $0 }
    }

    func openTimeAction(title: String = "Open Time") -> TodayInlineAction {
        TodayInlineAction(kind: .openTime, title: title, systemImage: "calendar", state: .default, target: TodayActionTarget())
    }

    func explanation(_ input: TodayExecutionProjectionInput, preferred: String?, fallbackTitle: String) -> TodayExplanationAffordanceState? {
        let explanation = preferred.flatMap { id in input.explanations.first { $0.id == id } } ?? input.explanations.first
        return TodayExplanationAffordanceState(
            id: "today2.explanation.\(preferred ?? explanation?.id ?? fallbackTitle)",
            title: explanation?.title ?? fallbackTitle,
            summary: explanation?.summary ?? input.legacyHero.truth.trustWhisper?.detail ?? input.nowState.priorityPressure.summary,
            explanationID: explanation?.id ?? preferred,
            state: .selected
        )
    }

    func lensChip(_ lens: NowContextLens, active: Bool) -> TodayLensChipState {
        TodayLensChipState(id: "lens.\(lens.rawValue)", title: lens.displayTitle, icon: lens.icon, state: active ? .selected : .default, isActive: active)
    }

    func lensSummary(_ state: CanonicalNowState) -> String {
        let source = state.isManualLensOverrideActive ? "manual override" : state.lensSource.displayTitle
        if state.urgentOutsideLens.count > 0 {
            return "\(state.activeContextLens.displayTitle) lens from \(source). \(state.urgentOutsideLens.summary)"
        }
        return "\(state.activeContextLens.displayTitle) from \(source). Urgent work stays visible."
    }

    func semanticState(confidence: RecommendationConfidence, posture: NowPosture) -> AmbitionSemanticState {
        if posture == .tight || posture == .overloaded { return .protected }
        switch confidence {
        case .high:
            return .focus
        case .medium:
            return .confidenceMedium
        case .low:
            return .trust
        }
    }

    func recoveryLabel(_ status: ExecutionRecoveryStatus) -> String {
        switch status {
        case .stable: "Stable"
        case .watch: "Watch"
        case .needsRecovery: "Needs recovery"
        case .atRisk: "At risk"
        case .blocked: "Blocked"
        case .recovering: "Recovering"
        }
    }

    func pressureLabel(_ level: NowPressureLevel) -> String {
        switch level {
        case .none: "No pressure"
        case .low: "Low"
        case .moderate: "Moderate"
        case .elevated: "Elevated"
        case .high: "High"
        case .critical: "Critical"
        }
    }

    func timeTitle(_ level: NowPressureLevel) -> String {
        switch level {
        case .none, .low:
            "Time has room"
        case .moderate:
            "Time is getting tight"
        case .elevated, .high, .critical:
            "Time needs attention"
        }
    }
}

extension NowContextLens {
    var displayTitle: String {
        switch self {
        case .work: "Work"
        case .personal: "Personal"
        case .freeTime: "Free Time"
        case .admin: "Admin"
        case .creative: "Creative"
        case .recovery: "Recovery"
        case .deepFocus: "Deep Focus"
        case .all: "All"
        }
    }

    var icon: String {
        switch self {
        case .work: "briefcase.fill"
        case .personal: "person.fill"
        case .freeTime: "sun.max.fill"
        case .admin: "tray.full.fill"
        case .creative: "paintbrush.pointed.fill"
        case .recovery: "heart.fill"
        case .deepFocus: "scope"
        case .all: "square.grid.2x2.fill"
        }
    }
}

extension NowContextLensSource {
    var displayTitle: String {
        switch self {
        case .manual: "manual choice"
        case .schedule: "schedule"
        case .calendar: "calendar-derived context"
        case .domain: "work context"
        case .deadline: "deadline pressure"
        case .recovery: "recovery state"
        case .systemDefault: "local default"
        }
    }
}
