#if canImport(SwiftUI)
import SwiftUI

private struct LoadingDegradedStatePreviewGallery: View {
    @Environment(\.ambitionTheme) private var theme

    private let primaryStates: [AmbitionsLoadingState] = [
        .loading,
        .empty,
        .staleSource,
        .sourceConflict,
        .privacySensitive,
        .unsafeBlocked,
        .recovery,
        .setupNeeded
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.lg) {
                AdaptiveModuleChrome(
                    title: "Loading Empty Degraded States",
                    subtitle: "Honest state modules name what is available, what is private, and what can happen next.",
                    context: .trust,
                    state: .stale,
                    evidence: "SI13 preview matrix covers loading, empty, stale, privacy, blocked, recovery, and setup states."
                ) {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        ForEach(primaryStates, id: \.rawValue) { state in
                            AmbitionsLoadingStatePrimitive(state: state, action: {})
                        }
                    }
                }

                AdaptiveModuleChrome(
                    title: "Source And Local-Only States",
                    subtitle: "LDI hook states stay visual-only and do not claim source pack, sync, or runtime implementation.",
                    context: .trust,
                    state: .sensitive,
                    evidence: "Future hooks are source, privacy, local-only, and support markers only."
                ) {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: theme.spacing.sm)], spacing: theme.spacing.sm) {
                        ForEach(AmbitionsLoadingState.allCases, id: \.rawValue) { state in
                            compactStateRow(state)
                        }
                    }
                }
            }
            .padding(theme.spacing.lg)
        }
        .background(LivingSurfaceBackground(context: .trust, state: .calm).ignoresSafeArea())
        .ambitionTheme(.dark)
    }

    private func compactStateRow(_ state: AmbitionsLoadingState) -> some View {
        HStack(alignment: .center, spacing: theme.spacing.sm) {
            Image(systemName: state.symbolName)
                .font(.system(size: theme.icon.smallSize, weight: theme.icon.symbolWeight))
                .foregroundStyle(state.emphasis.semanticState.accentColor(in: theme))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                Text(state.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(state.action.title)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            Spacer(minLength: theme.spacing.xs)
        }
        .padding(theme.spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .fill(theme.colors.surfaceSecondary.opacity(0.54))
        )
        .overlay(
            RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                .stroke(theme.colors.strokeSubtle, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(state.accessibilityAnnouncement)
    }
}

struct LoadingDegradedStatePreviews: PreviewProvider {
    static var previews: some View {
        Group {
            LoadingDegradedStatePreviewGallery()
                .previewDisplayName("SI13 Loading Empty Degraded States")

            LoadingDegradedStatePreviewGallery()
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                .previewDisplayName("SI13 Loading Empty Degraded Reduce Motion")

            LoadingDegradedStatePreviewGallery()
                .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
                .previewDisplayName("SI13 Loading Empty Degraded Dynamic Type")
        }
    }
}
#endif
