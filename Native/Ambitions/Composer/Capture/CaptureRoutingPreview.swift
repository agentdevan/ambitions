import AmbitionsDesignSystem
import SwiftUI

struct CapturePlacementPreviewStrip: View {
    @Environment(\.ambitionTheme) private var theme
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let preview: CaptureDraftRoutePreview
    let onRouteChoice: (SmartAttachmentRouteType) -> Void
    let accessibilityIDs: CaptureAtmosphereComposerAccessibilityIDs

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(preview.postInputStateTitle)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                            .accessibilityIdentifier(accessibilityIDs.placementPreviewStrip)
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
                    "Placement check",
                    detail: preview.routeProofDetail,
                    source: preview.destinationLabel,
                    state: livingState,
                    context: .capture
                )

                EvidenceLabel(
                    "Review",
                    detail: preview.atmosphereComposerCompactInspectionSummary,
                    source: "Placement can change before saving",
                    state: livingState,
                    context: .capture
                )
                .accessibilityIdentifier(accessibilityIDs.placementInspectionSummary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, theme.spacing.sm)
        .padding(.leading, theme.spacing.sm)
        .background(alignment: .leading) {
            Rectangle()
                .fill(routeAccent.opacity(0.32))
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
        .accessibilityElement(children: .contain)
        .accessibilityLabel(preview.accessibilityLabel)
        .accessibilityValue([preview.accessibilityValue, preview.atmosphereComposerInspectionSummary].joined(separator: ". "))
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
            .accessibilityIdentifier("\(accessibilityIDs.placementChoicePrefix)\(choice.routeType.rawValue)")
            .accessibilityLabel(choice.title)
            .accessibilityValue(choice.isSelected ? "Selected placement" : "Available placement")
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

    private var routeAccent: Color {
        livingState == .empty ? LivingTabContext.capture.accent(in: theme) : theme.stateStyle(for: livingState.ambitionState).accent
    }
}
