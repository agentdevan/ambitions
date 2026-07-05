import Foundation

let sourceAtlasVerifiedPublicPlanningBridgeSchemaVersion = "source_atlas_verified_public_planning_bridge.native.v1"
let sourceInfluenceReceiptSchemaVersion = "source_influence_receipt.native.v1"

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
    let sourceAtlasOwnsPublicReferenceContext: Bool
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
        self.sourceAtlasOwnsPublicReferenceContext = context.ownership.sourceAtlasOwnsPublicReferenceContext
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

struct SourceInfluenceReceipt: Codable, Sendable, Equatable, Hashable, Identifiable {
    let schemaVersion: String
    let id: String
    let recordedAt: String
    let publicPlanningContextID: String
    let selectedPackID: String
    let selectedPackDomainID: String
    let manifestVersionID: String?
    let localDecisionOutputID: String
    let localSelectedCandidateID: String
    let sourceIDs: [String]
    let claimIDs: [String]
    let requirementIDs: [String]
    let proofNeedIDs: [String]
    let starterActionIDs: [String]
    let sourceAtlasOwnsPublicReferenceContext: Bool
    let privateRuntimeOwnsPersonalization: Bool
    let privateRuntimeOwnsPathing: Bool
    let privateRuntimeOwnsScheduling: Bool
    let privateRuntimeOwnsReceipts: Bool
    let sourceAtlasCreatesFinalSteps: Bool
    let sourceAtlasCreatesUserSchedule: Bool
    let sourceAtlasStoresRuntimeState: Bool
    let privateInputIncluded: Bool
    let privateLifeGraphIncluded: Bool
    let reviewRequired: Bool
    let localOnly: Bool

    init(
        recordedAt: String,
        publicPlanningContextID: String,
        selectedPackID: String,
        selectedPackDomainID: String,
        manifestVersionID: String? = nil,
        localDecisionOutputID: String,
        localSelectedCandidateID: String,
        sourceIDs: [String],
        claimIDs: [String],
        requirementIDs: [String],
        proofNeedIDs: [String],
        starterActionIDs: [String],
        sourceAtlasOwnsPublicReferenceContext: Bool = true,
        privateRuntimeOwnsPersonalization: Bool = true,
        privateRuntimeOwnsPathing: Bool = true,
        privateRuntimeOwnsScheduling: Bool = true,
        privateRuntimeOwnsReceipts: Bool = true,
        sourceAtlasCreatesFinalSteps: Bool = false,
        sourceAtlasCreatesUserSchedule: Bool = false,
        sourceAtlasStoresRuntimeState: Bool = false,
        privateInputIncluded: Bool = false,
        privateLifeGraphIncluded: Bool = false,
        reviewRequired: Bool = false,
        localOnly: Bool = true
    ) {
        self.schemaVersion = sourceInfluenceReceiptSchemaVersion
        self.recordedAt = Self.normalizedRequired(recordedAt)
        self.publicPlanningContextID = Self.normalizedRequired(publicPlanningContextID)
        self.selectedPackID = Self.normalizedRequired(selectedPackID)
        self.selectedPackDomainID = Self.normalizedRequired(selectedPackDomainID)
        self.manifestVersionID = Self.normalizedOptional(manifestVersionID)
        self.localDecisionOutputID = Self.normalizedRequired(localDecisionOutputID)
        self.localSelectedCandidateID = Self.normalizedRequired(localSelectedCandidateID)
        self.sourceIDs = Self.normalized(sourceIDs)
        self.claimIDs = Self.normalized(claimIDs)
        self.requirementIDs = Self.normalized(requirementIDs)
        self.proofNeedIDs = Self.normalized(proofNeedIDs)
        self.starterActionIDs = Self.normalized(starterActionIDs)
        self.sourceAtlasOwnsPublicReferenceContext = sourceAtlasOwnsPublicReferenceContext
        self.privateRuntimeOwnsPersonalization = privateRuntimeOwnsPersonalization
        self.privateRuntimeOwnsPathing = privateRuntimeOwnsPathing
        self.privateRuntimeOwnsScheduling = privateRuntimeOwnsScheduling
        self.privateRuntimeOwnsReceipts = privateRuntimeOwnsReceipts
        self.sourceAtlasCreatesFinalSteps = sourceAtlasCreatesFinalSteps
        self.sourceAtlasCreatesUserSchedule = sourceAtlasCreatesUserSchedule
        self.sourceAtlasStoresRuntimeState = sourceAtlasStoresRuntimeState
        self.privateInputIncluded = privateInputIncluded
        self.privateLifeGraphIncluded = privateLifeGraphIncluded
        self.reviewRequired = reviewRequired
        self.localOnly = localOnly
        self.id = CandidateSource.stableIdentifier(
            prefix: "source-influence-receipt",
            components: [
                self.schemaVersion,
                self.recordedAt,
                self.publicPlanningContextID,
                self.selectedPackID,
                self.selectedPackDomainID,
                self.manifestVersionID ?? "manifest.none",
                self.localDecisionOutputID,
                self.localSelectedCandidateID,
                self.sourceIDs.joined(separator: ","),
                self.claimIDs.joined(separator: ","),
                self.requirementIDs.joined(separator: ","),
                self.proofNeedIDs.joined(separator: ","),
                self.starterActionIDs.joined(separator: ","),
                self.sourceAtlasOwnsPublicReferenceContext ? "source-atlas-public-reference-owner" : "source-atlas-public-reference-not-owner",
                self.privateRuntimeOwnsPersonalization ? "private-runtime-personalization" : "no-private-runtime-personalization",
                self.privateRuntimeOwnsPathing ? "private-runtime-pathing" : "no-private-runtime-pathing",
                self.privateRuntimeOwnsScheduling ? "private-runtime-scheduling" : "no-private-runtime-scheduling",
                self.privateRuntimeOwnsReceipts ? "private-runtime-receipts" : "no-private-runtime-receipts",
                self.sourceAtlasCreatesFinalSteps ? "source-atlas-final-steps" : "no-source-atlas-final-steps",
                self.sourceAtlasCreatesUserSchedule ? "source-atlas-schedule" : "no-source-atlas-schedule",
                self.sourceAtlasStoresRuntimeState ? "source-atlas-runtime-state" : "no-source-atlas-runtime-state",
                self.privateInputIncluded ? "private-input-included" : "no-private-input",
                self.privateLifeGraphIncluded ? "private-life-graph-included" : "no-private-life-graph",
                self.reviewRequired ? "review-required" : "review-not-required",
                self.localOnly ? "local-only" : "not-local-only"
            ]
        )
    }

