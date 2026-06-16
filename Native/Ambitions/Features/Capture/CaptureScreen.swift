import AmbitionsDesignSystem
import SwiftUI

enum CaptureScreenShellMode: Equatable {
    case timeSupport
    case topLevelCapture
}

struct CaptureObjectStagePrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let stageName: String
    let screenshotIdentifier: String
    let sourceRouteOrder: [String]
    let replacesStructures: [String]
    let forbiddenRootPatterns: [String]
    let accessibilityFallbacks: [String]
    let keepsCaptureGlobalAction: Bool

    static let current = CaptureObjectStagePrimitiveContract(
        primitiveID: "capture-route-ribbon",
        ownerSurface: "Global Capture",
        productObject: "Atmosphere Composer",
        stageName: "Capture Object Stage",
        screenshotIdentifier: "CaptureObjectStage",
        sourceRouteOrder: [
            "open field",
            "suggested path",
            "placement shelf",
            "review history",
            "continuity lines"
        ],
        replacesStructures: [
            "composer panels",
            "draft-route local containers",
            "capture item cards",
            "category-like capture buckets",
            "first-run card shell"
        ],
        forbiddenRootPatterns: [
            "floating action button",
            "message-first shell",
            "raw activity stream",
            "intake matrix",
            "top-level tab"
        ],
        accessibilityFallbacks: [
            "VoiceOver reads input, suggested route, consequence, privacy, receipt, and correction choices in stage order.",
            "Dynamic Type stacks route controls before supporting route evidence.",
            "Reduce Motion uses static route-reveal state rather than motion-only meaning.",
            "Increase Contrast and Differentiate Without Color use line, symbol, and text labels in addition to accent color."
        ],
        keepsCaptureGlobalAction: true
    )
}

struct CaptureStageGroup<Content: View>: View {
    @Environment(\.ambitionTheme) private var theme

    let state: LivingVisualState
    let accessibilityIdentifier: String
    let content: Content

    init(
        state: LivingVisualState,
        accessibilityIdentifier: String,
        @ViewBuilder content: () -> Content
    ) {
        self.state = state
        self.accessibilityIdentifier = accessibilityIdentifier
        self.content = content()
    }

    var body: some View {
        let accent = state == .empty ? LivingTabContext.capture.accent(in: theme) : theme.stateStyle(for: state.ambitionState).accent

        VStack(alignment: .leading, spacing: theme.spacing.md) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, theme.spacing.sm)
        .padding(.leading, theme.spacing.sm)
        .background(alignment: .leading) {
            Rectangle()
                .fill(accent.opacity(0.32))
                .frame(width: 2)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.72))
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.colors.strokeSubtle.opacity(0.42))
                .frame(height: 1)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

struct CaptureScreen: View {
    @Environment(\.appShellCapability) private var appShellCapability
    @Environment(\.appFeatureFactoryCapability) private var appFeatureFactoryCapability
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var viewModel: CaptureViewModel
    @State private var isCaptureDepthExpanded = false
    private let shellMode: CaptureScreenShellMode

    @MainActor
    init(shellMode: CaptureScreenShellMode = .timeSupport) {
        self.shellMode = shellMode
        _viewModel = State(initialValue: CaptureViewModel())
    }

