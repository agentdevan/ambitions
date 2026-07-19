import AmbitionsDesignSystem
import Foundation

extension TimeLifeSuiteProjector {
    func dayShapeFacts(_ today: TimeElasticWeekDayState?) -> [String] {
        guard let today else {
            return ["Manual shaping is available.", "Nothing shifts without review."]
        }
        return [
            today.capacityLabel,
            today.openWindow?.title ?? "No open window is suggested yet.",
            today.blocks.isEmpty ? "No fixed points attached." : "\(today.blocks.count) fixed point\((today.blocks.count == 1) ? "" : "s") attached."
        ]
    }

    func weekShapeFacts(
        weekDays: [TimeElasticWeekDayState],
        pressuredDays: Int,
        openCaptureCount: Int,
        openDays: Int
    ) -> [String] {
        [
            openDays == 1 ? "Open time: 1 day remains open." : "Open time: \(openDays) days remain open.",
            "\(pressuredDays) pressured day\((pressuredDays == 1) ? "" : "s") visible.",
            openCaptureCount == 1 ? "1 capture is waiting for review." : "\(openCaptureCount) captures are waiting for review.",
            "\(weekDays.count) day\((weekDays.count == 1) ? "" : "s") included in this week."
        ]
    }

    func lifeShapeDrillDown(
        weekDays: [TimeElasticWeekDayState],
        activeGoalCount: Int,
        openCaptureCount: Int
    ) -> TimeLifeShapeDrillDownState {
        let pressuredDays = weekDays.filter { [.tight, .fragile, .overloaded].contains($0.level) }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let fixedProtectedBlocks = weekDays.flatMap(\.blocks).filter { $0.kind == .fixed }
            .count
        let flexibleBlocks = weekDays.flatMap(\.blocks).filter { $0.kind == .flexible }
            .count
        let transitionFriction = max(pressuredDays - max(openDays, 0), 0)
        let protectedBlocks = weekDays.flatMap(\.blocks).filter { $0.kind == .protected || $0.kind == .fixed }
        let allBlocks = weekDays.flatMap(\.blocks)
        let milestoneTitles = Array(allBlocks.prefix(2)).map(\.goalLabel).uniqued()
        let pressureState: AmbitionVisualState = pressuredDays > 0 ? .warning : .selected
        let isNoOpen = openDays == 0
        let rhythmLabel = pressuredDays > 0
            ? "Rhythm: pressure gathers on \(pressuredDays) day\((pressuredDays == 1) ? "" : "s")."
            : "Rhythm: the visible week has room to breathe."
        let milestoneLabel = milestoneTitles.isEmpty
            ? "Milestones: no active milestone needs wider Time yet."
            : "Milestones: \(milestoneTitles.joined(separator: ", ")) shape the longer arc."

        return TimeLifeShapeDrillDownState(
            title: "Life Calendar detail",
            subtitle: "Month/year life-range horizon, rhythm, and instrument readings stay inspectable without becoming an event list.",
            rhythmLabel: rhythmLabel,
            pressureWeeksLabel: pressuredDays == 0
                ? "Pressure weeks: no pressured band is asking for review."
                : "Pressure weeks: review relief before adding new commitments.",
            milestoneLabel: milestoneLabel,
            protectedTimeLabel: protectedBlocks.isEmpty
                ? "Protected time: nothing protected is competing loudly."
                : "Protected time: \(protectedBlocks.count) fixed or protected block\((protectedBlocks.count == 1) ? "" : "s") stay visible.",
            freeTimeLabel: openDays == 0
                ? "Free-time bands: create one smaller opening before widening the shape."
                : "Free-time bands: \(openDays) open day\((openDays == 1) ? "" : "s") can protect recovery.",
            recoverySpaceLabel: openDays > 0
                ? "Recovery space: protect open room before filling it."
                : "Recovery space: reduce the ask before the next commitment.",
            commitmentLoadLabel: allBlocks.isEmpty
                ? "Commitment load: no visible commitments are crowding the shape."
                : "Commitment load: \(allBlocks.count) visible block\((allBlocks.count == 1) ? "" : "s") across active Time shape.",
            monthRangeLabel: activeGoalCount == 0
                ? "Month horizon: no active Time horizon loaded yet."
                : "Month horizon: active commitments remain within the month-level shape.",
            yearRangeLabel: activeGoalCount == 0
                ? "Year horizon: no long-range pressure signal is active yet."
                : "Year horizon: longer-view openings are visible and still editable by local confirmation.",
            lifeRangeLabel: openCaptureCount == 0
                ? "Life range: open capacity is currently broad."
                : "Life range: \(openCaptureCount) capture\((openCaptureCount == 1) ? "" : "s") still needs placement.",
            cognitiveLoadLabel: isNoOpen
                ? "Cognitive load: high visual density suggests review-first."
                : "Cognitive load: stable enough for one focused shape.",
            physicalEnergyLabel: openCaptureCount > 0
                ? "Physical energy: keep protected time before adding more capacity."
                : "Physical energy: no immediate overload from visible commitments.",
            transitionFrictionLabel: transitionFriction > 0
                ? "Transition friction: \(transitionFriction) transition point\((transitionFriction == 1) ? "" : "s") need smoothing before expansion."
                : "Transition friction: transitions are manageable for now.",
            freeTimeQualityLabel: fixedProtectedBlocks > flexibleBlocks
                ? "Free-time quality: protected time is helping recovery."
                : "Free-time quality: watch quality drift before opening bigger commitments.",
            executionLanesLabel: allBlocks.isEmpty
                ? "Open time: none currently active in this Life Calendar slice."
                : "Open time: \(allBlocks.count) block\((allBlocks.count == 1) ? "" : "s") stay reviewable before mutation.",
            goalLoadLabel: activeGoalCount == 0
                ? "Goal load: no active goals to stretch this shape."
                : "Goal load: \(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") shape the longer range.",
            items: [
                TimeLifeShapeDrillDownItemState(
                    id: "life-areas",
                    title: "Life areas",
                    value: activeGoalCount == 0 ? "Quiet" : "\(activeGoalCount) active",
                    detail: activeGoalCount == 0
                        ? "Life Calendar waits for active goals before drawing a wider pattern."
                        : "Active goals are the source for longer-range shape.",
                    visualState: activeGoalCount == 0 ? .default : .selected
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "pressure-weeks",
                    title: "Pressure weeks",
                    value: pressuredDays == 0 ? "Clear" : "\(pressuredDays) visible",
                    detail: pressuredDays == 0
                        ? "No pressure band needs a larger review right now."
                        : "Pressure needs relief before the shape grows.",
                    visualState: pressureState
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "milestones",
                    title: "Milestones",
                    value: milestoneTitles.isEmpty ? "None visible" : "\(milestoneTitles.count) visible",
                    detail: milestoneTitles.first.map { "\($0) is the clearest current milestone source." }
                        ?? "Milestones appear when active goals carry visible steps.",
                    visualState: milestoneTitles.isEmpty ? .default : .selected
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "protected-time",
                    title: "Protected time",
                    value: protectedBlocks.isEmpty ? "Clear" : "\(protectedBlocks.count) protected",
                    detail: protectedBlocks.isEmpty
                        ? "No protected block needs a wider explanation."
                        : "Protected time stays visible before any review.",
                    visualState: protectedBlocks.isEmpty ? .success : .warning
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "free-time",
                    title: "Free-time bands",
                    value: openDays == 0 ? "Tight" : "\(openDays) open",
                    detail: openDays == 0
                        ? "Make room by reducing the ask."
                        : "Open room is recovery space, not automatic capacity.",
                    visualState: openDays == 0 ? .warning : .success
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "commitment-load",
                    title: "Commitment load",
                    value: allBlocks.isEmpty ? "Light" : "\(allBlocks.count) visible",
                    detail: "Load stays qualitative and reviewable.",
                    visualState: pressureState
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "month-horizon",
                    title: "Month horizon",
                    value: activeGoalCount == 0 ? "Open" : "Shaped",
                    detail: "Month-level shaping stays local and inspectable, not a scheduling forecast.",
                    visualState: activeGoalCount == 0 ? .default : .selected
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "year-horizon",
                    title: "Year horizon",
                    value: activeGoalCount == 0 ? "Open" : "Shaped",
                    detail: "Year-level shape stays editable before any broad commitment change.",
                    visualState: activeGoalCount == 0 ? .default : .selected
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "life-range",
                    title: "Life range",
                    value: allBlocks.isEmpty ? "Stable" : "Active",
                    detail: "Life range shows where capacity is real today and this week.",
                    visualState: isNoOpen ? .warning : .success
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "cognitive-load",
                    title: "Cognitive load",
                    value: pressuredDays == 0 ? "Calm" : "Focused",
                    detail: "Cognitive load is derived from pressure bands and block pressure.",
                    visualState: pressuredDays > 0 ? .warning : .success
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "physical-energy",
                    title: "Physical energy",
                    value: openDays == 0 ? "Tight" : "Steady",
                    detail: "Protect recovery room before extending capacity.",
                    visualState: openDays == 0 ? .warning : .selected
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "transition-friction",
                    title: "Transition friction",
                    value: transitionFriction == 0 ? "Low" : "\(transitionFriction) active",
                    detail: "Smoother transitions reduce silent schedule churn.",
                    visualState: transitionFriction == 0 ? .success : .warning
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "free-time-quality",
                    title: "Free-time quality",
                    value: openDays == 0 ? "Compressed" : "Open",
                    detail: "Free-time quality should stay inspectable before expanding the week.",
                    visualState: openDays == 0 ? .warning : .success
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "open-time",
                    title: "Open time",
                    value: weekDays.count == 0 ? "None" : "\(weekDays.count) blocks",
                    detail: "Open time is reviewed before any schedule mutation.",
                    visualState: weekDays.count == 0 ? .default : .selected
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "goal-load",
                    title: "Goal load",
                    value: activeGoalCount == 0 ? "Quiet" : "\(activeGoalCount) goals",
                    detail: "Goal load stays explicit to preserve non-coercive execution.",
                    visualState: activeGoalCount == 0 ? .default : .warning
                )
            ]
        )
    }
}

private extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var seen = Set<Element>()
        return filter { seen.insert($0).inserted }
    }
}
