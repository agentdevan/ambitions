import AmbitionsDesignSystem
import SwiftUI
#if canImport(UIKit)
    import UIKit
#endif

enum PublicReferenceSourceLinkPolicy {
    static func approvedURL(_ locator: String) -> URL? {
        guard let components = URLComponents(string: locator),
              components.scheme?.lowercased() == "https",
              let host = components.host?.lowercased(),
              host == "onetcenter.org" || host.hasSuffix(".onetcenter.org"),
              components.user == nil,
              components.password == nil,
              components.query == nil,
              components.fragment == nil
        else { return nil }
        return components.url
    }
}

/// A contextual, read-only Trust detail. It renders a release-bound projection
/// and deliberately contains no source fetch, mutation, or root navigation.
struct PublicReferenceInspectionView: View {
    private enum FocusTarget: Hashable {
        case sourceLink
        case corpusRetry
        case claimRetry
        case recheck
    }

    @Environment(\.ambitionTheme) private var theme
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedClaimID: PublicReferenceClaimID?
    @State private var isTechnicalProvenanceExpanded = false
    @State private var isRechecking = false
    @State private var awaitsExternalReturn = false
    @State private var detectedUpdateToken: PublicReferenceUpdateToken?
    @State private var recheckOutcomeMessage: String?
    @AccessibilityFocusState private var focusedAction: FocusTarget?

    let projection: PublicReferenceInspectionProjection
    let onRecheck: @MainActor (
        String,
        PublicReferenceUpdateToken?,
        PublicReferenceClaimID?
    ) async -> YouViewModel.PublicReferenceRecheckOutcome

    init(
        projection: PublicReferenceInspectionProjection,
        onRecheck: @escaping @MainActor (
            String,
            PublicReferenceUpdateToken?,
            PublicReferenceClaimID?
        ) async -> YouViewModel.PublicReferenceRecheckOutcome
    ) {
        self.projection = projection
        self.onRecheck = onRecheck
        _selectedClaimID = State(initialValue: projection.selectedClaimID)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            summaryCard

            if projection.availability == .available {
                if let unavailableClaimID {
                    unavailableClaimCard(unavailableClaimID)
                }
                publicClaimsCard
                if let selectedClaim {
                    claimCard(selectedClaim)
                }
            } else {
                unavailableCard
            }

            if projection.availability == .available {
                recheckCard
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("trust.public-reference-inspection.\(projection.id)")
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active, awaitsExternalReturn else { return }
            awaitsExternalReturn = false
            focusedAction = .sourceLink
            announce("Returned to the O*NET source link. Ambitions data was not changed.")
        }
        .onChange(of: projection.sourceRevision) { oldRevision, newRevision in
            guard oldRevision != newRevision else { return }
            announce("Public reference updated. Review the current source revision and visible claims.")
            focusedAction = .recheck
        }
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

    private var unavailableClaimID: PublicReferenceClaimID? {
        if let unavailableRequestedClaimID = projection.unavailableRequestedClaimID {
            return unavailableRequestedClaimID
        }
        guard let selectedClaimID, selectedClaim == nil else { return nil }
        return selectedClaimID
    }

    private func claimCard(_ claim: PublicReferenceInspectionProjection.Claim) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Claim inspection",
                    title: claim.title,
                    subtitle: claim.value
                )

                detailRow("What this source can claim", claim.claimScope)
                detailRow("Current use", claim.currentUse)
                detailRow("Jurisdiction and release", claim.jurisdictionAndRelease)
                detailRow("Checked and freshness", "\(claim.retrieval). Freshness: \(claim.freshness).")
                detailRow("Source-native identifiers", claim.sourceNativeIdentity)
                detailRow("Attribution and use terms", claim.attribution)
                detailRow("Known limits", claim.limits)
                detailRow("Conflicts", claim.conflicts)
                detailRow("Supersession", claim.supersession)
                detailRow("Cross-source relationship", claim.crossSourceRelationship)

