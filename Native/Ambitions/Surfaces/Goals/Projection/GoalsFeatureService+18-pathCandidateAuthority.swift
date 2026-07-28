import Foundation

/// Read-only authority state for an already-persisted compiled goal-path
/// candidate. This deliberately does not select, install, or mutate a path:
/// the legacy goal store has no durable path-selection receipt schema.
enum GoalPathCandidateAuthorityIssue: String, Sendable, Equatable, Hashable {
    case goalContextUnavailable
    case ambiguousDraftAuthority
    case planningMetadataUnavailable
    case schemaLineageMismatch
    case candidateUnavailable
    case candidateBlocked
    case milestonesInvalid
    case dependencyBlocked
    case assumptionsUnsafe
    case blockingRequirement
    case resourceGraphMismatch
    case capacityUnavailable
    case provenanceUnavailable
}

struct GoalPathCandidateAuthorityState: Sendable, Equatable {
    let goalID: String?
    let draftID: String
    let candidateID: String
    let compiledPathSchemaVersion: String
    let resourceGraphSchemaVersion: String
    let energyModelSchemaVersion: String
    let stageIDs: [String]
    let dependencyIDs: [String]
    let assumptionIDs: [String]
    let capacityBand: EnergyFitBand
    let sourceRecordIDs: [String]
    let issues: [GoalPathCandidateAuthorityIssue]

    /// A caller may present this candidate for explicit review only when every
    /// persisted authority link is internally consistent. It is not a write
    /// authorization and cannot be treated as a selection receipt.
    var isEligibleForExplicitAcceptance: Bool { issues.isEmpty }
}

