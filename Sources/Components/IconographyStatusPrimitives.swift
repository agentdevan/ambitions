#if canImport(SwiftUI)
import SwiftUI

public enum AmbitionsStatusSymbolFamily: String, CaseIterable, Sendable {
    case proof
    case source
    case privacy
    case pressure
    case recovery
    case system

    public var title: String {
        switch self {
        case .proof: "Proof"
        case .source: "Source"
        case .privacy: "Privacy"
        case .pressure: "Pressure"
        case .recovery: "Recovery"
        case .system: "System"
        }
    }
}

public enum AmbitionsStatusSymbolPlacement: String, CaseIterable, Sendable {
    case objectHeader
    case statusBadge
    case receiptProof
    case externalCompact
    case loadingDegradedCard
    case reviewFold

    public var title: String {
        switch self {
        case .objectHeader: "Object header"
        case .statusBadge: "Status badge"
        case .receiptProof: "Receipt proof"
        case .externalCompact: "External compact"
        case .loadingDegradedCard: "Loading or degraded card"
        case .reviewFold: "Review fold"
        }
    }
}

public enum AmbitionsStatusSymbolRole: String, CaseIterable, Identifiable, Sendable {
    case proofSaved
    case proofPending
    case receiptAvailable
    case sourceFresh
    case sourcePartial
    case sourceStale
    case sourceDenied
    case sourceConflict
    case privacyProtected
    case privacySensitive
    case localOnly
    case syncUnavailable
    case packUnavailable
    case professionalBoundary
    case unsafeBlocked
    case crisisSupport
    case pressureRising
    case recoveryAvailable
    case waiting
    case needsReview
    case setupNeeded
    case noDataYet
    case disabledPendingValidation
    case loading

    public var id: String { rawValue }

    public var family: AmbitionsStatusSymbolFamily {
        switch self {
        case .proofSaved, .proofPending, .receiptAvailable:
            return .proof
        case .sourceFresh, .sourcePartial, .sourceStale, .sourceDenied,
             .sourceConflict, .packUnavailable:
            return .source
        case .privacyProtected, .privacySensitive, .localOnly,
             .syncUnavailable:
            return .privacy
        case .pressureRising, .unsafeBlocked, .crisisSupport,
             .professionalBoundary:
            return .pressure
        case .recoveryAvailable:
            return .recovery
        case .waiting, .needsReview, .setupNeeded, .noDataYet,
             .disabledPendingValidation, .loading:
            return .system
        }
    }

    public var title: String {
        switch self {
        case .proofSaved: "Proof saved"
        case .proofPending: "Proof pending"
        case .receiptAvailable: "Receipt"
        case .sourceFresh: "Fresh source"
        case .sourcePartial: "Partial source"
        case .sourceStale: "Review source"
        case .sourceDenied: "Source denied"
        case .sourceConflict: "Source conflict"
        case .privacyProtected: "Private"
        case .privacySensitive: "Private detail"
        case .localOnly: "Local only"
        case .syncUnavailable: "Continuity paused"
        case .packUnavailable: "Pack unavailable"
        case .professionalBoundary: "Boundary"
        case .unsafeBlocked: "Blocked"
        case .crisisSupport: "Support"
        case .pressureRising: "Pressure rising"
        case .recoveryAvailable: "Recovery"
        case .waiting: "Waiting"
        case .needsReview: "Needs review"
        case .setupNeeded: "Setup needed"
        case .noDataYet: "No signal yet"
        case .disabledPendingValidation: "Validation pending"
        case .loading: "Loading"
        }
    }

    public var detail: String {
        switch self {
        case .proofSaved: "Progress has a saved proof marker."
        case .proofPending: "Proof is expected before this is treated as final."
        case .receiptAvailable: "A receipt can explain what changed."
        case .sourceFresh: "Source evidence is current enough to read."
        case .sourcePartial: "Some source evidence is visible, but not complete."
        case .sourceStale: "Source evidence should be reviewed before reuse."
        case .sourceDenied: "The source is unavailable; local state remains visible."
        case .sourceConflict: "Source states disagree and need review."
        case .privacyProtected: "Private by default."
        case .privacySensitive: "Sensitive detail is summarized."
        case .localOnly: "This state stays on this device."
        case .syncUnavailable: "Continuity is paused without changing local truth."
        case .packUnavailable: "The source pack is not available here."
        case .professionalBoundary: "Professional support remains outside Ambitions."
        case .unsafeBlocked: "This cannot become an Ambitions action path."
        case .crisisSupport: "Support language takes priority."
        case .pressureRising: "Capacity or pressure needs attention."
        case .recoveryAvailable: "A smaller recovery path is available."
        case .waiting: "This is parked until something outside Ambitions changes."
        case .needsReview: "A person reviews this before changes proceed."
        case .setupNeeded: "Setup is needed before this becomes useful."
        case .noDataYet: "There is not enough local signal yet."
        case .disabledPendingValidation: "The action stays still until checks finish."
        case .loading: "Ambitions is preparing the state."
        }
    }

