import Foundation

public enum CaptureNativeCalibrationPresentationKind: String, Equatable, Sendable {
    case globalFullScreenTemporary = "Global · Full-screen · Temporary"
}

public struct CaptureNativeCalibrationOrigin: Equatable, Sendable {
    public let rootIdentity: String
    public let initiatingControl: String
    public let presentationKind: CaptureNativeCalibrationPresentationKind

    public static let neutralToday = CaptureNativeCalibrationOrigin(
        rootIdentity: "Today",
        initiatingControl: "Capture",
        presentationKind: .globalFullScreenTemporary
    )
}

public enum CaptureNativeCalibrationRootPhase: Equatable, Sendable {
    case expression
    case boundedMeaning
    case clarification
    case recovery
}

public enum CaptureNativeCalibrationRoute: Hashable, Sendable {
    case review
}

public enum CaptureNativeCalibrationFocusAnchor: Equatable, Sendable {
    case originCaptureTrigger
    case expressionEditor
    case boundedMeaningReview
    case clarificationResponse
    case recoveryContinue
    case reviewPrimaryAction
}

public enum CaptureNativeCalibrationCloseResult: Equatable, Sendable {
    case dismissedEmpty
    case confirmationRequired
}

public struct CaptureNativeCalibrationDismissedContext: Equatable, Sendable {
    public let expression: String
    public let clarification: String
    public let phase: CaptureNativeCalibrationRootPhase
    public let route: CaptureNativeCalibrationRoute?
}

public struct CaptureNativeCalibrationJourneyState: Equatable, Sendable {
    public let origin: CaptureNativeCalibrationOrigin
    public private(set) var isPresented: Bool
    public private(set) var expression: String
    public private(set) var clarificationResponse: String
    public private(set) var phase: CaptureNativeCalibrationRootPhase
    public private(set) var navigationPath: [CaptureNativeCalibrationRoute]
    public private(set) var focusAnchor: CaptureNativeCalibrationFocusAnchor
    public private(set) var clarificationCount: Int
    public private(set) var isCloseConfirmationPresented: Bool
    public private(set) var fixtureHandoffPrepared: Bool
    public private(set) var canonicalMutationCount: Int
    public private(set) var currentAcceptedTruth: String
    public private(set) var timeChronology: String
    public private(set) var lastDismissedContext: CaptureNativeCalibrationDismissedContext?

    public init(
        origin: CaptureNativeCalibrationOrigin = .neutralToday,
        isPresented: Bool = false,
        expression: String = "",
        clarificationResponse: String = "",
        phase: CaptureNativeCalibrationRootPhase = .expression,
        navigationPath: [CaptureNativeCalibrationRoute] = [],
        focusAnchor: CaptureNativeCalibrationFocusAnchor = .originCaptureTrigger,
        clarificationCount: Int = 0,
        isCloseConfirmationPresented: Bool = false,
        fixtureHandoffPrepared: Bool = false,
        canonicalMutationCount: Int = 0,
        currentAcceptedTruth: String = "Nothing has changed.",
        timeChronology: String = "Dentist appointment · Tomorrow · 9:30 AM",
        lastDismissedContext: CaptureNativeCalibrationDismissedContext? = nil
    ) {
        self.origin = origin
        self.isPresented = isPresented
        self.expression = expression
        self.clarificationResponse = clarificationResponse
        self.phase = phase
        self.navigationPath = navigationPath
        self.focusAnchor = focusAnchor
        self.clarificationCount = clarificationCount
        self.isCloseConfirmationPresented = isCloseConfirmationPresented
        self.fixtureHandoffPrepared = fixtureHandoffPrepared
        self.canonicalMutationCount = canonicalMutationCount
        self.currentAcceptedTruth = currentAcceptedTruth
        self.timeChronology = timeChronology
        self.lastDismissedContext = lastDismissedContext
    }

    public var originChromeVisible: Bool {
        isPresented == false
    }

    public var hasRetainedDraft: Bool {
        expression.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            || clarificationResponse.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }

