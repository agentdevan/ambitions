import AmbitionsDesignSystem
import SwiftUI

/// A contextual, read-only Trust detail. It renders a release-bound projection
/// and deliberately contains no source fetch, mutation, or root navigation.
struct PublicReferenceInspectionView: View {
    @Environment(\.ambitionTheme) private var theme

    let projection: PublicReferenceInspectionProjection

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            summaryCard

            if projection.availability == .available, let selected = projection.selectedClaim {
                claimCard(selected)
                publicClaimsCard
            } else {
                unavailableCard
            }

            recheckCard
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("trust.public-reference-inspection.\(projection.id)")
    }

    private var summaryCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Trust · Public reference",
                    title: projection.title,
                    subtitle: projection.corpusTitle
                )

                detailRow("Delivery", projection.delivery)
                detailRow("Semantic use", projection.semanticUse)
                detailRow("Recommendation readiness", projection.recommendationReadiness)
                detailRow("Authority", projection.authority)
                detailRow("Retrieval", projection.retrieval)
                detailRow("Freshness", projection.freshness)
                detailRow("Source revision", projection.sourceRevision)
            }
        }
    }

    private func claimCard(_ claim: PublicReferenceInspectionProjection.Claim) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Selected claim",
                    title: claim.title,
                    subtitle: claim.value
                )

                detailRow("What this source can claim", "A public, descriptive occupation reference for the named release and jurisdiction.")
                detailRow("Source-native identity", claim.sourceNativeIdentity)
                detailRow("Authority", claim.authority)
                detailRow("Jurisdiction and release", claim.jurisdictionAndRelease)
                detailRow("Retrieval", claim.retrieval)
                detailRow("Freshness", claim.freshness)
                detailRow("Limits", claim.limits)
                detailRow("Conflicts", claim.conflicts)
                detailRow("Supersession", claim.supersession)
                detailRow("Attribution", claim.attribution)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(claim.accessibilityLabel)
            .accessibilityValue(claim.accessibilityValue)
        }
    }

    private var publicClaimsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Approved corpus",
                    title: "Public claims",
                    subtitle: "Only release-bound descriptive claims appear here. They never include private life data."
                )

                ForEach(projection.claims) { claim in
                    VStack(alignment: .leading, spacing: theme.spacing.xs) {
                        Text(claim.title)
                            .font(theme.typography.bodyEmphasized)
                            .foregroundStyle(theme.colors.textPrimary)
                        Text(claim.value)
                            .font(theme.typography.body)
                            .foregroundStyle(theme.colors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(claim.jurisdictionAndRelease)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(theme.spacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                            .fill(theme.colors.surfaceOverlay)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous)
                            .stroke(theme.colors.strokeSubtle, lineWidth: 1)
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(claim.accessibilityLabel)
                    .accessibilityValue(claim.accessibilityValue)
                }
            }
        }
    }

    private var unavailableCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    eyebrow: "Availability",
                    title: "Public reference unavailable",
                    subtitle: "No verified public corpus is installed for this session."
                )
                Text("Local planning remains available and no source fact is inferred or fetched.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var recheckCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    eyebrow: projection.recheckTrigger.isRequired ? "Review required" : "Source maintenance",
                    title: projection.recheckTrigger.title,
                    subtitle: projection.recheckTrigger.detail
                )
                Text("Read-only · No source fetch or private-data join")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textTertiary)
            Text(value)
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}
