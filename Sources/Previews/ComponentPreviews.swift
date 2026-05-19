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
    case time = "Time"
    case profile = "You"
}

private struct DesignSystemPreviewGallery: View {
    @State private var filter: PreviewFilter = .week
    @State private var tab: PreviewTab = .today
    @State private var privateItems = true
    @State private var notifications = false

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
                    StatTile(title: "Consistency", value: "92%", detail: "7 day rhythm quality", icon: "waveform.path.ecg", state: .success)
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

                SectionHeader(eyebrow: "v2", title: "Adaptive System Panels", subtitle: "Canonical wrappers for grounded context, step recommendations, duration labels, and closure check-ins.")

                HeroStepPanel(
                    title: "Write the chorus",
                    subtitle: "You have open creative time before your next commitment.",
                    primaryActionTitle: "Start now",
                    content: {
                        HStack {
                            TimeContextBadge("Free time · 1h 20m open", sourceLabel: "Based on your schedule", state: .selected)
                            DurationBadge("30 min planned")
                        }
                    }
                )

                ClosureCheckInPanel(subtitle: "Yesterday has 2 loose ends. Review them without turning the day into a stale list.") {
                    HStack {
                        StatusChip("Still Counts", state: .success)
                        StatusChip("Rescheduled", state: .warning)
                        StatusChip("Waiting", state: .default)
                    }
                }

                AmbitionBand {
                    Image(systemName: "paintpalette")
                    Text("Band treatment carries lightweight continuity without turning every module into a heavy card.")
                        .font(.caption)
                }

                SectionHeader(eyebrow: "D03", title: "Grouped Navigation List", subtitle: "Settings-style grouped rows for secondary navigation, preferences, status, and caller-confirmed destructive actions.")

                GroupedNavigationList {
                    GroupedNavigationSection(title: "Privacy", footer: "Destructive actions open a confirmation step owned by the caller.") {
                        GroupedDisclosureNavigationRow(
                            title: "You are in control",
                            subtitle: "Review settings and history.",
                            systemImage: "person.crop.circle",
                            trailingValue: "3 areas",
                            accessibilityHint: "Opens control settings.",
                            action: {}
                        )

                        GroupedStatusNavigationRow(
                            title: "What Ambitions knows",
                            subtitle: "Review saved context.",
                            systemImage: "checkmark.shield",
                            value: "Local",
                            state: .trust,
                            accessibilityHint: "Shows where saved context is stored.",
                            action: {}
                        )

                        GroupedPreferenceRow(
                            title: "Private item",
                            subtitle: "Hide details in shared views.",
                            systemImage: "lock",
                            isOn: $privateItems,
                            accessibilityHint: "Turns private display on or off."
                        )

                        GroupedDestructiveActionRow(
                            title: "Delete review history",
                            subtitle: "Starts a confirmation step before anything changes.",
                            systemImage: "trash",
                            accessibilityHint: "Opens delete confirmation.",
                            action: {}
                        )
                    }

                    GroupedNavigationSection(title: "Settings") {
                        GroupedNavigationRow(
                            title: "Appearance",
                            subtitle: "Color and display preferences.",
                            systemImage: "paintpalette",
                            trailingValue: "Balanced",
                            action: {}
                        )

                        GroupedPreferenceRow(
                            title: "Notifications",
                            subtitle: "Choose what should interrupt you.",
                            systemImage: "bell",
                            isOn: $notifications,
                            accessibilityHint: "Turns notification preferences on or off."
                        )

                        GroupedStatusNavigationRow(
                            title: "Accessibility",
                            subtitle: "Text size and motion preferences.",
                            systemImage: "accessibility",
                            value: "Review",
                            state: .accessibilityUnverified,
                            action: {}
                        )

                        GroupedDisclosureNavigationRow(
                            title: "Review history",
                            subtitle: "Open past reviews and receipts.",
                            systemImage: "clock.arrow.circlepath",
                            badge: .init("Receipts", icon: "doc.text", state: .review),
                            action: {}
                        )
                    }
                }

