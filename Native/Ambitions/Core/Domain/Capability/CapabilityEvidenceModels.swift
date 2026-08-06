import Foundation

enum CapabilityEvidenceSourceKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goal
    case milestone
    case step
    case reflection
    case proof
}

struct CapabilityEvidenceSourceReference: Codable, Sendable, Equatable, Hashable {
    let kind: CapabilityEvidenceSourceKind
    let stableID: String
    let revision: Int
    let fingerprint: String

    init(kind: CapabilityEvidenceSourceKind, stableID: String, revision: Int, fingerprint: String) {
        self.kind = kind
        self.stableID = stableID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.revision = max(1, revision)
        self.fingerprint = fingerprint.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

enum CapabilityEvidenceRelationKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case practiced
    case proofLinked = "proof_linked"
}

enum CapabilityEvidenceAvailability: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case available
    case archived
    case trashed
    case unavailable
    case redacted
    case permanentlyDeleted = "permanently_deleted"

    var supportsNewProposal: Bool {
        self == .available || self == .archived
    }
}

enum CapabilityEvidenceContradictionState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case none
    case needsReview = "needs_review"
    case contradicted
}

struct CapabilityEvidenceRelationship: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let revision: Int
    let capabilityID: CapabilityID
    let source: CapabilityEvidenceSourceReference
    let relationKind: CapabilityEvidenceRelationKind
    let userApprovedContext: String?
    let occurredAt: String?
    let freshnessUpdatedAt: String?
    let availability: CapabilityEvidenceAvailability
    let contradictionState: CapabilityEvidenceContradictionState
    let lineageIDs: [String]

    init(
        id: String,
        revision: Int = 1,
        capabilityID: CapabilityID,
        source: CapabilityEvidenceSourceReference,
        relationKind: CapabilityEvidenceRelationKind,
        userApprovedContext: String? = nil,
        occurredAt: String? = nil,
        freshnessUpdatedAt: String? = nil,
        availability: CapabilityEvidenceAvailability = .available,
        contradictionState: CapabilityEvidenceContradictionState = .none,
        lineageIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.revision = max(1, revision)
        self.capabilityID = capabilityID
        self.source = source
        self.relationKind = relationKind
        self.userApprovedContext = userApprovedContext?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.occurredAt = occurredAt?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.freshnessUpdatedAt = freshnessUpdatedAt?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.availability = availability
        self.contradictionState = contradictionState
        self.lineageIDs = Array(Set(lineageIDs.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }

    var isWellFormed: Bool {
        id.isEmpty == false &&
            capabilityID.rawValue.isEmpty == false &&
            source.stableID.isEmpty == false &&
            source.fingerprint.isEmpty == false &&
            (relationKind != .proofLinked || source.kind == .proof)
    }

    var provenanceFacet: CapabilityProvenanceFacet {
        relationKind == .practiced ? .practiced : .proofLinked
    }
}

typealias CapabilityEvidenceEdge = CapabilityEvidenceRelationship

extension CapabilityRecord {
    func provenanceFacets(from relationships: [CapabilityEvidenceRelationship]) -> Set<CapabilityProvenanceFacet> {
        var facets: Set<CapabilityProvenanceFacet> = creationKind == .manual ? [.userStated] : []
        for relationship in relationships where relationship.capabilityID == id {
            facets.insert(relationship.provenanceFacet)
        }
        return facets
    }
}
