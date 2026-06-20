import Foundation

struct SourceAtlasFreshnessPolicy: Codable, Sendable, Equatable, Hashable {
    let reviewIntervalDays: Int
    let staleBlocksHighRiskUse: Bool

    static let conservativeFreshness = SourceAtlasFreshnessPolicy(
        reviewIntervalDays: 180,
        staleBlocksHighRiskUse: true
    )

    func canSupportCurrentRecommendation(
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass
    ) -> Bool {
        switch freshness {
        case .current:
            return true
        case .aging:
            return staleBlocksHighRiskUse == false ||
                riskClass.requiresStrictReview == false &&
                reviewIntervalDays >= 0
        case .stale, .staleCritical, .sourceChanged, .disputed, .revoked, .unknown:
            return false
        case .userProvided, .needsReview:
            return false
        }
    }
}

struct SourceAtlasRiskPolicy: Codable, Sendable, Equatable, Hashable {
    let strictReviewRiskClasses: [SourceAtlasRiskClass]

    static let conservative = SourceAtlasRiskPolicy(
        strictReviewRiskClasses: SourceAtlasRiskClass.allCases.filter(\.requiresStrictReview)
    )

    func allowsCurrentRecommendation(_ riskClass: SourceAtlasRiskClass) -> Bool {
        strictReviewRiskClasses.contains(riskClass) == false && riskClass.requiresStrictReview == false
    }
}

struct SourceAtlasDisclosureCopy: Codable, Sendable, Equatable, Hashable {
    let sourceNeeded: String
    let reviewRequired: String
    let notProfessionalAdvice: String
}

struct SourceAtlasRuntimeBoundary: Codable, Sendable, Equatable, Hashable {
    let storesUserData: Bool
    let performsNetworkFetches: Bool
    let mutatesPlans: Bool
    let writesPersistence: Bool

    static let valueModelOnly = SourceAtlasRuntimeBoundary(
        storesUserData: false,
        performsNetworkFetches: false,
        mutatesPlans: false,
        writesPersistence: false
    )

    var isValueModelOnly: Bool {
        storesUserData == false &&
            performsNetworkFetches == false &&
            mutatesPlans == false &&
            writesPersistence == false
    }
}

struct SourceAtlasCompositionContract: Codable, Sendable, Equatable, Hashable {
    let dependencyPackIDs: [String]
    let reusableNodeIDs: [String]
    let overlayDependencyIDs: [String]
    let projectionRecipeIDs: [String]
    let ownsIndividualGoalPhrase: Bool
    let requirementOverlays: [SourceAtlasRequirementOverlay]

    init(
        dependencyPackIDs: [String],
        reusableNodeIDs: [String],
        overlayDependencyIDs: [String],
        projectionRecipeIDs: [String],
        ownsIndividualGoalPhrase: Bool,
        requirementOverlays: [SourceAtlasRequirementOverlay] = []
    ) {
        self.dependencyPackIDs = dependencyPackIDs
        self.reusableNodeIDs = reusableNodeIDs
        self.overlayDependencyIDs = overlayDependencyIDs
        self.projectionRecipeIDs = projectionRecipeIDs
        self.ownsIndividualGoalPhrase = ownsIndividualGoalPhrase
        self.requirementOverlays = requirementOverlays
    }
}

struct SourceAtlasRequirementOverlay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceAtlasRequirementID: String
    let requirementIDs: [String]
    let summary: String
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState

    var isWellFormed: Bool {
        id.isEmpty == false &&
            sourceAtlasRequirementID.isEmpty == false &&
            summary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
    }
}

