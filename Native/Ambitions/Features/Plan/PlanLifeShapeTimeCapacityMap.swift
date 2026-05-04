import AmbitionsDesignSystem
import SwiftUI

struct PlanLifeShapeMapItem: Identifiable, Sendable, Hashable {
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
    let recoveryLabel: String
    let symbolName: String
    let accessibilityIdentifier: String

    init(shape: PlanLifeSuiteShapeState) {
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
        self.recoveryLabel = Self.recoveryLabel(for: shape)
        self.symbolName = Self.symbolName(for: shape.kind)
        self.accessibilityIdentifier = "plan.life-shape-map.\(shape.kind.rawValue)"
    }

    var accessibilityLabel: String {
        [title, capacityLabel, summary, recoveryLabel]
            .filter { $0.isEmpty == false }
            .joined(separator: ". ")
    }

    var accessibilityHint: String {
        "Selects this LifeShape band without changing the plan or calendar."
    }

    private static func pressureLevel(for shape: PlanLifeSuiteShapeState) -> Double {
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

    private static func capacityLabel(for shape: PlanLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return shape.visualState == .warning ? "Tight day" : "Day can hold"
        case .week:
            return shape.visualState == .warning ? "Pressure visible" : "Week has room"
        case .life:
            return shape.visualState == .warning ? "Life load needs review" : "Life direction visible"
        }
    }

    private static func recoveryLabel(for shape: PlanLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Recovery: protect the clearest pocket."
        case .week:
            return "Recovery: lighten the loudest pressure first."
        case .life:
            return "Recovery: keep the plan pointed at active goals."
        }
    }

    private static func symbolName(for kind: PlanLifeSuiteShapeKind) -> String {
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

struct PlanLifeShapeTimeCapacityMap: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedItemID: PlanLifeShapeMapItem.ID?
    @State private var revealsPressure = false

    let suite: PlanLifeSuiteState

    private var items: [PlanLifeShapeMapItem] {
        suite.shapes.map(PlanLifeShapeMapItem.init(shape:))
    }

    private var selectedItem: PlanLifeShapeMapItem? {
        items.first { $0.id == selectedItemID } ?? items.first
    }

    var body: some View {
        StateDrivenMaterialPanel(context: .plan, state: .active) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                header

                if dynamicTypeSize.isAccessibilitySize {
                    accessibilityBandStack
                } else {
                    visualBandMap
                }

                if let selectedItem {
                    PlanLifeShapeSelectedBandPanel(item: selectedItem, revealsPressure: revealsPressure)
                }

                QuietActionButton(
                    revealsPressure ? "Hide pressure" : "Reveal pressure",
                    icon: revealsPressure ? "eye.slash" : "waveform.path"
                ) {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        revealsPressure.toggle()
                    }
                }
                .accessibilityIdentifier("plan.life-shape-map.pressure-toggle")

                EvidenceLabel(
                    "Shape before schedule",
                    detail: suite.subtitle,
                    source: suite.manualFallbackLabel,
                    state: .active,
                    context: .plan
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("plan.life-shape-map")
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("LifeShape Time Capacity Map")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Capacity, pressure, and recovery markers without a calendar grid.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            AmbitionChip(suite.calendarBoundaryLabel, role: .time, semanticState: .calendarDerived)
        }
    }

    private var visualBandMap: some View {
        HStack(alignment: .bottom, spacing: theme.spacing.sm) {
            ForEach(items) { item in
                PlanLifeShapeBandButton(
                    item: item,
                    isSelected: selectedItem?.id == item.id,
                    revealsPressure: revealsPressure,
                    reduceMotion: reduceMotion,
                    onSelect: { select(item) }
                )
            }
        }
        .frame(minHeight: 188, alignment: .bottom)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("LifeShape Time Capacity Map")
    }

    private var accessibilityBandStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(items) { item in
                PlanLifeShapeBandButton(
                    item: item,
                    isSelected: selectedItem?.id == item.id,
                    revealsPressure: revealsPressure,
                    reduceMotion: reduceMotion,
                    onSelect: { select(item) }
                )
                .frame(minHeight: 96)
            }
        }
    }

    private func select(_ item: PlanLifeShapeMapItem) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            selectedItemID = item.id
        }
    }
}

