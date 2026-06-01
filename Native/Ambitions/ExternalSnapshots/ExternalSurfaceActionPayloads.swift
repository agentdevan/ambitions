import Foundation

enum ExternalSurfaceActionName: String, Codable, Sendable, Equatable {
    case open
    case complete
    case snooze
    case delay
    case askForSmallerStep = "ask-for-smaller-step"
    case openToday = "open-today"
    case openCapturesInbox = "open-captures-inbox"
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
        case "open-captures-inbox":
            self = .openCapturesInbox
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
    case captureInbox = "captures-inbox"
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
        case .captureInbox:
            components.host = "captures"
            components.path = "/inbox"
        }

        if let origin {
            components.queryItems = [URLQueryItem(name: "origin", value: origin.rawValue)]
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
    case capture
    case time
    case you

    var canonicalTitle: String {
        switch self {
        case .today:
            return "Reality Meridian"
        case .goals:
            return "Constellation Atlas"
        case .capture:
            return "Atmosphere Composer"
        case .time:
            return "LifeShape Field"
        case .you:
            return "User System Profile"
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

struct ExternalObjectReopeningProjector: Sendable {
    func canonicalRecords(
        gate: ExternalObjectReopeningIndexGate = .disabledUntilProof
    ) -> [ExternalObjectReopeningCanonicalRecord] {
        guard gate.isEnabled else { return [] }
        return ExternalObjectReopeningRoot.allCases.compactMap { root in
            guard let rootFallbackURL = ExternalSurfaceActionPayload.safeDeepLinkURL(surface: .tab, tab: root.rawValue) else {
                return nil
            }
            return ExternalObjectReopeningCanonicalRecord(
                id: root.rawValue,
                root: root,
                title: root.canonicalTitle,
                rootFallbackURL: rootFallbackURL,
                metadataClass: .canonicalRoot,
                redaction: .safeSummary
            )
        }
    }

    func indexRecords(
        for candidates: [ExternalObjectReopeningCandidate],
        gate: ExternalObjectReopeningIndexGate = .disabledUntilProof
    ) -> [ExternalObjectReopeningIndexRecord] {
        guard gate.isEnabled else { return [] }
        return candidates.compactMap { candidate in
            guard let routeURL = routeURL(for: candidate, origin: .spotlight) else { return nil }
            let redaction = candidate.isSensitive ? ExternalObjectReopeningRedaction.redactedPrivate : .safeSummary
            return ExternalObjectReopeningIndexRecord(
                id: candidate.id,
                kind: candidate.kind,
                domainIdentifier: "ambitions.\(candidate.kind.rawValue)",
                title: safeTitle(for: candidate),
                contentDescription: safeDetail(for: candidate),
                routeURL: routeURL,
                redaction: redaction,
                eligibleForPublicIndexing: false,
                gateReason: gate.reason
            )
        }
    }

    func handoffRecord(for candidate: ExternalObjectReopeningCandidate) -> ExternalObjectReopeningHandoffRecord? {
        guard candidate.kind == .goal || candidate.kind == .currentStep,
              let routeURL = routeURL(for: candidate, origin: .handoff) else {
            return nil
        }
        var userInfo: [String: String] = [
            "kind": candidate.kind.rawValue,
            "id": candidate.id,
        ]
        if let goalID = nonEmpty(candidate.goalID) {
            userInfo["goalID"] = goalID
        }
        if let stepID = nonEmpty(candidate.stepID) {
            userInfo["stepID"] = stepID
        }

        return ExternalObjectReopeningHandoffRecord(
            id: candidate.id,
            kind: candidate.kind,
            activityType: candidate.kind.activityType,
            title: safeTitle(for: candidate),
            routeURL: routeURL,
            userInfo: userInfo,
            eligibleForHandoff: true
        )
    }

    private func routeURL(
        for candidate: ExternalObjectReopeningCandidate,
        origin: ExternalSurfaceOrigin
    ) -> URL? {
        continuationToken(for: candidate).routeURL(origin: origin)
    }

    private func continuationToken(for candidate: ExternalObjectReopeningCandidate) -> ExternalObjectContinuationToken {
        ExternalObjectContinuationToken(
            kind: candidate.kind,
            root: fallbackRoot(for: candidate.kind),
            goalID: nonEmpty(candidate.goalID),
            stepID: nonEmpty(candidate.stepID),
            receiptID: nonEmpty(candidate.receiptID),
            captureID: nonEmpty(candidate.captureID),
            metadataClass: candidate.isSensitive ? .fallbackRoot : .exactReopen,
            redaction: candidate.isSensitive ? .redactedPrivate : .safeSummary
        )
    }
}

private extension ExternalObjectReopeningProjector {
    func fallbackRoot(for kind: ExternalObjectReopeningKind) -> ExternalObjectReopeningRoot {
        switch kind {
        case .goal, .currentStep:
            return .goals
        case .receipt:
            return .today
        case .capture:
            return .capture
        }
    }

    private func safeTitle(for candidate: ExternalObjectReopeningCandidate) -> String {
        guard candidate.isSensitive == false, let title = nonEmpty(candidate.title) else {
            return candidate.kind.safeSystemTitle
        }
        return truncated(title, limit: 64)
    }

    private func safeDetail(for candidate: ExternalObjectReopeningCandidate) -> String {
        guard candidate.isSensitive == false, let detail = nonEmpty(candidate.detail) else {
            return "Details stay private until you open Ambitions."
        }
        return truncated(detail, limit: 96)
    }

    private func truncated(_ value: String, limit: Int) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count > limit else { return trimmed }
        let end = trimmed.index(trimmed.startIndex, offsetBy: limit)
        return String(trimmed[..<end])
    }

    private func nonEmpty(_ value: String?) -> String? {
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed?.isEmpty == false ? trimmed : nil
    }
}

extension ExternalObjectContinuationToken {
    var routePayload: [String: String] {
        var payload: [String: String] = [
            ExternalSurfaceActionPayload.Key.kind: kind.rawValue,
            ExternalSurfaceActionPayload.Key.root: root.rawValue,
            ExternalSurfaceActionPayload.Key.metadataClass: metadataClass.rawValue,
            ExternalSurfaceActionPayload.Key.redaction: redaction.rawValue
        ]

        if let goalID {
            payload[ExternalSurfaceActionPayload.Key.goalID] = goalID
        }
        if let stepID {
            payload[ExternalSurfaceActionPayload.Key.stepID] = stepID
        }
        if let receiptID {
            payload[ExternalSurfaceActionPayload.Key.receiptID] = receiptID
        }
        if let captureID {
            payload[ExternalSurfaceActionPayload.Key.captureID] = captureID
        }

        return payload
    }

    func routeURL(origin: ExternalSurfaceOrigin) -> URL? {
        switch kind {
        case .goal:
            guard let goalID else {
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
            }
            return ExternalSurfaceActionPayload.deepLinkURL(
                surface: .goalDetail,
                goalID: goalID,
                origin: origin
            )
        case .currentStep:
            guard let goalID else {
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
            }
            guard var components = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .goalDetail,
                goalID: goalID,
                origin: origin
            ).flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }) else {
                return nil
            }
            if let stepID {
                var queryItems = components.queryItems ?? []
                queryItems.append(URLQueryItem(name: ExternalSurfaceActionPayload.Key.stepID, value: stepID))
                components.queryItems = queryItems
            }
            return components.url
        case .receipt:
            if let receiptID {
                return externalObjectMemoryLensURL(query: "receipt:\(receiptID)", origin: origin)
            }
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
        case .capture:
            guard var components = ExternalSurfaceActionPayload.deepLinkURL(surface: .captureInbox, origin: origin).flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }) else {
                return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: root.rawValue, origin: origin)
            }
            if let captureID {
                var queryItems = components.queryItems ?? []
                queryItems.append(URLQueryItem(name: ExternalSurfaceActionPayload.Key.captureID, value: captureID))
                components.queryItems = queryItems
            }
            return components.url
        }
    }
}

