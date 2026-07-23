import Foundation

public struct TodayFlagshipPresentContext: Equatable, Sendable {
    public let dateISO8601: String
    public let relationship: String
    public let crownTitle: String

    public init(dateISO8601: String, relationship: String, crownTitle: String) {
        self.dateISO8601 = dateISO8601
        self.relationship = relationship
        self.crownTitle = crownTitle
    }
}

public struct TodayFlagshipInterfaceCopy: Equatable, Sendable {
    public let localeIdentifier: String
    public let startHereTitle: String
    public let stepTitle: String
    public let rightNowTitle: String
    public let whyItFitsTitle: String
    public let consequenceTitle: String
    public let reviewTitle: String
    public let reviewChangeTitle: String
    public let reviewRelationshipTitle: String
    public let detailsTitle: String
    public let historyTrustCue: String
    public let cancelTitle: String
    public let savingTitle: String
    public let savingBody: String
    public let settlementTitle: String
    public let settlementRelationshipPrefix: String
    public let viewHistoryTitle: String
    public let returnTodayTitle: String
    public let recoveryEntryTitle: String
    public let recoveryTitle: String
    public let recoveryBody: String
    public let timelineTitle: String

    public init(
        localeIdentifier: String,
        startHereTitle: String,
        stepTitle: String,
        rightNowTitle: String,
        whyItFitsTitle: String,
        consequenceTitle: String,
        reviewTitle: String,
        reviewChangeTitle: String,
        reviewRelationshipTitle: String,
        detailsTitle: String,
        historyTrustCue: String,
        cancelTitle: String,
        savingTitle: String,
        savingBody: String,
        settlementTitle: String,
        settlementRelationshipPrefix: String,
        viewHistoryTitle: String,
        returnTodayTitle: String,
        recoveryEntryTitle: String,
        recoveryTitle: String,
        recoveryBody: String,
        timelineTitle: String
    ) {
        self.localeIdentifier = localeIdentifier
        self.startHereTitle = startHereTitle
        self.stepTitle = stepTitle
        self.rightNowTitle = rightNowTitle
        self.whyItFitsTitle = whyItFitsTitle
        self.consequenceTitle = consequenceTitle
        self.reviewTitle = reviewTitle
        self.reviewChangeTitle = reviewChangeTitle
        self.reviewRelationshipTitle = reviewRelationshipTitle
        self.detailsTitle = detailsTitle
        self.historyTrustCue = historyTrustCue
        self.cancelTitle = cancelTitle
        self.savingTitle = savingTitle
        self.savingBody = savingBody
        self.settlementTitle = settlementTitle
        self.settlementRelationshipPrefix = settlementRelationshipPrefix
        self.viewHistoryTitle = viewHistoryTitle
        self.returnTodayTitle = returnTodayTitle
        self.recoveryEntryTitle = recoveryEntryTitle
        self.recoveryTitle = recoveryTitle
        self.recoveryBody = recoveryBody
        self.timelineTitle = timelineTitle
    }
}

public struct TodayFlagshipTemporalContext: Equatable, Sendable {
    public let exactTime: String
    public let relationship: String
    public let owner: String

    public init(exactTime: String, relationship: String, owner: String) {
        self.exactTime = exactTime
        self.relationship = relationship
        self.owner = owner
    }
}

public struct TodayFlagshipStillCountsProposal: Equatable, Sendable {
    public let outcomeTitle: String
    public let proposedTruth: String
    public let settledTruth: String
    public let exactConsequence: String
    public let affectedLineage: String
    public let proofRequirement: String
    public let createsProof: Bool
    public let createsReceipt: Bool
    public let appearsInHistory: Bool
    public let inverseAvailable: Bool
    public let commitActionTitle: String

    public init(
        outcomeTitle: String,
        proposedTruth: String,
        settledTruth: String,
        exactConsequence: String,
        affectedLineage: String,
        proofRequirement: String,
        createsProof: Bool,
        createsReceipt: Bool,
        appearsInHistory: Bool,
        inverseAvailable: Bool,
        commitActionTitle: String
    ) {
        self.outcomeTitle = outcomeTitle
        self.proposedTruth = proposedTruth
        self.settledTruth = settledTruth
        self.exactConsequence = exactConsequence
        self.affectedLineage = affectedLineage
        self.proofRequirement = proofRequirement
        self.createsProof = createsProof
        self.createsReceipt = createsReceipt
        self.appearsInHistory = appearsInHistory
        self.inverseAvailable = inverseAvailable
        self.commitActionTitle = commitActionTitle
    }
}

public struct TodayFlagshipStepSnapshot: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let parentPursuitID: String
    public let parentPursuitTitle: String
    public let currentAcceptedTruth: String
    public let whyItFitsNow: String
    public let materialConsequence: String
    public let temporalContext: TodayFlagshipTemporalContext
    public let primaryActionTitle: String
    public let stillCountsProposal: TodayFlagshipStillCountsProposal

    public init(
        id: String,
        title: String,
        parentPursuitID: String,
        parentPursuitTitle: String,
        currentAcceptedTruth: String,
        whyItFitsNow: String,
        materialConsequence: String,
        temporalContext: TodayFlagshipTemporalContext,
        primaryActionTitle: String,
        stillCountsProposal: TodayFlagshipStillCountsProposal
    ) {
        self.id = id
        self.title = title
        self.parentPursuitID = parentPursuitID
        self.parentPursuitTitle = parentPursuitTitle
        self.currentAcceptedTruth = currentAcceptedTruth
        self.whyItFitsNow = whyItFitsNow
        self.materialConsequence = materialConsequence
        self.temporalContext = temporalContext
        self.primaryActionTitle = primaryActionTitle
        self.stillCountsProposal = stillCountsProposal
    }
}

