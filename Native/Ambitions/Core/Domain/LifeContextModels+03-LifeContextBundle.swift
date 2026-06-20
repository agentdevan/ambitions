import Foundation

struct LifeContextBundle: Codable, Sendable, Equatable, Identifiable {
    let id: String
    let profile: LifeContextProfile
    let eligibilityPathways: [LifeContextEligibilityPathway]
    let opportunityContexts: [OpportunityContext]
    let historicalFacts: [HistoricalContextFact]
    let sources: [LifeContextSource]
    let futureProofContextCandidates: [FutureProofContextCandidate]
    let createdAt: String
    let updatedAt: String
    let deletedAt: String?

    init(
        id: String,
        profile: LifeContextProfile,
        eligibilityPathways: [LifeContextEligibilityPathway] = [],
        opportunityContexts: [OpportunityContext] = [],
        historicalFacts: [HistoricalContextFact] = [],
        sources: [LifeContextSource] = [],
        futureProofContextCandidates: [FutureProofContextCandidate] = [],
        createdAt: String,
        updatedAt: String,
        deletedAt: String? = nil
    ) {
        self.id = id
        self.profile = profile
        self.eligibilityPathways = eligibilityPathways
        self.opportunityContexts = opportunityContexts
        self.historicalFacts = historicalFacts
        self.sources = sources
        self.futureProofContextCandidates = futureProofContextCandidates
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
