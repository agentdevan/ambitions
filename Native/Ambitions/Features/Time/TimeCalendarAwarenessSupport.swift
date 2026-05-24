import Foundation

extension RepositoryBackedTimeService {
    func dayHorizon(now: Date, calendar: Calendar = Calendar.current) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(24 * 60 * 60)
        return DateInterval(start: start, end: end)
    }

    func weekHorizon(now: Date) -> DateInterval {
        return availabilityHorizon(now: now, calendar: Calendar.current, horizon: "week")
    }

    func availabilityHorizon(
        now: Date,
        calendar: Calendar = Calendar.current,
        horizon: String
    ) -> DateInterval {
        let start = calendar.startOfDay(for: now)
        let end: Date
        switch horizon {
        case "day":
            end = calendar.date(byAdding: .day, value: 1, to: start) ?? start.addingTimeInterval(24 * 60 * 60)
        case "week":
            end = calendar.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(7 * 24 * 60 * 60)
        case "month":
            end = calendar.date(byAdding: .month, value: 1, to: start) ?? start.addingTimeInterval(30 * 24 * 60 * 60)
        case "year":
            end = calendar.date(byAdding: .year, value: 1, to: start) ?? start.addingTimeInterval(365 * 24 * 60 * 60)
        default:
            end = calendar.date(byAdding: .day, value: 7, to: start) ?? start.addingTimeInterval(7 * 24 * 60 * 60)
        }
        return DateInterval(start: start, end: end)
    }

    func monthHorizon(now: Date, calendar: Calendar = Calendar.current) -> DateInterval {
        return availabilityHorizon(now: now, calendar: calendar, horizon: "month")
    }

    func yearHorizon(now: Date, calendar: Calendar = Calendar.current) -> DateInterval {
        return availabilityHorizon(now: now, calendar: calendar, horizon: "year")
    }

    func makeCalendarAwarenessState(permission: CalendarPermissionState, openWindowCount: Int?) -> TimeCalendarAwarenessState {
        switch permission {
        case .readWrite:
            return TimeCalendarAwarenessState(
                status: .calendarAware,
                title: "Calendar-aware availability",
                detail: openWindowCount.map { "Time used calendar-derived busy time locally and found \($0) open window\($0 == 1 ? "" : "s")." }
                    ?? "Time can use calendar-derived busy time locally when you ask for real open windows.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar.badge.clock",
                valueLabel: "Aware",
                sourceLabel: "From your calendar",
                visualState: .success,
                canRequestCalendarRead: true
            )
        case .writeOnly:
            return TimeCalendarAwarenessState(
                status: .writeOnly,
                title: "Calendar write is available",
                detail: "Time can write confirmed blocks, but it cannot read availability until calendar read access is granted.",
                primaryActionTitle: "Make Time calendar-aware",
                primaryActionSystemImage: "calendar.badge.clock",
                valueLabel: "Write only",
                sourceLabel: "Created in Ambitions",
                visualState: .warning,
                canRequestCalendarRead: true
            )
        case .denied, .restricted:
            return TimeCalendarAwarenessState(
                status: .denied,
                title: "Time works without Calendar",
                detail: "Calendar access is unavailable, so Time uses Ambitions data and baseline windows without reading events.",
                primaryActionTitle: "Find real open windows",
                primaryActionSystemImage: "calendar.badge.exclamationmark",
                valueLabel: "Denied",
                sourceLabel: "Created in Ambitions",
                visualState: .warning,
                canRequestCalendarRead: false
            )
        case .notDetermined:
            return TimeCalendarAwarenessState(
                status: .baseline,
                title: "Make Time calendar-aware",
                detail: "Time works without access. With your confirmation, it can read derived busy time locally to find real open windows.",
                primaryActionTitle: "Make Time calendar-aware",
                primaryActionSystemImage: "calendar.badge.plus",
                valueLabel: "Optional",
                sourceLabel: "Based on Time",
                visualState: .default,
                canRequestCalendarRead: true
            )
        case .unavailable:
            return TimeCalendarAwarenessState(
                status: .unavailable,
                title: "Calendar-aware mode unavailable",
                detail: "Time is using Ambitions data only in this runtime.",
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
