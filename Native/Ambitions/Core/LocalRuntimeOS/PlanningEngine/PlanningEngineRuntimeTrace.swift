import Foundation

enum PlanningRuntimeSpineStep: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case event
    case projection
    case receipt
    case replay

    static let requiredSpine: [PlanningRuntimeSpineStep] = [
        .command,
        .event,
        .projection,
        .receipt,
        .replay
    ]
}

struct PlanningEngineRuntimeTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let commandID: String
    let eventID: String
    let projectionID: String
    let receiptID: String
    let replayTraceID: String
    let sourceFingerprint: String
    let checksum: String
    let mutationSpine: [PlanningRuntimeSpineStep]
    let localOnly: Bool

    init(
        commandID: String,
        eventID: String,
        projectionID: String,
        receiptID: String,
        replayTraceID: String,
        sourceFingerprint: String,
        mutationSpine: [PlanningRuntimeSpineStep] = PlanningRuntimeSpineStep.requiredSpine,
        localOnly: Bool = true
    ) {
        self.commandID = Self.normalizedRequired(commandID)
        self.eventID = Self.normalizedRequired(eventID)
        self.projectionID = Self.normalizedRequired(projectionID)
        self.receiptID = Self.normalizedRequired(receiptID)
        self.replayTraceID = Self.normalizedRequired(replayTraceID)
        self.sourceFingerprint = Self.normalizedRequired(sourceFingerprint)
        self.mutationSpine = mutationSpine.isEmpty ? PlanningRuntimeSpineStep.requiredSpine : mutationSpine
        self.localOnly = localOnly
        self.checksum = CandidateSource.stableIdentifier(
            prefix: "planning-runtime-checksum",
            components: [
                self.commandID,
                self.eventID,
                self.projectionID,
                self.receiptID,
                self.replayTraceID,
                self.sourceFingerprint,
                self.mutationSpine.map(\.rawValue).joined(separator: ","),
                localOnly ? "local" : "non-local"
            ]
        )
        self.id = CandidateSource.stableIdentifier(
            prefix: "planning-runtime-trace",
            components: [
                self.commandID,
                self.eventID,
                self.projectionID,
                self.receiptID,
                self.replayTraceID,
                self.checksum
            ]
        )
    }

    var satisfiesCommandEventProjectionReceiptReplay: Bool {
        localOnly &&
            mutationSpine == PlanningRuntimeSpineStep.requiredSpine &&
            [commandID, eventID, projectionID, receiptID, replayTraceID, sourceFingerprint, checksum].allSatisfy { $0.isEmpty == false }
    }

    static func make(owner: String, generatedAt: String, components: [String], localOnly: Bool = true) -> PlanningEngineRuntimeTrace {
        let fingerprint = CandidateSource.stableIdentifier(
            prefix: "planning-source",
            components: [owner, generatedAt] + components
        )
        return PlanningEngineRuntimeTrace(
            commandID: CandidateSource.stableIdentifier(prefix: "planning-command", components: [fingerprint]),
            eventID: CandidateSource.stableIdentifier(prefix: "planning-event", components: [fingerprint]),
            projectionID: CandidateSource.stableIdentifier(prefix: "planning-projection", components: [fingerprint]),
            receiptID: CandidateSource.stableIdentifier(prefix: "planning-receipt", components: [fingerprint]),
            replayTraceID: CandidateSource.stableIdentifier(prefix: "planning-replay", components: [fingerprint]),
            sourceFingerprint: fingerprint,
            localOnly: localOnly
        )
    }

    static func normalizedRequired(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected a non-empty string")
        return trimmed
    }
}
