import AmbitionsDesignSystem
import Foundation

enum SourceInspectionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case staleCritical = "stale_critical"
    case unavailable
    case conflicted
    case revoked
    case unsupported
    case reviewRequired = "review_required"

    var userFacingTitle: String {
        switch self {
        case .current:
            "Current"
        case .stale:
            "May be out of date"
        case .staleCritical:
            "Too old to use"
        case .unavailable:
            "Source unavailable"
        case .conflicted:
            "Needs a conflict check"
        case .revoked:
            "No longer usable"
        case .unsupported:
            "Not supported here"
        case .reviewRequired:
            "Needs review"
        }
    }

    var userFacingSummary: String {
        switch self {
        case .current:
            "This public reference is recent enough for the current recommendation context."
        case .stale:
            "Ambitions can show this source as older context, but it should not silently change what you do next."
        case .staleCritical:
            "This reference is too old to guide a current recommendation."
        case .unavailable:
            "The reference detail is not available right now and cannot guide current use. Local planning can continue."
        case .conflicted:
            "The reference has conflicting public information and needs a check before it guides behavior."
        case .revoked:
            "This reference has been withdrawn and cannot guide current recommendations."
        case .unsupported:
            "This source type is not supported by this inspection detail and cannot guide current use."
        case .reviewRequired:
            "A person should review this source before Ambitions uses it to change a recommendation."
        }
    }

    var visualState: AmbitionVisualState {
        switch self {
        case .current:
            .success
        case .stale, .reviewRequired:
            .warning
        case .staleCritical, .unavailable, .conflicted, .revoked, .unsupported:
            .warning
        }
    }

    var blocksCurrentUse: Bool {
        switch self {
        case .current, .stale:
            false
        case .staleCritical, .unavailable, .conflicted, .revoked, .unsupported, .reviewRequired:
            true
        }
    }
}

struct SourceInspectionPublicDetail: Codable, Sendable, Equatable, Hashable {
    let sourceName: String
    let sourceKind: String
    let referenceTitle: String
    let retrievedLabel: String
    let freshnessLabel: String
    let useLabel: String

    init(
        sourceName: String,
        sourceKind: String,
        referenceTitle: String,
        retrievedLabel: String,
        freshnessLabel: String,
        useLabel: String
    ) {
        self.sourceName = sourceName
        self.sourceKind = sourceKind
        self.referenceTitle = referenceTitle
        self.retrievedLabel = retrievedLabel
        self.freshnessLabel = freshnessLabel
        self.useLabel = useLabel
    }
}

struct SourceInspectionPresentation: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let state: SourceInspectionState
    let title: String
    let subtitle: String
    let publicDetail: SourceInspectionPublicDetail
    let contextRows: [SourceInspectionRow]
    let privacySummary: String
    let hiddenByDefaultSummary: String
    let accessibilityLabel: String
    let accessibilityValue: String
    let accessibilityHint: String
    let semanticAnnouncement: String
    let redactionSummary: String
    let reduceMotionSummary: String

    init(
        id: String,
        state: SourceInspectionState,
        title: String,
        subtitle: String,
        publicDetail: SourceInspectionPublicDetail,
        contextRows: [SourceInspectionRow],
        privacySummary: String,
        hiddenByDefaultSummary: String,
        accessibilityLabel: String,
        accessibilityValue: String,
        accessibilityHint: String,
        semanticAnnouncement: String,
        redactionSummary: String,
        reduceMotionSummary: String
    ) {
        self.id = id
        self.state = state
        self.title = title
        self.subtitle = subtitle
        self.publicDetail = publicDetail
        self.contextRows = contextRows
        self.privacySummary = privacySummary
        self.hiddenByDefaultSummary = hiddenByDefaultSummary
        self.accessibilityLabel = accessibilityLabel
        self.accessibilityValue = accessibilityValue
        self.accessibilityHint = accessibilityHint
        self.semanticAnnouncement = semanticAnnouncement
        self.redactionSummary = redactionSummary
        self.reduceMotionSummary = reduceMotionSummary
    }

    static func make(
        id: String,
        state: SourceInspectionState,
        publicDetail: SourceInspectionPublicDetail,
        useContext: String,
        reviewAction: String
    ) -> SourceInspectionPresentation {
        let stateTitle = state.userFacingTitle
        let rows = [
            SourceInspectionRow(
                id: "source",
                title: "Reference",
                detail: "\(publicDetail.referenceTitle) from \(publicDetail.sourceName).",
                state: state.visualState
            ),
            SourceInspectionRow(
                id: "freshness",
                title: "Freshness",
                detail: publicDetail.freshnessLabel,
                state: state.visualState
            ),
            SourceInspectionRow(
                id: "use",
                title: "Use",
                detail: useContext,
                state: state.blocksCurrentUse ? .warning : .success
            ),
            SourceInspectionRow(
                id: "review",
                title: "Review",
                detail: reviewAction,
                state: state.blocksCurrentUse ? .warning : .default
            ),
        ]

        return SourceInspectionPresentation(
            id: id,
            state: state,
            title: "Source detail",
            subtitle: state.userFacingSummary,
            publicDetail: publicDetail,
            contextRows: rows,
            privacySummary: "Only public reference details are shown here. Personal goals, captures, schedules, proof, receipts, account secrets, and identifiers stay out of this detail.",
            hiddenByDefaultSummary: "Source detail appears only when requested or when a source state needs review.",
            accessibilityLabel: "Source detail, \(stateTitle)",
            accessibilityValue: "\(stateTitle). \(state.userFacingSummary) \(publicDetail.sourceName). \(publicDetail.freshnessLabel).",
            accessibilityHint: "Reviews public source context without opening a new product area.",
            semanticAnnouncement: "Source detail \(stateTitle.lowercased()). \(state.userFacingSummary)",
            redactionSummary: "Private life details are redacted from this inspection.",
            reduceMotionSummary: "Reduced motion keeps the same source state and review text without animated emphasis."
        )
    }
}

