import Foundation

struct PublicReferenceInspectionProjection: Codable, Sendable, Equatable, Hashable, Identifiable {
    enum Availability: String, Codable, Sendable, Equatable, Hashable {
        case available
        case unavailable
    }

    struct Claim: Codable, Sendable, Equatable, Hashable, Identifiable {
        let id: PublicReferenceClaimID
        let title: String
        let value: String
        let sourceNativeIdentity: String
        let claimScope: String
        let currentUse: String
        let authority: String
        let jurisdictionAndRelease: String
        let retrieval: String
        let freshness: String
        let limits: String
        let conflicts: String
        let supersession: String
        let attribution: String
        let sourceLocator: String
        let crossSourceRelationship: String
        let accessibilityLabel: String
        let accessibilityValue: String
    }

    struct RecheckTrigger: Codable, Sendable, Equatable, Hashable {
        let title: String
        let detail: String
        let isRequired: Bool
    }

    let id: String
    let title: String
    let corpusTitle: String
    let availability: Availability
    let sourceRevision: String
    let delivery: String
    let semanticUse: String
    let recommendationReadiness: String
    let authority: String
    let retrieval: String
    let freshness: String
    let selectedClaimID: PublicReferenceClaimID?
    let selectedClaim: Claim?
    let unavailableRequestedClaimID: PublicReferenceClaimID?
    let claims: [Claim]
    let recheckTrigger: RecheckTrigger
    let isReadOnly: Bool

    static func make(from result: PublicReferenceInspectionQueryResult) -> PublicReferenceInspectionProjection {
        let release = result.snapshot.release
        let ordered = release.claims.sorted(by: claimOrdering).map {
            claim($0, releaseClaims: release.claims)
        }
        let selected = result.selectedClaim.map {
            claim($0, releaseClaims: release.claims)
        }
        let source = release.claims.first
        let authority = source.map { "\($0.authority.publisherID) — \($0.authority.statement)" } ?? "Unavailable"
        let retrieval = source.map { "Retrieved \($0.retrievedAt); checked \($0.checkedAt)" } ?? "Unavailable"
        let freshness = source.map { $0.freshnessState.rawValue.replacingOccurrences(of: "_", with: " ") } ?? "Unavailable"
        return PublicReferenceInspectionProjection(
            id: "public-reference-inspection-\(release.artifactID)-\(release.release.id)",
            title: "Public reference sources",
            corpusTitle: "O*NET 30.3 — Software Developers (15-1252.00), United States",
            availability: .available,
            sourceRevision: release.sourceRevision,
            delivery: result.snapshot.delivery.rawValue.replacingOccurrences(of: "_", with: " "),
            semanticUse: release.claims.allSatisfy { $0.semanticReviewState == .complete }
                ? "Complete for approved descriptive claims"
                : "Incomplete for current use",
            recommendationReadiness: "Not approved for recommendation use",
            authority: authority,
            retrieval: retrieval,
            freshness: freshness,
            selectedClaimID: result.selectedClaim?.id,
            selectedClaim: selected,
            unavailableRequestedClaimID: result.unavailableRequestedClaimID,
            claims: ordered,
            recheckTrigger: RecheckTrigger(
                title: result.sourceChangedSinceObservation ? "Review update" : "Check approved source release",
                detail: result.sourceChangedSinceObservation
                    ? "The approved public source revision changed. Review its released claims before relying on this snapshot."
                    : "A later check may use the approved public artifact only; this inspection does not fetch or change data.",
                isRequired: result.sourceChangedSinceObservation
            ),
            isReadOnly: true
        )
    }

    private static func claimOrdering(_ lhs: PublicReferenceClaimEnvelope, _ rhs: PublicReferenceClaimEnvelope) -> Bool {
        let ordering = [
            "occupation.identity", "occupation.task", "occupation.skill", "occupation.knowledge",
            "occupation.work_activity", "occupation.work_context", "occupation.education", "occupation.experience"
        ]
        let left = ordering.firstIndex(of: lhs.predicateID) ?? Int.max
        let right = ordering.firstIndex(of: rhs.predicateID) ?? Int.max
        return left == right ? lhs.id.rawValue < rhs.id.rawValue : left < right
    }

