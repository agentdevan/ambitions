#if canImport(SwiftUI)
import SwiftUI

public enum TrustReceiptLayerKind: String, CaseIterable, Identifiable, Sendable {
    case proofSaved
    case moved
    case undone
    case privateItem
    case staleSource
    case offlineLocal
    case blockedSafely
    case needsReview
    case dreamHandling
    case sourceChange
    case mutation
    case unsafeRedirect
    case sourceConflict
    case professionalBoundary
    public var id: String { rawValue }
    public var title: String {
        switch self {
        case .proofSaved: "Proof saved"
        case .moved: "Moved with receipt"
        case .undone: "Undo recorded"
        case .privateItem: "Private receipt"
        case .staleSource: "Source may need review"
        case .offlineLocal: "Local only"
        case .blockedSafely: "Blocked safely"
        case .needsReview: "Needs review"
        case .dreamHandling: "Handling receipt"
        case .sourceChange: "Source change"
        case .mutation: "Mutation receipt"
        case .unsafeRedirect: "Unsafe redirect"
        case .sourceConflict: "Source conflict"
        case .professionalBoundary: "Professional boundary"
        }
    }
    public var symbolName: String {
        switch self {
        case .proofSaved: "checkmark.seal.fill"
        case .moved: "arrow.triangle.branch"
        case .undone: "arrow.uturn.backward.circle"
        case .privateItem: "lock.shield"
        case .staleSource: "clock.badge.exclamationmark"
        case .offlineLocal: "iphone"
        case .blockedSafely: "exclamationmark.shield"
        case .needsReview: "questionmark.folder"
        case .dreamHandling: "sparkles.rectangle.stack"
        case .sourceChange: "doc.badge.clock"
        case .mutation: "arrow.left.arrow.right.circle"
        case .unsafeRedirect: "hand.raised.circle"
        case .sourceConflict: "exclamationmark.arrow.triangle.2.circlepath"
        case .professionalBoundary: "person.crop.circle.badge.exclamationmark"
        }
    }
    public var visualState: LivingVisualState {
        switch self {
        case .proofSaved, .moved, .undone:
            return .proof
        case .privateItem, .offlineLocal:
            return .sensitive
        case .staleSource, .needsReview, .sourceChange, .sourceConflict, .professionalBoundary:
            return .stale
        case .blockedSafely, .unsafeRedirect:
            return .pressured
        case .dreamHandling, .mutation:
            return .active
        }
    }
}

public enum SourceFreshnessState: String, CaseIterable, Identifiable, Sendable {
    case fresh
    case partial
    case stale
    case denied
    case offline
    case localOnly
    case blocked
    case unavailable
    public var id: String { rawValue }
    public var label: String {
        switch self {
        case .fresh: "Fresh source"
        case .partial: "Partial source"
        case .stale: "Review context"
        case .denied: "Source denied"
        case .offline: "Offline"
        case .localOnly: "Local only"
        case .blocked: "Blocked"
        case .unavailable: "No source"
        }
    }
    public var detail: String {
        switch self {
        case .fresh: "Recently checked local evidence."
        case .partial: "Some evidence is visible; review before relying on it."
        case .stale: "Older evidence should be checked before reuse."
        case .denied: "Permission is not available."
        case .offline: "Stored on this device until source access returns."
        case .localOnly: "Private to this device unless the user changes it."
        case .blocked: "Ambitions will not act on this source."
        case .unavailable: "No source evidence is attached."
        }
    }
    var visualState: LivingVisualState {
        switch self {
        case .fresh: .proof
        case .partial: .active
        case .stale, .denied, .unavailable: .stale
        case .offline, .localOnly: .sensitive
        case .blocked: .pressured
        }
    }
}

