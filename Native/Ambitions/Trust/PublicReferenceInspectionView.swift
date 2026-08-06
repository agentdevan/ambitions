import AmbitionsDesignSystem
import SwiftUI

/// A contextual, read-only Trust detail. It renders a release-bound projection
/// and deliberately contains no source fetch, mutation, or root navigation.
struct PublicReferenceInspectionView: View {
    @Environment(\.ambitionTheme) private var theme
    @State private var selectedClaimID: PublicReferenceClaimID?
    @State private var isTechnicalProvenanceExpanded = false

    let projection: PublicReferenceInspectionProjection

    init(projection: PublicReferenceInspectionProjection) {
        self.projection = projection
        _selectedClaimID = State(initialValue: projection.selectedClaimID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            summaryCard

            if projection.availability == .available {
                publicClaimsCard
                if let selectedClaim {
                    claimCard(selectedClaim)
                }
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
            }
        }
    }

    private var selectedClaim: PublicReferenceInspectionProjection.Claim? {
        guard let selectedClaimID else { return nil }
        return projection.claims.first { $0.id == selectedClaimID }
            ?? projection.selectedClaim.flatMap { $0.id == selectedClaimID ? $0 : nil }
    }

    private func claimCard(_ claim: PublicReferenceInspectionProjection.Claim) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Claim inspection",
                    title: claim.title,
                    subtitle: claim.value
                )

                detailRow("What this source can claim", "A public, descriptive occupation reference for the named release and jurisdiction.")
                detailRow("Jurisdiction and release", claim.jurisdictionAndRelease)
                detailRow("Checked and freshness", "\(claim.retrieval). Freshness: \(claim.freshness).")
                detailRow("Source-native identifiers", claim.sourceNativeIdentity)
                detailRow("Attribution and use terms", claim.attribution)
                detailRow("Known limits", claim.limits)
                detailRow("Conflicts", claim.conflicts)
                detailRow("Supersession", claim.supersession)

                DisclosureGroup("Technical provenance", isExpanded: $isTechnicalProvenanceExpanded) {
                    VStack(alignment: .leading, spacing: theme.spacing.md) {
                        detailRow("Authority", claim.authority)
                        detailRow("Projection revision", projection.sourceRevision)
                        Text("Read-only · No source fetch or private-data join")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, theme.spacing.sm)
                }
                .font(theme.typography.bodyEmphasized)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityIdentifier("trust.public-reference.technical-provenance")
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
                    title: "Reference facts",
                    subtitle: "Choose a public fact to inspect its authority, freshness, and limits."
                )

                ForEach(projection.claims) { claim in
                    claimRow(claim)
                }

                Text("Only release-bound descriptive claims appear here. They never include private life data.")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func claimRow(_ claim: PublicReferenceInspectionProjection.Claim) -> some View {
        Button {
            selectedClaimID = claim.id
            isTechnicalProvenanceExpanded = false
        } label: {
            HStack(alignment: .center, spacing: theme.spacing.md) {
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

                Spacer(minLength: theme.spacing.sm)

                Image(systemName: "chevron.right")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .accessibilityHidden(true)
            }
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .padding(theme.spacing.md)
            .background(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .fill(theme.colors.surfaceOverlay)
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radius.md, style: .continuous)
                    .stroke(theme.colors.strokeSubtle, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("trust.public-reference.claim.\(claim.id.rawValue)")
        .accessibilityLabel(claim.accessibilityLabel)
        .accessibilityValue(claim.accessibilityValue)
        .accessibilityHint("Opens claim inspection.")
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
