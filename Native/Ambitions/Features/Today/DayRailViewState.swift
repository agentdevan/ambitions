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

struct StartHereContextEdgeState: Equatable {
    let title: String
    let summary: String
    let sourceLabel: String
}

struct StartHereTimeFitProofState: Equatable {
    let title: String
    let summary: String
    let detail: String
}

struct StartHereGoalThreadState: Equatable {
    let title: String
    let summary: String
    let detail: String
}

struct DayRailHeroStepState: Equatable {
    let id: String
    let title: String
    let subtitle: String
    let duration: DayRailDurationState
    let fitLabel: String
    let whySummary: String
    let sourceQualityLabel: String
    let becauseLine: String
    let receiptLabel: String
    let proofLabel: String
    let sourceRecordLabel: String
    let replayTraceLabel: String
    let replayInspectionLabel: String
    let contextEdge: StartHereContextEdgeState
    let timeFitProof: StartHereTimeFitProofState
    let goalThread: StartHereGoalThreadState
    let receiptItem: TrustReceiptLayerItem
    let primaryAction: TodayInlineAction
    let secondaryAction: TodayInlineAction?
    let detailTarget: DayRailDetailTargetState
    let sourceLabels: [DayRailSourceLabelState]

    init(
        id: String,
        title: String,
        subtitle: String,
        duration: DayRailDurationState,
        fitLabel: String,
        whySummary: String,
        sourceQualityLabel: String,
        becauseLine: String,
        receiptLabel: String = "",
        proofLabel: String = "",
        sourceRecordLabel: String = "",
        replayTraceLabel: String = "",
        replayInspectionLabel: String = "",
        contextEdge: StartHereContextEdgeState,
        timeFitProof: StartHereTimeFitProofState,
        goalThread: StartHereGoalThreadState,
        receiptItem: TrustReceiptLayerItem,
        primaryAction: TodayInlineAction,
        secondaryAction: TodayInlineAction?,
        detailTarget: DayRailDetailTargetState,
        sourceLabels: [DayRailSourceLabelState]
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.duration = duration
        self.fitLabel = fitLabel
        self.whySummary = whySummary
        self.sourceQualityLabel = sourceQualityLabel
        self.becauseLine = becauseLine
        self.receiptLabel = receiptLabel
        self.proofLabel = proofLabel
        self.sourceRecordLabel = sourceRecordLabel
        self.replayTraceLabel = replayTraceLabel
        self.replayInspectionLabel = replayInspectionLabel
        self.contextEdge = contextEdge
        self.timeFitProof = timeFitProof
        self.goalThread = goalThread
        self.receiptItem = receiptItem
        self.primaryAction = primaryAction
        self.secondaryAction = secondaryAction
        self.detailTarget = detailTarget
        self.sourceLabels = sourceLabels
    }
}

struct TodayStartHereReplayCoverageState: Equatable {
    let isInsideRealityMeridian: Bool
    let hasStartHereDecisionLayer: Bool
    let hasSourceRecord: Bool
    let hasReceipt: Bool
    let hasReplayTrace: Bool
    let isInspectableFromYou: Bool
    let missingRequirements: [String]

    var isGreen: Bool {
        missingRequirements.isEmpty
    }
}

struct TodayObjectStagePrimitiveContract: Equatable {
    let primitiveID: String
    let ownerSurface: String
    let productObject: String
    let firstViewportStructure: String
    let replacesFirstViewportStructures: [String]
    let sourceTrustLineOrder: [String]
    let accessibilityFallbacks: [String]
    let screenshotIdentifier: String
    let firstViewportAvoidsVisibleCardStructure: Bool

    static let current = TodayObjectStagePrimitiveContract(
        primitiveID: "today-object-stage",
        ownerSurface: "Today",
        productObject: "Reality Meridian / Start Here",
        firstViewportStructure: "Full-bleed object stage with the current time spine, Start here decision, inline source/trust line, and primary action.",
        replacesFirstViewportStructures: [
            "time-band panel",
            "topology tile grid",
            "fit and duration capsules",
            "source/trust strip item chrome"
        ],
        sourceTrustLineOrder: [
            "source",
            "freshness",
            "receipt",
            "privacy"
        ],
        accessibilityFallbacks: [
            "VoiceOver names Reality Meridian before Start here and source/trust proof",
            "Dynamic Type stacks source/trust labels without changing the object order",
            "Reduce Motion keeps the current-time relationship static",
            "Increase Contrast relies on semantic text and symbols rather than filled mini-containers",
            "Differentiate Without Color exposes source, freshness, receipt, and privacy as text"
        ],
        screenshotIdentifier: "TodayObjectStage",
        firstViewportAvoidsVisibleCardStructure: true
    )
}

