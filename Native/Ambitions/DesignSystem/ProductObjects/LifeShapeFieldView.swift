import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeFieldView: View {
    @Environment(\.ambitionTheme) var theme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @State var selectedHorizon: TimeHorizon
    @State var selectedZoomLevel: TimeLifeShapeZoomLevel = .field
    @State var revealsPressure = false
    @State var selectedReflowOptionID: String?
    @State var confirmedReflowAction: TimeReflowDecisionActionKind?

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

    var reading: LifeShapeReading {
        suite.field.reading(for: displayedHorizon)
    }

    var displayedHorizon: TimeHorizon {
        switch selectedZoomLevel {
        case .field:
            selectedHorizon
        case .day:
            .day
        case .week:
            .week
        case .month:
            .month
        case .year:
            .year
        }
    }

    var selectedReflowOption: TimeReflowDecisionOptionState? {
        guard let decision = reflowDecision else { return nil }
        if let selectedReflowOptionID,
           let selected = decision.options.first(where: { $0.id == selectedReflowOptionID }) {
            return selected
        }
        return decision.options.first
    }

    var displayedRenderState: LifeShapeRenderState {
        Self.screenshotRenderStateOverride() ?? suite.field.renderState
    }

    var displayedRenderStateTitle: String {
        switch displayedRenderState {
        case .defaultWeek: "Default"
        case .manualOnly: "Manual"
        case .calendarDenied: "Denied source"
        case .pressureCluster: "Pressure"
        case .sourceConflict: "Source split"
        case .reflowPreview: "Review"
        case .receiptAttached: "Review"
        }
    }

    static func initialScreenshotReflowAction() -> TimeReflowDecisionActionKind? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-AmbitionsTimeChangeAction"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return nil
        }

        switch arguments[arguments.index(after: flagIndex)].lowercased() {
        case "review", "apply", "applied":
            return .accept
        case "adjust":
            return .edit
        case "decline":
            return .decline
        default:
            return nil
        }
    }

    static func screenshotRenderStateOverride() -> LifeShapeRenderState? {
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
        case "context", "source-conflict":
            return .sourceConflict
        case "time-change", "change-preview":
            return .reflowPreview
        case "review", "receipt-attached":
            return .receiptAttached
        default:
            return nil
        }
    }

    static func screenshotFocusesQuietReflow() -> Bool {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-AmbitionsTimeFocus"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return false
        }

        let value = arguments[arguments.index(after: flagIndex)].lowercased()
        return value == "quiet-change" || value == "time-change"
    }

    var body: some View {
        let stageScene = TimeStageScene(
            surface: .time,
            productObject: TimeLens.objectStageContract.productObject,
            stageName: TimeLens.objectStageContract.stageName,
            firstViewportStructure: TimeLens.objectStageContract.firstViewportStructure,
            sourceTrustLineOrder: TimeLens.objectStageContract.sourceTrustLineOrder,
            currentDateSummary: reading.title,
            capacitySummary: reading.capacityStatement,
            protectedWindowSummary: suite.field.segments.first(where: { $0.kind == .protectedTime })?.detail ?? "",
            pressureSummary: suite.field.segments.first(where: { $0.kind == .pressure })?.detail ?? "",
            horizonSummary: "Day, week, month, and year stay inside Time.",
            captureSupportSummary: "Capture routes through the global composer.",
            accessibilityFallbacks: TimeLens.objectStageContract.accessibilityFallbacks
        )

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            contextCrown
            lifeShapeZoomControl
            if Self.screenshotFocusesQuietReflow() {
                reflowTrustSeam
            }
            capacityStatement
            sourceReceiptRow
            objectCanvas
            horizonControl
            if Self.screenshotFocusesQuietReflow() == false,
               revealsPressure || confirmedReflowAction != nil || displayedRenderState == .reflowPreview {
                reflowTrustSeam
            }
            continuityDock
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("time.life-shape-field")
        .accessibilityValue("\(accessibilityValue). \(TimeAccessibility.rootSummary(for: stageScene))")
    }

    @ViewBuilder
    var contextCrown: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                HStack(alignment: .center, spacing: theme.spacing.sm) {
                    Image(systemName: "clock")
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.stateStyle(for: suite.field.capacityFit.visualState).accent)
                        .frame(width: 28, height: 28)
                        .accessibilityHidden(true)

                    Text("Shape Time")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.accentSecondary)
                        .textCase(.uppercase)

                    Spacer(minLength: theme.spacing.sm)

                    inlineObjectLabel(
                        displayedRenderStateTitle,
                        icon: "gauge.with.dots.needle.bottom.50percent",
                        state: displayedRenderState.visualState
                    )
                    .fixedSize(horizontal: true, vertical: false)
                }

                Text("LifeShape Field")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Capacity proof.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        } else {
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
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("Field, day, week, month, and year stay in one LifeShape object.")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer(minLength: theme.spacing.sm)

                inlineObjectLabel(
                    displayedRenderStateTitle,
                    icon: "gauge.with.dots.needle.bottom.50percent",
                    state: displayedRenderState.visualState
                )
            }
        }
    }

    var lifeShapeZoomControl: some View {
        Picker("LifeShape zoom", selection: $selectedZoomLevel) {
            ForEach(TimeLifeShapeZoomLevel.allCases, id: \.self) { level in
                Text(level.title).tag(level)
            }
        }
	        .pickerStyle(.segmented)
	        .accessibilityIdentifier("time.life-shape-field.zoom-control")
	        .accessibilityLabel("LifeShape zoom")
	        .accessibilityHint("Moves between field, day, week, month, and year views without leaving Time.")
    }

    var horizonControl: some View {
        HorizonCapacityPrimitiveStage(
            role: .horizon,
	            title: "Horizon",
	            subtitle: "Day, week, month, year, and later stay inside the same field.",
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
        .accessibilityLabel("Future pressure")
        .accessibilityValue(selectedHorizon.title)
    }

}
