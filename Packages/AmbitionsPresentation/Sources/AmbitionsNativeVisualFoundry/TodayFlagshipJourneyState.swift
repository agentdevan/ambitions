public enum TodayFlagshipJourneyPhase: String, Equatable, Sendable {
    case todayInitial = "today-initial"
    case focusedCurrent = "focused-current"
    case reviewingProposal = "reviewing-proposal"
    case savingAcceptedTruth = "saving-accepted-truth"
    case failedSettlement = "failed-settlement"
    case settled
    case todayReturned = "today-returned"
    case focusedReturnedStartHere = "focused-returned-start-here"
    case interrupted
    case recoveryReview = "recovery-review"
    case recoveredContinuation = "recovered-continuation"
}

public enum TodayFlagshipFullDayOrigin: String, Equatable, Hashable, Sendable {
    case todayInitial
    case todayReturned
}

public enum TodayFlagshipRoute: Hashable, Sendable {
    case fullDay(origin: TodayFlagshipFullDayOrigin)
    case step(id: String)
}

public enum TodayFlagshipSupportingRoute: String, CaseIterable, Equatable, Sendable {
    case goalDetail = "goal-detail"
    case consequenceDetails = "consequence-details"
    case historyEntry = "history-entry"
    case historyFilters = "history-filters"
    case undoReview = "undo-review"
}

public enum TodayFlagshipFocusAnchor: String, Equatable, Sendable {
    case startHere = "start-here"
    case fullDayAction = "full-day-action"
    case fullDayNow = "full-day-now"
    case fullDayStep = "full-day-step"
    case focusedIdentity = "focused-identity"
    case reviewCurrentTruth = "review-current-truth"
    case saving
    case failedSettlement = "failed-settlement"
    case settledTruth = "settled-truth"
    case returnedSettledStep = "returned-settled-step"
    case interruption
    case recoveryReview = "recovery-review"
    case recoveredProgress = "recovered-progress"
    case goalDetail = "goal-detail"
    case consequenceDetails = "consequence-details"
    case historyEntry = "history-entry"
    case historyFilters = "history-filters"
    case undoReview = "undo-review"
}

public struct TodayFlagshipJourneyState: Equatable, Sendable {
    public private(set) var phase: TodayFlagshipJourneyPhase
    public private(set) var navigationPath: [TodayFlagshipRoute]
    public private(set) var acceptedTruth: String
    public private(set) var proposedTruth: String?
    public private(set) var focusAnchor: TodayFlagshipFocusAnchor
    public private(set) var hasCommittedMutation: Bool
    public private(set) var isHistoryExpanded: Bool
    public private(set) var supportingRoute: TodayFlagshipSupportingRoute?
    public private(set) var appliedInverseCommandID: String?
    public private(set) var focusedStepID: String?

    private let primaryStepID: String
    private let revealedStartHereStepID: String
    private let proposalTruth: String
    private let settledTruth: String
    private let recoveryChoiceIDs: [String]
    private let inverseIsAvailable: Bool
    private let inverseCommandID: String
    private let originalAcceptedTruth: String

    public let todayReturnAnchorID: String
    public let lastSavedProgress: String

    public init(content: TodayFlagshipCalibrationContent) {
        phase = .todayInitial
        navigationPath = []
        acceptedTruth = content.primaryStep.currentAcceptedTruth
        proposedTruth = nil
        focusAnchor = .startHere
        hasCommittedMutation = false
        isHistoryExpanded = false
        supportingRoute = nil
        appliedInverseCommandID = nil
        focusedStepID = nil
        primaryStepID = content.primaryStep.id
        revealedStartHereStepID = content.revealedStartHereStep.id
        proposalTruth = content.primaryStep.stillCountsProposal.proposedTruth
        settledTruth = content.primaryStep.stillCountsProposal.settledTruth
        recoveryChoiceIDs = content.recovery.availableChoices.map(\.id)
        inverseIsAvailable = content.supporting.inverse.isAvailable
        inverseCommandID = content.supporting.inverse.commandID
        originalAcceptedTruth = content.primaryStep.currentAcceptedTruth
        todayReturnAnchorID = content.returnContract.focusAnchorID
        lastSavedProgress = content.recovery.lastSavedProgress
    }

