import AmbitionsDesignSystem
import SwiftUI

struct TodayMasthead: View {
    @Environment(\.ambitionTheme) private var theme

    let date: Date
    let contextSummary: String?

    init(date: Date = .now, contextSummary: String? = nil) {
        self.date = date
        self.contextSummary = contextSummary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            HStack(alignment: .top, spacing: theme.spacing.md) {
                VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                    Text("Today")
                        .font(theme.typography.heroDisplay)
                        .foregroundStyle(theme.colors.textPrimary)
                        .accessibilityIdentifier("TodayMastheadTitle")

                    Text(date.formatted(.dateTime.weekday(.wide).month(.wide).day()))
                        .font(theme.typography.bodySecondary)
                        .foregroundStyle(theme.colors.textSecondary)
                }

                Spacer(minLength: theme.spacing.sm)

                LocalAmbitionsLockup()
                    .accessibilityIdentifier("TodayMastheadLocalAmbitionsLockup")
            }

            VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
                Text("Reality Meridian")
                    .font(theme.typography.title.weight(.bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [theme.semanticColors.trust, theme.colors.accentSecondary, theme.semanticColors.review],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .accessibilityIdentifier("TodayMastheadRealityMeridianTitle")

                Text(contextSummary ?? "Right plan. Right time. Real progress.")
                    .font(theme.typography.bodySecondary)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("TodayMastheadContextSummary")
            }
        }
        .padding(.top, theme.spacing.sm)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Today. Reality Meridian. \(contextSummary ?? "Right plan. Right time. Real progress.")")
        .accessibilityIdentifier("TodayMasthead")
    }
}
