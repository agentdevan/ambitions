import Foundation

extension GoalResourceEntity {
    func providerIDs(
        for resource: GoalResourceEntity? = nil,
        knowledgeClaimsByID: [String: KnowledgeClaim],
        knowledgeSourcesByID: [String: KnowledgeSourceRecord]
    ) -> [String] {
        let entity = resource ?? self
        let sourceProviders = entity.sourceRecordIDs.compactMap { knowledgeSourcesByID[$0]?.providerID }
        let claimProviders = entity.claimIDs.compactMap { knowledgeClaimsByID[$0]?.providerID }
        return Array(Set(sourceProviders + claimProviders)).sorted()
    }

    func providerArtifactRefs(
        requirementID: String,
        candidateID: String,
        stageID: String?,
        knowledgeClaimsByID: [String: KnowledgeClaim],
        knowledgeSourcesByID: [String: KnowledgeSourceRecord],
        providerStatusesByID: [String: KnowledgeProviderStatus]
    ) -> [GoalContradictionArtifactRef] {
        var refs: [GoalContradictionArtifactRef] = [
            .init(kind: .compiledPathRequirement, id: requirementID, candidateID: candidateID, stageID: stageID),
            .init(kind: .resource, id: id, candidateID: candidateID, stageID: targetStageID)
        ]

        refs.append(contentsOf: providerIDs(
            knowledgeClaimsByID: knowledgeClaimsByID,
            knowledgeSourcesByID: knowledgeSourcesByID
        ).compactMap { providerID in
            guard providerStatusesByID[providerID] != nil else { return nil }
            return GoalContradictionArtifactRef(kind: .knowledgeProvider, id: providerID, candidateID: candidateID, stageID: stageID)
        })

        return refs
    }
}
