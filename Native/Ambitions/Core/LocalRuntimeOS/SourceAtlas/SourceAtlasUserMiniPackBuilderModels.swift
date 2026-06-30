import Foundation

let sourceAtlasUserMiniPackBuilderSchemaVersion = "source_atlas_user_mini_pack_builder.native.v1"

enum SourceAtlasUserMiniPackEligibilityState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case eligible
    case reviewRequired = "review_required"
    case blocked

    var requiresReview: Bool {
        self != .eligible
    }
}

struct SourceAtlasUserMiniPackClaimInput: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let text: String
    let sourceState: SourceAtlasRequirementSourceState
    let riskClass: SourceAtlasRiskClass

    init(
        id: String,
        text: String,
        sourceState: SourceAtlasRequirementSourceState,
        riskClass: SourceAtlasRiskClass
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceState = sourceState
        self.riskClass = riskClass
    }
}

struct SourceAtlasUserMiniPackClaimState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claim: SourceAtlasClaim
    let sourceRecord: SourceAtlasSourceRecord
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let correctionEligibility: SourceAtlasUserMiniPackEligibilityState
    let rejectionEligibility: SourceAtlasUserMiniPackEligibilityState
    let deletionEligibility: SourceAtlasUserMiniPackEligibilityState
}

struct SourceAtlasUserMiniPackBuildRequest: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let domainID: String
    let claims: [SourceAtlasUserMiniPackClaimInput]
    let createdAt: String
    let updatedAt: String
    let version: String

    init(
        id: String,
        title: String,
        domainID: String,
        claims: [SourceAtlasUserMiniPackClaimInput],
        createdAt: String,
        updatedAt: String,
        version: String = "1.0.0"
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainID = domainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.claims = claims.sorted { $0.id < $1.id }
        self.createdAt = createdAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.updatedAt = updatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.version = version.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct SourceAtlasUserMiniPackBuildResult: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let pack: SourceAtlasPack
    let container: SourceAtlasSourceContainer
    let claimStates: [SourceAtlasUserMiniPackClaimState]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasFreshnessState
    let correctionEligibility: SourceAtlasUserMiniPackEligibilityState
    let rejectionEligibility: SourceAtlasUserMiniPackEligibilityState
    let deletionEligibility: SourceAtlasUserMiniPackEligibilityState

    var isLocalOnly: Bool {
        pack.runtimeBoundary.isValueModelOnly
    }

    var requiresReview: Bool {
        container.requiresReview
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case packSnapshot
        case container
        case claimStates
        case sourceState
        case freshnessState
        case correctionEligibility
        case rejectionEligibility
        case deletionEligibility
    }

    private struct PackSnapshot: Codable, Sendable, Equatable, Hashable {
        let id: String
        let title: String
        let kind: SourceAtlasPackKind
        let version: String
        let domainID: String
        let classification: String
        let productionUse: Bool
        let runtimeBoundary: SourceAtlasRuntimeBoundary
    }

    init(
        id: String,
        pack: SourceAtlasPack,
        container: SourceAtlasSourceContainer,
        claimStates: [SourceAtlasUserMiniPackClaimState],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasFreshnessState,
        correctionEligibility: SourceAtlasUserMiniPackEligibilityState,
        rejectionEligibility: SourceAtlasUserMiniPackEligibilityState,
        deletionEligibility: SourceAtlasUserMiniPackEligibilityState
    ) {
        self.id = id
        self.pack = pack
        self.container = container
        self.claimStates = claimStates
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.correctionEligibility = correctionEligibility
        self.rejectionEligibility = rejectionEligibility
        self.deletionEligibility = deletionEligibility
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        let snapshot = try container.decode(PackSnapshot.self, forKey: .packSnapshot)
        self.container = try container.decode(SourceAtlasSourceContainer.self, forKey: .container)
        self.claimStates = try container.decode([SourceAtlasUserMiniPackClaimState].self, forKey: .claimStates)
        self.sourceState = try container.decode(SourceAtlasRequirementSourceState.self, forKey: .sourceState)
        self.freshnessState = try container.decode(SourceAtlasFreshnessState.self, forKey: .freshnessState)
        self.correctionEligibility = try container.decode(SourceAtlasUserMiniPackEligibilityState.self, forKey: .correctionEligibility)
        self.rejectionEligibility = try container.decode(SourceAtlasUserMiniPackEligibilityState.self, forKey: .rejectionEligibility)
        self.deletionEligibility = try container.decode(SourceAtlasUserMiniPackEligibilityState.self, forKey: .deletionEligibility)
        self.pack = SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: snapshot.id,
                title: snapshot.title,
                kind: snapshot.kind,
                version: snapshot.version,
                domainID: snapshot.domainID,
                classification: snapshot.classification,
                productionUse: snapshot.productionUse
            ),
            sources: [],
            claims: [],
            requirements: [],
            starterItems: [],
            proofMap: [],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Needs a source before it can be reused.",
                reviewRequired: "Needs review before it can be reused.",
                notProfessionalAdvice: "Local private notes only."
            ),
            runtimeBoundary: snapshot.runtimeBoundary,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [snapshot.id],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["\(snapshot.id).mini_pack"],
                ownsIndividualGoalPhrase: false
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(
            PackSnapshot(
                id: pack.manifest.id,
                title: pack.manifest.title,
                kind: pack.manifest.kind,
                version: pack.manifest.version,
                domainID: pack.manifest.domainID,
                classification: pack.manifest.classification,
                productionUse: pack.manifest.productionUse,
                runtimeBoundary: pack.runtimeBoundary
            ),
            forKey: .packSnapshot
        )
        try container.encode(self.container, forKey: .container)
        try container.encode(claimStates, forKey: .claimStates)
        try container.encode(sourceState, forKey: .sourceState)
        try container.encode(freshnessState, forKey: .freshnessState)
        try container.encode(correctionEligibility, forKey: .correctionEligibility)
        try container.encode(rejectionEligibility, forKey: .rejectionEligibility)
        try container.encode(deletionEligibility, forKey: .deletionEligibility)
    }
}

