import Foundation

enum SourceAtlasPublicPackRefreshTargetRegistryStatus: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case active
    case reviewRequired = "review_required"
    case disabled
    case blocked
}

enum SourceAtlasPublicPackRefreshTargetRegistryIssue: String, Codable, Sendable, Equatable, Hashable, CaseIterable {
    case duplicateTargetID = "duplicate_target_id"
    case inactiveTarget = "inactive_target"
    case modeNotAllowed = "mode_not_allowed"
    case missingApprovalArtifact = "missing_approval_artifact"
    case unsafeTarget = "unsafe_target"
    case privateTargetMetadata = "private_target_metadata"
    case unsafeManifestRequest = "unsafe_manifest_request"
}

struct SourceAtlasPublicPackRefreshTargetRegistryEntry: Codable, Sendable, Equatable, Hashable, Identifiable {
    let target: SourceAtlasPublicPackLifecycleRefreshTarget
    let allowedModes: Set<SourceAtlasPublicPackLifecycleRefreshMode>
    let status: SourceAtlasPublicPackRefreshTargetRegistryStatus
    let reviewArtifactID: String?
    let nonClaims: [String]

    var id: String {
        target.id
    }

    var hasApprovalArtifact: Bool {
        guard let reviewArtifactID else {
            return false
        }
        return reviewArtifactID.isEmpty == false
    }

    var registryMetadataEgressRecord: SourceAtlasNoPrivateGraphEgressRecord {
        SourceAtlasNoPrivateGraphEgressRecord(
            surface: .cacheMetadata,
            identifier: "source-atlas-refresh-target-registry-entry",
            inspectedValue: [
                "target_id=\(target.id)",
                "status=\(status.rawValue)",
                "review_artifact_id=\(reviewArtifactID ?? "")",
                "non_claims=\(nonClaims.joined(separator: ","))",
            ].joined(separator: " ")
        )
    }

    init(
        target: SourceAtlasPublicPackLifecycleRefreshTarget,
        allowedModes: Set<SourceAtlasPublicPackLifecycleRefreshMode> = Set(SourceAtlasPublicPackLifecycleRefreshMode.allCases),
        status: SourceAtlasPublicPackRefreshTargetRegistryStatus = .reviewRequired,
        reviewArtifactID: String? = nil,
        nonClaims: [String] = []
    ) {
        self.target = target
        self.allowedModes = allowedModes
        self.status = status
        let trimmedReviewArtifactID = reviewArtifactID?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reviewArtifactID = trimmedReviewArtifactID?.isEmpty == true ? nil : trimmedReviewArtifactID
        self.nonClaims = nonClaims.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false }.sorted()
    }
}

struct SourceAtlasPublicPackRefreshTargetRegistryFinding: Codable, Sendable, Equatable, Hashable {
    let targetID: String
    let issue: SourceAtlasPublicPackRefreshTargetRegistryIssue
}

struct SourceAtlasPublicPackRefreshTargetRegistryResolution: Codable, Sendable, Equatable, Hashable {
    let mode: SourceAtlasPublicPackLifecycleRefreshMode
    let configuredEntryCount: Int
    let selectedTargets: [SourceAtlasPublicPackLifecycleRefreshTarget]
    let excludedTargetIDs: [String]
    let findings: [SourceAtlasPublicPackRefreshTargetRegistryFinding]
    let egressFindings: [SourceAtlasNoPrivateGraphEgressFinding]
    let lifecycleIssues: [SourceAtlasPublicPackLifecycleRefreshIssue]
    let sentPrivateRuntimeContext: Bool
    let generatedFinalPlan: Bool
    let generatedFinalSchedule: Bool
    let generatedStepList: Bool

    var selectedTargetIDs: [String] {
        selectedTargets.map(\.id)
    }

    var coreLocalPlanningBlocked: Bool {
        false
    }
}

struct SourceAtlasPublicPackRefreshTargetRegistry: Codable, Sendable, Equatable, Hashable {
    let entries: [SourceAtlasPublicPackRefreshTargetRegistryEntry]

    init(entries: [SourceAtlasPublicPackRefreshTargetRegistryEntry] = []) {
        self.entries = entries.sorted {
            if $0.target.id == $1.target.id {
                return $0.target.targetPackID < $1.target.targetPackID
            }
            return $0.target.id < $1.target.id
        }
    }

    static func defaultAppRegistry() -> SourceAtlasPublicPackRefreshTargetRegistry {
        SourceAtlasPublicPackRefreshTargetRegistry(entries: [])
    }

    func resolveTargets(
        for mode: SourceAtlasPublicPackLifecycleRefreshMode
    ) -> SourceAtlasPublicPackRefreshTargetRegistryResolution {
        let duplicateIDs = duplicatedTargetIDs()
        var selectedTargets: [SourceAtlasPublicPackLifecycleRefreshTarget] = []
        var excludedTargetIDs: [String] = []
        var findings: [SourceAtlasPublicPackRefreshTargetRegistryFinding] = []
        var egressFindings: [SourceAtlasNoPrivateGraphEgressFinding] = []
        var lifecycleIssues: Set<SourceAtlasPublicPackLifecycleRefreshIssue> = []

        for entry in entries {
            let validation = validate(entry, mode: mode, duplicateIDs: duplicateIDs)
            findings.append(contentsOf: validation.findings)
            egressFindings.append(contentsOf: validation.egressFindings)
            lifecycleIssues.formUnion(validation.lifecycleIssues)

            if validation.findings.isEmpty {
                selectedTargets.append(entry.target)
            } else {
                excludedTargetIDs.append(entry.target.id)
            }
        }

        return SourceAtlasPublicPackRefreshTargetRegistryResolution(
            mode: mode,
            configuredEntryCount: entries.count,
            selectedTargets: selectedTargets,
            excludedTargetIDs: orderedUniqueStrings(excludedTargetIDs),
            findings: orderedUniqueFindings(findings),
            egressFindings: orderedUniqueEgressFindings(egressFindings),
            lifecycleIssues: SourceAtlasPublicPackLifecycleRefreshIssue.allCases.filter { lifecycleIssues.contains($0) },
            sentPrivateRuntimeContext: false,
            generatedFinalPlan: false,
            generatedFinalSchedule: false,
            generatedStepList: false
        )
    }
}

