import SwiftUI

public struct CaptureNativeCalibrationView: View {
    private let fixture: CaptureNativeCalibrationFixture
    @Binding private var state: CaptureNativeCalibrationJourneyState
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @AccessibilityFocusState private var originCaptureFocused: Bool

    public init(
        fixture: CaptureNativeCalibrationFixture,
        state: Binding<CaptureNativeCalibrationJourneyState>
    ) {
        self.fixture = fixture
        _state = state
    }

    public var body: some View {
        presentationHost
            .onChange(of: state.focusAnchor, initial: true) { _, anchor in
                originCaptureFocused = state.isPresented == false
                    && anchor == .originCaptureTrigger
            }
    }

    @ViewBuilder
    private var presentationHost: some View {
        #if os(iOS)
        origin
            .fullScreenCover(isPresented: presentation) {
                CaptureNativeCalibrationPassage(
                    fixture: fixture,
                    state: $state
                )
                .dynamicTypeSize(dynamicTypeSize)
                .interactiveDismissDisabled()
            }
        #else
        ZStack {
            origin
            if state.isPresented {
                CaptureNativeCalibrationPassage(
                    fixture: fixture,
                    state: $state
                )
            }
        }
        #endif
    }

    private var presentation: Binding<Bool> {
        Binding(
            get: { state.isPresented },
            set: { isPresented in
                if isPresented == false {
                    state.dismissCapture()
                }
            }
        )
    }

    private var origin: some View {
        ZStack {
            CaptureNativeCalibrationPalette(
                colorScheme: .dark,
                contrast: .standard
            )
            .canvas
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 28) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(state.origin.rootIdentity)
                        .font(.largeTitle.weight(.semibold))
                    Text("Your day remains here while Capture is open.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("cnc-origin-chrome")

                Button {
                    _ = state.presentCapture()
                } label: {
                    Label(state.origin.initiatingControl, systemImage: "square.and.pencil")
                        .font(.headline)
                        .frame(maxWidth: .infinity, minHeight: 52)
                }
                .buttonStyle(.borderedProminent)
                .tint(
                    CaptureNativeCalibrationPalette(
                        colorScheme: .dark,
                        contrast: .standard
                    ).accent
                )
                .accessibilityValue(
                    state.lastDismissedContext == nil ? "" : "Returned from Capture"
                )
                .accessibilityFocused($originCaptureFocused)
                .accessibilityIdentifier("cnc-origin-capture-trigger")

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
        }
        .foregroundStyle(.white)
        .accessibilityHidden(state.isPresented)
    }
}

private struct CaptureNativeCalibrationPassage: View {
    let fixture: CaptureNativeCalibrationFixture
    @Binding var state: CaptureNativeCalibrationJourneyState

    var body: some View {
        NavigationStack(path: navigationPath) {
            CaptureNativeCalibrationRoot(
                fixture: fixture,
                state: $state
            )
            .navigationDestination(for: CaptureNativeCalibrationRoute.self) { route in
                switch route {
                case .review:
                    CaptureNativeCalibrationReviewDepth(
                        fixture: fixture,
                        state: $state
                    )
                }
            }
        }
        .confirmationDialog(
            "Close Capture?",
            isPresented: closeConfirmation,
            titleVisibility: .visible
        ) {
            Button("Keep Editing") {
                state.keepEditing()
            }
            Button("Discard and Close", role: .destructive) {
                state.discardAndClose()
            }
        } message: {
            Text("Your words will be discarded from this Capture session.")
        }
    }

    private var navigationPath: Binding<[CaptureNativeCalibrationRoute]> {
        Binding(
            get: { state.navigationPath },
            set: { state.restoreNavigationPath($0) }
        )
    }

    private var closeConfirmation: Binding<Bool> {
        Binding(
            get: { state.isCloseConfirmationPresented },
            set: { isPresented in
                if isPresented == false, state.isCloseConfirmationPresented {
                    state.keepEditing()
                }
            }
        )
    }
}

