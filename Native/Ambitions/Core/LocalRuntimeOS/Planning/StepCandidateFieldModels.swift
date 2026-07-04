import Foundation

let stepCandidateFieldSchemaVersion = "step_candidate_field.native.v1"

enum CandidateSource: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalIntentCompiler = "goal_intent_compiler"
    case privateLifeRuntime = "private_life_runtime"
    case replayTrace = "replay_trace"
    case personalizationFactorLedger = "personalization_factor_ledger"
    case sourceAtlasPathComposition = "source_atlas_path_composition"
    case sourceAtlasPack = "source_atlas_pack"
    case sourceAtlasStepCandidateSeed = "source_atlas_step_candidate_seed"
    case fallback
}

enum CandidateValidity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case preferred
    case review
    case fallback
    case blocked
    case rejected

    var sortWeight: Int {
        switch self {
        case .preferred:
            return 4
        case .review:
            return 3
        case .fallback:
            return 2
        case .blocked:
            return 1
        case .rejected:
            return 0
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .preferred:
            return "Preferred"
        case .review:
            return "Needs review"
        case .fallback:
            return "Fallback"
        case .blocked:
            return "Blocked"
        case .rejected:
            return "Rejected"
        }
    }
}

enum CandidateRiskLevel: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case low
    case moderate
    case high

    var sortWeight: Int {
        switch self {
        case .low:
            return 2
        case .moderate:
            return 1
        case .high:
            return 0
        }
    }
}

enum StepCandidateRejectionReasonCode: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case tooLong = "too_long"
    case tooHard = "too_hard"
    case tooEasy = "too_easy"
    case tooMuchEnergy = "too_much_energy"
    case wrongLocation = "wrong_location"
    case noEquipment = "no_equipment"
    case noTransportation = "no_transportation"
    case notEnoughTime = "not_enough_time"
    case emotionallyNotReady = "emotionally_not_ready"
    case blockedBySomeoneElse = "blocked_by_someone_else"
    case alreadyDidSimilar = "already_did_similar"
    case notUseful = "not_useful"
    case unsafeInjuryConcern = "unsafe_injury_concern"
    case boringLowMotivation = "boring_low_motivation"
    case preferDifferentPath = "prefer_different_path"
    case custom

    var displayLabel: String {
        switch self {
        case .tooLong: return "Too long"
        case .tooHard: return "Too hard"
        case .tooEasy: return "Too easy"
        case .tooMuchEnergy: return "Too much energy"
        case .wrongLocation: return "Wrong location"
        case .noEquipment: return "No equipment"
        case .noTransportation: return "No transportation"
        case .notEnoughTime: return "Not enough time"
        case .emotionallyNotReady: return "Emotionally not ready"
        case .blockedBySomeoneElse: return "Blocked by someone else"
        case .alreadyDidSimilar: return "Already did something similar"
        case .notUseful: return "Not useful"
        case .unsafeInjuryConcern: return "Unsafe / injury concern"
        case .boringLowMotivation: return "Boring / low motivation"
        case .preferDifferentPath: return "Prefer a different path"
        case .custom: return "Custom reason"
        }
    }

    var redactedLabel: String {
        switch self {
        case .custom:
            return "Custom reason"
        default:
            return displayLabel
        }
    }

    var isSensitive: Bool {
        switch self {
        case .emotionallyNotReady, .unsafeInjuryConcern, .custom:
            return true
        default:
            return false
        }
    }

    var learningWeight: Double {
        switch self {
        case .tooLong, .tooHard, .tooMuchEnergy, .wrongLocation, .noEquipment, .noTransportation, .notEnoughTime, .emotionallyNotReady, .blockedBySomeoneElse, .unsafeInjuryConcern:
            return 1
        case .tooEasy, .alreadyDidSimilar, .notUseful, .boringLowMotivation, .preferDifferentPath:
            return 0.72
        case .custom:
            return 0.5
        }
    }
}

struct StepCandidateRejectionReason: Codable, Sendable, Equatable, Hashable {
    let code: StepCandidateRejectionReasonCode
    let customText: String?

    init(code: StepCandidateRejectionReasonCode, customText: String? = nil) {
        self.code = code
        self.customText = Self.normalizedOptional(customText)
    }

    var displayLabel: String {
        code.displayLabel
    }

    var redactedLabel: String {
        code.redactedLabel
    }

    var storageLabel: String {
        code.rawValue
    }

    var traceLabel: String {
        code == .custom ? "custom" : code.rawValue
    }

    var hasSensitiveText: Bool {
        code.isSensitive || customText != nil
    }

    var customTextForLearning: String? {
        code == .custom ? customText : nil
    }
}

