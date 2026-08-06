import Foundation

extension PublicReferenceInspectionProjection {
    /// Synthetic, public-only preview data used to exercise the approved
    /// inspection surface. Production continues to depend on a verified pack.
    static let previewCurrent: PublicReferenceInspectionProjection = {
        let selectedClaim = Claim(
            id: PublicReferenceClaimID("onet-task-1"),
            title: "Task",
            value: "Analyze information to determine, recommend, and plan installation of a new system or modification of an existing system.",
            sourceNativeIdentity: "15-1252.00 · occupation.task · task-1",
            authority: "onet — O*NET descriptive authority.",
            jurisdictionAndRelease: "United States (US), release 30.3",
            retrieval: "Bundled with the approved 30.3 release; checked 2026-08-06",
            freshness: "current",
            limits: "Descriptive public occupation reference only. It does not describe the user and does not authorize recommendations.",
            conflicts: "No recorded conflicts.",
            supersession: "No recorded supersession.",
            attribution: "O*NET 30.3",
            accessibilityLabel: "Task public reference claim",
            accessibilityValue: "Public task description. Authority O*NET. United States release 30.3. Freshness current. Descriptive reference only. No conflicts or supersession. Attribution O*NET 30.3."
        )
        return PublicReferenceInspectionProjection(
            id: "public-reference-inspection-onet-30.3-30.3",
            title: "Public reference sources",
            corpusTitle: "O*NET 30.3 — Software Developers (15-1252.00), United States",
            availability: .available,
            sourceRevision: "30.3|preview-current",
            delivery: "Bundled and verified",
            semanticUse: "Complete for approved descriptive claims",
            recommendationReadiness: "Not approved for recommendation use",
            authority: "onet — O*NET descriptive authority.",
            retrieval: "Bundled with the approved 30.3 release; checked 2026-08-06",
            freshness: "current",
            selectedClaimID: selectedClaim.id,
            selectedClaim: selectedClaim,
            claims: [selectedClaim],
            recheckTrigger: RecheckTrigger(
                title: "Check approved source release",
                detail: "A later check may use the approved public artifact only; this inspection does not fetch or change data.",
                isRequired: false
            ),
            isReadOnly: true
        )
    }()
}
