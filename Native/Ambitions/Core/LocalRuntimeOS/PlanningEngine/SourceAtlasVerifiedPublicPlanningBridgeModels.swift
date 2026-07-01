import Foundation

let sourceAtlasVerifiedPublicPlanningBridgeSchemaVersion = "source_atlas_verified_public_planning_bridge.native.v1"

enum SourceAtlasVerifiedPublicPlanningBridgeIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case missingVerifiedPublicContext = "missing_verified_public_context"
    case publicContextRequestInvalid = "public_context_request_invalid"
    case publicContextEgressBlocked = "public_context_egress_blocked"
    case publicContextUnavailable = "public_context_unavailable"
    case localPlanningBlocked = "local_planning_blocked"
    case selectedPackMismatch = "selected_pack_mismatch"
    case selectedDomainMismatch = "selected_domain_mismatch"
    case ownershipBoundaryViolation = "ownership_boundary_violation"
}

struct SourceAtlasVerifiedPublicShardInfluence: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let publicPlanningContextID: String
    let selectedPackID: String
    let selectedPackDomainID: String
    let manifestVersionID: String?
    let useMode: SourceAtlasPublicPlanningContextUseMode
    let sourceIDs: [String]
    let claimIDs: [String]
    let requirementIDs: [String]
    let proofNeedIDs: [String]
    let starterActionIDs: [String]
    let caveatIDs: [String]
    let riskMetadataIDs: [String]
    let privateRuntimeOwnsPersonalization: Bool
    let privateRuntimeOwnsPathing: Bool
    let privateRuntimeOwnsScheduling: Bool
    let privateRuntimeOwnsReceipts: Bool
    let sourceAtlasCreatesFinalSteps: Bool
    let sourceAtlasCreatesUserSchedule: Bool
    let sourceAtlasStoresRuntimeState: Bool

    init(context: SourceAtlasPublicPlanningContext) {
        let sourceIDs = Self.normalized(context.sourceIDs)
        let claimIDs = Self.normalized(context.claimIDs)
        let requirementIDs = Self.normalized(context.requirements.map(\.id))
        let proofNeedIDs = Self.normalized(context.proofNeeds.map(\.id))
        let starterActionIDs = Self.normalized(context.starterActions.map(\.id))
        let caveatIDs = Self.normalized(context.caveats.map(\.id))
        let riskMetadataIDs = Self.normalized(context.riskMetadata.map(\.id))

        self.publicPlanningContextID = context.id
        self.selectedPackID = context.selectedPackID
        self.selectedPackDomainID = context.selectedPackDomainID
        self.manifestVersionID = context.manifestVersionID
        self.useMode = context.useMode
        self.sourceIDs = sourceIDs
        self.claimIDs = claimIDs
        self.requirementIDs = requirementIDs
        self.proofNeedIDs = proofNeedIDs
        self.starterActionIDs = starterActionIDs
        self.caveatIDs = caveatIDs
        self.riskMetadataIDs = riskMetadataIDs
        self.privateRuntimeOwnsPersonalization = context.ownership.privateRuntimeOwnsPersonalization
        self.privateRuntimeOwnsPathing = context.ownership.privateRuntimeOwnsPathing
        self.privateRuntimeOwnsScheduling = context.ownership.privateRuntimeOwnsScheduling
        self.privateRuntimeOwnsReceipts = context.ownership.privateRuntimeOwnsReceipts
        self.sourceAtlasCreatesFinalSteps = context.ownership.sourceAtlasCreatesFinalSteps
        self.sourceAtlasCreatesUserSchedule = context.ownership.sourceAtlasCreatesUserSchedule
        self.sourceAtlasStoresRuntimeState = context.ownership.sourceAtlasStoresRuntimeState
        self.id = CandidateSource.stableIdentifier(
            prefix: "source-atlas.public-shard-influence",
            components: [
                context.id,
                context.selectedPackID,
                context.selectedPackDomainID,
                sourceIDs.joined(separator: ","),
                claimIDs.joined(separator: ","),
                requirementIDs.joined(separator: ","),
                proofNeedIDs.joined(separator: ","),
                starterActionIDs.joined(separator: ",")
            ]
        )
    }

    private static func normalized(_ values: [String]) -> [String] {
        Array(
            Set(
                values
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { $0.isEmpty == false }
            )
        ).sorted()
    }
}

struct SourceAtlasVerifiedPublicPlanningBridgeOutput: Codable, Sendable, Equatable, Hashable {
    let schemaVersion: String
    let field: StepCandidateField
    let receipts: [SourceAtlasBridgeReceipt]
    let shardInfluence: SourceAtlasVerifiedPublicShardInfluence?
    let issues: [SourceAtlasVerifiedPublicPlanningBridgeIssue]
    let deterministicReplayFingerprint: String
    let localOnly: Bool

    init(
        field: StepCandidateField,
        receipts: [SourceAtlasBridgeReceipt],
        shardInfluence: SourceAtlasVerifiedPublicShardInfluence?,
        issues: [SourceAtlasVerifiedPublicPlanningBridgeIssue],
        localOnly: Bool
    ) {
        let schemaVersion = sourceAtlasVerifiedPublicPlanningBridgeSchemaVersion
        let orderedIssues = SourceAtlasVerifiedPublicPlanningBridgeIssue.allCases.filter { issues.contains($0) }

        self.schemaVersion = schemaVersion
        self.field = field
        self.receipts = receipts
        self.shardInfluence = shardInfluence
        self.issues = orderedIssues
        self.localOnly = localOnly
        self.deterministicReplayFingerprint = CandidateSource.stableIdentifier(
            prefix: "source-atlas.verified-public-planning-replay",
            components: [
                schemaVersion,
                field.id,
                field.rankingTrace.id,
                shardInfluence?.id ?? "no-public-shard-influence",
                orderedIssues.map(\.rawValue).joined(separator: ","),
                receipts.map(\.id).joined(separator: ","),
                localOnly ? "local-only" : "not-local-only"
            ]
        )
    }

    var canUseSourceAtlasCandidates: Bool {
        issues.isEmpty && shardInfluence != nil && field.sourceAtlasExpansionTrace != nil && localOnly
    }
}
