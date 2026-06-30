import Foundation

struct SourceAtlasClaim: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let text: String
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let sourceIDs: [String]
    let reviewRequired: Bool

    init(
        id: String,
        text: String,
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        sourceIDs: [String] = [],
        reviewRequired: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.reviewRequired = reviewRequired
    }

    var canDriveCurrentRecommendation: Bool {
        canDriveCurrentRecommendation(
            using: .conservativeFreshness,
            riskPolicy: .conservative
        )
    }

    func canDriveCurrentRecommendation(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        state == .official &&
            sourceIDs.isEmpty == false &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass)
    }

    var hasProvenanceEvidence: Bool {
        sourceIDs.isEmpty == false
    }

    func canTransition(
        to target: SourceAtlasClaimState,
        hasProvenanceEvidence: Bool? = nil,
        hasLocalProofEvidence: Bool = false
    ) -> Bool {
        state.canTransition(
            to: target,
            hasProvenanceEvidence: hasProvenanceEvidence ?? self.hasProvenanceEvidence,
            hasLocalProofEvidence: hasLocalProofEvidence
        )
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct SourceAtlasRequirement: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claimID: String
    let title: String
    let kind: SourceAtlasRequirementKind
    let required: Bool
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState

    init(
        id: String,
        claimID: String,
        title: String,
        kind: SourceAtlasRequirementKind,
        required: Bool,
        sourceState: SourceAtlasRequirementSourceState = .unknown,
        freshnessState: SourceAtlasRequirementFreshnessState = .unknown,
        riskState: SourceAtlasRequirementRiskState = .unknown,
        reviewState: SourceAtlasRequirementReviewState = .required
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.claimID = claimID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.required = required
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.riskState = riskState
        self.reviewState = reviewState
    }
}

enum SourceAtlasRequirementKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case hard
    case soft
    case prerequisite
    case equipment
    case skill
    case proof
    case deadline
    case blocker
    case accelerator
    case reviewRequired = "review-required"
}

enum SourceAtlasRequirementSourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case unknown
    case sourceNeeded = "source-needed"
    case stale
    case contradicted
    case revoked
    case locallyProven = "locally-proven"
    case official
    case officialCurrent = "official_current"
    case current
}

enum SourceAtlasRequirementFreshnessState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case stale
    case unknown
}

enum SourceAtlasRequirementRiskState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case medium
    case high
    case unknown
}

enum SourceAtlasRequirementReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case requested
    case required
    case approved
    case blocked
}

extension SourceAtlasRequirementSourceState {
    var blocksCurrentProjection: Bool {
        switch self {
        case .unknown, .sourceNeeded, .stale, .contradicted, .revoked:
            return true
        default:
            return false
        }
    }

    var hasExplicitProvenanceSignal: Bool {
        switch self {
        case .official, .officialCurrent, .current, .locallyProven:
            return true
        default:
            return false
        }
    }
}

extension SourceAtlasRequirementFreshnessState {
    var blocksCurrentProjection: Bool {
        self == .stale || self == .unknown
    }
}

extension SourceAtlasRequirementRiskState {
    var blocksCurrentProjection: Bool {
        self == .high || self == .unknown
    }
}

extension SourceAtlasRequirementReviewState {
    var blocksCurrentProjection: Bool {
        self == .required || self == .blocked || self == .requested
    }
}

extension SourceAtlasRequirement {
    var canDriveCurrentRecommendation: Bool {
        (sourceState == .officialCurrent || sourceState == .current)
            && freshnessState == .current
            && reviewState == .approved
            && riskState != .high
            && riskState != .unknown
    }
}

struct SourceAtlasStarterItem: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let stepCandidateSeed: String
    let storesFinalSchedule: Bool
}

enum SourceAtlasProofCandidate: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceEvidence = "source_evidence"
    case localObservation = "local_observation"
    case userProvided = "user_provided"
    case correctionArtifact = "correction_artifact"
    case revocationArtifact = "revocation_artifact"
    case unknown
}

enum SourceAtlasProofStrength: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case moderate
    case high
    case officialCertified = "official_certified"
    case localOnly = "local_only"
}

struct SourceAtlasProofMapEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let proofCandidate: SourceAtlasProofCandidate
    let proofStrength: SourceAtlasProofStrength
    let id: String
    let requirementID: String
    let capabilityNodeID: String?
    let sourceRecordIDs: [String]
    let sourceClaimIDs: [String]
    let proofDescription: String
    let correctionHookIDs: [String]
    let revocationHookIDs: [String]
    let privacyClass: HumanProgressPrivacyClass
    let evidenceLedgerBridgeIDs: [String]

    init(
        id: String,
        requirementID: String,
        proofDescription: String,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        proofCandidate: SourceAtlasProofCandidate = .sourceEvidence,
        proofStrength: SourceAtlasProofStrength = .moderate,
        capabilityNodeID: String? = nil,
        sourceRecordIDs: [String] = [],
        sourceClaimIDs: [String] = [],
        correctionHookIDs: [String] = [],
        revocationHookIDs: [String] = [],
        evidenceLedgerBridgeIDs: [String] = []
    ) {
        self.proofCandidate = proofCandidate
        self.proofStrength = proofStrength
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requirementID = requirementID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityNodeID = capabilityNodeID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.proofDescription = proofDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        self.correctionHookIDs = Self.orderedUnique(correctionHookIDs)
        self.revocationHookIDs = Self.orderedUnique(revocationHookIDs)
        self.privacyClass = privacyClass
        self.evidenceLedgerBridgeIDs = Self.orderedUnique(evidenceLedgerBridgeIDs)
    }

    var isSourceBound: Bool {
        sourceRecordIDs.isEmpty == false
    }

    var isClaimBound: Bool {
        sourceClaimIDs.isEmpty == false
    }

    var isLocalProofOnly: Bool {
        proofCandidate == .localObservation && proofStrength == .localOnly
    }

    var isSourceProofEligible: Bool {
        isSourceBound && isClaimBound
    }

    var isExternalProjectionSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    var canCertifySourceTruth: Bool {
        proofCandidate == .sourceEvidence &&
            proofStrength == .officialCertified &&
            isSourceProofEligible
    }

    func canSupportCurrentRequirement(_ claimsByID: [String: SourceAtlasClaim]) -> Bool {
        let boundClaims = sourceClaimIDs.compactMap { claimsByID[$0] }
        guard boundClaims.isEmpty == false else {
            return false
        }
        guard boundClaims.count == sourceClaimIDs.count else {
            return false
        }
        if boundClaims.contains(where: { $0.canDriveCurrentRecommendation == false }) {
            return false
        }
        if boundClaims.contains(where: \.state.isBlockingState) {
            return false
        }
        if boundClaims.contains(where: { $0.freshness == .stale || $0.freshness == .staleCritical }) {
            return false
        }
        if isLocalProofOnly {
            return false
        }
        return isSourceProofEligible && (proofStrength == .officialCertified || proofStrength == .high || proofStrength == .moderate)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

enum SourceAtlasCapabilityEdgeKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case prerequisite
    case unlocks
    case reinforces
    case blocks
}
