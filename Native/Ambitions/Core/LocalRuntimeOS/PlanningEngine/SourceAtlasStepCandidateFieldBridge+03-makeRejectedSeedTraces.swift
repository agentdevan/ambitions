import Foundation

extension SourceAtlasStepCandidateFieldBridge {

    func makeRejectedSeedTraces(
        seedTraces: [SourceAtlasStepCandidateSeedTrace],
        expandedCandidateTraces: [SourceAtlasStepExpansionCandidateTrace],
        composition: PersonalPathComposition,
        pack: SourceAtlasPack
    ) -> [SourceAtlasStepExpansionRejectedSeedTrace] {
        let survivingSeedIDs = Set(expandedCandidateTraces.map(\.sourceSeedID))
        return seedTraces.compactMap { seed in
            guard survivingSeedIDs.contains(seed.id) == false else {
                return nil
            }
            return SourceAtlasStepExpansionRejectedSeedTrace(
                id: stableIdentifier(prefix: "source-atlas.rejected-seed", components: [seed.id, composition.goalID, pack.id]),
                sourceSeedID: seed.id,
                sourcePackID: seed.sourcePackID,
                sourcePathID: seed.sourcePathID,
                reason: "Seed did not survive ranking or deduplication.",
                sourceRecordIDs: seed.sourceRecordIDs,
                sourceClaimIDs: seed.sourceClaimIDs
            )
        }
    }


    func makeExpansionTrace(
        seedTraces: [SourceAtlasStepCandidateSeedTrace],
        expandedCandidates: [SourceAtlasStepExpansionCandidateTrace],
        rejectedSeedTraces: [SourceAtlasStepExpansionRejectedSeedTrace],
        composition: PersonalPathComposition,
        pack: SourceAtlasPack,
        factorLedger: PersonalizationFactorLedger?,
        lifeContextProjection: LifeContextRuntimeProjection?
    ) -> SourceAtlasStepExpansionTrace {
        let personalizationFactorsUsed = factorLedger.map { ledger in
            ledger.factors.map { $0.factorType.rawValue }
        } ?? []
        let freshnessWarnings = uniqueStrings(
            seedTraces.flatMap(\.freshnessWarnings) +
            sourceFreshnessWarnings(path: composition.selectedPath, projection: lifeContextProjection)
        )
        let sensitiveContextRedactions = uniqueStrings(
            seedTraces.flatMap(\.sensitiveContextRedactions) +
            composition.explanationProjection.sourceLabels.compactMap(redactIfSensitive(_:)) +
            [composition.selectedPath.pathSummary].compactMap(redactIfSensitive(_:))
        )

        return SourceAtlasStepExpansionTrace(
            sourceStepCandidateSeeds: seedTraces,
            expandedCandidates: expandedCandidates,
            rejectedSeeds: rejectedSeedTraces,
            expansionRules: [
                "Selected path nodes become direct, prerequisite, access, and proof candidates.",
                "Requirements become admin setup, proof gathering, learning, and recovery-safe candidates.",
                "Starter seeds become concise action candidates with provenance preserved.",
                "Plan skeleton milestones become deadline-aware and recovery-aware candidates.",
                "Duplicate semantic signatures collapse to one candidate.",
                "Deadline protection comes from simulation, not from invented copy."
            ],
            personalizationFactorsUsed: personalizationFactorsUsed,
            freshnessWarnings: freshnessWarnings,
            sensitiveContextRedactions: sensitiveContextRedactions
        )
    }


    func rebuildField(
        _ field: StepCandidateField,
        sourceAtlasExpansionTrace: SourceAtlasStepExpansionTrace
    ) -> StepCandidateField {
        let rankingTrace = CandidateRankingTrace(
            generatedAt: field.rankingTrace.generatedAt,
            selectedCandidateID: field.rankingTrace.selectedCandidateID,
            rankedCandidateIDs: field.rankingTrace.rankedCandidateIDs,
            rejectedCandidateIDs: field.rankingTrace.rejectedCandidateIDs,
            suppressedRejectedCandidateIDs: field.rankingTrace.suppressedRejectedCandidateIDs,
            duplicateRejectedCandidateIDs: field.rankingTrace.duplicateRejectedCandidateIDs,
            sourceProvenance: field.rankingTrace.sourceProvenance,
            factorEvidenceIDs: field.rankingTrace.factorEvidenceIDs,
            replayReferenceID: field.rankingTrace.replayReferenceID,
            replayFingerprint: field.rankingTrace.replayFingerprint,
            sourceAtlasExpansionTrace: sourceAtlasExpansionTrace,
            semanticSummary: field.rankingTrace.semanticSummary,
            factorlessRanking: field.rankingTrace.factorlessRanking
        )

        return StepCandidateField(
            goalID: field.goalID,
            deadlineTargetDate: field.deadlineTargetDate,
            generatedAt: field.generatedAt,
            sourceProvenance: field.sourceProvenance,
            candidates: field.candidates,
            rankingTrace: rankingTrace,
            sourceAtlasExpansionTrace: sourceAtlasExpansionTrace,
            localOnly: field.localOnly
        )
    }


