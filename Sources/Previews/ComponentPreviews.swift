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
                    TagPill("Warning", icon: "exclamationmark.triangle.fill", state: .warning)
                    TagPill("Selected", icon: "checkmark.circle.fill", state: .selected)
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