    init(
        recordedAt: String,
        field: StepCandidateField,
        shardInfluence: SourceAtlasVerifiedPublicShardInfluence,
        reviewRequired: Bool,
        localOnly: Bool
    ) {
        self.init(
            recordedAt: recordedAt,
            publicPlanningContextID: shardInfluence.publicPlanningContextID,
            selectedPackID: shardInfluence.selectedPackID,
            selectedPackDomainID: shardInfluence.selectedPackDomainID,
            manifestVersionID: shardInfluence.manifestVersionID,
            localDecisionOutputID: field.id,
            localSelectedCandidateID: field.selectedCandidateID,
            sourceIDs: shardInfluence.sourceIDs,
            claimIDs: shardInfluence.claimIDs,
            requirementIDs: shardInfluence.requirementIDs,
            proofNeedIDs: shardInfluence.proofNeedIDs,
            starterActionIDs: shardInfluence.starterActionIDs,
            sourceAtlasOwnsPublicReferenceContext: shardInfluence.sourceAtlasOwnsPublicReferenceContext,
            privateRuntimeOwnsPersonalization: shardInfluence.privateRuntimeOwnsPersonalization,
            privateRuntimeOwnsPathing: shardInfluence.privateRuntimeOwnsPathing,
            privateRuntimeOwnsScheduling: shardInfluence.privateRuntimeOwnsScheduling,
            privateRuntimeOwnsReceipts: shardInfluence.privateRuntimeOwnsReceipts,
            sourceAtlasCreatesFinalSteps: shardInfluence.sourceAtlasCreatesFinalSteps,
            sourceAtlasCreatesUserSchedule: shardInfluence.sourceAtlasCreatesUserSchedule,
            sourceAtlasStoresRuntimeState: shardInfluence.sourceAtlasStoresRuntimeState,
            privateInputIncluded: false,
            privateLifeGraphIncluded: false,
            reviewRequired: reviewRequired,
            localOnly: localOnly
        )
    }

    var canInfluenceLocalPlanning: Bool {
        localOnly &&
            privateInputIncluded == false &&
            privateLifeGraphIncluded == false &&
            sourceAtlasOwnsPublicReferenceContext &&
            privateRuntimeOwnsPersonalization &&
            privateRuntimeOwnsPathing &&
            privateRuntimeOwnsScheduling &&
            privateRuntimeOwnsReceipts &&
            sourceAtlasCreatesFinalSteps == false &&
            sourceAtlasCreatesUserSchedule == false &&
            sourceAtlasStoresRuntimeState == false
    }

