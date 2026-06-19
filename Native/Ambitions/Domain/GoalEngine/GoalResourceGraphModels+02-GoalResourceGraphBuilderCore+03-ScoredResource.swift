import Foundation

extension GoalResourceGraphBuilderCore {

    struct ScoredResource {
        let resource: GoalResourceEntity
        let totalScore: Double
        let sourceTrustScore: Double
        let sourceFreshnessScore: Double
        let domainRelevanceScore: Double
        let stageRelevanceScore: Double
        let readinessRelevanceScore: Double
        let optionalityScore: Double
        let tieBreakKey: String
        let flags: [GoalResourceRankingFlag]
    }


    func scoredResource(from resource: GoalResourceEntity) -> ScoredResource {
        let sourceTrustScore = trustScore(for: resource.trustLevel)
        let sourceFreshnessScore = freshnessScore(for: resource.freshnessState)
        let domainRelevanceScore = resource.relatedDomains.isEmpty ? 0.05 : 0.12
        let stageRelevanceScore = stageScore(for: resource.targetStageID)
        let readinessRelevanceScore = readinessScore(resource: resource)
        let optionalityScore = resource.optionality == .required ? 0.09 : 0.04
        let flags = rankingFlags(for: resource)
        let totalScore = roundToFour(
            resolutionScore(for: resource.resolutionState) +
                sourceTrustScore +
                sourceFreshnessScore +
                domainRelevanceScore +
                stageRelevanceScore +
                readinessRelevanceScore +
                optionalityScore
        )
        return ScoredResource(
            resource: resource,
            totalScore: totalScore,
            sourceTrustScore: sourceTrustScore,
            sourceFreshnessScore: sourceFreshnessScore,
            domainRelevanceScore: domainRelevanceScore,
            stageRelevanceScore: stageRelevanceScore,
            readinessRelevanceScore: readinessRelevanceScore,
            optionalityScore: optionalityScore,
            tieBreakKey: resource.ranking.tieBreakKey,
            flags: flags
        )
    }


    func rankedResourceOrdering(lhs: ScoredResource, rhs: ScoredResource) -> Bool {
        if lhs.totalScore != rhs.totalScore {
            return lhs.totalScore > rhs.totalScore
        }
        if resolutionOrdering(lhs.resource.resolutionState) != resolutionOrdering(rhs.resource.resolutionState) {
            return resolutionOrdering(lhs.resource.resolutionState) < resolutionOrdering(rhs.resource.resolutionState)
        }
        if optionalityOrdering(lhs.resource.optionality) != optionalityOrdering(rhs.resource.optionality) {
            return optionalityOrdering(lhs.resource.optionality) < optionalityOrdering(rhs.resource.optionality)
        }
        if lhs.sourceTrustScore != rhs.sourceTrustScore {
            return lhs.sourceTrustScore > rhs.sourceTrustScore
        }
        if lhs.sourceFreshnessScore != rhs.sourceFreshnessScore {
            return lhs.sourceFreshnessScore > rhs.sourceFreshnessScore
        }
        if lhs.domainRelevanceScore != rhs.domainRelevanceScore {
            return lhs.domainRelevanceScore > rhs.domainRelevanceScore
        }
        if lhs.stageRelevanceScore != rhs.stageRelevanceScore {
            return lhs.stageRelevanceScore > rhs.stageRelevanceScore
        }
        if lhs.readinessRelevanceScore != rhs.readinessRelevanceScore {
            return lhs.readinessRelevanceScore > rhs.readinessRelevanceScore
        }
        return lhs.tieBreakKey < rhs.tieBreakKey
    }


    func resolutionOrdering(_ state: GoalResourceResolutionState) -> Int {
        switch state {
        case .concrete: return 0
        case .inferred: return 1
        case .placeholderOnly: return 2
        case .unresolved: return 3
        }
    }


    func optionalityOrdering(_ optionality: GoalCompiledPathResourceOptionality) -> Int {
        switch optionality {
        case .required: return 0
        case .optional: return 1
        }
    }


    func resolutionScore(for state: GoalResourceResolutionState) -> Double {
        switch state {
        case .concrete: return 0.30
        case .inferred: return 0.22
        case .placeholderOnly: return 0.12
        case .unresolved: return 0.08
        }
    }


    func trustScore(for level: KnowledgeTrustLevel?) -> Double {
        switch level {
        case .high: return 0.30
        case .medium: return 0.20
        case .low: return 0.10
        case .none: return 0
        }
    }


    func freshnessScore(for state: KnowledgeFreshnessState?) -> Double {
        switch state {
        case .fresh: return 0.20
        case .unknown: return 0.03
        case .stale: return 0.01
        case .expired: return 0
        case .none: return 0
        }
    }