private enum CaptureNativeCalibrationInputFocus: Hashable {
    case expression
    case clarification
}

private struct CaptureNativeCalibrationRoot: View {
    let fixture: CaptureNativeCalibrationFixture
    @Binding var state: CaptureNativeCalibrationJourneyState

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var inputFocus: CaptureNativeCalibrationInputFocus?
    @AccessibilityFocusState private var boundedReviewFocused: Bool
    @AccessibilityFocusState private var recoveryContinueFocused: Bool

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    private var proposal: CaptureNativeCalibrationProposal {
        fixture.proposal(
            for: state.expression,
            clarification: state.clarificationResponse
        ) ?? fixture.proposal
    }

    var body: some View {
        VStack(spacing: 0) {
            captureChrome
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
            content
        }
        .background(palette.canvas.ignoresSafeArea(.container))
        .foregroundStyle(palette.primary)
        .captureNativeCalibrationHideNavigationBar()
        .onAppear {
            focusForCurrentAnchor()
        }
        .onChange(of: state.focusAnchor) { _, _ in
            focusForCurrentAnchor()
        }
    }

    private var captureChrome: some View {
        HStack(alignment: .center, spacing: 16) {
            Text("Capture")
                .font(.title2.weight(.semibold))
                .accessibilityAddTraits(.isHeader)
                .accessibilityIdentifier("cnc-capture-identity")

            Spacer(minLength: 8)

            Button("Cancel") {
                inputFocus = nil
                _ = state.requestCancel()
            }
            .font(.body.weight(.semibold))
            .foregroundStyle(palette.accent)
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityIdentifier("cnc-capture-cancel")
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(palette.canvas)
    }

    @ViewBuilder
    private var content: some View {
        switch state.phase {
        case .expression:
            expressionState
        case .boundedMeaning:
            boundedMeaningState
        case .clarification:
            clarificationState
        case .recovery:
            recoveryState
        }
    }

    private var expressionState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Write it in your own words.")
                    .font(.body)
                    .foregroundStyle(palette.secondary)
                    .accessibilityIdentifier("cnc-capture-helper")

                ZStack(alignment: .topLeading) {
                    if state.expression.isEmpty {
                        Text("What do you want to capture?")
                            .font(.body)
                            .foregroundStyle(palette.secondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 15)
                            .accessibilityHidden(true)
                    }

                    TextEditor(text: expression)
                        .font(.body)
                        .foregroundStyle(palette.primary)
                        .scrollContentBackground(.hidden)
                        .focused($inputFocus, equals: .expression)
                        .frame(minHeight: 150, maxHeight: dynamicTypeSize.isAccessibilitySize ? 260 : 210)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 5)
                        .accessibilityLabel("What do you want to capture?")
                        .accessibilityValue(state.expression)
                        .accessibilityIdentifier("cnc-capture-expression-editor")
                }
                .background(palette.field, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                if state.expression.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                    Button("Continue") {
                        inputFocus = nil
                        _ = state.continueExpression(using: fixture)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("cnc-capture-expression-continue")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 22)
            .padding(.bottom, 20)
        }
        .captureNativeCalibrationNeverDismissesKeyboard()
        .accessibilityIdentifier("cnc-capture-expression-state")
    }

    private var expression: Binding<String> {
        Binding(
            get: { state.expression },
            set: { state.updateExpression($0) }
        )
    }

    private var boundedMeaningState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CaptureNativeCalibrationSection(
                    label: "Your words",
                    title: state.expression,
                    identifier: "cnc-meaning-original"
                )
                CaptureNativeCalibrationSection(
                    label: "What this could mean",
                    title: proposal.identity,
                    detail: "Related to \(proposal.relatedIdentity) · \(proposal.relatedTruth)",
                    identifier: "cnc-meaning-proposal"
                )
                CaptureNativeCalibrationSection(
                    label: "Destination",
                    title: proposal.destination,
                    detail: "Proposed, not added",
                    identifier: "cnc-meaning-destination"
                )

                CaptureNativeCalibrationActionGroup {
                    Button("Review") {
                        _ = state.openReview(using: fixture)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityFocused($boundedReviewFocused)
                    .accessibilityIdentifier("cnc-meaning-review")

                    Button("Change") {
                        state.changeWords()
                    }
                    .buttonStyle(.bordered)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("cnc-meaning-change")
                }
            }
        }
        .accessibilityIdentifier("cnc-capture-bounded-meaning")
    }

    private var clarificationState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CaptureNativeCalibrationSection(
                    label: "Your words",
                    title: state.expression,
                    identifier: "cnc-clarification-original"
                )

                VStack(alignment: .leading, spacing: 12) {
                    Text(CaptureNativeCalibrationFixture.clarificationQuestion)
                        .font(.title3.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("cnc-clarification-question")

                    TextField("Your answer", text: clarificationResponse, axis: .vertical)
                        .font(.body)
                        .lineLimit(1...4)
                        .padding(.horizontal, 14)
                        .frame(minHeight: 52)
                        .background(
                            palette.field,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                        .focused($inputFocus, equals: .clarification)
                        .submitLabel(.continue)
                        .accessibilityIdentifier("cnc-clarification-response")

                    if state.clarificationResponse
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty == false {
                        Button("Continue") {
                            inputFocus = nil
                            _ = state.continueClarification(using: fixture)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(palette.accent)
                        .frame(minHeight: 44)
                        .accessibilityIdentifier("cnc-clarification-continue")
                    }

                    Button("Change words") {
                        state.changeWords()
                    }
                    .buttonStyle(.bordered)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("cnc-clarification-change-words")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
            }
        }
        .captureNativeCalibrationNeverDismissesKeyboard()
        .accessibilityIdentifier("cnc-capture-clarification")
    }

    private var clarificationResponse: Binding<String> {
        Binding(
            get: { state.clarificationResponse },
            set: { state.updateClarificationResponse($0) }
        )
    }

    private var recoveryState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your draft is still here.")
                        .font(.title3.weight(.semibold))
                        .accessibilityAddTraits(.isHeader)
                    Text("Continue when you’re ready.")
                        .font(.body)
                        .foregroundStyle(palette.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 22)
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("cnc-recovery-message")
                .overlay(alignment: .bottom) {
                    Rectangle().fill(palette.separator).frame(height: 1)
                }

                CaptureNativeCalibrationSection(
                    label: "Your words",
                    title: state.expression,
                    detail: state.clarificationResponse.isEmpty
                        ? nil
                        : "Clarified: \(state.clarificationResponse)",
                    identifier: "cnc-recovery-original"
                )
                CaptureNativeCalibrationSection(
                    label: "Proposed in Goals",
                    title: proposal.identity,
                    detail: "\(proposal.relatedIdentity) · \(proposal.relatedTruth)",
                    identifier: "cnc-recovery-proposal"
                )

                CaptureNativeCalibrationActionGroup {
                    Button("Continue Review") {
                        _ = state.continueFromRecovery(using: fixture)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityFocused($recoveryContinueFocused)
                    .accessibilityIdentifier("cnc-recovery-continue")

                    Button("Keep Editing") {
                        state.changeWords()
                    }
                    .buttonStyle(.bordered)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("cnc-recovery-keep-editing")
                }
            }
        }
        .accessibilityIdentifier("cnc-capture-recovery")
    }

    private func focusForCurrentAnchor() {
        switch state.focusAnchor {
        case .expressionEditor:
            boundedReviewFocused = false
            recoveryContinueFocused = false
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(250))
                inputFocus = .expression
            }
        case .clarificationResponse:
            boundedReviewFocused = false
            recoveryContinueFocused = false
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(250))
                inputFocus = .clarification
            }
        case .boundedMeaningReview:
            inputFocus = nil
            boundedReviewFocused = true
        case .recoveryContinue:
            inputFocus = nil
            recoveryContinueFocused = true
        case .originCaptureTrigger, .reviewPrimaryAction:
            inputFocus = nil
        }
    }
}

