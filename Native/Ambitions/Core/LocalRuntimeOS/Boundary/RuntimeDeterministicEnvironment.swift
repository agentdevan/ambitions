import Foundation

protocol RuntimeClockDependency: Sendable {
    var now: Date { get }
}

protocol RuntimeCalendarDependency: Sendable {
    var calendar: Calendar { get }
}

protocol RuntimeTimeZoneDependency: Sendable {
    var timeZone: TimeZone { get }
}

protocol RuntimeLocaleDependency: Sendable {
    var locale: Locale { get }
}

protocol RuntimeUUIDDependency: Sendable {
    mutating func nextUUID() -> UUID
}

protocol RuntimeRandomDependency: Sendable {
    mutating func nextUInt64() -> UInt64
}

struct RuntimeClockClient: RuntimeClockDependency, Sendable {
    private let readNow: @Sendable () -> Date

    var now: Date { readNow() }

    init(readNow: @escaping @Sendable () -> Date) {
        self.readNow = readNow
    }

    static var live: RuntimeClockClient {
        RuntimeClockClient { Date() }
    }

    static func deterministic(_ now: Date) -> RuntimeClockClient {
        RuntimeClockClient { now }
    }
}

struct RuntimeCalendarClient: RuntimeCalendarDependency, Sendable {
    private let readCalendar: @Sendable () -> Calendar

    var calendar: Calendar { readCalendar() }

    init(readCalendar: @escaping @Sendable () -> Calendar) {
        self.readCalendar = readCalendar
    }

    static var live: RuntimeCalendarClient {
        RuntimeCalendarClient { Calendar.autoupdatingCurrent }
    }

    static func deterministic(
        identifier: Calendar.Identifier = .gregorian,
        timeZone: TimeZone,
        locale: Locale
    ) -> RuntimeCalendarClient {
        var calendar = Calendar(identifier: identifier)
        calendar.timeZone = timeZone
        calendar.locale = locale
        let configuredCalendar = calendar
        return RuntimeCalendarClient { configuredCalendar }
    }
}

struct RuntimeTimeZoneClient: RuntimeTimeZoneDependency, Sendable {
    private let readTimeZone: @Sendable () -> TimeZone

    var timeZone: TimeZone { readTimeZone() }

    init(readTimeZone: @escaping @Sendable () -> TimeZone) {
        self.readTimeZone = readTimeZone
    }

    static var live: RuntimeTimeZoneClient {
        RuntimeTimeZoneClient { TimeZone.autoupdatingCurrent }
    }

    static func deterministic(identifier: String) -> RuntimeTimeZoneClient? {
        guard let timeZone = TimeZone(identifier: identifier) else { return nil }
        return RuntimeTimeZoneClient { timeZone }
    }
}

struct RuntimeLocaleClient: RuntimeLocaleDependency, Sendable {
    private let readLocale: @Sendable () -> Locale

    var locale: Locale { readLocale() }

    init(readLocale: @escaping @Sendable () -> Locale) {
        self.readLocale = readLocale
    }

    static var live: RuntimeLocaleClient {
        RuntimeLocaleClient { Locale.autoupdatingCurrent }
    }

    static func deterministic(identifier: String) -> RuntimeLocaleClient {
        let locale = Locale(identifier: identifier)
        return RuntimeLocaleClient { locale }
    }
}

struct RuntimeRandomClient: RuntimeRandomDependency, Sendable {
    private enum Source: Sendable {
        case live
        case seeded(UInt64)
    }

    private var source: Source

    static var live: RuntimeRandomClient {
        RuntimeRandomClient(source: .live)
    }

    static func deterministic(seed: UInt64) -> RuntimeRandomClient {
        RuntimeRandomClient(source: .seeded(seed))
    }

    mutating func nextUInt64() -> UInt64 {
        switch source {
        case .live:
            var generator = SystemRandomNumberGenerator()
            return generator.next()
        case let .seeded(state):
            let nextState = state &+ 0x9E37_79B9_7F4A_7C15
            source = .seeded(nextState)
            var mixed = nextState
            mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
            mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
            return mixed ^ (mixed >> 31)
        }
    }
}

struct RuntimeUUIDClient: RuntimeUUIDDependency, Sendable {
    private var randomness: RuntimeRandomClient

    static var live: RuntimeUUIDClient {
        RuntimeUUIDClient(randomness: .live)
    }

    static func deterministic(seed: UInt64) -> RuntimeUUIDClient {
        RuntimeUUIDClient(randomness: .deterministic(seed: seed))
    }

    mutating func nextUUID() -> UUID {
        let high = randomness.nextUInt64()
        let low = randomness.nextUInt64()
        return UUID(uuid: (
            byte(high, 56), byte(high, 48), byte(high, 40), byte(high, 32),
            byte(high, 24), byte(high, 16), (byte(high, 8) & 0x0F) | 0x40, byte(high, 0),
            (byte(low, 56) & 0x3F) | 0x80, byte(low, 48), byte(low, 40), byte(low, 32),
            byte(low, 24), byte(low, 16), byte(low, 8), byte(low, 0)
        ))
    }

    private func byte(_ value: UInt64, _ shift: UInt64) -> UInt8 {
        UInt8(truncatingIfNeeded: value >> shift)
    }
}

struct RuntimeEnvironment: Sendable {
    let clock: RuntimeClockClient
    let calendar: RuntimeCalendarClient
    let timeZone: RuntimeTimeZoneClient
    let locale: RuntimeLocaleClient
    var uuid: RuntimeUUIDClient
    var random: RuntimeRandomClient

    static var live: RuntimeEnvironment {
        RuntimeEnvironment(
            clock: .live,
            calendar: .live,
            timeZone: .live,
            locale: .live,
            uuid: .live,
            random: .live
        )
    }

    static func deterministic(
        now: Date,
        timeZoneIdentifier: String = "UTC",
        localeIdentifier: String = "en_US_POSIX",
        seed: UInt64
    ) -> RuntimeEnvironment? {
        guard let timeZone = RuntimeTimeZoneClient.deterministic(identifier: timeZoneIdentifier) else {
            return nil
        }
        let locale = RuntimeLocaleClient.deterministic(identifier: localeIdentifier)
        return RuntimeEnvironment(
            clock: .deterministic(now),
            calendar: .deterministic(timeZone: timeZone.timeZone, locale: locale.locale),
            timeZone: timeZone,
            locale: locale,
            uuid: .deterministic(seed: seed ^ 0xA076_1D64_78BD_642F),
            random: .deterministic(seed: seed)
        )
    }
}
