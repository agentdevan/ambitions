import Foundation

struct CalendarPermission: Sendable {
    func state(
        for scope: CalendarRemindersScope,
        authorization: CalendarRemindersAuthorizationState
    ) -> PermissionState {
        let kind: AmbitionsPermissionKind = scope == .calendarEvents ? .calendarRead : .remindersWrite
        let availability = availability(for: authorization)
        let canRead = scope == .calendarEvents && authorization.canReadCalendarContext
        let canWrite = authorization.canWrite
        let canRequest = authorization == .notDetermined

        return PermissionState(
            kind: kind,
            availability: availability,
            canRead: canRead,
            canWrite: canWrite,
            canRequest: canRequest,
            requestTiming: canRequest ? .userInitiated : .blocked,
            fallbackSummary: fallbackSummary(scope: scope, authorization: authorization),
            inspectionSummary: inspectionSummary(scope: scope, authorization: authorization)
        )
    }

    func readDecision(
        current authorization: CalendarRemindersAuthorizationState,
        context: PermissionRequestContext
    ) -> PermissionRequestDecision {
        let permissionState = state(for: .calendarEvents, authorization: authorization)
        guard context.isContextual else {
            return .blocked(
                state: permissionState,
                reason: "Calendar read prompts require an explicit Time action."
            )
        }
        guard authorization == .notDetermined else {
            return .blocked(
                state: permissionState,
                reason: "Calendar read authorization is already determined."
            )
        }
        return .request(
            state: permissionState,
            reason: "Calendar read access is requested from a user-initiated Time action."
        )
    }

    func writeDecision(
        current authorization: CalendarRemindersAuthorizationState,
        intent: ScheduledBlockWriteIntent
    ) -> PermissionRequestDecision {
        let permissionState = state(for: .calendarEvents, authorization: authorization)
        guard intent.isExecutable else {
            return .blocked(
                state: permissionState,
                reason: "Calendar write prompts require a confirmed block."
            )
        }
        guard authorization == .notDetermined else {
            return .blocked(
                state: permissionState,
                reason: "Calendar write authorization is already determined."
            )
        }
        return .request(
            state: permissionState,
            reason: "Calendar write access is requested only after explicit Time confirmation."
        )
    }

    func lifeShapeFallback(permissionState: CalendarPermissionState) -> LifeShapeFallback? {
        switch permissionState {
        case .denied, .restricted, .unavailable:
            return LifeShapeFallback(
                kind: permissionState == .denied ? .calendarUnavailable : .sourceUnavailable,
                userVisibleSummary: "Calendar access is unavailable; Time still works from local manual planning."
            )
        case .notDetermined, .readWrite, .writeOnly:
            return nil
        }
    }

    private func availability(for authorization: CalendarRemindersAuthorizationState) -> PermissionAvailability {
        switch authorization {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .authorized, .writeOnly, .fullAccess:
            return .available
        }
    }

    private func fallbackSummary(
        scope: CalendarRemindersScope,
        authorization: CalendarRemindersAuthorizationState
    ) -> String {
        switch scope {
        case .reminders:
            return authorization.canWrite
                ? "Reminder writes are available after explicit user action."
                : "Ambitions keeps reminders inside the local runtime when Reminders access is unavailable."
        case .calendarEvents:
            return authorization.canReadCalendarContext || authorization.canWrite
                ? "Calendar access is bounded to the requested Time action."
                : "Time still works from local schedule and user-confirmed blocks without calendar access."
        }
    }

    private func inspectionSummary(
        scope: CalendarRemindersScope,
        authorization: CalendarRemindersAuthorizationState
    ) -> String {
        switch scope {
        case .reminders:
            return "Reminders permission is contextual and never required for local-first core value. State: \(authorization)."
        case .calendarEvents:
            return "Calendar permission is contextual to Time and confirmed block actions. State: \(authorization)."
        }
    }
}
