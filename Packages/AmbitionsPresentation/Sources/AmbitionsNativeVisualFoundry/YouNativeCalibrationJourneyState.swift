public enum YouNativeCalibrationRoute: Hashable, Sendable {
    case appearance
}

public enum YouNativeCalibrationFocusAnchor: Equatable, Sendable {
    case none
    case domain(YouNativeCalibrationDomainID)
}

public struct YouNativeCalibrationJourneyState: Equatable, Sendable {
    public private(set) var navigationPath: [YouNativeCalibrationRoute]
    public private(set) var focusAnchor: YouNativeCalibrationFocusAnchor
    public private(set) var previewAppearance: YouNativeCalibrationAppearanceMode

    public init(
        navigationPath: [YouNativeCalibrationRoute] = [],
        focusAnchor: YouNativeCalibrationFocusAnchor = .none,
        previewAppearance: YouNativeCalibrationAppearanceMode = .system
    ) {
        self.navigationPath = navigationPath
        self.focusAnchor = focusAnchor
        self.previewAppearance = previewAppearance
    }

    public var currentRoute: YouNativeCalibrationRoute? {
        navigationPath.last
    }

    public var hasDurableMutation: Bool { false }

    @discardableResult
    public mutating func openAppearance() -> Bool {
        guard navigationPath.isEmpty else { return false }
        navigationPath = [.appearance]
        focusAnchor = .none
        return true
    }

    public mutating func restoreNavigationPath(_ path: [YouNativeCalibrationRoute]) {
        let returnedFromAppearance = navigationPath.last == .appearance && path.isEmpty
        navigationPath = path
        if returnedFromAppearance {
            focusAnchor = .domain(.appearance)
        }
    }

    @discardableResult
    public mutating func selectAppearance(_ appearance: YouNativeCalibrationAppearanceMode) -> Bool {
        guard previewAppearance != appearance else { return false }
        previewAppearance = appearance
        return true
    }
}
