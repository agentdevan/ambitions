import AmbitionsDesignSystem
import SwiftUI

struct TimeLifeShapeFieldItem: Identifiable, Sendable, Hashable {
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
            "Life-area shape: \(sourceLabel)"
        ].joined(separator: " · ")
    }

    var compactInspectionSummary: String {
        "Schedule reality, free capacity, protected time, pressure, milestones, and life-area shape stay inspectable without becoming a calendar grid."
    }

    var accessibilityHint: String {
        "Selects this LifeShape Field contour without changing Time or calendar."
    }

    private static func pressureLevel(for shape: TimeLifeSuiteShapeState) -> Double {
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

    private static func capacityLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return shape.visualState == .warning ? "Tight day" : "Day can hold"
        case .week:
            return shape.visualState == .warning ? "Pressure visible" : "Week has room"
        case .life:
            return shape.visualState == .warning ? "Life load needs review" : "Life direction visible"
        }
    }

    private static func recoveryLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Recovery: protect the clearest pocket."
        case .week:
            return "Recovery: lighten the loudest pressure first."
        case .life:
            return "Recovery: keep the plan pointed at active goals."
        }
    }

    private static func protectedPocketLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Protected pocket: keep the clearest opening guarded."
        case .week:
            return "Protected pocket: reserve one lighter lane before adding more."
        case .life:
            return "Protected pocket: keep direction wider than today's slots."
        }
    }

    private static func pressureFieldLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.visualState {
        case .warning:
            return "Pressure field: visible and asking for review."
        case .disabled:
            return "Pressure field: quiet because this shape is unavailable."
        default:
            return "Pressure field: present but not crowding the shape."
        }
    }

    private static func recoveryPocketLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Recovery pocket: space before the next ask."
        case .week:
            return "Recovery pocket: lighten one pressured day first."
        case .life:
            return "Recovery pocket: preserve room for the next season."
        }
    }

    private static func milestoneRidgeLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.kind {
        case .day:
            return "Milestone ridge: today's clearest plan edge."
        case .week:
            return "Milestone ridge: the week bends around active goals."
        case .life:
            return "Milestone ridge: active goals anchor the longer arc."
        }
    }

    private static func commitmentLoadContourLabel(for shape: TimeLifeSuiteShapeState) -> String {
        switch shape.visualState {
        case .warning:
            return "Commitment load contour: tight, qualitative only."
        case .disabled:
            return "Commitment load contour: unavailable."
        default:
            return "Commitment load contour: reviewable, not measured as a number."
        }
    }

    private static func symbolName(for kind: TimeLifeSuiteShapeKind) -> String {
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

struct TimeLifeShapeField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedItemID: TimeLifeShapeFieldItem.ID?
    @State private var revealsPressure = false

    let suite: TimeLifeSuiteState

    private var items: [TimeLifeShapeFieldItem] {
        suite.shapes.map(TimeLifeShapeFieldItem.init(shape:))
    }

    private var selectedItem: TimeLifeShapeFieldItem? {
        items.first { $0.id == selectedItemID } ?? items.first
    }

    var body: some View {
        StateDrivenMaterialPanel(context: .plan, state: .active) {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                header

                if dynamicTypeSize.isAccessibilitySize {
                    accessibilityContourStack
                } else {
                    visualContourField
                }

                if let selectedItem {
                    TimeLifeShapeSelectedContourPanel(item: selectedItem, revealsPressure: revealsPressure)
                }

                TimeLifeShapeDrillDownPanel(drillDown: suite.drillDown)

                QuietActionButton(
                    revealsPressure ? "Hide pressure" : "Reveal pressure",
                    icon: revealsPressure ? "eye.slash" : "waveform.path"
                ) {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        revealsPressure.toggle()
                    }
                }
                .accessibilityIdentifier("time.life-shape-field.pressure-toggle")

                EvidenceLabel(
                    "Shape Time",
                    detail: suite.subtitle,
                    source: suite.manualFallbackLabel,
                    state: .active,
                    context: .plan
                )
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("time.life-shape-field")
        .accessibilityValue(selectedItem?.lifeShapeInspectionSummary ?? suite.subtitle)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("LifeShape Field")
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Open time, goal time, protected time, and pressure without becoming an event grid.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            AmbitionChip(suite.calendarBoundaryLabel, role: .time, semanticState: .calendarDerived)
        }
    }

    private var visualContourField: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            ForEach(items) { item in
                TimeLifeShapeContourButton(
                    item: item,
                    isSelected: selectedItem?.id == item.id,
                    revealsPressure: revealsPressure,
                    reduceMotion: reduceMotion,
                    onSelect: { select(item) }
                )
            }
        }
        .frame(minHeight: 188, alignment: .center)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Time LifeShape Field")
    }

    private var accessibilityContourStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            ForEach(items) { item in
                TimeLifeShapeContourButton(
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

    private func select(_ item: TimeLifeShapeFieldItem) {
        withAnimation(reduceMotion ? nil : .easeOut(duration: 0.2)) {
            selectedItemID = item.id
        }
    }
}

private struct TimeLifeShapeContourButton: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TimeLifeShapeFieldItem
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
            contourHeader

            Spacer(minLength: theme.spacing.xs)

            contourField

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

    private var contourHeader: some View {
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

    private var contourField: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(accent.opacity(isSelected ? 0.24 : 0.14))
                .frame(height: 108)
                .scaleEffect(x: contourWidthScale, y: contourHeightScale, anchor: .center)

            Capsule(style: .continuous)
                .stroke(accent.opacity(0.55), lineWidth: isSelected ? 1.5 : 1)
                .frame(height: 108)
                .scaleEffect(x: contourWidthScale, y: contourHeightScale, anchor: .center)

            milestoneRidge

            if revealsPressure {
                pressureField
            }

            pocketRow
        }
        .frame(maxWidth: .infinity, minHeight: 128)
    }

    @ViewBuilder
    private var pressureField: some View {
        if revealsPressure {
            Circle()
                .fill(accent.opacity(0.42))
                .frame(width: pressureDiameter, height: pressureDiameter)
                .overlay {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(theme.colors.textInverse)
                        .accessibilityHidden(true)
                }
                .offset(x: 28, y: -8)
                .transition(reduceMotion ? .opacity : .scale.combined(with: .opacity))
                .accessibilityHidden(true)
        }
    }

    private var milestoneRidge: some View {
        Capsule(style: .continuous)
            .fill(accent.opacity(0.72))
            .frame(width: 72, height: 4)
            .rotationEffect(.degrees(item.pressureLevel > 0.6 ? -8 : 6))
            .offset(y: -36)
            .accessibilityHidden(true)
    }

    private var pocketRow: some View {
        HStack(spacing: theme.spacing.xxxs) {
            pocketLabel("Protected", icon: "lock")
            pocketLabel("Recovery", icon: "leaf")
        }
        .offset(y: 38)
    }

    private func pocketLabel(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(theme.typography.micro)
            .foregroundStyle(theme.colors.textPrimary)
            .lineLimit(1)
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(
                Capsule(style: .continuous)
                    .fill(theme.colors.surfaceSecondary.opacity(0.88))
            )
            .accessibilityHidden(true)
    }

    private var accent: Color {
        theme.stateStyle(for: isSelected ? .pressed : item.visualState).accent
    }

    private var strokeColor: Color {
        theme.stateStyle(for: isSelected ? .pressed : item.visualState).stroke
            .opacity(isSelected ? 0.82 : 0.45)
    }

    private var contourWidthScale: CGFloat {
        0.84 + CGFloat(item.pressureLevel * 0.14)
    }

    private var contourHeightScale: CGFloat {
        0.58 + CGFloat(item.pressureLevel * 0.30)
    }

    private var pressureDiameter: CGFloat {
        26 + CGFloat(item.pressureLevel * 28)
    }
}

