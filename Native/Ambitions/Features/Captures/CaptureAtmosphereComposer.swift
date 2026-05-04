import AmbitionsDesignSystem
import SwiftUI

struct CaptureAtmosphereComposerPresentation: Equatable {
    let isRouteRevealVisible: Bool
    let placementTitle: String
    let destinationLabel: String
    let privacyLabel: String
    let evidenceTitle: String
    let evidenceDetail: String
    let accessibilityValue: String
    let submitLabel: String

    init(
        text: String,
        routePreview: CaptureDraftRoutePreview?,
        error: String?,
        isSubmitEnabled: Bool
    ) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        isRouteRevealVisible = routePreview != nil && trimmedText.isEmpty == false
        placementTitle = routePreview?.postInputStateTitle ?? (isSubmitEnabled ? "Ready to place" : "Needs a place")
        destinationLabel = routePreview?.destinationLabel ?? "Private intake"
        privacyLabel = routePreview?.privacyLabel ?? "Stored locally when saved"

        if let error {
            evidenceTitle = "Needs attention"
            evidenceDetail = error
        } else if let routePreview {
            evidenceTitle = routePreview.receiptTitle
            evidenceDetail = routePreview.consequenceLabel
        } else if isSubmitEnabled {
            evidenceTitle = "Ready to place"
            evidenceDetail = "Ambitions will suggest a route after you save."
        } else {
            evidenceTitle = "Needs a place"
            evidenceDetail = "Type one real thing; no inbox pressure is added."
        }

        accessibilityValue = [
            placementTitle,
            destinationLabel,
            privacyLabel,
            routePreview?.consequenceLabel,
            error
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
        submitLabel = isSubmitEnabled ? "Save capture" : "Save unavailable"
    }
}

struct CaptureAtmosphereComposer: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @FocusState private var isFocused: Bool

    @Binding var text: String

    let routePreview: CaptureDraftRoutePreview?
    let error: String?
    let isSubmitEnabled: Bool
    let onSubmit: () -> Void
    let onMicrophone: () -> Void
    let onRouteChoice: (SmartAttachmentRouteType) -> Void

    private var presentation: CaptureAtmosphereComposerPresentation {
        CaptureAtmosphereComposerPresentation(
            text: text,
            routePreview: routePreview,
            error: error,
            isSubmitEnabled: isSubmitEnabled
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            if presentation.isRouteRevealVisible, let routePreview {
                CaptureRouteRevealStrip(
                    preview: routePreview,
                    onRouteChoice: onRouteChoice
                )
                .transition(routeRevealTransition)
            }

            composerInput

            if let error {
                Text(error)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.warning)
                    .accessibilityIdentifier("captures.quick-error")
            }

            EvidenceLabel(
                presentation.evidenceTitle,
                detail: presentation.evidenceDetail,
                source: "Capture composer",
                state: composerState,
                context: .capture
            )
        }
        .padding(.horizontal, theme.spacing.lg)
        .padding(.top, theme.spacing.sm)
        .padding(.bottom, theme.spacing.sm)
        .background(.ultraThinMaterial)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.colors.strokeSubtle)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
        .animation(
            DAVMotionPreset.receiptConfirmation.animation(theme: theme, reduceMotion: reduceMotion),
            value: presentation.isRouteRevealVisible
        )
        .animation(
            DAVMotionPreset.receiptConfirmation.animation(theme: theme, reduceMotion: reduceMotion),
            value: isFocused
        )
        .accessibilityIdentifier("captures.composer")
        .accessibilityElement(children: .contain)
        .accessibilityValue(presentation.accessibilityValue)
    }

    private var composerInput: some View {
        let verticalLayout = dynamicTypeSize.isAccessibilitySize

        return Group {
            if verticalLayout {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    fieldCapsule
                    submitButton
                }
            } else {
                HStack(alignment: .bottom, spacing: theme.spacing.sm) {
                    fieldCapsule
                    submitButton
                }
            }
        }
    }

    private var fieldCapsule: some View {
        HStack(spacing: theme.spacing.sm) {
            TextField("What needs a place?", text: $text, axis: .vertical)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 2...5 : 1...3)
                .submitLabel(.done)
                .focused($isFocused)
                .onSubmit {
                    if isSubmitEnabled {
                        onSubmit()
                    }
                }
                .accessibilityIdentifier("captures.quick-input")
                .accessibilityLabel("What needs a place?")
                .accessibilityHint("Type a thought. Route suggestions appear after input.")

            Button(action: onMicrophone) {
                Image(systemName: "mic.fill")
                    .font(.system(size: theme.icon.smallSize, weight: .semibold))
                    .frame(width: 30, height: 30)
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.colors.textSecondary)
            .accessibilityIdentifier("captures.quick-mic")
            .accessibilityLabel("Voice capture")
            .accessibilityHint("Voice capture is not connected yet.")
        }
        .padding(.horizontal, theme.spacing.md)
        .padding(.vertical, theme.spacing.sm)
        .background(fieldBackground)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .stroke(isFocused ? theme.colors.accentWarm : theme.colors.strokeSubtle, lineWidth: isFocused ? 1.5 : 1)
        )
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var fieldBackground: some View {
        ZStack {
            ContextAtmosphereLayer(
                context: .capture,
                state: composerState,
                intensity: isFocused ? 0.5 : 0.38
            )
            RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.92))
        }
    }

    private var submitButton: some View {
        Button(action: onSubmit) {
            Image(systemName: "plus")
                .font(.system(size: theme.icon.smallSize, weight: .bold))
                .frame(width: 42, height: 42)
        }
        .buttonStyle(AmbitionPressableButtonStyle(state: isSubmitEnabled ? .selected : .disabled))
        .disabled(isSubmitEnabled == false)
        .accessibilityIdentifier("captures.quick-submit")
        .accessibilityLabel(presentation.submitLabel)
        .accessibilityHint(isSubmitEnabled ? "Saves the capture and keeps the route editable." : "Type a thought first.")
    }

    private var composerState: LivingVisualState {
        if error != nil { return .stale }
        if routePreview != nil || isSubmitEnabled { return .active }
        return .empty
    }

    private var routeRevealTransition: AnyTransition {
        reduceMotion ? .opacity : .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .opacity
        )
    }
}