                SectionHeader(eyebrow: "D04", title: "Panel Size + Display Density", subtitle: "Shared comfort foundation. Required information stays visible while extra detail can collapse.")

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 220), spacing: 12, alignment: .top)],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(AmbitionDisplayDensity.allCases) { density in
                        ForEach(AmbitionPanelSize.allCases) { size in
                            panelDensityMatrixTile(
                                configuration: .init(density: density, size: size)
                            )
                        }
                    }
                }

                SectionHeader(eyebrow: "Batch 63", title: "Rich Panel Foundations", subtitle: "Canonical panel types with semantic state, action, explanation, and visual slots.")

                SectionHeader(eyebrow: "SI02", title: "Adaptive Panel + Action Foundation", subtitle: "Shared Signature Interface primitives for module shells, action hierarchy, loading, disabled, privacy, and Dynamic Type lanes.")

                AdaptivePanel(
                    .init(
                        emphasis: .orientation,
                        title: "Start with the one thing that keeps the day together",
                        subtitle: "A calm module shell for future Today, Goals, Capture, Time, and You surfaces.",
                        status: "Ready",
                        accessibilityHint: "Reviews the primary orientation module."
                    )
                ) {
                    VStack(alignment: .leading, spacing: 12) {
                        AmbitionBand {
                            Image(systemName: "checkmark.seal")
                            Text("State is carried by text, symbol, and structure, not color alone.")
                                .font(.caption)
                        }

                        HStack(spacing: 12) {
                            AmbitionsActionButton("Start here", icon: "arrow.right.circle.fill", role: .primary) {}
                            QuietActionButton("Why this", icon: "questionmark.circle") {}
                        }
                    }
                }

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 220), spacing: 12, alignment: .top)],
                    alignment: .leading,
                    spacing: 12
                ) {
                    AdaptivePanel(.init(emphasis: .proof, title: "Proof saved", status: "Proof")) {
                        AmbitionChip("Local receipt", role: .state, semanticState: .trust)
                    }

                    AdaptivePanel(.init(emphasis: .source, title: "Private source", status: "Private", isPrivacySensitive: true)) {
                        AmbitionChip("Inspectable", role: .protected)
                    }

                    AdaptivePanel(.init(emphasis: .action, title: "Finding the safest action", isLoading: true))

                    AdaptivePanel(.init(emphasis: .recovery, title: "Recovery option paused", status: "Disabled", isDisabled: true)) {
                        AmbitionsActionButton("Still counts", role: .recovery) {}
                    }
                }

                AmbitionsInAppModule(
                    title: "Module shell",
                    subtitle: "For future owned Ambitions modules, not equal-weight dashboard cards.",
                    emphasis: .quiet
                ) {
                    HStack {
                        AmbitionChip("Reduced Motion safe", role: .state, semanticState: .accessibilityVerified)
                        AmbitionChip("44 pt targets", role: .state, semanticState: .accessibilityVerified)
                    }
                }

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
                    CelebrationBanner(title: "Momentum is compounding", subtitle: "Use this after wins, completed steps, or rhythm milestones.")
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
        case .time: "clock"
        case .profile: "person.crop.circle"
        }
    }

    private func panelConfiguration(for kind: AmbitionPanelKind) -> AmbitionRichPanelConfiguration {
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

    private func panelTitle(for kind: AmbitionPanelKind) -> String {
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
    private func previewVisualSlot(for kind: AmbitionPanelKind) -> some View {
        switch kind {
        case .timeline:
            VStack(alignment: .leading, spacing: 10) {
            previewTimelineRow("Rescheduled", detail: "Draft session shifted to a calmer window.")
                previewTimelineRow("Kept", detail: "Deep work stayed outside the busy block.")
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

    private func panelDensityMatrixTile(
        configuration: AmbitionPanelDisplayConfiguration
    ) -> some View {
        let required = AmbitionTheme.dark.panelDisplayDecision(
            for: .todayPlan,
            configuration: configuration
        )
        let optional = AmbitionTheme.dark.panelDisplayDecision(
            for: .optional,
            configuration: configuration
        )

        return WidgetCard {
            VStack(alignment: .leading, spacing: required.metrics.verticalSpacing) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(configuration.density.title)
                            .font(.headline.weight(.semibold))
                        Text(configuration.size.title)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    AmbitionChip(
                        required.visibility.previewTitle,
                        role: .state,
                        semanticState: .trust
                    )
                }

                Text("Required information stays visible.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if required.showsSupportingDetail {
                    Text("Looks doable.")
                        .font(.caption.weight(.semibold))
                }

                if optional.visibility == .hidden {
                    Text("Extra detail hidden.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                } else {
                    Text(optional.visibility == .full ? "More detail shown." : "Extra detail summarized.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Button("Make today doable") {}
                    .buttonStyle(AmbitionButtonStyle(tier: .compact, state: .selected))
                    .frame(minHeight: required.metrics.minimumTapTarget)
            }
            .padding(required.metrics.panelPadding)
            .ambitionPanelDisplayConfiguration(configuration)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(configuration.density.title), \(configuration.size.title)")
            .accessibilityValue("Required information stays visible. \(optional.visibility.previewAccessibilityText)")
        }
    }
}

private extension AmbitionPanelVisibility {
    var previewTitle: String {
        switch self {
        case .full: "Full"
        case .summarized: "Summary"
        case .collapsedSignal: "Signal"
        case .hidden: "Hidden"
        }
    }

    var previewAccessibilityText: String {
        switch self {
        case .full: "Extra detail is shown."
        case .summarized: "Extra detail is summarized."
        case .collapsedSignal: "Extra detail uses a signal."
        case .hidden: "Extra detail is hidden."
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

            DesignSystemPreviewGallery()
                .environment(\.dynamicTypeSize, .accessibility3)
                .previewDisplayName("SI02 High Dynamic Type")
        }
    }
}
#endif
