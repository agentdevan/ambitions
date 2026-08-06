import SwiftUI

/// A contextual Trust detail. It renders a supplied, release-bound projection
/// and deliberately contains no source fetch, command, or root navigation.
struct PublicReferenceInspectionView: View {
    let projection: PublicReferenceInspectionProjection

    var body: some View {
        List {
            Section("Authority and retrieval") {
                detailRow("Authority", projection.authority)
                detailRow("Delivery", projection.delivery)
                detailRow("Retrieval", projection.retrieval)
                detailRow("Freshness", projection.freshness)
                detailRow("Source revision", projection.sourceRevision)
            }

            if let selected = projection.selectedClaim {
                claimSection(selected, heading: "Selected public claim")
            }

            Section("Public claims") {
                ForEach(projection.claims) { claim in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(claim.title).font(.headline)
                        Text(claim.value).fixedSize(horizontal: false, vertical: true)
                        Text(claim.jurisdictionAndRelease).font(.caption).foregroundStyle(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(claim.accessibilityLabel)
                    .accessibilityValue(claim.accessibilityValue)
                }
            }

            Section(projection.recheckTrigger.title) {
                Text(projection.recheckTrigger.detail).fixedSize(horizontal: false, vertical: true)
            }
        }
        .accessibilityIdentifier("trust.public-reference-inspection.\(projection.id)")
        .accessibilityLabel("Public reference details")
    }

    @ViewBuilder
    private func claimSection(_ claim: PublicReferenceInspectionProjection.Claim, heading: String) -> some View {
        Section(heading) {
            detailRow("Value", claim.value)
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

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.semibold))
            Text(value).font(.body).fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}
