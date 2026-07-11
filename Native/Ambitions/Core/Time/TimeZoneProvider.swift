import Foundation

public struct TimeZoneProvider: Equatable, Sendable {
    private let fixedIdentifier: String?

    public static let current = TimeZoneProvider(fixedIdentifier: nil)
    public static let utc = TimeZoneProvider(timeZone: TimeZone(secondsFromGMT: 0)!)

    public init(timeZone: TimeZone) {
        fixedIdentifier = timeZone.identifier
    }

    private init(fixedIdentifier: String?) {
        self.fixedIdentifier = fixedIdentifier
    }

    public var timeZone: TimeZone {
        guard let fixedIdentifier else {
            return .current
        }
        return TimeZone(identifier: fixedIdentifier) ?? .current
    }
}
