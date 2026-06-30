import Foundation

struct RecoveryWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let window: ProtectedStepPlacementWindow
    let durationMinutes: Int
    let reason: String
    let runtimeTrace: TimeEngineRuntimeTrace

    init(window: ProtectedStepPlacementWindow, reason: String, localOnly: Bool) {
        self.window = window
        durationMinutes = TemporalMath.durationMinutes(start: window.start, end: window.end)
        self.reason = TimeEngineStableID.required(reason)
        let source = [TemporalMath.string(from: window.start), TemporalMath.string(from: window.end), self.reason].joined(separator: "|")
        runtimeTrace = TimeEngineRuntimeTrace.make(owner: "RecoveryWindowEngine", sourceID: source, localOnly: localOnly)
        id = TimeEngineStableID.make(prefix: "recovery-window", components: [source])
    }
}

struct RecoveryWindowEngine: Sendable {
    private let capacityEngine: CapacityEnvelopeEngine

    init(capacityEngine: CapacityEnvelopeEngine = CapacityEnvelopeEngine()) {
        self.capacityEngine = capacityEngine
    }

    func recoveryWindows(
        graph: TimeBlockGraph,
        horizon: ProtectedStepPlacementWindow,
        minimumDurationMinutes: Int = 30
    ) -> [RecoveryWindow] {
        let envelope = capacityEngine.evaluate(graph: graph, horizon: horizon)
        let windows = graph.availableWindows(in: horizon, minimumDurationMinutes: minimumDurationMinutes)
        let reason: String
        switch envelope.pressure {
        case .overloaded:
            reason = "Pressure is overloaded; recovery space should be protected before more placement."
        case .tight:
            reason = "Capacity is tight; preserve recovery margin."
        case .steady, .light:
            reason = "Recovery space is available without disrupting protected work."
        }
        return windows.map { RecoveryWindow(window: $0, reason: reason, localOnly: graph.localOnly) }
    }
}
