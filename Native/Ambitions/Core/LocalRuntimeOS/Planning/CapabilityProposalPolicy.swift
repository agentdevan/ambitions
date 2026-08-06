import CryptoKit
import Foundation

let capabilityProposalPolicyVersion = "capability_proposal.native.v1"

/// Only accepted local evidence can enter this policy. Receipt classification is
/// deliberately absent: a receipt alone is never capability evidence.
enum CapabilityProposalEligibilityEvent: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case acceptedCompletion = "accepted_completion"
    case approvedEvidence = "approved_evidence"
}

enum CapabilityProposalPresentationHost: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case goalReview = "goal_review"
    case closureReview = "closure_review"
    case lifeCapitalInspection = "life_capital_inspection"
}

enum CapabilityProposalStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pending
    case presented
    case notNow = "not_now"
    case notThis = "not_this"
    case needsRevalidation = "needs_revalidation"
    case settled
}

enum CapabilityProposalQuietReason: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case noAcceptedEvidence = "no_accepted_evidence"
    case futureUseNotPermitted = "future_use_not_permitted"
    case inactiveLifecycle = "inactive_lifecycle"
    case sourceUnavailable = "source_unavailable"
    case contradictoryEvidence = "contradictory_evidence"
    case protectedContent = "protected_content"
    case duplicateBasis = "duplicate_basis"
}

struct CapabilityProposalObservation: Codable, Sendable, Equatable, Hashable {
    let source: CapabilityEvidenceSourceReference
    let event: CapabilityProposalEligibilityEvent
    let relationKind: CapabilityEvidenceRelationKind
    let isAccepted: Bool
    let availability: CapabilityEvidenceAvailability
    let contradictionState: CapabilityEvidenceContradictionState
    let outputPrivacy: CapabilityPrivacyClassification
    let contextPrivacy: CapabilityPrivacyClassification
    let lifecycle: CapabilityLifecycle
    let futureUseState: CapabilityFutureUseState
    let explicitName: String?
    let explicitMeaning: String?
    let presentationHost: CapabilityProposalPresentationHost

    init(
        source: CapabilityEvidenceSourceReference,
        event: CapabilityProposalEligibilityEvent,
        relationKind: CapabilityEvidenceRelationKind,
        isAccepted: Bool,
        availability: CapabilityEvidenceAvailability,
        contradictionState: CapabilityEvidenceContradictionState,
        outputPrivacy: CapabilityPrivacyClassification,
        contextPrivacy: CapabilityPrivacyClassification,
        lifecycle: CapabilityLifecycle,
        futureUseState: CapabilityFutureUseState,
        explicitName: String?,
        explicitMeaning: String?,
        presentationHost: CapabilityProposalPresentationHost
    ) {
        self.source = source
        self.event = event
        self.relationKind = relationKind
        self.isAccepted = isAccepted
        self.availability = availability
        self.contradictionState = contradictionState
        self.outputPrivacy = outputPrivacy
        self.contextPrivacy = contextPrivacy
        self.lifecycle = lifecycle
        self.futureUseState = futureUseState
        self.explicitName = Self.trimmed(explicitName)
        self.explicitMeaning = Self.trimmed(explicitMeaning)
        self.presentationHost = presentationHost
    }

    private static func trimmed(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

/// A candidate is review-only. It intentionally has no Capability ID and no
/// mutation entry point; confirmation is owned by the later command service.
struct CapabilityProposalRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let revision: Int
    let policyVersion: String
    let normalizedName: String
    let normalizedMeaning: String
    let sourceReferences: [CapabilityEvidenceSourceReference]
    let evidenceBasisFingerprint: String
    let eligibilityEvent: CapabilityProposalEligibilityEvent
    let presentationHost: CapabilityProposalPresentationHost
    let relationshipKinds: Set<CapabilityEvidenceRelationKind>
    let uncertainty: String?
    let outputPrivacy: CapabilityPrivacyClassification
    let contextPrivacy: CapabilityPrivacyClassification
    let status: CapabilityProposalStatus
    let presentedCount: Int
    let materialEvidenceRevision: Int
}

struct CapabilityNotThisRecord: Codable, Sendable, Equatable, Hashable {
    let evidenceBasisFingerprint: String
    let policyVersion: String
    let dismissedAt: String
    let reconsideredAt: String?
}

enum CapabilityProposalDecision: Codable, Sendable, Equatable, Hashable {
    case proposal(CapabilityProposalRecord)
    case neutralReflection
    case quiet(CapabilityProposalQuietReason)
}

/// A pure deterministic classifier. It receives no store, command, Receipt,
/// History, or Capability mutation dependency.
struct CapabilityProposalPolicy: Sendable, Equatable, Hashable {
    let policyVersion: String

