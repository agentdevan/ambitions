#if canImport(SwiftUI)
import SwiftUI

public struct CoreReusableInteractionPrimitivePreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var privateByDefault = true
    private let scrolls: Bool

    public init(scrolls: Bool = true) {
        self.scrolls = scrolls
    }

    public var body: some View {
        contentContainer
        .background(AmbitionTheme.theme(for: .dark).colors.canvas)
        .ambitionTheme(.dark)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var contentContainer: some View {
        if scrolls {
            ScrollView {
                content
            }
        } else {
            content
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: theme.spacing.lg) {
            SectionHeader(
                eyebrow: "AMB-1061",
                title: "Core Reusable Interaction Primitives",
                subtitle: "Launch-path controls composed from existing Ambitions primitives."
            )

            AdaptivePanel(
                .init(
                    emphasis: .action,
                    title: "Recommended step is ready",
                    subtitle: "Primary, recovery, disclosure, and trust controls stay reusable without becoming a generic stack.",
                    status: "Inventory",
                    accessibilityHint: "Reviews AMB-1061 interaction primitive coverage."
                )
            ) {
                VStack(alignment: .leading, spacing: theme.spacing.sm) {
                    AmbitionCoreInteractionActionButton(role: .startHere, state: .selected, action: {})
                    AmbitionCoreInteractionActionButton(role: .startNow, state: .ready, action: {})
                    AmbitionCoreInteractionActionButton(role: .recoveryOption, state: .recovery, action: {})

                    AmbitionCoreInteractionDisclosureRow(
                        role: .inspectProof,
                        state: .localOnly,
                        subtitle: "SourceRecord, Receipt, and ReplayTrace stay inspectable.",
                        action: {}
                    )

                    AmbitionCoreInteractionPreferenceRow(
                        subtitle: "Hide sensitive details unless the user chooses otherwise.",
                        isOn: $privateByDefault
                    )

                    HStack(spacing: theme.spacing.xs) {
                        AmbitionCoreInteractionStatusPill(role: .reviewTimeFit, state: .sourceNeeded)
                        AmbitionCoreInteractionStatusPill(role: .captureContext, state: .localOnly)
                        AmbitionCoreInteractionStatusPill(role: .confirmChange, state: .destructiveConfirmation)
                    }
                }
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.sm, alignment: .top)],
                alignment: .leading,
                spacing: theme.spacing.sm
            ) {
                ForEach(AmbitionCoreInteractionPreviewMatrix.rows) { row in
                    previewRow(row)
                }
            }
        }
        .padding(theme.spacing.lg)
    }

    private func previewRow(_ row: AmbitionCoreInteractionPreviewRow) -> some View {
        AdaptivePanel(
            .init(
                emphasis: .quiet,
                title: row.role.title,
                subtitle: "\(row.role.ownerSurface) / \(row.role.primaryObject)",
                status: row.role.family.rawValue,
                accessibilityLabel: row.accessibilitySummary,
                accessibilityHint: row.role.accessibilityHint
            )
        ) {
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                ForEach(row.cells.prefix(4)) { cell in
                    AmbitionCoreInteractionStatusPill(role: cell.role, state: cell.state)
                }
            }
        }
    }
}

#Preview("AMB-1061 Core Reusable Interaction Primitives") {
    CoreReusableInteractionPrimitivePreviewGallery()
}
#endif
