import Foundation

enum TimeCapacityPressure: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case light
    case steady
    case tight
    case overloaded
}

struct CapacityEnvelope: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let horizon: ProtectedStepPlacementWindow
    let committedMinutes: Int
    let availableMinutes: Int
    let protectedMinutes: Int
    let recoveryMinutes: Int
    let pressure: TimeCapacityPressure
    let localOnly: Bool
    let runtimeTrace: SchedulingRuntimeTrace

    var hasRecoveryMargin: Bool {
        recoveryMinutes >= 30 || availableMinutes >= 60
    }
}

struct CapacityEnvelopeEngine: Sendable {
    func evaluate(graph: TimeBlockGraph, horizon: ProtectedStepPlacementWindow, expectedCapacityMinutes: Int? = nil) -> CapacityEnvelope {
        let visibleBlocks = graph.blocks(intersecting: horizon)
        let committed = visibleBlocks
            .filter(\.kind.consumesCapacity)
            .reduce(0) { partial, block in
                partial + TemporalMath.overlapMinutes(start: block.start, end: block.end, otherStart: horizon.start, otherEnd: horizon.end)
            }
        let protected = visibleBlocks
            .filter(\.kind.protectsBoundary)
            .reduce(0) { partial, block in
                partial + TemporalMath.overlapMinutes(start: block.start, end: block.end, otherStart: horizon.start, otherEnd: horizon.end)
            }
        let recovery = visibleBlocks
            .filter { $0.kind == .recovery }
            .reduce(0) { partial, block in
                partial + TemporalMath.overlapMinutes(start: block.start, end: block.end, otherStart: horizon.start, otherEnd: horizon.end)
            }
        let defaultCapacity = TemporalMath.durationMinutes(start: horizon.start, end: horizon.end)
        let capacity = max(0, expectedCapacityMinutes ?? defaultCapacity)
        let available = max(0, capacity - committed)
        let pressure = pressure(committed: committed, capacity: capacity)
        let sourceID = [graph.id, TemporalMath.string(from: horizon.start), TemporalMath.string(from: horizon.end), "\(capacity)", "\(committed)"].joined(separator: "|")
        let trace = SchedulingRuntimeTrace.make(owner: "CapacityEnvelopeEngine", sourceID: sourceID, localOnly: graph.localOnly)
        return CapacityEnvelope(
            id: SchedulingStableID.make(prefix: "capacity-envelope", components: [sourceID]),
            horizon: horizon,
            committedMinutes: committed,
            availableMinutes: available,
            protectedMinutes: protected,
            recoveryMinutes: recovery,
            pressure: pressure,
            localOnly: graph.localOnly,
            runtimeTrace: trace
        )
    }

    private func pressure(committed: Int, capacity: Int) -> TimeCapacityPressure {
        guard capacity > 0 else { return committed > 0 ? .overloaded : .light }
        let ratio = Double(committed) / Double(capacity)
        if ratio >= 1.0 { return .overloaded }
        if ratio >= 0.75 { return .tight }
        if ratio >= 0.35 { return .steady }
        return .light
    }
}
