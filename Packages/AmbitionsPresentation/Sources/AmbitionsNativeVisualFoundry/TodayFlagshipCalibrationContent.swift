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
    public let ambitionsWordmark: String
    public let todayAccessibilityHeading: String
    public let nowAnchorTitle: String
    public let nextFixedAnchorTitle: String
    public let protectedAnchorTitle: String
    public let openLaneAnchorTitle: String
    public let viewFullDayTitle: String
    public let fullDayTitle: String
    public let scrollToNowTitle: String
    public let rootsGroupTitle: String
    public let globalActionsGroupTitle: String
    public let selectedRootValue: String
    public let openNavigationHint: String
    public let closeNavigationHint: String
    public let partOfRelationshipPrefix: String
    public let todayNavigationTitle: String
    public let goalsNavigationTitle: String
    public let timeNavigationTitle: String
    public let youNavigationTitle: String
    public let searchNavigationTitle: String
    public let captureNavigationTitle: String
    public let timeOwnerTitle: String
    public let offlineLocalTitle: String
    public let offlineLocalBody: String
    public let staleExternalTitle: String
    public let staleExternalBody: String
    public let conflictTransferTitle: String
    public let conflictTransferBody: String
    public let savingAnnouncement: String
    public let settlementAnnouncement: String
    public let interruptionAnnouncement: String
    public let recoveryAnnouncement: String
    public let returnAnnouncement: String
    public let timelineContextTitle: String
    public let openStartHereHint: String
    public let fallbackTodayTitle: String
    public let fallbackTodayBody: String
    public let stillCountsRationale: String
    public let chooseOutcomeTitle: String
    public let reviewStillCountsHint: String
    public let lastSavedProgressTitle: String
    public let addedToRelationshipTitle: String
    public let historyAvailableDetail: String
    public let recordIdentifierPrefix: String
    public let returnTodayHint: String
    public let interruptedStepTitle: String
    public let receiptAvailableDetail: String
    public let savedHistoryDetail: String
    public let commitProgressHint: String
    public let cancelReviewHint: String
    public let openNavigationLabel: String
    public let navigationCommandsHint: String
    public let closeNavigationLabel: String
    public let currentStateAccessibilityTitle: String
    public let proposedStateAccessibilityTitle: String
    public let settledStateAccessibilityTitle: String
    public let interruptedStateAccessibilityTitle: String

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
        timelineTitle: String,
        ambitionsWordmark: String,
        todayAccessibilityHeading: String,
        nowAnchorTitle: String,
        nextFixedAnchorTitle: String,
        protectedAnchorTitle: String,
        openLaneAnchorTitle: String,
        viewFullDayTitle: String,
        fullDayTitle: String,
        scrollToNowTitle: String,
        rootsGroupTitle: String,
        globalActionsGroupTitle: String,
        selectedRootValue: String,
        openNavigationHint: String,
        closeNavigationHint: String,
        partOfRelationshipPrefix: String,
        todayNavigationTitle: String,
        goalsNavigationTitle: String,
        timeNavigationTitle: String,
        youNavigationTitle: String,
        searchNavigationTitle: String,
        captureNavigationTitle: String,
        timeOwnerTitle: String,
        offlineLocalTitle: String,
        offlineLocalBody: String,
        staleExternalTitle: String,
        staleExternalBody: String,
        conflictTransferTitle: String,
        conflictTransferBody: String,
        savingAnnouncement: String,
        settlementAnnouncement: String,
        interruptionAnnouncement: String,
        recoveryAnnouncement: String,
        returnAnnouncement: String,
        timelineContextTitle: String,
        openStartHereHint: String,
        fallbackTodayTitle: String,
        fallbackTodayBody: String,
        stillCountsRationale: String,
        chooseOutcomeTitle: String,
        reviewStillCountsHint: String,
        lastSavedProgressTitle: String,
        addedToRelationshipTitle: String,
        historyAvailableDetail: String,
        recordIdentifierPrefix: String,
        returnTodayHint: String,
        interruptedStepTitle: String,
        receiptAvailableDetail: String,
        savedHistoryDetail: String,
        commitProgressHint: String,
        cancelReviewHint: String,
        openNavigationLabel: String,
        navigationCommandsHint: String,
        closeNavigationLabel: String,
        currentStateAccessibilityTitle: String,
        proposedStateAccessibilityTitle: String,
        settledStateAccessibilityTitle: String,
        interruptedStateAccessibilityTitle: String
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
        self.ambitionsWordmark = ambitionsWordmark
        self.todayAccessibilityHeading = todayAccessibilityHeading
        self.nowAnchorTitle = nowAnchorTitle
        self.nextFixedAnchorTitle = nextFixedAnchorTitle
        self.protectedAnchorTitle = protectedAnchorTitle
        self.openLaneAnchorTitle = openLaneAnchorTitle
        self.viewFullDayTitle = viewFullDayTitle
        self.fullDayTitle = fullDayTitle
        self.scrollToNowTitle = scrollToNowTitle
        self.rootsGroupTitle = rootsGroupTitle
        self.globalActionsGroupTitle = globalActionsGroupTitle
        self.selectedRootValue = selectedRootValue
        self.openNavigationHint = openNavigationHint
        self.closeNavigationHint = closeNavigationHint
        self.partOfRelationshipPrefix = partOfRelationshipPrefix
        self.todayNavigationTitle = todayNavigationTitle
        self.goalsNavigationTitle = goalsNavigationTitle
        self.timeNavigationTitle = timeNavigationTitle
        self.youNavigationTitle = youNavigationTitle
        self.searchNavigationTitle = searchNavigationTitle
        self.captureNavigationTitle = captureNavigationTitle
        self.timeOwnerTitle = timeOwnerTitle
        self.offlineLocalTitle = offlineLocalTitle
        self.offlineLocalBody = offlineLocalBody
        self.staleExternalTitle = staleExternalTitle
        self.staleExternalBody = staleExternalBody
        self.conflictTransferTitle = conflictTransferTitle
        self.conflictTransferBody = conflictTransferBody
        self.savingAnnouncement = savingAnnouncement
        self.settlementAnnouncement = settlementAnnouncement
        self.interruptionAnnouncement = interruptionAnnouncement
        self.recoveryAnnouncement = recoveryAnnouncement
        self.returnAnnouncement = returnAnnouncement
        self.timelineContextTitle = timelineContextTitle
        self.openStartHereHint = openStartHereHint
        self.fallbackTodayTitle = fallbackTodayTitle
        self.fallbackTodayBody = fallbackTodayBody
        self.stillCountsRationale = stillCountsRationale
        self.chooseOutcomeTitle = chooseOutcomeTitle
        self.reviewStillCountsHint = reviewStillCountsHint
        self.lastSavedProgressTitle = lastSavedProgressTitle
        self.addedToRelationshipTitle = addedToRelationshipTitle
        self.historyAvailableDetail = historyAvailableDetail
        self.recordIdentifierPrefix = recordIdentifierPrefix
        self.returnTodayHint = returnTodayHint
        self.interruptedStepTitle = interruptedStepTitle
        self.receiptAvailableDetail = receiptAvailableDetail
        self.savedHistoryDetail = savedHistoryDetail
        self.commitProgressHint = commitProgressHint
        self.cancelReviewHint = cancelReviewHint
        self.openNavigationLabel = openNavigationLabel
        self.navigationCommandsHint = navigationCommandsHint
        self.closeNavigationLabel = closeNavigationLabel
        self.currentStateAccessibilityTitle = currentStateAccessibilityTitle
        self.proposedStateAccessibilityTitle = proposedStateAccessibilityTitle
        self.settledStateAccessibilityTitle = settledStateAccessibilityTitle
        self.interruptedStateAccessibilityTitle = interruptedStateAccessibilityTitle
    }

    public func navigationTitle(for command: TodayFlagshipNavigationCommand) -> String {
        switch command {
        case .today: todayNavigationTitle
        case .goals: goalsNavigationTitle
        case .time: timeNavigationTitle
        case .you: youNavigationTitle
        case .search: searchNavigationTitle
        case .capture: captureNavigationTitle
        }
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
    public let startHereSummary: String
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
        startHereSummary: String,
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
        self.startHereSummary = startHereSummary
        self.temporalContext = temporalContext
        self.primaryActionTitle = primaryActionTitle
        self.stillCountsProposal = stillCountsProposal
    }
}