    @discardableResult
    public mutating func presentCapture(expression initialExpression: String = "") -> Bool {
        guard isPresented == false else { return false }
        isPresented = true
        expression = initialExpression
        clarificationResponse = ""
        phase = .expression
        navigationPath = []
        focusAnchor = .expressionEditor
        clarificationCount = 0
        isCloseConfirmationPresented = false
        fixtureHandoffPrepared = false
        return true
    }

    public mutating func updateExpression(_ value: String) {
        expression = value
        phase = .expression
        navigationPath = []
        fixtureHandoffPrepared = false
        focusAnchor = .expressionEditor
    }

    public mutating func updateClarificationResponse(_ value: String) {
        clarificationResponse = value
        focusAnchor = .clarificationResponse
    }

    @discardableResult
    public mutating func continueExpression(
        using fixture: CaptureNativeCalibrationFixture
    ) -> Bool {
        switch fixture.interpretation(for: expression) {
        case .proposed:
            phase = .boundedMeaning
            focusAnchor = .boundedMeaningReview
            return true
        case .clarification:
            phase = .clarification
            if clarificationCount == 0 {
                clarificationCount = 1
            }
            focusAnchor = .clarificationResponse
            return true
        case .unsupported:
            focusAnchor = .expressionEditor
            return false
        }
    }

    @discardableResult
    public mutating func continueClarification(
        using fixture: CaptureNativeCalibrationFixture
    ) -> Bool {
        guard fixture.proposal(
            for: expression,
            clarification: clarificationResponse
        ) != nil else {
            focusAnchor = .clarificationResponse
            return false
        }
        phase = .boundedMeaning
        focusAnchor = .boundedMeaningReview
        return true
    }

    @discardableResult
    public mutating func openReview(
        using fixture: CaptureNativeCalibrationFixture
    ) -> Bool {
        guard
            isPresented,
            navigationPath.isEmpty,
            fixture.proposal(for: expression, clarification: clarificationResponse) != nil
        else {
            return false
        }
        navigationPath = [.review]
        focusAnchor = .reviewPrimaryAction
        return true
    }

    public mutating func restoreNavigationPath(_ path: [CaptureNativeCalibrationRoute]) {
        let previousRoute = navigationPath.last
        navigationPath = path
        if path.last == .review {
            focusAnchor = .reviewPrimaryAction
        } else if previousRoute == .review {
            focusAnchor = .boundedMeaningReview
        }
    }

    public mutating func changeWords() {
        navigationPath = []
        phase = .expression
        focusAnchor = .expressionEditor
    }

    public mutating func showRecovery() {
        guard hasRetainedDraft else { return }
        navigationPath = []
        phase = .recovery
        focusAnchor = .recoveryContinue
    }

    @discardableResult
    public mutating func continueFromRecovery(
        using fixture: CaptureNativeCalibrationFixture
    ) -> Bool {
        guard phase == .recovery else { return false }
        return openReview(using: fixture)
    }

    public mutating func recordFixtureOnlyHandoff() {
        guard navigationPath.last == .review else { return }
        fixtureHandoffPrepared = true
    }

    @discardableResult
    public mutating func requestCancel() -> CaptureNativeCalibrationCloseResult {
        if hasRetainedDraft {
            isCloseConfirmationPresented = true
            return .confirmationRequired
        }
        dismissCapture()
        return .dismissedEmpty
    }

    public mutating func keepEditing() {
        isCloseConfirmationPresented = false
        navigationPath = []
        phase = .expression
        focusAnchor = .expressionEditor
    }

    public mutating func discardAndClose() {
        isCloseConfirmationPresented = false
        dismissCapture()
    }

    public mutating func dismissCapture() {
        guard isPresented else { return }
        lastDismissedContext = CaptureNativeCalibrationDismissedContext(
            expression: expression,
            clarification: clarificationResponse,
            phase: phase,
            route: navigationPath.last
        )
        isPresented = false
        navigationPath = []
        focusAnchor = .originCaptureTrigger
    }
}