private struct TimeLifeShapeSelectedContourPanel: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TimeLifeShapeFieldItem
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
            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text(item.capacityContourLabel)
                Text(item.protectedPocketLabel)
                Text(item.pressureFieldLabel)
                Text(item.recoveryPocketLabel)
                Text(item.milestoneRidgeLabel)
                Text(item.commitmentLoadContourLabel)
            }
            .font(theme.typography.micro)
            .foregroundStyle(theme.colors.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
            EvidenceLabel(
                "LifeShape meaning",
                detail: item.compactInspectionSummary,
                source: "Time capacity",
                state: item.livingVisualState,
                context: .plan
            )
            .accessibilityIdentifier("time.life-shape-field.inspection-summary")
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
        .accessibilityIdentifier("time.life-shape-field.selected-band")
    }
}

private extension TimeLifeShapeFieldItem {
    var livingVisualState: LivingVisualState {
        switch visualState {
        case .warning:
            return .pressured
        case .disabled:
            return .empty
        case .success:
            return .proof
        default:
            return .active
        }
    }
}

#Preview("AFI09 Time LifeShape Field") {
    TimeLifeShapeField(
        suite: TimeLifeSuiteState(
            title: "Shape Time",
            subtitle: "LifeShape Field shows what the week can hold.",
            shapes: [
                TimeLifeSuiteShapeState(kind: .day, title: "Day Shape", question: "What can this day honestly hold?", summary: "Today has a protected pocket and one planned block.", facts: ["Protected pocket visible."], sourceLabel: "Based on your plan", boundaryLabel: "No silent replanning", visualState: .selected),
                TimeLifeSuiteShapeState(kind: .week, title: "Week Shape", question: "Does the week still fit?", summary: "Two days may need lighter scope before the week feels believable.", facts: ["2 pressured days visible."], sourceLabel: "Based on goals and captures", boundaryLabel: "Confirm first", visualState: .warning),
                TimeLifeSuiteShapeState(kind: .life, title: "Life Shape", question: "Is Time pointed at the life you are building?", summary: "Three active goals shape the current LifeShape Field.", facts: ["3 active goals included."], sourceLabel: "Based on active goals", boundaryLabel: "Broader than time slots", visualState: .default),
            ],
            calendarBoundaryLabel: "Calendar stays optional",
            manualFallbackLabel: "Manual fallback available",
            trustLabel: "No silent calendar changes"
        )
    )
    .padding()
}
