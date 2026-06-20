import Foundation

struct TimeZoneProvider: Equatable, Sendable {
    private let fixedIdentifier: String?

    static let current = TimeZoneProvider(fixedIdentifier: nil)
    static let utc = TimeZoneProvider(timeZone: TimeZone(secondsFromGMT: 0)!)

    init(timeZone: TimeZone) {
        fixedIdentifier = timeZone.identifier
    }

    private init(fixedIdentifier: String?) {
        self.fixedIdentifier = fixedIdentifier
    }

    var timeZone: TimeZone {
        guard let fixedIdentifier else {
            return .current
        }
        return TimeZone(identifier: fixedIdentifier) ?? .current
    }
}
