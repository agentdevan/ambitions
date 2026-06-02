import AmbitionsDesignSystem
import Foundation

enum TimeLifeSuiteShapeKind: String, Sendable, CaseIterable {
    case day = "day_shape"
    case week = "week_shape"
    case life = "life_shape"
}

struct TimeLifeSuiteShapeState: Identifiable, Sendable {
    let kind: TimeLifeSuiteShapeKind
    let title: String
    let question: String
    let summary: String
    let facts: [String]
    let sourceLabel: String
    let boundaryLabel: String
    let schedulePressureLabel: String
    let protectedTimeLabel: String
    let capacityLabel: String
    let proofOpportunityLabel: String
    let provenanceLabel: String
    let privacyLabel: String
    let visualState: AmbitionVisualState

    var id: String { kind.rawValue }

    init(
        kind: TimeLifeSuiteShapeKind,
        title: String,
        question: String,
        summary: String,
        facts: [String],
        sourceLabel: String,
        boundaryLabel: String,
        schedulePressureLabel: String = "Schedule pressure: review locally.",
        protectedTimeLabel: String = "Protected time: visible locally.",
        capacityLabel: String = "Capacity: qualitative only.",
        proofOpportunityLabel: String = "Proof opportunity: receipts stay local.",
        provenanceLabel: String = "Provenance: local Time state.",
        privacyLabel: String = "Privacy: local-only preview.",
        visualState: AmbitionVisualState
    ) {
        self.kind = kind
        self.title = title
        self.question = question
        self.summary = summary
        self.facts = facts
        self.sourceLabel = sourceLabel
        self.boundaryLabel = boundaryLabel
        self.schedulePressureLabel = schedulePressureLabel
        self.protectedTimeLabel = protectedTimeLabel
        self.capacityLabel = capacityLabel
        self.proofOpportunityLabel = proofOpportunityLabel
        self.provenanceLabel = provenanceLabel
        self.privacyLabel = privacyLabel
        self.visualState = visualState
    }
}

struct TimeLifeSuiteState: Sendable {
    let title: String
    let subtitle: String
    let shapes: [TimeLifeSuiteShapeState]
    let drillDown: TimeLifeShapeDrillDownState
    let calendarBoundaryLabel: String
    let manualFallbackLabel: String
    let trustLabel: String

    init(
        title: String,
        subtitle: String,
        shapes: [TimeLifeSuiteShapeState],
        drillDown: TimeLifeShapeDrillDownState = .baseline,
        calendarBoundaryLabel: String,
        manualFallbackLabel: String,
        trustLabel: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.shapes = shapes
        self.drillDown = drillDown
        self.calendarBoundaryLabel = calendarBoundaryLabel
        self.manualFallbackLabel = manualFallbackLabel
        self.trustLabel = trustLabel
    }
}

struct TimeLifeShapeDrillDownItemState: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let value: String
    let detail: String
    let visualState: AmbitionVisualState
}

struct TimeLifeShapeDrillDownState: Sendable {
    let title: String
    let subtitle: String
    let rhythmLabel: String
    let pressureWeeksLabel: String
    let milestoneLabel: String
    let protectedTimeLabel: String
    let freeTimeLabel: String
    let recoverySpaceLabel: String
    let commitmentLoadLabel: String
    let items: [TimeLifeShapeDrillDownItemState]

    static let baseline = TimeLifeShapeDrillDownState(
        title: "LifeShape Field detail",
        subtitle: "Longer-range shape stays explanatory, not event-like.",
        rhythmLabel: "Rhythm: no pattern loaded yet.",
        pressureWeeksLabel: "Pressure weeks: none visible.",
        milestoneLabel: "Milestones: no active milestones visible.",
        protectedTimeLabel: "Protected time: none marked.",
        freeTimeLabel: "Free-time bands: manual review available.",
        recoverySpaceLabel: "Recovery space: keep one pocket open.",
        commitmentLoadLabel: "Commitment load: qualitative only.",
        items: []
    )