    init(
        shellMode: CaptureScreenShellMode,
        viewModel: CaptureViewModel
    ) {
        self.shellMode = shellMode
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .top) {
            LivingSurfaceBackground(context: .capture, state: captureLivingState, intensity: 0.68)
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                    Spacer()
                        .frame(height: 60)

                    capturePrompt

                    AtmosphereComposerCanvas(
                        inputText: Binding(
                            get: { viewModel.draftText },
                            set: { viewModel.updateDraftText($0) }
                        )
                    ) { text in
                        Task {
                            await viewModel.createQuickCapture(
                                captureService: featureFactory.captureService,
                                goalsService: featureFactory.goalsService
                            )
                        }
                    }

                    switch viewModel.state {
                    case .loading:
                        DegradedStateSurface(state: DegradedStateOrchestrator.objectLoading(.capturePlacementShelf))
                            .transition(.ambitionPanel)
                    case .failed:
                        DegradedStateSurface(
                            state: DegradedStateOrchestrator.objectUnavailable(.capturePlacementShelf),
                            primaryAccessibilityIdentifier: "capture.retry-button",
                            onPrimaryAction: {
                                Task { await load() }
                            }
                        )
                        .transition(.ambitionPanel)
                    case let .loaded(viewState):
                        if viewState.captures.isEmpty,
                           viewModel.draftRoutePreview == nil,
                           viewModel.actionMessage == nil {
                            loadedContent(viewState)
                                .transition(.ambitionPanel)
                        } else {
                            CaptureDepthDisclosureStage(
                                isExpanded: $isCaptureDepthExpanded
                            ) {
                                loadedContent(viewState)
                            }
                            .transition(.ambitionPanel)
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.lg)
                .padding(.top, theme.spacing.md)
                .padding(.bottom, theme.spacing.xl)
                .flagshipCaptureComposerStage(state: captureLivingState, summary: promptSubtitle)
            }
            .scrollIndicators(.hidden)

            ContextCrownHeader(
                title: "Capture",
                contextPhrase: promptSubtitle
            )
        }
        .navigationTitle("")
        .refreshable {
            await load()
        }
        .accessibilityIdentifier("capture.screen")
        .animation(theme.motion.animation(reduceMotion: reduceMotion, emphasis: true), value: viewModel.stateKey)
        .task {
            guard case .loading = viewModel.state else { return }
            await load()
        }
    }

    private var captureLivingState: LivingVisualState {
        if viewModel.actionMessage != nil {
            return .proof
        }
        if viewModel.draftRoutePreview != nil {
            return .active
        }
        if canSubmitDraft {
            return .active
        }
        return .empty
    }

    private var canSubmitDraft: Bool {
        viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    private func load() async {
        await viewModel.load(captureService: featureFactory.captureService, goalsService: featureFactory.goalsService)
    }

    private var capturePrompt: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text("Open Field")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(promptSubtitle)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            EvidenceLabel(
                "Open Field",
                detail: "Capture stays text-first and route choices stay editable after input.",
                source: "Capture",
                state: captureLivingState,
                context: .capture
            )

            if shellMode == .timeSupport {
                Button {
                    shell.navigation.resetTimePath()
                } label: {
                    Label("Time", systemImage: "calendar")
                }
                .buttonStyle(.bordered)
                .accessibilityIdentifier("capture.return-to-time")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("capture.prompt")
    }

    private var promptSubtitle: String {
        let draftIsEmpty = viewModel.draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if draftIsEmpty {
            switch shellMode {
            case .timeSupport:
                return "What needs placement? Type one real thing; placement appears only after input."
            case .topLevelCapture:
                return "Where does this belong? Open Field is the first stop. Move onward to Today, Goals, Time, or You when it is ready."
            }
        }
        return "Needs placement, Ready to Place, and Open as Goal stay editable. Nothing becomes planned work until you save it."
    }

    @ViewBuilder
    private func loadedContent(_ viewState: CaptureViewState) -> some View {
        if let routePreview = viewModel.draftRoutePreview {
            draftRoutePreviewStage(routePreview)
        }

        if let message = viewModel.actionMessage {
            captureReceiptPreview(message)
        }

        if viewState.captures.isEmpty, viewModel.draftRoutePreview == nil, viewModel.actionMessage == nil {
            emptyCaptureState
        } else if viewState.captures.isEmpty == false {
            LazyVStack(alignment: .leading, spacing: theme.spacing.lg) {
                SectionHeader(
                    eyebrow: "Capture",
                    title: "Continuity lines",
                    subtitle: "Placed, parked, and still-open captures stay in one Atmosphere Composer stage instead of separate buckets."
                )

                ForEach(orderedCaptures(viewState.captures)) { capture in
                    captureStageLine(capture, activeGoalOptions: viewState.activeGoalOptions)
                }
            }
        }
    }

    private struct CaptureDepthDisclosureStage<Content: View>: View {
        @Environment(\.ambitionTheme) private var theme

        @Binding var isExpanded: Bool
        let content: Content

        init(
            isExpanded: Binding<Bool>,
            @ViewBuilder content: () -> Content
        ) {
            _isExpanded = isExpanded
            self.content = content()
        }

        var body: some View {
            CaptureStageGroup(state: .calm, accessibilityIdentifier: "capture.depth-disclosure") {
                DisclosureGroup(isExpanded: $isExpanded) {
                    content
                        .padding(.top, theme.spacing.md)
                } label: {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text("Capture depth")
                            .font(theme.typography.section)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text("Open placed items, receipts, and parked capture only after the composer has taken input.")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .accessibilityElement(children: .contain)
        }
    }

    private var emptyCaptureState: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            DegradedStateSurface(
                state: DegradedStateOrchestrator.capturesEmpty(),
                primaryAccessibilityIdentifier: "capture.empty.start-here",
                secondaryAccessibilityIdentifier: "capture.empty.create-goal",
                onPrimaryAction: {
                    shell.commandRouter.route(to: .tab(.today), source: .shellCompose)
                },
                onSecondaryAction: {
                    shell.commandRouter.presentCreateGoal(source: .shellCompose)
                }
            )

            if shellMode == .topLevelCapture {
                CaptureFirstRunGuide()
            }
        }
        .accessibilityIdentifier("capture.empty")
    }

    private func captureReceiptPreview(_ message: CaptureActionMessage) -> some View {
        CaptureStageGroup(state: .proof, accessibilityIdentifier: "capture.receipt-preview") {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .top, spacing: theme.spacing.sm) {
                    ProofPulse(isActive: true, label: "Capture receipt saved")
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(message.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(message.body)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }
                EvidenceLabel(
                    "Receipt",
                    detail: message.body,
                    source: "Capture action",
                    state: .proof,
                    context: .capture
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func draftRoutePreviewStage(_ preview: CaptureDraftRoutePreview) -> some View {
        CaptureRouteStagePrimitive(preview: preview) { routeType in
            viewModel.selectDraftRoute(routeType)
        }
    }

    private func metadataText(for capture: Capture) -> String {
        var parts = [capture.kind.title, capture.route.title, capture.triageStatus.title]
        if let sourceType = capture.sourceType {
            parts.append(sourceLabel(for: sourceType))
        }
        if let deadlineText = capture.deadlineText { parts.append("Deadline \(deadlineText)") }
        if let contextLensHint = capture.contextLensHint { parts.append(contextLensHint.displayTitle) }
        if let revisitAfter = capture.revisitAfter {
            parts.append("Revisit after \(revisitAfter)")
        }
        parts.append(capture.updatedAt)
        return parts.joined(separator: " • ")
    }

    private func sourceLabel(for sourceType: CaptureSourceType) -> String {
        sourceType.title
    }

    private func orderedCaptures(_ captures: [Capture]) -> [Capture] {
        captures.sorted { lhs, rhs in
            captureStageRank(lhs) < captureStageRank(rhs)
        }
    }

    private func captureStageRank(_ capture: Capture) -> Int {
        switch capture.status {
        case .needsTriage, .actionable:
            return 0
        case .seed, .goalBound, .scheduled, .delegated:
            return 1
        case .waiting, .optionalSomeday, .archived:
            return 2
        }
    }

    private func captureStageLine(_ capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        CaptureStageGroup(state: livingState(for: capture), accessibilityIdentifier: "capture.stage-line.\(capture.id)") {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                Text(capture.rawText)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(metadataText(for: capture))
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("capture.metadata.\(capture.id)")

                if let assumption = capture.assumptionSummary {
                    captureTrustSeam(reason: assumption, source: capture.sourceType?.title ?? "Local capture")
                }

                placementReview(capture.placementReviewState, correction: capture.correctionReviewState)
                if canPromoteCaptureToGoal(capture) {
                    goalSeedIncubator(capture.goalSeedIncubatorState)
                }

                captureActions(for: capture, activeGoalOptions: activeGoalOptions)
            }
        }
    }

    private func livingState(for capture: Capture) -> LivingVisualState {
        switch capture.status {
        case .waiting, .optionalSomeday:
            return .stale
        case .archived:
            return .empty
        case .goalBound, .scheduled:
            return .proof
        case .needsTriage, .seed, .actionable, .delegated:
            return .active
        }
    }

    private func placementReview(
        _ review: CapturePlacementReviewState,
        correction: CaptureCorrectionReviewState
    ) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Divider()

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Label(review.title, systemImage: "tray.and.arrow.down")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                TagPill(review.placementStateTitle, state: review.state)
            }

            Label(review.destinationLabel, systemImage: "arrow.triangle.branch")
            Label(review.consequenceLabel, systemImage: "checkmark.seal")
            Label(review.privacyLabel, systemImage: "lock.shield")
            Label(review.confirmationLabel, systemImage: "hand.raised")
            Label(review.archiveLabel, systemImage: "archivebox")

            Label(correction.title, systemImage: "arrow.uturn.backward")
                .font(theme.typography.caption.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)
            Label(correction.routeCorrectionLabel, systemImage: "arrow.triangle.branch")
            Label(correction.notGoalLabel, systemImage: "target")
            Label(correction.notNowLabel, systemImage: "moon")
            Label(correction.receiptLabel, systemImage: "doc.text.magnifyingglass")
            Label(correction.learningBoundaryLabel, systemImage: "hand.raised")
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(review.title)
        .accessibilityValue([review.accessibilityValue, correction.accessibilityValue].joined(separator: ". "))
        .accessibilityIdentifier("capture.placement-review.\(review.id)")
    }

    private func goalSeedIncubator(_ state: CaptureGoalSeedIncubatorState) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Divider()

            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
                Label(state.title, systemImage: "seedling")
                    .font(theme.typography.caption.weight(.semibold))
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer()
                TagPill("Confirm first", state: state.state)
            }

            Label(state.whyGoalLabel, systemImage: "questionmark.circle")
            Label(state.startingPositionProofLabel, systemImage: "location")
            Label(state.firstMilestoneAnchorLabel, systemImage: "flag")
            Label(state.firstStepLabel, systemImage: "arrow.forward.circle")
            Label(state.proofSourceSeedLabel, systemImage: "doc.text.magnifyingglass")
            Label(state.promotionConfirmationLabel, systemImage: "hand.raised")
        }
        .font(theme.typography.caption)
        .foregroundStyle(theme.colors.textSecondary)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(state.title)
        .accessibilityValue(state.accessibilityValue)
        .accessibilityIdentifier("capture.goal-seed-incubator.\(state.id)")
    }

    private func captureTrustSeam(reason: String, source: String) -> some View {
        CaptureStageGroup(state: .calm, accessibilityIdentifier: "capture.route-trust") {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                EvidenceLabel(
                    "Why this?",
                    detail: reason,
                    source: source,
                    state: .calm,
                    context: .capture
                )

                Label("Review before saving; route choices stay editable.", systemImage: "hand.raised")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Capture route trust")
        .accessibilityValue("\(reason). Review before saving; route choices stay editable.")
    }

    @ViewBuilder
    private func captureActions(for capture: Capture, activeGoalOptions: [CaptureGoalOption]) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.routeToTime(
                            id: capture.id,
                            captureService: featureFactory.captureService,
                            goalsService: featureFactory.goalsService
                        )
                    }
                } label: {
                    Label("Ready to Place", systemImage: "checkmark.circle")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .scheduled) == false)

                Button {
                    shell.commandRouter.presentCreateGoal(
                        source: .capturesScreen,
                        seedText: capture.rawText,
                        captureID: capture.id
                    )
                } label: {
                    Label("Open as Goal", systemImage: "target")
                }
                .buttonStyle(.borderedProminent)
                .disabled(canPromoteCaptureToGoal(capture) == false)
                .accessibilityIdentifier("capture.new-goal.\(capture.id)")
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.saveToNeedsPlace(
                            id: capture.id,
                            captureService: featureFactory.captureService,
                            goalsService: featureFactory.goalsService
                        )
                    }
                } label: {
                    Label("Keep for review", systemImage: "tray.full")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .needsTriage) == false)

                Menu("Attach proof") {
                    if activeGoalOptions.isEmpty {
                        Text("No active goals")
                    } else {
                        ForEach(activeGoalOptions) { option in
                            Button(option.title) {
                                Task {
                                    if let target = await viewModel.attachToGoal(
                                        captureID: capture.id,
                                        goalID: option.id,
                                        goalTitle: option.title,
                                        captureService: featureFactory.captureService,
                                        goalsService: featureFactory.goalsService
                                    ) {
                                        openGoal(target)
                                    }
                                }
                            }
                        }
                    }
                }
                .disabled(capture.status.canTransition(to: .goalBound) == false || activeGoalOptions.isEmpty)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.markDeliverableSeed(
                            id: capture.id,
                            text: capture.rawText,
                            captureService: featureFactory.captureService,
                            goalsService: featureFactory.goalsService
                        )
                    }
                } label: {
                    Label("Idea", systemImage: "lightbulb")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .seed) == false)

                Button {
                    Task {
                        await viewModel.markWaiting(
                            id: capture.id,
                            captureService: featureFactory.captureService,
                            goalsService: featureFactory.goalsService
                        )
                    }
                } label: {
                    Label("Waiting", systemImage: "hourglass")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .waiting) == false)
            }

            HStack(spacing: theme.spacing.sm) {
                Button {
                    Task {
                        await viewModel.markOptionalSomeday(
                            id: capture.id,
                            captureService: featureFactory.captureService,
                            goalsService: featureFactory.goalsService
                        )
                    }
                } label: {
                    Label("Review later", systemImage: "moon")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .optionalSomeday) == false)

                Button {
                    Task {
                        await viewModel.archive(
                            id: capture.id,
                            captureService: featureFactory.captureService,
                            goalsService: featureFactory.goalsService
                        )
                    }
                } label: {
                    Label("Archive", systemImage: "archivebox")
                }
                .buttonStyle(.bordered)
                .disabled(capture.status.canTransition(to: .archived) == false)
            }
        }
        .font(theme.typography.caption)
    }

    private func openGoal(_ target: GoalRouteTarget) {
        guard let goalID = target.goalID else { return }
        shell.navigation.openGoalDetail(goalID: goalID, draftID: target.draftID)
    }

    private func canPromoteCaptureToGoal(_ capture: Capture) -> Bool {
        switch capture.status {
        case .needsTriage, .seed, .actionable:
            return true
        case .goalBound, .scheduled, .delegated, .archived:
            return false
        case .waiting, .optionalSomeday:
            return false
        }
    }

    private var shell: AppShellCapability {
        guard let appShellCapability else {
            preconditionFailure("App shell capability must be injected.")
        }
        return appShellCapability
    }

    private var featureFactory: AppFeatureFactoryCapability {
        guard let appFeatureFactoryCapability else {
            preconditionFailure("App feature factory capability must be injected.")
        }
        return appFeatureFactoryCapability
    }
}

