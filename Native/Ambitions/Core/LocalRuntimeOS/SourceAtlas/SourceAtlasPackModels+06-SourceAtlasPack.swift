import Foundation

struct SourceAtlasPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    var id: String { manifest.id }

    let manifest: SourceAtlasPackManifest
    let sources: [SourceAtlasSourceRecord]
    let claims: [SourceAtlasClaim]
    let requirements: [SourceAtlasRequirement]
    let starterItems: [SourceAtlasStarterItem]
    let proofMap: [SourceAtlasProofMapEntry]
    let projections: [SourceAtlasGoalProjection]
    let freshnessPolicy: SourceAtlasFreshnessPolicy
    let riskPolicy: SourceAtlasRiskPolicy
    let disclosureCopy: SourceAtlasDisclosureCopy
    let runtimeBoundary: SourceAtlasRuntimeBoundary
    let composition: SourceAtlasCompositionContract
    let domainPacks: [SourceAtlasDomainPack]
    let specificDomainPacks: [SourceAtlasSpecificDomainPack]
    let capabilityGraphs: [SourceAtlasCapabilityGraph]

    init(
        manifest: SourceAtlasPackManifest,
        sources: [SourceAtlasSourceRecord],
        claims: [SourceAtlasClaim],
        requirements: [SourceAtlasRequirement],
        starterItems: [SourceAtlasStarterItem],
        proofMap: [SourceAtlasProofMapEntry],
        projections: [SourceAtlasGoalProjection],
        freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy,
        disclosureCopy: SourceAtlasDisclosureCopy,
        runtimeBoundary: SourceAtlasRuntimeBoundary,
        composition: SourceAtlasCompositionContract,
        domainPacks: [SourceAtlasDomainPack] = [],
        specificDomainPacks: [SourceAtlasSpecificDomainPack] = [],
        capabilityGraphs: [SourceAtlasCapabilityGraph] = []
    ) {
        self.manifest = manifest
        self.sources = sources
        self.claims = claims
        self.requirements = requirements
        self.starterItems = starterItems
        self.proofMap = proofMap
        self.projections = projections
        self.freshnessPolicy = freshnessPolicy
        self.riskPolicy = riskPolicy
        self.disclosureCopy = disclosureCopy
        self.runtimeBoundary = runtimeBoundary
        self.composition = composition
        self.domainPacks = domainPacks
        self.specificDomainPacks = specificDomainPacks
        self.capabilityGraphs = capabilityGraphs
    }

    var validationIssues: [SourceAtlasValidationIssue] {
        SourceAtlasPackValidator().validate(self)
    }

    var isValidForRuntimeUse: Bool {
        validationIssues.isEmpty
    }

    func validatedForUse() throws -> SourceAtlasPack {
        try SourceAtlasPackValidator().validated(self)
    }
}

struct SourceAtlasPackValidator: Sendable, Equatable, Hashable {
    struct ValidationError: Error, Equatable {
        let issues: [SourceAtlasValidationIssue]
    }