    private static func claim(
        _ value: PublicReferenceClaimEnvelope,
        releaseClaims: [PublicReferenceClaimEnvelope]
    ) -> Claim {
        let limits = [
            "Authority lane: \(value.authority.lane.rawValue.replacingOccurrences(of: "_", with: " "))",
            "Rights: \(value.rightsState.rawValue.replacingOccurrences(of: "_", with: " "))",
            "Risk: \(value.riskState)"
        ].joined(separator: ". ")
        let conflicts = value.conflictIDs.isEmpty
            ? "No recorded conflicts."
            : "Review required. Conflicting statements remain separate: " +
                relationshipStatements(value.conflictIDs, releaseClaims: releaseClaims)
        let supersessionIDs = value.supersedesIDs + value.supersededByIDs
        let supersession = supersessionIDs.isEmpty
            ? "No recorded supersession."
            : "Revision relationship: " + relationshipStatements(supersessionIDs, releaseClaims: releaseClaims) +
                ". The current statement is not silently substituted."
        let freshness = value.freshnessState.rawValue.replacingOccurrences(of: "_", with: " ")
        let title = value.predicateID.replacingOccurrences(of: "occupation.", with: "").replacingOccurrences(of: "_", with: " ").capitalized
        let claimScope: String
        switch value.authority.lane {
        case .classification:
            claimScope = "O*NET identifies this occupation in its release-specific classification. It does not classify the user."
        case .typicalPreparation:
            claimScope = "O*NET reports descriptive typical preparation for this occupation. It is not a universal qualification or employer gate."
        default:
            claimScope = "O*NET provides this release-specific descriptive occupation fact. It does not describe the user or authorize a recommendation."
        }
        let availability = value.availability.rawValue.replacingOccurrences(of: "_", with: " ")
        let reviewState = value.semanticReviewState.rawValue.replacingOccurrences(of: "_", with: " ")
        let currentUse = "\(availability). Semantic review: \(reviewState). Risk: \(value.riskState)."
        return Claim(
            id: value.id, title: title, value: value.value.text,
            sourceNativeIdentity: [
                value.sourceNativeSubjectID,
                value.predicateID,
                value.sourceNativeFieldID
            ].joined(separator: " · "),
            claimScope: claimScope,
            currentUse: currentUse,
            authority: "\(value.authority.publisherID) — \(value.authority.statement)",
            jurisdictionAndRelease: "\(value.jurisdiction.label) (\(value.jurisdiction.code)), release \(value.release.id)",
            retrieval: "Retrieved \(value.retrievedAt); checked \(value.checkedAt)",
            freshness: freshness,
            limits: limits, conflicts: conflicts, supersession: supersession,
            attribution: "\(value.requiredAttribution). Use terms: \(value.rightsState.rawValue.replacingOccurrences(of: "_", with: " ")).",
            sourceLocator: value.sourceLocator,
            crossSourceRelationship: "No approved cross-source relationship",
            accessibilityLabel: "\(title) public reference claim",
            accessibilityValue: [
                value.value.text,
                "What this source can claim \(claimScope)",
                "Current use \(currentUse)",
                "Authority \(value.authority.publisherID) — \(value.authority.statement)",
                "Jurisdiction and release \(value.jurisdiction.label), \(value.release.id)",
                "Freshness \(freshness)",
                "Limits \(limits)",
                "Conflicts \(conflicts)",
                "Supersession \(supersession)",
                "No approved cross-source relationship",
                "Attribution \(value.requiredAttribution). Use terms \(value.rightsState.rawValue.replacingOccurrences(of: "_", with: " "))"
            ].joined(separator: ". ")
        )
    }

    private static func relationshipStatements(
        _ ids: [PublicReferenceClaimID],
        releaseClaims: [PublicReferenceClaimEnvelope]
    ) -> String {
        ids.map { id in
            guard let relatedClaim = releaseClaims.first(where: { $0.id == id }) else {
                return "\(id.rawValue) — statement unavailable in this release"
            }
            return "\(id.rawValue) — \(relatedClaim.value.text)"
        }.joined(separator: "; ")
    }
}

extension PublicReferenceInspectionProjection {
    static let unavailable = PublicReferenceInspectionProjection(
        id: "public-reference-inspection-unavailable",
        title: "Public reference sources",
        corpusTitle: "No verified public corpus installed",
        availability: .unavailable,
        sourceRevision: "Unavailable",
        delivery: "Unavailable",
        semanticUse: "No approved public claims available",
        recommendationReadiness: "Not approved for recommendation use",
        authority: "Unavailable",
        retrieval: "No verified local reference is available",
        freshness: "Unavailable",
        selectedClaimID: nil,
        selectedClaim: nil,
        unavailableRequestedClaimID: nil,
        claims: [],
        recheckTrigger: RecheckTrigger(
            title: "Check approved source release",
            detail: "Local planning remains available. Check again after an approved public reference is installed.",
            isRequired: false
        ),
        isReadOnly: true
    )
}