struct SourceAtlasUserMiniPackBuilder: Sendable, Equatable, Hashable {
    func build(_ request: SourceAtlasUserMiniPackBuildRequest) -> SourceAtlasUserMiniPackBuildResult {
        let claimStates = request.claims.map { input in
            let sourceRecord = SourceAtlasSourceRecord(
                id: "\(request.id).source.\(input.id)",
                title: input.text,
                kind: .userProvided,
                locator: "ambitions://source-atlas/user-mini/\(request.id)/\(input.id)",
                approvedForOfficialClaims: false
            )
            let freshnessState = Self.freshnessState(for: input.sourceState)
            let claim = SourceAtlasClaim(
                id: input.id,
                text: input.text,
                state: Self.claimState(for: input.sourceState),
                freshness: freshnessState,
                riskClass: input.riskClass,
                sourceIDs: [sourceRecord.id],
                reviewRequired: input.sourceState.miniPackEligibility.requiresReview
            )
            let eligibility = input.sourceState.miniPackEligibility

            return SourceAtlasUserMiniPackClaimState(
                id: claim.id,
                claim: claim,
                sourceRecord: sourceRecord,
                sourceState: input.sourceState,
                freshnessState: freshnessState,
                correctionEligibility: eligibility,
                rejectionEligibility: eligibility,
                deletionEligibility: eligibility
            )
        }

        let aggregatedSourceState = Self.aggregateSourceState(claimStates.map(\.sourceState))
        let aggregatedFreshnessState = Self.aggregateFreshnessState(claimStates.map(\.freshnessState))
        let aggregatedEligibility = Self.aggregateEligibility(claimStates.map(\.correctionEligibility))
        let sources = claimStates.map(\.sourceRecord)
        let claims = claimStates.map(\.claim)

        let pack = SourceAtlasPack(
            manifest: SourceAtlasPackManifest(
                id: request.id,
                title: request.title,
                kind: .userMiniPack,
                version: request.version,
                domainID: request.domainID,
                classification: "user_mini_pack",
                productionUse: false
            ),
            sources: sources,
            claims: claims,
            requirements: [],
            starterItems: [],
            proofMap: [],
            projections: [],
            freshnessPolicy: .conservativeFreshness,
            riskPolicy: .conservative,
            disclosureCopy: SourceAtlasDisclosureCopy(
                sourceNeeded: "Needs a source before it can be reused.",
                reviewRequired: "Needs review before it can be reused.",
                notProfessionalAdvice: "Local private notes only."
            ),
            runtimeBoundary: .valueModelOnly,
            composition: SourceAtlasCompositionContract(
                dependencyPackIDs: [],
                reusableNodeIDs: [request.id],
                overlayDependencyIDs: [],
                projectionRecipeIDs: ["\(request.id).mini_pack"],
                ownsIndividualGoalPhrase: false
            )
        )

        let container = SourceAtlasSourceContainer(
            id: request.id,
            title: request.title,
            kind: .userMiniPack,
            sourceKind: .userProvided,
            locator: "ambitions://source-atlas/user-mini/\(request.id)",
            provenanceState: .userMiniPack,
            extractionState: .notStarted,
            sourceState: aggregatedSourceState,
            freshnessState: aggregatedFreshnessState,
            reviewState: .ready,
            privacyClass: .privateLife,
            sourceRecordIDs: sources.map(\.id),
            claimIDs: claims.map(\.id),
            createdAt: request.createdAt,
            updatedAt: request.updatedAt
        )

        return SourceAtlasUserMiniPackBuildResult(
            id: request.id,
            pack: pack,
            container: container,
            claimStates: claimStates,
            sourceState: aggregatedSourceState,
            freshnessState: aggregatedFreshnessState,
            correctionEligibility: aggregatedEligibility,
            rejectionEligibility: aggregatedEligibility,
            deletionEligibility: aggregatedEligibility
        )
    }

