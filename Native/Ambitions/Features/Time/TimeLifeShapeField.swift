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
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State private var selectedHorizon: TimeHorizon
    @State private var revealsPressure = false
    @State private var selectedReflowOptionID: String?
    @State private var confirmedReflowAction: TimeReflowDecisionActionKind?

    let suite: TimeLifeSuiteState
    let reflowDecision: TimeReflowDecisionState?
    let reflowReceiptPreview: TimeReflowReceiptPreviewState?
    let calendarAwareness: TimeCalendarAwarenessState?
    let onReflowDecision: ((TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void)?

    init(
        suite: TimeLifeSuiteState,
        reflowDecision: TimeReflowDecisionState? = nil,
        reflowReceiptPreview: TimeReflowReceiptPreviewState? = nil,
        calendarAwareness: TimeCalendarAwarenessState? = nil,
        onReflowDecision: ((TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void)? = nil
    ) {
        self.suite = suite
        self.reflowDecision = reflowDecision
        self.reflowReceiptPreview = reflowReceiptPreview
        self.calendarAwareness = calendarAwareness
        self.onReflowDecision = onReflowDecision
        _selectedHorizon = State(initialValue: suite.field.defaultHorizon)
        _confirmedReflowAction = State(initialValue: Self.initialScreenshotReflowAction())
    }

    private var reading: LifeShapeReading {
        suite.field.reading(for: selectedHorizon)
    }

    private var selectedReflowOption: TimeReflowDecisionOptionState? {
        guard let decision = reflowDecision else { return nil }
        if let selectedReflowOptionID,
           let selected = decision.options.first(where: { $0.id == selectedReflowOptionID }) {
            return selected
        }
        return decision.options.first
    }

    private var displayedRenderState: LifeShapeRenderState {
        Self.screenshotRenderStateOverride() ?? suite.field.renderState
    }

    private var displayedRenderStateTitle: String {
        switch displayedRenderState {
        case .defaultWeek: "Default"
        case .manualOnly: "Manual"
        case .calendarDenied: "Denied source"
        case .pressureCluster: "Pressure"
        case .sourceConflict: "Source split"
        case .reflowPreview: "Reflow"
        case .receiptAttached: "Receipt"
        }
    }

    private static func initialScreenshotReflowAction() -> TimeReflowDecisionActionKind? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-AmbitionsTimeReflowAction"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return nil
        }

        switch arguments[arguments.index(after: flagIndex)].lowercased() {
        case "receipt", "apply", "applied":
            return .accept
        case "adjust":
            return .edit
        case "decline":
            return .decline
        default:
            return nil
        }
    }

    private static func screenshotRenderStateOverride() -> LifeShapeRenderState? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-AmbitionsTimeRenderState"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return nil
        }

        switch arguments[arguments.index(after: flagIndex)].lowercased() {
        case "default", "default-week":
            return .defaultWeek
        case "manual", "manual-only":
            return .manualOnly
        case "denied", "calendar-denied":
            return .calendarDenied
        case "pressure", "pressure-cluster":
            return .pressureCluster
        case "source", "source-conflict":
            return .sourceConflict
        case "reflow", "reflow-preview":
            return .reflowPreview
        case "receipt", "receipt-attached":
            return .receiptAttached
        default:
            return nil
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            contextCrown
            horizonControl
            reflowTrustSeam
            objectCanvas
            capacityStatement
            sourceReceiptRow
            continuityDock
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("time.life-shape-field")
        .accessibilityValue(accessibilityValue)
    }

    private var contextCrown: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: "clock")
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: suite.field.capacityFit.visualState).accent)
                .frame(width: 34, height: 34)
                .background(
                    Circle()
                        .fill(theme.colors.surfaceOverlay)
                )
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Shape Time")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.accentSecondary)
                    .textCase(.uppercase)
                Text("LifeShape Field")
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                Text("Capacity, pressure, protected time, and local source state.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            TagPill(displayedRenderStateTitle, icon: "gauge.with.dots.needle.bottom.50percent", state: displayedRenderState.visualState)
        }
    }

    private var horizonControl: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(TimeHorizon.allCases) { horizon in
                Button {
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                        selectedHorizon = horizon
                    }
                } label: {
                    Text(horizon.title)
                        .font(theme.typography.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, theme.spacing.xs)
                }
                .buttonStyle(.plain)
                .foregroundStyle(selectedHorizon == horizon ? theme.colors.textPrimary : theme.colors.textSecondary)
                .background(
                    Capsule(style: .continuous)
                        .fill(selectedHorizon == horizon ? theme.colors.surfaceOverlay : theme.colors.surfaceSecondary.opacity(0.54))
                )
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(selectedHorizon == horizon ? theme.stateStyle(for: .selected).stroke : theme.colors.strokeSubtle, lineWidth: 1)
                )
                .accessibilityIdentifier("time.life-shape-field.horizon.\(horizon.rawValue)")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Time horizon")
        .accessibilityValue(selectedHorizon.title)
    }

    private var objectCanvas: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                .fill(theme.colors.canvasElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.xl, style: .continuous)
                        .stroke(theme.stateStyle(for: suite.field.capacityFit.visualState).stroke.opacity(0.56), lineWidth: 1.2)
                )

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                segmentTexture
                Spacer(minLength: 0)
                Text(reading.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(reading.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                if revealsPressure {
                    Text(suite.field.reflowProposal.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.lg)
        }
        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 380 : 330)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("LifeShape Field")
        .accessibilityValue("\(reading.title). \(reading.summary). \(reading.capacityStatement)")
    }

    private var segmentTexture: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(suite.field.semanticMarks) { mark in
                semanticMarkRow(mark)
            }
        }
        .accessibilityHidden(true)
    }

    private func semanticMarkRow(_ mark: LifeShapeSemanticMark) -> some View {
        let style = theme.stateStyle(for: mark.visualState)
        let lineWidth = colorSchemeContrast == .increased ? 1.6 : 1
        let fillOpacity = reduceTransparency ? 1.0 : (mark.kind == .pressure && revealsPressure ? 1 : 0.72)
        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: mark.kind.systemImage)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 16)
            Text("\(mark.kind.semanticMeaning): \(mark.valueLabel)")
                .font(theme.typography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .layoutPriority(1)
            Spacer(minLength: theme.spacing.xs)
            if reduceMotion {
                Text(mark.kind.title)
                    .font(theme.typography.micro)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            } else {
                Capsule(style: .continuous)
                    .fill(style.accent.opacity(colorSchemeContrast == .increased ? 0.72 : 0.34))
                    .frame(width: max(CGFloat(30), CGFloat(58 * mark.intensity)), height: colorSchemeContrast == .increased ? 9 : 7)
            }
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(
            Capsule(style: .continuous)
                .fill(style.fill.opacity(fillOpacity))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(style.stroke.opacity(colorSchemeContrast == .increased ? 0.95 : 0.70), lineWidth: lineWidth)
        )
    }

    private func segmentRow(_ segment: LifeShapeSegment) -> some View {
        let style = theme.stateStyle(for: segment.visualState)
        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: segment.kind.systemImage)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 16)
            Text(segment.valueLabel)
                .font(theme.typography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Spacer(minLength: theme.spacing.xs)
            Capsule(style: .continuous)
                .fill(style.accent.opacity(0.34))
                .frame(width: max(CGFloat(42), CGFloat(126 * segment.weight)), height: 7)
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, theme.spacing.xs)
        .padding(.vertical, theme.spacing.xxxs)
        .background(
            Capsule(style: .continuous)
                .fill(style.fill.opacity(segment.kind == .pressure && revealsPressure ? 1 : 0.72))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(style.stroke.opacity(0.70), lineWidth: 1)
        )
    }

    private func segmentMark(_ segment: LifeShapeSegment, index: Int, size: CGSize) -> some View {
        let style = theme.stateStyle(for: segment.visualState)
        let width = max(size.width * (0.30 + segment.weight * 0.52), 96)
        let height = CGFloat(20 + (index % 3) * 10)
        let y = CGFloat(34 + index * 30)
        let rotation = Double(index - 2) * 4.0

        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: segment.kind.systemImage)
                .font(.system(size: 12, weight: .semibold))
            Text(segment.valueLabel)
                .font(theme.typography.micro)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(style.foreground)
        .padding(.horizontal, theme.spacing.xs)
        .frame(width: width, height: max(height, 30), alignment: .leading)
        .background(
            Capsule(style: .continuous)
                .fill(style.fill.opacity(segment.kind == .pressure && revealsPressure ? 1 : 0.72))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(style.stroke.opacity(0.72), lineWidth: 1)
        )
        .rotationEffect(.degrees(rotation))
        .position(x: size.width * (index.isMultiple(of: 2) ? 0.46 : 0.56), y: min(y, size.height - 120))
    }

    private var capacityStatement: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                    .foregroundStyle(theme.stateStyle(for: suite.field.capacityFit.visualState).accent)
                    .accessibilityHidden(true)
                Text(reading.capacityStatement)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Text(suite.field.reflowProposal.title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceOverlay.opacity(0.72))
        )
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("time.life-shape-field.capacity-statement")
    }

    private var sourceReceiptRow: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(spacing: theme.spacing.xs) {
                TagPill("Source", icon: "checkmark.shield", state: suite.field.sourceState.visualState)
                TagPill("Why this?", icon: "questionmark.circle", state: .default)
                TagPill(suite.field.receipt.ageLabel, icon: "doc.text", state: suite.field.receipt.visualState)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("\(suite.field.sourceState.whyThisLabel) \(suite.field.receipt.detail)")
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("time.life-shape-field.source-receipt")
    }

    private var reflowTrustSeam: some View {
        Group {
            if let decision = reflowDecision,
               let option = selectedReflowOption,
               let receiptPreview = reflowReceiptPreview {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    HStack(alignment: .top, spacing: theme.spacing.sm) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                            .foregroundStyle(theme.stateStyle(for: decision.visualState).accent)
                            .frame(width: 28)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                            Text("Reflow preview")
                                .font(theme.typography.bodyEmphasized)
                                .foregroundStyle(theme.colors.textPrimary)
                            Text(decision.subtitle)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: theme.spacing.xs)

                        TagPill(reflowStatusTitle, icon: "doc.text", state: reflowStatusState)
                    }

                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(option.beforeAfterPreview.beforeLabel)
                        Text(option.beforeAfterPreview.afterLabel)
                        Text(option.beforeAfterPreview.shapeChangeLabel)
                    }
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: theme.spacing.xs) {
                        TagPill(decision.sourceLabel, icon: "checkmark.shield", state: decision.visualState)
                        TagPill(calendarFallbackTitle, icon: calendarFallbackIcon, state: calendarFallbackState)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        Text("Reason: \(decision.reasonLabel)")
                        Text("Control: \(option.boundaryLabel)")
                        Text(receiptPreview.confirmationRequired)
                    }
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)

                    reflowActionRow(option)
                }
                .padding(theme.spacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .fill(theme.colors.surfaceOverlay.opacity(reduceTransparency ? 1 : 0.72))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                        .stroke(theme.stateStyle(for: decision.visualState).stroke.opacity(colorSchemeContrast == .increased ? 0.96 : 0.64), lineWidth: colorSchemeContrast == .increased ? 1.5 : 1)
                )
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Time reflow preview")
                .accessibilityValue(reflowAccessibilityValue(option: option, decision: decision, receiptPreview: receiptPreview))
                .accessibilityIdentifier("time.life-shape-field.reflow-trust-seam")
            }
        }
    }

    private func reflowActionRow(_ option: TimeReflowDecisionOptionState) -> some View {
        let actions = [
            TimeReflowDecisionActionKind.decline,
            TimeReflowDecisionActionKind.edit,
            TimeReflowDecisionActionKind.accept
        ]

        return Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: theme.spacing.xs) {
                    ForEach(actions, id: \.self) { action in
                        reflowActionButton(action, option: option)
                    }
                }
            } else {
                HStack(spacing: theme.spacing.xs) {
                    ForEach(actions, id: \.self) { action in
                        reflowActionButton(action, option: option)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func reflowActionButton(
        _ action: TimeReflowDecisionActionKind,
        option: TimeReflowDecisionOptionState
    ) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                confirmedReflowAction = action
                selectedReflowOptionID = option.id
            }
            onReflowDecision?(option, action)
        } label: {
            Label(reflowActionTitle(action), systemImage: action.icon)
                .font(theme.typography.micro)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing.xxs)
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.stateStyle(for: reflowActionState(action)).foreground)
        .background(
            Capsule(style: .continuous)
                .fill(theme.stateStyle(for: reflowActionState(action)).fill.opacity(reduceTransparency ? 1 : 0.78))
        )
        .overlay(
            Capsule(style: .continuous)
                .stroke(theme.stateStyle(for: reflowActionState(action)).stroke.opacity(colorSchemeContrast == .increased ? 0.95 : 0.66), lineWidth: colorSchemeContrast == .increased ? 1.4 : 1)
        )
        .accessibilityIdentifier("time.life-shape-field.reflow.\(action.rawValue)")
    }

    private func reflowActionTitle(_ action: TimeReflowDecisionActionKind) -> String {
        switch action {
        case .accept: "Apply"
        case .edit: "Adjust"
        case .decline: "Decline"
        }
    }

    private func reflowActionState(_ action: TimeReflowDecisionActionKind) -> AmbitionVisualState {
        if confirmedReflowAction == action {
            return action == .decline ? .success : .selected
        }
        return switch action {
        case .accept: .selected
        case .edit: .default
        case .decline: .success
        }
    }

    private var reflowStatusTitle: String {
        switch confirmedReflowAction {
        case .accept: "Receipt"
        case .edit: "Adjustment pending"
        case .decline: "Current shape kept"
        case nil: displayedRenderStateTitle
        }
    }

    private var reflowStatusState: AmbitionVisualState {
        switch confirmedReflowAction {
        case .accept: .selected
        case .edit: .default
        case .decline: .success
        case nil: displayedRenderState.visualState
        }
    }

    private var calendarFallbackTitle: String {
        guard let calendarAwareness else {
            return "Manual fallback"
        }
        switch calendarAwareness.status {
        case .denied:
            return "Calendar denied"
        case .calendarAware:
            return "Calendar optional"
        case .baseline, .unavailable, .writeOnly:
            return "Manual fallback"
        }
    }

    private var calendarFallbackIcon: String {
        guard let calendarAwareness else { return "hand.draw" }
        return calendarAwareness.status == .calendarAware ? "calendar.badge.clock" : "hand.draw"
    }

    private var calendarFallbackState: AmbitionVisualState {
        guard let calendarAwareness else { return .default }
        return calendarAwareness.status == .denied ? .warning : .default
    }

    private func reflowAccessibilityValue(
        option: TimeReflowDecisionOptionState,
        decision: TimeReflowDecisionState,
        receiptPreview: TimeReflowReceiptPreviewState
    ) -> String {
        [
            "LifeShape: \(reading.title)",
            "Capacity: \(reading.capacityStatement)",
            decision.subtitle,
            option.beforeAfterPreview.accessibilityValue,
            "Primary action: Apply reflow after review.",
            "Available actions: Decline, Adjust, Apply.",
            "Source: \(decision.sourceLabel)",
            "Reason: \(decision.reasonLabel)",
            "Control: \(option.boundaryLabel)",
            "Receipt: \(receiptPreview.confirmationRequired)"
        ].joined(separator: ". ")
    }

    private var continuityDock: some View {
        HStack(spacing: theme.spacing.xs) {
            ForEach(Array(suite.field.continuityDockItems.enumerated()), id: \.offset) { index, item in
                Label(item, systemImage: continuityIcon(at: index))
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .padding(.horizontal, theme.spacing.xs)
                    .padding(.vertical, theme.spacing.xxs)
                    .background(
                        Capsule(style: .continuous)
                            .fill(theme.colors.surfaceSecondary.opacity(0.70))
                    )
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("time.life-shape-field.continuity-dock")
    }

    private func continuityIcon(at index: Int) -> String {
        switch index {
        case 0: "waveform.path"
        case 1: "lock"
        default: "doc.text"
        }
    }

    private var accessibilityValue: String {
        [
            reading.title,
            reading.summary,
            reading.capacityStatement,
            suite.field.sourceState.detail,
            suite.field.receipt.detail
        ].joined(separator: ". ")
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
            Text(item.schedulePressureLabel)
            Text(item.proofOpportunityLabel)
            Text(item.provenanceLabel)
            Text(item.privacyLabel)
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
                TimeLifeSuiteShapeState(kind: .day, title: "Day Shape", question: "What can this day honestly hold?", summary: "Today has a protected pocket and one planned block.", facts: ["Protected pocket visible."], sourceLabel: "Based on your plan", boundaryLabel: "No silent replanning", schedulePressureLabel: "Schedule pressure: today is readable.", protectedTimeLabel: "Protected time: one pocket stays visible.", capacityLabel: "Capacity: day can hold.", proofOpportunityLabel: "Proof opportunity: one receipt can explain today's work.", provenanceLabel: "Provenance: based on the current day only.", privacyLabel: "Privacy: local-only preview.", visualState: .selected),
                TimeLifeSuiteShapeState(kind: .week, title: "Week Shape", question: "Does the week still fit?", summary: "Two days may need lighter scope before the week feels believable.", facts: ["2 pressured days visible."], sourceLabel: "Based on goals and captures", boundaryLabel: "Confirm first", schedulePressureLabel: "Schedule pressure: 2 pressured days need review.", protectedTimeLabel: "Protected time: protected items stay visible.", capacityLabel: "Capacity: captures still need placement.", proofOpportunityLabel: "Proof opportunity: a small confirmed step can become a receipt.", provenanceLabel: "Provenance: based on goals and captures.", privacyLabel: "Privacy: local-only preview.", visualState: .warning),
                TimeLifeSuiteShapeState(kind: .life, title: "Life Shape", question: "Is Time pointed at the life you are building?", summary: "Three active goals shape the current LifeShape Field.", facts: ["3 active goals included."], sourceLabel: "Based on active goals", boundaryLabel: "Broader than time slots", schedulePressureLabel: "Schedule pressure: active goals shape the longer arc.", protectedTimeLabel: "Protected time: the life view stays broader than one day.", capacityLabel: "Capacity: active goals keep the life view meaningful.", proofOpportunityLabel: "Proof opportunity: active goals can show durable proof locally.", provenanceLabel: "Provenance: based on active goals.", privacyLabel: "Privacy: local-only preview.", visualState: .default),
            ],
            calendarBoundaryLabel: "Calendar stays optional",
            manualFallbackLabel: "Manual fallback available",
            trustLabel: "No silent calendar changes"
        )
    )
    .padding()
}
