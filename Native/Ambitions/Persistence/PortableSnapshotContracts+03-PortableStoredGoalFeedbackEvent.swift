import Foundation

struct PortableStoredGoalFeedbackEvent: Codable, Sendable, Equatable {
    let schemaVersion: String?
    let kind: GoalHistoryEventKind
    let base: GoalFeedbackEventBase
    let actualDuration: Int?
    let effortLevel: GoalFeedbackEffortLevel?
    let confidenceDelta: Double?
    let reasonCode: GoalStepSkipReasonCode?
    let timingAdjustment: GoalTimingAdjustment?
    let adjustedDate: String?
    let rewrittenText: String?
    let confusionType: GoalConfusionType?

    init(
        schemaVersion: String?,
        kind: GoalHistoryEventKind,
        base: GoalFeedbackEventBase,
        actualDuration: Int?,
        effortLevel: GoalFeedbackEffortLevel?,
        confidenceDelta: Double?,
        reasonCode: GoalStepSkipReasonCode?,
        timingAdjustment: GoalTimingAdjustment?,
        adjustedDate: String?,
        rewrittenText: String?,
        confusionType: GoalConfusionType?
    ) {
        self.schemaVersion = schemaVersion
        self.kind = kind
        self.base = base
        self.actualDuration = actualDuration
        self.effortLevel = effortLevel
        self.confidenceDelta = confidenceDelta
        self.reasonCode = reasonCode
        self.timingAdjustment = timingAdjustment
        self.adjustedDate = adjustedDate
        self.rewrittenText = rewrittenText
        self.confusionType = confusionType
    }

    init(event: GoalFeedbackEvent) {
        switch event {
        case let .completed(base, actualDuration, effortLevel, confidenceDelta):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .completed, base: base, actualDuration: actualDuration, effortLevel: effortLevel, confidenceDelta: confidenceDelta, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .skipped(base, reasonCode):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .skipped, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: reasonCode, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .delayed(base, timingAdjustment, date):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .delayed, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: timingAdjustment, adjustedDate: date, rewrittenText: nil, confusionType: nil)
        case let .edited(base, rewrittenText):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .edited, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: rewrittenText, confusionType: nil)
        case let .confused(base, confusionType):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .confused, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: confusionType)
        case let .tooBig(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .tooBig, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .tooEasy(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .tooEasy, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .notRelevant(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .notRelevant, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .askedForSmallerVersion(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .askedForSmallerVersion, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        case let .askedWhyThisMatters(base):
            self = PortableStoredGoalFeedbackEvent(schemaVersion: GoalFeedbackEventBase.schemaVersion, kind: .askedWhyThisMatters, base: base, actualDuration: nil, effortLevel: nil, confidenceDelta: nil, reasonCode: nil, timingAdjustment: nil, adjustedDate: nil, rewrittenText: nil, confusionType: nil)
        }
    }

    var event: GoalFeedbackEvent {
        switch kind {
        case .completed:
            return .completed(base: base, actualDuration: actualDuration, effortLevel: effortLevel ?? .medium, confidenceDelta: confidenceDelta)
        case .skipped:
            return .skipped(base: base, reasonCode: reasonCode ?? .notNow)
        case .delayed:
            return .delayed(base: base, timingAdjustment: timingAdjustment ?? .laterToday, date: adjustedDate)
        case .edited:
            return .edited(base: base, rewrittenText: rewrittenText ?? "")
        case .confused:
            return .confused(base: base, confusionType: confusionType ?? .unclearAction)
        case .tooBig:
            return .tooBig(base: base)
        case .tooEasy:
            return .tooEasy(base: base)
        case .notRelevant:
            return .notRelevant(base: base)
        case .askedForSmallerVersion:
            return .askedForSmallerVersion(base: base)
        case .askedWhyThisMatters:
            return .askedWhyThisMatters(base: base)
        }
    }
}

struct PortableStoredActionReceiptHistoryRecord: Codable, Sendable, Equatable {
    let receipt: ActionReceipt
    let privacyLevel: ActionReceiptPrivacyLevel
    let localOnly: Bool
    let proofRelevance: ActionReceiptProofRelevance
    let requiresConfirmationBeforeBroaderUse: Bool
    let proofFreshnessLineage: ActionReceiptProofFreshnessLineage

    init(
        receipt: ActionReceipt,
        privacyLevel: ActionReceiptPrivacyLevel,
        localOnly: Bool,
        proofRelevance: ActionReceiptProofRelevance,
        requiresConfirmationBeforeBroaderUse: Bool,
        proofFreshnessLineage: ActionReceiptProofFreshnessLineage
    ) {
        self.receipt = receipt
        self.privacyLevel = privacyLevel
        self.localOnly = localOnly
        self.proofRelevance = proofRelevance
        self.requiresConfirmationBeforeBroaderUse = requiresConfirmationBeforeBroaderUse
        self.proofFreshnessLineage = proofFreshnessLineage
    }

    init(_ record: ActionReceiptHistoryRecord) {
        self.init(
            receipt: record.receipt,
            privacyLevel: record.privacyLevel,
            localOnly: record.localOnly,
            proofRelevance: record.proofRelevance,
            requiresConfirmationBeforeBroaderUse: record.requiresConfirmationBeforeBroaderUse,
            proofFreshnessLineage: record.proofFreshnessLineage
        )
    }

    var record: ActionReceiptHistoryRecord {
        ActionReceiptHistoryRecord(
            receipt: receipt,
            privacyLevel: privacyLevel,
            localOnly: localOnly,
            proofRelevance: proofRelevance,
            requiresConfirmationBeforeBroaderUse: requiresConfirmationBeforeBroaderUse,
            proofFreshnessLineage: proofFreshnessLineage
        )
    }
}
