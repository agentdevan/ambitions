import Foundation

struct SystemClock: AmbitionsClock {
    let timeZoneProvider: TimeZoneProvider

    init(timeZoneProvider: TimeZoneProvider = .current) {
        self.timeZoneProvider = timeZoneProvider
    }

    var now: Date { Date() }
    var timeZone: TimeZone { timeZoneProvider.timeZone }
    var advancesAutomatically: Bool { true }

    var calendar: Calendar {
        RuntimeTickPolicy(timeZoneProvider: timeZoneProvider).calendar
    }
}
