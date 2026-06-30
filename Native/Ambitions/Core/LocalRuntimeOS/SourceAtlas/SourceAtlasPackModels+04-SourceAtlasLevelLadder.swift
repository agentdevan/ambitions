import Foundation

struct SourceAtlasLevelLadder: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let capabilityGraphID: String
    let pathOverlays: [SourceAtlasPathOverlay]
    let levelLabels: [String]

    init(
        id: String,
        title: String,
        capabilityGraphID: String,
        pathOverlays: [SourceAtlasPathOverlay],
        levelLabels: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.pathOverlays = pathOverlays
        self.levelLabels = Self.orderedUnique(levelLabels)
    }

    func canReusePathOverlay(_ pathID: String) -> Bool {
        pathOverlays.contains { $0.id == pathID }
    }

    func highestReusablePathID(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy = .conservativeFreshness,
        riskPolicy: SourceAtlasRiskPolicy = .conservative
    ) -> String? {
        bestReusablePath(
            for: skillSliceID,
            roleID: roleID,
            using: freshnessPolicy,
            riskPolicy: riskPolicy
        )?.id
    }

    func bestReusablePath(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> SourceAtlasPathOverlay? {
        reusablePaths(for: skillSliceID, roleID: roleID, using: freshnessPolicy, riskPolicy: riskPolicy)
            .max {
                if $0.pathPriority != $1.pathPriority {
                    return $0.pathPriority < $1.pathPriority
                }
                let lhsSpecificity = $0.specificityScore(for: skillSliceID, roleID: roleID)
                let rhsSpecificity = $1.specificityScore(for: skillSliceID, roleID: roleID)
                if lhsSpecificity != rhsSpecificity {
                    return lhsSpecificity < rhsSpecificity
                }
                return $0.id < $1.id
            }
    }

    func reusablePaths(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> [SourceAtlasPathOverlay] {
        pathOverlays.filter {
            $0.canDriveCurrentProjection(
                for: skillSliceID,
                roleID: roleID,
                using: freshnessPolicy,
                riskPolicy: riskPolicy
            )
        }
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

struct SourceAtlasCapabilityNode: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let capabilityGraphID: String
    let title: String
    let summary: String
    let sourceRecordIDs: [String]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool
    let linkedClaimIDs: [String]

    init(
        id: String,
        capabilityGraphID: String,
        title: String,
        summary: String,
        sourceRecordIDs: [String] = [],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false,
        linkedClaimIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.summary = summary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
        self.linkedClaimIDs = Self.orderedUnique(linkedClaimIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    func canDriveCurrentProjection(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
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

struct SourceAtlasCapabilityEdge: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let capabilityGraphID: String
    let sourceNodeID: String
    let targetNodeID: String
    let kind: SourceAtlasCapabilityEdgeKind
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool
    let roleOverlayIDs: [String]
    let pathOverlayIDs: [String]
    let sourceRecordIDs: [String]

    init(
        id: String,
        capabilityGraphID: String,
        sourceNodeID: String,
        targetNodeID: String,
        kind: SourceAtlasCapabilityEdgeKind,
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false,
        roleOverlayIDs: [String] = [],
        pathOverlayIDs: [String] = [],
        sourceRecordIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityGraphID = capabilityGraphID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceNodeID = sourceNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.targetNodeID = targetNodeID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.kind = kind
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
        self.roleOverlayIDs = Self.orderedUnique(roleOverlayIDs)
        self.pathOverlayIDs = Self.orderedUnique(pathOverlayIDs)
        self.sourceRecordIDs = Self.orderedUnique(sourceRecordIDs)
    }

    var hasProvenanceEvidence: Bool {
        sourceRecordIDs.isEmpty == false
    }

    func canTraverse(
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
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

struct SourceAtlasCapabilityGraph: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let domainPackID: String
    let capabilityNodeIDs: [String]
    let capabilityEdgeIDs: [String]
    let levelLadderIDs: [String]
    let roleOverlayIDs: [String]
    let nodes: [SourceAtlasCapabilityNode]
    let edges: [SourceAtlasCapabilityEdge]
    let ladders: [SourceAtlasLevelLadder]
    let roleOverlays: [SourceAtlasRoleOverlay]
    let state: SourceAtlasClaimState
    let freshness: SourceAtlasFreshnessState
    let riskClass: SourceAtlasRiskClass
    let reviewRequired: Bool

    init(
        id: String,
        title: String,
        domainPackID: String,
        capabilityNodeIDs: [String],
        capabilityEdgeIDs: [String],
        levelLadderIDs: [String],
        roleOverlayIDs: [String],
        nodes: [SourceAtlasCapabilityNode],
        edges: [SourceAtlasCapabilityEdge],
        ladders: [SourceAtlasLevelLadder],
        roleOverlays: [SourceAtlasRoleOverlay],
        state: SourceAtlasClaimState,
        freshness: SourceAtlasFreshnessState,
        riskClass: SourceAtlasRiskClass,
        reviewRequired: Bool = false
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.domainPackID = domainPackID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capabilityNodeIDs = Self.orderedUnique(capabilityNodeIDs)
        self.capabilityEdgeIDs = Self.orderedUnique(capabilityEdgeIDs)
        self.levelLadderIDs = Self.orderedUnique(levelLadderIDs)
        self.roleOverlayIDs = Self.orderedUnique(roleOverlayIDs)
        self.nodes = nodes
        self.edges = edges
        self.ladders = ladders
        self.roleOverlays = roleOverlays
        self.state = state
        self.freshness = freshness
        self.riskClass = riskClass
        self.reviewRequired = reviewRequired
    }

    var hasProvenanceEvidence: Bool {
        nodes.contains(where: { $0.hasProvenanceEvidence }) ||
        edges.contains(where: { $0.hasProvenanceEvidence })
    }

    func highestReusablePathID(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy = .conservativeFreshness,
        riskPolicy: SourceAtlasRiskPolicy = .conservative
    ) -> String? {
        bestReusablePath(
            for: skillSliceID,
            roleID: roleID,
            using: freshnessPolicy,
            riskPolicy: riskPolicy
        )?.id
    }

    func bestReusablePath(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> SourceAtlasPathOverlay? {
        ladders
            .flatMap { $0.reusablePaths(for: skillSliceID, roleID: roleID, using: freshnessPolicy, riskPolicy: riskPolicy) }
            .max {
                if $0.pathPriority != $1.pathPriority {
                    return $0.pathPriority < $1.pathPriority
                }
                let lhsSpecificity = $0.specificityScore(for: skillSliceID, roleID: roleID)
                let rhsSpecificity = $1.specificityScore(for: skillSliceID, roleID: roleID)
                if lhsSpecificity != rhsSpecificity {
                    return lhsSpecificity < rhsSpecificity
                }
                return $0.id < $1.id
            }
    }

    func canDriveCurrentProjection(
        for skillSliceID: String,
        roleID: String? = nil,
        using freshnessPolicy: SourceAtlasFreshnessPolicy,
        riskPolicy: SourceAtlasRiskPolicy
    ) -> Bool {
        bestReusablePath(for: skillSliceID, roleID: roleID, using: freshnessPolicy, riskPolicy: riskPolicy) != nil &&
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
