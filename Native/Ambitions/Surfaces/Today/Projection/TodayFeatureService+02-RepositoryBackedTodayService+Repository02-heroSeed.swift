import AmbitionsDesignSystem
import Foundation

extension RepositoryBackedTodayService {
    func heroSeed(
        from focus: TodayFocusState,
        ritual: TodayRitualLoopState,
        milestone: TodayMilestoneState
    ) -> (title: String, detail: String, shellSummary: GoalShellSummaryState?) {
        switch focus {
        case let .planned(state):
            return (state.title, state.reason, state.shellSummary)
        case let .starter(state):
            return (state.title, state.subtitle, state.shellSummary)
        case let .clarification(state):
            return (state.title, state.subtitle, nil)
        case let .blocked(state):
            return (state.title, state.nextBestAction, nil)
        case let .empty(state):
            return (
                milestone.title.isEmpty ? state.title : milestone.title,
                state.message.isEmpty ? ritual.thesis : state.message,
                milestone.shellSummary
            )
        }
    }

    func makePrimaryAction(
        posture: TodayDayPosture,
        entryContext: TodayEntryContext,
        focus: TodayFocusState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState
    ) -> TodayPrimaryActionState {
        let available = primaryActions(
            from: focus,
            posture: posture,
            entryContext: entryContext,
            milestone: milestone,
            freeTime: freeTime
        )
        let primary = available.first ?? TodayInlineAction(
            kind: .openTime,
            title: "Build today",
            systemImage: "calendar.badge.plus",
            state: .selected,
            target: TodayActionTarget()
        )
        return TodayPrimaryActionState(
            title: primary.title,
            subtitle: primarySubtitle(for: posture, action: primary),
            action: primary,
            supportingActions: prioritizedSupportingActions(from: Array(available.dropFirst()))
        )
    }

    func prioritizedSupportingActions(from actions: [TodayInlineAction]) -> [TodayInlineAction] {
        guard actions.count > 4 else { return actions }

        var prioritized: [TodayInlineAction] = []
        var seen = Set<String>()

        func append(_ action: TodayInlineAction?) {
            guard let action else { return }
            let key = action.id
            guard seen.insert(key).inserted else { return }
            prioritized.append(action)
        }

        append(actions.first(where: { $0.kind == .openDetail }))
        append(actions.first(where: { $0.kind == .split }))
        append(actions.first(where: { $0.kind == .defer }))
        append(actions.first(where: { $0.kind == .reschedule }))
        append(actions.first(where: { $0.kind == .askWhyThisMatters }))

        for action in actions where prioritized.count < 5 {
            append(action)
        }

        return Array(prioritized.prefix(5))
    }

    func primaryActions(
        from focus: TodayFocusState,
        posture: TodayDayPosture,
        entryContext: TodayEntryContext,
        milestone: TodayMilestoneState,
        freeTime: TodayFreeTimeState
    ) -> [TodayInlineAction] {
        let focusActions: [TodayInlineAction] = {
            switch focus {
            case let .planned(state):
                state.actions
            case let .starter(state):
                state.actions
            case let .clarification(state):
                state.actions
            case let .blocked(state):
                state.actions
            case let .empty(state):
                state.actions
            }
        }()

        var actions = focusActions
        if entryContext.normalized != .stepSession,
           posture == .stable,
           let firstFocusAction = focusActions.first(where: {
               $0.kind == .complete || $0.kind == .split || $0.kind == .askForHelp
           }) {
            actions.insert(
                TodayInlineAction(
                    kind: .startStepSession,
                    title: "Start now",
                    systemImage: "scope",
                    state: .selected,
                    target: firstFocusAction.target
                ),
                at: 0
            )
        }
        if posture == .tight || posture == .overloaded || posture == .recovering {
            actions.insert(
                TodayInlineAction(
                    kind: .protectLater,
                    title: "Adjust Time",
                    systemImage: "calendar.badge.clock",
                    state: .selected,
                    target: TodayActionTarget()
                ),
                at: 0
            )
        }
        if actions.isEmpty, let milestoneAction = milestone.action {
            actions.append(milestoneAction)
        }
        if actions.isEmpty, let freeAction = freeTime.opportunities.first?.action {
            actions.append(freeAction)
        }
        return deduplicated(actions)
    }

    func primarySubtitle(for posture: TodayDayPosture, action: TodayInlineAction) -> String {
        switch posture {
        case .stable:
            return "One clear step matters more than another layer of noise."
        case .tight:
            return action.kind == .protectLater ? "Adjust this in Time before pressure turns noisy." : "Keep the day doable without widening scope."
        case .drifted:
            return "Use the calmest next step to get traction back."
        case .overloaded:
            return "Reduce pressure before adding more intent."
        case .recovering:
            return "Come back through one safer lane, not a full reset."
        case .lowData:
            return "Clarify the next step before pretending certainty."
        case .noPlan:
            return "Start with one bounded step and let the shell own the bigger reshaping."
        }
    }

    func dominantText(for posture: TodayDayPosture, heroTitle: String) -> String {
        switch posture {
        case .stable:
            return heroTitle
        case .tight:
            return "Hold the day around \(heroTitle.lowercased())"
        case .drifted:
            return "Return through \(heroTitle.lowercased())"
        case .overloaded:
            return "Lighten the day before it hardens"
        case .recovering:
            return "Recover through one believable step"
        case .lowData:
            return "Clarify the next step first"
        case .noPlan:
            return "Build today from one real step"
        }
    }