public enum TodayFlagshipTimelineRole: String, Equatable, Sendable {
    case now
    case ordinary
    case fixed
    case protected
    case external
    case openLane
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
    public let isOpenLane: Bool
    public let role: TodayFlagshipTimelineRole

    public init(
        id: String,
        canonicalObjectID: String,
        objectTitle: String,
        timeLabel: String,
        relationship: String,
        acceptedState: String,
        isProtected: Bool = false,
        isFixed: Bool = false,
        isOpenLane: Bool = false,
        role: TodayFlagshipTimelineRole? = nil
    ) {
        self.id = id
        self.canonicalObjectID = canonicalObjectID
        self.objectTitle = objectTitle
        self.timeLabel = timeLabel
        self.relationship = relationship
        self.acceptedState = acceptedState
        self.isProtected = isProtected
        self.isFixed = isFixed
        self.isOpenLane = isOpenLane
        self.role = role ?? Self.compatibilityRole(
            isProtected: isProtected,
            isFixed: isFixed,
            isOpenLane: isOpenLane
        )
    }

    private static func compatibilityRole(
        isProtected: Bool,
        isFixed: Bool,
        isOpenLane: Bool
    ) -> TodayFlagshipTimelineRole {
        if isProtected {
            return .protected
        }
        if isFixed {
            return .fixed
        }
        if isOpenLane {
            return .openLane
        }
        return .ordinary
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

public struct TodayFlagshipGoalContextSnapshot: Equatable, Identifiable, Sendable {
    public let id: String
    public let title: String
    public let whyItMatters: String
    public let currentPosture: String
    public let nextStepID: String

    public init(
        id: String,
        title: String,
        whyItMatters: String,
        currentPosture: String,
        nextStepID: String
    ) {
        self.id = id
        self.title = title
        self.whyItMatters = whyItMatters
        self.currentPosture = currentPosture
        self.nextStepID = nextStepID
    }
}

public struct TodayFlagshipTimeTransferSnapshot: Equatable, Sendable {
    public let title: String
    public let body: String
    public let sourceOwner: String
    public let destinationOwner: String
    public let isReadOnly: Bool
    public let isHostEvaluationOnly: Bool
    public let isProductRouteAvailable: Bool

    public init(
        title: String,
        body: String,
        sourceOwner: String,
        destinationOwner: String,
        isReadOnly: Bool,
        isHostEvaluationOnly: Bool,
        isProductRouteAvailable: Bool
    ) {
        self.title = title
        self.body = body
        self.sourceOwner = sourceOwner
        self.destinationOwner = destinationOwner
        self.isReadOnly = isReadOnly
        self.isHostEvaluationOnly = isHostEvaluationOnly
        self.isProductRouteAvailable = isProductRouteAvailable
    }
}

public struct TodayFlagshipHistoryEntrySnapshot: Equatable, Identifiable, Sendable {
    public let id: String
    public let recordedAtISO8601: String
    public let recordedTruth: String
    public let stepID: String
    public let goalID: String
    public let isLocalOnly: Bool

    public init(
        id: String,
        recordedAtISO8601: String,
        recordedTruth: String,
        stepID: String,
        goalID: String,
        isLocalOnly: Bool
    ) {
        self.id = id
        self.recordedAtISO8601 = recordedAtISO8601
        self.recordedTruth = recordedTruth
        self.stepID = stepID
        self.goalID = goalID
        self.isLocalOnly = isLocalOnly
    }
}

public struct TodayFlagshipInverseSnapshot: Equatable, Sendable {
    public let commandID: String
    public let title: String
    public let triggerReceiptID: String
    public let currentReceiptID: String?
    public let stepRevisionIsCurrent: Bool
    public let dependenciesAreCurrent: Bool
    public let hasNewerDependentCommand: Bool
    public let preservesHistory: Bool

    public init(
        commandID: String,
        title: String,
        triggerReceiptID: String,
        currentReceiptID: String?,
        stepRevisionIsCurrent: Bool,
        dependenciesAreCurrent: Bool,
        hasNewerDependentCommand: Bool,
        preservesHistory: Bool
    ) {
        self.commandID = commandID
        self.title = title
        self.triggerReceiptID = triggerReceiptID
        self.currentReceiptID = currentReceiptID
        self.stepRevisionIsCurrent = stepRevisionIsCurrent
        self.dependenciesAreCurrent = dependenciesAreCurrent
        self.hasNewerDependentCommand = hasNewerDependentCommand
        self.preservesHistory = preservesHistory
    }

    public var isAvailable: Bool {
        currentReceiptID == triggerReceiptID
            && stepRevisionIsCurrent
            && dependenciesAreCurrent
            && !hasNewerDependentCommand
            && preservesHistory
    }
}

public struct TodayFlagshipCommitFailureSnapshot: Equatable, Sendable {
    public let affectedStepID: String
    public let title: String
    public let body: String
    public let retryTitle: String
    public let dismissTitle: String
    public let preservesAcceptedTruth: Bool

    public init(
        affectedStepID: String,
        title: String,
        body: String,
        retryTitle: String,
        dismissTitle: String,
        preservesAcceptedTruth: Bool
    ) {
        self.affectedStepID = affectedStepID
        self.title = title
        self.body = body
        self.retryTitle = retryTitle
        self.dismissTitle = dismissTitle
        self.preservesAcceptedTruth = preservesAcceptedTruth
    }
}

public struct TodayFlagshipSupportingSnapshots: Equatable, Sendable {
    public let goal: TodayFlagshipGoalContextSnapshot
    public let timeTransfer: TodayFlagshipTimeTransferSnapshot
    public let history: TodayFlagshipHistoryEntrySnapshot
    public let inverse: TodayFlagshipInverseSnapshot
    public let commitFailure: TodayFlagshipCommitFailureSnapshot

    public init(
        goal: TodayFlagshipGoalContextSnapshot,
        timeTransfer: TodayFlagshipTimeTransferSnapshot,
        history: TodayFlagshipHistoryEntrySnapshot,
        inverse: TodayFlagshipInverseSnapshot,
        commitFailure: TodayFlagshipCommitFailureSnapshot
    ) {
        self.goal = goal
        self.timeTransfer = timeTransfer
        self.history = history
        self.inverse = inverse
        self.commitFailure = commitFailure
    }
}

public enum TodayFlagshipContextCondition: String, Equatable, Sendable {
    case offlineLocalTruth
    case staleExternalContext
    case conflictTransfer
}

public struct TodayFlagshipContextSeamSnapshot: Equatable, Sendable {
    public let condition: TodayFlagshipContextCondition
    public let title: String
    public let body: String
    public let affectedObjectID: String
    public let ownerTitle: String
    public let accessibilityLabel: String

    public init(
        condition: TodayFlagshipContextCondition,
        title: String,
        body: String,
        affectedObjectID: String,
        ownerTitle: String,
        accessibilityLabel: String
    ) {
        self.condition = condition
        self.title = title
        self.body = body
        self.affectedObjectID = affectedObjectID
        self.ownerTitle = ownerTitle
        self.accessibilityLabel = accessibilityLabel
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
    public let contextSeam: TodayFlagshipContextSeamSnapshot?
    public let supporting: TodayFlagshipSupportingSnapshots

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
        recovery: TodayFlagshipRecoverySnapshot,
        contextSeam: TodayFlagshipContextSeamSnapshot? = nil,
        supporting: TodayFlagshipSupportingSnapshots
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
        self.contextSeam = contextSeam
        self.supporting = supporting
    }

    public var returnedTodayTimeline: [TodayFlagshipTimelineObject] {
        timeline.filter {
            $0.canonicalObjectID != revealedStartHereStep.id
                && $0.canonicalObjectID != returnContract.settledStepID
        }
    }

    public var returnedTodayVisibleObjectIDs: [String] {
        [revealedStartHereStep.id, returnContract.settledStepID]
            + returnedTodayTimeline.map(\.canonicalObjectID)
    }

    public func nowAnchorObjectID(for origin: TodayFlagshipFullDayOrigin) -> String {
        switch origin {
        case .todayInitial:
            primaryStep.id
        case .todayReturned:
            revealedStartHereStep.id
        }
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
