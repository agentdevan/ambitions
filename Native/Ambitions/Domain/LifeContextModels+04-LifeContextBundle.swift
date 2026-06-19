import Foundation

extension LifeContextBundle {
    enum CodingKeys: String, CodingKey {
        case id
        case profile
        case eligibilityPathways
        case opportunityContexts
        case historicalFacts
        case sources
        case futureProofContextCandidates
        case createdAt
        case updatedAt
        case deletedAt
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.profile = try container.decode(LifeContextProfile.self, forKey: .profile)
        self.eligibilityPathways = try container.decodeIfPresent([LifeContextEligibilityPathway].self, forKey: .eligibilityPathways) ?? []
        self.opportunityContexts = try container.decodeIfPresent([OpportunityContext].self, forKey: .opportunityContexts) ?? []
        self.historicalFacts = try container.decodeIfPresent([HistoricalContextFact].self, forKey: .historicalFacts) ?? []
        self.sources = try container.decodeIfPresent([LifeContextSource].self, forKey: .sources) ?? []
        self.futureProofContextCandidates = try container.decodeIfPresent([FutureProofContextCandidate].self, forKey: .futureProofContextCandidates) ?? []
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
        self.deletedAt = try container.decodeIfPresent(String.self, forKey: .deletedAt)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(profile, forKey: .profile)
        try container.encode(eligibilityPathways, forKey: .eligibilityPathways)
        try container.encode(opportunityContexts, forKey: .opportunityContexts)
        try container.encode(historicalFacts, forKey: .historicalFacts)
        try container.encode(sources, forKey: .sources)
        try container.encode(futureProofContextCandidates, forKey: .futureProofContextCandidates)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}

extension LifeContextBudgetConstraintBand {
    var displayLabelIfMeaningful: String? {
        switch self {
        case .unknown:
            return nil
        case .tight:
            return "Tight"
        case .moderate:
            return "Moderate"
        case .flexible:
            return "Flexible"
        case .custom:
            return "Custom"
        }
    }
}

extension LifeContextEnergyPattern {
    var displayLabelIfMeaningful: String? {
        switch self {
        case .unknown:
            return nil
        case .morning:
            return "Morning"
        case .midday:
            return "Midday"
        case .evening:
            return "Evening"
        case .variable:
            return "Variable"
        }
    }
}
