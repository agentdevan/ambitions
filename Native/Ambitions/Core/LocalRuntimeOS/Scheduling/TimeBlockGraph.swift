import Foundation

enum TimeBlockKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case protected
    case fixed
    case flexible
    case scheduledStep = "scheduled_step"
    case recovery
    case buffer
    case externalBusy = "external_busy"

    var consumesCapacity: Bool {
        switch self {
        case .protected, .fixed, .scheduledStep, .buffer, .externalBusy:
            true
        case .flexible, .recovery:
            false
        }
    }

    var protectsBoundary: Bool {
        switch self {
        case .protected, .fixed:
            true
        case .flexible, .scheduledStep, .recovery, .buffer, .externalBusy:
            false
        }
    }
}

enum TimeBlockSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localRuntime = "local_runtime"
    case user
    case command
    case eventJournal = "event_journal"
    case projection
    case eventKit = "event_kit"
    case reminder
}

struct TimeBlock: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let start: Date
    let end: Date
    let kind: TimeBlockKind
    let source: TimeBlockSource
    let stepID: String?
    let goalID: String?
    let commandID: String?
    let eventID: String?
    let privacyClass: AmbitionPrivacyClass
    let localOnly: Bool

    init(
        id: String? = nil,
        title: String,
        start: Date,
        end: Date,
        kind: TimeBlockKind,
        source: TimeBlockSource = .localRuntime,
        stepID: String? = nil,
        goalID: String? = nil,
        commandID: String? = nil,
        eventID: String? = nil,
        privacyClass: AmbitionPrivacyClass = .privateConstraint,
        localOnly: Bool = true
    ) {
        precondition(end > start, "TimeBlock end must be after start")
        self.title = SchedulingStableID.required(title)
        self.start = start
        self.end = end
        self.kind = kind
        self.source = source
        self.stepID = SchedulingStableID.optional(stepID)
        self.goalID = SchedulingStableID.optional(goalID)
        self.commandID = SchedulingStableID.optional(commandID)
        self.eventID = SchedulingStableID.optional(eventID)
        self.privacyClass = privacyClass
        self.localOnly = localOnly
        self.id = SchedulingStableID.optional(id) ?? SchedulingStableID.make(
            prefix: "time-block",
            components: [
                self.title,
                TemporalMath.string(from: start),
                TemporalMath.string(from: end),
                kind.rawValue,
                self.stepID ?? "no-step",
                self.goalID ?? "no-goal"
            ]
        )
    }

    var durationMinutes: Int {
        TemporalMath.durationMinutes(start: start, end: end)
    }

    func intersects(_ other: TimeBlock) -> Bool {
        TemporalMath.intersects(start: start, end: end, otherStart: other.start, otherEnd: other.end)
    }

    func intersects(_ window: ProtectedStepPlacementWindow) -> Bool {
        TemporalMath.intersects(start: start, end: end, otherStart: window.start, otherEnd: window.end)
    }

    func overlapMinutes(with other: TimeBlock) -> Int {
        TemporalMath.overlapMinutes(start: start, end: end, otherStart: other.start, otherEnd: other.end)
    }

    func clipped(to window: ProtectedStepPlacementWindow) -> TimeBlock? {
        guard intersects(window) else { return nil }
        return TimeBlock(
            id: id,
            title: title,
            start: max(start, window.start),
            end: min(end, window.end),
            kind: kind,
            source: source,
            stepID: stepID,
            goalID: goalID,
            commandID: commandID,
            eventID: eventID,
            privacyClass: privacyClass,
            localOnly: localOnly
        )
    }
}

enum TimeConflictSeverity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case advisory
    case blocking
}

