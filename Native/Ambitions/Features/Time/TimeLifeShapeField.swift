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

struct TimeObjectStagePrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let firstViewportStructure: String
    let replacesFirstViewportStructures: [String]
    let sourceTrustLineOrder: [String]
    let accessibilityFallbacks: [String]
    let screenshotIdentifier: String
    let firstViewportAvoidsCalendarCardDashboardGeometry: Bool

    static let current = TimeObjectStagePrimitiveContract(
        primitiveID: "time-object-stage",
        ownerSurface: "Time",
        productObject: "LifeShape Field",
        firstViewportStructure: "Full-bleed LifeShape Field object stage with inline horizon control, pressure texture, plain week-capacity line, shaping actions, and source/receipt relationship.",
        replacesFirstViewportStructures: [
            "calendar-like horizon chip strip",
            "rounded LifeShape canvas panel",
            "capacity statement panel",
            "metric-row dashboard",
            "source and receipt pills",
            "reflow preview panel"
        ],
        sourceTrustLineOrder: [
            "source",
            "reason",
            "receipt",
            "privacy"
        ],
        accessibilityFallbacks: [
            "VoiceOver names LifeShape Field before horizon, capacity, source, receipt, and action controls",
            "Dynamic Type stacks horizon and source/receipt lines without changing object order",
            "Reduce Motion keeps pressure texture static",
            "Increase Contrast strengthens lines and text rather than adding card chrome",
            "Differentiate Without Color exposes source, reason, receipt, and privacy as text"
        ],
        screenshotIdentifier: "TimeObjectStage",
        firstViewportAvoidsCalendarCardDashboardGeometry: true
    )
}

private struct TimeObjectStageInlineDatum: Identifiable {
    let id: String
    let title: String
    let value: String
    let symbolName: String
    let token: AmbitionPrimitiveSemanticToken
}

