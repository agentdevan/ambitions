import AmbitionsDesignSystem
import Foundation

enum DayRailMode: String, CaseIterable, Equatable {
    case normal
    case recovery
    case protected
    case overloaded
    case empty
    case noSchedule
}

enum DayRailRowSlot: String, CaseIterable, Equatable {
    case now
    case next
    case later
}

enum DayRailDurationSource: String, CaseIterable, Equatable {
    case userSet
    case suggested
    case historicallyBased
    case acceptedFromPlan
    case calendarBlock
    case notSet
}

enum DayRailDetailTargetKind: String, Equatable {
    case stepDetail
    case planContext
    case captureContext
    case unavailable
}

enum DayRailNodeKind: String, Equatable {
    case recommended
    case active
    case upcoming
    case flexible
    case closure
    case proof
    case protected
    case waiting
    case blocked
    case empty
}

struct DayRailDurationState: Equatable {
    let minutes: Int?
    let source: DayRailDurationSource
    let label: String
}

struct DayRailSourceLabelState: Identifiable, Equatable {
    let id: String
    let label: String
    let source: EventLedgerPrivacyClassification
}

struct DayRailDetailTargetState: Equatable {
    let kind: DayRailDetailTargetKind
    let goalID: String?
    let stepID: String?
    let draftID: String?
    let placeholderLabel: String
}


struct DayRailHeroStepState: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let duration: DayRailDurationState
    let fitLabel: String
    let whySummary: String
    let primaryAction: TodayInlineAction
    let detailTarget: DayRailDetailTargetState
    let sourceLabels: [DayRailSourceLabelState]
}

struct DayRailRowState: Identifiable, Equatable {
    let id: String
    let slot: DayRailRowSlot
    let title: String
    let subtitle: String
    let duration: DayRailDurationState
    let detailTarget: DayRailDetailTargetState
    let sourceLabels: [DayRailSourceLabelState]
}

struct DayRailClosureSlotState: Equatable {
    let title: String
    let subtitle: String
    let reservedForActionClosureSheet: Bool
}

struct DayRailProofSlotState: Equatable {
    let title: String
    let subtitle: String
    let noSilentChanges: Bool
    let reservedForReceiptPeek: Bool
}

struct DayRailPrivacyProjectionState: Equatable {
    let classification: EventLedgerPrivacyClassification
    let isSensitiveProjection: Bool
    let titleReplacement: String?
    let sourceLabel: String
}

struct AmbitionsDayRailViewState: Equatable {
    let id: String
    let mode: DayRailMode
    let dateTitle: String
    let contextSummary: String
    let heroStep: DayRailHeroStepState?
    let rows: [DayRailRowState]
    let primaryAction: TodayInlineAction?
    let rowTapDetailTargetPlaceholder: DayRailDetailTargetState?
    let durationSource: DayRailDurationSource
    let contextLabels: [DayRailSourceLabelState]
    let privacyProjection: DayRailPrivacyProjectionState
    let closureSlot: DayRailClosureSlotState
    let proofSlot: DayRailProofSlotState
}
