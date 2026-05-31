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
        static let surface = "surface"
        static let goalID = "goalID"
        static let stepID = "stepID"
        static let draftID = "draftID"
        static let tab = "tab"
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
        var url: URL?
        switch candidate.kind {
        case .goal:
            url = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .goalDetail,
                goalID: candidate.goalID ?? candidate.id,
                origin: origin
            )
        case .currentStep:
            url = ExternalSurfaceActionPayload.deepLinkURL(
                surface: .goalDetail,
                goalID: candidate.goalID,
                origin: origin
            )
        case .receipt:
            url = memoryLensURL(query: "receipt:\(candidate.receiptID ?? candidate.id)", origin: origin)
        case .capture:
            url = ExternalSurfaceActionPayload.deepLinkURL(surface: .captureInbox, origin: origin)
        }

        guard var components = url.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }) else {
            return nil
        }
        var queryItems = components.queryItems ?? []
        if candidate.kind == .currentStep, let stepID = nonEmpty(candidate.stepID) {
            queryItems.append(URLQueryItem(name: "stepID", value: stepID))
        }
        if candidate.kind == .capture, let captureID = nonEmpty(candidate.captureID) {
            queryItems.append(URLQueryItem(name: "captureID", value: captureID))
        }
        components.queryItems = queryItems
        return components.url
    }

    private func memoryLensURL(query: String, origin: ExternalSurfaceOrigin) -> URL? {
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