    public var symbolName: String {
        switch self {
        case .proofSaved: "checkmark.seal.fill"
        case .proofPending: "seal"
        case .receiptAvailable: "doc.text.magnifyingglass"
        case .sourceFresh: "checkmark.shield.fill"
        case .sourcePartial: "circle.lefthalf.filled"
        case .sourceStale: "clock.badge.exclamationmark"
        case .sourceDenied: "eye.slash"
        case .sourceConflict: "exclamationmark.arrow.triangle.2.circlepath"
        case .privacyProtected: "lock.shield.fill"
        case .privacySensitive: "lock.shield"
        case .localOnly: "iphone"
        case .syncUnavailable: "icloud.slash"
        case .packUnavailable: "shippingbox"
        case .professionalBoundary: "person.crop.circle.badge.exclamationmark"
        case .unsafeBlocked: "hand.raised"
        case .crisisSupport: "heart.text.square"
        case .pressureRising: "gauge.with.dots.needle.67percent"
        case .recoveryAvailable: "arrow.uturn.backward.circle"
        case .waiting: "pause.circle"
        case .needsReview: "checklist"
        case .setupNeeded: "slider.horizontal.3"
        case .noDataYet: "circle.dashed"
        case .disabledPendingValidation: "lock.circle"
        case .loading: "hourglass"
        }
    }

    public var semanticState: AmbitionSemanticState {
        switch self {
        case .proofSaved, .sourceFresh:
            return .trust
        case .proofPending, .sourcePartial, .needsReview:
            return .review
        case .receiptAvailable:
            return .confidenceMedium
        case .sourceStale, .sourceDenied, .sourceConflict,
             .packUnavailable, .disabledPendingValidation:
            return .caution
        case .privacyProtected, .privacySensitive, .localOnly,
             .syncUnavailable:
            return .protected
        case .professionalBoundary, .unsafeBlocked, .crisisSupport,
             .pressureRising:
            return .risk
        case .recoveryAvailable:
            return .recovery
        case .waiting, .setupNeeded, .loading:
            return .waiting
        case .noDataYet:
            return .neutral
        }
    }

    public var accessibilityLabel: String {
        "\(title). \(detail). Family: \(family.title)."
    }

    public var nonColorCue: String {
        "\(shapeCue) with visible label: \(title)"
    }

    public var shapeCue: String {
        switch family {
        case .proof:
            return "Seal/document shape using \(symbolName)"
        case .source:
            return "Source shield/clock/conflict shape using \(symbolName)"
        case .privacy:
            return "Privacy device/lock/cloud-slash shape using \(symbolName)"
        case .pressure:
            return "Boundary/pressure/support shape using \(symbolName)"
        case .recovery:
            return "Recovery turn-back shape using \(symbolName)"
        case .system:
            return "System waiting/review/setup shape using \(symbolName)"
        }
    }

    public var allowedPlacements: [AmbitionsStatusSymbolPlacement] {
        switch self {
        case .proofSaved, .proofPending, .receiptAvailable:
            return [.objectHeader, .statusBadge, .receiptProof, .reviewFold]
        case .sourceFresh, .sourcePartial, .sourceStale, .sourceDenied,
             .sourceConflict, .packUnavailable:
            return [.objectHeader, .statusBadge, .loadingDegradedCard, .reviewFold]
        case .privacyProtected, .privacySensitive, .localOnly,
             .syncUnavailable:
            return [.objectHeader, .statusBadge, .externalCompact, .loadingDegradedCard]
        case .professionalBoundary, .unsafeBlocked, .crisisSupport,
             .pressureRising:
            return [.objectHeader, .statusBadge, .loadingDegradedCard, .reviewFold]
        case .recoveryAvailable:
            return [.objectHeader, .statusBadge, .loadingDegradedCard, .reviewFold]
        case .waiting, .needsReview, .setupNeeded, .noDataYet,
             .disabledPendingValidation, .loading:
            return [.objectHeader, .statusBadge, .loadingDegradedCard]
        }
    }

    public var placementSummary: String {
        allowedPlacements.map(\.title).joined(separator: ", ")
    }

    public var reduceMotionSemantics: String {
        "Static symbol and visible label preserve the same status."
    }

    public var isFutureLDIVisualHook: Bool {
        switch self {
        case .sourceConflict, .syncUnavailable, .packUnavailable,
             .professionalBoundary, .unsafeBlocked, .crisisSupport:
            return true
        default:
            return false
        }
    }
}

public enum AmbitionsStatusSymbolStyle: String, CaseIterable, Sendable {
    case inline
    case badge
    case row
}

public struct AmbitionsStatusSymbol: View {
    @Environment(\.ambitionTheme) private var theme

