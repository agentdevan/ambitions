import Foundation

extension SourceInspectionPresentation {
    static func make(
        localReferenceProof proof: SourceAtlasLocalReferenceCompositionProof
    ) -> SourceInspectionPresentation {
        SourceInspectionPresentation.make(
            id: proof.id,
            state: SourceInspectionState(localReferenceState: proof.state),
            publicDetail: SourceInspectionPublicDetail(
                sourceName: proof.sourceName,
                sourceKind: proof.sourceKind,
                referenceTitle: proof.referenceTitle,
                retrievedLabel: proof.retrievedLabel,
                freshnessLabel: proof.freshnessLabel,
                useLabel: proof.useLabel
            ),
            useContext: "\(proof.useLabel) \(proof.localOnlyMatchingStatement) \(proof.nonClaim)",
            reviewAction: reviewAction(for: proof)
        )
    }

    private static func reviewAction(
        for proof: SourceAtlasLocalReferenceCompositionProof
    ) -> String {
        switch proof.state {
        case .current:
            "No review is needed for this public reference state. Keep final action choices local."
        case .stale:
            "Confirm the source before this older reference changes behavior."
        case .staleCritical:
            "Refresh this source before it guides current behavior."
        case .unavailable:
            "Continue locally without this reference."
        case .conflicted:
            "Review the conflict before using this source."
        case .revoked:
            "Do not use this withdrawn reference."
        case .unsupported:
            "Use local planning without this source type."
        case .reviewRequired:
            "Review this source before it changes behavior."
        }
    }
}

private extension SourceInspectionState {
    init(localReferenceState: SourceAtlasLocalReferenceCompositionState) {
        switch localReferenceState {
        case .current:
            self = .current
        case .stale:
            self = .stale
        case .staleCritical:
            self = .staleCritical
        case .unavailable:
            self = .unavailable
        case .conflicted:
            self = .conflicted
        case .revoked:
            self = .revoked
        case .unsupported:
            self = .unsupported
        case .reviewRequired:
            self = .reviewRequired
        }
    }
}
