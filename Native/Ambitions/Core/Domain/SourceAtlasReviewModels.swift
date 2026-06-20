import Foundation

enum SourceAtlasReviewDisplayToken: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case sourceNeeded = "sourceNeeded"
    case stale = "stale"
    case unknown = "unknown"
    case contradicted = "contradicted"
    case revoked = "revoked"
    case locallyProven = "locallyProven"
    case provenanceMissing = "provenanceMissing"
    case currentUseBlocked = "currentUseBlocked"
    case officialCurrentClaimsBlocked = "officialCurrentClaimsBlocked"
    case requiresHumanReview = "requiresHumanReview"
}

struct SourceAtlasClaimReviewDrawerState: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let claimID: String
    let claimText: String
    let sourceIDs: [String]
    let provenanceSourceIDs: [String]
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskClass: SourceAtlasRiskClass?
    let fallbackReason: SourceAtlasQueryFallbackReason
    let blocksOfficialCurrentClaims: Bool
    let blocksCurrentUse: Bool
    let requiresHumanReview: Bool
    let displayTokens: [SourceAtlasReviewDisplayToken]

    var copyTokens: [String] {
        displayTokens.map(\.rawValue)
    }

    init(
        claim: SourceAtlasClaim,
        provenanceSourceIDs: [String],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskClass: SourceAtlasRiskClass?,
        fallbackReason: SourceAtlasQueryFallbackReason,
        blocksOfficialCurrentClaims: Bool,
        blocksCurrentUse: Bool,
        requiresHumanReview: Bool
    ) {
        self.id = claim.id
        self.claimID = claim.id
        self.claimText = claim.text
        self.sourceIDs = Self.orderedUnique(claim.sourceIDs)
        self.provenanceSourceIDs = Self.orderedUnique(provenanceSourceIDs)
        self.sourceState = sourceState
        self.freshnessState = freshnessState
        self.reviewState = reviewState
        self.riskClass = riskClass
        self.fallbackReason = fallbackReason
        self.blocksOfficialCurrentClaims = blocksOfficialCurrentClaims
        self.blocksCurrentUse = blocksCurrentUse
        self.requiresHumanReview = requiresHumanReview

        let tokens = Self.displayTokens(
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            fallbackReason: fallbackReason,
            provenanceSourceIDs: self.provenanceSourceIDs,
            blocksOfficialCurrentClaims: blocksOfficialCurrentClaims,
            blocksCurrentUse: blocksCurrentUse,
            requiresHumanReview: requiresHumanReview
        )
        self.displayTokens = tokens
    }

    private static func displayTokens(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        fallbackReason: SourceAtlasQueryFallbackReason,
        provenanceSourceIDs: [String],
        blocksOfficialCurrentClaims: Bool,
        blocksCurrentUse: Bool,
        requiresHumanReview: Bool
    ) -> [SourceAtlasReviewDisplayToken] {
        var tokens: [SourceAtlasReviewDisplayToken] = []

        if let token = sourceState.reviewDisplayToken {
            tokens.append(token)
        }
        if let token = freshnessState.reviewDisplayToken {
            tokens.append(token)
        }
        if reviewState.blocksCurrentProjection {
            tokens.append(.requiresHumanReview)
        }
        if fallbackReason == .provenanceMissing || provenanceSourceIDs.isEmpty {
            tokens.append(.provenanceMissing)
        }
        if blocksCurrentUse {
            tokens.append(.currentUseBlocked)
        }
        if blocksOfficialCurrentClaims {
            tokens.append(.officialCurrentClaimsBlocked)
        }
        if requiresHumanReview {
            tokens.append(.requiresHumanReview)
        }

        return Self.orderedUnique(tokens)
    }

    private static func orderedUnique(_ tokens: [SourceAtlasReviewDisplayToken]) -> [SourceAtlasReviewDisplayToken] {
        var seen: Set<SourceAtlasReviewDisplayToken> = []
        return tokens.filter { seen.insert($0).inserted }
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

struct SourceAtlasReviewSheetSummary: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let queryResult: SourceAtlasQueryResult
    let sourceRecord: SourceAtlasSourceRecord?
    let claim: SourceAtlasClaim?
    let requirement: SourceAtlasRequirement?
    let sourceRecordID: String?
    let claimID: String?
    let requirementID: String?
    let sourceState: SourceAtlasRequirementSourceState
    let freshnessState: SourceAtlasRequirementFreshnessState
    let reviewState: SourceAtlasRequirementReviewState
    let riskClass: SourceAtlasRiskClass?
    let fallbackReason: SourceAtlasQueryFallbackReason
    let provenanceSourceIDs: [String]
    let proofEntryIDs: [String]
    let blocksOfficialCurrentClaims: Bool
    let blocksCurrentUse: Bool
    let requiresHumanReview: Bool
    let displayTokens: [SourceAtlasReviewDisplayToken]
    let claimDrawerState: SourceAtlasClaimReviewDrawerState?

    var copyTokens: [String] {
        displayTokens.map(\.rawValue)
    }

    init(
        queryResult: SourceAtlasQueryResult,
        sourceRecord: SourceAtlasSourceRecord? = nil,
        claim: SourceAtlasClaim? = nil,
        requirement: SourceAtlasRequirement? = nil
    ) {
        self.id = queryResult.id
        self.queryResult = queryResult
        self.sourceRecord = sourceRecord
        self.claim = claim
        self.requirement = requirement
        self.sourceRecordID = sourceRecord?.id
        self.claimID = claim?.id ?? queryResult.claimID
        self.requirementID = requirement?.id ?? queryResult.requirementID
        self.sourceState = queryResult.sourceState
        self.freshnessState = queryResult.freshnessState
        self.reviewState = queryResult.reviewState
        self.riskClass = queryResult.riskClass
        self.fallbackReason = queryResult.fallbackReason ?? .none
        self.provenanceSourceIDs = Self.orderedUnique(queryResult.provenanceSourceIDs)
        self.proofEntryIDs = Self.orderedUnique(queryResult.proofEntryIDs)

        let blocksOfficialCurrentClaims = Self.blocksOfficialCurrentClaims(
            queryResult: queryResult,
            sourceRecord: sourceRecord,
            claim: claim,
            requirement: requirement
        )
        let blocksCurrentUse = Self.blocksCurrentUse(
            queryResult: queryResult,
            claim: claim,
            requirement: requirement
        )
        let requiresHumanReview = Self.requiresHumanReview(
            queryResult: queryResult,
            sourceRecord: sourceRecord,
            claim: claim,
            requirement: requirement,
            blocksOfficialCurrentClaims: blocksOfficialCurrentClaims,
            blocksCurrentUse: blocksCurrentUse
        )

        self.blocksOfficialCurrentClaims = blocksOfficialCurrentClaims
        self.blocksCurrentUse = blocksCurrentUse
        self.requiresHumanReview = requiresHumanReview
        self.displayTokens = Self.displayTokens(
            sourceState: queryResult.sourceState,
            freshnessState: queryResult.freshnessState,
            reviewState: queryResult.reviewState,
            fallbackReason: queryResult.fallbackReason ?? .none,
            provenanceSourceIDs: self.provenanceSourceIDs,
            blocksOfficialCurrentClaims: blocksOfficialCurrentClaims,
            blocksCurrentUse: blocksCurrentUse,
            requiresHumanReview: requiresHumanReview
        )

        self.claimDrawerState = Self.guardClaimDrawer(
            claim: claim,
            provenanceSourceIDs: self.provenanceSourceIDs,
            sourceState: queryResult.sourceState,
            freshnessState: queryResult.freshnessState,
            reviewState: queryResult.reviewState,
            riskClass: queryResult.riskClass,
            fallbackReason: queryResult.fallbackReason ?? .none,
            blocksOfficialCurrentClaims: blocksOfficialCurrentClaims,
            blocksCurrentUse: blocksCurrentUse,
            requiresHumanReview: requiresHumanReview
        )
    }

    var claimText: String? {
        claim?.text
    }

    private static func guardClaimDrawer(
        claim: SourceAtlasClaim?,
        provenanceSourceIDs: [String],
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        riskClass: SourceAtlasRiskClass?,
        fallbackReason: SourceAtlasQueryFallbackReason,
        blocksOfficialCurrentClaims: Bool,
        blocksCurrentUse: Bool,
        requiresHumanReview: Bool
    ) -> SourceAtlasClaimReviewDrawerState? {
        guard let claim else {
            return nil
        }

        return SourceAtlasClaimReviewDrawerState(
            claim: claim,
            provenanceSourceIDs: provenanceSourceIDs,
            sourceState: sourceState,
            freshnessState: freshnessState,
            reviewState: reviewState,
            riskClass: riskClass,
            fallbackReason: fallbackReason,
            blocksOfficialCurrentClaims: blocksOfficialCurrentClaims,
            blocksCurrentUse: blocksCurrentUse,
            requiresHumanReview: requiresHumanReview
        )
    }

    private static func blocksOfficialCurrentClaims(
        queryResult: SourceAtlasQueryResult,
        sourceRecord: SourceAtlasSourceRecord?,
        claim: SourceAtlasClaim?,
        requirement: SourceAtlasRequirement?
    ) -> Bool {
        guard queryResult.canSupportCurrentUse else {
            return true
        }
        if queryResult.sourceState.blocksCurrentProjection {
            return true
        }
        if queryResult.sourceState == .locallyProven {
            return true
        }
        guard sourceRecord?.approvedForOfficialClaims == true else {
            return true
        }
        guard let claim else {
            return true
        }
        guard claim.state == .official else {
            return true
        }
        guard claim.canDriveCurrentRecommendation else {
            return true
        }
        guard let requirement else {
            return true
        }
        return requirement.canDriveCurrentRecommendation == false
    }

    private static func blocksCurrentUse(
        queryResult: SourceAtlasQueryResult,
        claim: SourceAtlasClaim?,
        requirement: SourceAtlasRequirement?
    ) -> Bool {
        if queryResult.canSupportCurrentUse == false {
            return true
        }
        if queryResult.sourceState.blocksCurrentProjection {
            return true
        }
        if queryResult.reviewState.blocksCurrentProjection {
            return true
        }
        if claim?.reviewRequired == true {
            return true
        }
        if requirement?.sourceState.blocksCurrentProjection == true {
            return true
        }
        if requirement?.freshnessState.blocksCurrentProjection == true {
            return true
        }
        if requirement?.reviewState.blocksCurrentProjection == true {
            return true
        }
        return false
    }

    private static func requiresHumanReview(
        queryResult: SourceAtlasQueryResult,
        sourceRecord: SourceAtlasSourceRecord?,
        claim: SourceAtlasClaim?,
        requirement: SourceAtlasRequirement?,
        blocksOfficialCurrentClaims: Bool,
        blocksCurrentUse: Bool
    ) -> Bool {
        if blocksOfficialCurrentClaims || blocksCurrentUse {
            return true
        }
        if sourceRecord?.approvedForOfficialClaims != true {
            return true
        }
        if claim?.reviewRequired == true {
            return true
        }
        if requirement?.reviewState.blocksCurrentProjection == true {
            return true
        }
        if queryResult.fallbackReason != nil {
            return true
        }
        return false
    }

    private static func displayTokens(
        sourceState: SourceAtlasRequirementSourceState,
        freshnessState: SourceAtlasRequirementFreshnessState,
        reviewState: SourceAtlasRequirementReviewState,
        fallbackReason: SourceAtlasQueryFallbackReason,
        provenanceSourceIDs: [String],
        blocksOfficialCurrentClaims: Bool,
        blocksCurrentUse: Bool,
        requiresHumanReview: Bool
    ) -> [SourceAtlasReviewDisplayToken] {
        var tokens: [SourceAtlasReviewDisplayToken] = []

        if let token = sourceState.reviewDisplayToken {
            tokens.append(token)
        }
        if let token = freshnessState.reviewDisplayToken {
            tokens.append(token)
        }
        if reviewState.blocksCurrentProjection {
            tokens.append(.requiresHumanReview)
        }
        if fallbackReason == .provenanceMissing || provenanceSourceIDs.isEmpty {
            tokens.append(.provenanceMissing)
        }
        if blocksCurrentUse {
            tokens.append(.currentUseBlocked)
        }
        if blocksOfficialCurrentClaims {
            tokens.append(.officialCurrentClaimsBlocked)
        }
        if requiresHumanReview {
            tokens.append(.requiresHumanReview)
        }

        return orderedUnique(tokens)
    }

    private static func orderedUnique(_ tokens: [SourceAtlasReviewDisplayToken]) -> [SourceAtlasReviewDisplayToken] {
        var seen: Set<SourceAtlasReviewDisplayToken> = []
        return tokens.filter { seen.insert($0).inserted }
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

private extension SourceAtlasRequirementSourceState {
    var reviewDisplayToken: SourceAtlasReviewDisplayToken? {
        switch self {
        case .sourceNeeded:
            return .sourceNeeded
        case .stale:
            return .stale
        case .unknown:
            return .unknown
        case .contradicted:
            return .contradicted
        case .revoked:
            return .revoked
        case .locallyProven:
            return .locallyProven
        case .official, .officialCurrent, .current:
            return nil
        }
    }
}

private extension SourceAtlasRequirementFreshnessState {
    var reviewDisplayToken: SourceAtlasReviewDisplayToken? {
        switch self {
        case .stale:
            return .stale
        case .unknown:
            return .unknown
        case .current:
            return nil
        }
    }
}