private struct PlanLifeShapeBandButton: View {
    @Environment(\.ambitionTheme) private var theme

    let item: PlanLifeShapeMapItem
    let isSelected: Bool
    let revealsPressure: Bool
    let reduceMotion: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            content
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(item.accessibilityLabel)
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(item.accessibilityHint)
        .accessibilityIdentifier(item.accessibilityIdentifier)
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            bandHeader

            Spacer(minLength: theme.spacing.xs)

            bandStack

            Text(item.capacityLabel)
                .font(theme.typography.micro)
                .foregroundStyle(accent)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 174, alignment: .bottomLeading)
        .padding(theme.spacing.sm)
        .background {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceOverlay)
        }
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(strokeColor, lineWidth: isSelected ? 1.5 : 1)
        }
    }

    private var bandHeader: some View {
        HStack(spacing: theme.spacing.xs) {
            Image(systemName: item.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(accent)
                .accessibilityHidden(true)
            Text(item.title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
        }
    }

    private var bandStack: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(accent.opacity(isSelected ? 0.24 : 0.13))
                .frame(height: 120)

            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(accent.opacity(revealsPressure ? 0.86 : 0.58))
                .frame(height: pressureHeight)
                .overlay(alignment: .topTrailing) {
                    pressureMarker
                }
        }
    }

    @ViewBuilder
    private var pressureMarker: some View {
        if revealsPressure {
            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(theme.colors.textInverse)
                .padding(6)
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                .accessibilityHidden(true)
        }
    }

    private var accent: Color {
        theme.stateStyle(for: isSelected ? .pressed : item.visualState).accent
    }

    private var strokeColor: Color {
        theme.stateStyle(for: isSelected ? .pressed : item.visualState).stroke
            .opacity(isSelected ? 0.82 : 0.45)
    }

    private var pressureHeight: CGFloat {
        34 + CGFloat(item.pressureLevel * 82)
    }
}

private struct PlanLifeShapeSelectedBandPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let item: PlanLifeShapeMapItem
    let revealsPressure: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(item.question)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
            Text(revealsPressure ? item.recoveryLabel : item.summary)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: theme.spacing.xs) {
                TagPill(item.sourceLabel, icon: "scope", state: .default)
                TagPill(item.boundaryLabel, icon: "hand.raised", state: item.visualState)
            }
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.stateStyle(for: item.visualState).accent.opacity(0.08))
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("plan.life-shape-map.selected-band")
    }
}

#Preview("SI08 LifeShape Map") {
    PlanLifeShapeTimeCapacityMap(
        suite: PlanLifeSuiteState(
            title: "Plan Life Suite",
            subtitle: "Does this hold together?",
            shapes: [
                PlanLifeSuiteShapeState(kind: .day, title: "Day Shape", question: "What can this day honestly hold?", summary: "Today has a protected pocket and one planned block.", facts: ["Protected pocket visible."], sourceLabel: "Based on your plan", boundaryLabel: "No silent replanning", visualState: .selected),
                PlanLifeSuiteShapeState(kind: .week, title: "Week Shape", question: "Does the week still fit?", summary: "Two days may need lighter scope before the week feels believable.", facts: ["2 pressured days visible."], sourceLabel: "Based on goals and captures", boundaryLabel: "Confirm first", visualState: .warning),
                PlanLifeSuiteShapeState(kind: .life, title: "Life Shape", question: "Is the plan pointed at the life you are building?", summary: "Three active goals shape the current life plan.", facts: ["3 active goals included."], sourceLabel: "Based on active goals", boundaryLabel: "Broader than time slots", visualState: .default),
            ],
            calendarBoundaryLabel: "Calendar stays optional",
            manualFallbackLabel: "Manual fallback available",
            trustLabel: "No silent calendar changes"
        )
    )
    .padding()
}