private enum CaptureFirstRunGuideItem: String, CaseIterable, Identifiable {
    case captureAnything
    case startHere
    case createGoal
    case shapeTime
    case closeWithProof
    case inspectWhatAmbitionsKnows

    var id: String { rawValue }

    var title: String {
        switch self {
        case .captureAnything: "Open field"
        case .startHere: "Start here"
        case .createGoal: "Create goal"
        case .shapeTime: "Shape time"
        case .closeWithProof: "Close with proof"
        case .inspectWhatAmbitionsKnows: "Inspect what Ambitions knows"
        }
    }

    var detail: String {
        switch self {
        case .captureAnything:
            "Type one real thing in the composer."
        case .startHere:
            "Open Today when the thing needs one doable step."
        case .createGoal:
            "Use Goals when the thing needs a direction and a path."
        case .shapeTime:
            "Open Time when the thing needs room this week."
        case .closeWithProof:
            "Let Today and its receipts show what changed after the step is done."
        case .inspectWhatAmbitionsKnows:
            "Use You to review trust, receipts, and local settings."
        }
    }

    var icon: String {
        switch self {
        case .captureAnything: "tray.and.arrow.down"
        case .startHere: "sun.max"
        case .createGoal: "target"
        case .shapeTime: "calendar.badge.clock"
        case .closeWithProof: "checkmark.seal"
        case .inspectWhatAmbitionsKnows: "person.crop.circle"
        }
    }
}

