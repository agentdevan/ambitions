import Foundation

let humanProgressGraphSchemaVersion = "human_progress_graph.native.v1"
let lifeGraphEventLogSchemaVersion = "life_graph_event_log.native.v1"

enum HumanProgressGraphNodeFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case lifeThread = "life_thread"
    case commitment
    case openLoop = "open_loop"
    case goalPath = "goal_path"
    case requirement
    case proof
    case sourceClaim = "source_claim"
    case timeCapacity = "time_capacity"
    case pivot
    case identityDirection = "identity_direction"
    case privacyPermission = "privacy_permission"
    case receipt
}

enum HumanProgressGraphEdgeFamily: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case supports
    case proves
    case dependsOn = "depends_on"
    case conflictsWith = "conflicts_with"
    case supersedes
    case transfersTo = "transfers_to"
    case blockedBy = "blocked_by"
    case sourcedFrom = "sourced_from"
    case verifiedBy = "verified_by"
    case hiddenFrom = "hidden_from"
    case scheduledWithin = "scheduled_within"
    case stillCountsToward = "still_counts_toward"
}

enum HumanProgressPrivacyClass: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case privateLife = "private"
    case sensitive
    case externalRedacted = "external_redacted"
    case shareableByUser = "shareable_by_user"
    case deletePending = "delete_pending"
}

enum HumanProgressSourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case userStated = "user_stated"
    case userConfirmed = "user_confirmed"
    case sourceBacked = "source_backed"
    case sourceNeeded = "source_needed"
    case inferredReviewRequired = "inferred_review_required"
    case importedReviewRequired = "imported_review_required"
    case unsupported
    case disputed
    case revoked
    case unknown

    var canDriveSourceSensitiveRecommendation: Bool {
        switch self {
        case .userConfirmed, .sourceBacked:
            return true
        case .userStated, .sourceNeeded, .inferredReviewRequired,
             .importedReviewRequired, .unsupported, .disputed, .revoked, .unknown:
            return false
        }
    }
}

enum HumanProgressFreshnessState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case current
    case reviewSoon = "review_soon"
    case stale
    case staleCritical = "stale_critical"
    case sourceChanged = "source_changed"
    case notApplicable = "not_applicable"
    case unknown

    var blocksHighRiskUse: Bool {
        self == .staleCritical || self == .sourceChanged || self == .unknown
    }
}

enum HumanProgressReviewState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case ready
    case needsUserReview = "needs_user_review"
    case needsSourceReview = "needs_source_review"
    case needsPrivacyReview = "needs_privacy_review"
    case needsCorrection = "needs_correction"
    case hiddenByUser = "hidden_by_user"
    case rejectedByUser = "rejected_by_user"
    case deletedByUser = "deleted_by_user"

    var blocksAutomaticMutation: Bool {
        self != .ready
    }
}

struct HumanProgressGraphNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: HumanProgressGraphNodeFamily
    let title: String
    let privacyClass: HumanProgressPrivacyClass
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let createdAt: String
    let updatedAt: String
    let receiptIDs: [String]
    let sourceReferenceIDs: [String]
    let schemaVersion: String

    init(
        id: String,
        family: HumanProgressGraphNodeFamily,
        title: String,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .needsUserReview,
        createdAt: String,
        updatedAt: String? = nil,
        receiptIDs: [String] = [],
        sourceReferenceIDs: [String] = [],
        schemaVersion: String = humanProgressGraphSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.family = family
        self.title = Self.normalizedRequired(title)
        self.privacyClass = privacyClass
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.sourceReferenceIDs = Self.orderedUnique(sourceReferenceIDs)
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false && title.isEmpty == false
    }

    var canDriveSourceSensitiveRecommendation: Bool {
        sourceState.canDriveSourceSensitiveRecommendation &&
            freshnessState.blocksHighRiskUse == false &&
            reviewState == .ready
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map(normalizedRequired).filter { $0.isEmpty == false })).sorted()
    }
}

struct HumanProgressGraphEdge: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let family: HumanProgressGraphEdgeFamily
    let sourceNodeID: String
    let targetNodeID: String
    let privacyClass: HumanProgressPrivacyClass
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let createdAt: String
    let updatedAt: String
    let receiptIDs: [String]
    let sourceReferenceIDs: [String]
    let schemaVersion: String

    init(
        family: HumanProgressGraphEdgeFamily,
        sourceNodeID: String,
        targetNodeID: String,
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .needsUserReview,
        createdAt: String,
        updatedAt: String? = nil,
        receiptIDs: [String] = [],
        sourceReferenceIDs: [String] = [],
        id: String? = nil,
        schemaVersion: String = humanProgressGraphSchemaVersion
    ) {
        self.family = family
        self.sourceNodeID = Self.normalizedRequired(sourceNodeID)
        self.targetNodeID = Self.normalizedRequired(targetNodeID)
        self.privacyClass = privacyClass
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.sourceReferenceIDs = Self.orderedUnique(sourceReferenceIDs)
        self.schemaVersion = schemaVersion
        self.id = id ?? Self.deterministicID(
            family: family,
            sourceNodeID: self.sourceNodeID,
            targetNodeID: self.targetNodeID
        )
    }

    var isWellFormed: Bool {
        sourceNodeID.isEmpty == false &&
            targetNodeID.isEmpty == false &&
            sourceNodeID != targetNodeID
    }

    var blocksAutomaticMutation: Bool {
        reviewState.blocksAutomaticMutation ||
            sourceState.canDriveSourceSensitiveRecommendation == false ||
            freshnessState.blocksHighRiskUse
    }

    private static func deterministicID(
        family: HumanProgressGraphEdgeFamily,
        sourceNodeID: String,
        targetNodeID: String
    ) -> String {
        "hpg:\(sourceNodeID):\(family.rawValue):\(targetNodeID)"
            .lowercased()
            .replacingOccurrences(of: #"[^a-z0-9:_-]+"#, with: "-", options: .regularExpression)
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map(normalizedRequired).filter { $0.isEmpty == false })).sorted()
    }
}

