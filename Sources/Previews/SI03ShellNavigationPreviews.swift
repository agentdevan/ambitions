#if canImport(SwiftUI)
import SwiftUI

private struct SI03ShellNavigationPreview: View {
    @State private var privateItems = true
    @State private var overlayPresented = true

    var body: some View {
        ScrollView {
            AmbitionsSurfaceShell(
                kind: .utilityHub,
                title: "You",
                subtitle: "Personal system center with grouped routes, trust controls, and calm return paths.",
                statusMessage: "Top-level destinations stay Today, Goals, Time, Motion, and You with global Capture.",
                primaryAction: .init(
                    title: "Open command",
                    systemImage: "command",
                    accessibilityIdentifier: "preview.si03.command"
                ) {},
                secondaryAction: .init(
                    title: "Review context",
                    systemImage: "checkmark.shield",
                    accessibilityIdentifier: "preview.si03.source"
                ) {}
            ) {
                GroupedNavigationList {
                    GroupedNavigationSection(
                        title: "Planning setup",
                        footer: "Rows open owned drill-downs. No route is created by the preview."
                    ) {
                        GroupedDisclosureNavigationRow(
                            title: "Planning defaults",
                            subtitle: "How Ambitions proposes the next plan.",
                            systemImage: "slider.horizontal.3",
                            badge: .init("Review", state: .review),
                            accessibilityHint: "Opens planning defaults.",
                            action: {}
                        )

                        GroupedStatusNavigationRow(
                            title: "Schedule and availability",
                            subtitle: "Calendar-derived context remains inspectable.",
                            systemImage: "calendar.badge.clock",
                            value: "Local",
                            state: .calendarDerived,
                            accessibilityHint: "Opens schedule and availability.",
                            action: {}
                        )
                    }

                    GroupedNavigationSection(title: "Trust and control") {
                        GroupedStatusNavigationRow(
                            title: "Search Ambitions",
                            subtitle: "Review saved context and receipts.",
                            systemImage: "checkmark.shield",
                            value: "Private",
                            state: .protected,
                            accessibilityHint: "Opens saved context.",
                            action: {}
                        )

                        GroupedPreferenceRow(
                            title: "Private display",
                            subtitle: "Hide sensitive details in shared views.",
                            systemImage: "eye.slash",
                            isOn: $privateItems,
                            accessibilityHint: "Turns private display on or off."
                        )
                    }
                }

                ShellOverlayZone(
                    title: "Return path",
                    subtitle: "Temporary overlays name the source and dismiss back to the owning surface.",
                    isPresented: overlayPresented,
                    onDismiss: { overlayPresented = false }
                ) {
                    AmbitionBand {
                        Image(systemName: "arrow.uturn.backward.circle")
                        Text("Overlay motion uses a Reduce Motion opacity fallback.")
                            .font(.caption)
                    }
                }
            }
            .padding()
        }
    }
}

struct SI03ShellNavigationPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            SI03ShellNavigationPreview()
                .previewDisplayName("SI03 Shell Navigation")

            SI03ShellNavigationPreview()
                .environment(\.dynamicTypeSize, .accessibility3)
                .previewDisplayName("SI03 Dynamic Type")

            SI03ShellNavigationPreview()
                .previewDisplayName("SI03 Reduce Motion Path")
        }
    }
}
#endif