    func heroSupportingText(for posture: TodayDayPosture, heroDetail: String, ritual: TodayRitualLoopState) -> String {
        switch posture {
        case .stable:
            if ritual.thesis.localizedCaseInsensitiveContains("shared") &&
                heroDetail.localizedCaseInsensitiveContains("shared") == false {
                return ritual.thesis
            }
            return heroDetail
        case .tight, .recovering:
            return ritual.thesis
        case .drifted, .overloaded:
            return heroDetail.isEmpty ? ritual.subtitle : heroDetail
        case .lowData:
            return heroDetail
        case .noPlan:
            return ritual.thesis
        }
    }

    func makeReentryState(entryContext: TodayEntryContext) -> TodayReentryState? {
        switch entryContext.normalized {
        case .standard:
            return nil
        case .recovery:
            return TodayReentryState(
                eyebrow: "Re-entry",
                title: "Recovery landed in Today",
                detail: "This pass is centered on the calmest next step, not the whole backlog.",
                state: .selected
            )
        case .stepSession:
            return TodayReentryState(
                eyebrow: "Re-entry",
                title: "Step session landed in Today",
                detail: "The hero is holding the clearest next step without turning the session into a timer.",
                state: .success
            )
        case .focus:
            return nil
        }
    }

    func nextHeroItem(from dailyTargets: TodayDailyTargetsState, excluding title: String) -> (title: String, subtitle: String)? {
        guard let item = dailyTargets.items.first(where: { $0.title != title }) else {
            return nil
        }
        return (item.title, item.subtitle)
    }

    func nextHeroItem(from freeTime: TodayFreeTimeState) -> (title: String, subtitle: String)? {
        guard let item = freeTime.opportunities.first else { return nil }
        return (item.title, item.subtitle)
    }

    func makeTimeAperture(
        now: Date,
        posture: TodayDayPosture,
        focus: TodayFocusState,
        dailyTargets: TodayDailyTargetsState,
        freeTime: TodayFreeTimeState,
        milestone: TodayMilestoneState,
        shellSummary: GoalShellSummaryState?
    ) -> TodayTimeApertureState {
        let pressure = dayPressureState(
            posture: posture,
            fixedCount: dailyTargets.items.count,
            flexibleCount: freeTime.opportunities.count
        )
        let windows = openWindows(
            now: now,
            posture: posture,
            focus: focus,
            dailyTargets: dailyTargets,
            freeTime: freeTime
        )
        let bestUseAction = windows.first?.action ?? milestone.action
        let bestUseTitle: String
        let bestUseDetail: String
        if let window = windows.first {
            bestUseTitle = window.title
            bestUseDetail = window.subtitle
        } else if let opportunity = freeTime.opportunities.first {
            bestUseTitle = opportunity.title
            bestUseDetail = opportunity.subtitle
        } else {
            bestUseTitle = "Keep the day quiet"
            bestUseDetail = posture == .overloaded || posture == .drifted || posture == .recovering
                ? "The best use of the remaining day may be protecting one believable block instead of forcing more work."
                : "Unused room is allowed to stay unused when nothing cleanly fits."
        }

        let whisper = shellSummary.map { summary in
            TodayTrustWhisperState(
                title: pressure.label == "Needs confirmation" ? "May need confirmation" : "Based on",
                detail: pressure.label == "Needs confirmation"
                    ? "Time pressure is being inferred from current Time shape and may change as newer input lands."
                    : summary.pathSummary,
                state: pressure.state
            )
        }

        return TodayTimeApertureState(
            title: "Time Aperture",
            subtitle: "Room and pressure stay visible without turning Today into a dense calendar.",
            pressure: pressure,
            windows: windows,
            emptyMessage: windows.isEmpty ? "No open window needs to be filled right now." : nil,
            bestUseTitle: bestUseTitle,
            bestUseDetail: bestUseDetail,
            bestUseAction: bestUseAction,
            trustWhisper: whisper
        )
    }

    func dayPressureState(
        posture: TodayDayPosture,
        fixedCount: Int,
        flexibleCount: Int
    ) -> TodayDayPressureState {
        switch posture {
        case .stable:
            return TodayDayPressureState(
                title: "The day still has breathing room",
                detail: flexibleCount > 0
                    ? "There is space for one deliberate step and one flexible option if the first block lands."
                    : "The visible work can stay singular without squeezing more into the day.",
                label: "Strong fit",
                state: .success
            )
        case .tight:
            return TodayDayPressureState(
                title: "The day is getting tight",
                detail: "There is still enough room for one meaningful block, but extra switching will make the day noisier.",
                label: "Likely fit",
                state: .selected
            )
        case .drifted:
            return TodayDayPressureState(
                title: "The day drifted off its first Time",
                detail: "Pressure is less about time volume and more about getting back to one believable step.",
                label: "Needs recovery",
                state: .warning
            )
        case .overloaded:
            return TodayDayPressureState(
                title: "Too many asks are touching today",
                detail: "The remaining room is real, but only after the day is lightened back to one safe lane.",
                label: "Compressed",
                state: .warning
            )
        case .recovering:
            return TodayDayPressureState(
                title: "Recovery is already in progress",
                detail: "Use the remaining room for the smallest safe block, not for catching everything up.",
                label: "Recovering",
                state: .selected
            )
        case .lowData:
            return TodayDayPressureState(
                title: "Time shape is present, but certainty is not",
                detail: "The day can still hold one small step, but clarification matters before stronger timing claims.",
                label: "Needs confirmation",
                state: .warning
            )
        case .noPlan:
            return TodayDayPressureState(
                title: "Today has open room",
                detail: fixedCount == 0
                    ? "Nothing is forcing the day yet, so the first step should stay small and real."
                    : "One small commitment is enough to make the day useful.",
                label: "Open",
                state: .default
            )
        }
    }

}
