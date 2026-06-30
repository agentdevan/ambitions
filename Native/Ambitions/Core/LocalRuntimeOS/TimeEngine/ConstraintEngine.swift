import Foundation

enum TimeConstraintKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noOverlap = "no_overlap"
    case protectedWindow = "protected_window"
    case keepClear = "keep_clear"
    case capacityLimit = "capacity_limit"
    case localOnly = "local_only"
}

enum TimeConstraintViolationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case overlappingBlocks = "overlapping_blocks"
    case protectedWindowConflict = "protected_window_conflict"
    case keepClearConflict = "keep_clear_conflict"
    case capacityExceeded = "capacity_exceeded"
    case nonLocalBlock = "non_local_block"
}

struct TimeConstraint: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: TimeConstraintKind
    let window: ProtectedStepPlacementWindow?
    let maxMinutes: Int?
    let affectedObjectIDs: [String]
    let summary: String

    init(
        id: String? = nil,
        kind: TimeConstraintKind,
        window: ProtectedStepPlacementWindow? = nil,
        maxMinutes: Int? = nil,
        affectedObjectIDs: [String] = [],
        summary: String
    ) {
        self.kind = kind
        self.window = window
        self.maxMinutes = maxMinutes.map { max(1, $0) }
        self.affectedObjectIDs = TimeEngineStableID.unique(affectedObjectIDs)
        self.summary = TimeEngineStableID.required(summary)
        self.id = TimeEngineStableID.optional(id) ?? TimeEngineStableID.make(
            prefix: "time-constraint",
            components: [
                kind.rawValue,
                window.map { "\(TemporalMath.string(from: $0.start))-\(TemporalMath.string(from: $0.end))" } ?? "unbounded",
                "\(self.maxMinutes ?? 0)",
                self.affectedObjectIDs.joined(separator: ","),
                self.summary
            ]
        )
    }
}

struct TimeConstraintViolation: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: TimeConstraintViolationKind
    let constraintID: String
    let blockIDs: [String]
    let severity: TimeConflictSeverity
    let reason: String

    init(
        kind: TimeConstraintViolationKind,
        constraintID: String,
        blockIDs: [String],
        severity: TimeConflictSeverity,
        reason: String
    ) {
        self.kind = kind
        self.constraintID = TimeEngineStableID.required(constraintID)
        self.blockIDs = TimeEngineStableID.unique(blockIDs)
        self.severity = severity
        self.reason = TimeEngineStableID.required(reason)
        id = TimeEngineStableID.make(prefix: "time-constraint-violation", components: [kind.rawValue, self.constraintID, self.blockIDs.joined(separator: ","), severity.rawValue])
    }
}

struct TimeConstraintEvaluation: Codable, Sendable, Equatable, Hashable {
    let violations: [TimeConstraintViolation]
    let runtimeTrace: TimeEngineRuntimeTrace

    var blockingViolations: [TimeConstraintViolation] {
        violations.filter { $0.severity == .blocking }
    }

    var hasBlockingViolation: Bool {
        blockingViolations.isEmpty == false
    }
}

struct ConstraintEngine: Sendable {
    func evaluate(
        graph: TimeBlockGraph,
        candidate: TimeBlock? = nil,
        constraints: [TimeConstraint] = []
    ) -> TimeConstraintEvaluation {
        let candidateGraph = candidate.map { graph.adding($0) } ?? graph
        var violations: [TimeConstraintViolation] = candidateGraph.conflicts.map { conflict in
            TimeConstraintViolation(
                kind: .overlappingBlocks,
                constraintID: TimeConstraint.noOverlap.id,
                blockIDs: [conflict.firstBlockID, conflict.secondBlockID],
                severity: conflict.severity,
                reason: conflict.reason
            )
        }

        let blocks = candidate.map { [$0] } ?? candidateGraph.blocks
        for constraint in constraints + [TimeConstraint.localOnly] {
            violations.append(contentsOf: evaluate(constraint: constraint, blocks: blocks, graph: candidateGraph))
        }

        let uniqueViolations = Dictionary(grouping: violations, by: \.id).compactMap { $0.value.first }.sorted { $0.id < $1.id }
        return TimeConstraintEvaluation(
            violations: uniqueViolations,
            runtimeTrace: TimeEngineRuntimeTrace.make(
                owner: "ConstraintEngine",
                sourceID: [candidateGraph.id, uniqueViolations.map(\.id).joined(separator: ",")].joined(separator: "|"),
                localOnly: candidateGraph.localOnly
            )
        )
    }

    private func evaluate(
        constraint: TimeConstraint,
        blocks: [TimeBlock],
        graph: TimeBlockGraph
    ) -> [TimeConstraintViolation] {
        switch constraint.kind {
        case .noOverlap:
            return []
        case .localOnly:
            return blocks.filter { $0.localOnly == false }.map { block in
                TimeConstraintViolation(
                    kind: .nonLocalBlock,
                    constraintID: constraint.id,
                    blockIDs: [block.id],
                    severity: .blocking,
                    reason: "TimeEngine blocks must stay local and account-free."
                )
            }
        case .protectedWindow, .keepClear:
            guard let window = constraint.window else { return [] }
            return blocks.filter { $0.intersects(window) && $0.kind.protectsBoundary == false }.map { block in
                TimeConstraintViolation(
                    kind: constraint.kind == .protectedWindow ? .protectedWindowConflict : .keepClearConflict,
                    constraintID: constraint.id,
                    blockIDs: [block.id],
                    severity: .blocking,
                    reason: constraint.summary
                )
            }
        case .capacityLimit:
            guard let window = constraint.window, let maxMinutes = constraint.maxMinutes else { return [] }
            let capacityMinutes = graph.blocks(intersecting: window)
                .filter(\.kind.consumesCapacity)
                .reduce(0) { partial, block in
                    partial + TemporalMath.overlapMinutes(start: block.start, end: block.end, otherStart: window.start, otherEnd: window.end)
                }
            guard capacityMinutes > maxMinutes else { return [] }
            return [
                TimeConstraintViolation(
                    kind: .capacityExceeded,
                    constraintID: constraint.id,
                    blockIDs: graph.blocks(intersecting: window).map(\.id),
                    severity: .blocking,
                    reason: "Capacity exceeds \(maxMinutes) minutes inside the evaluated window."
                )
            ]
        }
    }
}

extension TimeConstraint {
    static let localOnly = TimeConstraint(kind: .localOnly, summary: "TimeEngine state must remain local-only.")
    static let noOverlap = TimeConstraint(kind: .noOverlap, summary: "Time blocks should not overlap without review.")

    static func protected(window: ProtectedStepPlacementWindow, summary: String = "Protected time requires review before placement.") -> TimeConstraint {
        TimeConstraint(kind: .protectedWindow, window: window, summary: summary)
    }

    static func keepClear(window: ProtectedStepPlacementWindow, summary: String = "This window should stay clear.") -> TimeConstraint {
        TimeConstraint(kind: .keepClear, window: window, summary: summary)
    }

    static func capacityLimit(window: ProtectedStepPlacementWindow, maxMinutes: Int) -> TimeConstraint {
        TimeConstraint(kind: .capacityLimit, window: window, maxMinutes: maxMinutes, summary: "Capacity limit for local TimeEngine evaluation.")
    }
}