private func externalObjectMemoryLensURL(query: String, origin: ExternalSurfaceOrigin) -> URL? {
    var components = URLComponents()
    components.scheme = "ambitions"
    components.host = "overlay"
    components.path = "/memory-lens"
    components.queryItems = [
        URLQueryItem(name: "intent", value: "memory_lens"),
        URLQueryItem(name: "q", value: query),
        URLQueryItem(name: "origin", value: origin.rawValue),
    ]
    return components.url
}

struct ExternalSurfaceGlanceState: Sendable, Equatable {
    let primaryReference: ExternalSurfaceActionReference?
    let todayPosture: ExternalSurfaceTodayPosture
    let pressureLevel: ExternalSurfacePressureLevel
    let openCaptureUrgency: ExternalSurfaceCaptureUrgency
    let blockerSummary: ExternalSurfaceBlockerSummary
    let ritualCue: ExternalSurfaceRitualCue?
    let supportedCommands: [ExternalSurfaceCommandDescriptor]
    let ambientState: ExternalSurfaceAmbientState?
    let continuity: ExternalSurfaceContinuityState
    let urgency: ExternalSurfaceUrgency
    let timing: ExternalSurfaceTiming

    init(snapshot: ExternalSurfaceSnapshot?) {
        guard let snapshot else {
            primaryReference = nil
            todayPosture = .empty
            pressureLevel = .open
            openCaptureUrgency = .none
            blockerSummary = ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0)
            ritualCue = nil
            supportedCommands = [
                ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ExternalSurfaceCommandDescriptor(kind: .openMemoryLens, requiresGoalID: false, requiresStepID: false),
            ]
            ambientState = nil
            continuity = ExternalSurfaceContinuityState(
                lease: ExternalSurfaceNowStateLease(
                    status: .unavailable,
                    generatedAt: nil,
                    freshnessLabel: "Open Ambitions to refresh",
                    staleActionLabel: "Open Ambitions to confirm"
                ),
                syncHealth: ExternalSurfaceSyncHealth(
                    state: .unavailable,
                    label: "This surface may be behind",
                    detail: "Local app truth is available when Ambitions opens"
                ),
                receipt: nil
            )
            urgency = .anytime
            timing = .untimed
            return
        }

