import Foundation

extension RepositoryBackedPlanService {
    func weekHorizon(now: Date) -> DateInterval {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(7 * 86_400)
        return DateInterval(start: start, end: end)
    }

    func makeCalendarAwarenessState(permission: CalendarPermissionState, openWindowCount: Int?) -> PlanCalendarAwarenessState {
        switch permission {
        case .readWrite:
            return PlanCalendarAwarenessState(
                status: .calendarAware,
                title: "Calendar-aware planning",
                detail: openWindowCount.map { "Plan used calendar-derived busy time locally and found \($0) open window\($0 == 1 ? "" : "s")." }
                    ?? "Plan can use calendar-derived busy time locally when you ask for real open windows.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar.badge.clock",
                valueLabel: "Aware",
                sourceLabel: "From your calendar",
                visualState: .success,
                canRequestCalendarRead: true
            )
        case .writeOnly:
            return PlanCalendarAwarenessState(
                status: .writeOnly,
                title: "Calendar write is available",
                detail: "Plan can write confirmed blocks, but it cannot read availability until calendar read access is granted.",
                primaryActionTitle: "Make Plan calendar-aware",
                primaryActionSystemImage: "calendar.badge.clock",
                valueLabel: "Write only",
                sourceLabel: "Created in Ambitions",
                visualState: .warning,
                canRequestCalendarRead: true
            )
        case .denied, .restricted:
            return PlanCalendarAwarenessState(
                status: .denied,
                title: "Plan works without Calendar",
                detail: "Calendar access is unavailable, so Plan uses Ambitions data and baseline windows without reading events.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar.badge.exclamationmark",
                valueLabel: "Denied",
                sourceLabel: "Created in Ambitions",
                visualState: .warning,
                canRequestCalendarRead: false
            )
        case .notDetermined:
            return PlanCalendarAwarenessState(
                status: .baseline,
                title: "Make Plan calendar-aware",
                detail: "Plan works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
                primaryActionTitle: "Make Plan calendar-aware",
                primaryActionSystemImage: "calendar.badge.plus",
                valueLabel: "Optional",
                sourceLabel: "Based on your plan",
                visualState: .default,
                canRequestCalendarRead: true
            )
        case .unavailable:
            return PlanCalendarAwarenessState(
                status: .unavailable,
                title: "Calendar-aware mode unavailable",
                detail: "Plan is using Ambitions data only in this runtime.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar",
                valueLabel: "Local",
                sourceLabel: "Created in Ambitions",
                visualState: .default,
                canRequestCalendarRead: false
            )
        }
    }

}
