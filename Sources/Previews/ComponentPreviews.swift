#if canImport(SwiftUI)
import SwiftUI

private enum PreviewFilter: String, CaseIterable {
    case today = "Today"
    case week = "Week"
    case month = "Month"
}

private enum PreviewTab: String, CaseIterable {
    case today = "Today"
    case goals = "Goals"
    case plan = "Plan"
    case profile = "Profile"
}

private struct DesignSystemPreviewGallery: View {
    @State private var filter: PreviewFilter = .week
    @State private var tab: PreviewTab = .today

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HeroCard(state: .celebration) {
                    VStack(alignment: .leading, spacing: 16) {
                        AvatarHeader(title: "Ambitions", subtitle: "Design system foundation", initials: "A") {
                            TagPill("Premium", icon: "sparkles", state: .selected)
                        }
                        SectionHeader(eyebrow: "Hero", title: "Warm, calm, modular UI", subtitle: "Reusable shell for high-emphasis summaries.")
                        ProgressRail(title: "Readiness", progress: 0.78, trailingValue: "78%", state: .celebration)
                    }
                }

                SectionHeader(eyebrow: "Cards", title: "Shared Surfaces", subtitle: "Base shells for screens and compact modules.")

                AppCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("AppCard")
                            .font(.title3.weight(.semibold))
                        Text("Primary grouped surface for richer modules and screen sections.")
                            .foregroundStyle(.secondary)
                    }
                }

                HStack(spacing: 16) {
                    WidgetCard {
                        Text("WidgetCard")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    StatTile(title: "Consistency", value: "92%", detail: "7 day streak quality", icon: "waveform.path.ecg", state: .success)
                }

                SectionHeader(eyebrow: "Controls", title: "Interactive Primitives")
                SegmentedFilterBar(items: PreviewFilter.allCases, selection: $filter) { $0.rawValue }
                HStack {
                    TagPill("Default")
                    StatusChip("Success", icon: "checkmark.circle.fill", state: .success)
                    TagPill("Warning", icon: "exclamationmark.triangle.fill", state: .warning)
                    TagPill("Selected", icon: "checkmark.circle.fill", state: .selected)
                }

                HStack(spacing: 12) {
                    Button("Primary action") {}
                        .buttonStyle(AmbitionButtonStyle(tier: .hero, state: .selected))
                    Button("Secondary") {}
                        .buttonStyle(AmbitionButtonStyle(tier: .secondary))
                }

                AmbitionBand {
                    Image(systemName: "paintpalette")
                    Text("Band treatment carries lightweight continuity without turning every module into a heavy card.")
                        .font(.caption)
                }

                SectionHeader(eyebrow: "Batch 63", title: "Rich Panel Foundations", subtitle: "Canonical panel types with semantic state, action, explanation, and visual slots.")

                ForEach(AmbitionPanelKind.allCases) { kind in
                    AmbitionRichPanel(panelConfiguration(for: kind)) {
                        previewVisualSlot(for: kind)
                    } contentSlot: {
                        previewContentSlot(for: kind)
                    }
                }

                CompactChartShell(title: "CompactChartShell", subtitle: "Chart content drops into the shell later.") {
                    HStack(alignment: .bottom, spacing: 10) {
                        ForEach([0.35, 0.50, 0.44, 0.70, 0.58], id: \.self) { value in
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(LinearGradient(colors: [.mint.opacity(0.9), .orange.opacity(0.65)], startPoint: .top, endPoint: .bottom))
                                .frame(maxWidth: .infinity)
                                .frame(height: 100 * value)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }

                VStack(spacing: 16) {
                    EmptyStateCard(
                        title: "No insights yet",
                        message: "Use this when a module has no data but still needs calm structure.",
                        icon: "moon.stars"
                    )

                    LoadingSkeletonCard(lineCount: 4)
                    CelebrationBanner(title: "Momentum is compounding", subtitle: "Use this after wins, completed plans, or streak milestones.")
                }

                VStack(spacing: 12) {
                    ListChevronRow(
                        title: "Drill-in row",
                        subtitle: "Consistent navigation affordance",
                        leading: {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(.mint)
                        },
                        trailing: {
                            Text("4 items")
                                .foregroundStyle(.secondary)
                        },
                        action: {}
                    )

                    BottomNavShell(items: PreviewTab.allCases, selection: $tab, title: { $0.rawValue }, icon: { icon(for: $0) })
                }
            }
            .padding(24)
        }
        .ambitionTheme(.dark)
    }

    private func icon(for tab: PreviewTab) -> String {
        switch tab {
        case .today: "sun.max.fill"
        case .goals: "target"
        case .plan: "calendar"
        case .profile: "person.crop.circle"
        }
    }

    private func panelConfiguration(for kind: AmbitionPanelKind) -> AmbitionRichPanelConfiguration {
        AmbitionRichPanelConfiguration(
            kind: kind,
            title: panelTitle(for: kind),
            subtitle: "Reusable foundation for later surface batches without changing app behavior today.",
            semanticState: kind.defaultSemanticState,
            confidenceLabel: kind == .progress ? "Medium confidence" : nil,
            progressValue: kind == .progress ? 0.64 : nil,
            explanation: "State is paired with text, iconography, and accessibility values so color is never the only signal.",
            primaryAction: .init(id: "\(kind.rawValue)-primary", title: "Primary", role: .primary),
            secondaryAction: .init(id: "\(kind.rawValue)-why", title: "Why this", icon: "questionmark.circle", role: .tertiary)
        )
    }

    private func panelTitle(for kind: AmbitionPanelKind) -> String {
        switch kind {
        case .heroDecision: "Choose the next believable move"
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
    private func previewVisualSlot(for kind: AmbitionPanelKind) -> some View {
        switch kind {
        case .timeline:
            VStack(alignment: .leading, spacing: 10) {
                previewTimelineRow("Moved", detail: "Draft session shifted to a calmer window.")
                previewTimelineRow("Protected", detail: "Deep work kept outside the busy block.")
                previewTimelineRow("Recovered", detail: "Smaller version preserved momentum.")
            }
        case .schedule:
            HStack(spacing: 8) {
                ForEach(["9", "12", "3", "6"], id: \.self) { hour in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(hour == "3" ? Color.orange.opacity(0.55) : Color.teal.opacity(0.34))
                            .frame(height: hour == "3" ? 76 : 46)
                        Text(hour)
                            .font(.caption2)
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
    private func previewContentSlot(for kind: AmbitionPanelKind) -> some View {
        switch kind {
        case .capture:
            HStack {
                AmbitionChip("Raw", role: .capture)
                AmbitionChip("Plan seed", role: .domain)
                AmbitionChip("10 min", role: .time)
            }
        case .recovery:
            HStack {
                AmbitionChip("Smaller", role: .recovery)
                AmbitionChip("Later", role: .waiting)
                AmbitionChip("Protect", role: .protected)
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

    private func previewTimelineRow(_ title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.orange.opacity(0.8))
                .frame(width: 8, height: 8)
                .padding(.top, 5)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct DesignSystemPreviewGallery_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DesignSystemPreviewGallery()
                .previewDisplayName("Dark")

            DesignSystemPreviewGallery()
                .ambitionTheme(.light)
                .preferredColorScheme(.light)
                .previewDisplayName("Light Hook")
        }
    }
}
#endif