struct TimeBlockConflict: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let firstBlockID: String
    let secondBlockID: String
    let overlapMinutes: Int
    let severity: TimeConflictSeverity
    let reason: String

    init(first: TimeBlock, second: TimeBlock) {
        firstBlockID = min(first.id, second.id)
        secondBlockID = max(first.id, second.id)
        overlapMinutes = first.overlapMinutes(with: second)
        severity = (first.kind.protectsBoundary || second.kind.protectsBoundary || first.kind.consumesCapacity && second.kind.consumesCapacity) ? .blocking : .advisory
        reason = severity == .blocking
            ? "A protected, fixed, or capacity-consuming block overlaps another scheduled block."
            : "Flexible blocks overlap and should be reviewed before placement."
        id = SchedulingStableID.make(prefix: "time-conflict", components: [firstBlockID, secondBlockID, "\(overlapMinutes)", severity.rawValue])
    }
}

struct TimeBlockGraph: Codable, Sendable, Equatable, Hashable, Identifiable {
    static let empty = TimeBlockGraph(blocks: [])

    let id: String
    let blocks: [TimeBlock]
    let localOnly: Bool
    let runtimeTrace: SchedulingRuntimeTrace

    init(blocks: [TimeBlock], localOnly: Bool = true) {
        self.blocks = blocks.sorted {
            if $0.start != $1.start { return $0.start < $1.start }
            if $0.end != $1.end { return $0.end < $1.end }
            return $0.id < $1.id
        }
        self.localOnly = localOnly && self.blocks.allSatisfy(\.localOnly)
        let fingerprint = SchedulingStableID.make(
            prefix: "time-block-graph.source",
            components: self.blocks.map { "\($0.id):\(TemporalMath.string(from: $0.start)):\(TemporalMath.string(from: $0.end)):\($0.kind.rawValue)" }
        )
        id = SchedulingStableID.make(prefix: "time-block-graph", components: [fingerprint])
        runtimeTrace = SchedulingRuntimeTrace.make(owner: "TimeBlockGraph", sourceID: fingerprint, localOnly: self.localOnly)
    }

    var conflicts: [TimeBlockConflict] {
        var result: [TimeBlockConflict] = []
        for index in blocks.indices {
            for otherIndex in blocks.indices where otherIndex > index {
                let first = blocks[index]
                let second = blocks[otherIndex]
                if first.intersects(second) {
                    result.append(TimeBlockConflict(first: first, second: second))
                }
            }
        }
        return result.sorted { $0.id < $1.id }
    }

    func block(id: String) -> TimeBlock? {
        blocks.first { $0.id == id || $0.stepID == id || $0.goalID == id }
    }

    func blocks(intersecting window: ProtectedStepPlacementWindow) -> [TimeBlock] {
        blocks.filter { $0.intersects(window) }
    }

    func adding(_ block: TimeBlock) -> TimeBlockGraph {
        TimeBlockGraph(blocks: blocks.filter { $0.id != block.id } + [block], localOnly: localOnly && block.localOnly)
    }

    func removing(blockID: String) -> TimeBlockGraph {
        TimeBlockGraph(blocks: blocks.filter { $0.id != blockID }, localOnly: localOnly)
    }

    func availableWindows(in horizon: ProtectedStepPlacementWindow, minimumDurationMinutes: Int) -> [ProtectedStepPlacementWindow] {
        let minimumSeconds = TimeInterval(max(1, minimumDurationMinutes) * 60)
        let busy = blocks
            .filter(\.kind.consumesCapacity)
            .compactMap { $0.clipped(to: horizon) }
            .sorted { $0.start < $1.start }

        var cursor = horizon.start
        var windows: [ProtectedStepPlacementWindow] = []
        for block in busy {
            if block.start.timeIntervalSince(cursor) >= minimumSeconds,
               let window = ProtectedStepPlacementWindow(start: cursor, end: block.start) {
                windows.append(window)
            }
            cursor = max(cursor, block.end)
        }
        if horizon.end.timeIntervalSince(cursor) >= minimumSeconds,
           let window = ProtectedStepPlacementWindow(start: cursor, end: horizon.end) {
            windows.append(window)
        }
        return windows
    }
}