        if let nowState = snapshot.nowState {
            primaryReference = nowState.activeFocus ?? nowState.bestNextStep
            todayPosture = nowState.todayPosture
            pressureLevel = nowState.pressureLevel
            openCaptureUrgency = nowState.openCaptureUrgency
            blockerSummary = nowState.blockerSummary
            ritualCue = nowState.ritualCue
            supportedCommands = nowState.supportedCommands
        } else if let nextAction = snapshot.nextAction {
            primaryReference = ExternalSurfaceActionReference(goalID: nextAction.goalID, stepID: nextAction.stepID)
            todayPosture = .active
            pressureLevel = .steady
            openCaptureUrgency = .none
            blockerSummary = ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0)
            ritualCue = nil
            supportedCommands = [
                ExternalSurfaceCommandDescriptor(kind: .complete, requiresGoalID: true, requiresStepID: true),
                ExternalSurfaceCommandDescriptor(kind: .snooze, requiresGoalID: true, requiresStepID: true),
                ExternalSurfaceCommandDescriptor(kind: .openGoal, requiresGoalID: true, requiresStepID: false),
                ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ExternalSurfaceCommandDescriptor(kind: .openMemoryLens, requiresGoalID: false, requiresStepID: false),
            ]
        } else {
            primaryReference = nil
            todayPosture = .empty
            pressureLevel = .open
            openCaptureUrgency = .none
            blockerSummary = ExternalSurfaceBlockerSummary(waitingCount: 0, blockedCount: 0)
            ritualCue = nil
            supportedCommands = [
                ExternalSurfaceCommandDescriptor(kind: .openToday, requiresGoalID: false, requiresStepID: false),
                ExternalSurfaceCommandDescriptor(kind: .openMemoryLens, requiresGoalID: false, requiresStepID: false),
            ]
        }

        ambientState = snapshot.ambientState
        continuity = snapshot.continuity
        urgency = snapshot.nextAction?.display.urgency ?? .anytime
        timing = snapshot.nextAction?.display.timing ?? .untimed
    }

    var primaryURL: URL? {
        if let goalID = primaryReference?.goalID {
            return ExternalSurfaceActionPayload.deepLinkURL(surface: .goalDetail, goalID: goalID, origin: .widget)
        }
        return ExternalSurfaceActionPayload.deepLinkURL(surface: .tab, tab: "today", origin: .widget)
    }
}
