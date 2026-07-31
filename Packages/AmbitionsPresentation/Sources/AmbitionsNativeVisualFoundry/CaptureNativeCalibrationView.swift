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
                case .clarification:
                    CaptureNativeCalibrationClarificationDepth(
                        fixture: fixture,
                        state: $state
                    )
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
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
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
        .padding(.bottom, 10)
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
            Color.clear
                .accessibilityHidden(true)
        case .recovery:
            recoveryState
        }
    }

    private var expressionState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Write it in your own words.")
                    .font(.body)
                    .foregroundStyle(palette.secondary)
                    .accessibilityIdentifier("cnc-capture-helper")

                ZStack(alignment: .topLeading) {
                    if state.expression.isEmpty {
                        Text("What do you want to capture?")
                            .font(.title3)
                            .foregroundStyle(palette.secondary)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 9)
                            .accessibilityHidden(true)
                    }

                    TextEditor(text: expression)
                        .font(.title3)
                        .foregroundStyle(palette.primary)
                        .scrollContentBackground(.hidden)
                        .focused($inputFocus, equals: .expression)
                        .frame(
                            minHeight: dynamicTypeSize.isAccessibilitySize ? 180 : 196,
                            maxHeight: dynamicTypeSize.isAccessibilitySize ? 280 : 236
                        )
                        .padding(.horizontal, -1)
                        .accessibilityLabel("What do you want to capture?")
                        .accessibilityValue(state.expression)
                        .accessibilityIdentifier("cnc-capture-expression-editor")
                }
                .padding(.horizontal, 3)
                .background(palette.editorRelief)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 20)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if state.expression.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
                CaptureNativeCalibrationActionRegion {
                    Button("Continue") {
                        inputFocus = nil
                        _ = state.continueExpression(using: fixture)
                    }
                    .buttonStyle(.plain)
                    .captureNativeCalibrationPrimaryAction()
                    .accessibilityIdentifier("cnc-capture-expression-continue")
                } secondary: {
                    EmptyView()
                }
            }
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
            VStack(alignment: .leading, spacing: 22) {
                CaptureNativeCalibrationOriginalExpression(
                    expression: state.expression,
                    clarification: state.clarificationResponse,
                    identifier: "cnc-meaning-original",
                    isPrimary: true
                )

                CaptureNativeCalibrationProposalFold(
                    proposal: proposal,
                    stateQualification: "Nothing has been added.",
                    identifier: "cnc-meaning-proposal"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CaptureNativeCalibrationActionRegion {
                Button("Review proposal") {
                    _ = state.openReview(using: fixture)
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationPrimaryAction()
                .accessibilityFocused($boundedReviewFocused)
                .accessibilityIdentifier("cnc-meaning-review")
            } secondary: {
                Button("Edit words") {
                    state.changeWords()
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationSecondaryAction()
                .accessibilityIdentifier("cnc-meaning-change")
            }
        }
        .accessibilityIdentifier("cnc-capture-bounded-meaning")
    }

    private var recoveryState: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Your draft is still here.")
                        .font(.title3.weight(.semibold))
                    Text("Continue when you’re ready.")
                        .font(.body)
                        .foregroundStyle(palette.secondary)
                }
                .padding(.leading, 16)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(palette.reliefEdge)
                        .frame(width: 3)
                }
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("cnc-recovery-message")

                CaptureNativeCalibrationRetainedDraft(
                    expression: state.expression,
                    clarification: state.clarificationResponse,
                    proposal: proposal
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CaptureNativeCalibrationActionRegion {
                Button("Continue review") {
                    _ = state.continueFromRecovery(using: fixture)
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationPrimaryAction()
                .accessibilityFocused($recoveryContinueFocused)
                .accessibilityIdentifier("cnc-recovery-continue")
            } secondary: {
                Button("Keep editing") {
                    state.changeWords()
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationSecondaryAction()
                .accessibilityIdentifier("cnc-recovery-keep-editing")
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
            inputFocus = nil
        case .boundedMeaningReview:
            inputFocus = nil
            boundedReviewFocused = voiceOverEnabled
        case .recoveryContinue:
            inputFocus = nil
            recoveryContinueFocused = voiceOverEnabled
        case .originCaptureTrigger, .reviewPrimaryAction:
            inputFocus = nil
        }
    }
}

private struct CaptureNativeCalibrationClarificationDepth: View {
    let fixture: CaptureNativeCalibrationFixture
    @Binding var state: CaptureNativeCalibrationJourneyState

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @FocusState private var inputFocus: CaptureNativeCalibrationInputFocus?

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CaptureNativeCalibrationOriginalExpression(
                    expression: state.expression,
                    clarification: "",
                    identifier: "cnc-clarification-original",
                    isPrimary: false
                )

                VStack(alignment: .leading, spacing: 14) {
                    Text(CaptureNativeCalibrationFixture.clarificationQuestion)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityIdentifier("cnc-clarification-question")

                    TextField("Your answer", text: clarificationResponse, axis: .vertical)
                        .font(.title3)
                        .lineLimit(1...4)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 10)
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(palette.reliefEdge)
                                .frame(height: 2)
                        }
                        .focused($inputFocus, equals: .clarification)
                        .submitLabel(.continue)
                        .accessibilityIdentifier("cnc-clarification-response")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CaptureNativeCalibrationActionRegion {
                Button("Continue") {
                    inputFocus = nil
                    _ = state.continueClarification(using: fixture)
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationPrimaryAction()
                .disabled(
                    state.clarificationResponse
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .isEmpty
                )
                .accessibilityIdentifier("cnc-clarification-continue")
            } secondary: {
                Button("Edit original words") {
                    state.changeWords()
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationSecondaryAction()
                .accessibilityIdentifier("cnc-clarification-change-words")
            }
        }
        .background(palette.canvas.ignoresSafeArea())
        .foregroundStyle(palette.primary)
        .navigationTitle("Clarify")
        .captureNativeCalibrationInlineNavigationTitle()
        .captureNativeCalibrationNavigationBarBackground(palette.canvas)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Cancel") {
                    inputFocus = nil
                    _ = state.requestCancel()
                }
                .foregroundStyle(palette.accent)
                .accessibilityIdentifier("cnc-capture-cancel")
            }
        }
        .captureNativeCalibrationNeverDismissesKeyboard()
        .onAppear {
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(250))
                inputFocus = .clarification
            }
        }
        .accessibilityIdentifier("cnc-capture-clarification")
    }

    private var clarificationResponse: Binding<String> {
        Binding(
            get: { state.clarificationResponse },
            set: { state.updateClarificationResponse($0) }
        )
    }
}

