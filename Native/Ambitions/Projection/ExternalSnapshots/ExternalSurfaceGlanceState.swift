import Foundation

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
                receipt: nil,
                lifecycleContext: .relaunch
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
