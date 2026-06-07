import AmbitionsDesignSystem
import Foundation

enum TimeLifeSuiteShapeKind: String, Sendable, CaseIterable {
    case day = "day_shape"
    case week = "week_shape"
    case life = "life_shape"
}

enum TimeHorizon: String, Sendable, CaseIterable, Identifiable {
    case day
    case week
    case month

    var id: String { rawValue }

    var title: String {
        switch self {
        case .day: "Day"
        case .week: "Week"
        case .month: "Month"
        }
    }
}

enum LifeShapeSegmentKind: String, Sendable {
    case openTime
    case goalTime
    case protectedTime
    case pressure
    case recovery
    case source

    var title: String {
        switch self {
        case .openTime: "Open time"
        case .goalTime: "Goal time"
        case .protectedTime: "Protected time"
        case .pressure: "Pressure"
        case .recovery: "Recovery"
        case .source: "Source"
        }
    }

    var systemImage: String {
        switch self {
        case .openTime: "sun.max"
        case .goalTime: "scope"
        case .protectedTime: "lock"
        case .pressure: "waveform.path"
        case .recovery: "leaf"
        case .source: "checkmark.shield"
        }
    }
}

struct LifeShapeSegment: Identifiable, Sendable, Hashable {
    let id: String
    let kind: LifeShapeSegmentKind
    let title: String
    let detail: String
    let valueLabel: String
    let weight: Double
    let visualState: AmbitionVisualState

    init(
        kind: LifeShapeSegmentKind,
        title: String? = nil,
        detail: String,
        valueLabel: String,
        weight: Double,
        visualState: AmbitionVisualState
    ) {
        self.id = kind.rawValue
        self.kind = kind
        self.title = title ?? kind.title
        self.detail = detail
        self.valueLabel = valueLabel
        self.weight = min(max(weight, 0), 1)
        self.visualState = visualState
    }
}

enum LifeShapeCapacityFit: String, Sendable {
    case open
    case steady
    case tight
    case overloaded

    var title: String {
        switch self {
        case .open: "Open"
        case .steady: "Steady"
        case .tight: "Tight"
        case .overloaded: "Needs relief"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .open, .steady: .selected
        case .tight, .overloaded: .warning
        }
    }
}

struct LifeShapeReading: Sendable, Hashable {
    let horizon: TimeHorizon
    let title: String
    let summary: String
    let capacityStatement: String
    let sourceDetail: String
}

struct LifeShapeSourceState: Sendable, Hashable {
    let title: String
    let detail: String
    let whyThisLabel: String
    let privacyLabel: String
    let visualState: AmbitionVisualState
}

struct LifeShapeReflowProposal: Sendable, Hashable {
    let title: String
    let detail: String
    let actionTitle: String
    let visualState: AmbitionVisualState
}

struct LifeShapeReceipt: Sendable, Hashable {
    let title: String
    let detail: String
    let ageLabel: String
    let visualState: AmbitionVisualState
}

enum LifeShapeRenderState: String, Sendable, Hashable {
    case defaultWeek
    case manualOnly
    case calendarDenied
    case pressureCluster
    case sourceConflict
    case reflowPreview
    case receiptAttached

    var title: String {
        switch self {
        case .defaultWeek: "Default week"
        case .manualOnly: "Manual-only"
        case .calendarDenied: "Calendar denied"
        case .pressureCluster: "Pressure cluster"
        case .sourceConflict: "Source conflict"
        case .reflowPreview: "Reflow preview"
        case .receiptAttached: "Receipt attached"
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .defaultWeek, .receiptAttached: .selected
        case .manualOnly, .reflowPreview: .default
        case .calendarDenied, .pressureCluster, .sourceConflict: .warning
        }
    }
}

enum LifeShapeSemanticMarkKind: String, Sendable, Hashable {
    case pressure
    case cognitiveLoad
    case physicalEnergy
    case transitionFriction
    case protectedTime
    case recoveryNeed
    case freeTimeQuality
    case executionLanes
    case goalLoad
    case sourceConflict
    case receiptReflow

