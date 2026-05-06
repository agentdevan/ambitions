import Foundation

let lifeGraphDeltaReviewSchemaVersion = "life_graph_delta_review.native.v1"

enum LifeGraphDeltaReviewSurface: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case today
    case goals
    case capture
    case plan
    case you
    case runtimeContract = "runtime_contract"
}

enum LifeGraphDeltaReviewDecision: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pending
    case approvedForProjection = "approved_for_projection"
    case rejected
    case needsCorrection = "needs_correction"
    case needsSourceReview = "needs_source_review"
    case needsPrivacyReview = "needs_privacy_review"

    var allowsProjection: Bool {
        self == .approvedForProjection
    }
}

enum LifeGraphDeltaReviewRisk: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceNeeded = "source_needed"
    case staleSource = "stale_source"
    case privacySensitive = "privacy_sensitive"
    case deletePending = "delete_pending"
    case userReviewRequired = "user_review_required"
    case malformedDelta = "malformed_delta"
}

struct LifeGraphDeltaReviewRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let delta: HumanProgressGraphDelta
    let requestedAt: String
    let surface: LifeGraphDeltaReviewSurface
    let decision: LifeGraphDeltaReviewDecision
    let decidedAt: String?
    let reviewerNote: String?
    let correctionIDs: [String]
    let receiptIDs: [String]
    let risks: [LifeGraphDeltaReviewRisk]
    let schemaVersion: String

    init(
        id: String,
        delta: HumanProgressGraphDelta,
        requestedAt: String,
        surface: LifeGraphDeltaReviewSurface,
        decision: LifeGraphDeltaReviewDecision = .pending,
        decidedAt: String? = nil,
        reviewerNote: String? = nil,
        correctionIDs: [String] = [],
        receiptIDs: [String] = [],
        risks: [LifeGraphDeltaReviewRisk]? = nil,
        schemaVersion: String = lifeGraphDeltaReviewSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.delta = delta
        self.requestedAt = requestedAt
        self.surface = surface
        self.decision = decision
        self.decidedAt = decidedAt
        self.reviewerNote = Self.normalizedOptional(reviewerNote)
        self.correctionIDs = Self.orderedUnique(correctionIDs)
        self.receiptIDs = Self.orderedUnique(receiptIDs)
        self.risks = risks ?? Self.inferredRisks(delta: delta)
        self.schemaVersion = schemaVersion
    }

    var isWellFormed: Bool {
        id.isEmpty == false && delta.isWellFormed
    }

    var canProject: Bool {
        isWellFormed &&
            decision.allowsProjection &&
            risks.isEmpty &&
            receiptIDs.isEmpty == false
    }

    var requiresHumanReview: Bool {
        decision == .pending ||
            decision == .needsCorrection ||
            decision == .needsSourceReview ||
            decision == .needsPrivacyReview ||
            risks.isEmpty == false
    }

    private static func inferredRisks(delta: HumanProgressGraphDelta) -> [LifeGraphDeltaReviewRisk] {
        var risks: Set<LifeGraphDeltaReviewRisk> = []
        if delta.isWellFormed == false {
            risks.insert(.malformedDelta)
        }
        if delta.requiresReviewBeforeMutation {
            risks.insert(.userReviewRequired)
        }
        for node in delta.nodesToUpsert {
            if node.sourceState.canDriveSourceSensitiveRecommendation == false {
                risks.insert(.sourceNeeded)
            }
            if node.freshnessState.blocksHighRiskUse {
                risks.insert(.staleSource)
            }
            if node.privacyClass == .sensitive {
                risks.insert(.privacySensitive)
            }
            if node.privacyClass == .deletePending || node.reviewState == .deletedByUser {
                risks.insert(.deletePending)
            }
        }
        for edge in delta.edgesToUpsert {
            if edge.sourceState.canDriveSourceSensitiveRecommendation == false {
                risks.insert(.sourceNeeded)
            }
            if edge.freshnessState.blocksHighRiskUse {
                risks.insert(.staleSource)
            }
            if edge.privacyClass == .sensitive {
                risks.insert(.privacySensitive)
            }
            if edge.privacyClass == .deletePending {
                risks.insert(.deletePending)
            }
        }
        return risks.sorted { $0.rawValue < $1.rawValue }
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct LifeGraphProjectionSnapshot: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let surface: LifeGraphDeltaReviewSurface
    let generatedAt: String
    let projectedNodeIDs: [String]
    let projectedEdgeIDs: [String]
    let reviewRecordIDs: [String]
    let privacyClass: HumanProgressPrivacyClass
    let schemaVersion: String

    init(
        id: String,
        surface: LifeGraphDeltaReviewSurface,
        generatedAt: String,
        projectedNodeIDs: [String],
        projectedEdgeIDs: [String],
        reviewRecordIDs: [String],
        privacyClass: HumanProgressPrivacyClass = .privateLife,
        schemaVersion: String = lifeGraphDeltaReviewSchemaVersion
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.surface = surface
        self.generatedAt = generatedAt
        self.projectedNodeIDs = Self.orderedUnique(projectedNodeIDs)
        self.projectedEdgeIDs = Self.orderedUnique(projectedEdgeIDs)
        self.reviewRecordIDs = Self.orderedUnique(reviewRecordIDs)
        self.privacyClass = privacyClass
        self.schemaVersion = schemaVersion
    }

    var isExternalSafe: Bool {
        privacyClass == .externalRedacted || privacyClass == .shareableByUser
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct LifeGraphDeltaReviewProjectionStore: Codable, Sendable, Equatable, Hashable {
    let records: [LifeGraphDeltaReviewRecord]

    init(records: [LifeGraphDeltaReviewRecord] = []) {
        self.records = Self.orderedUnique(records)
    }

    func pendingRecords(for surface: LifeGraphDeltaReviewSurface? = nil) -> [LifeGraphDeltaReviewRecord] {
        records.filter { record in
            (surface == nil || record.surface == surface) &&
                record.requiresHumanReview
        }
    }

    func projectableRecords(for surface: LifeGraphDeltaReviewSurface) -> [LifeGraphDeltaReviewRecord] {
        records.filter { $0.surface == surface && $0.canProject }
    }

    func projectionSnapshot(
        for surface: LifeGraphDeltaReviewSurface,
        generatedAt: String,
        id: String
    ) -> LifeGraphProjectionSnapshot {
        let projectable = projectableRecords(for: surface)
        return LifeGraphProjectionSnapshot(
            id: id,
            surface: surface,
            generatedAt: generatedAt,
            projectedNodeIDs: projectable.flatMap { $0.delta.nodesToUpsert.map(\.id) },
            projectedEdgeIDs: projectable.flatMap { $0.delta.edgesToUpsert.map(\.id) },
            reviewRecordIDs: projectable.map(\.id),
            privacyClass: .privateLife
        )
    }

    private static func orderedUnique(_ records: [LifeGraphDeltaReviewRecord]) -> [LifeGraphDeltaReviewRecord] {
        var seen = Set<String>()
        return records
            .filter { $0.isWellFormed }
            .filter { seen.insert($0.id).inserted }
            .sorted { lhs, rhs in
                if lhs.requestedAt != rhs.requestedAt {
                    return lhs.requestedAt < rhs.requestedAt
                }
                return lhs.id < rhs.id
            }
    }
}