enum LifeGraphEventLogKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case graphDeltaProposed = "graph_delta_proposed"
    case nodeUpsertRequested = "node_upsert_requested"
    case edgeUpsertRequested = "edge_upsert_requested"
    case reviewRequested = "review_requested"
    case sourceReviewNeeded = "source_review_needed"
    case privacyReviewNeeded = "privacy_review_needed"
    case receiptLinked = "receipt_linked"
    case mutationRejected = "mutation_rejected"
}

enum LifeGraphEventLogActor: String, Codable, Sendable, Equatable, Hashable {
    case user
    case system
    case kernelProposal = "kernel_proposal"
}

enum LifeGraphEventLogScope: String, Codable, Sendable, Equatable, Hashable {
    case goals
    case plan
    case you
    case runtimeContract = "runtime_contract"
}

struct LifeGraphEventLogEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: LifeGraphEventLogKind
    let occurredAt: String
    let actor: LifeGraphEventLogActor
    let scope: LifeGraphEventLogScope
    let affectedNodeIDs: [String]
    let affectedEdgeIDs: [String]
    let receiptIDs: [String]
    let privacyClass: HumanProgressPrivacyClass
    let sourceState: HumanProgressSourceState
    let freshnessState: HumanProgressFreshnessState
    let reviewState: HumanProgressReviewState
    let summary: String
    let localOnly: Bool
    let schemaVersion: String

    init(
        id: String,
        kind: LifeGraphEventLogKind,
        occurredAt: String,
        actor: LifeGraphEventLogActor,
        scope: LifeGraphEventLogScope,
        affectedNodeIDs: [String] = [],
        affectedEdgeIDs: [String] = [],
        receiptIDs: [String] = [],
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        sourceState: HumanProgressSourceState = .userStated,
        freshnessState: HumanProgressFreshnessState = .notApplicable,
        reviewState: HumanProgressReviewState = .needsUserReview,
        summary: String,
        localOnly: Bool = true,
        schemaVersion: String = lifeGraphEventLogSchemaVersion
    ) {
        self.id = Self.normalizedRequired(id)
        self.kind = kind
        self.occurredAt = occurredAt
        self.actor = actor
        self.scope = scope
        self.affectedNodeIDs = Self.orderedUnique(affectedNodeIDs)
        self.affectedEdgeIDs = Self.orderedUnique(affectedEdgeIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.privacyClass = privacyClass
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.summary = Self.normalizedRequired(summary)
        self.localOnly = localOnly
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false && summary.isEmpty == false
    }

    var requiresReviewBeforeMutation: Bool {
        actor == .kernelProposal ||
            reviewState.blocksAutomaticMutation ||
            sourceState.canDriveSourceSensitiveRecommendation == false ||
            freshnessState.blocksHighRiskUse ||
            privacyClass == .sensitive ||
            privacyClass == .deletePending
    }

    var isProposalOnly: Bool {
        kind == .graphDeltaProposed || requiresReviewBeforeMutation
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map(normalizedRequired).filter { $0.isEmpty == false })).sorted()
    }
}

struct HumanProgressGraphDelta: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let proposedAt: String
    let nodesToUpsert: [HumanProgressGraphNode]
    let edgesToUpsert: [HumanProgressGraphEdge]
    let event: LifeGraphEventLogEntry
    let rollbackHint: String

    init(
        id: String,
        proposedAt: String,
        nodesToUpsert: [HumanProgressGraphNode] = [],
        edgesToUpsert: [HumanProgressGraphEdge] = [],
        event: LifeGraphEventLogEntry,
        rollbackHint: String
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.proposedAt = proposedAt
        self.nodesToUpsert = Self.orderedUnique(nodesToUpsert)
        self.edgesToUpsert = Self.orderedUnique(edgesToUpsert)
        self.event = event
        self.rollbackHint = rollbackHint.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            event.isWellFormed &&
            rollbackHint.isEmpty == false &&
            nodesToUpsert.allSatisfy(\.isWellFormed) &&
            edgesToUpsert.allSatisfy(\.isWellFormed)
    }

    var requiresReviewBeforeMutation: Bool {
        event.requiresReviewBeforeMutation ||
            nodesToUpsert.contains { $0.reviewState.blocksAutomaticMutation } ||
            edgesToUpsert.contains { $0.blocksAutomaticMutation }
    }

    private static func orderedUnique(_ nodes: [HumanProgressGraphNode]) -> [HumanProgressGraphNode] {
        var seen = Set<String>()
        return nodes
            .filter { seen.insert($0.id).inserted }
            .sorted { $0.id < $1.id }
    }

    private static func orderedUnique(_ edges: [HumanProgressGraphEdge]) -> [HumanProgressGraphEdge] {
        var seen = Set<String>()
        return edges
            .filter { $0.isWellFormed }
            .filter { seen.insert($0.id).inserted }
            .sorted { $0.id < $1.id }
    }
}
