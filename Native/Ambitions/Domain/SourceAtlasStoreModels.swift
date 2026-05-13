import CryptoKit
import Foundation

enum SourceAtlasStorePayloadSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case bundled
    case cached
    case lastKnownGood = "last_known_good"
}

enum SourceAtlasStoreSourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unknown
    case sourceNeeded = "source_needed"
    case stale
    case contradicted
    case revoked
    case locallyProven = "locally_proven"
    case official
    case officialCurrent = "official_current"
    case current
}

enum SourceAtlasStoreQuarantineReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingPayload = "missing_payload"
    case corruptJSON = "corrupt_json"
    case unsupportedSchema = "unsupported_schema"
    case hashMismatch = "hash_mismatch"
    case invalidPack = "invalid_pack"
    case contradicted
    case revoked
}

enum SourceAtlasOfflineFallbackCondition: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noInternet = "no_internet"
    case unreachableManifest = "unreachable_manifest"
    case failedDownload = "failed_download"
    case staleCache = "stale_cache"
    case missingPack = "missing_pack"
    case corruptInvalidPack = "corrupt_invalid_pack"
}

struct SourceAtlasOfflineFallbackAvailability: Codable, Sendable, Equatable, Hashable {
    let internetAvailable: Bool
    let manifestReachable: Bool
    let downloadSucceeded: Bool

    init(
        internetAvailable: Bool = true,
        manifestReachable: Bool = true,
        downloadSucceeded: Bool = true
    ) {
        self.internetAvailable = internetAvailable
        self.manifestReachable = manifestReachable
        self.downloadSucceeded = downloadSucceeded
    }
}

struct SourceAtlasStorePayload: Sendable, Equatable, Hashable {
    let source: SourceAtlasStorePayloadSource
    let data: Data
    let declaredSHA256: String