private struct CaptureRouteRevealStrip: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let preview: CaptureDraftRoutePreview
    let onRouteChoice: (SmartAttachmentRouteType) -> Void

    var body: some View {
        StateDrivenMaterialPanel(context: .capture, state: livingState) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(preview.postInputStateTitle)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(preview.consequenceLabel)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: theme.spacing.sm)
                    AmbitionChip(preview.privacyLabel, role: .protected, semanticState: .trust)
                }

                routeChoiceRow

                EvidenceLabel(
                    preview.routeProofTitle,
                    detail: preview.routeProofDetail,
                    source: "Local capture text",
                    state: livingState,
                    context: .capture
                )
            }
        }
        .accessibilityIdentifier("captures.route-reveal-strip")
        .accessibilityElement(children: .contain)
        .accessibilityLabel(preview.accessibilityLabel)
        .accessibilityValue(preview.accessibilityValue)
        .accessibilityHint(preview.accessibilityHint ?? "Choose a route or save the suggested placement.")
    }

    private var routeChoiceRow: some View {
        let verticalLayout = dynamicTypeSize.isAccessibilitySize

        return Group {
            if verticalLayout {
                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    routeChoiceButtons
                }
            } else {
                HStack(spacing: theme.spacing.xs) {
                    routeChoiceButtons
                }
            }
        }
    }

    @ViewBuilder
    private var routeChoiceButtons: some View {
        ForEach(preview.choices) { choice in
            Button {
                onRouteChoice(choice.routeType)
            } label: {
                Label(choice.title, systemImage: choice.isSelected ? "checkmark.circle.fill" : "circle")
                    .font(theme.typography.caption)
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .accessibilityIdentifier("captures.route-choice.\(choice.routeType.rawValue)")
            .accessibilityLabel(choice.title)
            .accessibilityValue(choice.isSelected ? "Selected route" : "Available route")
        }
    }

    private var livingState: LivingVisualState {
        switch preview.semanticState {
        case "savedToNeedsPlace", "needsClarification":
            return .stale
        case "failedSafely":
            return .stale
        default:
            return .active
        }
    }
}

#Preview("SI09 Capture Atmosphere Composer") {
    @Previewable @State var text = "Book dentist before Friday"
    let preview = CaptureDraftRoutePreview(
        originalText: "Book dentist before Friday",
        postInputStateTitle: "Suggested Place",
        receiptTitle: "Saved as Task · Today",
        summary: "Looks like a standalone task.",
        routeProofTitle: "Route evidence",
        routeProofDetail: "Local text only; no calendar, network, account, or cloud route.",
        destinationLabel: "Today",
        objectTypeLabel: "Task",
        appearanceLabel: "Today",
        consequenceLabel: "Adds a visible Task to Today after you confirm.",
        privacyLabel: "Private item",
        primaryActionTitle: "Place it",
        changeActionTitle: "Change",
        safeActionTitle: "Decide later",
        semanticState: "savedStandalone",
        clarificationQuestion: nil,
        choices: [
            CaptureDraftRouteChoice(id: "task", title: "Task", routeType: .task, isSelected: true),
            CaptureDraftRouteChoice(id: "goal", title: "Goal", routeType: .goal, isSelected: false),
            CaptureDraftRouteChoice(id: "idea", title: "Needs a Place", routeType: .idea, isSelected: false)
        ],
        accessibilityLabel: "Suggested capture route",
        accessibilityValue: "Task, Today, private item",
        accessibilityHint: "Choose a route or save the suggested placement."
    )

    return CaptureAtmosphereComposer(
        text: $text,
        routePreview: preview,
        error: nil,
        isSubmitEnabled: true,
        onSubmit: {},
        onMicrophone: {},
        onRouteChoice: { _ in }
    )
    .padding()
    .background(LivingSurfaceBackground(context: .capture, state: .active))
}
