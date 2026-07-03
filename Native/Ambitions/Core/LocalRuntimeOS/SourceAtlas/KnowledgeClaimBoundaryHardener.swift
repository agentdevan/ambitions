import Foundation

enum KnowledgeClaimBoundaryIssue: String, Codable, Sendable, Equatable, Hashable {
    case missingSourceLocator = "missing_source_locator"
    case inferredSource = "inferred_source"
    case staleOrExpired = "stale_or_expired"
    case lowTrust = "low_trust"
    case providerUnavailable = "provider_unavailable"
    case conflicting = "conflicting"
}

struct KnowledgeClaimBoundaryAssessment: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let claimID: String
    let subject: String
    let issues: [KnowledgeClaimBoundaryIssue]
    let userFacingAssertionAllowed: Bool
    let disclosureSummary: String
}

struct KnowledgeClaimBoundaryReport: Codable, Sendable, Equatable {
    let assessments: [KnowledgeClaimBoundaryAssessment]
    let degradationStates: [KnowledgeDegradationState]
    let degradationSummary: String?
}

struct KnowledgeClaimBoundaryHardener: Sendable {
    func assess(
        claims: [KnowledgeClaim],
        providerStatuses: [KnowledgeProviderStatus],
        existingDegradationStates: [KnowledgeDegradationState] = []
    ) -> KnowledgeClaimBoundaryReport {
        let providerUnavailableIDs = Set(
            providerStatuses
                .filter { $0.availability == .providerUnavailable || $0.availability == .unsupported }
                .map(\.provider.id)
        )
        let assessments = claims.map { claim in
            assessment(for: claim, providerUnavailableIDs: providerUnavailableIDs)
        }
        let states = stableUnique(existingDegradationStates + degradationStates(from: assessments))
        return KnowledgeClaimBoundaryReport(
            assessments: assessments,
            degradationStates: states,
            degradationSummary: states.isEmpty ? nil : states.map(\.rawValue).joined(separator: ",")
        )
    }

    private func assessment(
        for claim: KnowledgeClaim,
        providerUnavailableIDs: Set<String>
    ) -> KnowledgeClaimBoundaryAssessment {
        var issues: [KnowledgeClaimBoundaryIssue] = []
        if (claim.source.locator ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append(.missingSourceLocator)
        }
        if claim.source.provenanceKind == .inferred || claim.uncertaintyFlags.contains(.inferred) {
            issues.append(.inferredSource)
        }
        if claim.freshness.state == .stale || claim.freshness.state == .expired || claim.uncertaintyFlags.contains(.stale) {
            issues.append(.staleOrExpired)
        }
        if claim.trustLevel == .low || claim.confidence == .low || claim.uncertaintyFlags.contains(.lowConfidence) {
            issues.append(.lowTrust)
        }
        if providerUnavailableIDs.contains(claim.providerID) || claim.uncertaintyFlags.contains(.providerUnavailable) {
            issues.append(.providerUnavailable)
        }
        if claim.uncertaintyFlags.contains(.conflicting) {
            issues.append(.conflicting)
        }
        let stableIssues = stableUnique(issues)
        return KnowledgeClaimBoundaryAssessment(
            id: "knowledge_claim_boundary.\(claim.id)",
            claimID: claim.id,
            subject: claim.subject,
            issues: stableIssues,
            userFacingAssertionAllowed: stableIssues.isEmpty,
            disclosureSummary: stableIssues.isEmpty
                ? "Claim has source, freshness, trust, and conflict boundary support."
                : "Claim requires boundary disclosure before being treated as settled knowledge."
        )
    }

    private func degradationStates(from assessments: [KnowledgeClaimBoundaryAssessment]) -> [KnowledgeDegradationState] {
        var states: [KnowledgeDegradationState] = []
        if assessments.contains(where: { $0.issues.contains(.staleOrExpired) }) {
            states.append(.staleInformation)
        }
        if assessments.contains(where: { $0.issues.contains(.lowTrust) || $0.issues.contains(.missingSourceLocator) || $0.issues.contains(.inferredSource) }) {
            states.append(.lowTrustInformation)
        }
        if assessments.contains(where: { $0.issues.contains(.providerUnavailable) }) {
            states.append(.providerUnavailable)
        }
        if assessments.contains(where: { $0.issues.contains(.conflicting) }) {
            states.append(.conflictingClaims)
        }
        return stableUnique(states)
    }

    private func stableUnique<T: Hashable>(_ values: [T]) -> [T] {
        var seen: Set<T> = []
        var result: [T] = []
        for value in values where seen.insert(value).inserted {
            result.append(value)
        }
        return result
    }
}
