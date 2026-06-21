import AmbitionsDesignSystem
import SwiftUI

struct InspectionSurface: View {
    @Environment(\.ambitionTheme) private var theme

    let state: InspectionSurfaceState

    init(kind: TrustInspectionKind, policy: RuntimeExplanationPolicy = .detailInspection) {
        self.state = InspectionSurfaceState.make(kind: kind, policy: policy)
    }

    init(state: InspectionSurfaceState) {
        self.state = state
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.md) {
                SectionHeader(
                    eyebrow: "Trust",
                    title: state.title,
                    subtitle: state.subtitle
                )

                HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                    TagPill(state.disclosureLevel.title, state: .selected)
                    Text(state.disclosureLevel.accessibilitySummary)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                ForEach(state.items) { item in
                    InspectionSurfaceRow(item: item)
                }
            }
        }
        .accessibilityIdentifier(state.accessibilityIdentifier)
        .ambitionPanelAccessibility(
            label: state.title,
            value: state.accessibilityValue,
            hint: state.accessibilityHint
        )
    }
}

struct InspectionSurfaceState: Equatable, Sendable {
    let kind: TrustInspectionKind
    let title: String
    let subtitle: String
    let ownerSurface: String
    let contextualRouteLabel: String
    let visibleConsequenceSummary: String
    let localBoundarySummary: String
    let claimBoundarySummary: String
    let disclosureLevel: TrustDisclosureLevel
    let items: [TrustInspectionItem]
    let accessibilityIdentifier: String
    let accessibilityValue: String
    let accessibilityHint: String

    static func make(kind: TrustInspectionKind, policy: RuntimeExplanationPolicy) -> InspectionSurfaceState {
        let level = policy.disclosureLevel(for: kind)
        let items = Self.items(kind: kind, policy: policy)
        return InspectionSurfaceState(
            kind: kind,
            title: "\(kind.title) inspection",
            subtitle: policy.explanation(for: kind),
            ownerSurface: "You",
            contextualRouteLabel: kind.contextualRouteLabel,
            visibleConsequenceSummary: kind.visibleConsequenceSummary,
            localBoundarySummary: policy.localOnlySummary,
            claimBoundarySummary: "This is local review context, not release readiness or public proof.",
            disclosureLevel: level,
            items: items,
            accessibilityIdentifier: "trust.\(kind.rawValue).inspection-surface",
            accessibilityValue: "\(level.title). Opens from \(kind.contextualRouteLabel) in You. \(kind.visibleConsequenceSummary) \(items.map(\.title).joined(separator: ", ")).",
            accessibilityHint: level.requiresUserIntent
                ? "Opens review detail only after the user asks, then returns to the owning surface."
                : "Summarizes the current trust boundary from the owning surface."
        )
    }

    private static func items(kind: TrustInspectionKind, policy: RuntimeExplanationPolicy) -> [TrustInspectionItem] {
        switch kind {
        case .proof:
            [
                TrustInspectionItem(title: "What changed", detail: "Shows the user-visible mutation that created proof.", state: .selected),
                TrustInspectionItem(title: "Why it counts", detail: "Keeps completion, correction, and recovery reasons reviewable.", state: .success),
                TrustInspectionItem(title: "Where to review", detail: policy.correctionSummary, state: .default),
            ]
        case .source:
            [
                TrustInspectionItem(title: "Local source", detail: "Names the record, time shape, or goal context used.", state: .selected),
                TrustInspectionItem(title: "Freshness", detail: "Explains whether the source is current enough for the surface.", state: .default),
                TrustInspectionItem(title: "Boundary", detail: "Keeps public reference material separate from private life details.", state: .success),
            ]
        case .privacy:
            [
                TrustInspectionItem(title: "Local first", detail: policy.localOnlySummary, state: .success),
                TrustInspectionItem(title: "Private summary", detail: "Sensitive details remain summarized before expansion.", state: .selected),
                TrustInspectionItem(title: "User control", detail: "Correction and review remain user-directed.", state: .default),
            ]
        case .history:
            [
                TrustInspectionItem(title: "Recent changes", detail: "Shows continuity without turning history into a root destination.", state: .selected),
                TrustInspectionItem(title: "Corrections", detail: "Keeps changed decisions tied to their owning surface.", state: .default),
                TrustInspectionItem(title: "Return path", detail: "Review leads back to Time, Today, Goals, or You.", state: .success),
            ]
        case .receipt:
            [
                TrustInspectionItem(title: "Receipt", detail: "Shows what changed and why.", state: .selected),
                TrustInspectionItem(title: "Undo", detail: "Names whether the change can be reversed.", state: .default),
                TrustInspectionItem(title: "Proof artifact", detail: "Keeps evidence reviewable without public claims.", state: .success),
            ]
        }
    }
}

extension TrustInspectionKind {
    var contextualRouteLabel: String {
        switch self {
        case .proof:
            "History"
        case .source:
            "Sources and permissions"
        case .privacy:
            "Privacy"
        case .history:
            "Receipts and history"
        case .receipt:
            "Receipts and history"
        }
    }

    var visibleConsequenceSummary: String {
        switch self {
        case .proof:
            "Completion and correction proof stays attached to the step, goal, or review that created it."
        case .source:
            "Source review changes the recommendation context only where the owning surface uses that source."
        case .privacy:
            "Privacy review changes what is summarized, hidden, or blocked before private detail appears."
        case .history:
            "History review opens recent continuity and routes back to Today, Goals, Time, or You."
        case .receipt:
            "Receipt review names what changed, why it changed, and whether undo is available."
        }
    }
}

struct TrustInspectionItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let detail: String
    let state: AmbitionVisualState

    init(title: String, detail: String, state: AmbitionVisualState) {
        self.id = title
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        self.title = title
        self.detail = detail
        self.state = state
    }
}

private struct InspectionSurfaceRow: View {
    @Environment(\.ambitionTheme) private var theme

    let item: TrustInspectionItem

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: theme.spacing.sm) {
                Text(item.title)
                    .font(theme.typography.bodyEmphasized)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer(minLength: theme.spacing.sm)
                TagPill("Review", state: item.state)
            }

            Text(item.detail)
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(theme.spacing.md)
        .background(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).fill(theme.colors.surfaceOverlay))
        .overlay(RoundedRectangle(cornerRadius: theme.radius.lg, style: .continuous).stroke(theme.colors.strokeSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(item.title)
        .accessibilityValue(item.detail)
    }
}
