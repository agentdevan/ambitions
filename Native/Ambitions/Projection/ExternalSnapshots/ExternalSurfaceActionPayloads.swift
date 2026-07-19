import Foundation

enum ExternalSurfaceActionName: String, Codable, Sendable, Equatable {
    case open
    case complete
    case snooze
    case delay
    case askForSmallerStep = "ask-for-smaller-step"
    case openToday = "open-today"
    case openCaptureComposer = "open-capture-composer"
    case openMemoryLens = "open-memory-lens"

    init(rawAction: String) {
        switch rawAction.lowercased() {
        case "complete":
            self = .complete
        case "delay":
            self = .delay
        case "snooze":
            self = .snooze
        case "ask-for-smaller-step", "smaller-step":
            self = .askForSmallerStep
        case "open-today":
            self = .openToday
        case "open-capture-composer":
            self = .openCaptureComposer
        case "open-memory-lens", "memory-lens":
            self = .openMemoryLens
        default:
            self = .open
        }
    }
}

enum ExternalSurfacePayloadSurface: String, Codable, Sendable, Equatable {
    case tab
    case goalDetail = "goal-detail"
    case captureComposer = "capture-composer"
}

enum ExternalSurfaceActionPayload {
    enum Key {
        static let action = "action"
        static let kind = "kind"
        static let root = "root"
        static let surface = "surface"
        static let goalID = "goalID"
        static let stepID = "stepID"
        static let receiptID = "receiptID"
        static let captureID = "captureID"
        static let draftID = "draftID"
        static let tab = "tab"
        static let metadataClass = "metadataClass"
        static let redaction = "redaction"
    }

    static func commandPayload(
        action: ExternalSurfaceActionName,
        surface: ExternalSurfacePayloadSurface,
        goalID: String? = nil,
        stepID: String? = nil,
        draftID: String? = nil,
        tab: String? = nil
    ) -> [String: String] {
        var payload = routePayload(
            surface: surface,
            goalID: goalID,
            stepID: stepID,
            draftID: draftID,
            tab: tab
        )
        payload[Key.action] = action.rawValue
        return payload
    }

    static func routePayload(
        surface: ExternalSurfacePayloadSurface,
        goalID: String? = nil,
        stepID: String? = nil,
        draftID: String? = nil,
        tab: String? = nil
    ) -> [String: String] {
        var payload: [String: String] = [
            Key.surface: surface.rawValue,
        ]

        if let goalID, goalID.isEmpty == false {
            payload[Key.goalID] = goalID
        }
        if let stepID, stepID.isEmpty == false {
            payload[Key.stepID] = stepID
        }
        if let draftID, draftID.isEmpty == false {
            payload[Key.draftID] = draftID
        }
        if let tab, tab.isEmpty == false {
            payload[Key.tab] = tab
        }

        return payload
    }

    static func deepLinkURL(
        surface: ExternalSurfacePayloadSurface,
        goalID: String? = nil,
        tab: String? = nil,
        origin: ExternalSurfaceOrigin? = nil
    ) -> URL? {
        var components = URLComponents()
        components.scheme = "ambitions"

        switch surface {
        case .tab:
            components.host = "tab"
            components.path = "/\(tab ?? "today")"
        case .goalDetail:
            guard let goalID, goalID.isEmpty == false else { return nil }
            components.host = "goal"
            components.path = "/\(goalID)"
        case .captureComposer:
            components.host = "overlay"
            components.path = "/quiet-command-sheet"
            components.queryItems = [URLQueryItem(name: "intent", value: "quick_capture")]
        }

        if let origin {
            var queryItems = components.queryItems ?? []
            queryItems.append(URLQueryItem(name: "origin", value: origin.rawValue))
            components.queryItems = queryItems
        }
        return components.url
    }

    static func safeDeepLinkURL(
        surface: ExternalSurfacePayloadSurface,
        goalID: String? = nil,
        tab: String? = nil,
        origin: ExternalSurfaceOrigin? = nil,
        fallbackTab: String = "today"
    ) -> URL? {
        deepLinkURL(surface: surface, goalID: goalID, tab: tab, origin: origin)
            ?? deepLinkURL(surface: .tab, tab: fallbackTab, origin: origin)
    }