private struct CaptureNativeCalibrationReviewDepth: View {
    let fixture: CaptureNativeCalibrationFixture
    @Binding var state: CaptureNativeCalibrationJourneyState

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
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
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Proposed for Goals")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.secondary)
                    Text(proposal.identity)
                        .font(.title2.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Proposed for Goals")
                .accessibilityValue(proposal.identity)
                .accessibilityIdentifier("cnc-review-proposal")

                CaptureNativeCalibrationOriginalExpression(
                    expression: state.expression,
                    clarification: state.clarificationResponse,
                    identifier: "cnc-review-original",
                    isPrimary: false
                )

                Text("\(proposal.relatedIdentity) · \(proposal.relatedTruth)")
                    .font(.body)
                    .foregroundStyle(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityLabel("Related time")
                    .accessibilityValue("\(proposal.relatedIdentity). \(proposal.relatedTruth)")
                    .accessibilityIdentifier("cnc-review-related")

                VStack(alignment: .leading, spacing: 10) {
                    Text("Nothing has changed yet.")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Current state")
                        .accessibilityValue("Nothing has changed yet.")
                        .accessibilityIdentifier("cnc-review-current")

                    Text("Goals will review the proposal. The appointment stays at 9:30 AM.")
                        .font(.body)
                        .foregroundStyle(palette.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityLabel("Consequence")
                        .accessibilityValue(
                            "Goals will review the proposal. The appointment stays at 9:30 AM."
                        )
                        .accessibilityIdentifier("cnc-review-consequence")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(palette.relief, in: CaptureNativeCalibrationFoldShape())
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("cnc-review-truth-seam")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 28)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            CaptureNativeCalibrationActionRegion {
                Button(proposal.primaryAction) {
                    state.recordFixtureOnlyHandoff()
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationPrimaryAction()
                .accessibilityHint("Continues this proposal for review in Goals.")
                .accessibilityFocused($primaryActionFocused)
                .accessibilityIdentifier("cnc-review-continue-goals")
            } secondary: {
                Button("Edit proposal") {
                    state.changeWords()
                }
                .buttonStyle(.plain)
                .captureNativeCalibrationSecondaryAction()
                .accessibilityIdentifier("cnc-review-change")
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
            primaryActionFocused = voiceOverEnabled
                && state.focusAnchor == .reviewPrimaryAction
        }
        .accessibilityIdentifier("cnc-capture-review")
    }
}

private struct CaptureNativeCalibrationOriginalExpression: View {
    let expression: String
    let clarification: String
    let identifier: String
    let isPrimary: Bool

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text("Your words")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondary)
            Text(expression)
                .font(isPrimary ? .title2.weight(.medium) : .body)
                .fixedSize(horizontal: false, vertical: true)
            if clarification.isEmpty == false {
                Text("Clarified with: \(clarification)")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Your words")
        .accessibilityValue(
            [expression, clarification.isEmpty ? nil : "Clarified with: \(clarification)"]
                .compactMap { $0 }
                .joined(separator: ". ")
        )
        .accessibilityIdentifier(identifier)
    }
}

private struct CaptureNativeCalibrationProposalFold: View {
    let proposal: CaptureNativeCalibrationProposal
    let stateQualification: String
    let identifier: String

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text("Proposed for Goals")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.secondary)
            Text(proposal.identity)
                .font(.title3.weight(.semibold))
                .fixedSize(horizontal: false, vertical: true)
            Text("\(proposal.relatedIdentity) · \(proposal.relatedTruth)")
                .font(.body)
                .foregroundStyle(palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Text(stateQualification)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(palette.relief, in: CaptureNativeCalibrationFoldShape())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Proposed for Goals")
        .accessibilityValue(
            [
                proposal.identity,
                "\(proposal.relatedIdentity). \(proposal.relatedTruth)",
                stateQualification
            ].joined(separator: ". ")
        )
        .accessibilityIdentifier(identifier)
    }
}

private struct CaptureNativeCalibrationRetainedDraft: View {
    let expression: String
    let clarification: String
    let proposal: CaptureNativeCalibrationProposal

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            CaptureNativeCalibrationOriginalExpression(
                expression: expression,
                clarification: clarification,
                identifier: "cnc-recovery-original",
                isPrimary: false
            )