private struct CaptureNativeCalibrationReviewDepth: View {
    let fixture: CaptureNativeCalibrationFixture
    @Binding var state: CaptureNativeCalibrationJourneyState

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @AccessibilityFocusState private var primaryActionFocused: Bool

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    private var proposal: CaptureNativeCalibrationProposal {
        fixture.proposal(
            for: state.expression,
            clarification: state.clarificationResponse
        ) ?? fixture.proposal
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                CaptureNativeCalibrationSection(
                    label: "Your words",
                    title: state.expression,
                    detail: state.clarificationResponse.isEmpty
                        ? nil
                        : "Clarified: \(state.clarificationResponse)",
                    identifier: "cnc-review-original"
                )
                CaptureNativeCalibrationSection(
                    label: "Proposed in Goals",
                    title: proposal.identity,
                    identifier: "cnc-review-proposal"
                )
                CaptureNativeCalibrationSection(
                    label: "Related context",
                    title: "\(proposal.relatedIdentity) · \(proposal.relatedTruth)",
                    identifier: "cnc-review-related"
                )
                CaptureNativeCalibrationSection(
                    label: "Current state",
                    title: proposal.currentState,
                    identifier: "cnc-review-current"
                )
                CaptureNativeCalibrationSection(
                    label: "Before anything changes",
                    title: proposal.consequence,
                    identifier: "cnc-review-consequence",
                    emphasizesTitle: false
                )

                CaptureNativeCalibrationActionGroup {
                    Button(proposal.primaryAction) {
                        state.recordFixtureOnlyHandoff()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityHint("Continues this proposal for review in Goals.")
                    .accessibilityFocused($primaryActionFocused)
                    .accessibilityIdentifier("cnc-review-continue-goals")

                    Button("Change") {
                        state.changeWords()
                    }
                    .buttonStyle(.bordered)
                    .tint(palette.accent)
                    .frame(minHeight: 44)
                    .accessibilityIdentifier("cnc-review-change")
                }
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primary)
        .navigationTitle("Review")
        .captureNativeCalibrationInlineNavigationTitle()
        .captureNativeCalibrationNavigationBarBackground(palette.canvas)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Cancel") {
                    _ = state.requestCancel()
                }
                .foregroundStyle(palette.accent)
                .accessibilityIdentifier("cnc-capture-cancel")
            }
        }
        .onAppear {
            primaryActionFocused = state.focusAnchor == .reviewPrimaryAction
        }
        .accessibilityIdentifier("cnc-capture-review")
    }
}

private struct CaptureNativeCalibrationSection: View {
    let label: String
    let title: String
    let detail: String?
    let identifier: String
    let emphasizesTitle: Bool

    init(
        label: String,
        title: String,
        detail: String? = nil,
        identifier: String,
        emphasizesTitle: Bool = true
    ) {
        self.label = label
        self.title = title
        self.detail = detail
        self.identifier = identifier
        self.emphasizesTitle = emphasizesTitle
    }

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondary)
            Text(title)
                .font(emphasizesTitle ? .title3.weight(.semibold) : .body)
                .fixedSize(horizontal: false, vertical: true)
            if let detail {
                Text(detail)
                    .font(.body)
                    .foregroundStyle(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue([title, detail].compactMap { $0 }.joined(separator: ". "))
        .accessibilityIdentifier(identifier)
        .overlay(alignment: .bottom) {
            Rectangle().fill(palette.separator).frame(height: 1)
        }
    }
}

private struct CaptureNativeCalibrationActionGroup<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
    }
}