private struct CaptureFirstRunGuide: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        CaptureStageGroup(state: .active, accessibilityIdentifier: "capture.empty.guide") {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "First run",
                    title: "How to operate life from Ambitions",
                    subtitle: "Capture is the first stop. The other objects stay nearby when the thing needs a step, a direction, room, or review."
                )

                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    ForEach(CaptureFirstRunGuideItem.allCases) { item in
                        HStack(alignment: .top, spacing: theme.spacing.sm) {
                            Image(systemName: item.icon)
                                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                                .foregroundStyle(theme.colors.textSecondary)
                                .frame(width: 20)
                                .accessibilityHidden(true)

                            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                                Text(item.title)
                                    .font(theme.typography.bodyEmphasized)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Text(item.detail)
                                    .font(theme.typography.caption)
                                    .foregroundStyle(theme.colors.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .contain)
    }
}

private extension NowContextLens {
    var displayTitle: String {
        switch self {
        case .work: "Work"
        case .personal: "Personal"
        case .freeTime: "Free Time"
        case .admin: "Admin"
        case .creative: "Creative"
        case .recovery: "Recovery"
        case .deepFocus: "Deep Focus"
        case .all: "All"
        }
    }
}

private extension CaptureScreenShellMode {
    var eyebrow: String {
        switch self {
        case .timeSupport: "Time support"
        case .topLevelCapture: "Top-level intake"
        }
    }

