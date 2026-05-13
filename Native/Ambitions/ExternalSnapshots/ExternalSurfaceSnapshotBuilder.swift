import Foundation

struct ExternalSurfaceSnapshotBuilder: Sendable {
    private let ritualService = RitualOrchestrationService()

    func makeSnapshot(goals: [Goal], captures: [Capture] = [], now: Date) -> ExternalSurfaceSnapshot {
        let nextAction = nextAction(from: goals, now: now)
        let generatedAt = Self.iso.string(from: now)
        let state = nowState(goals: goals, captures: captures, nextAction: nextAction, now: now)
        return ExternalSurfaceSnapshot(
            generatedAt: generatedAt,
            nextAction: nextAction,
            nowState: state,
            ambientState: ambientState(goals: goals, captures: captures, nextAction: nextAction, nowState: state),
            continuity: ExternalSurfaceContinuityState.localFirst(generatedAt: generatedAt)
        )
    }

    private func nextAction(from goals: [Goal], now: Date) -> ExternalSurfaceNextAction? {
        guard let selection = PlanningNextStepSelector().bestSelection(goals: goals, now: now) else {
            return nil
        }

        let goal = selection.goal
        let step = selection.step
        return ExternalSurfaceNextAction(
            goalID: goal.id,
            stepID: step.id,
            display: ExternalSurfaceDisplayMetadata(
                templateKey: "next_tiny_step",
                goalMode: mapGoalMode(goal.mode),
                stepState: mapStepState(step.state),
                urgency: urgency(for: step.timing, now: now),
                timing: timing(for: step.timing)
            )
        )
    }