    var accessibilityValue: String {
        [
            title,
            subtitle,
            rhythmLabel,
            pressureWeeksLabel,
            milestoneLabel,
            protectedTimeLabel,
            freeTimeLabel,
            recoverySpaceLabel,
            commitmentLoadLabel
        ].joined(separator: ". ")
    }
}

struct TimeLifeSuiteProjector: Sendable {
    func project(
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        activeGoalCount: Int,
        mode: TimeDashboardMode
    ) -> TimeLifeSuiteState {
        TimeLifeSuiteState(
            title: "Shape Time",
            subtitle: "Open time, goal time, protected time, pressure, source state, and manual fallback stay inspectable.",
            shapes: [
                dayShape(weekDays: weekDays, calendarAwareness: calendarAwareness),
                weekShape(
                    weekDays: weekDays,
                    openCaptureCount: openCaptureCount,
                    activeGoalCount: activeGoalCount,
                    calendarAwareness: calendarAwareness,
                    mode: mode
                ),
                lifeShape(activeGoalCount: activeGoalCount, calendarAwareness: calendarAwareness)
            ],
            drillDown: lifeShapeDrillDown(
                weekDays: weekDays,
                activeGoalCount: activeGoalCount,
                openCaptureCount: openCaptureCount
            ),
            calendarBoundaryLabel: calendarAwareness.canRequestCalendarRead ? "Calendar stays optional" : "Manual planning still works",
            manualFallbackLabel: "Manual fallback available",
            trustLabel: "No silent calendar changes"
        )
    }

