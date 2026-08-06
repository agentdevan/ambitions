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
        let authority: String
        let jurisdictionAndRelease: String
        let retrieval: String
        let freshness: String
        let limits: String
        let conflicts: String
        let supersession: String
        let attribution: String
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
    let claims: [Claim]
    let recheckTrigger: RecheckTrigger
    let isReadOnly: Bool

    static func make(from result: PublicReferenceInspectionQueryResult) -> PublicReferenceInspectionProjection {
        let release = result.snapshot.release
        let ordered = release.claims.sorted(by: claimOrdering).map(claim)
        let selected = result.selectedClaim.map(claim)
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

    private static func claim(_ value: PublicReferenceClaimEnvelope) -> Claim {
        let limits = [
            "Authority lane: \(value.authority.lane.rawValue.replacingOccurrences(of: "_", with: " "))",
            "Rights: \(value.rightsState.rawValue.replacingOccurrences(of: "_", with: " "))",
            "Risk: \(value.riskState)"
        ].joined(separator: ". ")
        let conflicts = value.conflictIDs.isEmpty ? "No recorded conflicts." : value.conflictIDs.map(\.rawValue).joined(separator: ", ")
        let supersessionIDs = value.supersedesIDs + value.supersededByIDs
        let supersession = supersessionIDs.isEmpty ? "No recorded supersession." : supersessionIDs.map(\.rawValue).joined(separator: ", ")
        let freshness = value.freshnessState.rawValue.replacingOccurrences(of: "_", with: " ")
        let title = value.predicateID.replacingOccurrences(of: "occupation.", with: "").replacingOccurrences(of: "_", with: " ").capitalized
        return Claim(
            id: value.id, title: title, value: value.value.text,
            sourceNativeIdentity: "\(value.sourceNativeSubjectID) · \(value.predicateID) · \(value.sourceRecordID)",
            authority: "\(value.authority.publisherID) — \(value.authority.statement)",
            jurisdictionAndRelease: "\(value.jurisdiction.label) (\(value.jurisdiction.code)), release \(value.release.id)",
            retrieval: "Retrieved \(value.retrievedAt); checked \(value.checkedAt)",
            freshness: freshness, limits: limits, conflicts: conflicts, supersession: supersession,
            attribution: value.requiredAttribution,
            accessibilityLabel: "\(title) public reference claim",
            accessibilityValue: [
                value.value.text,
                "Authority \(value.authority.publisherID) — \(value.authority.statement)",
                "Jurisdiction and release \(value.jurisdiction.label), \(value.release.id)",
                "Freshness \(freshness)",
                "Limits \(limits)",
                "Conflicts \(conflicts)",
                "Supersession \(supersession)",
                "Attribution \(value.requiredAttribution)"
            ].joined(separator: ". ")
        )
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
        claims: [],
        recheckTrigger: RecheckTrigger(
            title: "Check approved source release",
            detail: "Local planning remains available. Check again after an approved public reference is installed.",
            isRequired: false
        ),
        isReadOnly: true
    )
}
