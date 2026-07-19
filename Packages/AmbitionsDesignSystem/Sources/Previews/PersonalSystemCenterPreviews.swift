#if canImport(SwiftUI)
import SwiftUI

private struct PersonalSystemCenterPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    let setupItems: [PersonalSystemCenterSetupItem] = [
        PersonalSystemCenterSetupItem(id: "trust", title: "Trust Center", statusLabel: "Review", state: .proof),
        PersonalSystemCenterSetupItem(id: "memory", title: "Memory", statusLabel: "Local", state: .calm),
        PersonalSystemCenterSetupItem(id: "schedule", title: "Schedule", statusLabel: "Denied", state: .stale),
        PersonalSystemCenterSetupItem(id: "access", title: "Accessibility", statusLabel: "Claims locked", state: .stale)
    ]

    let sections: [GroupedNavigationSystemSection] = [
        GroupedNavigationSystemSection(
            id: "trust-memory",
            title: "Trust, Memory & Receipts",
            subtitle: "Inspectable controls without a settings dump.",
            items: [
                GroupedNavigationSystemItem(
                    id: "trust-center",
                    title: "Trust Center",
                    subtitle: "Permissions, privacy, and boundaries.",
                    symbolName: "checkmark.shield",
                    state: .proof,
                    statusLabel: "Review"
                ),
                GroupedNavigationSystemItem(
                    id: "what-ambitions-knows",
                    title: "Memory",
                    subtitle: "Local records Ambitions can explain and let you correct.",
                    symbolName: "brain.head.profile",
                    state: .calm,
                    statusLabel: "Local"
                )
            ]
        ),
        GroupedNavigationSystemSection(
            id: "future-edges",
            title: "Privacy, Accessibility & Boundaries",
            subtitle: "Future-owned edges stay labeled instead of implied.",
            items: [
                GroupedNavigationSystemItem(
                    id: "export-import",
                    title: "Privacy",
                    subtitle: "Export and import remain manual/future-owned.",
                    symbolName: "lock.shield",
                    state: .stale,
                    statusLabel: "Manual"
                ),
                GroupedNavigationSystemItem(
                    id: "widgets",
                    title: "Automation & Trust",
                    subtitle: "Widgets, shortcuts, and sync claims stay bounded.",
                    symbolName: "rectangle.connected.to.line.below",
                    state: .stale,
                    statusLabel: "Future"
                )
            ]
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                PersonalSystemCenterHeader(
                    title: "Your system",
                    summary: "Local-first controls are visible before any deeper setup.",
                    signals: [
                        PersonalSystemCenterSignal(id: "trust", title: "Trust Center", detail: "Reviewable", source: "No silent changes", state: .proof, context: .trust),
                        PersonalSystemCenterSignal(id: "memory", title: "Memory", detail: "Inspectable", source: "Local records", state: .calm, context: .memory),
                        PersonalSystemCenterSignal(id: "access", title: "Accessibility", detail: "Claims locked", source: "Human proof pending", state: .stale, context: .you)
                    ]
                )

                PersonalSystemCenterSetupCompleteness(
                    title: "Setup completeness",
                    summary: "Setup-needed states stay visible without account or sync assumptions.",
                    completedCount: 2,
                    totalCount: setupItems.count,
                    items: setupItems
                )

                PersonalSystemCenterNavigation(sections: sections) { _ in }
            }
            .padding(theme.spacing.lg)
        }
        .background {
            LivingSurfaceBackground(context: .you, state: .calm, intensity: 0.68)
                .ignoresSafeArea()
        }
    }
}

struct PersonalSystemCenterPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            PersonalSystemCenterPreviewGallery()
                .previewDisplayName("SI11 Personal System Center")

            PersonalSystemCenterPreviewGallery()
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                .previewDisplayName("SI11 Personal System Center Reduce Motion")

            PersonalSystemCenterPreviewGallery()
                .environment(\.dynamicTypeSize, .accessibility3)
                .previewDisplayName("SI11 Personal System Center Dynamic Type")
        }
    }
}
#endif
