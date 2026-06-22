import AmbitionsDesignSystem
import Foundation

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
        let pressureKind = fit == .tight ? PressureKind.tight : .light
        return LifeShapeFieldState(
            defaultHorizon: .week,
            capacityFit: fit,
            segments: [
                LifeShapeSegment(kind: .openTime, detail: day?.summary ?? "Manual shaping available.", valueLabel: day?.capacityLabel ?? "Manual", weight: 0.44, visualState: day?.visualState ?? .default),
                LifeShapeSegment(kind: .goalTime, detail: life?.summary ?? "Goal load not loaded.", valueLabel: life?.sourceLabel ?? "Goals", weight: 0.50, visualState: life?.visualState ?? .default),
                LifeShapeSegment(kind: .protectedTime, detail: day?.protectedTimeLabel ?? "Protected time is inspectable.", valueLabel: "Protected", weight: 0.38, visualState: .selected),
                LifeShapeSegment(kind: .pressure, detail: week?.schedulePressureLabel ?? "Capacity has room before another Step is added.", valueLabel: pressureKind.title, weight: fit == .tight ? 0.78 : 0.44, visualState: fit.visualState),
                LifeShapeSegment(kind: .recovery, detail: "Recovery stays available without shame.", valueLabel: "Recovery", weight: 0.34, visualState: .default),
                LifeShapeSegment(kind: .source, detail: trustLabel, valueLabel: "Local", weight: 0.30, visualState: .selected)
            ],
            semanticMarks: Self.fallbackSemanticMarks(fit: fit, pressureKind: pressureKind),
            renderState: .defaultWeek,
            readings: [
                .day: LifeShapeReading(horizon: .day, title: day?.title ?? "Day shape", summary: day?.summary ?? "Manual shaping available.", capacityStatement: day?.capacityLabel ?? "Capacity is qualitative.", sourceDetail: day?.provenanceLabel ?? manualFallbackLabel),
                .week: LifeShapeReading(horizon: .week, title: week?.title ?? "Week shape", summary: week?.summary ?? "Week shape is local and qualitative.", capacityStatement: week?.capacityLabel ?? "Capacity is qualitative.", sourceDetail: week?.provenanceLabel ?? manualFallbackLabel),
                .month: LifeShapeReading(horizon: .month, title: "Month shape", summary: life?.summary ?? "Longer-range Time shape is quiet.", capacityStatement: life?.capacityLabel ?? "Longer-range capacity is qualitative.", sourceDetail: life?.provenanceLabel ?? manualFallbackLabel),
                .year: LifeShapeReading(horizon: .year, title: "Year shape", summary: life?.summary ?? "Year shape stays directional until active goals create a longer arc.", capacityStatement: life?.capacityLabel ?? "Year capacity remains qualitative.", sourceDetail: life?.provenanceLabel ?? manualFallbackLabel)
            ],
            sourceState: LifeShapeSourceState(title: calendarBoundaryLabel, detail: manualFallbackLabel, whyThisLabel: trustLabel, privacyLabel: "Local Time state; no silent calendar write.", visualState: .selected),
            reflowProposal: LifeShapeReflowProposal(title: "Review stays optional", detail: "Time can suggest relief only after capacity is clear.", actionTitle: "Review shape", visualState: fit.visualState),
            receipt: LifeShapeReceipt(title: "Changes stay reviewable", detail: trustLabel, ageLabel: "Current", visualState: .selected),
            continuityDockItems: ["Open field", "Protect pocket", "Review receipt"]
        )
    }

    private static func fallbackSemanticMarks(fit: LifeShapeCapacityFit, pressureKind: PressureKind) -> [LifeShapeSemanticMark] {
        let localInput = LifeShapeInputRef(
            id: "time.baseline.local-field",
            kind: .localDefault,
            label: "Local Time baseline field"
        )
        func mark(
            kind: LifeShapeSemanticMarkKind,
            valueLabel: String,
            detail: String,
            intensity: Double,
            visualState: AmbitionVisualState
        ) -> LifeShapeSemanticMark {
            LifeShapeSemanticMark(
                kind: kind,
                valueLabel: valueLabel,
                detail: detail,
                intensity: intensity,
                visualState: visualState,
                inputRefs: [localInput],
                ruleIDs: [LifeShapeRuleID(rawValue: "lifeshape.baseline.\(kind.rawValue)")],
                accessibilitySummary: "\(kind.title). \(kind.semanticMeaning). \(valueLabel). \(detail)"
            )
        }

        return [
            mark(kind: .pressure, valueLabel: pressureKind.title, detail: "Pressure is qualitative and text-labeled.", intensity: fit == .tight ? 0.70 : 0.34, visualState: fit.visualState),
            mark(kind: .cognitiveLoad, valueLabel: "Reviewable", detail: "Mental load stays visible as text and mark.", intensity: 0.42, visualState: .default),
            mark(kind: .physicalEnergy, valueLabel: "Unloaded", detail: "Energy state is quiet until local context changes.", intensity: 0.30, visualState: .default),
            mark(kind: .transitionFriction, valueLabel: "Smooth", detail: "No narrowed bridge is active.", intensity: 0.26, visualState: .default),
            mark(kind: .protectedTime, valueLabel: "Protected", detail: "Protected time uses a preserved boundary.", intensity: 0.38, visualState: .selected),
            mark(kind: .recoveryNeed, valueLabel: "Reserve", detail: "Recovery need is a reserve pocket.", intensity: 0.34, visualState: .default),
            mark(kind: .freeTimeQuality, valueLabel: "Available", detail: "Free-time quality appears as lane quality.", intensity: 0.52, visualState: .selected),
            mark(kind: .executionLanes, valueLabel: "Open lanes", detail: "Execution lanes show where action can fit.", intensity: 0.48, visualState: .selected),
            mark(kind: .goalLoad, valueLabel: "Anchored", detail: "Goal load is an anchored lane.", intensity: 0.44, visualState: .selected)
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
