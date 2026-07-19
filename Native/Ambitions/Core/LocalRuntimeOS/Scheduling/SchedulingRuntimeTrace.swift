import Foundation

enum SchedulingRuntimeSpineStep: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case event
    case projection
    case receipt
    case replay

    static let required: [SchedulingRuntimeSpineStep] = [
        .command,
        .event,
        .projection,
        .receipt,
        .replay
    ]
}

struct SchedulingRuntimeTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let owner: String
    let commandID: String
    let eventID: String
    let projectionID: String
    let receiptID: String
    let replayTraceID: String
    let checksum: String
    let localOnly: Bool
    let mutationSpine: [SchedulingRuntimeSpineStep]

    init(
        owner: String,
        commandID: String,
        eventID: String,
        projectionID: String,
        receiptID: String,
        replayTraceID: String,
        localOnly: Bool = true,
        mutationSpine: [SchedulingRuntimeSpineStep] = SchedulingRuntimeSpineStep.required
    ) {
        self.owner = SchedulingStableID.required(owner)
        self.commandID = SchedulingStableID.required(commandID)
        self.eventID = SchedulingStableID.required(eventID)
        self.projectionID = SchedulingStableID.required(projectionID)
        self.receiptID = SchedulingStableID.required(receiptID)
        self.replayTraceID = SchedulingStableID.required(replayTraceID)
        self.localOnly = localOnly
        self.mutationSpine = mutationSpine.isEmpty ? SchedulingRuntimeSpineStep.required : mutationSpine
        checksum = SchedulingStableID.make(
            prefix: "scheduling.checksum",
            components: [
                self.owner,
                self.commandID,
                self.eventID,
                self.projectionID,
                self.receiptID,
                self.replayTraceID,
                localOnly ? "local" : "non-local",
                self.mutationSpine.map(\.rawValue).joined(separator: ",")
            ]
        )
        id = SchedulingStableID.make(prefix: "scheduling.trace", components: [self.owner, checksum])
    }

    var satisfiesRuntimeSpine: Bool {
        localOnly &&
            mutationSpine == SchedulingRuntimeSpineStep.required &&
            [owner, commandID, eventID, projectionID, receiptID, replayTraceID, checksum].allSatisfy { $0.isEmpty == false }
    }

    static func make(owner: String, sourceID: String, localOnly: Bool = true) -> SchedulingRuntimeTrace {
        let normalizedOwner = SchedulingStableID.required(owner)
        let normalizedSource = SchedulingStableID.required(sourceID)
        return SchedulingRuntimeTrace(
            owner: normalizedOwner,
            commandID: SchedulingStableID.make(prefix: "scheduling.command", components: [normalizedOwner, normalizedSource]),
            eventID: SchedulingStableID.make(prefix: "scheduling.event", components: [normalizedOwner, normalizedSource]),
            projectionID: SchedulingStableID.make(prefix: "scheduling.projection", components: [normalizedOwner, normalizedSource]),
            receiptID: SchedulingStableID.make(prefix: "scheduling.receipt", components: [normalizedOwner, normalizedSource]),
            replayTraceID: SchedulingStableID.make(prefix: "scheduling.replay", components: [normalizedOwner, normalizedSource]),
            localOnly: localOnly
        )
    }
}

enum SchedulingStableID {
    static func make(prefix: String, components: [String]) -> String {
        let normalizedPrefix = slug(prefix)
        let normalizedComponents = components.map(slug).filter { $0.isEmpty == false }
        let payload = ([normalizedPrefix] + normalizedComponents).joined(separator: "|")
        let digest = fnv1a64(payload)
        return "\(normalizedPrefix).\(String(digest, radix: 16))"
    }

    static func required(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected non-empty Scheduling identifier")
        return trimmed
    }

    static func optional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    static func unique(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.compactMap(optional).filter { seen.insert($0).inserted }.sorted()
    }

    private static func slug(_ value: String) -> String {
        let lowered = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        var output = ""
        for character in lowered {
            if character.isLetter || character.isNumber {
                output.append(character)
            } else if output.last != "-" {
                output.append("-")
            }
        }
        return output.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }

    private static func fnv1a64(_ value: String) -> UInt64 {
        var hash: UInt64 = 1_469_598_103_934_665_603
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1_099_511_628_211
        }
        return hash
    }
}