    var title: String {
        switch self {
        case .pressure: "Pressure"
        case .cognitiveLoad: "Cognitive load"
        case .physicalEnergy: "Physical energy"
        case .transitionFriction: "Transition friction"
        case .protectedTime: "Protected time"
        case .recoveryNeed: "Recovery need"
        case .freeTimeQuality: "Free-time quality"
        case .executionLanes: "Execution lanes"
        case .goalLoad: "Goal load"
        case .sourceConflict: "Source conflict"
        case .receiptReflow: "Receipt/reflow"
        }
    }

    var semanticMeaning: String {
        switch self {
        case .pressure: "Compression ridge"
        case .cognitiveLoad: "Mental load contour"
        case .physicalEnergy: "Energy basin"
        case .transitionFriction: "Narrowed bridge"
        case .protectedTime: "Preserved boundary"
        case .recoveryNeed: "Reserve pocket"
        case .freeTimeQuality: "Available lane quality"
        case .executionLanes: "Execution lane"
        case .goalLoad: "Anchored goal lane"
        case .sourceConflict: "Split trace"
        case .receiptReflow: "Proof mark"
        }
    }

    var systemImage: String {
        switch self {
        case .pressure: "waveform.path"
        case .cognitiveLoad: "brain"
        case .physicalEnergy: "bolt.heart"
        case .transitionFriction: "arrow.triangle.branch"
        case .protectedTime: "lock"
        case .recoveryNeed: "leaf"
        case .freeTimeQuality: "sun.max"
        case .executionLanes: "point.topleft.down.curvedto.point.bottomright.up"
        case .goalLoad: "scope"
        case .sourceConflict: "exclamationmark.triangle"
        case .receiptReflow: "checkmark.seal"
        }
    }
}

struct LifeShapeSemanticMark: Identifiable, Sendable, Hashable {
    let id: String
    let kind: LifeShapeSemanticMarkKind
    let valueLabel: String
    let detail: String
    let intensity: Double
    let visualState: AmbitionVisualState

    init(
        kind: LifeShapeSemanticMarkKind,
        valueLabel: String,
        detail: String,
        intensity: Double,
        visualState: AmbitionVisualState
    ) {
        self.id = kind.rawValue
        self.kind = kind
        self.valueLabel = valueLabel
        self.detail = detail
        self.intensity = min(max(intensity, 0), 1)
        self.visualState = visualState
    }
}

struct LifeShapeFieldState: Sendable, Hashable {
    let defaultHorizon: TimeHorizon
    let capacityFit: LifeShapeCapacityFit
    let segments: [LifeShapeSegment]
    let semanticMarks: [LifeShapeSemanticMark]
    let renderState: LifeShapeRenderState
    let readings: [TimeHorizon: LifeShapeReading]
    let sourceState: LifeShapeSourceState
    let reflowProposal: LifeShapeReflowProposal
    let receipt: LifeShapeReceipt
    let continuityDockItems: [String]

    func reading(for horizon: TimeHorizon) -> LifeShapeReading {
        readings[horizon] ?? readings[defaultHorizon] ?? LifeShapeReading(
            horizon: defaultHorizon,
            title: "Week shape",
            summary: "Time is waiting for enough local context to shape the field.",
            capacityStatement: "Capacity is qualitative until more local context is available.",
            sourceDetail: sourceState.detail
        )
    }
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
    let field: LifeShapeFieldState
    let drillDown: TimeLifeShapeDrillDownState
    let calendarBoundaryLabel: String
    let manualFallbackLabel: String
    let trustLabel: String