public struct TrustReceiptLayerItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let kind: TrustReceiptLayerKind
    public let title: String
    public let summary: String
    public let sourceLabel: String
    public let freshness: SourceFreshnessState
    public let privacyLabel: String
    public let whyLabel: String?
    public let changeLabel: String?
    public let undoLabel: String?
    public let correctionLabel: String?
    public let reviewLabel: String?
    public let redactedDetail: String?

    public init(
        id: String,
        kind: TrustReceiptLayerKind,
        title: String,
        summary: String,
        sourceLabel: String,
        freshness: SourceFreshnessState,
        privacyLabel: String = "Private by default",
        whyLabel: String? = nil,
        changeLabel: String? = nil,
        undoLabel: String? = nil,
        correctionLabel: String? = nil,
        reviewLabel: String? = nil,
        redactedDetail: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.summary = summary
        self.sourceLabel = sourceLabel
        self.freshness = freshness
        self.privacyLabel = privacyLabel
        self.whyLabel = whyLabel
        self.changeLabel = changeLabel
        self.undoLabel = undoLabel
        self.correctionLabel = correctionLabel
        self.reviewLabel = reviewLabel
        self.redactedDetail = redactedDetail
    }

    public var accessibilitySummary: String {
        [
            kind.title,
            title,
            summary,
            sourceLabel,
            freshness.label,
            privacyLabel,
            whyLabel,
            changeLabel,
            correctionLabel,
            reviewLabel,
            undoLabel
        ]
        .compactMap { $0 }
        .joined(separator: ". ")
    }
}

public struct ReceiptDrawerSection: Identifiable, Equatable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String?
    public let items: [TrustReceiptLayerItem]

    public init(
        id: String,
        title: String,
        subtitle: String? = nil,
        items: [TrustReceiptLayerItem]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.items = items
    }
}

public struct SourceFreshnessLabel: View {
    @Environment(\.ambitionTheme) private var theme

    let state: SourceFreshnessState
    let label: String?

    public init(_ state: SourceFreshnessState, label: String? = nil) {
        self.state = state
        self.label = label
    }

    public var body: some View {
        EvidenceLabel(
            label ?? state.label,
            detail: state.detail,
            source: "Source freshness",
            state: state.visualState,
            context: .trust
        )
        .accessibilityIdentifier("trust.source-freshness.\(state.rawValue)")
    }
}

public enum SourceTrustReceiptStripRole: String, CaseIterable, Identifiable, Sendable {
    case source
    case freshness
    case privacy
    case receipt

    public var id: String { rawValue }

    var title: String {
        switch self {
        case .source: "Source"
        case .freshness: "Freshness"
        case .privacy: "Trust"
        case .receipt: "Receipt"
        }
    }

    var symbolName: String {
        switch self {
        case .source: "link.badge.plus"
        case .freshness: "clock.badge.checkmark"
        case .privacy: "lock.shield"
        case .receipt: "doc.text.magnifyingglass"
        }
    }
}

public struct SourceTrustReceiptStripItem: Identifiable, Equatable, Sendable {
    public let id: String
    public let role: SourceTrustReceiptStripRole
    public let value: String
    public let detail: String
    public let visualState: LivingVisualState

    public init(
        id: String,
        role: SourceTrustReceiptStripRole,
        value: String,
        detail: String,
        visualState: LivingVisualState
    ) {
        self.id = id
        self.role = role
        self.value = value
        self.detail = detail
        self.visualState = visualState
    }

    public var accessibilitySummary: String {
        "\(role.title). \(value). \(detail)"
    }

    public var primitiveSemanticToken: AmbitionPrimitiveSemanticToken {
        switch visualState {
        case .stale, .pressured:
            return .sourceAttention
        case .sensitive:
            return .privacyBoundary
        case .proof:
            switch role {
            case .source, .freshness:
                return .source
            case .privacy:
                return .privacyBoundary
            case .receipt:
                return .receipt
            }
        case .active, .calm, .empty:
            switch role {
            case .privacy:
                return .privacyBoundary
            case .receipt:
                return .receipt
            case .source, .freshness:
                return .source
            }
        case .recovery:
            return .receipt
        }
    }
}
#endif
