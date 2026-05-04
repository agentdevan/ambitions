#if canImport(SwiftUI)
import SwiftUI

public struct IconographyStatusPreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    private let highlightedRoles: [AmbitionsStatusSymbolRole] = [
        .proofSaved,
        .sourceFresh,
        .sourceStale,
        .sourceConflict,
        .privacySensitive,
        .localOnly,
        .syncUnavailable,
        .professionalBoundary,
        .unsafeBlocked,
        .crisisSupport,
        .recoveryAvailable,
        .disabledPendingValidation
    ]

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                Text("Status grammar")
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: theme.spacing.xs) {
                    ForEach(highlightedRoles) { role in
                        AmbitionsStatusSymbol(role, style: .row)
                    }
                }

                Divider()
                    .overlay(theme.colors.strokeSubtle)

                ForEach(AmbitionsStatusSymbolFamily.allCases, id: \.rawValue) { family in
                    familySection(family)
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(theme.colors.canvas)
    }

    private func familySection(_ family: AmbitionsStatusSymbolFamily) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            Text(family.title)
                .font(theme.typography.sectionTitle)
                .foregroundStyle(theme.colors.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 168), spacing: theme.spacing.xs)], spacing: theme.spacing.xs) {
                ForEach(AmbitionsStatusSymbolRole.allCases.filter { $0.family == family }) { role in
                    AmbitionsStatusSymbol(role, style: .badge)
                }
            }
        }
    }
}

#Preview("SI14 Iconography Status Grammar") {
    IconographyStatusPreviewGallery()
        .ambitionTheme(.theme(for: .dark, accentFamily: .sage))
}

#Preview("SI14 Iconography Status Dynamic Type") {
    IconographyStatusPreviewGallery()
        .ambitionTheme(.theme(for: .light, accentFamily: .blueGray))
        .environment(\.dynamicTypeSize, .accessibility2)
}

#Preview("SI14 Iconography Status Reduce Motion") {
    IconographyStatusPreviewGallery()
        .ambitionTheme(.theme(for: .dark, accentFamily: .mutedGold))
}
#endif
