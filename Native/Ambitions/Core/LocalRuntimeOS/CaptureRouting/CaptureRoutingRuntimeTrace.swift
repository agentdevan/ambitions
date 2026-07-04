import Foundation

enum CaptureRoutingRuntimeSpineStep: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case event
    case projection
    case receipt
    case replay

    static let required: [CaptureRoutingRuntimeSpineStep] = [
        .command,
        .event,
        .projection,
        .receipt,
        .replay
    ]
}

struct CaptureRoutingRuntimeTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let owner: String
    let commandID: String
    let eventID: String
    let projectionID: String
    let receiptID: String
    let replayTraceID: String
    let checksum: String
    let localOnly: Bool
    let mutationSpine: [CaptureRoutingRuntimeSpineStep]

    init(
        owner: String,
        commandID: String,
        eventID: String,
        projectionID: String,
        receiptID: String,
        replayTraceID: String,
        localOnly: Bool = true,
        mutationSpine: [CaptureRoutingRuntimeSpineStep] = CaptureRoutingRuntimeSpineStep.required
    ) {
        self.owner = CaptureRoutingStableID.required(owner)
        self.commandID = CaptureRoutingStableID.required(commandID)
        self.eventID = CaptureRoutingStableID.required(eventID)
        self.projectionID = CaptureRoutingStableID.required(projectionID)
        self.receiptID = CaptureRoutingStableID.required(receiptID)
        self.replayTraceID = CaptureRoutingStableID.required(replayTraceID)
        self.localOnly = localOnly
        self.mutationSpine = mutationSpine.isEmpty ? CaptureRoutingRuntimeSpineStep.required : mutationSpine
        checksum = CaptureRoutingStableID.make(
            prefix: "capture-routing.checksum",
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
        id = CaptureRoutingStableID.make(prefix: "capture-routing.trace", components: [self.owner, checksum])
    }

    var satisfiesRuntimeSpine: Bool {
        localOnly &&
            mutationSpine == CaptureRoutingRuntimeSpineStep.required &&
            [owner, commandID, eventID, projectionID, receiptID, replayTraceID, checksum].allSatisfy { $0.isEmpty == false }
    }

    static func make(owner: String, sourceID: String, localOnly: Bool = true) -> CaptureRoutingRuntimeTrace {
        let normalizedOwner = CaptureRoutingStableID.required(owner)
        let normalizedSource = CaptureRoutingStableID.required(sourceID)
        return CaptureRoutingRuntimeTrace(
            owner: normalizedOwner,
            commandID: CaptureRoutingStableID.make(prefix: "capture-routing.command", components: [normalizedOwner, normalizedSource]),
            eventID: CaptureRoutingStableID.make(prefix: "capture-routing.event", components: [normalizedOwner, normalizedSource]),
            projectionID: CaptureRoutingStableID.make(prefix: "capture-routing.projection", components: [normalizedOwner, normalizedSource]),
            receiptID: CaptureRoutingStableID.make(prefix: "capture-routing.receipt", components: [normalizedOwner, normalizedSource]),
            replayTraceID: CaptureRoutingStableID.make(prefix: "capture-routing.replay", components: [normalizedOwner, normalizedSource]),
            localOnly: localOnly
        )
    }
}

enum CaptureRoutingStableID {
    static func make(prefix: String, components: [String]) -> String {
        let normalizedPrefix = slug(prefix)
        let normalizedComponents = components.map(slug).filter { $0.isEmpty == false }
        let payload = ([normalizedPrefix] + normalizedComponents).joined(separator: "|")
        let digest = fnv1a64(payload)
        return "\(normalizedPrefix).\(String(digest, radix: 16))"
    }

    static func required(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected non-empty CaptureRouting identifier")
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

    static func checksum(prefix: String, components: [String]) -> String {
        make(prefix: "\(prefix).checksum", components: components)
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