            VStack(alignment: .leading, spacing: 7) {
                Text("Proposed for Goals")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.secondary)
                Text(proposal.identity)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(proposal.relatedIdentity) · \(proposal.relatedTruth)")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Proposed for Goals")
            .accessibilityValue(
                "\(proposal.identity). \(proposal.relatedIdentity). \(proposal.relatedTruth)"
            )
            .accessibilityIdentifier("cnc-recovery-proposal")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(palette.relief, in: CaptureNativeCalibrationFoldShape())
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("cnc-recovery-draft")
    }
}

private struct CaptureNativeCalibrationActionRegion<Primary: View, Secondary: View>: View {
    @ViewBuilder let primary: () -> Primary
    @ViewBuilder let secondary: () -> Secondary

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.colorSchemeContrast) private var contrast
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var palette: CaptureNativeCalibrationPalette {
        CaptureNativeCalibrationPalette(colorScheme: colorScheme, contrast: contrast)
    }

    var body: some View {
        VStack(spacing: 0) {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(spacing: 4) {
                    primary()
                    secondary()
                }
            } else {
                HStack(spacing: 12) {
                    primary()
                    secondary()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(palette.actionRegion.ignoresSafeArea(edges: .bottom))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("cnc-capture-action-region")
    }
}

private struct CaptureNativeCalibrationFoldShape: Shape {
    func path(in rect: CGRect) -> Path {
        let corner: CGFloat = 14
        let notch: CGFloat = 18
        var path = Path()
        path.move(to: CGPoint(x: 0, y: notch))
        path.addLine(to: CGPoint(x: notch, y: notch))
        path.addLine(to: CGPoint(x: notch + 12, y: 0))
        path.addLine(to: CGPoint(x: rect.maxX - corner, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: corner),
            control: CGPoint(x: rect.maxX, y: 0)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - corner))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX - corner, y: rect.maxY),
            control: CGPoint(x: rect.maxX, y: rect.maxY)
        )
        path.addLine(to: CGPoint(x: corner, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: rect.maxY - corner),
            control: CGPoint(x: 0, y: rect.maxY)
        )
        path.closeSubpath()
        return path
    }
}
