import Foundation

public struct SystemClock: AmbitionsClock {
    private let timeZoneProvider: TimeZoneProvider

    public init(timeZoneProvider: TimeZoneProvider = .current) {
        self.timeZoneProvider = timeZoneProvider
    }

    public var now: Date { Date() }
    public var timeZone: TimeZone { timeZoneProvider.timeZone }
    public var advancesAutomatically: Bool { true }

    public var calendar: Calendar {
        RuntimeTickPolicy(timeZoneProvider: timeZoneProvider).calendar
    }
}