struct StepCandidateRejectionRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let candidateID: String
    let sourceCandidateID: String?
    let sourceStepID: String
    let contextFingerprint: String
    let reason: StepCandidateRejectionReason
    let skippedReason: Bool
    let recordedAt: String

    init(
        candidateID: String,
        sourceCandidateID: String? = nil,
        sourceStepID: String,
        contextFingerprint: String,
        reason: StepCandidateRejectionReason,
        skippedReason: Bool,
        recordedAt: String
    ) {
        self.candidateID = Self.normalizedRequired(candidateID)
        self.sourceCandidateID = Self.normalizedOptional(sourceCandidateID)
        self.sourceStepID = Self.normalizedRequired(sourceStepID)
        self.contextFingerprint = Self.normalizedRequired(contextFingerprint)
        self.reason = reason
        self.skippedReason = skippedReason
        self.recordedAt = Self.normalizedRequired(recordedAt)
        self.id = Self.stableIdentifier(
            prefix: "step-candidate-rejection",
            components: [
                self.candidateID,
                self.contextFingerprint,
                self.reason.storageLabel,
                self.recordedAt
            ]
        )
    }

    var isLearningQualityLow: Bool {
        skippedReason || reason.code == .custom
    }

    var publicSummary: String {
        let qualityNote = skippedReason ? " (reason skipped)" : ""
        return "\(reason.redactedLabel)\(qualityNote)"
    }
}

struct SourceAtlasStepCandidateSeedTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourcePackID: String
    let sourcePathID: String
    let sourcePathOverlayIDs: [String]
    let sourceNodeIDs: [String]
    let sourceRequirementIDs: [String]
    let sourceProofRequirementIDs: [String]
    let sourceStarterItemIDs: [String]
    let seedKind: String
    let seedText: String
    let sourceRecordIDs: [String]
    let sourceClaimIDs: [String]
    let freshnessWarnings: [String]
    let sensitiveContextRedactions: [String]
}

struct SourceAtlasStepExpansionCandidateTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceSeedID: String
    let candidateID: String
    let sourcePackID: String
    let sourcePathID: String
    let sourcePathOverlayIDs: [String]
    let sourceNodeIDs: [String]
    let sourceRequirementIDs: [String]
    let sourceProofRequirementIDs: [String]
    let sourceStarterItemIDs: [String]
    let candidateKindRawValue: String
    let candidateSourceRawValue: String
    let title: String
    let summary: String
    let deadlineProtecting: Bool
    let sourceRecordIDs: [String]
    let sourceClaimIDs: [String]
}

struct SourceAtlasStepExpansionRejectedSeedTrace: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceSeedID: String
    let sourcePackID: String
    let sourcePathID: String
    let reason: String
    let sourceRecordIDs: [String]
    let sourceClaimIDs: [String]
}

struct SourceAtlasStepExpansionTrace: Codable, Sendable, Equatable, Hashable {
    let sourceStepCandidateSeeds: [SourceAtlasStepCandidateSeedTrace]
    let expandedCandidates: [SourceAtlasStepExpansionCandidateTrace]
    let rejectedSeeds: [SourceAtlasStepExpansionRejectedSeedTrace]
    let expansionRules: [String]
    let personalizationFactorsUsed: [String]
    let freshnessWarnings: [String]
    let sensitiveContextRedactions: [String]
}

enum StepCandidateKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case directBest = "direct_best"
    case lighter
    case shorter
    case lowerEnergy = "lower_energy"
    case locationCompatible = "location_compatible"
    case noEquipment = "no_equipment"
    case recoverySafe = "recovery_safe"
    case adminSetup = "admin_setup"
    case learningResearch = "learning_research"
    case proofGathering = "proof_gathering"
    case prerequisite
    case maintenance
    case catchUp = "catch_up"
    case substitution
    case parallelPath = "parallel_path"
    case fallback

    var semanticLabel: String {
        switch self {
        case .directBest:
            return "Direct best"
        case .lighter:
            return "Lighter"
        case .shorter:
            return "Shorter"
        case .lowerEnergy:
            return "Lower energy"
        case .locationCompatible:
            return "Location compatible"
        case .noEquipment:
            return "No equipment"
        case .recoverySafe:
            return "Recovery safe"
        case .adminSetup:
            return "Admin setup"
        case .learningResearch:
            return "Learning and research"
        case .proofGathering:
            return "Proof gathering"
        case .prerequisite:
            return "Prerequisite"
        case .maintenance:
            return "Maintenance"
        case .catchUp:
            return "Catch up"
        case .substitution:
            return "Substitution"
        case .parallelPath:
            return "Parallel path"
        case .fallback:
            return "Fallback"
        }
    }

    var defaultValidity: CandidateValidity {
        switch self {
        case .directBest, .lighter, .shorter, .lowerEnergy, .locationCompatible, .noEquipment, .recoverySafe, .adminSetup, .learningResearch, .proofGathering, .prerequisite, .maintenance, .catchUp, .substitution, .parallelPath:
            return .review
        case .fallback:
            return .fallback
        }
    }
}

struct CandidateTradeoff: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let label: String
    let benefit: String
    let cost: String
    let note: String?

    init(
        id: String,
        label: String,
        benefit: String,
        cost: String,
        note: String? = nil
    ) {
        self.id = Self.normalizedRequired(id)
        self.label = Self.normalizedRequired(label)
        self.benefit = Self.normalizedRequired(benefit)
        self.cost = Self.normalizedRequired(cost)
        self.note = Self.normalizedOptional(note)
    }
}