    public var isReviewPresented: Bool {
        phase == .reviewingProposal
            || phase == .savingAcceptedTruth
            || phase == .failedSettlement
    }

    public var isRecoveryPresented: Bool {
        phase == .recoveryReview
    }

    public var isCommitInFlight: Bool {
        phase == .savingAcceptedTruth
    }

    public var receiptIsVisible: Bool {
        phase == .settled || phase == .todayReturned || phase == .focusedReturnedStartHere
    }

    public var primaryStepIsStartHereEligible: Bool {
        phase != .settled && phase != .todayReturned && phase != .focusedReturnedStartHere
    }

    public var visibleStartHereStepID: String {
        phase == .todayReturned || phase == .focusedReturnedStartHere
            ? revealedStartHereStepID
            : primaryStepID
    }

    public var settledStepRemainsVisible: Bool {
        phase == .todayReturned || phase == .focusedReturnedStartHere
    }

    public var availableRecoveryChoiceIDs: [String] {
        phase == .recoveryReview ? recoveryChoiceIDs : []
    }

    @discardableResult
    public mutating func openFullDay() -> Bool {
        guard navigationPath.isEmpty else { return false }

        let origin: TodayFlagshipFullDayOrigin
        switch phase {
        case .todayInitial:
            origin = .todayInitial
        case .todayReturned:
            origin = .todayReturned
        default:
            return false
        }

        navigationPath.append(.fullDay(origin: origin))
        focusAnchor = .fullDayNow
        return true
    }

    @discardableResult
    public mutating func openStepFromFullDay(id: String) -> Bool {
        guard
            phase == .todayInitial,
            id == primaryStepID,
            navigationPath == [.fullDay(origin: .todayInitial)]
        else {
            return false
        }

        navigationPath.append(.step(id: id))
        phase = .focusedCurrent
        focusAnchor = .focusedIdentity
        return true
    }

    public mutating func reconcileNavigationPath(_ path: [TodayFlagshipRoute]) {
        let previousPath = navigationPath
        guard previousPath != path else { return }

        switch (previousPath, path) {
        case (
            [
                .fullDay(origin: .todayInitial),
                .step(id: primaryStepID)
            ],
            [.fullDay(origin: .todayInitial)]
        ):
            navigationPath = path
            phase = .todayInitial
            proposedTruth = nil
            supportingRoute = nil
            focusAnchor = .fullDayStep
        case (
            [
                .fullDay(origin: .todayInitial),
                .step(id: primaryStepID)
            ],
            []
        ):
            navigationPath = []
            phase = .todayInitial
            proposedTruth = nil
            supportingRoute = nil
            focusAnchor = .fullDayAction
        case ([.fullDay(origin: .todayInitial)], []):
            navigationPath = []
            phase = .todayInitial
            proposedTruth = nil
            supportingRoute = nil
            focusAnchor = .fullDayAction
        case ([.fullDay(origin: .todayReturned)], []):
            navigationPath = []
            phase = .todayReturned
            supportingRoute = nil
            focusAnchor = .fullDayAction
        case ([.step(id: primaryStepID)], []):
            navigationPath = []
            phase = .todayInitial
            proposedTruth = nil
            supportingRoute = nil
            focusedStepID = nil
            focusAnchor = .startHere
        case ([.step(id: revealedStartHereStepID)], []):
            navigationPath = []
            phase = .todayReturned
            proposedTruth = nil
            supportingRoute = nil
            focusedStepID = nil
            focusAnchor = .returnedSettledStep
        default:
            return
        }
    }