private extension SourceAtlasPublicPackRefreshTargetRegistry {
    func validate(
        _ entry: SourceAtlasPublicPackRefreshTargetRegistryEntry,
        mode: SourceAtlasPublicPackLifecycleRefreshMode,
        duplicateIDs: Set<String>
    ) -> (
        findings: [SourceAtlasPublicPackRefreshTargetRegistryFinding],
        egressFindings: [SourceAtlasNoPrivateGraphEgressFinding],
        lifecycleIssues: Set<SourceAtlasPublicPackLifecycleRefreshIssue>
    ) {
        var issues: Set<SourceAtlasPublicPackRefreshTargetRegistryIssue> = []
        var lifecycleIssues: Set<SourceAtlasPublicPackLifecycleRefreshIssue> = []
        var egressFindings = privateTargetMetadataFindings([
            entry.target.egressRecord,
            entry.registryMetadataEgressRecord,
        ])

        if duplicateIDs.contains(entry.target.id) {
            issues.insert(.duplicateTargetID)
            lifecycleIssues.insert(.unsafeTarget)
        }

        if entry.status != .active {
            issues.insert(.inactiveTarget)
        }

        if entry.status == .active && entry.hasApprovalArtifact == false {
            issues.insert(.missingApprovalArtifact)
            lifecycleIssues.insert(.missingApprovalArtifact)
        }

        if entry.allowedModes.contains(mode) == false {
            issues.insert(.modeNotAllowed)
        }

        if entry.target.id.isEmpty ||
            entry.target.domainID.isEmpty ||
            entry.target.channel.isEmpty ||
            entry.target.schemaVersion.isEmpty ||
            entry.target.appVersion.isEmpty ||
            entry.target.targetPackID.isEmpty ||
            entry.target.environment.isEmpty {
            issues.insert(.unsafeTarget)
            lifecycleIssues.insert(.unsafeTarget)
        }

        if egressFindings.isEmpty == false {
            issues.insert(.privateTargetMetadata)
            lifecycleIssues.insert(.privateTargetMetadata)
        }

        if entry.target.manifestRequest.validationIssues.isEmpty == false {
            issues.insert(.unsafeManifestRequest)
            lifecycleIssues.insert(.unsafeManifestRequest)
            egressFindings = orderedUniqueEgressFindings(
                egressFindings + SourceAtlasNoPrivateGraphEgressAudit.validate([entry.target.manifestRequest.egressRecord])
            )
        }

        return (
            findings: SourceAtlasPublicPackRefreshTargetRegistryIssue.allCases
                .filter { issues.contains($0) }
                .map { SourceAtlasPublicPackRefreshTargetRegistryFinding(targetID: entry.target.id, issue: $0) },
            egressFindings: orderedUniqueEgressFindings(egressFindings),
            lifecycleIssues: lifecycleIssues
        )
    }

    func duplicatedTargetIDs() -> Set<String> {
        var seen: Set<String> = []
        var duplicates: Set<String> = []
        for id in entries.map(\.target.id) {
            if seen.insert(id).inserted == false {
                duplicates.insert(id)
            }
        }
        return duplicates
    }

    func privateTargetMetadataFindings(
        _ records: [SourceAtlasNoPrivateGraphEgressRecord]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        let extraTokens = [
            "account_id",
            "device_id",
            "goal_id",
            "goal_text",
            "capture_text",
            "schedule",
            "calendar",
            "proof_payload",
            "receipt_payload",
            "private_context",
            "private_user_context",
            "life_graph",
            "personalized",
        ]
        let standardFindings = SourceAtlasNoPrivateGraphEgressAudit.validate(records)
        let extraFindings = records.flatMap { record in
            let normalized = SourceAtlasNoPrivateGraphEgressAudit.normalize(record.inspectedValue)
            return extraTokens.compactMap { token in
                normalized.contains(token)
                    ? SourceAtlasNoPrivateGraphEgressFinding(
                        surface: record.surface,
                        identifier: record.identifier,
                        forbiddenToken: token
                    )
                    : nil
            }
        }
        return orderedUniqueEgressFindings(standardFindings + extraFindings)
    }

    func orderedUniqueFindings(
        _ findings: [SourceAtlasPublicPackRefreshTargetRegistryFinding]
    ) -> [SourceAtlasPublicPackRefreshTargetRegistryFinding] {
        var seen: Set<SourceAtlasPublicPackRefreshTargetRegistryFinding> = []
        return findings.filter { seen.insert($0).inserted }
    }

    func orderedUniqueEgressFindings(
        _ findings: [SourceAtlasNoPrivateGraphEgressFinding]
    ) -> [SourceAtlasNoPrivateGraphEgressFinding] {
        var seen: Set<SourceAtlasNoPrivateGraphEgressFinding> = []
        return findings.filter { seen.insert($0).inserted }
    }

    func orderedUniqueStrings(_ values: [String]) -> [String] {
        var seen: Set<String> = []
        return values.filter { seen.insert($0).inserted }
    }
}
