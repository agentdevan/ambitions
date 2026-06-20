import Foundation

struct SourceAtlasDomainPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let domainID: String
    let capabilityGraphIDs: [String]
    let specificDomainPackIDs: [String]
    let reusableNodeIDs: [String]
    let sourceSliceIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool

    init(
        id: String,
        title: String,
        domainID: String,
        capabilityGraphIDs: [String],
        specificDomainPackIDs: [String] = [],
        reusableNodeIDs: [String] = [],
        sourceSliceIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainID = domainID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphIDs = Self.orderedUnique(capabilityGraphIDs)
        self.specificDomainPackIDs = Self.orderedUnique(specificDomainPackIDs)
        self.reusableNodeIDs = Self.orderedUnique(reusableNodeIDs)
        self.sourceSliceIDs = Self.orderedUnique(sourceSliceIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        sourceSliceIDs.isEmpty == false
    }

    func supports(skillSliceID: String) -> Bool {
        sourceSliceIDs.isEmpty || sourceSliceIDs.contains(skillSliceID)
    }

    func canDriveCurrentProjection(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            state.isBlockingState == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass)
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

struct SourceAtlasSpecificDomainPack: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let domainPackID: String
    let capabilityGraphID: String
    let skillSliceIDs: [String]
    let roleOverlayIDs: [String]
    let pathOverlayIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool
    let sourceSliceIDs: [String]

    init(
        id: String,
        title: String,
        domainPackID: String,
        capabilityGraphID: String,
        skillSliceIDs: [String],
        roleOverlayIDs: [String] = [],
        pathOverlayIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false,
        sourceSliceIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainPackID = domainPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.skillSliceIDs = Self.orderedUnique(skillSliceIDs)
        self.roleOverlayIDs = Self.orderedUnique(roleOverlayIDs)
        self.pathOverlayIDs = Self.orderedUnique(pathOverlayIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
        self.sourceSliceIDs = Self.orderedUnique(sourceSliceIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceSliceIDs.isEmpty == false
    }

    func supports(skillSliceID: String) -> Bool {
        guard skillSliceIDs.isEmpty == false else {
            return false
        }
        return skillSliceIDs.contains(where: { supported in
            supported == skillSliceID ||
            skillSliceID.hasPrefix(supported + ".")
        })
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        supports(skillSliceID: skillSliceID) &&
            state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasRoleOverlay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let roleID: String
    let skillSliceID: String
    let reusableNodeIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let sourceIDs: [String]
    let reviewRequired: Bool

    init(
        id: String,
        roleID: String,
        skillSliceID: String,
        reusableNodeIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        sourceIDs: [String] = [],
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.roleID = roleID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.skillSliceID = skillSliceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reusableNodeIDs = Self.orderedUnique(reusableNodeIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.sourceIDs = Self.orderedUnique(sourceIDs)
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        sourceIDs.isEmpty == false
    }

    func supports(skillSliceID: String) -> Bool {
        skillSliceID == self.skillSliceID ||
            skillSliceID.hasPrefix(self.skillSliceID + ".")
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        supports(skillSliceID: skillSliceID) &&
            state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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

struct SourceAtlasPathOverlay: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let skillSliceID: String
    let capabilityNodeIDs: [String]
    let pathPriority: Int
    let roleID: String?
    let claimIDs: [String]
    let sourceRecordIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool

    init(
        id: String,
        title: String,
        skillSliceID: String,
        capabilityNodeIDs: [String] = [],
        pathPriority: Int,
        roleID: String? = nil,
        claimIDs: [String] = [],
        sourceRecordIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.skillSliceID = skillSliceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityNodeIDs = Self.orderedUnique(capabilityNodeIDs)
        self.pathPriority = pathPriority
        self.roleID = roleID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.claimIDs = Self.orderedUnique(claimIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    func matches(skillSliceID: String, roleID: String?) -> Bool {
        let supportsSkillSlice = skillSliceID.isEmpty == false ? (
            self.skillSliceID == skillSliceID ||
            skillSliceID.hasPrefix(self.skillSliceID + ".")
        ) : false

        let roleIsMatched = self.roleID == nil || self.roleID == roleID
        return supportsSkillSlice && roleIsMatched
    }

    func specificityScore(for skillSliceID: String, roleID: String? = nil) -> Int {
        guard matches(skillSliceID: skillSliceID, roleID: roleID) else {
            return -1
        }
        let requestedDepth = skillSliceID.split(separator: ".").count
        let overlayDepth = self.skillSliceID.split(separator: ".").count
        if self.skillSliceID == skillSliceID {
            return max(requestedDepth, overlayDepth) + 1
        }
        if skillSliceID.hasPrefix(self.skillSliceID + ".") {
            return overlayDepth
        }
        return -1
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        roleID: String?,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        matches(skillSliceID: skillSliceID, roleID: roleID) &&
            state == .official &&
            hasProvenanceEvidence &&
            reviewRequired == false &&
            freshnessPolicy.canSupportCurrentRecommendation(freshness: freshness, riskClass: riskClass) &&
            riskPolicy.allowsCurrentRecommendation(riskClass) &&
            state.isBlockingState == false
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