    func pathNodes(for path: SourceAtlasCapabilityPath, pack: SourceAtlasPack) -> [SourceAtlasCapabilityNode] {
        let nodesByID = Dictionary(uniqueKeysWithValues: pack.capabilityGraphs.flatMap(\.nodes).map { ($0.id, $0) })
        return path.selectedNodeIDs.compactMap { nodesByID[$0] }
    }


    func requirementIDs(
        for node: SourceAtlasCapabilityNode,
        in path: SourceAtlasCapabilityPath,
        pack: SourceAtlasPack
    ) -> [String] {
        let requirements = path.planSkeleton.milestones.flatMap { milestone in
            milestone.nodeIDs.contains(node.id) ? milestone.requirementIDs : []
        } + path.planSkeleton.proofMoments.flatMap { moment in
            moment.nodeIDs.contains(node.id) ? moment.requirementIDs : []
        }
        return uniqueStrings(requirements + pack.requirements.filter { $0.title.localizedCaseInsensitiveContains(node.title) }.map(\.id))
    }


    func proofRequirementIDs(
        for node: SourceAtlasCapabilityNode,
        in path: SourceAtlasCapabilityPath,
        pack: SourceAtlasPack
    ) -> [String] {
        let requirements = path.planSkeleton.proofMoments.flatMap { moment in
            moment.nodeIDs.contains(node.id) ? moment.requirementIDs : []
        } + pack.proofMap.compactMap { proof in
            proof.capabilityNodeID == node.id ? proof.requirementID : nil
        }
        return uniqueStrings(requirements)
    }


    func nodeSeedKind(for node: SourceAtlasCapabilityNode, sourcePath: SourceAtlasCapabilityPath) -> String {
        if sourcePath.planSkeleton.proofMoments.contains(where: { $0.nodeIDs.contains(node.id) }) {
            return "proof"
        }
        if sourcePath.planSkeleton.reviewMoments.contains(where: { $0.requirementIDs.contains(where: { requirementID in requirementID.contains(node.id) }) }) {
            return "review"
        }
        if sourcePath.planSkeleton.recoveryWindows.contains(where: { $0.relatedNodeIDs.contains(node.id) }) {
            return "recovery"
        }
        if sourcePath.planSkeleton.milestones.contains(where: { $0.kind == .setup || $0.nodeIDs.contains(node.id) }) {
            return "setup"
        }
        return "direct"
    }


    func requirementSeedKind(for requirement: SourceAtlasRequirement) -> String {
        switch requirement.kind {
        case .prerequisite, .hard:
            return "prerequisite"
        case .equipment:
            return "admin"
        case .proof:
            return "proof"
        case .deadline:
            return "deadline"
        case .blocker:
            return "recovery"
        case .accelerator, .soft, .skill, .reviewRequired:
            return "direct"
        }
    }


    func stepKind(for seed: SourceAtlasStepCandidateSeedTrace) -> StepCandidateKind {
        switch seed.seedKind {
        case "proof":
            return .proofGathering
        case "prerequisite":
            return .prerequisite
        case "admin":
            return .adminSetup
        case "learning", "review":
            return .learningResearch
        case "recovery":
            return .recoverySafe
        case "deadline":
            return .catchUp
        case "starter":
            return .directBest
        default:
            return .directBest
        }
    }


    func stepType(for seed: SourceAtlasStepCandidateSeedTrace) -> StepType {
        switch seed.seedKind {
        case "proof":
            return .learningCheckpoint
        case "prerequisite", "admin":
            return .supportAction
        case "learning", "review":
            return .reflectionPrompt
        case "recovery":
            return .observationPrompt
        default:
            return .actionUnit
        }
    }


    func pace(for seed: SourceAtlasStepCandidateSeedTrace, path: SourceAtlasCapabilityPath) -> PlanningPace {
        if path.planSkeleton.feasibilityBand == .impossibleUnderCurrentConstraints || path.planSkeleton.feasibilityBand == .atRisk {
            return .deadline
        }
        switch seed.seedKind {
        case "proof", "review":
            return .targeted
        case "recovery":
            return .untimed
        default:
            return .ongoing
        }
    }


