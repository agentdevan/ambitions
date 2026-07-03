import Foundation

enum BufferKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case roomAvailable = "room_available"
    case keepLight = "keep_light"
    case addRoom = "add_room"
    case needsBuffer = "needs_buffer"

    var title: String {
        switch self {
        case .roomAvailable:
            "Room available"
        case .keepLight:
            "Keep light"
        case .addRoom:
            "Add room"
        case .needsBuffer:
            "Needs buffer"
        }
    }
}

enum BufferRuleKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case blockedOrMovedSteps = "blocked_or_moved_steps"
    case fixedPointDensity = "fixed_point_density"
    case lateDayCompression = "late_day_compression"
    case planningDefaultBuffer = "planning_default_buffer"
    case recentClosurePattern = "recent_closure_pattern"
    case manualCorrection = "manual_correction"
}

struct BufferRuleSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: BufferRuleKind
    let contribution: Int
    let summary: String
    let evidenceReferenceIDs: [String]

    init(
        kind: BufferRuleKind,
        contribution: Int,
        summary: String,
        evidenceReferenceIDs: [String] = []
    ) {
        self.id = "buffer.rule.\(kind.rawValue)"
        self.kind = kind
        self.contribution = contribution
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.evidenceReferenceIDs = Array(Set(evidenceReferenceIDs.filter { $0.isEmpty == false })).sorted()
    }
}

enum BufferCorrectionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case needsMoreRoom = "needs_more_room"
    case addedFutureRoom = "added_future_room"
    case keepBlockLight = "keep_block_light"
}

struct BufferCorrection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: BufferCorrectionKind
    let createdAt: String
    let evidenceReferenceID: String?

    init(
        id: String,
        kind: BufferCorrectionKind,
        createdAt: String,
        evidenceReferenceID: String? = nil
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.createdAt = createdAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.evidenceReferenceID = evidenceReferenceID?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct BufferReading: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: BufferKind
    let ordinal: Int
    let summary: String
    let semanticSummary: String
    let accessibilitySummary: String
    let ruleSnapshots: [BufferRuleSnapshot]
    let hiddenFromRootUI: Bool

    init(
        id: String,
        kind: BufferKind,
        ordinal: Int,
        summary: String,
        semanticSummary: String,
        accessibilitySummary: String,
        ruleSnapshots: [BufferRuleSnapshot],
        hiddenFromRootUI: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.ordinal = max(0, ordinal)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.semanticSummary = semanticSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.accessibilitySummary = accessibilitySummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.ruleSnapshots = ruleSnapshots.sorted { $0.kind.rawValue < $1.kind.rawValue }
        self.hiddenFromRootUI = hiddenFromRootUI
    }

    static func roomAvailable(generatedAt: String = "unknown") -> BufferReading {
        BufferReading(
            id: "buffer.reading.\(generatedAt)",
            kind: .roomAvailable,
            ordinal: 0,
            summary: BufferKind.roomAvailable.title,
            semanticSummary: "Room available: schedule has room around the next block.",
            accessibilitySummary: "Buffer room is available around the next block.",
            ruleSnapshots: [],
            hiddenFromRootUI: true
        )
    }
}

struct BufferEngine: Sendable, Equatable {
    func reading(
        from snapshot: RuntimeSnapshot,
        corrections: [BufferCorrection] = []
    ) -> BufferReading {
        reading(
            nowState: snapshot.nowState,
            capacityShape: snapshot.capacityShape,
            corrections: corrections
        )
    }

    func reading(
        nowState: CanonicalNowState,
        capacityShape: CapacityShape,
        corrections: [BufferCorrection] = []
    ) -> BufferReading {
        let baseSnapshots = [
            blockedOrMovedSteps(nowState),
            fixedPointDensity(nowState),
            lateDayCompression(nowState, capacityShape),
            planningDefaultBuffer(capacityShape),
            recentClosurePattern(nowState)
        ]
        let correctionSnapshots = correctionRule(corrections).map { [$0] } ?? []
        let ruleSnapshots = baseSnapshots + correctionSnapshots
        let ordinal = max(0, ruleSnapshots.map(\.contribution).reduce(0, +))
        let kind = kind(for: ordinal)

        return BufferReading(
            id: "buffer.reading.\(nowState.id)",
            kind: kind,
            ordinal: ordinal,
            summary: summary(kind: kind, nowState: nowState),
            semanticSummary: semanticSummary(kind: kind),
            accessibilitySummary: accessibilitySummary(kind: kind),
            ruleSnapshots: ruleSnapshots,
            hiddenFromRootUI: true
        )
    }

    func kind(for ordinal: Int) -> BufferKind {
        switch max(0, ordinal) {
        case 0:
            .roomAvailable
        case 1...2:
            .keepLight
        case 3...4:
            .addRoom
        default:
            .needsBuffer
        }
    }