    static func continuationPayload(for token: ExternalObjectContinuationToken) -> [String: String] {
        token.routePayload
    }
}

enum ExternalObjectReopeningMetadataClass: String, Codable, Sendable, Equatable {
    case canonicalRoot = "canonical_root"
    case exactReopen = "exact_reopen"
    case fallbackRoot = "fallback_root"
}

enum ExternalObjectReopeningRoot: String, Codable, Sendable, Equatable, CaseIterable {
    case today
    case goals
    case time
    case you

    var canonicalTitle: String {
        switch self {
        case .today:
            return "Today"
        case .goals:
            return "Goals"
        case .time:
            return "Time"
        case .you:
            return "You"
        }
    }

    var fallbackURL: URL? {
        switch self {
        case .today, .goals, .time, .you:
            return ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .tab, tab: rawValue)
        }
    }
}

enum ExternalObjectReopeningKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goal
    case currentStep = "current_step"
    case receipt
    case capture

    var safeSystemTitle: String {
        switch self {
        case .goal:
            return "Goal in Ambitions"
        case .currentStep:
            return "Step in Ambitions"
        case .receipt:
            return "Receipt in Ambitions"
        case .capture:
            return "Capture in Ambitions"
        }
    }

    var activityType: String {
        "com.ambitions.reopen.\(rawValue)"
    }
}

enum ExternalObjectReopeningRedaction: String, Codable, Sendable, Equatable {
    case safeSummary = "safe_summary"
    case redactedPrivate = "redacted_private"
}

struct ExternalObjectReopeningIndexGate: Codable, Sendable, Equatable {
    let isEnabled: Bool
    let reason: String

    static let disabledUntilProof = ExternalObjectReopeningIndexGate(
        isEnabled: false,
        reason: "Spotlight indexing stays disabled until device and privacy proof are complete."
    )

    static let internalOptIn = ExternalObjectReopeningIndexGate(
        isEnabled: true,
        reason: "Internal opt-in indexing with privacy-safe summaries only."
    )
}

struct ExternalObjectReopeningCandidate: Codable, Sendable, Equatable {
    let kind: ExternalObjectReopeningKind
    let id: String
    let title: String
    let detail: String
    let goalID: String?
    let stepID: String?
    let receiptID: String?
    let captureID: String?
    let isSensitive: Bool

    init(
        kind: ExternalObjectReopeningKind,
        id: String,
        title: String,
        detail: String,
        goalID: String? = nil,
        stepID: String? = nil,
        receiptID: String? = nil,
        captureID: String? = nil,
        isSensitive: Bool = true
    ) {
        self.kind = kind
        self.id = id
        self.title = title
        self.detail = detail
        self.goalID = goalID
        self.stepID = stepID
        self.receiptID = receiptID
        self.captureID = captureID
        self.isSensitive = isSensitive
    }
}

struct ExternalObjectReopeningIndexRecord: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let kind: ExternalObjectReopeningKind
    let domainIdentifier: String
    let title: String
    let contentDescription: String
    let routeURL: URL
    let redaction: ExternalObjectReopeningRedaction
    let eligibleForPublicIndexing: Bool
    let gateReason: String
}

struct ExternalObjectReopeningCanonicalRecord: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let root: ExternalObjectReopeningRoot
    let title: String
    let rootFallbackURL: URL
    let metadataClass: ExternalObjectReopeningMetadataClass
    let redaction: ExternalObjectReopeningRedaction
}

struct ExternalObjectContinuationToken: Codable, Sendable, Equatable, Identifiable {
    let kind: ExternalObjectReopeningKind
    let root: ExternalObjectReopeningRoot
    let goalID: String?
    let stepID: String?
    let receiptID: String?
    let captureID: String?
    let metadataClass: ExternalObjectReopeningMetadataClass
    let redaction: ExternalObjectReopeningRedaction

    var id: String {
        [
            kind.rawValue,
            root.rawValue,
            goalID ?? "goal:none",
            stepID ?? "step:none",
            receiptID ?? "receipt:none",
            captureID ?? "capture:none"
        ].joined(separator: "|")
    }
}

struct ExternalObjectReopeningHandoffRecord: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let kind: ExternalObjectReopeningKind
    let activityType: String
    let title: String
    let routeURL: URL
    let userInfo: [String: String]
    let eligibleForHandoff: Bool
}