    func stageScore(for stageID: String?) -> Double {
        guard let stageID else { return 0.04 }
        if stageID.contains("readiness") { return 0.12 }
        if stageID.contains("first_proof") { return 0.10 }
        if stageID.contains("advancement") { return 0.08 }
        if stageID.contains("review_finish") { return 0.06 }
        if stageID.contains("setup") { return 0.05 }
        return 0.04
    }


    func readinessScore(resource: GoalResourceEntity) -> Double {
        switch resource.hookKind {
        case .requirementReference:
            return resource.targetStageID?.contains("readiness") == true ? 0.12 : 0.09
        case .preparationMaterial:
            return resource.targetStageID?.contains("readiness") == true ? 0.08 : 0.07
        }
    }


    func rankingFlags(for resource: GoalResourceEntity) -> [GoalResourceRankingFlag] {
        var flags: [GoalResourceRankingFlag] = []
        if resource.resolutionState == .placeholderOnly {
            flags.append(.placeholderOnly)
        }
        if resource.missingResourceState != .none {
            flags.append(.missingConcreteResource)
        }
        if resource.optionality == .optional {
            flags.append(.optionalResource)
        }
        if resource.relatedDomains.isEmpty == false {
            flags.append(.domainAligned)
        }
        if resource.targetStageID != nil {
            flags.append(.stageAligned)
        }
        if resource.targetStageID?.contains("readiness") == true && resource.hookKind == .requirementReference {
            flags.append(.readinessAligned)
        }
        if resource.trustLevel == .low || resource.uncertaintyFlags.contains(.lowConfidence) {
            flags.append(.lowTrustSource)
        }
        if resource.freshnessState == .stale {
            flags.append(.staleSource)
        }
        if resource.freshnessState == .expired {
            flags.append(.expiredSource)
        }
        if resource.resolutionState == .inferred {
            flags.append(.inferredSource)
        }
        if resource.sourceRecordIDs.isEmpty == false && resource.uncertaintyFlags.contains(.inferred) {
            flags.append(.inferredSource)
        }
        if resource.sourceRecordIDs.isEmpty == false &&
            resource.resolutionState != .placeholderOnly &&
            resource.resolutionState != .unresolved &&
            resource.uncertaintyFlags.contains(.inferred) == false &&
            resource.trustLevel != nil {
            if resource.uncertaintyFlags.contains(.stale) == false && resource.trustLevel == .high {
                flags.append(.officialSource)
            }
        }
        return Array(Set(flags)).sorted { $0.rawValue < $1.rawValue }
    }


    func resourceOrdering(lhs: GoalResourceEntity, rhs: GoalResourceEntity) -> Bool {
        if lhs.candidateID != rhs.candidateID {
            return lhs.candidateID < rhs.candidateID
        }
        if lhs.selectionGroupID != rhs.selectionGroupID {
            return lhs.selectionGroupID < rhs.selectionGroupID
        }
        if lhs.ranking.rank != rhs.ranking.rank {
            return lhs.ranking.rank < rhs.ranking.rank
        }
        return lhs.id < rhs.id
    }


    func candidateOrdering(lhs: GoalCompiledPathCandidate, rhs: GoalCompiledPathCandidate) -> Bool {
        if lhs.isPrimary != rhs.isPrimary {
            return lhs.isPrimary && !rhs.isPrimary
        }
        return lhs.id < rhs.id
    }


    func resourceType(for hookKind: GoalCompiledPathResourceHookKind) -> GoalResourceType {
        switch hookKind {
        case .requirementReference:
            return .reference
        case .preparationMaterial:
            return .preparationMaterial
        }
    }


    func resourceRole(for hookKind: GoalCompiledPathResourceHookKind) -> GoalResourceRole {
        switch hookKind {
        case .requirementReference:
            return .requirementSupport
        case .preparationMaterial:
            return .preparationSupport
        }
    }


    func makeSelectionGroupID(candidateID: String, hook: GoalCompiledPathResourceHook) -> String {
        let stage = hook.targetStageID ?? "no-stage"
        return "selection-\(normalized(candidateID))-\(normalized(stage))-\(normalized(hook.id))"
    }


    func normalized(_ value: String) -> String {
        let lowered = value.lowercased()
        let scalars = lowered.unicodeScalars.map { scalar -> Character in
            CharacterSet.alphanumerics.contains(scalar) ? Character(scalar) : "-"
        }
        let collapsed = String(scalars)
            .replacingOccurrences(of: "-+", with: "-", options: .regularExpression)
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return collapsed
    }


    func roundToFour(_ value: Double) -> Double {
        (value * 10_000).rounded() / 10_000
    }
}
