import Foundation

enum PressureKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case light
    case crowded
    case tight
    case needsBuffer = "needs_buffer"

    var title: String {
        switch self {
        case .light:
            "Light"
        case .crowded:
            "Crowded"
        case .tight:
            "Tight"
        case .needsBuffer:
            "Needs buffer"
        }
    }
}

enum PressureRuleKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case fixedPointDensity = "fixed_point_density"
    case gapFragmentation = "gap_fragmentation"
    case pastDueSteps = "past_due_steps"
    case unclosedSteps = "unclosed_steps"
    case goalThreadLoad = "goal_thread_load"
    case shortTransitions = "short_transitions"
    case protectedWindowConflicts = "protected_window_conflicts"
    case manualCorrection = "manual_correction"
}

struct PressureRuleSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: PressureRuleKind
    let contribution: Int
    let summary: String
    let evidenceReferenceIDs: [String]

    init(
        kind: PressureRuleKind,
        contribution: Int,
        summary: String,
        evidenceReferenceIDs: [String] = []
    ) {
        self.id = "pressure.rule.\(kind.rawValue)"
        self.kind = kind
        self.contribution = contribution
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.evidenceReferenceIDs = Array(Set(evidenceReferenceIDs.filter { $0.isEmpty == false })).sorted()
    }
}

enum PressureCorrectionKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case feltCrowded = "felt_crowded"
    case feltLight = "felt_light"
    case needsTransitionBuffer = "needs_transition_buffer"
}

