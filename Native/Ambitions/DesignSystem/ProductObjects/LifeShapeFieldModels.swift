import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeFieldItem: Identifiable, Sendable, Hashable {
    let id: String
    let title: String
    let question: String
    let summary: String
    let facts: [String]
    let sourceLabel: String
    let boundaryLabel: String
    let visualState: AmbitionVisualState
    let pressureLevel: Double
    let capacityLabel: String
    let capacityShapeLabel: String
    let protectedTimeLabel: String
    let pressureFieldLabel: String
    let recoveryRoomLabel: String
    let milestoneAnchorLabel: String
    let commitmentLoadLabel: String
    let schedulePressureLabel: String
    let proofOpportunityLabel: String
    let provenanceLabel: String
    let privacyLabel: String
    let recoveryLabel: String
    let symbolName: String
    let accessibilityIdentifier: String

    init(shape: TimeLifeSuiteShapeState) {
        self.id = shape.id
        self.title = shape.title
        self.question = shape.question
        self.summary = shape.summary
        self.facts = shape.facts
        self.sourceLabel = shape.sourceLabel
        self.boundaryLabel = shape.boundaryLabel
        self.visualState = shape.visualState
        self.pressureLevel = Self.pressureLevel(for: shape)
        self.capacityLabel = Self.capacityLabel(for: shape)
        self.capacityShapeLabel = "Capacity: \(Self.capacityLabel(for: shape))."
        self.protectedTimeLabel = Self.protectedTimeLabel(for: shape)
        self.pressureFieldLabel = Self.pressureFieldLabel(for: shape)
        self.recoveryRoomLabel = Self.recoveryRoomLabel(for: shape)
        self.milestoneAnchorLabel = Self.milestoneAnchorLabel(for: shape)
        self.commitmentLoadLabel = Self.commitmentLoadLabel(for: shape)
        self.schedulePressureLabel = shape.schedulePressureLabel
        self.proofOpportunityLabel = shape.proofOpportunityLabel
        self.provenanceLabel = shape.provenanceLabel
        self.privacyLabel = shape.privacyLabel
        self.recoveryLabel = Self.recoveryLabel(for: shape)
        self.symbolName = Self.symbolName(for: shape.kind)
        self.accessibilityIdentifier = "time.life-shape-field.\(shape.kind.rawValue)"
    }

    var accessibilityLabel: String {
        [
            title,
            capacityShapeLabel,
            protectedTimeLabel,
            pressureFieldLabel,
            recoveryRoomLabel,
            milestoneAnchorLabel,
            commitmentLoadLabel,
            schedulePressureLabel,
            proofOpportunityLabel,
            provenanceLabel,
            privacyLabel,
            summary,
            recoveryLabel
        ]
            .filter { $0.isEmpty == false }
            .joined(separator: ". ")
    }

    var lifeShapeInspectionSummary: String {
        [
            "Schedule reality: \(summary)",
            "Free capacity: \(capacityShapeLabel)",
            "Protected time: \(protectedTimeLabel)",
            "Pressure: \(pressureFieldLabel)",
            "Milestones: \(milestoneAnchorLabel)",
            "Schedule pressure: \(schedulePressureLabel)",
            "Proof opportunity: \(proofOpportunityLabel)",
            "Provenance: \(provenanceLabel)",
            "Privacy: \(privacyLabel)",
            "Life-area shape: \(sourceLabel)"
        ].joined(separator: " · ")
    }

    var compactInspectionSummary: String {
        "Schedule reality, free capacity, protected time, pressure, proof opportunity, provenance, privacy, and life-area shape stay inspectable without becoming a calendar grid."
    }

    var accessibilityHint: String {
        "Selects this LifeShape Field shape without changing Time or calendar."
    }

    static func pressureLevel(for shape: TimeLifeSuiteShapeState) -> Double {
        switch (shape.kind, shape.visualState) {
        case (.week, .warning):
            return 0.84
        case (.day, .warning):
            return 0.68
        case (.life, .warning):
            return 0.56
        case (.week, _):
            return 0.48
        case (.day, _):
            return 0.40
        case (.life, _):
            return 0.32
        }
    }

    static func capacityLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return shape.visualState == .warning ? "Tight day" : "Day can hold"
        case .week:
            return shape.visualState == .warning ? "Pressure visible" : "Week has room"
        case .life:
            return shape.visualState == .warning ? "Life load needs review" : "Life direction visible"
        }
    }

    static func recoveryLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Recovery: protect the clearest opening."
        case .week:
            return "Recovery: lighten the loudest pressure first."
        case .life:
            return "Recovery: keep Time pointed at active goals."
        }
    }

    static func protectedTimeLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Protected time: keep the clearest opening guarded."
        case .week:
            return "Protected time: reserve one lighter opening before adding more."
        case .life:
            return "Protected time: keep direction wider than today's slots."
        }
    }

    static func pressureFieldLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.visualState {
        case .warning:
            return "Pressure field: visible and asking for review."
        case .disabled:
            return "Pressure field: quiet because this shape is unavailable."
        default:
            return "Pressure field: present but not crowding the shape."
        }
    }

    static func recoveryRoomLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Recovery room: space before the next ask."
        case .week:
            return "Recovery room: lighten one pressured day first."
        case .life:
            return "Recovery room: preserve room for the next season."
        }
    }

    static func milestoneAnchorLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Milestone anchor: today's clearest Time edge."
        case .week:
            return "Milestone anchor: the week bends around active goals."
        case .life:
            return "Milestone anchor: active goals guide the longer arc."
        }
    }

    static func commitmentLoadLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.visualState {
        case .warning:
            return "Commitment load: tight, qualitative only."
        case .disabled:
            return "Commitment load: unavailable."
        default:
            return "Commitment load: reviewable, not measured as a number."
        }
    }

    static func symbolName(for kind: TimeLifeSuiteShapeKind) -> String {
        switch kind {
        case .day:
            return "sun.max"
        case .week:
            return "waveform.path.ecg.rectangle"
        case .life:
            return "point.3.connected.trianglepath.dotted"
        }
    }
}

enum TimeLifeShapeZoomLevel: String, CaseIterable {
    case field
    case day
    case week
    case month
    case year

    var title: String {
        switch self {
        case .field: "Field"
        case .day: "Day"
        case .week: "Week"
        case .month: "Month"
        case .year: "Year"
        }
    }
}
