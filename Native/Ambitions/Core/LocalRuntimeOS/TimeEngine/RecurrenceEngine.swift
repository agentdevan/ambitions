import Foundation

struct TimeRecurrenceRule: Codable, Sendable, Equatable, Hashable {
    let cadenceDays: Int
    let timeZoneIdentifier: String

    init(cadenceDays: Int, timeZone: TimeZone = TemporalMath.utc) {
        self.cadenceDays = max(1, cadenceDays)
        timeZoneIdentifier = timeZone.identifier
    }

    var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? TemporalMath.utc
    }
}

struct TimeRecurrenceSeed: Codable, Sendable, Equatable, Hashable {
    let id: String
    let title: String
    let startsAt: Date
    let rule: TimeRecurrenceRule
    let isPaused: Bool
    let localOnly: Bool

    init(
        id: String,
        title: String,
        startsAt: Date,
        rule: TimeRecurrenceRule,
        isPaused: Bool = false,
        localOnly: Bool = true
    ) {
        self.id = TimeEngineStableID.required(id)
        self.title = TimeEngineStableID.required(title)
        self.startsAt = startsAt
        self.rule = rule
        self.isPaused = isPaused
        self.localOnly = localOnly
    }
}

struct RecurringTimeOccurrence: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let seedID: String
    let scheduledAt: Date
    let title: String
    let isPaused: Bool
    let runtimeTrace: TimeEngineRuntimeTrace

    init(seed: TimeRecurrenceSeed, scheduledAt: Date) {
        seedID = seed.id
        self.scheduledAt = scheduledAt
        title = seed.title
        isPaused = seed.isPaused
        let source = [seed.id, TemporalMath.string(from: scheduledAt), seed.rule.timeZoneIdentifier].joined(separator: "|")
        runtimeTrace = TimeEngineRuntimeTrace.make(owner: "RecurrenceEngine", sourceID: source, localOnly: seed.localOnly)
        id = TimeEngineStableID.make(prefix: "recurring-time-occurrence", components: [source])
    }
}

struct RecurrenceEngine: Sendable {
    func occurrences(seed: TimeRecurrenceSeed, from start: Date, limit rawLimit: Int) -> [RecurringTimeOccurrence] {
        guard seed.isPaused == false, seed.localOnly else { return [] }
        return TemporalMath.occurrences(
            startingAt: seed.startsAt,
            cadenceDays: seed.rule.cadenceDays,
            from: start,
            limit: rawLimit,
            timeZone: seed.rule.timeZone
        ).map { RecurringTimeOccurrence(seed: seed, scheduledAt: $0) }
    }

    func nextOccurrence(after date: Date, seed: TimeRecurrenceSeed) -> RecurringTimeOccurrence? {
        occurrences(seed: seed, from: date, limit: 1).first
    }

    func advance(seed: TimeRecurrenceSeed, after completedAt: Date) -> TimeRecurrenceSeed {
        let next = TemporalMath.addDays(seed.rule.cadenceDays, to: max(seed.startsAt, completedAt), timeZone: seed.rule.timeZone)
        return TimeRecurrenceSeed(
            id: seed.id,
            title: seed.title,
            startsAt: next,
            rule: seed.rule,
            isPaused: seed.isPaused,
            localOnly: seed.localOnly
        )
    }
}