struct SourceInspectionRow: Identifiable, Sendable, Equatable, Hashable {
    let id: String
    let title: String
    let detail: String
    let state: AmbitionVisualState
}

enum SourceInspectionPresentationFixtures {
    static let all: [SourceInspectionPresentation] = SourceInspectionState.allCases.map { state in
        presentation(for: state)
    }

    static let defaultDetail = presentation(for: .current)

    static func presentation(for state: SourceInspectionState) -> SourceInspectionPresentation {
        SourceInspectionPresentation.make(
            id: "source-inspection-\(state.rawValue)",
            state: state,
            publicDetail: SourceInspectionPublicDetail(
                sourceName: "Public reference pack",
                sourceKind: "Official public reference",
                referenceTitle: referenceTitle(for: state),
                retrievedLabel: retrievedLabel(for: state),
                freshnessLabel: freshnessLabel(for: state),
                useLabel: useLabel(for: state)
            ),
            useContext: useContext(for: state),
            reviewAction: reviewAction(for: state)
        )
    }

    private static func referenceTitle(for state: SourceInspectionState) -> String {
        switch state {
        case .current:
            "Current eligibility reference"
        case .stale:
            "Older eligibility reference"
        case .staleCritical:
            "Expired eligibility reference"
        case .unavailable:
            "Unavailable reference detail"
        case .conflicted:
            "Conflicting public reference"
        case .revoked:
            "Withdrawn public reference"
        case .unsupported:
            "Unsupported reference type"
        case .reviewRequired:
            "Reference pending review"
        }
    }

    private static func retrievedLabel(for state: SourceInspectionState) -> String {
        switch state {
        case .current:
            "Checked recently"
        case .stale:
            "Checked earlier"
        case .staleCritical:
            "Past the allowed freshness window"
        case .unavailable:
            "Not available right now"
        case .conflicted:
            "Conflicting updates found"
        case .revoked:
            "Withdrawn by source"
        case .unsupported:
            "Not readable by this detail"
        case .reviewRequired:
            "Waiting for review"
        }
    }

    private static func freshnessLabel(for state: SourceInspectionState) -> String {
        switch state {
        case .current:
            "Fresh enough for current use"
        case .stale:
            "Older context only"
        case .staleCritical:
            "Too old for current use"
        case .unavailable:
            "No current source detail available"
        case .conflicted:
            "Conflicting public updates"
        case .revoked:
            "Withdrawn and blocked"
        case .unsupported:
            "Unsupported source type"
        case .reviewRequired:
            "Review needed before use"
        }
    }

    private static func useLabel(for state: SourceInspectionState) -> String {
        state.blocksCurrentUse ? "Blocked from current use" : "Available for local review"
    }

    private static func useContext(for state: SourceInspectionState) -> String {
        switch state {
        case .current:
            "Can support a local recommendation when the owning surface asks for source context."
        case .stale:
            "Can explain older context, but should not silently change a recommendation."
        case .staleCritical:
            "Cannot guide a current recommendation."
        case .unavailable:
            "Cannot guide current source-backed behavior, but local planning remains available."
        case .conflicted:
            "Cannot guide current behavior until the conflict is resolved."
        case .revoked:
            "Cannot guide current behavior."
        case .unsupported:
            "Cannot be inspected or used from this detail."
        case .reviewRequired:
            "Cannot change a recommendation until review is complete."
        }
    }

    private static func reviewAction(for state: SourceInspectionState) -> String {
        switch state {
        case .current:
            "No review needed right now."
        case .stale:
            "Review before using this source for a new recommendation."
        case .staleCritical:
            "Use local planning or another current public reference."
        case .unavailable:
            "Try again later or keep working from local context."
        case .conflicted:
            "Review the public references before use."
        case .revoked:
            "Keep it blocked unless a new public reference replaces it."
        case .unsupported:
            "Use a supported public reference instead."
        case .reviewRequired:
            "Review is required before use."
        }
    }
}
