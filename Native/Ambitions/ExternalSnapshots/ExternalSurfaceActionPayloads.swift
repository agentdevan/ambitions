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
    case capturesInbox = "captures-inbox"
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
        case .capturesInbox:
            components.host = "captures"
            components.path = "/inbox"
        }

        if let origin {
            components.queryItems = [URLQueryItem(name: "origin", value: origin.rawValue)]
        }
        return components.url
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