public struct TodayFlagshipTimelineObject: Equatable, Identifiable, Sendable {
    public let id: String
    public let canonicalObjectID: String
    public let objectTitle: String
    public let timeLabel: String
    public let relationship: String
    public let acceptedState: String
    public let isProtected: Bool
    public let isFixed: Bool

    public init(
        id: String,
        canonicalObjectID: String,
        objectTitle: String,
        timeLabel: String,
        relationship: String,
        acceptedState: String,
        isProtected: Bool = false,
        isFixed: Bool = false
    ) {
        self.id = id
        self.canonicalObjectID = canonicalObjectID
        self.objectTitle = objectTitle
        self.timeLabel = timeLabel
        self.relationship = relationship
        self.acceptedState = acceptedState
        self.isProtected = isProtected
        self.isFixed = isFixed
    }
}

public struct TodayFlagshipReceiptSnapshot: Equatable, Identifiable, Sendable {
    public let id: String
    public let historyID: String
    public let recordedLabel: String
    public let receiptSummary: String
    public let historySummary: String
    public let proofLabel: String

    public init(
        id: String,
        historyID: String,
        recordedLabel: String,
        receiptSummary: String,
        historySummary: String,
        proofLabel: String
    ) {
        self.id = id
        self.historyID = historyID
        self.recordedLabel = recordedLabel
        self.receiptSummary = receiptSummary
        self.historySummary = historySummary
        self.proofLabel = proofLabel
    }
}

public struct TodayFlagshipReturnContract: Equatable, Sendable {
    public let settledStepID: String
    public let newStartHereStepID: String
    public let focusAnchorID: String
    public let settledLocationTitle: String

    public init(
        settledStepID: String,
        newStartHereStepID: String,
        focusAnchorID: String,
        settledLocationTitle: String
    ) {
        self.settledStepID = settledStepID
        self.newStartHereStepID = newStartHereStepID
        self.focusAnchorID = focusAnchorID
        self.settledLocationTitle = settledLocationTitle
    }
}

public struct TodayFlagshipRecoveryChoice: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let consequence: String

    public init(id: String, title: String, consequence: String) {
        self.id = id
        self.title = title
        self.consequence = consequence
    }
}

public struct TodayFlagshipRecoverySnapshot: Equatable, Sendable {
    public let stepID: String
    public let interruptionTitle: String
    public let interruptionDetail: String
    public let lastSavedProgress: String
    public let availableChoices: [TodayFlagshipRecoveryChoice]

    public init(
        stepID: String,
        interruptionTitle: String,
        interruptionDetail: String,
        lastSavedProgress: String,
        availableChoices: [TodayFlagshipRecoveryChoice]
    ) {
        self.stepID = stepID
        self.interruptionTitle = interruptionTitle
        self.interruptionDetail = interruptionDetail
        self.lastSavedProgress = lastSavedProgress
        self.availableChoices = availableChoices
    }
}

public struct TodayFlagshipCalibrationContent: Equatable, Identifiable, Sendable {
    public var id: String { familyID }

    public let familyID: String
    public let isSynthetic: Bool
    public let interfaceCopy: TodayFlagshipInterfaceCopy
    public let presentContext: TodayFlagshipPresentContext
    public let primaryStep: TodayFlagshipStepSnapshot
    public let revealedStartHereStep: TodayFlagshipStepSnapshot
    public let timeline: [TodayFlagshipTimelineObject]
    public let receipt: TodayFlagshipReceiptSnapshot
    public let returnContract: TodayFlagshipReturnContract
    public let recovery: TodayFlagshipRecoverySnapshot

    public init(
        familyID: String,
        isSynthetic: Bool,
        interfaceCopy: TodayFlagshipInterfaceCopy,
        presentContext: TodayFlagshipPresentContext,
        primaryStep: TodayFlagshipStepSnapshot,
        revealedStartHereStep: TodayFlagshipStepSnapshot,
        timeline: [TodayFlagshipTimelineObject],
        receipt: TodayFlagshipReceiptSnapshot,
        returnContract: TodayFlagshipReturnContract,
        recovery: TodayFlagshipRecoverySnapshot
    ) {
        self.familyID = familyID
        self.isSynthetic = isSynthetic
        self.interfaceCopy = interfaceCopy
        self.presentContext = presentContext
        self.primaryStep = primaryStep
        self.revealedStartHereStep = revealedStartHereStep
        self.timeline = timeline
        self.receipt = receipt
        self.returnContract = returnContract
        self.recovery = recovery
    }

    public var returnedTodayTimeline: [TodayFlagshipTimelineObject] {
        timeline.filter { $0.canonicalObjectID != revealedStartHereStep.id }
    }
}

public enum TodayFlagshipNavigationCommand: String, CaseIterable, Equatable, Identifiable, Sendable {
    case today
    case goals
    case time
    case you
    case search
    case capture

    public static let roots: [Self] = [.today, .goals, .time, .you]
    public static let globalActions: [Self] = [.search, .capture]

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .today: "Today"
        case .goals: "Goals"
        case .time: "Time"
        case .you: "You"
        case .search: "Search"
        case .capture: "Capture"
        }
    }

    public var symbolName: String {
        switch self {
        case .today: "sun.max"
        case .goals: "target"
        case .time: "clock"
        case .you: "person.crop.circle"
        case .search: "magnifyingglass"
        case .capture: "plus"
        }
    }

    public var isSelectedRoot: Bool { self == .today }
}