struct TimeLifeShapeField: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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

    private static func screenshotFocusesQuietReflow() -> Bool {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-AmbitionsTimeFocus"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return false
        }

        let value = arguments[arguments.index(after: flagIndex)].lowercased()
        return value == "quiet-reflow" || value == "reflow"
    }

    var body: some View {
        let objectStageContract = TimeObjectStagePrimitiveContract.current

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            contextCrown
            if Self.screenshotFocusesQuietReflow() {
                reflowTrustSeam
            }
            capacityStatement
            sourceReceiptRow
            objectCanvas
            horizonControl
            if Self.screenshotFocusesQuietReflow() == false {
                reflowTrustSeam
            }
            continuityDock
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("time.life-shape-field")
        .accessibilityValue("\(accessibilityValue). \(objectStageContract.firstViewportStructure)")
    }

    private var contextCrown: some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: "clock")
                .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(theme.stateStyle(for: suite.field.capacityFit.visualState).accent)
                .frame(width: 28, height: 28)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Shape Time")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.accentSecondary)
                    .textCase(.uppercase)
                Text("LifeShape Field")
                    .font(dynamicTypeSize.isAccessibilitySize ? theme.typography.section : theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : nil)
                    .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 0.72 : 1)
                Text(dynamicTypeSize.isAccessibilitySize ? "Source proof." : "Capacity, pressure, protected time, and local source state.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2 : nil)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: theme.spacing.sm)

            inlineObjectLabel(
                displayedRenderStateTitle,
                icon: "gauge.with.dots.needle.bottom.50percent",
                state: displayedRenderState.visualState
            )
        }
    }

    private var horizonControl: some View {
        HorizonCapacityPrimitiveStage(
            role: .horizon,
            title: "Horizon",
            subtitle: "Day, Week, and Month shape capacity without becoming root navigation.",
            statusLabel: selectedHorizon.title,
            accessibilityIdentifier: "time.life-shape-field.horizon-control"
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(TimeHorizon.allCases) { horizon in
                    horizonTextButton(horizon)
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Time horizon")
        .accessibilityValue(selectedHorizon.title)
    }

    private func horizonTextButton(_ horizon: TimeHorizon) -> some View {
        let selected = selectedHorizon == horizon
        let horizonReading = suite.field.reading(for: horizon)
        return Button {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                selectedHorizon = horizon
            }
        } label: {
            HorizonCapacityPrimitiveLine(
                role: selected ? .selectedHorizon : .horizon,
                title: horizon.title,
                subtitle: horizonReading.capacityStatement,
                statusLabel: selected ? "Selected" : "Review",
                visualState: selected ? .selected : .default,
                isSelected: selected,
                accessibilityIdentifier: "time.life-shape-field.horizon.\(horizon.rawValue)"
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("time.life-shape-field.horizon.\(horizon.rawValue)")
    }

    private var objectCanvas: some View {
        ZStack(alignment: .topLeading) {
            objectStageTextureBackdrop

            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                Text(reading.title)
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(reading.summary)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                    .fixedSize(horizontal: false, vertical: true)
                segmentTexture
                if revealsPressure {
                    Text(suite.field.reflowProposal.detail)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                        .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(theme.spacing.lg)
        }
        .frame(minHeight: dynamicTypeSize.isAccessibilitySize ? 300 : 380)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("LifeShape Field")
        .accessibilityValue("\(reading.title). \(reading.summary). \(reading.capacityStatement)")
    }

    private var objectStageTextureBackdrop: some View {
        ProductMeaningCanvasEngine(
            role: .timePressure,
            marks: suite.field.semanticMarks.map { mark in
                ProductMeaningCanvasMark(id: mark.id, intensity: mark.intensity)
            },
            visualState: suite.field.capacityFit.visualState,
            accessibilityIdentifier: "time.life-shape-field.pressure-canvas-engine"
        )
        .opacity(colorSchemeContrast == .increased ? 0.58 : 0.36)
        .mask {
            RadialGradient(
                colors: [
                    .white,
                    .white.opacity(0.68),
                    .clear
                ],
                center: .center,
                startRadius: dynamicTypeSize.isAccessibilitySize ? 80 : 118,
                endRadius: dynamicTypeSize.isAccessibilitySize ? 260 : 320
            )
        }
        .accessibilityHidden(true)
    }

    private var segmentTexture: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(semanticMarksForFirstViewport) { mark in
                semanticMarkRow(mark, compact: dynamicTypeSize.isAccessibilitySize == false)
            }
        }
        .accessibilityHidden(true)
    }

    private var semanticMarksForFirstViewport: ArraySlice<LifeShapeSemanticMark> {
        if dynamicTypeSize.isAccessibilitySize {
            return suite.field.semanticMarks.prefix(suite.field.semanticMarks.count)
        }
        return suite.field.semanticMarks.prefix(6)
    }

    private func semanticMarkRow(_ mark: LifeShapeSemanticMark, compact: Bool) -> some View {
        let style = theme.stateStyle(for: mark.visualState)
        let lineWidth = colorSchemeContrast == .increased ? 1.6 : 1
        return HStack(spacing: theme.spacing.xs) {
            Image(systemName: mark.kind.systemImage)
                .font(.system(size: 12, weight: .semibold))
                .frame(width: 16)
            Text("\(mark.kind.semanticMeaning): \(mark.valueLabel)")
                .font(theme.typography.micro)
                .lineLimit(compact ? 2 : 1)
                .minimumScaleFactor(compact ? 0.64 : 0.68)
                .layoutPriority(1)
            Spacer(minLength: theme.spacing.xs)
            if reduceMotion {
                Text(mark.kind.title)
                    .font(theme.typography.micro)
                    .lineLimit(1)
                    .minimumScaleFactor(0.70)
            } else {
                Rectangle()
                    .fill(style.accent.opacity(colorSchemeContrast == .increased ? 0.72 : 0.34))
                    .frame(
                        width: max(CGFloat(compact ? 18 : 30), CGFloat((compact ? 34 : 58) * mark.intensity)),
                        height: colorSchemeContrast == .increased ? 9 : 7
                    )
            }
        }
        .foregroundStyle(style.foreground)
        .padding(.vertical, theme.spacing.xxxs)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(colorSchemeContrast == .increased ? 0.78 : 0.32))
                .frame(height: lineWidth)
        }
    }

    @ViewBuilder
    private var capacityStatement: some View {
        if dynamicTypeSize.isAccessibilitySize {
            accessibilityCapacityStatement
        } else {
            standardCapacityStatement
        }
    }

    private var standardCapacityStatement: some View {
        HorizonCapacityPrimitiveStage(
            role: .capacity,
            title: reading.capacityStatement,
            subtitle: suite.field.reflowProposal.title,
            statusLabel: suite.field.capacityFit.title,
            visualState: suite.field.capacityFit.visualState,
            accessibilityIdentifier: "time.life-shape-field.capacity-statement"
        ) {
            shapingActionStrip

            HorizonCapacityPrimitiveLine(
                role: .continuity,
                title: "Review before reflow",
                subtitle: suite.field.reflowProposal.detail,
                systemImage: "lock.shield",
                visualState: .default
            )
        }
        .accessibilityElement(children: .combine)
    }

    private var accessibilityCapacityStatement: some View {
        let style = theme.stateStyle(for: suite.field.capacityFit.visualState)
        return VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(alignment: .top, spacing: theme.spacing.sm) {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(style.accent)
                    .frame(width: 28, alignment: .leading)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text("Capacity")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(style.accent)
                    Text(reading.capacityStatement)
                        .font(theme.typography.micro.weight(.semibold))
                        .foregroundStyle(theme.colors.textPrimary)
                        .lineLimit(7)
                        .minimumScaleFactor(0.64)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(dynamicTypeSize.isAccessibilitySize ? "Keep shape." : suite.field.reflowProposal.title)
                        .font(theme.typography.micro)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: theme.spacing.sm)

                Text(suite.field.capacityFit.title)
                    .font(theme.typography.micro.weight(.semibold))
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.trailing)
                    .fixedSize(horizontal: false, vertical: true)
            }

            shapingActionStrip
        }
        .padding(.leading, theme.spacing.md)
        .padding(.trailing, theme.spacing.sm)
        .padding(.vertical, theme.spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style.fill.opacity(0.18))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(style.accent)
                .frame(width: 3)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(style.stroke.opacity(0.66))
                .frame(height: colorSchemeContrast == .increased ? 2 : 1)
                .accessibilityHidden(true)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(style.stroke.opacity(0.66))
                .frame(height: colorSchemeContrast == .increased ? 2 : 1)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("capacity, \(reading.capacityStatement)")
        .accessibilityValue([suite.field.reflowProposal.title, suite.field.capacityFit.title].joined(separator: ". "))
        .accessibilityIdentifier("time.life-shape-field.capacity-statement")
    }

    private var shapingActionStrip: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: dynamicTypeSize.isAccessibilitySize ? 220 : 132), spacing: theme.spacing.xs)],
            alignment: .leading,
            spacing: theme.spacing.xs
        ) {
            shapingActionButton(
                title: "Shape week",
                icon: "calendar.badge.clock",
                identifier: "time.life-shape-field.action.shape-week"
            ) {
                selectedHorizon = .week
                revealsPressure = false
            }
            shapingActionButton(
                title: "Review pressure",
                icon: "waveform.path.ecg.rectangle",
                identifier: "time.life-shape-field.action.review-pressure"
            ) {
                revealsPressure = true
            }
            shapingActionButton(
                title: "Protect this block",
                icon: "clock.badge.checkmark",
                identifier: "time.life-shape-field.action.protect-block"
            ) {
                selectedHorizon = .week
                confirmedReflowAction = .decline
            }
            shapingActionButton(
                title: "Adjust plan",
                icon: "slider.horizontal.3",
                identifier: "time.life-shape-field.action.adjust-plan"
            ) {
                confirmedReflowAction = .edit
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func shapingActionButton(
        title: String,
        icon: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                action()
            }
        } label: {
            Label(title, systemImage: icon)
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
                .frame(maxWidth: .infinity, minHeight: 38, alignment: .leading)
                .padding(.vertical, theme.spacing.xxs)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(theme.colors.strokeSubtle)
                        .frame(height: 1)
                }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier(identifier)
    }

    private var sourceReceiptRow: some View {
        let items = objectStageSourceItems

        return HorizonCapacityPrimitiveStage(
            role: .source,
            title: "Source and receipt",
            subtitle: displayedSourceDetail,
            statusLabel: suite.field.receipt.ageLabel,
            accessibilityIdentifier: "time.life-shape-field.source-receipt"
        ) {
            Group {
                if dynamicTypeSize.isAccessibilitySize {
                    ForEach(items) { item in
                        horizonCapacitySourceLine(item)
                    }
                } else {
                    HStack(alignment: .top, spacing: theme.spacing.xs) {
                        ForEach(items) { item in
                            horizonCapacitySourceLine(item)
                        }
                    }
                }
            }

            HorizonCapacityPrimitiveLine(
                role: .receipt,
                title: suite.field.sourceState.whyThisLabel,
                subtitle: suite.field.receipt.detail,
                systemImage: "doc.text.magnifyingglass",
                visualState: suite.field.receipt.visualState
            )
        }
        .accessibilityElement(children: .combine)
    }

    private func horizonCapacitySourceLine(_ item: TimeObjectStageInlineDatum) -> some View {
        HorizonCapacityPrimitiveLine(
            role: horizonCapacityRole(for: item),
            title: item.title,
            subtitle: item.value,
            systemImage: item.symbolName,
            visualState: horizonCapacityVisualState(for: item),
            accessibilityIdentifier: "time.life-shape-field.source-receipt.\(item.id)"
        )
    }

    private func horizonCapacityRole(for item: TimeObjectStageInlineDatum) -> HorizonCapacityPrimitiveRole {
        switch item.id {
        case "receipt":
            return .receipt
        case "source", "privacy":
            return .source
        default:
            return .continuity
        }
    }

    private func horizonCapacityVisualState(for item: TimeObjectStageInlineDatum) -> AmbitionVisualState {
        switch item.id {
        case "receipt":
            return suite.field.receipt.visualState
        case "reason":
            return suite.field.sourceState.visualState
        default:
            return .default
        }
    }

    private var objectStageSourceItems: [TimeObjectStageInlineDatum] {
        [
            TimeObjectStageInlineDatum(
                id: "source",
                title: "Source",
                value: displayedSourceTitle,
                symbolName: "checkmark.shield",
                token: .source
            ),
            TimeObjectStageInlineDatum(
                id: "reason",
                title: "Reason",
                value: nonEmpty(suite.field.sourceState.whyThisLabel, fallback: "Why this remains inspectable"),
                symbolName: "questionmark.circle",
                token: .sourceAttention
            ),
            TimeObjectStageInlineDatum(
                id: "receipt",
                title: "Receipt",
                value: suite.field.receipt.ageLabel,
                symbolName: "doc.text",
                token: .receipt
            ),
            TimeObjectStageInlineDatum(
                id: "privacy",
                title: "Privacy",
                value: displayedPrivacyLabel,
                symbolName: "lock",
                token: .privacyBoundary
            )
        ]
    }

    private var displayedSourceTitle: String {
        switch displayedRenderState {
        case .manualOnly:
            return "Manual Time source"
        case .calendarDenied:
            return "Calendar denied"
        default:
            return suite.field.sourceState.title
        }
    }

    private var displayedSourceDetail: String {
        switch displayedRenderState {
        case .manualOnly:
            return "Time is shaped from local goals, captures, and manual defaults."
        case .calendarDenied:
            return "Calendar is unavailable; Time still works from local goals, captures, and user choice."
        default:
            return suite.field.sourceState.detail
        }
    }

    private var displayedPrivacyLabel: String {
        switch displayedRenderState {
        case .manualOnly:
            return "No external calendar source is required."
        case .calendarDenied:
            return "Calendar access stays optional; no external source is required."
        default:
            return nonEmpty(suite.field.sourceState.privacyLabel, fallback: "Local by default")
        }
    }

    private var reflowTrustSeam: some View {
        Group {
            if let decision = reflowDecision,
               let option = selectedReflowOption,
               let receiptPreview = reflowReceiptPreview {
                QuietReflowPrimitiveStage(
                    role: .preview,
                    title: "Reflow preview",
                    subtitle: decision.subtitle,
                    statusLabel: reflowStatusTitle,
                    visualState: reflowStatusState,
                    accessibilityIdentifier: "time.life-shape-field.reflow-trust-seam"
                ) {
                    QuietReflowBeforeAfterPrimitive(
                        title: option.beforeAfterPreview.title,
                        beforeLabel: option.beforeAfterPreview.beforeLabel,
                        afterLabel: option.beforeAfterPreview.afterLabel,
                        changeLabel: option.beforeAfterPreview.shapeChangeLabel,
                        receiptLabel: option.beforeAfterPreview.receiptPreviewLabel,
                        visualState: reflowStatusState
                    )

                    HStack(alignment: .firstTextBaseline, spacing: theme.spacing.lg) {
                        QuietReflowPrimitiveLine(
                            role: .source,
                            title: decision.sourceLabel,
                            systemImage: "checkmark.shield",
                            visualState: decision.visualState
                        )
                        QuietReflowPrimitiveLine(
                            role: .manualFallback,
                            title: calendarFallbackTitle,
                            systemImage: calendarFallbackIcon,
                            visualState: calendarFallbackState
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                        QuietReflowPrimitiveLine(
                            role: .impact,
                            title: "Reason",
                            subtitle: decision.reasonLabel,
                            systemImage: "questionmark.circle",
                            visualState: decision.visualState
                        )
                        QuietReflowPrimitiveLine(
                            role: .noSilentChange,
                            title: "Control",
                            subtitle: option.boundaryLabel,
                            systemImage: "lock.shield",
                            visualState: .default
                        )
                        QuietReflowPrimitiveLine(
                            role: .receipt,
                            title: receiptPreview.confirmationRequired,
                            systemImage: "doc.text.magnifyingglass",
                            visualState: reflowStatusState
                        )
                    }

                    reflowActionRow(option)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Time reflow preview")
                .accessibilityValue(reflowAccessibilityValue(option: option, decision: decision, receiptPreview: receiptPreview))
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
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.stateStyle(for: reflowActionState(action)).stroke.opacity(confirmedReflowAction == action ? 0.90 : 0.34))
                .frame(height: confirmedReflowAction == action ? 2 : 1)
        }
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
            return "User choice"
        }
        switch calendarAwareness.status {
        case .denied:
            return "Calendar denied"
        case .calendarAware:
            return "Calendar optional"
        case .baseline, .unavailable, .writeOnly:
            return "User choice"
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
        HorizonCapacityPrimitiveStage(
            role: .continuity,
            title: "Continuity",
            subtitle: "Horizon changes keep source, protected pocket, and receipt review attached.",
            statusLabel: selectedHorizon.title,
            accessibilityIdentifier: "time.life-shape-field.continuity-dock"
        ) {
            ForEach(Array(suite.field.continuityDockItems.enumerated()), id: \.offset) { index, item in
                HorizonCapacityPrimitiveLine(
                    role: .continuity,
                    title: item,
                    subtitle: continuitySubtitle(at: index),
                    systemImage: continuityIcon(at: index),
                    visualState: index == 0 ? .selected : .default,
                    accessibilityIdentifier: "time.life-shape-field.continuity-dock.\(index)"
                )
            }

            HorizonCapacityPrimitiveLine(
                role: .continuity,
                title: "Context stays together",
                subtitle: "Day, Week, and Month keep the current shape attached.",
                systemImage: "lock.shield",
                visualState: .default,
                accessibilityIdentifier: "time.life-shape-field.continuity-dock.context"
            )
        }
    }

    private func inlineObjectLabel(_ title: String, icon: String, state: AmbitionVisualState) -> some View {
        Label(title, systemImage: icon)
            .font(theme.typography.micro.weight(.semibold))
            .foregroundStyle(theme.stateStyle(for: state).accent)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
    }

    private func nonEmpty(_ value: String?, fallback: String) -> String {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return fallback
        }
        return trimmed
    }

    private func continuityIcon(at index: Int) -> String {
        switch index {
        case 0: "waveform.path"
        case 1: "lock"
        default: "doc.text"
        }
    }

    private func continuitySubtitle(at index: Int) -> String {
        switch index {
        case 0: "Current horizon relationship remains inspectable."
        case 1: "Protected time stays attached to capacity review."
        default: "Receipt history stays with the horizon change."
        }
    }

    private var accessibilityValue: String {
        [
            reading.title,
            reading.summary,
            reading.capacityStatement,
            displayedSourceDetail,
            suite.field.receipt.detail
        ].joined(separator: ". ")
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
            manualFallbackLabel: "User choice available",
            trustLabel: "No silent calendar changes"
        )
    )
    .padding()
}