extension DayRailHeroStepState {
    var startHereReplayCoverage: TodayStartHereReplayCoverageState {
        let checks = [
            ("Reality Meridian", true),
            ("Start here", primaryAction.title == "Start now" || primaryAction.title == "Open step"),
            ("Source", sourceRecordLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false),
            ("Receipt", receiptLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && receiptItem.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false),
            ("Reason", replayTraceLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && replayInspectionLabel.contains(replayTraceLabel)),
            ("You / What Ambitions knows", replayInspectionLabel.contains(sourceRecordLabel) && sourceRecordLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false)
        ]
        let missing = checks.compactMap { title, passes in passes ? nil : title }
        return TodayStartHereReplayCoverageState(
            isInsideRealityMeridian: true,
            hasStartHereDecisionLayer: primaryAction.title == "Start now" || primaryAction.title == "Open step",
            hasSourceRecord: sourceRecordLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
            hasReceipt: receiptLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && receiptItem.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
            hasReplayTrace: replayTraceLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false && replayInspectionLabel.contains(replayTraceLabel),
            isInspectableFromYou: replayInspectionLabel.contains(sourceRecordLabel) && sourceRecordLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
            missingRequirements: missing
        )
    }
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

struct DayRailContinuityMarkerState: Identifiable, Equatable {
    let id: String
    let kind: DayRailNodeKind
    let title: String
    let summary: String
    let detail: String
    let semanticState: AmbitionSemanticState
}

struct DayRailContinuityState: Equatable {
    let title: String
    let summary: String
    let markers: [DayRailContinuityMarkerState]
    let pressureLabel: String
    let noSilentChangesLabel: String
}

struct RealityMeridianContinuityProjectionState: Equatable {
    let primaryObjectTitle: String
    let recommendationTitle: String
    let recommendationSubtitle: String
    let timeRealityLabel: String
    let capacityLabel: String
    let sourceFreshnessLabel: String
    let proofLabel: String
    let provenanceLabel: String
    let recoveryLabel: String
    let continuationIdentity: String
    let restorationIdentity: String
    let sourceRecordLabel: String
    let receiptLabel: String
    let replayTraceLabel: String
    let youInspectionLabel: String
    let reducedMotionSummary: String
    let differentiateWithoutColorSummary: String
    let dynamicTypeSummary: String
    let voiceOverOrder: [String]

    var inspectionLabels: [String] {
        [
            sourceRecordLabel,
            receiptLabel,
            replayTraceLabel,
            youInspectionLabel,
        ]
    }
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
    let continuity: DayRailContinuityState
    let closureSlot: DayRailClosureSlotState
    let proofSlot: DayRailProofSlotState
}

extension RealityMeridianContinuityProjectionState {
    static func make(
        dayRail: AmbitionsDayRailViewState,
        heroStep: DayRailHeroStepState?,
        recommendedStep: TodayContractEntryState,
        todayTimeLayer: TodayTimeLayerState,
        dayState: TodayQualitativeDayState,
        recoveryLabel: String
    ) -> RealityMeridianContinuityProjectionState {
        let sourceRecordLabel = heroStep?.sourceRecordLabel ?? "Source record stays local"
        let receiptLabel = heroStep?.receiptLabel ?? "Start here receipt seam"
        let replayTraceLabel = heroStep?.replayTraceLabel ?? "Replay trace stays inspectable"
        let youInspectionLabel = "You / What Ambitions knows: \(sourceRecordLabel). \(replayTraceLabel)."
        let provenanceLabel = heroStep?.sourceQualityLabel
            ?? dayRail.contextLabels.first?.label
            ?? "Source-backed by the current Time shape"
        let capacityLabel = heroStep?.fitLabel ?? dayState.rawValue.capitalized
        let timeRealityLabel = todayTimeLayer.openWindowLabel
        let sourceFreshnessLabel = heroStep?.receiptItem.freshness.label ?? "Fresh source"
        let proofLabel = dayRail.proofSlot.title
        let reducedMotionSummary = "Reduced motion keeps the same order: \(timeRealityLabel), \(provenanceLabel), \(proofLabel)."
        let differentiateWithoutColorSummary = "Labels, node shapes, and order keep meaning visible without color."
        let dynamicTypeSummary = "Dynamic Type keeps the continuity as readable, stacked sentences."
        let voiceOverOrder = [
            "Reality Meridian",
            "Start here",
            recommendedStep.title,
            timeRealityLabel,
            sourceRecordLabel,
            receiptLabel,
            replayTraceLabel,
            youInspectionLabel,
            recoveryLabel,
        ]
        let continuityIdentity = [
            "reality-meridian",
            dayRail.id,
            recommendedStep.id,
            todayTimeLayer.compactTimelineLabel,
            recoveryLabel,
        ]
        .joined(separator: ".")

        return RealityMeridianContinuityProjectionState(
            primaryObjectTitle: "Reality Meridian",
            recommendationTitle: recommendedStep.title,
            recommendationSubtitle: recommendedStep.subtitle,
            timeRealityLabel: timeRealityLabel,
            capacityLabel: capacityLabel,
            sourceFreshnessLabel: sourceFreshnessLabel,
            proofLabel: proofLabel,
            provenanceLabel: provenanceLabel,
            recoveryLabel: recoveryLabel,
            continuationIdentity: continuityIdentity,
            restorationIdentity: continuityIdentity,
            sourceRecordLabel: sourceRecordLabel,
            receiptLabel: receiptLabel,
            replayTraceLabel: replayTraceLabel,
            youInspectionLabel: youInspectionLabel,
            reducedMotionSummary: reducedMotionSummary,
            differentiateWithoutColorSummary: differentiateWithoutColorSummary,
            dynamicTypeSummary: dynamicTypeSummary,
            voiceOverOrder: voiceOverOrder
        )
    }
}