    private func nowState(
        goals: [Goal],
        captures: [Capture],
        nextAction: ExternalSurfaceNextAction?,
        now: Date
    ) -> ExternalSurfaceNowState {
        let activeGoals = goals.filter { $0.state == .active || $0.state == .paused }
        let blockedSteps = activeGoals.flatMap { goal in
            goal.plan?.sections.flatMap(\.steps) ?? []
        }.filter { $0.state == .blocked }
        let openCaptures = captures.filter { capture in
            capture.status != .archived
        }

        let posture: ExternalSurfaceTodayPosture
        if activeGoals.isEmpty {
            posture = .empty
        } else if blockedSteps.isEmpty == false && nextAction == nil {
            posture = .waiting
        } else {
            posture = .active
        }

        return ExternalSurfaceNowState(
            todayPosture: posture,
            pressureLevel: pressureLevel(activeGoalCount: activeGoals.count, blockedCount: blockedSteps.count),
            bestNextStep: nextAction.map { ExternalSurfaceActionReference(goalID: $0.goalID, stepID: $0.stepID) },
            activeFocus: nil,
            openCaptureUrgency: captureUrgency(openCaptureCount: openCaptures.count),
            blockerSummary: ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: blockedSteps.count),
            ritualCue: ritualCue(goals: activeGoals, captures: captures, now: now),
            supportedCommands: supportedCommands(hasNextAction: nextAction != nil)
        )
    }

    private func ritualCue(goals: [Goal], captures: [Capture], now: Date) -> ExternalSurfaceRitualCue? {
        let plan = ritualService.makePlan(
            input: RitualOrchestrationInput(
                goals: goals,
                captures: captures,
                evidence: [],
                feedback: [],
                now: now
            )
        )
        let recommendation = plan.activeRecommendation
        guard recommendation.progressState != .unavailable else { return nil }
        return ExternalSurfaceRitualCue(
            kind: mapRitualKind(recommendation.kind),
            templateKey: templateKey(for: recommendation.kind),
            progressState: mapRitualProgress(recommendation.progressState),
            primaryReference: recommendation.primaryAction.flatMap { action in
                guard let goalID = action.goalID else { return nil }
                return ExternalSurfaceActionReference(goalID: goalID, stepID: action.stepID)
            }
        )
    }

    private func pressureLevel(activeGoalCount: Int, blockedCount: Int) -> ExternalSurfacePressureLevel {
        if activeGoalCount == 0 { return .open }
        if blockedCount >= 3 || activeGoalCount >= 8 { return .overloaded }
        if blockedCount > 0 || activeGoalCount >= 5 { return .elevated }
        return .steady
    }

    private func captureUrgency(openCaptureCount: Int) -> ExternalSurfaceCaptureUrgency {
        if openCaptureCount == 0 { return .none }
        if openCaptureCount >= 5 { return .elevated }
        return .low
    }

    private func supportedCommands(hasNextAction: Bool) -> [ExternalSurfaceCommandDescriptor] {
        var commands = [
            ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
            ExternalSurfaceCommandDescriptor(kind: .openCapturesInbox, requiresGoalID: false, requiresStepID: false),
            ExternalSurfaceCommandDescriptor(kind: .openMemoryLens, requiresGoalID: false, requiresStepID: false),
        ]

        if hasNextAction {
            commands = [
                ExternalSurfaceCommandDescriptor(kind: .complete, requiresGoalID: true, requiresStepID: true),
                ExternalSurfaceCommandDescriptor(kind: .snooze, requiresGoalID: true, requiresStepID: true),
                ExternalSurfaceCommandDescriptor(kind: .openGoal, requiresGoalID: true, requiresStepID: false),
            ] + commands
        }

        return commands
    }

    private func ambientState(
        goals: [Goal],
        captures: [Capture],
        nextAction: ExternalSurfaceNextAction?,
        nowState: ExternalSurfaceNowState
    ) -> ExternalSurfaceAmbientState {
        let activeGoals = goals.filter { $0.state == .active || $0.state == .paused }
        let activeGoalCount = activeGoals.count
        let openCaptureCount = captures.filter { $0.status != .archived }.count
        let blockedCount = nowState.blockerSummary.blockedCount
        let primaryReference = nowState.activeFocus ?? nowState.bestNextStep

        return ExternalSurfaceAmbientState(
            today: ExternalSurfaceVariantState(
                kind: .today,
                title: todayVariantTitle(posture: nowState.todayPosture),
                detail: todayVariantDetail(posture: nowState.todayPosture, pressure: nowState.pressureLevel),
                privacySummary: "Glance-safe next step only",
                action: ExternalSurfaceVariantAction(title: "Open Today", surface: .tab, tab: "today"),
                reference: primaryReference,
                prominence: nowState.pressureLevel == .overloaded || nowState.pressureLevel == .elevated ? .elevated : .standard
            ),
            focus: ExternalSurfaceVariantState(
                kind: .focus,
                title: primaryReference == nil ? "Focus when ready" : "Focus step ready",
                detail: focusVariantDetail(urgency: nextAction?.display.urgency, pressure: nowState.pressureLevel),
                privacySummary: "Details stay inside Ambitions",
                action: ExternalSurfaceVariantAction(title: "Open Focus", surface: .tab, tab: "today"),
                reference: primaryReference,
                prominence: primaryReference == nil ? .quiet : .elevated
            ),
            goal: ExternalSurfaceVariantState(
                kind: .goal,
                title: activeGoalCount == 0 ? "No active goal pressure" : "\(activeGoalCount) active goals",
                detail: blockedCount == 0 ? "Momentum is readable from your local plan." : "\(blockedCount) blocked steps need a calmer next pass.",
                privacySummary: "Goal names stay private here",
                action: ExternalSurfaceVariantAction(title: "Open Goals", surface: .tab, tab: "goals"),
                reference: primaryReference,
                prominence: blockedCount > 0 ? .elevated : .standard
            ),
            plan: ExternalSurfaceVariantState(
                kind: .plan,
                title: planVariantTitle(pressure: nowState.pressureLevel),
                detail: openCaptureCount == 0 ? "The week can be shaped from the latest local state." : "\(openCaptureCount) captures are waiting for review.",
                privacySummary: "Plan detail opens in app",
                action: ExternalSurfaceVariantAction(title: "Open Time", surface: .tab, tab: "plan"),
                reference: primaryReference,
                prominence: nowState.openCaptureUrgency == .elevated ? .elevated : .standard
            )
        )
    }

    private func todayVariantTitle(posture: ExternalSurfaceTodayPosture) -> String {
        switch posture {
        case .empty:
            return "Today is open"
        case .active:
            return "Today has a next step"
        case .waiting:
            return "Today needs confirmation"
        case .recovery:
            return "Recovery is ready"
        }
    }

    private func todayVariantDetail(posture: ExternalSurfaceTodayPosture, pressure: ExternalSurfacePressureLevel) -> String {
        switch posture {
        case .empty:
            return "Open Ambitions to set the first useful step."
        case .waiting:
            return "A blocker is visible; open Ambitions before committing."
        case .recovery:
            return "Use the smallest safe step from your local plan."
        case .active:
            switch pressure {
            case .open:
                return "Room is available for a calm next step."
            case .steady:
                return "Your next step is still believable."
            case .elevated:
                return "Pressure is rising; keep the step small."
            case .overloaded:
                return "Open Ambitions to triage before pushing."
            }
        }
    }

    private func focusVariantDetail(urgency: ExternalSurfaceUrgency?, pressure: ExternalSurfacePressureLevel) -> String {
        guard let urgency else {
            return "Open Ambitions when you want a bounded session."
        }
        switch urgency {
        case .overdue:
            return "Start only if this still fits right now."
        case .soon:
            return "A bounded focus window is useful soon."
        case .normal:
            return pressure == .elevated ? "Keep the focus narrow." : "A clean focus step is available."
        case .anytime:
            return "Flexible timing; no pressure added."
        }
    }

    private func planVariantTitle(pressure: ExternalSurfacePressureLevel) -> String {
        switch pressure {
        case .open:
            return "Week has room"
        case .steady:
            return "Week is holding"
        case .elevated:
            return "Week needs shaping"
        case .overloaded:
            return "Week needs triage"
        }
    }

    private func urgency(for timing: GoalTiming, now: Date) -> ExternalSurfaceUrgency {
        guard let reference = parseDate(timing.dueAt ?? timing.targetBy ?? timing.windowEnd ?? timing.suggestedNextAt) else {
            return timing.tempo == .untimed ? .anytime : .normal
        }

        let delta = reference.timeIntervalSince(now)
        if delta < 0 { return .overdue }
        if delta <= 48 * 60 * 60 { return .soon }
        return .normal
    }

    private func timing(for timing: GoalTiming) -> ExternalSurfaceTiming {
        switch timing.tempo {
        case .deadlineBased:
            return .deadline
        case .targetWindow:
            return .window
        case .ongoing:
            return .cadence
        case .untimed:
            return .untimed
        }
    }

    private func mapGoalMode(_ mode: GoalMode) -> ExternalSurfaceGoalMode {
        switch mode {
        case .achievement:
            return .achievement
        case .project:
            return .project
        case .habit:
            return .habit
        case .learning:
            return .learning
        case .exploration:
            return .exploration
        case .maintenance:
            return .maintenance
        case .recovery:
            return .recovery
        case .delegatedSupport:
            return .delegatedSupport
        }
    }

    private func mapStepState(_ state: StepLifecycleState) -> ExternalSurfaceStepState {
        switch state {
        case .planned:
            return .planned
        case .active:
            return .active
        case .completed:
            return .completed
        case .blocked:
            return .blocked
        case .cancelled:
            return .cancelled
        }
    }

    private func mapRitualKind(_ kind: RitualKind) -> ExternalSurfaceRitualKind {
        switch kind {
        case .morningSetup:
            return .morningSetup
        case .middayReset:
            return .middayReset
        case .eveningClose:
            return .eveningClose
        case .weeklyReset:
            return .weeklyReset
        }
    }

    private func mapRitualProgress(_ state: RitualProgressState) -> ExternalSurfaceRitualProgressState {
        switch state {
        case .unavailable:
            return .unavailable
        case .ready:
            return .ready
        case .needsReset:
            return .needsReset
        case .complete:
            return .complete
        }
    }

    private func templateKey(for kind: RitualKind) -> String {
        switch kind {
        case .morningSetup:
            return "ritual_morning_setup"
        case .middayReset:
            return "ritual_midday_reset"
        case .eveningClose:
            return "ritual_evening_close"
        case .weeklyReset:
            return "ritual_weekly_reset"
        }
    }

    private func parseDate(_ value: String?) -> Date? {
        guard let value else { return nil }
        return Self.iso.date(from: value) ?? Self.isoFallback.date(from: value)
    }

    private static var iso: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }

    private static var isoFallback: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }
}
