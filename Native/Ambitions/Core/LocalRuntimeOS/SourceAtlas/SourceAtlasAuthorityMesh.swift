import Foundation

// Guard note: this Persistence boundary composes existing Source Atlas query, cache, and seed outputs.

enum SourceAtlasAuthorityAction: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case visibleStep = "visible_step"
    case scheduleInstall = "schedule_install"
    case userControlledShare = "user_controlled_share"
}

enum SourceAtlasAuthoritySourceState: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case accepted
    case limited
    case revoked
    case blocked

    var blocksCurrentUse: Bool {
        self == .revoked || self == .blocked
    }
}

enum SourceAtlasAuthorityShareScope: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localOnly = "local_only"
    case userControlled = "user_controlled"
    case publicExport = "public_export"
}

enum SourceAtlasAuthorityShareRight: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case localOnly = "local_only"
    case userControlled = "user_controlled"
    case publicExport = "public_export"
    case blocked

    func allows(_ scope: SourceAtlasAuthorityShareScope) -> Bool {
        switch (self, scope) {
        case (.blocked, _):
            return false
        case (.localOnly, .localOnly):
            return true
        case (.localOnly, _):
            return false
        case (.userControlled, .localOnly), (.userControlled, .userControlled):
            return true
        case (.userControlled, .publicExport):
            return false
        case (.publicExport, _):
            return true
        }
    }
}

enum SourceAtlasAuthorityRevocationTarget: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case pack
    case source
    case claim
    case requirement
}