    var bridgeReceipt: SourceAtlasBridgeReceipt {
        SourceAtlasBridgeReceipt(
            kind: .sourceAtlasInfluenceReceiptRecorded,
            recordedAt: recordedAt,
            summary: "Source Atlas public context influence was recorded for a local planning decision.",
            details: [
                "schema=\(schemaVersion)",
                "context=\(publicPlanningContextID)",
                "pack=\(selectedPackID)",
                "domain=\(selectedPackDomainID)",
                "manifest=\(manifestVersionID ?? "none")",
                "candidate-field=\(localDecisionOutputID)",
                "selected-candidate=\(localSelectedCandidateID)",
                "source-count=\(sourceIDs.count)",
                "claim-count=\(claimIDs.count)",
                "requirement-count=\(requirementIDs.count)",
                "proof-need-count=\(proofNeedIDs.count)",
                "starter-action-count=\(starterActionIDs.count)",
                "source-atlas-public-reference-owner=\(sourceAtlasOwnsPublicReferenceContext)",
                "source-atlas-final-step-owner=\(sourceAtlasCreatesFinalSteps)",
                "source-atlas-final-schedule-owner=\(sourceAtlasCreatesUserSchedule)",
                "source-atlas-stores-runtime-state=\(sourceAtlasStoresRuntimeState)",
                "private-runtime-owns-personalization=\(privateRuntimeOwnsPersonalization)",
                "private-runtime-owns-pathing=\(privateRuntimeOwnsPathing)",
                "private-runtime-owns-scheduling=\(privateRuntimeOwnsScheduling)",
                "private-runtime-owns-receipts=\(privateRuntimeOwnsReceipts)",
                "private-input-included=\(privateInputIncluded)",
                "private-life-graph-included=\(privateLifeGraphIncluded)",
                "can-influence-local-planning=\(canInfluenceLocalPlanning)",
                "review-required=\(reviewRequired)",
                "local-only=\(localOnly)",
                "r2-artifact=false"
            ],
            relatedIDs: relatedPublicIDs + [localDecisionOutputID, localSelectedCandidateID]
        )
    }

    var relatedPublicIDs: [String] {
        Self.normalized(
            [publicPlanningContextID, selectedPackID, selectedPackDomainID] +
                sourceIDs +
                claimIDs +
                requirementIDs +
                proofNeedIDs +
                starterActionIDs
        )
    }

    private static func normalizedRequired(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let value else { return nil }
        let trimmed = normalizedRequired(value)
        return trimmed.isEmpty ? nil : trimmed
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
    let sourceInfluenceReceipt: SourceInfluenceReceipt?
    let issues: [SourceAtlasVerifiedPublicPlanningBridgeIssue]
    let deterministicReplayFingerprint: String
    let localOnly: Bool

    init(
        field: StepCandidateField,
        receipts: [SourceAtlasBridgeReceipt],
        shardInfluence: SourceAtlasVerifiedPublicShardInfluence?,
        sourceInfluenceReceipt: SourceInfluenceReceipt?,
        issues: [SourceAtlasVerifiedPublicPlanningBridgeIssue],
        localOnly: Bool
    ) {
        let schemaVersion = sourceAtlasVerifiedPublicPlanningBridgeSchemaVersion
        let orderedIssues = SourceAtlasVerifiedPublicPlanningBridgeIssue.allCases.filter { issues.contains($0) }

        self.schemaVersion = schemaVersion
        self.field = field
        self.receipts = receipts
        self.shardInfluence = shardInfluence
        self.sourceInfluenceReceipt = sourceInfluenceReceipt
        self.issues = orderedIssues
        self.localOnly = localOnly
        self.deterministicReplayFingerprint = CandidateSource.stableIdentifier(
            prefix: "source-atlas.verified-public-planning-replay",
            components: [
                schemaVersion,
                field.id,
                field.rankingTrace.id,
                shardInfluence?.id ?? "no-public-shard-influence",
                sourceInfluenceReceipt?.id ?? "no-source-influence-receipt",
                orderedIssues.map(\.rawValue).joined(separator: ","),
                receipts.map(\.id).joined(separator: ","),
                localOnly ? "local-only" : "not-local-only"
            ]
        )
    }

    var canUseSourceAtlasCandidates: Bool {
        issues.isEmpty &&
            shardInfluence != nil &&
            sourceInfluenceReceipt?.canInfluenceLocalPlanning == true &&
            field.sourceAtlasExpansionTrace != nil &&
            localOnly
    }
}
