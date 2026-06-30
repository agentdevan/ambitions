import Foundation

struct RuntimeCausalClock: Codable, Equatable, Hashable {
    let localSequence: Int64
    let deviceID: String
    let wallTime: String

    init(localSequence: Int64, deviceID: String, wallTime: String) {
        self.localSequence = max(0, localSequence)
        self.deviceID = deviceID.isEmpty ? "local-device" : deviceID
        self.wallTime = wallTime
    }

    static func tick(
        sequence: Int64,
        occurredAt: String,
        deviceID: String = RuntimeLocalDeviceID.current
    ) -> RuntimeCausalClock {
        RuntimeCausalClock(
            localSequence: sequence,
            deviceID: deviceID,
            wallTime: occurredAt
        )
    }
}

enum RuntimeLocalDeviceID {
    static var current: String {
        let raw = ProcessInfo.processInfo.hostName
        let normalized = raw
            .lowercased()
            .unicodeScalars
            .map { CharacterSet.alphanumerics.contains($0) ? Character($0) : "-" }
        let collapsed = String(normalized)
            .split(separator: "-", omittingEmptySubsequences: true)
            .joined(separator: "-")
        return collapsed.isEmpty ? "local-device" : collapsed
    }
}
