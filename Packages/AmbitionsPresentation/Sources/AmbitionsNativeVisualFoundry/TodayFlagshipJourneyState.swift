public enum TodayFlagshipJourneyPhase: String, Equatable, Sendable {
    case todayInitial = "today-initial"
    case focusedCurrent = "focused-current"
    case reviewingProposal = "reviewing-proposal"
    case savingAcceptedTruth = "saving-accepted-truth"
    case settled
    case todayReturned = "today-returned"
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

public enum TodayFlagshipFocusAnchor: String, Equatable, Sendable {
    case startHere = "start-here"
    case fullDayAction = "full-day-action"
    case fullDayNow = "full-day-now"
    case fullDayStep = "full-day-step"
    case focusedIdentity = "focused-identity"
    case reviewCurrentTruth = "review-current-truth"
    case saving
    case settledTruth = "settled-truth"
    case returnedSettledStep = "returned-settled-step"
    case interruption
    case recoveryReview = "recovery-review"
    case recoveredProgress = "recovered-progress"
}

public struct TodayFlagshipJourneyState: Equatable, Sendable {
    public private(set) var phase: TodayFlagshipJourneyPhase
    public private(set) var navigationPath: [TodayFlagshipRoute]
    public private(set) var acceptedTruth: String
    public private(set) var proposedTruth: String?
    public private(set) var focusAnchor: TodayFlagshipFocusAnchor
    public private(set) var hasCommittedMutation: Bool
    public private(set) var isHistoryExpanded: Bool

    private let primaryStepID: String
    private let revealedStartHereStepID: String
    private let proposalTruth: String
    private let settledTruth: String
    private let recoveryChoiceIDs: [String]

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
        primaryStepID = content.primaryStep.id
        revealedStartHereStepID = content.revealedStartHereStep.id
        proposalTruth = content.primaryStep.stillCountsProposal.proposedTruth
        settledTruth = content.primaryStep.stillCountsProposal.settledTruth
        recoveryChoiceIDs = content.recovery.availableChoices.map(\.id)
        todayReturnAnchorID = content.returnContract.focusAnchorID
        lastSavedProgress = content.recovery.lastSavedProgress
    }

    public var isReviewPresented: Bool {
        phase == .reviewingProposal || phase == .savingAcceptedTruth
    }

    public var isRecoveryPresented: Bool {
        phase == .recoveryReview
    }

    public var isCommitInFlight: Bool {
        phase == .savingAcceptedTruth
    }

    public var receiptIsVisible: Bool {
        phase == .settled || phase == .todayReturned
    }

    public var primaryStepIsStartHereEligible: Bool {
        phase != .settled && phase != .todayReturned
    }

    public var visibleStartHereStepID: String {
        phase == .todayReturned ? revealedStartHereStepID : primaryStepID
    }

    public var settledStepRemainsVisible: Bool {
        phase == .todayReturned
    }

    public var availableRecoveryChoiceIDs: [String] {
        phase == .recoveryReview ? recoveryChoiceIDs : []
    }

    public mutating func updateNavigationPath(_ path: [TodayFlagshipRoute]) {
        navigationPath = path
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

        navigationPath = path

        if
            previousPath == [
                .fullDay(origin: .todayInitial),
                .step(id: primaryStepID)
            ],
            path == [.fullDay(origin: .todayInitial)] {
            phase = .todayInitial
            proposedTruth = nil
            focusAnchor = .fullDayStep
            return
        }

        if previousPath == [.fullDay(origin: .todayInitial)], path.isEmpty {
            phase = .todayInitial
            focusAnchor = .fullDayAction
            return
        }

        if previousPath == [.fullDay(origin: .todayReturned)], path.isEmpty {
            phase = .todayReturned
            focusAnchor = .fullDayAction
            return
        }

        if previousPath == [.step(id: primaryStepID)], path.isEmpty {
            phase = .todayInitial
            proposedTruth = nil
            focusAnchor = .startHere
        }
    }

    @discardableResult
    public mutating func openStartHere() -> Bool {
        guard phase == .todayInitial else { return false }
        phase = .focusedCurrent
        navigationPath = [.step(id: primaryStepID)]
        focusAnchor = .focusedIdentity
        return true
    }

    @discardableResult
    public mutating func selectStillCounts() -> Bool {
        guard phase == .focusedCurrent || phase == .recoveredContinuation else {
            return false
        }
        phase = .reviewingProposal
        proposedTruth = proposalTruth
        focusAnchor = .reviewCurrentTruth
        return true
    }

    @discardableResult
    public mutating func cancelReview() -> Bool {
        guard phase == .reviewingProposal else { return false }
        phase = .focusedCurrent
        proposedTruth = nil
        focusAnchor = .focusedIdentity
        return true
    }

    @discardableResult
    public mutating func beginCommit() -> Bool {
        guard phase == .reviewingProposal else { return false }
        phase = .savingAcceptedTruth
        focusAnchor = .saving
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
        return true
    }

    @discardableResult
    public mutating func returnToToday() -> Bool {
        guard phase == .settled else { return false }
        phase = .todayReturned
        navigationPath = []
        focusAnchor = .returnedSettledStep
        isHistoryExpanded = false
        return true
    }

    @discardableResult
    public mutating func openHistory() -> Bool {
        guard phase == .settled else { return false }
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
        guard phase == .focusedCurrent || phase == .interrupted || phase == .recoveredContinuation else {
            return false
        }
        reconcileNavigationPath([])
        return true
    }

    @discardableResult
    public mutating func interrupt() -> Bool {
        guard phase == .focusedCurrent else { return false }
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
        case .reviewingProposal:
            _ = state.selectStillCounts()
        case .savingAcceptedTruth:
            _ = state.selectStillCounts()
            _ = state.beginCommit()
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
