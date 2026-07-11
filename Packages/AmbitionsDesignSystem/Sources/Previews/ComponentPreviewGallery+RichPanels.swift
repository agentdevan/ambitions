#if canImport(SwiftUI)
import SwiftUI

extension DesignSystemPreviewGallery {
    func panelConfiguration(for kind: AmbitionPanelKind) -> AmbitionRichPanelConfiguration {
        AmbitionRichPanelConfiguration(
            kind: kind,
            title: panelTitle(for: kind),
            subtitle: "Reusable foundation for later surface batches without changing app behavior today.",
            semanticState: kind.defaultSemanticState,
            confidenceLabel: kind == .progress ? "Useful signal" : nil,
            progressValue: kind == .progress ? 0.64 : nil,
            explanation: "State is paired with text, iconography, and accessibility values so color is never the only signal.",
            primaryAction: .init(id: "\(kind.rawValue)-primary", title: "Primary", role: .primary),
            secondaryAction: .init(id: "\(kind.rawValue)-why", title: "Why this", icon: "questionmark.circle", role: .tertiary)
        )
    }

    func panelTitle(for kind: AmbitionPanelKind) -> String {
        switch kind {
        case .heroDecision: "Choose the recommended step"
        case .progress: "Pace is holding"
        case .timeline: "Three recent changes"
        case .schedule: "Open window later today"
        case .insight: "Capacity is the constraint"
        case .recovery: "Recover without rewriting the day"
        case .trust: "Based on local plan evidence"
        case .capture: "Triage this capture"
        case .review: "What changed this week"
        case .settingsPreference: "Calendar-aware planning"
        }
    }

    @ViewBuilder
    func previewVisualSlot(for kind: AmbitionPanelKind) -> some View {
        switch kind {
        case .timeline:
            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                previewTimelineRow("Rescheduled", detail: "Draft session shifted to a calmer window.")
                previewTimelineRow("Kept", detail: "Deep work stayed outside the busy block.")
                previewTimelineRow("Recovered", detail: "Smaller version preserved momentum.")
            }
        case .schedule:
            HStack(spacing: theme.spacing.xxs) {
                ForEach(["9", "12", "3", "6"], id: \.self) { hour in
                    VStack(spacing: theme.spacing.xxxs) {
                        RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                            .fill(hour == "3" ? theme.colors.warning.opacity(0.55) : theme.colors.accentSecondary.opacity(0.34))
                            .frame(height: hour == "3" ? 76 : 46)
                        Text(hour)
                            .font(theme.typography.micro)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        case .progress:
            ProgressRail(title: "Believable pace", progress: 0.64, trailingValue: "64%", state: .selected)
        default:
            EmptyView()
        }
    }

    @ViewBuilder
    func previewContentSlot(for kind: AmbitionPanelKind) -> some View {
        switch kind {
        case .capture:
            HStack {
                AmbitionChip("Raw", role: .capture)
                AmbitionChip("Schedule idea", role: .domain)
                AmbitionChip("10 min", role: .time)
            }
        case .recovery:
            HStack {
                AmbitionChip("Smaller", role: .recovery)
                AmbitionChip("Later", role: .waiting)
                AmbitionChip("Keep", role: .protected)
            }
        case .trust:
            HStack {
                AmbitionChip("Local", role: .state, semanticState: .trust)
                AmbitionChip("Not synced", role: .state, semanticState: .waiting)
            }
        default:
            EmptyView()
        }
    }

    func previewTimelineRow(_ title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: theme.spacing.xxs) {
            Circle()
                .fill(theme.colors.warning.opacity(0.8))
                .frame(width: 8, height: 8)
                .padding(.top, theme.spacing.xxxs + 1)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.caption.weight(.semibold))
                Text(detail)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }
}
#endif
