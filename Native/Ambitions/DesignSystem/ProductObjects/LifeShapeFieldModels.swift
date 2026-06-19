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
    let capacityContourLabel: String
    let protectedPocketLabel: String
    let pressureFieldLabel: String
    let recoveryPocketLabel: String
    let milestoneRidgeLabel: String
    let commitmentLoadContourLabel: String
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
        self.capacityContourLabel = "Capacity contour: \(Self.capacityLabel(for: shape))."
        self.protectedPocketLabel = Self.protectedPocketLabel(for: shape)
        self.pressureFieldLabel = Self.pressureFieldLabel(for: shape)
        self.recoveryPocketLabel = Self.recoveryPocketLabel(for: shape)
        self.milestoneRidgeLabel = Self.milestoneRidgeLabel(for: shape)
        self.commitmentLoadContourLabel = Self.commitmentLoadContourLabel(for: shape)
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
            capacityContourLabel,
            protectedPocketLabel,
            pressureFieldLabel,
            recoveryPocketLabel,
            milestoneRidgeLabel,
            commitmentLoadContourLabel,
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
            "Free capacity: \(capacityContourLabel)",
            "Protected time: \(protectedPocketLabel)",
            "Pressure: \(pressureFieldLabel)",
            "Milestones: \(milestoneRidgeLabel)",
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
        "Selects this LifeShape Field contour without changing Time or calendar."
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
            return "Recovery: protect the clearest pocket."
        case .week:
            return "Recovery: lighten the loudest pressure first."
        case .life:
            return "Recovery: keep Time pointed at active goals."
        }
    }

    static func protectedPocketLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Protected pocket: keep the clearest opening guarded."
        case .week:
            return "Protected pocket: reserve one lighter lane before adding more."
        case .life:
            return "Protected pocket: keep direction wider than today's slots."
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

    static func recoveryPocketLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Recovery pocket: space before the next ask."
        case .week:
            return "Recovery pocket: lighten one pressured day first."
        case .life:
            return "Recovery pocket: preserve room for the next season."
        }
    }

    static func milestoneRidgeLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Milestone ridge: today's clearest Time edge."
        case .week:
            return "Milestone ridge: the week bends around active goals."
        case .life:
            return "Milestone ridge: active goals anchor the longer arc."
        }
    }

    static func commitmentLoadContourLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.visualState {
        case .warning:
            return "Commitment load contour: tight, qualitative only."
        case .disabled:
            return "Commitment load contour: unavailable."
        default:
            return "Commitment load contour: reviewable, not measured as a number."
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