    private static func claimState(for sourceState: SourceAtlasRequirementSourceState) -> SourceAtlasClaimState {
        switch sourceState {
        case .unknown:
            return .unknown
        case .sourceNeeded:
            return .sourceNeeded
        case .stale:
            return .stale
        case .contradicted:
            return .contradicted
        case .revoked:
            return .revoked
        case .locallyProven:
            return .verifiedByLocalProof
        case .official, .officialCurrent, .current:
            return .userConfirmed
        }
    }

    private static func freshnessState(for sourceState: SourceAtlasRequirementSourceState) -> SourceAtlasFreshnessState {
        switch sourceState {
        case .unknown:
            return .unknown
        case .sourceNeeded:
            return .needsReview
        case .stale:
            return .stale
        case .contradicted:
            return .disputed
        case .revoked:
            return .revoked
        case .locallyProven:
            return .current
        case .official, .officialCurrent, .current:
            return .current
        }
    }

    private static func aggregateSourceState(_ states: [SourceAtlasRequirementSourceState]) -> SourceAtlasRequirementSourceState {
        if states.contains(.revoked) {
            return .revoked
        }
        if states.contains(.contradicted) {
            return .contradicted
        }
        if states.contains(.stale) {
            return .stale
        }
        if states.contains(.locallyProven) {
            return .locallyProven
        }
        if states.contains(.sourceNeeded) {
            return .sourceNeeded
        }
        if states.contains(.official) || states.contains(.officialCurrent) || states.contains(.current) {
            return .current
        }
        return .unknown
    }

    private static func aggregateFreshnessState(_ states: [SourceAtlasFreshnessState]) -> SourceAtlasFreshnessState {
        if states.contains(.revoked) {
            return .revoked
        }
        if states.contains(.disputed) {
            return .disputed
        }
        if states.contains(.staleCritical) {
            return .staleCritical
        }
        if states.contains(.stale) {
            return .stale
        }
        if states.contains(.sourceChanged) {
            return .sourceChanged
        }
        if states.contains(.needsReview) {
            return .needsReview
        }
        if states.contains(.aging) {
            return .aging
        }
        if states.contains(.userProvided) {
            return .userProvided
        }
        if states.contains(.unknown) {
            return .unknown
        }
        if states.contains(.current) {
            return .current
        }
        return .unknown
    }

    private static func aggregateEligibility(_ states: [SourceAtlasUserMiniPackEligibilityState]) -> SourceAtlasUserMiniPackEligibilityState {
        if states.contains(.blocked) {
            return .blocked
        }
        if states.contains(.reviewRequired) {
            return .reviewRequired
        }
        return .eligible
    }
}

private extension SourceAtlasRequirementSourceState {
    var miniPackEligibility: SourceAtlasUserMiniPackEligibilityState {
        switch self {
        case .locallyProven:
            return .eligible
        case .unknown, .sourceNeeded, .official, .officialCurrent, .current:
            return .reviewRequired
        case .stale, .contradicted, .revoked:
            return .blocked
        }
    }
}