struct PressureCorrection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: PressureCorrectionKind
    let createdAt: String
    let evidenceReferenceID: String?

    init(
        id: String,
        kind: PressureCorrectionKind,
        createdAt: String,
        evidenceReferenceID: String? = nil
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.createdAt = createdAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.evidenceReferenceID = evidenceReferenceID?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct PressureReading: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: PressureKind
    let ordinal: Int
    let summary: String
    let semanticSummary: String
    let accessibilitySummary: String
    let ruleSnapshots: [PressureRuleSnapshot]
    let hiddenFromRootUI: Bool

    init(
        id: String,
        kind: PressureKind,
        ordinal: Int,
        summary: String,
        semanticSummary: String,
        accessibilitySummary: String,
        ruleSnapshots: [PressureRuleSnapshot],
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

    static func light(generatedAt: String = "unknown") -> PressureReading {
        PressureReading(
            id: "pressure.reading.\(generatedAt)",
            kind: .light,
            ordinal: 0,
            summary: PressureKind.light.title,
            semanticSummary: "Light: capacity has room.",
            accessibilitySummary: "Pressure is light. Capacity has room.",
            ruleSnapshots: [],
            hiddenFromRootUI: true
        )
    }
}

struct PressureEngine: Sendable, Equatable {
    func reading(
        from snapshot: RuntimeSnapshot,
        corrections: [PressureCorrection] = []
    ) -> PressureReading {
        reading(
            nowState: snapshot.nowState,
            capacityShape: snapshot.capacityShape,
            corrections: corrections
        )
    }

    func reading(
        nowState: CanonicalNowState,
        capacityShape: CapacityShape,
        corrections: [PressureCorrection] = []
    ) -> PressureReading {
        let baseSnapshots = [
            fixedPointDensity(nowState),
            gapFragmentation(capacityShape),
            pastDueSteps(nowState),
            unclosedSteps(nowState),
            goalThreadLoad(nowState),
            shortTransitions(capacityShape),
            protectedWindowConflicts(nowState, capacityShape)
        ]
        let correctionSnapshots = correctionRule(corrections).map { [$0] } ?? []
        let ruleSnapshots = baseSnapshots + correctionSnapshots
        let ordinal = max(0, ruleSnapshots.map { $0.contribution }.reduce(0, +))
        let kind = kind(for: ordinal)

        return PressureReading(
            id: "pressure.reading.\(nowState.id)",
            kind: kind,
            ordinal: ordinal,
            summary: kind.title,
            semanticSummary: semanticSummary(kind: kind),
            accessibilitySummary: accessibilitySummary(kind: kind),
            ruleSnapshots: ruleSnapshots,
            hiddenFromRootUI: true
        )
    }

    func kind(for ordinal: Int) -> PressureKind {
        switch max(0, ordinal) {
        case 0...1:
            .light
        case 2...3:
            .crowded
        case 4...5:
            .tight
        default:
            .needsBuffer
        }
    }

    private func fixedPointDensity(_ state: CanonicalNowState) -> PressureRuleSnapshot {
        PressureRuleSnapshot(
            kind: .fixedPointDensity,
            contribution: contribution(forCount: state.schedulePressure.itemCount, first: 3, second: 5),
            summary: "Fixed points are counted from local Time shape.",
            evidenceReferenceIDs: state.schedulePressure.evidenceReferenceIDs
        )
    }

    private func gapFragmentation(_ capacity: CapacityShape) -> PressureRuleSnapshot {
        let contribution: Int
        if capacity.flexibleMinutes <= 15 {
            contribution = 2
        } else if capacity.flexibleMinutes <= 45 {
            contribution = 1
        } else {
            contribution = 0
        }
        return PressureRuleSnapshot(
            kind: .gapFragmentation,
            contribution: contribution,
            summary: "Open time is checked for usable shape."
        )
    }

    private func pastDueSteps(_ state: CanonicalNowState) -> PressureRuleSnapshot {
        PressureRuleSnapshot(
            kind: .pastDueSteps,
            contribution: contribution(for: state.deadlinePressure.level),
            summary: "Dated Steps are checked before they shape the day.",
            evidenceReferenceIDs: state.deadlinePressure.evidenceReferenceIDs
        )
    }

    private func unclosedSteps(_ state: CanonicalNowState) -> PressureRuleSnapshot {
        PressureRuleSnapshot(
            kind: .unclosedSteps,
            contribution: contribution(forCount: state.blockersWaiting.blockedCount + state.blockersWaiting.waitingCount, first: 1, second: 3),
            summary: "Blocked and waiting Steps stay visible without blame."
        )
    }

    private func goalThreadLoad(_ state: CanonicalNowState) -> PressureRuleSnapshot {
        let goalCount = state.activeGoalPressure.count + state.passiveGoalPressure.count
        let evidenceIDs = (state.activeGoalPressure + state.passiveGoalPressure)
            .flatMap(\.eventLedgerEntryIDs)
        return PressureRuleSnapshot(
            kind: .goalThreadLoad,
            contribution: contribution(forCount: goalCount, first: 3, second: 6),
            summary: "Goal threads are counted as load, not as failure.",
            evidenceReferenceIDs: evidenceIDs
        )
    }

    private func shortTransitions(_ capacity: CapacityShape) -> PressureRuleSnapshot {
        let contribution = capacity.openMinutes > 0 && capacity.flexibleMinutes < 30 ? 1 : 0
        return PressureRuleSnapshot(
            kind: .shortTransitions,
            contribution: contribution,
            summary: "Short transitions can ask for buffer."
        )
    }

    private func protectedWindowConflicts(_ state: CanonicalNowState, _ capacity: CapacityShape) -> PressureRuleSnapshot {
        let contribution = capacity.protectedMinutes > 0 && state.blockersWaiting.blockedCount > 0 ? 1 : 0
        return PressureRuleSnapshot(
            kind: .protectedWindowConflicts,
            contribution: contribution,
            summary: "Protected windows stay protected when pressure is read."
        )
    }

    private func correctionRule(_ corrections: [PressureCorrection]) -> PressureRuleSnapshot? {
        let contribution = corrections.reduce(0) { partial, correction in
            switch correction.kind {
            case .feltCrowded, .needsTransitionBuffer:
                partial + 1
            case .feltLight:
                partial - 1
            }
        }
        guard contribution != 0 else { return nil }
        return PressureRuleSnapshot(
            kind: .manualCorrection,
            contribution: contribution,
            summary: "Manual correction calibrates the next reading.",
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

    private func semanticSummary(kind: PressureKind) -> String {
        switch kind {
        case .light:
            "Light: capacity has room."
        case .crowded:
            "Crowded: choose one Step with care."
        case .tight:
            "Tight: protect recovery before adding more."
        case .needsBuffer:
            "Needs buffer: shorten or protect one window."
        }
    }

    private func accessibilitySummary(kind: PressureKind) -> String {
        switch kind {
        case .light:
            "Pressure is light. Capacity has room."
        case .crowded:
            "Pressure is crowded. Choose one Step with care."
        case .tight:
            "Pressure is tight. Protect recovery before adding more."
        case .needsBuffer:
            "Pressure needs buffer. Shorten or protect one window."
        }
    }
}