    var title: String {
        switch self {
        case .timeSupport: "Capture"
        case .topLevelCapture: "Capture"
        }
    }

    var subtitle: String {
        switch self {
        case .timeSupport:
            "Absorb raw inputs into the current week without turning Capture into a holding bin, raw activity stream, or classification board."
        case .topLevelCapture:
            "Open Field stays calm until a thought is ready to place, grow into a goal, or stay in Needs placement."
        }
    }
}

#if DEBUG
#Preview("Capture Empty") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.empty())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Route Suggestions") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Needs placement") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.needsPlace())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Manual Route") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.manualRoute())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Dynamic Type") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
    .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("Capture Reduce Motion") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Receipt") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.receipt())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.dark)
    .preferredColorScheme(.dark)
}

#Preview("Capture Light") {
    NavigationStack {
        CaptureScreen(shellMode: .topLevelCapture, viewModel: CapturePreviewFactory.routeSuggestions())
    }
    .appContainer(PreviewAppContainerFactory.preview)
    .ambitionTheme(.light)
    .preferredColorScheme(.light)
}

@MainActor
private enum CapturePreviewFactory {
    static func empty() -> CaptureViewModel {
        CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
    }

    static func routeSuggestions() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [
            CaptureGoalOption(id: "goal-music", title: "Music Goal", subtitle: "Creative")
        ])))
        viewModel.updateDraftText("Finish lyrics before rehearsal")
        return viewModel
    }

    static func needsPlace() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        return viewModel
    }

    static func manualRoute() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.updateDraftText("NASA")
        viewModel.selectDraftRoute(.task)
        return viewModel
    }

    static func receipt() -> CaptureViewModel {
        let viewModel = CaptureViewModel(state: .loaded(CaptureViewState(captures: [], activeGoalOptions: [])))
        viewModel.actionMessage = CaptureActionMessage(
            title: "Saved as Task · Today",
            body: "This can become plan work later; no calendar event was created."
        )
        return viewModel
    }
}
#endif