struct SourceAtlasAuthorityRevocationEvidence: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let target: SourceAtlasAuthorityRevocationTarget
    let targetID: String
    let reason: String
    let recordedAt: Date
    let active: Bool
    let evidenceSourceIDs: [String]

    init(
        id: String,
        target: SourceAtlasAuthorityRevocationTarget,
        targetID: String,
        reason: String,
        recordedAt: Date,
        active: Bool = true,
        evidenceSourceIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.target = target
        self.targetID = targetID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reason = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        self.recordedAt = recordedAt
        self.active = active
        self.evidenceSourceIDs = Self.orderedUnique(evidenceSourceIDs)
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct SourceAtlasAuthorityRecord: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let sourceID: String
    let state: SourceAtlasAuthoritySourceState
    let jurisdictionIDs: [String]
    let shareRight: SourceAtlasAuthorityShareRight
    let lastReviewedAt: Date?
    let revocationEvidenceIDs: [String]

    init(
        id: String,
        sourceID: String,
        state: SourceAtlasAuthoritySourceState = .accepted,
        jurisdictionIDs: [String] = ["global"],
        shareRight: SourceAtlasAuthorityShareRight = .localOnly,
        lastReviewedAt: Date? = nil,
        revocationEvidenceIDs: [String] = []
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceID = sourceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.state = state
        self.jurisdictionIDs = Self.normalizedJurisdictions(jurisdictionIDs)
        self.shareRight = shareRight
        self.lastReviewedAt = lastReviewedAt
        self.revocationEvidenceIDs = Self.orderedUnique(revocationEvidenceIDs)
    }

    func isCompatible(with jurisdictionID: String) -> Bool {
        let normalized = Self.normalizedJurisdiction(jurisdictionID)
        return jurisdictionIDs.contains("global") || jurisdictionIDs.contains(normalized)
    }

    private static func normalizedJurisdictions(_ values: [String]) -> [String] {
        let normalized = orderedUnique(values.map(normalizedJurisdiction))
        return normalized.isEmpty ? ["global"] : normalized
    }

    private static func normalizedJurisdiction(_ value: String) -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return trimmed.isEmpty ? "global" : trimmed
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

struct SourceAtlasAuthorityUpstreamState: Codable, Sendable, Equatable, Hashable {
    let cacheCanSupportCurrentUse: Bool?
    let seedCanSupportCurrentUse: Bool?
    let cacheIssueCodes: [String]
    let seedIssueCodes: [String]

    init(
        cacheCanSupportCurrentUse: Bool? = nil,
        seedCanSupportCurrentUse: Bool? = nil,
        cacheIssueCodes: [String] = [],
        seedIssueCodes: [String] = []
    ) {
        self.cacheCanSupportCurrentUse = cacheCanSupportCurrentUse
        self.seedCanSupportCurrentUse = seedCanSupportCurrentUse
        self.cacheIssueCodes = Self.orderedUnique(cacheIssueCodes)
        self.seedIssueCodes = Self.orderedUnique(seedIssueCodes)
    }

    init(
        cacheResolution: SourceAtlasLocalPackCacheResolution?,
        seedEligibility: SourceAtlasSeedEligibilityRecord?
    ) {
        self.init(
            cacheCanSupportCurrentUse: cacheResolution?.canSupportCurrentUse,
            seedCanSupportCurrentUse: seedEligibility?.canSupportCurrentUse,
            cacheIssueCodes: cacheResolution?.cacheIssues.map(\.rawValue) ?? [],
            seedIssueCodes: seedEligibility?.issues.map(\.rawValue) ?? []
        )
    }

    private static func orderedUnique(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}

enum SourceAtlasAuthorityMeshIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case resultCannotSupportCurrentUse = "result_cannot_support_current_use"
    case provenanceMissing = "provenance_missing"
    case missingSourceAuthority = "missing_source_authority"
    case sourceRevoked = "source_revoked"
    case sourceBlocked = "source_blocked"
    case jurisdictionIncompatible = "jurisdiction_incompatible"
    case shareRightsBlocked = "share_rights_blocked"
    case claimRevoked = "claim_revoked"
    case requirementRevoked = "requirement_revoked"
    case packRevoked = "pack_revoked"
    case freshnessBlocked = "freshness_blocked"
    case reviewBlocked = "review_blocked"
    case cacheCannotSupportCurrentUse = "cache_cannot_support_current_use"
    case seedCannotSupportCurrentUse = "seed_cannot_support_current_use"
}

struct SourceAtlasAuthorityMeshContext: Codable, Sendable, Equatable, Hashable {
    let action: SourceAtlasAuthorityAction
    let jurisdictionID: String
    let shareScope: SourceAtlasAuthorityShareScope

    init(
        action: SourceAtlasAuthorityAction,
        jurisdictionID: String = "global",
        shareScope: SourceAtlasAuthorityShareScope = .localOnly
    ) {
        self.action = action
        let normalizedJurisdiction = jurisdictionID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        self.jurisdictionID = normalizedJurisdiction.isEmpty ? "global" : normalizedJurisdiction
        self.shareScope = shareScope
    }
}

struct SourceAtlasAuthorityMeshInput: Sendable, Equatable, Hashable {
    let queryResponse: SourceAtlasQueryResponse
    let authorityRecords: [SourceAtlasAuthorityRecord]
    let revocationEvidence: [SourceAtlasAuthorityRevocationEvidence]
    let context: SourceAtlasAuthorityMeshContext
    let upstreamState: SourceAtlasAuthorityUpstreamState

    init(
        queryResponse: SourceAtlasQueryResponse,
        authorityRecords: [SourceAtlasAuthorityRecord],
        revocationEvidence: [SourceAtlasAuthorityRevocationEvidence] = [],
        context: SourceAtlasAuthorityMeshContext,
        upstreamState: SourceAtlasAuthorityUpstreamState = SourceAtlasAuthorityUpstreamState()
    ) {
        self.queryResponse = queryResponse
        self.authorityRecords = authorityRecords
        self.revocationEvidence = revocationEvidence
        self.context = context
        self.upstreamState = upstreamState
    }
}

struct SourceAtlasAuthorityMatrixRow: Codable, Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let resultID: String
    let packID: String
    let requirementID: String?
    let action: SourceAtlasAuthorityAction
    let jurisdictionID: String
    let shareScope: SourceAtlasAuthorityShareScope
    let sourceIDs: [String]
    let authorityRecordIDs: [String]
    let revocationEvidenceIDs: [String]
    let issueCodes: [String]
    let canSupportVisibleStep: Bool
    let canInstallSchedule: Bool
    let canShare: Bool
    let cacheIssueCodes: [String]
    let seedIssueCodes: [String]
}