    private func blockedOrMovedSteps(_ state: CanonicalNowState) -> BufferRuleSnapshot {
        BufferRuleSnapshot(
            kind: .blockedOrMovedSteps,
            contribution: contribution(forCount: state.blockersWaiting.blockedCount + state.blockersWaiting.waitingCount, first: 1, second: 3),
            summary: "Blocked and moved Steps are counted as schedule room needs.",
            evidenceReferenceIDs: state.blockersWaiting.references.flatMap { reference in
                [reference.goalID, reference.stepID, reference.captureID, reference.timeID].compactMap { $0 }
            }
        )
    }

    private func fixedPointDensity(_ state: CanonicalNowState) -> BufferRuleSnapshot {
        BufferRuleSnapshot(
            kind: .fixedPointDensity,
            contribution: contribution(forCount: state.schedulePressure.itemCount, first: 3, second: 5),
            summary: "Fixed points are counted before adding more load.",
            evidenceReferenceIDs: state.schedulePressure.evidenceReferenceIDs
        )
    }

    private func lateDayCompression(_ state: CanonicalNowState, _ capacity: CapacityShape) -> BufferRuleSnapshot {
        let contribution = isAfterFivePM(state.generatedAt) && capacity.flexibleMinutes <= 45 ? 2 : 0
        return BufferRuleSnapshot(
            kind: .lateDayCompression,
            contribution: contribution,
            summary: "Late-day compression checks schedule room after 5:00 PM."
        )
    }

    private func planningDefaultBuffer(_ capacity: CapacityShape) -> BufferRuleSnapshot {
        let contribution = capacity.openMinutes > 0 && capacity.flexibleMinutes < 20 ? 1 : 0
        return BufferRuleSnapshot(
            kind: .planningDefaultBuffer,
            contribution: contribution,
            summary: "Planning defaults keep room around fixed points."
        )
    }

    private func recentClosurePattern(_ state: CanonicalNowState) -> BufferRuleSnapshot {
        BufferRuleSnapshot(
            kind: .recentClosurePattern,
            contribution: contribution(for: state.captureUrgency.level),
            summary: "Recent closure and review load can reserve schedule room.",
            evidenceReferenceIDs: state.captureUrgency.evidenceReferenceIDs
        )
    }

    private func correctionRule(_ corrections: [BufferCorrection]) -> BufferRuleSnapshot? {
        let contribution = corrections.reduce(0) { partial, correction in
            switch correction.kind {
            case .needsMoreRoom, .keepBlockLight:
                partial + 1
            case .addedFutureRoom:
                partial - 2
            }
        }
        guard contribution != 0 else { return nil }
        return BufferRuleSnapshot(
            kind: .manualCorrection,
            contribution: contribution,
            summary: "Manual correction creates inspectable schedule-room proof.",
            evidenceReferenceIDs: corrections.compactMap(\.evidenceReferenceID)
        )
    }

    private func contribution(for level: NowPressureLevel) -> Int {
        switch level {
        case .none, .low:
            0
        case .moderate:
            1
        case .elevated:
            2
        case .high, .critical:
            3
        }
    }

    private func contribution(forCount count: Int, first: Int, second: Int) -> Int {
        if count >= second {
            return 2
        }
        if count >= first {
            return 1
        }
        return 0
    }

    private func isAfterFivePM(_ timestamp: String) -> Bool {
        guard let date = DomainTimestamp.date(from: timestamp) else { return false }
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        let hour = calendar.component(.hour, from: date)
        return hour >= 17
    }

    private func summary(kind: BufferKind, nowState: CanonicalNowState) -> String {
        switch kind {
        case .roomAvailable:
            BufferKind.roomAvailable.title
        case .keepLight:
            "Keep this block light."
        case .addRoom:
            "Add room after this fixed point."
        case .needsBuffer:
            isAfterFivePM(nowState.generatedAt) ? "Needs buffer after 5:00 PM." : "Needs buffer."
        }
    }

    private func semanticSummary(kind: BufferKind) -> String {
        switch kind {
        case .roomAvailable:
            "Room available: schedule has room around the next block."
        case .keepLight:
            "Keep light: keep this block light."
        case .addRoom:
            "Add room: add room after this fixed point."
        case .needsBuffer:
            "Needs buffer: add room before adding more load."
        }
    }

    private func accessibilitySummary(kind: BufferKind) -> String {
        switch kind {
        case .roomAvailable:
            "Buffer room is available around the next block."
        case .keepLight:
            "Buffer says keep this block light."
        case .addRoom:
            "Buffer says add room after this fixed point."
        case .needsBuffer:
            "Buffer needs schedule room before adding more load."
        }
    }
}
