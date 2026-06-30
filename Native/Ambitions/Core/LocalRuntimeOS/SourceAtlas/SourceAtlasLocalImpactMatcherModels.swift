import Foundation

enum SourceAtlasLocalImpactClaimBoundary: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localImpactOnly = "local_impact_only"
    case reviewRequired = "review_required"
    case sourceNeeded = "source_needed"
}

struct SourceAtlasLocalGoalSourceBinding: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let localGoalID: String
    let sourceClaimIDs: [String]
    let sourceRecordIDs: [String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let provenanceIDs: [String]

    init(
        id: String,
        localGoalID: String,
        sourceClaimIDs: [String],
        sourceRecordIDs: [String] = [],
        sourceState: SourceAtlasRequirementSourceState = .unknown,
        freshnessState: SourceAtlasRequirementFreshnessState = .unknown,
        reviewState: SourceAtlasRequirementReviewState = .required,
        provenanceIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.localGoalID = localGoalID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceClaimIDs = Self.orderedUnique(sourceClaimIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.provenanceIDs = Self.orderedUnique(provenanceIDs + sourceRecordIDs)
    }

    var requiresReview: Bool {
        sourceState.blocksCurrentProjection ||
            freshnessState.blocksCurrentProjection ||
            reviewState.blocksCurrentProjection
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasChangedPublicClaimSet: Codable, Sendable, Equatable, Hashable {
    let changedClaimIDs: [String]

    init(changedClaimIDs: [String]) {
        self.changedClaimIDs = Self.orderedUnique(changedClaimIDs)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasLocalImpactReceiptPreview: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let affectedLocalGoalIDs: [String]
    let changedClaimIDs: [String]
    let sourceRecordIDs: [String]
    let provenanceIDs: [String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewRequired: Bool
    let claimBoundary: SourceAtlasLocalImpactClaimBoundary

    init(
        id: String,
        affectedLocalGoalIDs: [String],
        changedClaimIDs: [String],
        sourceRecordIDs: [String],
        provenanceIDs: [String],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewRequired: Bool,
        claimBoundary: SourceAtlasLocalImpactClaimBoundary
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.affectedLocalGoalIDs = Self.orderedUnique(affectedLocalGoalIDs)
        self.changedClaimIDs = Self.orderedUnique(changedClaimIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.provenanceIDs = Self.orderedUnique(provenanceIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewRequired = reviewRequired
        self.claimBoundary = claimBoundary
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasLocalImpactMatch: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let bindingID: String
    let affectedLocalGoalID: String
    let changedClaimIDs: [String]
    let sourceRecordIDs: [String]
    let provenanceIDs: [String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewRequired: Bool
    let receiptPreview: SourceAtlasLocalImpactReceiptPreview
}

struct SourceAtlasLocalImpactMatcherResponse: Codable, Sendable, Equatable, Hashable {
    let changedClaimIDs: [String]
    let matches: [SourceAtlasLocalImpactMatch]
    let runtimeBoundary: SourceAtlasRuntimeBoundary

    var receiptPreviews: [SourceAtlasLocalImpactReceiptPreview] {
        matches.map(\.receiptPreview)
    }
}

struct SourceAtlasLocalImpactMatcher: Sendable, Equatable, Hashable {
    let runtimeBoundary: SourceAtlasRuntimeBoundary

    init(runtimeBoundary: SourceAtlasRuntimeBoundary = .valueModelOnly) {
        self.runtimeBoundary = runtimeBoundary
    }

    func match(
        changedClaims: SourceAtlasChangedPublicClaimSet,
        localBindings: [SourceAtlasLocalGoalSourceBinding]
    ) -> SourceAtlasLocalImpactMatcherResponse {
        let changedIDs = Set(changedClaims.changedClaimIDs)

        let matches = localBindings.compactMap { binding -> SourceAtlasLocalImpactMatch? in
            let impactedClaimIDs = binding.sourceClaimIDs.filter { changedIDs.contains($0) }
            guard impactedClaimIDs.isEmpty == false else {
                return nil
            }

            let reviewRequired = binding.requiresReview || impactedClaimIDs.isEmpty == false
            let boundary = Self.claimBoundary(
                sourceState: binding.sourceState,
                reviewRequired: reviewRequired
            )
            let matchID = Self.stableID(parts: ["impact", binding.localGoalID, binding.id] + impactedClaimIDs)
            let receipt = SourceAtlasLocalImpactReceiptPreview(
                id: "receipt-\(matchID)",
                affectedLocalGoalIDs: [binding.localGoalID],
                changedClaimIDs: impactedClaimIDs,
                sourceRecordIDs: binding.sourceRecordIDs,
                provenanceIDs: binding.provenanceIDs,
                sourceState: binding.sourceState,
                freshnessState: binding.freshnessState,
                reviewRequired: reviewRequired,
                claimBoundary: boundary
            )

            return SourceAtlasLocalImpactMatch(
                id: matchID,
                bindingID: binding.id,
                affectedLocalGoalID: binding.localGoalID,
                changedClaimIDs: impactedClaimIDs,
                sourceRecordIDs: binding.sourceRecordIDs,
                provenanceIDs: binding.provenanceIDs,
                sourceState: binding.sourceState,
                freshnessState: binding.freshnessState,
                reviewRequired: reviewRequired,
                receiptPreview: receipt
            )
        }

        return SourceAtlasLocalImpactMatcherResponse(
            changedClaimIDs: changedClaims.changedClaimIDs,
            matches: matches.sorted { $0.id < $1.id },
            runtimeBoundary: runtimeBoundary
        )
    }

    private static func claimBoundary(
        sourceState: SourceAtlasRequirementSourceState,
        reviewRequired: Bool
    ) -> SourceAtlasLocalImpactClaimBoundary {
        switch sourceState {
        case .sourceNeeded, .unknown:
            return .sourceNeeded
        default:
            return reviewRequired ? .reviewRequired : .localImpactOnly
        }
    }

    private static func stableID(parts: [String]) -> String {
        parts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }
}
