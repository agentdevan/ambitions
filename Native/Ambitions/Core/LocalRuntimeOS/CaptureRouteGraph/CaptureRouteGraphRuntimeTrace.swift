import Foundation

enum CaptureRouteGraphRuntimeSpineStep: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case command
    case event
    case projection
    case receipt
    case replay

    static let required: [CaptureRouteGraphRuntimeSpineStep] = [
        .command,
        .event,
        .projection,
        .receipt,
        .replay
    ]
}

struct CaptureRouteGraphRuntimeTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let owner: String
    let commandID: String
    let eventID: String
    let projectionID: String
    let receiptID: String
    let replayTraceID: String
    let checksum: String
    let localOnly: Bool
    let mutationSpine: [CaptureRouteGraphRuntimeSpineStep]

    init(
        owner: String,
        commandID: String,
        eventID: String,
        projectionID: String,
        receiptID: String,
        replayTraceID: String,
        localOnly: Bool = true,
        mutationSpine: [CaptureRouteGraphRuntimeSpineStep] = CaptureRouteGraphRuntimeSpineStep.required
    ) {
        self.owner = CaptureRouteGraphStableID.required(owner)
        self.commandID = CaptureRouteGraphStableID.required(commandID)
        self.eventID = CaptureRouteGraphStableID.required(eventID)
        self.projectionID = CaptureRouteGraphStableID.required(projectionID)
        self.receiptID = CaptureRouteGraphStableID.required(receiptID)
        self.replayTraceID = CaptureRouteGraphStableID.required(replayTraceID)
        self.localOnly = localOnly
        self.mutationSpine = mutationSpine.isEmpty ? CaptureRouteGraphRuntimeSpineStep.required : mutationSpine
        checksum = CaptureRouteGraphStableID.make(
            prefix: "capture-route.checksum",
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
        id = CaptureRouteGraphStableID.make(prefix: "capture-route.trace", components: [self.owner, checksum])
    }

    var satisfiesRuntimeSpine: Bool {
        localOnly &&
            mutationSpine == CaptureRouteGraphRuntimeSpineStep.required &&
            [owner, commandID, eventID, projectionID, receiptID, replayTraceID, checksum].allSatisfy { $0.isEmpty == false }
    }

    static func make(owner: String, sourceID: String, localOnly: Bool = true) -> CaptureRouteGraphRuntimeTrace {
        let normalizedOwner = CaptureRouteGraphStableID.required(owner)
        let normalizedSource = CaptureRouteGraphStableID.required(sourceID)
        return CaptureRouteGraphRuntimeTrace(
            owner: normalizedOwner,
            commandID: CaptureRouteGraphStableID.make(prefix: "capture-route.command", components: [normalizedOwner, normalizedSource]),
            eventID: CaptureRouteGraphStableID.make(prefix: "capture-route.event", components: [normalizedOwner, normalizedSource]),
            projectionID: CaptureRouteGraphStableID.make(prefix: "capture-route.projection", components: [normalizedOwner, normalizedSource]),
            receiptID: CaptureRouteGraphStableID.make(prefix: "capture-route.receipt", components: [normalizedOwner, normalizedSource]),
            replayTraceID: CaptureRouteGraphStableID.make(prefix: "capture-route.replay", components: [normalizedOwner, normalizedSource]),
            localOnly: localOnly
        )
    }
}

enum CaptureRouteGraphStableID {
    static func make(prefix: String, components: [String]) -> String {
        let normalizedPrefix = slug(prefix)
        let normalizedComponents = components.map(slug).filter { $0.isEmpty == false }
        let payload = ([normalizedPrefix] + normalizedComponents).joined(separator: "|")
        let digest = fnv1a64(payload)
        return "\(normalizedPrefix).\(String(digest, radix: 16))"
    }

    static func required(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        precondition(trimmed.isEmpty == false, "Expected non-empty CaptureRouteGraph identifier")
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
