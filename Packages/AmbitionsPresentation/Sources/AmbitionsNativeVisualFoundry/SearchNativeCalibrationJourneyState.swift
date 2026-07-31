import Foundation

public enum SearchNativeCalibrationPresentationKind: String, Equatable, Sendable {
    case globalFullScreenTemporary = "Global · Full-screen · Temporary"
}

public struct SearchNativeCalibrationOrigin: Equatable, Sendable {
    public let rootIdentity: String
    public let initiatingControl: String
    public let presentationKind: SearchNativeCalibrationPresentationKind

    public static let neutralToday = SearchNativeCalibrationOrigin(
        rootIdentity: "Today",
        initiatingControl: "Search",
        presentationKind: .globalFullScreenTemporary
    )
}

public enum SearchNativeCalibrationRoute: Hashable, Sendable {
    case inspect(resultID: String)
    case ownerHandoff
}

public enum SearchNativeCalibrationFocusAnchor: Equatable, Sendable {
    case originSearchTrigger
    case query
    case result(String)
    case handoffPreparation
}

public struct SearchNativeCalibrationDismissedContext: Equatable, Sendable {
    public let query: String
    public let route: SearchNativeCalibrationRoute?
    public let selectedResultID: String?
}

public struct SearchNativeCalibrationJourneyState: Equatable, Sendable {
    public let origin: SearchNativeCalibrationOrigin
    public private(set) var isPresented: Bool
    public private(set) var query: String
    public private(set) var navigationPath: [SearchNativeCalibrationRoute]
    public private(set) var focusAnchor: SearchNativeCalibrationFocusAnchor
    public private(set) var selectedResultID: String?
    public private(set) var fixtureHandoffPrepared: Bool
    public private(set) var canonicalMutationCount: Int
    public private(set) var currentEventTruth: String
    public private(set) var lastDismissedContext: SearchNativeCalibrationDismissedContext?

    public init(
        origin: SearchNativeCalibrationOrigin = .neutralToday,
        isPresented: Bool = false,
        query: String = "",
        navigationPath: [SearchNativeCalibrationRoute] = [],
        focusAnchor: SearchNativeCalibrationFocusAnchor = .originSearchTrigger,
        selectedResultID: String? = nil,
        fixtureHandoffPrepared: Bool = false,
        canonicalMutationCount: Int = 0,
        currentEventTruth: String = "Tomorrow · 9:30 AM",
        lastDismissedContext: SearchNativeCalibrationDismissedContext? = nil
    ) {
        self.origin = origin
        self.isPresented = isPresented
        self.query = query
        self.navigationPath = navigationPath
        self.focusAnchor = focusAnchor
        self.selectedResultID = selectedResultID
        self.fixtureHandoffPrepared = fixtureHandoffPrepared
        self.canonicalMutationCount = canonicalMutationCount
        self.currentEventTruth = currentEventTruth
        self.lastDismissedContext = lastDismissedContext
    }

    public var currentRoute: SearchNativeCalibrationRoute? {
        navigationPath.last
    }

    public var originChromeVisible: Bool {
        isPresented == false
    }

    @discardableResult
    public mutating func presentSearch(query initialQuery: String = "") -> Bool {
        guard isPresented == false else { return false }
        isPresented = true
        query = initialQuery
        navigationPath = []
        selectedResultID = nil
        fixtureHandoffPrepared = false
        focusAnchor = .query
        return true
    }

    public mutating func updateQuery(_ value: String) {
        query = value
        navigationPath = []
        selectedResultID = nil
        fixtureHandoffPrepared = false
        focusAnchor = .query
    }

    @discardableResult
    public mutating func openInspect(resultID: String) -> Bool {
        guard isPresented, navigationPath.isEmpty else { return false }
        selectedResultID = resultID
        navigationPath = [.inspect(resultID: resultID)]
        focusAnchor = .result(resultID)
        return true
    }

    @discardableResult
    public mutating func openOwnerHandoff() -> Bool {
        guard isPresented, navigationPath.isEmpty else { return false }
        selectedResultID = "event.dentist-appointment"
        navigationPath = [.ownerHandoff]
        focusAnchor = .handoffPreparation
        return true
    }

    public mutating func restoreNavigationPath(_ path: [SearchNativeCalibrationRoute]) {
        let previousRoute = navigationPath.last
        navigationPath = path
        if let currentRoute = path.last {
            switch currentRoute {
            case let .inspect(resultID):
                selectedResultID = resultID
                focusAnchor = .result(resultID)
            case .ownerHandoff:
                selectedResultID = "event.dentist-appointment"
                focusAnchor = .handoffPreparation
            }
            return
        }
        switch previousRoute {
        case let .inspect(resultID):
            selectedResultID = resultID
            focusAnchor = .result(resultID)
        case .ownerHandoff:
            selectedResultID = "event.dentist-appointment"
            focusAnchor = .handoffPreparation
        case .none:
            break
        }
    }

    public mutating func cancelOwnerHandoff() {
        guard navigationPath.last == .ownerHandoff else { return }
        navigationPath = []
        selectedResultID = "event.dentist-appointment"
        fixtureHandoffPrepared = false
        focusAnchor = .handoffPreparation
    }

    public mutating func recordFixtureOnlyHandoff() {
        guard navigationPath.last == .ownerHandoff else { return }
        fixtureHandoffPrepared = true
    }

    public mutating func dismissSearch() {
        guard isPresented else { return }
        lastDismissedContext = SearchNativeCalibrationDismissedContext(
            query: query,
            route: navigationPath.last,
            selectedResultID: selectedResultID
        )
        isPresented = false
        navigationPath = []
        focusAnchor = .originSearchTrigger
    }
}
