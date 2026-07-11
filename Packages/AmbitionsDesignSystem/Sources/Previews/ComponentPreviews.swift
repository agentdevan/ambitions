#if canImport(SwiftUI)
import SwiftUI

struct DesignSystemPreviewGallery: View {
    @Environment(\.ambitionTheme) var theme
    @State private var filter: ComponentPreviewFilter = .week
    @State private var selectedSurface: ComponentPreviewRootSurface = .today
    @State private var privateItems = true
    @State private var notifications = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                HeroCard(state: .celebration) {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        AvatarHeader(title: "Ambitions", subtitle: "Design system foundation", initials: "A") {
                            TagPill("Premium", icon: "sparkles", state: .selected)
                        }
                        SectionHeader(eyebrow: "Hero", title: "Warm, calm, modular UI", subtitle: "Reusable shell for high-emphasis summaries.")
                        ProgressRail(title: "Readiness", progress: 0.78, trailingValue: "78%", state: .celebration)
                    }
                }

                SectionHeader(eyebrow: "Cards", title: "Shared Surfaces", subtitle: "Base shells for screens and compact modules.")

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text("AppCard")
                            .font(theme.typography.titleCompact)
                        Text("Primary grouped surface for richer modules and screen sections.")
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                }

                HStack(spacing: theme.spacing.sm) {
                    WidgetCard {
                        Text("WidgetCard")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    StatTile(title: "Consistency", value: "92%", detail: "7 day rhythm quality", icon: "waveform.path.ecg", state: .success)
                }

                SectionHeader(eyebrow: "Controls", title: "Interactive Primitives")
                SegmentedFilterBar(items: ComponentPreviewFilter.allCases, selection: $filter) { $0.rawValue }
                HStack {
                    TagPill("Default")
                    StatusChip("Success", icon: "checkmark.circle.fill", state: .success)
                    TagPill("Warning", icon: "exclamationmark.triangle.fill", state: .warning)
                    TagPill("Selected", icon: "checkmark.circle.fill", state: .selected)
                }

                HStack(spacing: theme.spacing.xs) {
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
                        .font(theme.typography.caption)
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
                            title: "Search Ambitions",
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
                    columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.xs, alignment: .top)],
                    alignment: .leading,
                    spacing: theme.spacing.xs
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
                        subtitle: "A calm module shell for Today, Goals, Time, and You surfaces, with Capture as the global composer.",
                        status: "Ready",
                        accessibilityHint: "Reviews the primary orientation module."
                    )
                ) {
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        AmbitionBand {
                            Image(systemName: "checkmark.seal")
                            Text("State is carried by text, symbol, and structure, not color alone.")
                                .font(theme.typography.caption)
                        }

                        HStack(spacing: theme.spacing.xs) {
                            AmbitionsActionButton("Start here", icon: "arrow.right.circle.fill", role: .primary) {}
                            QuietActionButton("Why this", icon: "questionmark.circle") {}
                        }
                    }
                }

                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.xs, alignment: .top)],
                    alignment: .leading,
                    spacing: theme.spacing.xs
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
                    HStack(alignment: .bottom, spacing: theme.spacing.xxs) {
                        ForEach([0.35, 0.50, 0.44, 0.70, 0.58], id: \.self) { value in
                            RoundedRectangle(cornerRadius: theme.radius.sm, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            theme.colors.accentSecondary.opacity(0.9),
                                            theme.colors.accentWarm.opacity(0.65)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(maxWidth: .infinity)
                                .frame(height: 100 * value)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .bottom)
                }

                VStack(spacing: theme.spacing.sm) {
                    EmptyStateCard(
                        title: "No insights yet",
                        message: "Use this when a module has no data but still needs calm structure.",
                        icon: "moon.stars"
                    )

                    LoadingSkeletonCard(lineCount: 4)
                    CelebrationBanner(title: "Momentum is compounding", subtitle: "Use this after wins, completed steps, or rhythm milestones.")
                }

                VStack(spacing: theme.spacing.xs) {
                    ListChevronRow(
                        title: "Drill-in row",
                        subtitle: "Consistent navigation affordance",
                        leading: {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(theme.colors.accentSecondary)
                        },
                        trailing: {
                            Text("4 items")
                                .foregroundStyle(theme.colors.textSecondary)
                        },
                        action: {}
                    )

                    BottomNavShell(
                        items: ComponentPreviewRootSurface.allCases,
                        selection: $selectedSurface,
                        title: { $0.rawValue },
                        icon: { $0.iconName }
                    )
                }
            }
            .padding(theme.spacing.lg)
        }
        .ambitionTheme(.dark)
    }
}
#endif
