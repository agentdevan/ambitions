import AmbitionsDesignSystem
import SwiftUI

struct LifeShapeFieldView: View {
    @Environment(\.ambitionTheme) var theme
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    @Environment(\.dynamicTypeSize) var dynamicTypeSize

    @State var selectedHorizon: TimeHorizon
    @State var selectedZoomLevel: TimeLifeShapeZoomLevel = .field
    @State var selectedLayer: LifeShapeLayer = .open
    @State var selectedMarkID: String?
    @State var revealsPressure = false
    @State var selectedReflowOptionID: String?
    @State var confirmedReflowAction: TimeReflowDecisionActionKind?

    let suite: TimeLifeSuiteState
    let reflowDecision: TimeReflowDecisionState?
    let reflowReceiptPreview: TimeReflowReceiptPreviewState?
    let calendarAwareness: TimeCalendarAwarenessState?
    let onReflowDecision: ((TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void)?
    let onSearch: (() -> Void)?
    let onCapture: (() -> Void)?
    let visibleMutation: UserVisibleMutation?
    let onMutationAction: ((TimeFieldMutationAction, LifeShapeSemanticMark?) -> Void)?
    let onUndoMutation: (() -> Void)?

    init(
        suite: TimeLifeSuiteState,
        reflowDecision: TimeReflowDecisionState? = nil,
        reflowReceiptPreview: TimeReflowReceiptPreviewState? = nil,
        calendarAwareness: TimeCalendarAwarenessState? = nil,
        onReflowDecision: ((TimeReflowDecisionOptionState, TimeReflowDecisionActionKind) -> Void)? = nil,
        onSearch: (() -> Void)? = nil,
        onCapture: (() -> Void)? = nil,
        visibleMutation: UserVisibleMutation? = nil,
        onMutationAction: ((TimeFieldMutationAction, LifeShapeSemanticMark?) -> Void)? = nil,
        onUndoMutation: (() -> Void)? = nil
    ) {
        self.suite = suite
        self.reflowDecision = reflowDecision
        self.reflowReceiptPreview = reflowReceiptPreview
        self.calendarAwareness = calendarAwareness
        self.onReflowDecision = onReflowDecision
        self.onSearch = onSearch
        self.onCapture = onCapture
        self.visibleMutation = visibleMutation
        self.onMutationAction = onMutationAction
        self.onUndoMutation = onUndoMutation
        _selectedHorizon = State(initialValue: suite.field.defaultHorizon)
        _selectedLayer = State(initialValue: Self.initialScreenshotLayer())
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

    var selectedLayerMarks: [LifeShapeSemanticMark] {
        let allowedKinds: Set<LifeShapeSemanticMarkKind> = switch selectedLayer {
        case .open:
            [.freeTimeQuality, .executionLanes, .goalLoad]
        case .protected:
            [.protectedTime, .recoveryNeed]
        case .pressure, .buffer:
            []
        }
        let marks = suite.field.semanticMarks.filter { allowedKinds.contains($0.kind) }
        return marks.isEmpty ? Array(suite.field.semanticMarks.prefix(2)) : marks
    }

    var selectedMark: LifeShapeSemanticMark? {
        if let selectedMarkID,
           let mark = selectedLayerMarks.first(where: { $0.id == selectedMarkID }) {
            return mark
        }
        return selectedLayerMarks.first
    }

    var primaryActionTitle: String {
        selectedLayer == .open ? "Place Step" : "Protect window"
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

    static func initialScreenshotLayer() -> LifeShapeLayer {
        screenshotRenderStateOverride() == .pressureCluster ? .protected : .open
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
            horizonSummary: "\(displayedHorizon.title) remains one Time field.",
            captureSupportSummary: "Capture routes through the global composer.",
            accessibilityFallbacks: TimeLens.objectStageContract.accessibilityFallbacks
        )

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            contextCrown
            LifeShapeLayerSelector(selection: $selectedLayer)
            if Self.screenshotFocusesQuietReflow() {
                reflowTrustSeam
            }
            LifeShapeNowInstrument(
                title: reading.title,
                caption: reading.capacityStatement,
                detail: reading.summary,
                primaryActionTitle: primaryActionTitle,
                visualState: suite.field.capacityFit.visualState
            ) {
                if selectedLayer == .open {
                    onMutationAction?(.placeStep, selectedMark)
                } else {
                    onMutationAction?(.protectWindow, selectedMark)
                }
            }
            if let visibleMutation {
                LifeShapeMutationProofBanner(
                    mutation: visibleMutation,
                    onUndo: visibleMutation.stageMutation.undoAvailability.isAvailable ? onUndoMutation : nil
                )
            }
            objectCanvas
            lifeShapeHorizonRows
            LifeShapeBucketDetail(
                layer: selectedLayer,
                mark: selectedMark,
                todayAnchor: "Today follows this Time shape when the window changes."
            )
            LifeShapeCorrectionMenu(
                layer: selectedLayer,
                onNotUsable: { onMutationAction?(.notUsable, selectedMark) },
                onNeedsMoreTime: { onMutationAction?(.needsMoreTime, selectedMark) },
                onKeepClear: {
                    selectedLayer = .protected
                    onMutationAction?(.keepClear, selectedMark)
                }
            )
            if Self.screenshotFocusesQuietReflow() == false,
               revealsPressure || confirmedReflowAction != nil {
                reflowTrustSeam
            }
            continuityDock
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("time.life-shape-field")
        .accessibilityValue("\(accessibilityValue). \(TimeAccessibility.rootSummary(for: stageScene))")
        .modifier(LifeShapeMutationHapticModifier(mutation: visibleMutation))
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

                    Text("Time")
                        .font(theme.typography.caption.weight(.semibold))
                        .foregroundStyle(theme.colors.accentSecondary)

                    Spacer(minLength: theme.spacing.sm)

                    contextCrownActions
                }

                Text("LifeShape Field")
                    .font(theme.typography.section)
                    .foregroundStyle(theme.colors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("This week")
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
                    Text("Time")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.accentSecondary)
                    Text("LifeShape Field")
                        .font(theme.typography.title)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text("This week")
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer(minLength: theme.spacing.sm)

                contextCrownActions
            }
        }
    }

    var contextCrownActions: some View {
        HStack(spacing: theme.spacing.xs) {
            Button {
                onSearch?()
            } label: {
                Label("Search", systemImage: "magnifyingglass")
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Search")
            .accessibilityIdentifier("time.context-crown.search")

            Button {
                onCapture?()
            } label: {
                Label("Capture", systemImage: "plus")
                    .labelStyle(.iconOnly)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Capture")
            .accessibilityIdentifier("time.context-crown.capture")
        }
    }

    var lifeShapeHorizonRows: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            ForEach(selectedLayerMarks) { mark in
                LifeShapeHorizonRowView(
                    mark: mark,
                    selected: selectedMark?.id == mark.id
                ) {
                    selectedMarkID = mark.id
                }
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("time.life-shape-field.horizon-rows")
    }

}

private struct LifeShapeMutationHapticModifier: ViewModifier {
    let mutation: UserVisibleMutation?

    func body(content: Content) -> some View {
        if let mutation,
           let intent = Self.intent(from: mutation.stageMutation.hapticIntent) {
            content.ambitionHaptic(intent, trigger: mutation.stageMutation.runtimeMutationID)
        } else {
            content
        }
    }

    static func intent(from rawValue: String) -> AmbitionTheme.HapticIntent? {
        switch rawValue {
        case "confirmation":
            .completion
        case "selection":
            .selection
        case "correction":
            .correction
        case "reschedule":
            .reschedule
        case "warning":
            .warning
        case "routeChange":
            .routeChange
        default:
            nil
        }
    }
}