    init(
        title: String,
        subtitle: String,
        shapes: [TimeLifeSuiteShapeState],
        field: LifeShapeFieldState? = nil,
        drillDown: TimeLifeShapeDrillDownState = .baseline,
        calendarBoundaryLabel: String,
        manualFallbackLabel: String,
        trustLabel: String
    ) {
        self.title = title
        self.subtitle = subtitle
        self.shapes = shapes
        self.field = field ?? Self.fallbackField(
            shapes: shapes,
            calendarBoundaryLabel: calendarBoundaryLabel,
            manualFallbackLabel: manualFallbackLabel,
            trustLabel: trustLabel
        )
        self.drillDown = drillDown
        self.calendarBoundaryLabel = calendarBoundaryLabel
        self.manualFallbackLabel = manualFallbackLabel
        self.trustLabel = trustLabel
    }

    private static func fallbackField(
        shapes: [TimeLifeSuiteShapeState],
        calendarBoundaryLabel: String,
        manualFallbackLabel: String,
        trustLabel: String
    ) -> LifeShapeFieldState {
        let week = shapes.first { $0.kind == .week } ?? shapes.first
        let day = shapes.first { $0.kind == .day } ?? week
        let life = shapes.first { $0.kind == .life } ?? week
        let fit: LifeShapeCapacityFit = week?.visualState == .warning ? .tight : .steady
        return LifeShapeFieldState(
            defaultHorizon: .week,
            capacityFit: fit,
            segments: [
                LifeShapeSegment(kind: .openTime, detail: day?.summary ?? "Manual shaping available.", valueLabel: day?.capacityLabel ?? "Manual", weight: 0.44, visualState: day?.visualState ?? .default),
                LifeShapeSegment(kind: .goalTime, detail: life?.summary ?? "Goal load not loaded.", valueLabel: life?.sourceLabel ?? "Goals", weight: 0.50, visualState: life?.visualState ?? .default),
                LifeShapeSegment(kind: .protectedTime, detail: day?.protectedTimeLabel ?? "Protected time is inspectable.", valueLabel: "Protected", weight: 0.38, visualState: .selected),
                LifeShapeSegment(kind: .pressure, detail: week?.schedulePressureLabel ?? "Pressure is reviewable.", valueLabel: fit.title, weight: fit == .tight ? 0.78 : 0.44, visualState: fit.visualState),
                LifeShapeSegment(kind: .recovery, detail: "Recovery stays available without shame.", valueLabel: "Recovery", weight: 0.34, visualState: .default),
                LifeShapeSegment(kind: .source, detail: trustLabel, valueLabel: "Local", weight: 0.30, visualState: .selected)
            ],
            semanticMarks: Self.fallbackSemanticMarks(fit: fit),
            renderState: .defaultWeek,
            readings: [
                .day: LifeShapeReading(horizon: .day, title: day?.title ?? "Day shape", summary: day?.summary ?? "Manual shaping available.", capacityStatement: day?.capacityLabel ?? "Capacity is qualitative.", sourceDetail: day?.provenanceLabel ?? manualFallbackLabel),
                .week: LifeShapeReading(horizon: .week, title: week?.title ?? "Week shape", summary: week?.summary ?? "Week shape is local and qualitative.", capacityStatement: week?.capacityLabel ?? "Capacity is qualitative.", sourceDetail: week?.provenanceLabel ?? manualFallbackLabel),
                .month: LifeShapeReading(horizon: .month, title: "Month shape", summary: life?.summary ?? "Longer-range Time shape is quiet.", capacityStatement: life?.capacityLabel ?? "Longer-range capacity is qualitative.", sourceDetail: life?.provenanceLabel ?? manualFallbackLabel)
            ],
            sourceState: LifeShapeSourceState(title: calendarBoundaryLabel, detail: manualFallbackLabel, whyThisLabel: trustLabel, privacyLabel: "Local Time state; no silent calendar write.", visualState: .selected),
            reflowProposal: LifeShapeReflowProposal(title: "Reflow stays optional", detail: "Time can suggest relief only after capacity is clear.", actionTitle: "Review shape", visualState: fit.visualState),
            receipt: LifeShapeReceipt(title: "No silent changes", detail: trustLabel, ageLabel: "Current", visualState: .selected),
            continuityDockItems: ["Open field", "Protect pocket", "Review receipt"]
        )
    }