    init(
        source: SourceAtlasStorePayloadSource,
        data: Data,
        declaredSHA256: String
    ) {
        self.source = source
        self.data = data
        self.declaredSHA256 = declaredSHA256.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

struct SourceAtlasStoreQuarantine: Codable, Sendable, Equatable, Hashable {
    let source: SourceAtlasStorePayloadSource
    let reason: SourceAtlasStoreQuarantineReason
    let validationIssues: [SourceAtlasValidationIssue]

    init(
        source: SourceAtlasStorePayloadSource,
        reason: SourceAtlasStoreQuarantineReason,
        validationIssues: [SourceAtlasValidationIssue] = []
    ) {
        self.source = source
        self.reason = reason
        self.validationIssues = validationIssues
    }
}

struct SourceAtlasStoreLoadResult: Sendable, Equatable, Hashable {
    let pack: SourceAtlasPack?
    let selectedSource: SourceAtlasStorePayloadSource?
    let sourceState: SourceAtlasStoreSourceState
    let quarantines: [SourceAtlasStoreQuarantine]

    var hasPack: Bool {
        pack != nil
    }
}

struct SourceAtlasStore {
    private let decoder: JSONDecoder
    private let validator: SourceAtlasPackValidator

    init(
        decoder: JSONDecoder = JSONDecoder(),
        validator: SourceAtlasPackValidator = SourceAtlasPackValidator()
    ) {
        self.decoder = decoder
        self.validator = validator
    }

    func load(
        bundled: SourceAtlasStorePayload?,
        cached: SourceAtlasStorePayload?,
        lastKnownGood: SourceAtlasStorePayload?
    ) -> SourceAtlasStoreLoadResult {
        var quarantines: [SourceAtlasStoreQuarantine] = []

        for payload in [cached, bundled].compactMap({ $0 }) {
            switch evaluate(payload) {
            case .accepted(let pack, let state):
                return SourceAtlasStoreLoadResult(
                    pack: pack,
                    selectedSource: payload.source,
                    sourceState: state,
                    quarantines: quarantines
                )
            case .quarantined(let quarantine):
                quarantines.append(quarantine)
            }
        }

        if cached == nil && bundled == nil {
            quarantines.append(SourceAtlasStoreQuarantine(source: .cached, reason: .missingPayload))
            quarantines.append(SourceAtlasStoreQuarantine(source: .bundled, reason: .missingPayload))
        }

        if let lastKnownGood {
            switch evaluate(lastKnownGood) {
            case .accepted(let pack, _):
                return SourceAtlasStoreLoadResult(
                    pack: pack,
                    selectedSource: .lastKnownGood,
                    sourceState: .stale,
                    quarantines: quarantines
                )
            case .quarantined(let quarantine):
                quarantines.append(quarantine)
            }
        }

        return SourceAtlasStoreLoadResult(
            pack: nil,
            selectedSource: nil,
            sourceState: .sourceNeeded,
            quarantines: quarantines
        )
    }

    static func sha256Hex(for data: Data) -> String {
        SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }

    private func evaluate(_ payload: SourceAtlasStorePayload) -> Evaluation {
        guard payload.declaredSHA256 == Self.sha256Hex(for: payload.data) else {
            return .quarantined(SourceAtlasStoreQuarantine(source: payload.source, reason: .hashMismatch))
        }

        let pack: SourceAtlasPack
        do {
            pack = try decoder.decode(SourceAtlasPack.self, from: payload.data)
        } catch {
            return .quarantined(SourceAtlasStoreQuarantine(source: payload.source, reason: .corruptJSON))
        }

        if pack.manifest.schemaVersion != sourceAtlasPackSchemaVersion {
            return .quarantined(SourceAtlasStoreQuarantine(source: payload.source, reason: .unsupportedSchema))
        }

        let blockingState = Self.blockingState(in: pack)
        if blockingState == .revoked {
            return .quarantined(SourceAtlasStoreQuarantine(source: payload.source, reason: .revoked))
        }
        if blockingState == .contradicted {
            return .quarantined(SourceAtlasStoreQuarantine(source: payload.source, reason: .contradicted))
        }

        let issues = validator.validate(pack)
        guard issues.isEmpty else {
            return .quarantined(
                SourceAtlasStoreQuarantine(
                    source: payload.source,
                    reason: .invalidPack,
                    validationIssues: issues
                )
            )
        }

        return .accepted(pack, state: Self.sourceState(for: pack))
    }

    private static func blockingState(in pack: SourceAtlasPack) -> SourceAtlasStoreSourceState? {
        let requirementStates = pack.requirements.map(\.sourceState)
        if pack.claims.contains(where: { $0.state == .revoked || $0.freshness == .revoked }) ||
            requirementStates.contains(.revoked) {
            return .revoked
        }
        if pack.claims.contains(where: { $0.state == .contradicted || $0.freshness == .disputed }) ||
            requirementStates.contains(.contradicted) {
            return .contradicted
        }
        return nil
    }

    private static func sourceState(for pack: SourceAtlasPack) -> SourceAtlasStoreSourceState {
        let states = pack.requirements.map(\.sourceState)
        if states.contains(.officialCurrent) {
            return .officialCurrent
        }
        if states.contains(.official) {
            return .official
        }
        if states.contains(.current) {
            return .current
        }
        if states.contains(.locallyProven) {
            return .locallyProven
        }
        if states.contains(.stale) {
            return .stale
        }
        if states.contains(.sourceNeeded) {
            return .sourceNeeded
        }
        return .unknown
    }
}

extension SourceAtlasStoreSourceState {
    init(requirementSourceState: SourceAtlasRequirementSourceState) {
        switch requirementSourceState {
        case .unknown:
            self = .unknown
        case .sourceNeeded:
            self = .sourceNeeded
        case .stale:
            self = .stale
        case .contradicted:
            self = .contradicted
        case .revoked:
            self = .revoked
        case .locallyProven:
            self = .locallyProven
        case .official:
            self = .official
        case .officialCurrent:
            self = .officialCurrent
        case .current:
            self = .current
        }
    }
}

private enum Evaluation: Equatable {
    case accepted(SourceAtlasPack, state: SourceAtlasStoreSourceState)
    case quarantined(SourceAtlasStoreQuarantine)
}