extension RepositoryBackedGoalsService {
    /// Resolves one persisted candidate through the draft that owns its
    /// orchestration metadata. Ambiguous, stale, or incomplete lineage is a
    /// typed non-acceptance result rather than a fallback to generated state.
    func pathCandidateAuthority(
        target: GoalRouteTarget,
        candidateID: String
    ) async throws -> GoalPathCandidateAuthorityState {
        let normalizedCandidateID = candidateID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard normalizedCandidateID.isEmpty == false else {
            return unavailableState(target: target, candidateID: normalizedCandidateID, issue: .candidateUnavailable)
        }

        let drafts: [PersistedGoalDraft]
        if let draftID = target.draftID {
            drafts = try await repositories.drafts.draft(id: draftID).map { [$0] } ?? []
        } else if let goalID = target.goalID {
            drafts = try await repositories.drafts.listDrafts().filter { $0.plannedGoalID == goalID }
        } else {
            return unavailableState(target: target, candidateID: normalizedCandidateID, issue: .goalContextUnavailable)
        }

        guard drafts.count == 1, let draft = drafts.first else {
            return unavailableState(
                target: target,
                candidateID: normalizedCandidateID,
                issue: drafts.isEmpty ? .goalContextUnavailable : .ambiguousDraftAuthority
            )
        }
        guard let metadata = draft.metadata else {
            return unavailableState(target: target, draft: draft, candidateID: normalizedCandidateID, issue: .planningMetadataUnavailable)
        }

        let compiledPath = metadata.compiledPath
        let candidates = compiledPath.candidates.filter { $0.id == normalizedCandidateID }
        guard candidates.count == 1, let candidate = candidates.first else {
            return unavailableState(target: target, draft: draft, candidateID: normalizedCandidateID, issue: .candidateUnavailable, metadata: metadata)
        }

        var issues = Set<GoalPathCandidateAuthorityIssue>()
        let resourceGraph = metadata.resourceGraph
        let energyModel = metadata.energyModel
        if compiledPath.schemaVersion.isEmpty ||
            resourceGraph.schemaVersion.isEmpty ||
            energyModel.schemaVersion.isEmpty ||
            resourceGraph.sourceCompiledPathSchemaVersion != compiledPath.schemaVersion ||
            energyModel.sourceCompiledPathSchemaVersion != compiledPath.schemaVersion {
            issues.insert(.schemaLineageMismatch)
        }

        let stageIDs = candidate.stages.map(\.id)
        if stageIDs.isEmpty || Set(stageIDs).count != stageIDs.count || stageIDs.contains(where: { $0.isEmpty }) {
            issues.insert(.milestonesInvalid)
        }
        let stageIDSet = Set(stageIDs)
        if candidate.dependencies.contains(where: { dependency in
            dependency.blocking || (dependency.relatedStageID.map { stageIDSet.contains($0) == false } ?? false)
        }) {
            issues.insert(.dependencyBlocked)
        }
        if candidate.assumptions.contains(where: { $0.safeForCompilation == false }) {
            issues.insert(.assumptionsUnsafe)
        }
        if candidate.blockingReasons.isEmpty == false || candidate.posture == .blocked || candidate.safeForStarterPlanning == false {
            issues.insert(.candidateBlocked)
        }
        if candidate.requirementHints.contains(where: \.blocking) ||
            candidate.readinessCriteria.contains(where: \.blocking) {
            issues.insert(.blockingRequirement)
        }

        let graphCandidates = resourceGraph.candidateGraphs.filter { $0.candidateID == candidate.id }
        if graphCandidates.count != 1 || Set(graphCandidates[0].stageIDs) != stageIDSet {
            issues.insert(.resourceGraphMismatch)
        }
        let capacity = energyModel.candidateSummaries.filter { $0.candidateID == candidate.id }
        let capacityBand = capacity.count == 1 ? capacity[0].fitBand : .unknown
        if capacityBand == .unknown || capacityBand == .strained {
            issues.insert(.capacityUnavailable)
        }

        let sourceRecordIDs = Array(Set(
            candidate.dependencies.flatMap(\.sourceRecordIDs) +
                candidate.resourceHooks.flatMap(\.sourceRecordIDs) +
                resourceGraph.audit.entries
                    .filter { $0.candidateID == candidate.id }
                    .compactMap(\.sourceRecordID)
        )).sorted()
        if sourceRecordIDs.isEmpty {
            issues.insert(.provenanceUnavailable)
        }
        return GoalPathCandidateAuthorityState(
            goalID: target.goalID ?? draft.plannedGoalID,
            draftID: draft.id,
            candidateID: candidate.id,
            compiledPathSchemaVersion: compiledPath.schemaVersion,
            resourceGraphSchemaVersion: resourceGraph.schemaVersion,
            energyModelSchemaVersion: energyModel.schemaVersion,
            stageIDs: stageIDs.sorted(),
            dependencyIDs: candidate.dependencies.map(\.id).sorted(),
            assumptionIDs: candidate.assumptions.map(\.id).sorted(),
            capacityBand: capacityBand,
            sourceRecordIDs: sourceRecordIDs,
            issues: issues.sorted { $0.rawValue < $1.rawValue }
        )
    }

    private func unavailableState(
        target: GoalRouteTarget,
        draft: PersistedGoalDraft? = nil,
        candidateID: String,
        issue: GoalPathCandidateAuthorityIssue,
        metadata: GoalOrchestrationMetadata? = nil
    ) -> GoalPathCandidateAuthorityState {
        GoalPathCandidateAuthorityState(
            goalID: target.goalID ?? draft?.plannedGoalID,
            draftID: draft?.id ?? "",
            candidateID: candidateID,
            compiledPathSchemaVersion: metadata?.compiledPath.schemaVersion ?? "",
            resourceGraphSchemaVersion: metadata?.resourceGraph.schemaVersion ?? "",
            energyModelSchemaVersion: metadata?.energyModel.schemaVersion ?? "",
            stageIDs: [],
            dependencyIDs: [],
            assumptionIDs: [],
            capacityBand: .unknown,
            sourceRecordIDs: [],
            issues: [issue]
        )
    }
}