    func validate(_ pack: SourceAtlasPack) -> [SourceAtlasValidationIssue] {
        var issues: Set<SourceAtlasValidationIssue> = []

        if pack.manifest.schemaVersion != sourceAtlasPackSchemaVersion {
            issues.insert(.unsupportedSchema)
        }
        if pack.manifest.id.isEmpty || pack.manifest.title.isEmpty || pack.manifest.domainID.isEmpty {
            issues.insert(.missingManifestIdentity)
        }
        if pack.manifest.canonDocumentIDs.contains("docs/codex/SOURCE_ATLAS_GATE_MATRIX.md") == false ||
            pack.manifest.canonDocumentIDs.contains("docs/codex/SOURCE_ATLAS_COMPOSITION_GOAL_PROJECTION_MODEL.md") == false {
            issues.insert(.missingCanonIntegration)
        }
        if pack.composition.reusableNodeIDs.isEmpty || pack.composition.projectionRecipeIDs.isEmpty {
            issues.insert(.missingCompositionContract)
        }
        if pack.composition.ownsIndividualGoalPhrase {
            issues.insert(.onePackPerGoalRisk)
        }
        if pack.runtimeBoundary.isValueModelOnly == false {
            issues.insert(.runtimeStoreBehavior)
        }

        let approvedSourceIDs = Set(
            pack.sources
                .filter { $0.approvedForOfficialClaims && $0.kind == .official }
                .map(\.id)
        )

        for claim in pack.claims {
            if claim.state == .official && approvedSourceIDs.isDisjoint(with: claim.sourceIDs) {
                issues.insert(.officialClaimWithoutApprovedSource)
            }
            if claim.riskClass.requiresStrictReview && claim.reviewRequired == false {
                issues.insert(.highRiskClaimWithoutReview)
            }
        }

        let requirementIDs = Set(pack.requirements.map(\.id))
        let claimsByID = Dictionary(uniqueKeysWithValues: pack.claims.map { ($0.id, $0) })
        let requirementsByID = Dictionary(uniqueKeysWithValues: pack.requirements.map { ($0.id, $0) })
        var requirementSupportsCurrentProof: [String: Bool] = [:]
        var requirementHasProofEntries: [String: Bool] = [:]

        for entry in pack.proofMap {
            if entry.requirementID.isEmpty || requirementsByID[entry.requirementID] == nil {
                issues.insert(.proofCannotSupportCurrentRequirement)
                continue
            }
            if entry.capabilityNodeID == "" {
                issues.insert(.invalidRequirementOverlay)
            }
            if entry.proofStrength == .officialCertified && entry.isSourceProofEligible == false {
                issues.insert(.proofRequiresSourceOrClaimBinding)
            }
            if entry.privacyClass == .sensitive && entry.isExternalProjectionSafe == false {
                issues.insert(.sensitiveProofProjectionRisk)
            }
            if entry.proofCandidate == .correctionArtifact && entry.correctionHookIDs.isEmpty {
                issues.insert(.invalidRequirementOverlay)
            }
            if entry.proofCandidate == .revocationArtifact && entry.revocationHookIDs.isEmpty {
                issues.insert(.invalidRequirementOverlay)
            }
            if let requirement = requirementsByID[entry.requirementID],
               requirement.canDriveCurrentRecommendation,
               entry.canSupportCurrentRequirement(claimsByID) == false {
                issues.insert(.proofCannotSupportCurrentRequirement)
            }
            if entry.canSupportCurrentRequirement(claimsByID) {
                requirementSupportsCurrentProof[entry.requirementID] = true
            }
            requirementHasProofEntries[entry.requirementID] = true
        }

        for requirement in pack.requirements {
            guard let claim = claimsByID[requirement.claimID] else {
                issues.insert(.invalidRequirementOverlay)
                continue
            }
            if requirement.canDriveCurrentRecommendation && claim.canDriveCurrentRecommendation == false {
                issues.insert(.invalidRequirementOverlay)
            }
            if [
                .unknown, .sourceNeeded, .stale, .contradicted, .revoked, .locallyProven
            ].contains(requirement.sourceState) {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.freshnessState == .stale || requirement.freshnessState == .unknown {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.reviewState == .required || requirement.reviewState == .blocked || requirement.reviewState == .requested {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.riskState == .unknown || requirement.riskState == .high {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirement.canDriveCurrentRecommendation && (requirementHasProofEntries[requirement.id] == false ||
                requirementSupportsCurrentProof[requirement.id] == false) {
                issues.insert(.proofCannotSupportCurrentRequirement)
            }
        }

        for overlay in pack.composition.requirementOverlays {
            if overlay.isWellFormed == false {
                issues.insert(.invalidRequirementOverlay)
            }
            if requirementIDs.contains(overlay.sourceAtlasRequirementID) == false {
                issues.insert(.invalidRequirementOverlay)
            }
            if overlay.requirementIDs.contains(where: { requirementIDs.contains($0) == false }) {
                issues.insert(.invalidRequirementOverlay)
            }
            if overlay.sourceState == .unknown || overlay.sourceState == .sourceNeeded || overlay.sourceState == .stale ||
                overlay.freshnessState == .stale || overlay.freshnessState == .unknown ||
                overlay.reviewState == .required || overlay.reviewState == .blocked || overlay.reviewState == .requested ||
                overlay.riskState == .unknown || overlay.riskState == .high {
                issues.insert(.invalidRequirementOverlay)
            }
        }

        if pack.starterItems.contains(where: \.storesFinalSchedule) {
            issues.insert(.universalScheduledStep)
        }

        for projection in pack.projections {
            if projection.projectionProfiles.isEmpty || projection.projectionProfiles.contains(where: { $0.personalPathInstances.isEmpty }) {
                issues.insert(.invalidRequirementOverlay)
            }
            if projection.hasProjectionReceipts == false {
                issues.insert(.projectionRecipeMissingReceipt)
            }
        }

        return issues.sorted { $0.rawValue < $1.rawValue }
    }

    func validated(_ pack: SourceAtlasPack) throws -> SourceAtlasPack {
        let issues = validate(pack)
        guard issues.isEmpty else {
            throw ValidationError(issues: issues)
        }
        return pack
    }
}

enum PlanSkeletonFeasibilityBand: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case comfortablyOnTrack = "comfortably_on_track"
    case onTrack = "on_track"
    case tightButPossible = "tight_but_possible"
    case atRisk = "at_risk"
    case unrealisticWithoutChangingScopeTimeCapacity = "unrealistic_without_changing_scope_time_capacity"
    case impossibleUnderCurrentConstraints = "impossible_under_current_constraints"

    var accessibilityLabel: String {
        switch self {
        case .comfortablyOnTrack:
            return "Comfortably on track"
        case .onTrack:
            return "On track"
        case .tightButPossible:
            return "Tight but possible"
        case .atRisk:
            return "At risk"
        case .unrealisticWithoutChangingScopeTimeCapacity:
            return "Unrealistic without changing scope, time, or capacity"
        case .impossibleUnderCurrentConstraints:
            return "Impossible under current constraints"
        }
    }
}

struct SourceAtlasRequirementProjection: Codable, Sendable, Equatable, Hashable {
    let requirementIDs: [String]
    let hardRequirements: [SourceAtlasRequirement]
    let softRequirements: [SourceAtlasRequirement]
    let prerequisites: [SourceAtlasRequirement]
    let equipment: [SourceAtlasRequirement]
    let skills: [SourceAtlasRequirement]
    let proofNeeds: [SourceAtlasRequirement]
    let blockers: [SourceAtlasRequirement]
    let accelerators: [SourceAtlasRequirement]
    let deadlineSensitiveItems: [SourceAtlasRequirement]
    let sourceFreshnessSummary: [LifeContextSourceFreshnessSummary]

    init(
        requirements: [SourceAtlasRequirement],
        sourceFreshnessSummary: [LifeContextSourceFreshnessSummary]
    ) {
        self.requirementIDs = Self.normalized(requirements.map(\.id))
        self.hardRequirements = Self.sorted(requirements.filter { $0.kind == .hard })
        self.softRequirements = Self.sorted(requirements.filter { $0.kind == .soft })
        self.prerequisites = Self.sorted(requirements.filter { $0.kind == .prerequisite })
        self.equipment = Self.sorted(requirements.filter { $0.kind == .equipment })
        self.skills = Self.sorted(requirements.filter { $0.kind == .skill })
        self.proofNeeds = Self.sorted(requirements.filter { $0.kind == .proof })
        self.blockers = Self.sorted(requirements.filter { $0.kind == .blocker || $0.sourceState.blocksCurrentProjection || $0.freshnessState.blocksCurrentProjection || $0.riskState.blocksCurrentProjection || $0.reviewState.blocksCurrentProjection })
        self.accelerators = Self.sorted(requirements.filter { $0.kind == .accelerator })
        self.deadlineSensitiveItems = Self.sorted(requirements.filter { $0.kind == .deadline })
        self.sourceFreshnessSummary = sourceFreshnessSummary.sorted { $0.id < $1.id }
    }

    var allRequirements: [SourceAtlasRequirement] {
        Self.sorted(hardRequirements + softRequirements + prerequisites + equipment + skills + proofNeeds + blockers + accelerators + deadlineSensitiveItems)
    }

    var hasBlockedItems: Bool {
        blockers.isEmpty == false
    }

    static func sorted(_ requirements: [SourceAtlasRequirement]) -> [SourceAtlasRequirement] {
        requirements.sorted { lhs, rhs in
            if lhs.kind.rawValue != rhs.kind.rawValue {
                return lhs.kind.rawValue < rhs.kind.rawValue
            }
            return lhs.id < rhs.id
        }
    }

    static func normalized(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct PlanSkeletonMilestone: Codable, Sendable, Equatable, Hashable, Identifiable {
    enum MilestoneKind: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
        case setup
        case access
        case execution
        case proof
        case review
        case recovery
    }

    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let kind: MilestoneKind
    let requirementIDs: [String]
    let nodeIDs: [String]
    let proofRequired: Bool
    let reviewRequired: Bool
}

struct PlanSkeletonPhase: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let milestoneIDs: [String]
    let pathNodeIDs: [String]
    let riskFlagIDs: [String]
}

struct PlanSkeletonWeeklyCadence: Codable, Sendable, Equatable, Hashable {
    let summary: String
    let anchorDays: [String]
    let proofTouchpoints: [String]
    let reviewTouchpoints: [String]
}

struct PlanSkeletonProofMoment: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let requirementIDs: [String]
    let nodeIDs: [String]
}

struct PlanSkeletonReviewMoment: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let requirementIDs: [String]
    let reason: String
}

struct PlanSkeletonRecoveryWindow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let detail: String
    let orderIndex: Int
    let protectsRecovery: Bool
    let relatedNodeIDs: [String]
}