    init(policyVersion: String = capabilityProposalPolicyVersion) {
        self.policyVersion = policyVersion.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func evaluate(
        observations: [CapabilityProposalObservation],
        dismissedBasisFingerprints: Set<String> = []
    ) -> CapabilityProposalDecision {
        let ordered = observations.sorted(by: Self.observationOrdering)
        guard ordered.isEmpty == false else {
            return .quiet(.noAcceptedEvidence)
        }

        if let reason = ordered.compactMap(quietReason(for:)).first {
            return .quiet(reason)
        }

        let names = ordered.compactMap(\.explicitName).map(normalize)
        let meanings = ordered.compactMap(\.explicitMeaning).map(normalize)
        guard let normalizedName = names.first, normalizedName.isEmpty == false,
              let normalizedMeaning = meanings.first, normalizedMeaning.isEmpty == false
        else {
            return .neutralReflection
        }

        let sources = ordered.map(\.source)
        let fingerprint = basisFingerprint(sources: sources, normalizedMeaning: normalizedMeaning)
        if dismissedBasisFingerprints.contains(fingerprint) {
            return .quiet(.duplicateBasis)
        }

        let host = ordered.map(\.presentationHost).sorted { $0.rawValue < $1.rawValue }.first ?? .lifeCapitalInspection
        let event = ordered.map(\.event).sorted { $0.rawValue < $1.rawValue }.first ?? .approvedEvidence
        let relationshipKinds = Set(ordered.map(\.relationKind))
        let maximumRevision = sources.map(\.revision).max() ?? 1
        return .proposal(CapabilityProposalRecord(
            id: "capability.proposal.\(fingerprint)",
            revision: 1,
            policyVersion: policyVersion,
            normalizedName: normalizedName,
            normalizedMeaning: normalizedMeaning,
            sourceReferences: sources,
            evidenceBasisFingerprint: fingerprint,
            eligibilityEvent: event,
            presentationHost: host,
            relationshipKinds: relationshipKinds,
            uncertainty: nil,
            outputPrivacy: .privateLocal,
            contextPrivacy: .privateLocal,
            status: .pending,
            presentedCount: 0,
            materialEvidenceRevision: maximumRevision
        ))
    }
}

private extension CapabilityProposalPolicy {
    static func observationOrdering(_ lhs: CapabilityProposalObservation, _ rhs: CapabilityProposalObservation) -> Bool {
        let left = "\(lhs.source.stableID)|\(lhs.source.revision)|\(lhs.source.fingerprint)|\(lhs.relationKind.rawValue)"
        let right = "\(rhs.source.stableID)|\(rhs.source.revision)|\(rhs.source.fingerprint)|\(rhs.relationKind.rawValue)"
        return left < right
    }

    func quietReason(for observation: CapabilityProposalObservation) -> CapabilityProposalQuietReason? {
        guard observation.isAccepted else { return .noAcceptedEvidence }
        guard observation.futureUseState.isEnabled else { return .futureUseNotPermitted }
        guard observation.lifecycle.canInfluenceFutureUse else { return .inactiveLifecycle }
        guard observation.availability.supportsNewProposal else { return .sourceUnavailable }
        guard observation.contradictionState == .none else { return .contradictoryEvidence }
        guard observation.outputPrivacy.permitsFutureUse, observation.contextPrivacy.permitsFutureUse else {
            return .protectedContent
        }
        return nil
    }

    func basisFingerprint(sources: [CapabilityEvidenceSourceReference], normalizedMeaning: String) -> String {
        let sourcePart = sources
            .map { "\($0.stableID)@\($0.revision)#\($0.fingerprint)" }
            .joined(separator: "+")
        let canonicalBasis = "\(policyVersion)|\(sourcePart)|\(normalizedMeaning)"
        return SHA256.hash(data: Data(canonicalBasis.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: \.isWhitespace)
            .joined(separator: " ")
            .lowercased()
    }
}
