#if canImport(SwiftUI)
import SwiftUI

private struct DynamicAdaptiveVisualGallery: View {
    @Environment(\.ambitionTheme) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                AdaptiveModuleChrome(
                    title: "Today has a shape",
                    subtitle: "One next step, pressure visible, recovery nearby.",
                    context: .today,
                    state: .active,
                    evidence: "Based on your plan"
                ) {
                    PressureGlow(level: 0.58, context: .today, label: "Today pressure")

                    HStack(spacing: theme.spacing.sm) {
                        EvidenceLabel("Next step is ready", detail: "Now", source: "Today rail", state: .proof, context: .today)
                        ProofPulse(isActive: true)
                    }
                }

                QuietCommandSurface(
                    placeholder: "What needs a place?",
                    detail: "Capture stays composer-first.",
                    context: .capture
                ) {
                    Image(systemName: "plus")
                        .font(.system(size: theme.icon.mediumSize, weight: theme.icon.symbolWeight))
                        .foregroundStyle(theme.colors.textInverse)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(theme.semanticColors.capture))
                        .accessibilityLabel("Add")
                }

                AdaptiveModuleChrome(
                    title: "Memory stays inspectable",
                    subtitle: "Source, freshness, and controls are visible before personality.",
                    context: .memory,
                    state: .stale,
                    evidence: "Source review needed"
                ) {
                    EvidenceLabel(
                        "May need review",
                        detail: "Older context should be checked before reuse.",
                        source: "Saved from a previous goal",
                        state: .stale,
                        context: .memory
                    )
                }

                GroupedNavigationSystem(
                    sections: [
                        GroupedNavigationSystemSection(
                            id: "trust",
                            title: "Trust",
                            subtitle: "Control before intelligence.",
                            items: [
                                GroupedNavigationSystemItem(
                                    id: "data-map",
                                    title: "Data map",
                                    subtitle: "See what Ambitions can use.",
                                    symbolName: "map",
                                    state: .calm
                                ),
                                GroupedNavigationSystemItem(
                                    id: "private-mode",
                                    title: "Private mode",
                                    subtitle: "Sensitive areas stay under your control.",
                                    symbolName: "lock.shield",
                                    state: .sensitive
                                )
                            ]
                        )
                    ],
                    context: .you
                )
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .today, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }
}

struct DynamicAdaptiveVisualGallery_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            DynamicAdaptiveVisualGallery()
                .previewDisplayName("DAV Normal")

            DynamicAdaptiveVisualGallery()
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                .previewDisplayName("DAV Reduce Motion")

            DynamicAdaptiveVisualGallery()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("DAV High Dynamic Type")
        }
    }
}
#endif