    private static func fallbackSemanticMarks(fit: LifeShapeCapacityFit) -> [LifeShapeSemanticMark] {
        [
            LifeShapeSemanticMark(kind: .pressure, valueLabel: fit.title, detail: "Pressure is represented as a compression ridge.", intensity: fit == .tight ? 0.70 : 0.34, visualState: fit.visualState),
            LifeShapeSemanticMark(kind: .cognitiveLoad, valueLabel: "Reviewable", detail: "Mental load stays visible as text and mark.", intensity: 0.42, visualState: .default),
            LifeShapeSemanticMark(kind: .physicalEnergy, valueLabel: "Unloaded", detail: "Energy state is quiet until local context changes.", intensity: 0.30, visualState: .default),
            LifeShapeSemanticMark(kind: .transitionFriction, valueLabel: "Smooth", detail: "No narrowed bridge is active.", intensity: 0.26, visualState: .default),
            LifeShapeSemanticMark(kind: .protectedTime, valueLabel: "Protected", detail: "Protected time uses a preserved boundary.", intensity: 0.38, visualState: .selected),
            LifeShapeSemanticMark(kind: .recoveryNeed, valueLabel: "Reserve", detail: "Recovery need is a reserve pocket.", intensity: 0.34, visualState: .default),
            LifeShapeSemanticMark(kind: .freeTimeQuality, valueLabel: "Available", detail: "Free-time quality appears as lane quality.", intensity: 0.52, visualState: .selected),
            LifeShapeSemanticMark(kind: .executionLanes, valueLabel: "Open lanes", detail: "Execution lanes show where action can fit.", intensity: 0.48, visualState: .selected),
            LifeShapeSemanticMark(kind: .goalLoad, valueLabel: "Anchored", detail: "Goal load is an anchored lane.", intensity: 0.44, visualState: .selected)
        ]
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
    let monthRangeLabel: String
    let yearRangeLabel: String
    let lifeRangeLabel: String
    let cognitiveLoadLabel: String
    let physicalEnergyLabel: String
    let transitionFrictionLabel: String
    let freeTimeQualityLabel: String
    let executionLanesLabel: String
    let goalLoadLabel: String
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
        monthRangeLabel: "Month horizon: not yet loaded.",
        yearRangeLabel: "Year horizon: no long-range trend loaded.",
        lifeRangeLabel: "Life range: no longer-range shape loaded.",
        cognitiveLoadLabel: "Cognitive load: no pressure spikes visible.",
        physicalEnergyLabel: "Physical energy: no physical-energy pressure loaded.",
        transitionFrictionLabel: "Transition friction: no transition pressure loaded.",
        freeTimeQualityLabel: "Free-time quality: not yet measured.",
        executionLanesLabel: "Execution lanes: no active lane pressure loaded.",
        goalLoadLabel: "Goal load: no goal-load detail loaded.",
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
            commitmentLoadLabel,
            monthRangeLabel,
            yearRangeLabel,
            lifeRangeLabel,
            cognitiveLoadLabel,
            physicalEnergyLabel,
            transitionFrictionLabel,
            freeTimeQualityLabel,
            executionLanesLabel,
            goalLoadLabel
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
        let shapes = [
            dayShape(weekDays: weekDays, calendarAwareness: calendarAwareness),
            weekShape(
                weekDays: weekDays,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                calendarAwareness: calendarAwareness,
                mode: mode
            ),
            lifeShape(activeGoalCount: activeGoalCount, calendarAwareness: calendarAwareness)
        ]
        return TimeLifeSuiteState(
            title: "Shape Time",
            subtitle: "Open time, goal time, protected time, pressure, source state, and manual fallback stay inspectable.",
            shapes: shapes,
            field: lifeShapeField(
                shapes: shapes,
                weekDays: weekDays,
                calendarAwareness: calendarAwareness,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                mode: mode
            ),
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

    private func lifeShapeField(
        shapes: [TimeLifeSuiteShapeState],
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        activeGoalCount: Int,
        mode: TimeDashboardMode
    ) -> LifeShapeFieldState {
        let day = shapes.first { $0.kind == .day }
        let week = shapes.first { $0.kind == .week }
        let life = shapes.first { $0.kind == .life }
        let pressuredDays = weekDays.filter { [.tight, .fragile, .overloaded].contains($0.level) }.count
        let openDays = weekDays.filter { $0.level == .open }.count
        let protectedBlocks = weekDays.flatMap(\.blocks).filter { $0.kind == .protected || $0.kind == .fixed }.count
        let totalBlocks = max(weekDays.flatMap(\.blocks).count, 1)
        let capacityFit: LifeShapeCapacityFit
        if mode == .empty {
            capacityFit = .open
        } else if pressuredDays >= 3 {
            capacityFit = .overloaded
        } else if pressuredDays > 0 || openCaptureCount > 0 {
            capacityFit = .tight
        } else {
            capacityFit = .steady
        }

        let sourceTitle = calendarAwareness.canRequestCalendarRead ? "Calendar optional" : "Manual Time source"
        let sourceDetail = calendarAwareness.canRequestCalendarRead
            ? "Calendar can inform availability, but Time does not become an event grid."
            : "Time is shaped from local goals, captures, and manual defaults."
        let renderState = lifeShapeRenderState(
            capacityFit: capacityFit,
            calendarAwareness: calendarAwareness,
            openCaptureCount: openCaptureCount,
            protectedBlocks: protectedBlocks,
            mode: mode
        )

        return LifeShapeFieldState(
            defaultHorizon: .week,
            capacityFit: capacityFit,
            segments: [
                LifeShapeSegment(
                    kind: .openTime,
                    detail: openDays == 1 ? "1 day still has room." : "\(openDays) days still have room.",
                    valueLabel: openDays == 1 ? "1 open day" : "\(openDays) open days",
                    weight: Double(openDays) / Double(max(weekDays.count, 1)),
                    visualState: openDays > 0 ? .selected : .default
                ),
                LifeShapeSegment(
                    kind: .goalTime,
                    detail: activeGoalCount == 0 ? "No active goal is asking for Time yet." : "\(activeGoalCount) active goal\(activeGoalCount == 1 ? "" : "s") shape this field.",
                    valueLabel: activeGoalCount == 1 ? "1 goal" : "\(activeGoalCount) goals",
                    weight: min(Double(activeGoalCount) / 5.0, 1),
                    visualState: activeGoalCount == 0 ? .default : .selected
                ),
                LifeShapeSegment(
                    kind: .protectedTime,
                    detail: protectedBlocks == 0 ? "No protected pocket is marked yet." : "\(protectedBlocks) fixed or protected block\(protectedBlocks == 1 ? "" : "s") stay visible.",
                    valueLabel: protectedBlocks == 1 ? "1 protected" : "\(protectedBlocks) protected",
                    weight: Double(protectedBlocks) / Double(totalBlocks),
                    visualState: protectedBlocks > 0 ? .selected : .default
                ),
                LifeShapeSegment(
                    kind: .pressure,
                    detail: pressuredDays == 0 ? "No pressured day is asking for relief." : "\(pressuredDays) pressured day\(pressuredDays == 1 ? "" : "s") need review before adding more.",
                    valueLabel: capacityFit.title,
                    weight: capacityFit == .overloaded ? 0.92 : (capacityFit == .tight ? 0.72 : 0.38),
                    visualState: capacityFit.visualState
                ),
                LifeShapeSegment(
                    kind: .recovery,
                    detail: pressuredDays == 0 ? "Recovery stays available as margin." : "Lighten the loudest pressure before widening the week.",
                    valueLabel: "Recovery",
                    weight: pressuredDays == 0 ? 0.28 : 0.60,
                    visualState: pressuredDays == 0 ? .default : .warning
                ),
                LifeShapeSegment(
                    kind: .source,
                    detail: sourceDetail,
                    valueLabel: "Local",
                    weight: 0.34,
                    visualState: .selected
                )
            ],
            semanticMarks: semanticMarks(
                weekDays: weekDays,
                calendarAwareness: calendarAwareness,
                openCaptureCount: openCaptureCount,
                activeGoalCount: activeGoalCount,
                pressuredDays: pressuredDays,
                openDays: openDays,
                protectedBlocks: protectedBlocks,
                capacityFit: capacityFit,
                renderState: renderState
            ),
            renderState: renderState,
            readings: [
                .day: LifeShapeReading(
                    horizon: .day,
                    title: "Day shape",
                    summary: day?.summary ?? "Manual shaping is available for today.",
                    capacityStatement: day?.capacityLabel ?? "Capacity: qualitative only.",
                    sourceDetail: day?.provenanceLabel ?? sourceDetail
                ),
                .week: LifeShapeReading(
                    horizon: .week,
                    title: "Week shape",
                    summary: week?.summary ?? "The week has room until local goals or captures change it.",
                    capacityStatement: week?.capacityLabel ?? "Capacity: qualitative only.",
                    sourceDetail: week?.provenanceLabel ?? sourceDetail
                ),
                .month: LifeShapeReading(
                    horizon: .month,
                    title: "Month shape",
                    summary: life?.summary ?? "The longer Time arc is quiet until active goals shape it.",
                    capacityStatement: life?.capacityLabel ?? "Capacity: qualitative only.",
                    sourceDetail: life?.provenanceLabel ?? sourceDetail
                )
            ],
            sourceState: LifeShapeSourceState(
                title: sourceTitle,
                detail: sourceDetail,
                whyThisLabel: "Why this? Based on local goals, captures, protected time, pressure, and manual fallback.",
                privacyLabel: calendarAwareness.canRequestCalendarRead
                    ? "Calendar access stays optional and local."
                    : "No external calendar source is required.",
                visualState: calendarAwareness.canRequestCalendarRead ? .selected : .default
            ),
            reflowProposal: LifeShapeReflowProposal(
                title: capacityFit == .tight || capacityFit == .overloaded ? "Review pressure before adding more" : "Keep the week shaped around what matters",
                detail: openCaptureCount == 0
                    ? "No unplaced capture is forcing a Time change."
                    : "\(openCaptureCount) capture\(openCaptureCount == 1 ? "" : "s") need placement before Time changes.",
                actionTitle: "Review shape",
                visualState: capacityFit.visualState
            ),
            receipt: LifeShapeReceipt(
                title: "No silent calendar changes",
                detail: "Time changes require confirmation and leave a receipt.",
                ageLabel: "Current",
                visualState: .selected
            ),
            continuityDockItems: ["Open field", "Protect pocket", "Review receipt"]
        )
    }

    private func lifeShapeRenderState(
        capacityFit: LifeShapeCapacityFit,
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        protectedBlocks: Int,
        mode: TimeDashboardMode
    ) -> LifeShapeRenderState {
        if calendarAwareness.status == .denied {
            return .calendarDenied
        }
        if calendarAwareness.canRequestCalendarRead == false {
            return .manualOnly
        }
        if capacityFit == .overloaded || capacityFit == .tight {
            return .pressureCluster
        }
        if openCaptureCount > 0 && protectedBlocks == 0 {
            return .sourceConflict
        }
        if openCaptureCount > 0 {
            return .reflowPreview
        }
        if mode != .empty {
            return .receiptAttached
        }
        return .defaultWeek
    }

    private func semanticMarks(
        weekDays: [TimeElasticWeekDayState],
        calendarAwareness: TimeCalendarAwarenessState,
        openCaptureCount: Int,
        activeGoalCount: Int,
        pressuredDays: Int,
        openDays: Int,
        protectedBlocks: Int,
        capacityFit: LifeShapeCapacityFit,
        renderState: LifeShapeRenderState
    ) -> [LifeShapeSemanticMark] {
        let dayCount = max(weekDays.count, 1)
        let pressureIntensity = max(Double(pressuredDays) / Double(dayCount), capacityFit == .tight ? 0.64 : 0.20)
        let transitionFriction = min(max(Double(pressuredDays - openDays) / Double(dayCount), 0), 1)
        let goalLoad = min(Double(activeGoalCount) / 5.0, 1)
        let recoveryNeed = max(pressureIntensity, transitionFriction)
        let freeTimeQuality = min(Double(openDays) / Double(dayCount), 1)
        let executionLaneIntensity = max(freeTimeQuality, openCaptureCount > 0 ? 0.42 : 0.30)
        let protectedIntensity = min(Double(protectedBlocks) / Double(max(weekDays.flatMap(\.blocks).count, 1)), 1)
        let sourceConflictActive = renderState == .sourceConflict || calendarAwareness.status == .denied
        let receiptActive = renderState == .receiptAttached || renderState == .reflowPreview

        var marks = [
            LifeShapeSemanticMark(kind: .pressure, valueLabel: capacityFit.title, detail: "Pressure is a compression ridge with inspectable meaning.", intensity: pressureIntensity, visualState: capacityFit.visualState),
            LifeShapeSemanticMark(kind: .cognitiveLoad, valueLabel: pressuredDays == 0 ? "Light" : "Review", detail: "Cognitive load follows pressured days and remains text-labeled.", intensity: pressureIntensity * 0.78, visualState: pressuredDays == 0 ? .default : .warning),
            LifeShapeSemanticMark(kind: .physicalEnergy, valueLabel: recoveryNeed > 0.55 ? "Reserve" : "Steady", detail: "Physical energy appears as a reserve basin when recovery is needed.", intensity: recoveryNeed * 0.62, visualState: recoveryNeed > 0.55 ? .warning : .default),
            LifeShapeSemanticMark(kind: .transitionFriction, valueLabel: transitionFriction > 0.35 ? "Narrow" : "Smooth", detail: "Transition friction is a narrowed bridge when pressure exceeds open lanes.", intensity: transitionFriction, visualState: transitionFriction > 0.35 ? .warning : .default),
            LifeShapeSemanticMark(kind: .protectedTime, valueLabel: protectedBlocks == 0 ? "None" : "\(protectedBlocks) held", detail: "Protected time is a preserved boundary/pocket.", intensity: protectedIntensity, visualState: protectedBlocks == 0 ? .default : .selected),
            LifeShapeSemanticMark(kind: .recoveryNeed, valueLabel: recoveryNeed > 0.55 ? "Needed" : "Reserve", detail: "Recovery need is a reserve pocket, never a failure.", intensity: recoveryNeed, visualState: recoveryNeed > 0.55 ? .warning : .default),
            LifeShapeSemanticMark(kind: .freeTimeQuality, valueLabel: openDays == 0 ? "Thin" : "\(openDays) open", detail: "Free-time quality is an available lane/basin.", intensity: freeTimeQuality, visualState: openDays == 0 ? .warning : .selected),
            LifeShapeSemanticMark(kind: .executionLanes, valueLabel: openDays == 0 ? "Review" : "Open", detail: "Execution lanes show where action can fit.", intensity: executionLaneIntensity, visualState: openDays == 0 ? .warning : .selected),
            LifeShapeSemanticMark(kind: .goalLoad, valueLabel: activeGoalCount == 0 ? "No anchors" : "\(activeGoalCount) anchors", detail: "Goal load is an anchored lane.", intensity: goalLoad, visualState: activeGoalCount == 0 ? .default : .selected)
        ]

        marks.append(
            LifeShapeSemanticMark(kind: .sourceConflict, valueLabel: sourceConflictActive ? "Split trace" : "Clear", detail: "Source conflict uses a split trace/unresolved overlap.", intensity: sourceConflictActive ? 0.82 : 0.18, visualState: sourceConflictActive ? .warning : .default)
        )
        marks.append(
            LifeShapeSemanticMark(kind: .receiptReflow, valueLabel: receiptActive ? "Attached" : "Ready", detail: "Receipt/reflow appears as a proof mark attached to changed regions.", intensity: receiptActive ? 0.70 : 0.24, visualState: receiptActive ? .selected : .default)
        )
        return marks
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
            ? "Milestones: no active milestone needs a wider lane yet."
            : "Milestones: \(milestoneTitles.joined(separator: ", ")) shape the longer arc."

        return TimeLifeShapeDrillDownState(
            title: "LifeShape Field detail",
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
                ? "Free-time bands: create one smaller pocket before widening the shape."
                : "Free-time bands: \(openDays) open day\((openDays == 1) ? "" : "s") can protect recovery.",
            recoverySpaceLabel: openDays > 0
                ? "Recovery space: protect open room before filling it."
                : "Recovery space: reduce the ask before the next commitment.",
            commitmentLoadLabel: allBlocks.isEmpty
                ? "Commitment load: no visible commitments are crowding the shape."
                : "Commitment load: \(allBlocks.count) visible block\((allBlocks.count == 1) ? "" : "s") across active planning.",
            monthRangeLabel: activeGoalCount == 0
                ? "Month horizon: no active plan horizon loaded yet."
                : "Month horizon: active commitments remain within the month-level shape.",
            yearRangeLabel: activeGoalCount == 0
                ? "Year horizon: no long-range pressure signal is active yet."
                : "Year horizon: longer-view lanes are visible and still editable by local confirmation.",
            lifeRangeLabel: openCaptureCount == 0
                ? "Life range: open capacity is currently broad."
                : "Life range: \(openCaptureCount) capture\((openCaptureCount == 1) ? "" : "s") still needs placement.",
            cognitiveLoadLabel: isNoOpen
                ? "Cognitive load: high visual density suggests review-first."
                : "Cognitive load: stable enough for one-lane shaping.",
            physicalEnergyLabel: openCaptureCount > 0
                ? "Physical energy: keep protected time before adding more capacity."
                : "Physical energy: no immediate overload from visible commitments.",
            transitionFrictionLabel: transitionFriction > 0
                ? "Transition friction: \(transitionFriction) transition point\((transitionFriction == 1) ? "" : "s") need smoothing before expansion."
                : "Transition friction: transitions are manageable for now.",
            freeTimeQualityLabel: fixedProtectedBlocks > flexibleBlocks
                ? "Free-time quality: protected time is helping recovery."
                : "Free-time quality: watch quality drift before opening bigger plans.",
            executionLanesLabel: allBlocks.isEmpty
                ? "Execution lanes: none currently active in this LifeShape slice."
                : "Execution lanes: \(allBlocks.count) lane\((allBlocks.count == 1) ? "" : "s") stay reviewable before mutation.",
            goalLoadLabel: activeGoalCount == 0
                ? "Goal load: no active goals to stretch this shape."
                : "Goal load: \(activeGoalCount) active goal\((activeGoalCount == 1) ? "" : "s") shape the life-range contour.",
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
                    detail: "Protect recovery pockets before extending capacity.",
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
                    id: "execution-lanes",
                    title: "Execution lanes",
                    value: weekDays.count == 0 ? "None" : "\(weekDays.count) lanes",
                    detail: "Execution lanes are reviewed before any schedule mutation.",
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