    private let role: AmbitionsStatusSymbolRole
    private let style: AmbitionsStatusSymbolStyle
    private let showsDetail: Bool

    public init(
        _ role: AmbitionsStatusSymbolRole,
        style: AmbitionsStatusSymbolStyle = .inline,
        showsDetail: Bool = false
    ) {
        self.role = role
        self.style = style
        self.showsDetail = showsDetail
    }

    public var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.xs) {
            symbol
            labelStack
        }
        .padding(padding)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(style == .inline ? Color.clear : stateStyle.stroke, lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(role.accessibilityLabel)
        .accessibilityIdentifier("si14.status-symbol.\(role.rawValue)")
    }

    private var symbol: some View {
        Image(systemName: role.symbolName)
            .font(.system(size: iconSize, weight: theme.icon.symbolWeight))
            .foregroundStyle(stateStyle.accent)
            .frame(width: iconFrame, height: iconFrame)
            .background(symbolBackground)
            .clipShape(Circle())
            .accessibilityHidden(true)
    }

    private var labelStack: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxxs) {
            Text(role.title)
                .font(style == .row ? theme.typography.bodyEmphasized : theme.typography.caption)
                .foregroundStyle(theme.colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if showsDetail || style == .row {
                Text(role.detail)
                    .font(theme.typography.micro)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var stateStyle: AmbitionSemanticStyle {
        theme.semanticStyle(for: role.semanticState)
    }

    private var symbolBackground: Color {
        style == .inline ? Color.clear : stateStyle.fill
    }

    @ViewBuilder
    private var background: some View {
        if style == .inline {
            Color.clear
        } else {
            stateStyle.fill.opacity(style == .badge ? 0.70 : 0.46)
        }
    }

    private var padding: EdgeInsets {
        switch style {
        case .inline:
            EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        case .badge:
            EdgeInsets(top: theme.spacing.xxs, leading: theme.spacing.xs, bottom: theme.spacing.xxs, trailing: theme.spacing.xs)
        case .row:
            EdgeInsets(top: theme.spacing.sm, leading: theme.spacing.sm, bottom: theme.spacing.sm, trailing: theme.spacing.sm)
        }
    }

    private var radius: CGFloat {
        switch style {
        case .inline: theme.radius.sm
        case .badge: theme.radius.pill
        case .row: theme.radius.md
        }
    }

    private var iconSize: CGFloat {
        switch style {
        case .inline: theme.icon.smallSize
        case .badge: theme.icon.smallSize
        case .row: theme.icon.mediumSize
        }
    }

    private var iconFrame: CGFloat {
        switch style {
        case .inline: theme.icon.mediumSize
        case .badge: theme.icon.mediumSize + theme.spacing.xxxs
        case .row: theme.icon.largeSize + theme.spacing.xxs
        }
    }
}

public extension SourceFreshnessState {
    var statusSymbolRole: AmbitionsStatusSymbolRole {
        switch self {
        case .fresh: .sourceFresh
        case .partial: .sourcePartial
        case .stale: .sourceStale
        case .denied: .sourceDenied
        case .offline, .localOnly: .localOnly
        case .blocked: .unsafeBlocked
        case .unavailable: .packUnavailable
        }
    }
}

public extension TrustReceiptLayerKind {
    var statusSymbolRole: AmbitionsStatusSymbolRole {
        switch self {
        case .proofSaved, .moved, .undone: .proofSaved
        case .privateItem: .privacyProtected
        case .staleSource, .sourceChange: .sourceStale
        case .offlineLocal: .localOnly
        case .blockedSafely, .unsafeRedirect: .unsafeBlocked
        case .needsReview: .needsReview
        case .dreamHandling, .mutation: .receiptAvailable
        case .sourceConflict: .sourceConflict
        case .professionalBoundary: .professionalBoundary
        }
    }
}

public extension AmbitionsLoadingState {
    var statusSymbolRole: AmbitionsStatusSymbolRole {
        switch self {
        case .loading: .loading
        case .empty: .proofSaved
        case .noDataYet: .noDataYet
        case .disabledPendingValidation: .disabledPendingValidation
        case .staleSource: .sourceStale
        case .partialSource: .sourcePartial
        case .deniedSource: .sourceDenied
        case .sourceConflict: .sourceConflict
        case .packUnavailable: .packUnavailable
        case .iCloudUnavailable: .syncUnavailable
        case .localOnly: .localOnly
        case .updatePending: .proofPending
        case .privacySensitive: .privacySensitive
        case .crisisSupport: .crisisSupport
        case .unsafeBlocked: .unsafeBlocked
        case .waiting: .waiting
        case .needsReview: .needsReview
        case .recovery, .overwhelmingDay: .recoveryAvailable
        case .setupNeeded: .setupNeeded
        }
    }
}
#endif