    func title(for seed: SourceAtlasStepCandidateSeedTrace, selectedPath: SourceAtlasCapabilityPath) -> String {
        let text = seed.seedText.isEmpty ? selectedPath.pathSummary : seed.seedText
        switch stepKind(for: seed) {
        case .proofGathering:
            return "Gather proof for \(text)"
        case .prerequisite:
            return "Do the prerequisite for \(text)"
        case .adminSetup:
            return "Set up the conditions for \(text)"
        case .learningResearch:
            return "Learn what is needed before \(text)"
        case .recoverySafe:
            return "Do a recovery-safe version of \(text)"
        case .catchUp:
            return "Catch up on \(text)"
        default:
            return text
        }
    }


    func summary(for seed: SourceAtlasStepCandidateSeedTrace, selectedPath: SourceAtlasCapabilityPath) -> String {
        switch stepKind(for: seed) {
        case .proofGathering:
            return "Collects proof before the path expands."
        case .prerequisite:
            return "Finishes the dependency before the main step."
        case .adminSetup:
            return "Prepares the conditions for a later pass."
        case .learningResearch:
            return "Clarifies the missing information first."
        case .recoverySafe:
            return "Stays conservative and gentle on recovery."
        case .catchUp:
            return "Recovers momentum without pretending the delay disappeared."
        case .directBest:
            return "Best fit from the selected Source Atlas path."
        case .lighter, .shorter, .lowerEnergy, .locationCompatible, .noEquipment, .maintenance, .substitution, .parallelPath, .fallback:
            return "Source Atlas generated a safe path-backed step."
        }
    }


    func evidenceHint(for seed: SourceAtlasStepCandidateSeedTrace, selectedPath: SourceAtlasCapabilityPath) -> String {
        if seed.sourceRequirementIDs.isEmpty == false {
            return "Requirement-backed from \(selectedPath.id)."
        }
        if seed.sourceNodeIDs.isEmpty == false {
            return "Node-backed from \(selectedPath.id)."
        }
        return "Path-backed from \(selectedPath.id)."
    }


    func contextRequirements(for seed: SourceAtlasStepCandidateSeedTrace, selectedPath: SourceAtlasCapabilityPath, pack: SourceAtlasPack) -> [String] {
        var requirements: [String] = []
        if seed.sourceNodeIDs.isEmpty == false {
            requirements.append(contentsOf: seed.sourceNodeIDs.map { "Source node: \($0)" })
        }
        if seed.sourceRequirementIDs.isEmpty == false {
            requirements.append(contentsOf: seed.sourceRequirementIDs.map { "Source requirement: \($0)" })
        }
        if selectedPath.missingSourceNodes.isEmpty == false {
            requirements.append("Review missing source nodes before expanding the path.")
        }
        if pack.requirements.contains(where: { $0.kind == .equipment }) && seed.seedKind == "admin" {
            requirements.append("Local setup is required.")
        }
        return uniqueStrings(requirements)
    }


    func repeatEveryDays(for seed: SourceAtlasStepCandidateSeedTrace, path: SourceAtlasCapabilityPath) -> Int? {
        switch seed.seedKind {
        case "proof":
            return 5
        case "prerequisite", "admin":
            return 7
        case "recovery":
            return 4
        case "deadline":
            return 3
        case "starter":
            return 6
        default:
            return path.planSkeleton.feasibilityBand == .atRisk ? 5 : nil
        }
    }


    func sourceFreshnessWarnings(
        path: SourceAtlasCapabilityPath,
        projection: LifeContextRuntimeProjection?
    ) -> [String] {
        var warnings = path.staleNodes.map { "Stale node: \($0)" }
        warnings.append(contentsOf: path.missingSourceNodes.map { "Missing source node: \($0)" })
        if let projection {
            warnings.append(contentsOf: projection.sourceFreshnessSummary.compactMap { summary in
                guard summary.freshness != .current else { return nil }
                let label = redactIfSensitive(summary.label) ?? summary.label
                return "\(label): \(summary.freshness.rawValue)"
            })
        }
        return uniqueStrings(warnings)
    }


    func redactIfSensitive(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        if trimmed.localizedCaseInsensitiveContains("private") || trimmed.localizedCaseInsensitiveContains("secret") {
            return "[redacted]"
        }
        return trimmed
    }


    func uniqueStrings(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }


    func stableIdentifier(prefix: String, components: [String]) -> String {
        CandidateSource.stableIdentifier(prefix: prefix, components: components)
    }
}