    @discardableResult
    public mutating func openStartHere() -> Bool {
        let stepID: String
        switch phase {
        case .todayInitial:
            phase = .focusedCurrent
            stepID = primaryStepID
        case .todayReturned:
            phase = .focusedReturnedStartHere
            stepID = revealedStartHereStepID
        default:
            return false
        }
        focusedStepID = stepID
        navigationPath = [.step(id: stepID)]
        focusAnchor = .focusedIdentity
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func selectStillCounts() -> Bool {
        guard
            supportingRoute == nil,
            phase == .focusedCurrent || phase == .recoveredContinuation
        else {
            return false
        }
        phase = .reviewingProposal
        proposedTruth = proposalTruth
        focusAnchor = .reviewCurrentTruth
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func cancelReview() -> Bool {
        guard phase == .reviewingProposal, supportingRoute == nil else { return false }
        phase = .focusedCurrent
        proposedTruth = nil
        focusAnchor = .focusedIdentity
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func beginCommit() -> Bool {
        guard phase == .reviewingProposal, supportingRoute == nil else { return false }
        phase = .savingAcceptedTruth
        focusAnchor = .saving
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func resolveCommit(succeeded: Bool) -> Bool {
        if succeeded {
            return settle()
        }
        return failCommit()
    }

    @discardableResult
    public mutating func failCommit() -> Bool {
        guard phase == .savingAcceptedTruth else { return false }
        phase = .failedSettlement
        focusAnchor = .failedSettlement
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func retryFailedCommit() -> Bool {
        guard phase == .failedSettlement, supportingRoute == nil else { return false }
        phase = .savingAcceptedTruth
        focusAnchor = .saving
        return true
    }

    @discardableResult
    public mutating func dismissFailedCommit() -> Bool {
        guard phase == .failedSettlement, supportingRoute == nil else { return false }
        phase = .focusedCurrent
        proposedTruth = nil
        focusAnchor = .focusedIdentity
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func settle() -> Bool {
        guard phase == .savingAcceptedTruth else { return false }
        phase = .settled
        acceptedTruth = settledTruth
        proposedTruth = nil
        focusAnchor = .settledTruth
        hasCommittedMutation = true
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func openSupportingRoute(_ route: TodayFlagshipSupportingRoute) -> Bool {
        guard supportingRoute == nil, isHistoryExpanded == false else { return false }

        let anchor: TodayFlagshipFocusAnchor
        switch (phase, route) {
        case (.focusedCurrent, .goalDetail), (.recoveredContinuation, .goalDetail):
            anchor = .goalDetail
        case (.reviewingProposal, .consequenceDetails),
             (.failedSettlement, .consequenceDetails):
            anchor = .consequenceDetails
        case (.settled, .historyEntry):
            anchor = .historyEntry
        case (.settled, .historyFilters):
            anchor = .historyFilters
        case (.settled, .undoReview) where inverseIsAvailable:
            anchor = .undoReview
        default:
            return false
        }

        supportingRoute = route
        focusAnchor = anchor
        return true
    }

    @discardableResult
    public mutating func applyEligibleInverse() -> Bool {
        guard
            phase == .settled,
            supportingRoute == .undoReview,
            inverseIsAvailable,
            isHistoryExpanded == false,
            appliedInverseCommandID == nil
        else {
            return false
        }

        acceptedTruth = originalAcceptedTruth
        proposedTruth = nil
        phase = .focusedCurrent
        navigationPath = [.step(id: primaryStepID)]
        supportingRoute = nil
        focusAnchor = .focusedIdentity
        appliedInverseCommandID = inverseCommandID
        hasCommittedMutation = true
        return true
    }

    @discardableResult
    public mutating func closeSupportingRoute() -> Bool {
        guard supportingRoute != nil else { return false }

        let restoredFocus: TodayFlagshipFocusAnchor
        switch phase {
        case .focusedCurrent, .recoveredContinuation:
            restoredFocus = .focusedIdentity
        case .reviewingProposal:
            restoredFocus = .reviewCurrentTruth
        case .failedSettlement:
            restoredFocus = .failedSettlement
        case .settled:
            restoredFocus = .settledTruth
        default:
            return false
        }

        supportingRoute = nil
        focusAnchor = restoredFocus
        return true
    }

    @discardableResult
    public mutating func returnToToday() -> Bool {
        guard phase == .settled, supportingRoute == nil else { return false }
        phase = .todayReturned
        navigationPath = []
        focusedStepID = nil
        focusAnchor = .returnedSettledStep
        isHistoryExpanded = false
        supportingRoute = nil
        return true
    }

    @discardableResult
    public mutating func openHistory() -> Bool {
        guard phase == .settled, supportingRoute == nil else { return false }
        isHistoryExpanded = true
        return true
    }

    @discardableResult
    public mutating func closeHistory() -> Bool {
        guard phase == .settled, isHistoryExpanded else { return false }
        isHistoryExpanded = false
        return true
    }

    @discardableResult
    public mutating func returnByNativeBackNavigation() -> Bool {
        guard
            supportingRoute == nil,
            phase == .focusedCurrent
                || phase == .focusedReturnedStartHere
                || phase == .interrupted
                || phase == .recoveredContinuation
        else {
            return false
        }
        reconcileNavigationPath([])
        return true
    }

    @discardableResult
    public mutating func interrupt() -> Bool {
        guard phase == .focusedCurrent, supportingRoute == nil else { return false }
        phase = .interrupted
        focusAnchor = .interruption
        return true
    }

    @discardableResult
    public mutating func openRecoveryReview() -> Bool {
        guard phase == .interrupted else { return false }
        phase = .recoveryReview
        focusAnchor = .recoveryReview
        return true
    }

    @discardableResult
    public mutating func dismissRecovery() -> Bool {
        guard phase == .recoveryReview else { return false }
        phase = .interrupted
        focusAnchor = .interruption
        return true
    }

    @discardableResult
    public mutating func leaveForLater() -> Bool {
        guard
            phase == .recoveryReview,
            recoveryChoiceIDs.contains("recovery.keep-step")
        else {
            return false
        }
        phase = .interrupted
        focusAnchor = .interruption
        return true
    }

    @discardableResult
    public mutating func continueFromSavedProgress() -> Bool {
        guard phase == .recoveryReview else { return false }
        phase = .recoveredContinuation
        focusAnchor = .recoveredProgress
        return true
    }
}

public extension TodayFlagshipJourneyState {
    static func preview(
        content: TodayFlagshipCalibrationContent,
        phase: TodayFlagshipJourneyPhase
    ) -> Self {
        var state = Self(content: content)
        guard phase != .todayInitial else { return state }

        _ = state.openStartHere()
        switch phase {
        case .todayInitial, .focusedCurrent:
            break
        case .focusedReturnedStartHere:
            _ = state.selectStillCounts()
            _ = state.beginCommit()
            _ = state.settle()
            _ = state.returnToToday()
            _ = state.openStartHere()
        case .reviewingProposal:
            _ = state.selectStillCounts()
        case .savingAcceptedTruth:
            _ = state.selectStillCounts()
            _ = state.beginCommit()
        case .failedSettlement:
            _ = state.selectStillCounts()
            _ = state.beginCommit()
            _ = state.failCommit()
        case .settled:
            _ = state.selectStillCounts()
            _ = state.beginCommit()
            _ = state.settle()
        case .todayReturned:
            _ = state.selectStillCounts()
            _ = state.beginCommit()
            _ = state.settle()
            _ = state.returnToToday()
        case .interrupted:
            _ = state.interrupt()
        case .recoveryReview:
            _ = state.interrupt()
            _ = state.openRecoveryReview()
        case .recoveredContinuation:
            _ = state.interrupt()
            _ = state.openRecoveryReview()
            _ = state.continueFromSavedProgress()
        }
        return state
    }
}
