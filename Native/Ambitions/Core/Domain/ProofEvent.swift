import Foundation

struct ProofEvent: Codable, Sendable, Equatable, Hashable, Identifiable {
    enum Kind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case closure
        case capture
        case receipt
        case recovery
        case source
    }

    let id: String
    let ambitionID: String?
    let goalThreadID: String?
    let commitmentID: String?
    let closureEventID: String?
    let kind: Kind
    let artifactReference: String?
    let summary: String
    let source: String?
    let privacyClass: AmbitionPrivacyClass
    let userConfirmed: Bool
    let createdAt: String

    init(
        id: String,
        ambitionID: String? = nil,
        goalThreadID: String? = nil,
        commitmentID: String? = nil,
        closureEventID: String? = nil,
        kind: Kind,
        artifactReference: String? = nil,
        summary: String,
        source: String? = nil,
        privacyClass: AmbitionPrivacyClass = .privateProof,
        userConfirmed: Bool = false,
        createdAt: String
    ) {
        self.id = Self.normalizedRequired(id, fallback: "proof-event")
        self.ambitionID = Self.normalizedOptional(ambitionID)
        self.goalThreadID = Self.normalizedOptional(goalThreadID)
        self.commitmentID = Self.normalizedOptional(commitmentID)
        self.closureEventID = Self.normalizedOptional(closureEventID)
        self.kind = kind
        self.artifactReference = Self.normalizedOptional(artifactReference)
        self.summary = Self.normalizedRequired(summary, fallback: "Proof event")
        self.source = Self.normalizedOptional(source)
        self.privacyClass = privacyClass
        self.userConfirmed = userConfirmed
        self.createdAt = Self.normalizedRequired(createdAt, fallback: "unknown")
    }

    init(proof: Proof) {
        self.init(
            id: proof.id,
            ambitionID: proof.ambitionID,
            goalThreadID: proof.goalThreadID,
            commitmentID: proof.commitmentID,
            closureEventID: proof.closureEventID,
            kind: proof.proofType.eventKind,
            artifactReference: proof.artifactReference,
            summary: proof.text ?? proof.artifactReference ?? proof.proofType.rawValue,
            source: proof.source,
            privacyClass: proof.privacyClass,
            userConfirmed: proof.userConfirmed,
            createdAt: proof.createdAt
        )
    }

    var isUsableForRecommendation: Bool {
        userConfirmed && privacyClass != .privateConstraint && summary.isEmpty == false
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines), trimmed.isEmpty == false else {
            return nil
        }
        return trimmed
    }

    private static func normalizedRequired(_ value: String, fallback: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? fallback : trimmed
    }
}

extension Proof {
    var proofEvent: ProofEvent {
        ProofEvent(proof: self)
    }
}

extension AmbitionGraphProofType {
    var eventKind: ProofEvent.Kind {
        switch self {
        case .artifact, .receipt, .photo, .voice:
            .receipt
        case .text, .checkpoint, .reviewNote:
            .closure
        }
    }
}