struct SourceAtlasAuthorityInspectionRecord: Codable, Sendable, Equatable, Hashable {
    let selectedRow: SourceAtlasAuthorityMatrixRow
    let matrixRows: [SourceAtlasAuthorityMatrixRow]
    let blockedStepExamples: [String]
    let activeRevocationEvidenceIDs: [String]

    var canSupportCurrentUse: Bool {
        switch selectedRow.action {
        case .visibleStep:
            return selectedRow.canSupportVisibleStep
        case .scheduleInstall:
            return selectedRow.canInstallSchedule
        case .userControlledShare:
            return selectedRow.canShare
        }
    }
}

struct SourceAtlasAuthorityMesh: Sendable, Equatable, Hashable {
    func inspect(_ input: SourceAtlasAuthorityMeshInput) -> SourceAtlasAuthorityInspectionRecord {
        let rows = matrix(input)
        let selectedRow = rows.first { $0.resultID == input.queryResponse.selectedResult.id }
            ?? row(for: input.queryResponse.selectedResult, input: input)

        return SourceAtlasAuthorityInspectionRecord(
            selectedRow: selectedRow,
            matrixRows: rows,
            blockedStepExamples: blockedExamples(from: rows),
            activeRevocationEvidenceIDs: activeRevocationEvidenceIDs(input.revocationEvidence)
        )
    }

    func matrix(_ input: SourceAtlasAuthorityMeshInput) -> [SourceAtlasAuthorityMatrixRow] {
        input.queryResponse.results
            .map { row(for: $0, input: input) }
            .sorted {
                if $0.packID != $1.packID {
                    return $0.packID < $1.packID
                }
                return $0.resultID < $1.resultID
            }
    }
}

private extension SourceAtlasAuthorityMesh {
    func row(
        for result: SourceAtlasQueryResult,
        input: SourceAtlasAuthorityMeshInput
    ) -> SourceAtlasAuthorityMatrixRow {
        let authorityBySourceID = Dictionary(uniqueKeysWithValues: input.authorityRecords.map { ($0.sourceID, $0) })
        let baseIssues = baseIssues(for: result, input: input, authorityBySourceID: authorityBySourceID)
        let shareIssues = shareIssues(for: result, input: input, authorityBySourceID: authorityBySourceID)
        let actionIssues = input.context.action == .userControlledShare ? baseIssues.union(shareIssues) : baseIssues
        let authorityRecordIDs = result.provenanceSourceIDs.compactMap { authorityBySourceID[$0]?.id }.sorted()
        let revocationEvidenceIDs = matchingRevocationEvidence(for: result, evidence: input.revocationEvidence).map(\.id)

        return SourceAtlasAuthorityMatrixRow(
            id: "\(result.id)::\(input.context.action.rawValue)::\(input.context.jurisdictionID)",
            resultID: result.id,
            packID: result.packID,
            requirementID: result.requirementID,
            action: input.context.action,
            jurisdictionID: input.context.jurisdictionID,
            shareScope: input.context.shareScope,
            sourceIDs: result.provenanceSourceIDs.sorted(),
            authorityRecordIDs: authorityRecordIDs,
            revocationEvidenceIDs: revocationEvidenceIDs,
            issueCodes: orderedIssues(actionIssues).map(\.rawValue),
            canSupportVisibleStep: baseIssues.isEmpty,
            canInstallSchedule: baseIssues.isEmpty,
            canShare: baseIssues.isEmpty && shareIssues.isEmpty,
            cacheIssueCodes: input.upstreamState.cacheIssueCodes,
            seedIssueCodes: input.upstreamState.seedIssueCodes
        )
    }

