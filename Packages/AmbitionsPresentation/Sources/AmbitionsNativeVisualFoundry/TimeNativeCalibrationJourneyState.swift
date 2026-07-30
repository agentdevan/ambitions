import Foundation

public enum TimeNativeCalibrationRoute: Hashable, Sendable {
    case focusedDay(TimeNativeCalibrationDayID)
    case conflictReview(proposalID: String)
}

public enum TimeNativeCalibrationFocusAnchor: Hashable, Sendable {
    case week
    case day(TimeNativeCalibrationDayID)
    case temporalObject(String)
    case conflictProposal(String)
}

public struct TimeNativeCalibrationJourneyState: Equatable, Sendable {
    public private(set) var selectedDayID: TimeNativeCalibrationDayID
    public private(set) var navigationPath: [TimeNativeCalibrationRoute]
    public private(set) var presentedObjectID: String?
    public private(set) var focusAnchor: TimeNativeCalibrationFocusAnchor

    private let fixture: TimeNativeCalibrationFixture

    public init(fixture: TimeNativeCalibrationFixture) {
        self.fixture = fixture
        selectedDayID = fixture.selectedDayID
        navigationPath = []
        presentedObjectID = nil
        focusAnchor = .day(fixture.selectedDayID)
    }

    public var hasMutation: Bool { false }

    public var currentRoute: TimeNativeCalibrationRoute? {
        navigationPath.last
    }

    @discardableResult
    public mutating func selectDay(_ dayID: TimeNativeCalibrationDayID) -> Bool {
        guard fixture.day(dayID) != nil, navigationPath.isEmpty else { return false }
        selectedDayID = dayID
        focusAnchor = .day(dayID)
        return true
    }

    @discardableResult
    public mutating func openFocusedDay() -> Bool {
        guard navigationPath.isEmpty else { return false }
        navigationPath.append(.focusedDay(selectedDayID))
        focusAnchor = .day(selectedDayID)
        return true
    }

    @discardableResult
    public mutating func presentObject(id: String) -> Bool {
        guard fixture.object(id: id) != nil, presentedObjectID == nil else { return false }
        presentedObjectID = id
        focusAnchor = .temporalObject(id)
        return true
    }

    @discardableResult
    public mutating func dismissObjectDetail() -> Bool {
        guard let objectID = presentedObjectID else { return false }
        presentedObjectID = nil
        focusAnchor = .temporalObject(objectID)
        return true
    }

    @discardableResult
    public mutating func openConflictReview(proposalID: String) -> Bool {
        guard
            let proposal = fixture.object(id: proposalID),
            proposal.truth == .proposedPlacement,
            proposal.conflictParticipantIDs.isEmpty == false,
            presentedObjectID == nil
        else { return false }
        navigationPath.append(.conflictReview(proposalID: proposalID))
        focusAnchor = .conflictProposal(proposalID)
        return true
    }

    @discardableResult
    public mutating func cancelConflictReview() -> Bool {
        guard case let .conflictReview(proposalID)? = navigationPath.last else { return false }
        navigationPath.removeLast()
        focusAnchor = .conflictProposal(proposalID)
        return true
    }

    @discardableResult
    public mutating func keepCurrent() -> Bool {
        cancelConflictReview()
    }

    public mutating func restoreNavigationPath(_ path: [TimeNativeCalibrationRoute]) {
        let priorRoute = navigationPath.last
        navigationPath = path
        presentedObjectID = nil
        if
            case let .conflictReview(proposalID)? = priorRoute,
            path.last != priorRoute {
            focusAnchor = .conflictProposal(proposalID)
            return
        }
        switch path.last {
        case let .focusedDay(dayID):
            selectedDayID = dayID
            focusAnchor = .day(dayID)
        case let .conflictReview(proposalID):
            focusAnchor = .conflictProposal(proposalID)
        case nil:
            focusAnchor = .day(selectedDayID)
        }
    }
}