struct SourceAtlasGoalProjection: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let goalIntent: String
    let requiredPackIDs: [String]
    let projectionProfiles: [SourceAtlasProjectionProfile]

    init(
        id: String,
        goalIntent: String,
        requiredPackIDs: [String],
        projectionProfiles: [SourceAtlasProjectionProfile] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.goalIntent = goalIntent.trimmingCharacters(in: .whitespacesAndNewlines)
        self.requiredPackIDs = Self.orderedUnique(requiredPackIDs)
        self.projectionProfiles = projectionProfiles
    }

    var canDriveCurrentProjection: Bool {
        projectionProfiles.contains(where: { $0.canDriveCurrentProjection })
    }

    var hasProjectionReceipts: Bool {
        projectionProfiles.isEmpty == false &&
            projectionProfiles.allSatisfy(\.producesProjectionReceipt)
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasProjectionProfile: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let profileTitle: String
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let riskState: SourceAtlasRequirementRiskState
    let reviewState: SourceAtlasRequirementReviewState
    let producesPersonalPathInstance: Bool
    let producesProjectionReceipt: Bool
    let optionValueMap: SourceAtlasOptionValueMap
    let personalPathInstances: [SourceAtlasPersonalPathInstance]
    let alternativePathSet: SourceAtlasAlternativePathSet?

    init(
        id: String,
        profileTitle: String,
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        riskState: SourceAtlasRequirementRiskState,
        reviewState: SourceAtlasRequirementReviewState,
        producesPersonalPathInstance: Bool,
        producesProjectionReceipt: Bool,
        optionValueMap: SourceAtlasOptionValueMap,
        personalPathInstances: [SourceAtlasPersonalPathInstance] = [],
        alternativePathSet: SourceAtlasAlternativePathSet? = nil
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.profileTitle = profileTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.riskState = riskState
        self.reviewState = reviewState
        self.producesPersonalPathInstance = producesPersonalPathInstance
        self.producesProjectionReceipt = producesProjectionReceipt
        self.optionValueMap = optionValueMap
        self.personalPathInstances = personalPathInstances
        self.alternativePathSet = alternativePathSet
    }

    var canDriveCurrentProjection: Bool {
        sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false &&
            producesProjectionReceipt &&
            producesPersonalPathInstance &&
            optionValueMap.canDriveCurrentProjection &&
            personalPathInstances.contains(where: { $0.canDriveCurrentProjection }) &&
            alternativePathSet?.canDriveCurrentProjection != false
    }
}

struct SourceAtlasPersonalPathInstance: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let personalPathTemplateID: String
    let stepCandidateSeeds: [SourceAtlasStepCandidateSeed]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskState: SourceAtlasRequirementRiskState
    let sourceRecordIDs: [String]

    init(
        id: String,
        personalPathTemplateID: String,
        stepCandidateSeeds: [SourceAtlasStepCandidateSeed] = [],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskState: SourceAtlasRequirementRiskState,
        sourceRecordIDs: [String]
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.personalPathTemplateID = personalPathTemplateID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stepCandidateSeeds = stepCandidateSeeds
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.riskState = riskState
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    var canDriveCurrentProjection: Bool {
        sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false &&
            hasProvenanceEvidence
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasStepCandidateSeed: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let stepCandidate: String
    let storesFinalSchedule: Bool

    init(
        id: String,
        stepCandidate: String,
        storesFinalSchedule: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.stepCandidate = stepCandidate.trimmingCharacters(in: .whitespacesAndNewlines)
        self.storesFinalSchedule = storesFinalSchedule
    }
}

struct SourceAtlasAlternativePathSet: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let personalPathInstanceIDs: [String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskState: SourceAtlasRequirementRiskState

    init(
        id: String,
        personalPathInstanceIDs: [String],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskState: SourceAtlasRequirementRiskState
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.personalPathInstanceIDs = Self.orderedUnique(personalPathInstanceIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.riskState = riskState
    }

    var canDriveCurrentProjection: Bool {
        personalPathInstanceIDs.isEmpty == false &&
            sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false
    }

    static func orderedUnique(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasOptionValueMap: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let values: [String: String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskState: SourceAtlasRequirementRiskState

    init(
        id: String,
        values: [String: String],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskState: SourceAtlasRequirementRiskState
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.values = values
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.riskState = riskState
    }

    var canDriveCurrentProjection: Bool {
        sourceState.blocksCurrentProjection == false &&
            freshnessState.blocksCurrentProjection == false &&
            reviewState.blocksCurrentProjection == false &&
            riskState.blocksCurrentProjection == false
    }
}