    func baseIssues(
        for result: SourceAtlasQueryResult,
        input: SourceAtlasAuthorityMeshInput,
        authorityBySourceID: [String: SourceAtlasAuthorityRecord]
    ) -> Set<SourceAtlasAuthorityMeshIssue> {
        var issues: Set<SourceAtlasAuthorityMeshIssue> = []

        if result.canSupportCurrentUse == false {
            issues.insert(.resultCannotSupportCurrentUse)
        }
        if result.provenanceSourceIDs.isEmpty {
            issues.insert(.provenanceMissing)
        }
        if result.sourceState == .revoked || result.fallbackReason == .revoked {
            issues.insert(.claimRevoked)
        }
        if result.freshnessState.blocksCurrentProjection {
            issues.insert(.freshnessBlocked)
        }
        if result.reviewState.blocksCurrentProjection {
            issues.insert(.reviewBlocked)
        }
        if input.upstreamState.cacheCanSupportCurrentUse == false {
            issues.insert(.cacheCannotSupportCurrentUse)
        }
        if input.upstreamState.seedCanSupportCurrentUse == false {
            issues.insert(.seedCannotSupportCurrentUse)
        }

        for sourceID in result.provenanceSourceIDs {
            guard let authority = authorityBySourceID[sourceID] else {
                issues.insert(.missingSourceAuthority)
                continue
            }
            if authority.state == .revoked {
                issues.insert(.sourceRevoked)
            }
            if authority.state == .blocked {
                issues.insert(.sourceBlocked)
            }
            if authority.isCompatible(with: input.context.jurisdictionID) == false {
                issues.insert(.jurisdictionIncompatible)
            }
        }

        for evidence in matchingRevocationEvidence(for: result, evidence: input.revocationEvidence) where evidence.active {
            switch evidence.target {
            case .pack:
                issues.insert(.packRevoked)
            case .source:
                issues.insert(.sourceRevoked)
            case .claim:
                issues.insert(.claimRevoked)
            case .requirement:
                issues.insert(.requirementRevoked)
            }
        }

        return issues
    }

    func shareIssues(
        for result: SourceAtlasQueryResult,
        input: SourceAtlasAuthorityMeshInput,
        authorityBySourceID: [String: SourceAtlasAuthorityRecord]
    ) -> Set<SourceAtlasAuthorityMeshIssue> {
        var issues: Set<SourceAtlasAuthorityMeshIssue> = []
        for sourceID in result.provenanceSourceIDs {
            guard let authority = authorityBySourceID[sourceID] else {
                continue
            }
            if authority.shareRight.allows(input.context.shareScope) == false {
                issues.insert(.shareRightsBlocked)
            }
        }
        return issues
    }

    func matchingRevocationEvidence(
        for result: SourceAtlasQueryResult,
        evidence: [SourceAtlasAuthorityRevocationEvidence]
    ) -> [SourceAtlasAuthorityRevocationEvidence] {
        evidence.filter { item in
            switch item.target {
            case .pack:
                return item.targetID == result.packID
            case .source:
                return result.provenanceSourceIDs.contains(item.targetID)
            case .claim:
                return result.claimID == item.targetID
            case .requirement:
                return result.requirementID == item.targetID
            }
        }
        .sorted { $0.id < $1.id }
    }

    func activeRevocationEvidenceIDs(_ evidence: [SourceAtlasAuthorityRevocationEvidence]) -> [String] {
        evidence.filter(\.active).map(\.id).sorted()
    }

    func blockedExamples(from rows: [SourceAtlasAuthorityMatrixRow]) -> [String] {
        rows
            .filter { $0.canSupportVisibleStep == false || $0.canInstallSchedule == false || $0.canShare == false }
            .map { row in
                "\(row.resultID):\(row.issueCodes.joined(separator: "+"))"
            }
            .sorted()
    }

    func orderedIssues(_ issues: Set<SourceAtlasAuthorityMeshIssue>) -> [SourceAtlasAuthorityMeshIssue] {
        SourceAtlasAuthorityMeshIssue.allCases.filter { issues.contains($0) }
    }
}
