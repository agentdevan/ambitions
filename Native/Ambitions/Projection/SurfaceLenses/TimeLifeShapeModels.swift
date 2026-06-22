import AmbitionsDesignSystem
import Foundation

enum TimeLifeSuiteShapeKind: String, Sendable, CaseIterable {
    case day = "day_shape"
    case week = "week_shape"
    case life = "life_shape"
}

typealias TimeHorizon = LifeShapeHorizon

enum LifeShapeSegmentKind: String, Sendable {
    case openTime
    case goalTime
    case protectedTime
    case pressure
    case buffer
    case recovery
    case source

    var title: String {
        switch self {
        case .openTime: "Open time"
        case .goalTime: "Goal time"
        case .protectedTime: "Protected time"
        case .pressure: "Pressure"
        case .buffer: "Buffer"
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
        case .buffer: "rectangle.compress.vertical"
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
        case .reflowPreview: "Preview changes"
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
        case .receiptReflow: "Receipt/review"
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
    let inputRefs: [LifeShapeInputRef]
    let ruleIDs: [LifeShapeRuleID]
    let accessibilitySummary: String

    init(
        kind: LifeShapeSemanticMarkKind,
        valueLabel: String,
        detail: String,
        intensity: Double,
        visualState: AmbitionVisualState,
        inputRefs: [LifeShapeInputRef],
        ruleIDs: [LifeShapeRuleID],
        accessibilitySummary: String
    ) {
        self.id = kind.rawValue
        self.kind = kind
        self.valueLabel = valueLabel
        self.detail = detail
        self.intensity = min(max(intensity, 0), 1)
        self.visualState = visualState
        self.inputRefs = inputRefs
        self.ruleIDs = ruleIDs
        self.accessibilitySummary = accessibilitySummary
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