    private func dayShape(
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeLifeSuiteShapeState {
        let today = weekDays.first
        let protectedTime = today?.blocks.filter { $0.kind == .protected || $0.kind == .fixed }.count ?? 0
        let capacityLabel = today.map { $0.capacityLabel } ?? "Manual shaping available"
        return TimeLifeSuiteShapeState(
            kind: .day,
            title: "Day Shape",
            question: "What can this day honestly hold?",
            summary: today.map { "\($0.weekdayLabel) has \($0.roomLabel.lowercased()) and \($0.blocks.count) planned block\($0.blocks.count == 1 ? "" : "s")." }
                ?? "No day shape is loaded yet.",
            facts: dayShapeFacts(today),
            sourceLabel: "Based on Time",
            boundaryLabel: "No silent replanning",
            schedulePressureLabel: today.map { "Schedule pressure: \($0.roomLabel.lowercased())." } ?? "Schedule pressure: no day is loaded yet.",
            protectedTimeLabel: protectedTime == 0
                ? "Protected time: none marked in the current day."
                : "Protected time: \(protectedTime) fixed or protected item\(protectedTime == 1 ? "" : "s") stay visible.",
            capacityLabel: "Capacity: \(capacityLabel).",
            proofOpportunityLabel: today == nil
                ? "Proof opportunity: no day is loaded yet."
                : "Proof opportunity: one clear receipt can explain the day without changing it.",
            provenanceLabel: "Provenance: based on Time and today's visible blocks.",
            privacyLabel: calendarAwareness.canRequestCalendarRead
                ? "Privacy: calendar access stays optional and local."
                : "Privacy: this view stays local-only.",
            visualState: today?.level.visualState ?? .default
        )
    }

    private func weekShape(
        weekDays: [TimeElasticWeekDayState],
        openCaptureCount: Int,
        activeGoalCount: Int,
        calendarAwareness: TimeCalendarAwarenessState,
        mode: TimeDashboardMode
    ) -> TimeLifeSuiteShapeState {
        let pressuredDays = weekDays.filter { [.tight, .fragile, .overloaded].contains($0.level) }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let protectedDays = weekDays.flatMap(\.blocks).filter { $0.kind == .protected || $0.kind == .fixed }.count
        let summary: String
        if mode == .empty {
            summary = "The week has room until goals, captures, or routines create real constraints."
        } else if pressuredDays > 0 {
            summary = "\(pressuredDays) day\((pressuredDays == 1) ? "" : "s") may need shaping before the week feels believable."
        } else {
            summary = "The week has visible room and no overloaded day in the current plan."
        }

        return TimeLifeSuiteShapeState(
            kind: .week,
            title: "Week Shape",
            question: "Does the week still fit?",
            summary: openCaptureCount > 0
                ? "\(summary) \(openCaptureCount) capture\((openCaptureCount == 1) ? "" : "s") still need a place."
                : summary,
            facts: weekShapeFacts(
                weekDays: weekDays,
                pressuredDays: pressuredDays,
                openCaptureCount: openCaptureCount,
                openDays: openDays
            ),
            sourceLabel: "Based on goals and captures",
            boundaryLabel: "Suggestions require confirmation",
            schedulePressureLabel: pressuredDays == 0
                ? "Schedule pressure: the week is readable."
                : "Schedule pressure: \(pressuredDays) pressured day\((pressuredDays == 1) ? "" : "s") need review.",
            protectedTimeLabel: protectedDays == 0
                ? "Protected time: nothing is defending the week yet."
                : "Protected time: \(protectedDays) fixed or protected block\((protectedDays == 1) ? "" : "s") stay visible.",
            capacityLabel: openCaptureCount > 0
                ? "Capacity: \(openCaptureCount) capture\((openCaptureCount == 1) ? "" : "s") still need placement."
                : "Capacity: the current week has visible room.",
            proofOpportunityLabel: activeGoalCount == 0
                ? "Proof opportunity: no active goal is asking for a receipt yet."
                : "Proof opportunity: active goals can become inspectable receipts when one small step is confirmed.",
            provenanceLabel: "Provenance: based on goals, captures, and local week pressure.",
            privacyLabel: calendarAwareness.canRequestCalendarRead
                ? "Privacy: derived busy time stays locally inspectable and never writes silently."
                : "Privacy: local goals and captures are enough for this view, with manual fallback available.",
            visualState: pressuredDays > 0 ? .warning : .selected
        )
    }

    private func lifeShape(
        activeGoalCount: Int,
        calendarAwareness: TimeCalendarAwarenessState
    ) -> TimeLifeSuiteShapeState {
        TimeLifeSuiteShapeState(
            kind: .life,
            title: "Life Shape",
            question: "Is Time still pointed at the life you are building?",
            summary: activeGoalCount == 0
                ? "Life Shape is quiet until active goals give Time something to shape."
                : "\(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") shape the current LifeShape Field.",
            facts: [
                activeGoalCount == 0 ? "No active goals shaping life view yet." : "\(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") included.",
                "Life Shape stays inside Time.",
                "Manual fallback stays available."
            ],
            sourceLabel: "Based on active goals",
            boundaryLabel: "Life view, broader than time slots",
            schedulePressureLabel: activeGoalCount == 0
                ? "Schedule pressure: no active goal is loading the longer arc yet."
                : "Schedule pressure: active goals are shaping the longer arc.",
            protectedTimeLabel: "Protected time: the longer arc stays wider than any one day.",
            capacityLabel: activeGoalCount == 0
                ? "Capacity: the life view is quiet until goals give it shape."
                : "Capacity: \(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") keep the life view meaningful.",
            proofOpportunityLabel: activeGoalCount == 0
                ? "Proof opportunity: no long-range proof is expected yet."
                : "Proof opportunity: active goals can show durable proof when receipts are recorded locally.",
            provenanceLabel: "Provenance: based on active goals and LifeShape state.",
            privacyLabel: calendarAwareness.canRequestCalendarRead
                ? "Privacy: calendar access is optional, local, and never silent."
                : "Privacy: this life view remains local-only and never writes silently.",
            visualState: activeGoalCount == 0 ? .default : .selected
        )
    }

    private func dayShapeFacts(_ today: TimeElasticWeekDayState?) -> [String] {
        guard let today else {
            return ["Manual shaping is available.", "Nothing shifts without review."]
        }
        return [
            today.capacityLabel,
            today.openWindow?.title ?? "No open window is suggested yet.",
            today.blocks.isEmpty ? "No planned blocks attached." : "\(today.blocks.count) planned block\((today.blocks.count == 1) ? "" : "s") attached."
        ]
    }

    private func weekShapeFacts(
        weekDays: [TimeElasticWeekDayState],
        pressuredDays: Int,
        openCaptureCount: Int,
        openDays: Int
    ) -> [String] {
        [
            openDays == 1 ? "Open time: 1 day remains open." : "Open time: \(openDays) days remain open.",
            "\(pressuredDays) pressured day\((pressuredDays == 1) ? "" : "s") visible.",
            openCaptureCount == 1 ? "1 capture needs a place." : "\(openCaptureCount) captures need a place.",
            "\(weekDays.count) day\((weekDays.count == 1) ? "" : "s") included in this week."
        ]
    }

    private func lifeShapeDrillDown(
        weekDays: [TimeElasticWeekDayState],
        activeGoalCount: Int,
        openCaptureCount: Int
    ) -> TimeLifeShapeDrillDownState {
        let pressuredDays = weekDays.filter { [.tight, .fragile, .overloaded].contains($0.level) }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let protectedBlocks = weekDays.flatMap(\.blocks).filter { $0.kind == .protected || $0.kind == .fixed }
        let allBlocks = weekDays.flatMap(\.blocks)
        let milestoneTitles = Array(allBlocks.prefix(2)).map(\.goalLabel).uniqued()
        let pressureState: AmbitionVisualState = pressuredDays > 0 ? .warning : .selected
        let rhythmLabel = pressuredDays > 0
            ? "Rhythm: pressure gathers on \(pressuredDays) day\((pressuredDays == 1) ? "" : "s")."
            : "Rhythm: the visible week has room to breathe."
        let milestoneLabel = milestoneTitles.isEmpty
            ? "Milestones: no active milestone needs a wider lane yet."
            : "Milestones: \(milestoneTitles.joined(separator: ", ")) shape the longer arc."

        return TimeLifeShapeDrillDownState(
            title: "LifeShape Field detail",
            subtitle: "Longer-range planning explains rhythm, pressure, recovery, and milestones without becoming an event list.",
            rhythmLabel: rhythmLabel,
            pressureWeeksLabel: pressuredDays == 0
                ? "Pressure weeks: no pressured band is asking for review."
                : "Pressure weeks: review relief before adding new commitments.",
            milestoneLabel: milestoneLabel,
            protectedTimeLabel: protectedBlocks.isEmpty
                ? "Protected time: nothing protected is competing loudly."
                : "Protected time: \(protectedBlocks.count) fixed or protected block\((protectedBlocks.count == 1) ? "" : "s") stay visible.",
            freeTimeLabel: openDays == 0
                ? "Free-time bands: create one smaller pocket before widening the shape."
                : "Free-time bands: \(openDays) open day\((openDays == 1) ? "" : "s") can protect recovery.",
            recoverySpaceLabel: openDays > 0
                ? "Recovery space: protect open room before filling it."
                : "Recovery space: reduce the ask before the next commitment.",
            commitmentLoadLabel: allBlocks.isEmpty
                ? "Commitment load: no visible commitments are crowding the shape."
                : "Commitment load: \(allBlocks.count) visible block\((allBlocks.count == 1) ? "" : "s") across active planning.",
            items: [
                TimeLifeShapeDrillDownItemState(
                    id: "life-areas",
                    title: "Life areas",
                    value: activeGoalCount == 0 ? "Quiet" : "\(activeGoalCount) active",
                    detail: activeGoalCount == 0
                        ? "LifeShape Field waits for active goals before drawing a wider pattern."
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
                        ?? "Milestones appear when active plans carry visible steps.",
                    visualState: milestoneTitles.isEmpty ? .default : .selected
                ),
                TimeLifeShapeDrillDownItemState(
                    id: "protected-time",
                    title: "Protected time",
                    value: protectedBlocks.isEmpty ? "Clear" : "\(protectedBlocks.count) protected",
                    detail: protectedBlocks.isEmpty
                        ? "No protected block needs a wider explanation."
                        : "Protected time stays visible before any reflow.",
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
