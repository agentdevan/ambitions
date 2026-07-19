import Foundation

struct PermissionCoordinator: Sendable {
    let calendarPermission: CalendarPermission
    let notificationPermission: NotificationPermission
    let speechPermission: SpeechPermission
    let localAuthenticationPolicy: LocalAuthenticationPolicy

    init(
        calendarPermission: CalendarPermission = CalendarPermission(),
        notificationPermission: NotificationPermission = NotificationPermission(),
        speechPermission: SpeechPermission = SpeechPermission(),
        localAuthenticationPolicy: LocalAuthenticationPolicy = LocalAuthenticationPolicy()
    ) {
        self.calendarPermission = calendarPermission
        self.notificationPermission = notificationPermission
        self.speechPermission = speechPermission
        self.localAuthenticationPolicy = localAuthenticationPolicy
    }

    func calendarState(
        scope: CalendarRemindersScope,
        authorization: CalendarRemindersAuthorizationState
    ) -> PermissionState {
        calendarPermission.state(for: scope, authorization: authorization)
    }

    func notificationState(
        authorization: NotificationAuthorizationState
    ) -> PermissionState {
        notificationPermission.state(for: authorization)
    }

    func speechState(status: SpeechPermissionStatus) -> PermissionState {
        speechPermission.state(for: status)
    }

    func localAuthenticationState(
        availability: LocalAuthenticationAvailability
    ) -> PermissionState {
        localAuthenticationPolicy.state(for: availability)
    }

    func permissionSnapshot(
        calendarAuthorization: CalendarRemindersAuthorizationState,
        remindersAuthorization: CalendarRemindersAuthorizationState,
        notificationAuthorization: NotificationAuthorizationState,
        speechStatus: SpeechPermissionStatus = .unavailable,
        localAuthenticationAvailability: LocalAuthenticationAvailability = .unknownFailure
    ) -> [PermissionState] {
        [
            calendarState(scope: .calendarEvents, authorization: calendarAuthorization),
            calendarState(scope: .reminders, authorization: remindersAuthorization),
            notificationState(authorization: notificationAuthorization),
            speechState(status: speechStatus),
            localAuthenticationState(availability: localAuthenticationAvailability)
        ]
    }
}