                if let sourceURL = PublicReferenceSourceLinkPolicy.approvedURL(claim.sourceLocator) {
                    Button {
                        openURL(sourceURL) { wasOpened in
                            if wasOpened {
                                awaitsExternalReturn = true
                            } else {
                                focusedAction = .sourceLink
                                announce("The O*NET source link could not be opened. Ambitions data was not changed.")
                            }
                        }
                    } label: {
                        Label("Open O*NET source", systemImage: "arrow.up.right.square")
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("trust.public-reference.source-link")
                    .accessibilityHint("Opens the approved public source without sending private Ambitions information.")
                    .accessibilityFocused($focusedAction, equals: .sourceLink)
                }

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
                recheckOutcome
                recheckButton(
                    title: detectedUpdateToken == nil ? "Try Again" : "Review update",
                    identifier: "trust.public-reference.retry",
                    focusTarget: .corpusRetry
                )
            }
        }
    }

    private func unavailableClaimCard(_ claimID: PublicReferenceClaimID) -> some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    eyebrow: "Claim availability",
                    title: "Reference unavailable",
                    subtitle: "The requested public claim is not present in this verified release. Other independently valid claims remain available."
                )
                detailRow("Requested claim", claimID.rawValue)
                Text("No claim text was inferred, normalized, or substituted.")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                recheckOutcome
                recheckButton(
                    title: detectedUpdateToken == nil ? "Try Again" : "Review update",
                    identifier: "trust.public-reference.unavailable-claim.retry",
                    focusTarget: .claimRetry
                )
            }
        }
        .accessibilityIdentifier("trust.public-reference.unavailable-claim")
    }

    private var recheckCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                SectionHeader(
                    eyebrow: projection.recheckTrigger.isRequired ? "Review required" : "Source maintenance",
                    title: projection.recheckTrigger.title,
                    subtitle: projection.recheckTrigger.detail
                )
                Text("Fixed approved public artifact only · No selected claim or private-data join")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                recheckOutcome
                recheckButton(
                    title: detectedUpdateToken == nil ? "Check Again" : "Review update",
                    identifier: "trust.public-reference.recheck",
                    focusTarget: .recheck
                )
            }
        }
    }

    @ViewBuilder
    private var recheckOutcome: some View {
        if let recheckOutcomeMessage {
            Text(recheckOutcomeMessage)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityIdentifier("trust.public-reference.recheck-outcome")
        }
    }

    private func recheckButton(title: String, identifier: String, focusTarget: FocusTarget) -> some View {
        Button {
            Task { @MainActor in
                isRechecking = true
                let outcome = await onRecheck(
                    projection.sourceRevision,
                    detectedUpdateToken,
                    selectedClaimID
                )
                isRechecking = false
                focusedAction = focusTarget
                switch outcome {
                case .current:
                    detectedUpdateToken = nil
                    recheckOutcomeMessage = "Current verified local source state is shown."
                    announce("Public reference check finished. Current verified local source state is shown.")
                case let .updateAvailable(token):
                    detectedUpdateToken = token
                    recheckOutcomeMessage = "Source updated. Review the new verified revision before replacing this inspection."
                    announce("Public reference source updated. Review update before replacing this inspection.")
                case .stale:
                    detectedUpdateToken = nil
                    recheckOutcomeMessage = "The source changed again. Check the approved source before reviewing another revision."
                    announce("Public reference source changed again. Check again before reviewing another revision.")
                case .failed:
                    recheckOutcomeMessage = "The check could not finish. The last honest local state remains available."
                    announce("Public reference check could not finish. The last honest local state remains available.")
                }
            }
        } label: {
            Label(isRechecking ? "Checking…" : title, systemImage: "arrow.clockwise")
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .disabled(isRechecking)
        .accessibilityIdentifier(identifier)
        .accessibilityHint(detectedUpdateToken == nil
            ? "Checks only the fixed approved public artifact and sends no selected claim or private Ambitions information."
            : "Replaces this bound inspection with the exact verified revision already checked. It performs no second source fetch.")
        .accessibilityFocused($focusedAction, equals: focusTarget)
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
                .textSelection(.enabled)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }

    private func announce(_ message: String) {
        #if canImport(UIKit)
            UIAccessibility.post(notification: .announcement, argument: message)
        #else
            _ = message
        #endif
    }
}
