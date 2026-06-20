import Foundation

enum GoalFreshnessPosture: String, Codable, Sendable, Equatable, Hashable {
    case currentEnough = "current_enough"
    case aging
    case stale
    case expired
    case unknownFreshness = "unknown_freshness"
    case blockedMissingEvidence = "blocked_missing_evidence"
    case providerUnavailable = "provider_unavailable"
}

enum GoalUpdateNeededSeverity: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case monitor
    case recommended
    case required
    case blocked

    var rank: Int {
        switch self {
        case .none: return 0
        case .monitor: return 1
        case .recommended: return 2
        case .required: return 3
        case .blocked: return 4
        }
    }

    func isMoreSevere(than other: GoalUpdateNeededSeverity) -> Bool {
        rank > other.rank
    }
}

extension Array where Element == GoalUpdateNeededSeverity {
    func sortedBySeverityDescending() -> [GoalUpdateNeededSeverity] {
        sorted { lhs, rhs in
            if lhs.rank != rhs.rank {
                return lhs.rank > rhs.rank
            }
            return lhs.rawValue < rhs.rawValue
        }
    }
}

enum GoalUpdateNeededFlag: String, Codable, Sendable, Equatable, Hashable {
    case sourceAging = "source_aging"
    case sourceStale = "source_stale"
    case sourceExpired = "source_expired"
    case unknownFreshness = "unknown_freshness"
    case missingFreshnessEvidence = "missing_freshness_evidence"
    case providerUnavailable = "provider_unavailable"
    case noConcreteResource = "no_concrete_resource"
    case pathCandidateAffected = "path_candidate_affected"
}

struct GoalFreshnessLineageRef: Codable, Sendable, Equatable, Hashable {
    let providerID: String?
    let sourceRecordID: String?
    let claimID: String?
    let resourceID: String?
    let candidateID: String?
    let stageID: String?
    let reason: GoalUpdateNeededFlag
}

struct GoalResourceFreshnessImpact: Codable, Sendable, Equatable, Hashable {
    let resourceID: String
    let posture: GoalFreshnessPosture
    let updateNeeded: Bool
    let severity: GoalUpdateNeededSeverity
    let flags: [GoalUpdateNeededFlag]
    let lineage: [GoalFreshnessLineageRef]
    let rankingImpactScore: Double
    let rankingFlagsAdded: [GoalResourceRankingFlag]
}

struct GoalPathCandidateFreshnessSummary: Codable, Sendable, Equatable, Hashable {
    let candidateID: String
    let affectedResourceIDs: [String]
    let posture: GoalFreshnessPosture
    let updateNeeded: Bool
    let severity: GoalUpdateNeededSeverity
}

struct GoalResourceGraphFreshnessMetadata: Codable, Sendable, Equatable, Hashable {
    let evaluatedAt: String?
    let overallPosture: GoalFreshnessPosture
    let updateNeeded: Bool
    let maxSeverity: GoalUpdateNeededSeverity
    let resourceImpacts: [GoalResourceFreshnessImpact]
    let candidateSummaries: [GoalPathCandidateFreshnessSummary]
    let lineage: [GoalFreshnessLineageRef]

    static func unevaluated(evaluatedAt: String? = nil) -> GoalResourceGraphFreshnessMetadata {
        GoalResourceGraphFreshnessMetadata(
            evaluatedAt: evaluatedAt,
            overallPosture: .unknownFreshness,
            updateNeeded: false,
            maxSeverity: .none,
            resourceImpacts: [],
            candidateSummaries: [],
            lineage: []
        )
    }
}
