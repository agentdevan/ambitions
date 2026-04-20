import Foundation

protocol GoalDomainPackApplying: Sendable {
    func applyPacks(to compiledPath: GoalCompiledPath, understanding: GoalUnderstanding) -> GoalCompiledPath
}

struct DefaultGoalDomainPackService: GoalDomainPackApplying {
    private let packs: [any GoalDomainPack]

    init(packs: [any GoalDomainPack] = [CareerGoalDomainPack(), EducationGoalDomainPack()]) {
        self.packs = packs
    }

    func applyPacks(to compiledPath: GoalCompiledPath, understanding: GoalUnderstanding) -> GoalCompiledPath {
        let matches = matchedPacks(for: understanding)
        guard matches.isEmpty == false else {
            return compiledPath
        }

        let enrichedCandidates = compiledPath.candidates.map { candidate in
            enrich(candidate: candidate, understanding: understanding, matches: matches)
        }

        let packEntries = compiledPath.audit.packEntries + enrichedCandidates.flatMap(\.packAuditEntries)

        return GoalCompiledPath(
            schemaVersion: compiledPath.schemaVersion,
            sourceUnderstandingSchemaVersion: compiledPath.sourceUnderstandingSchemaVersion,
            overallPosture: compiledPath.overallPosture,
            safeForStarterPlanning: compiledPath.safeForStarterPlanning,
            candidates: enrichedCandidates.map(\.candidate),
            uncertainty: compiledPath.uncertainty,
            audit: GoalCompiledPathAuditMetadata(
                entries: compiledPath.audit.entries,
                packEntries: stableUnique(packEntries)
            )
        )
    }
}

private extension DefaultGoalDomainPackService {
    struct MatchedPack {
        let pack: any GoalDomainPack
        let match: GoalDomainPackMatch
    }

    struct EnrichedCandidateResult {
        let candidate: GoalCompiledPathCandidate
        let packAuditEntries: [GoalCompiledPathPackAuditEntry]
    }

    func matchedPacks(for understanding: GoalUnderstanding) -> [MatchedPack] {
        packs.compactMap { pack in
            guard let match = pack.match(understanding: understanding) else { return nil }
            return MatchedPack(pack: pack, match: match)
        }
        .sorted { lhs, rhs in
            GoalDomainPackMatch.stableOrdering(lhs.match, rhs.match)
        }
    }

    func enrich(
        candidate: GoalCompiledPathCandidate,
        understanding: GoalUnderstanding,
        matches: [MatchedPack]
    ) -> EnrichedCandidateResult {
        var dependencies = candidate.dependencies
        var branches = candidate.branches
        var risks = candidate.risks
        var requirementHints = candidate.requirementHints
        var readinessCriteria = candidate.readinessCriteria
        var resourceHooks = candidate.resourceHooks
        var appliedPacks: [GoalCompiledPathAppliedPack] = []
        var packAuditEntries: [GoalCompiledPathPackAuditEntry] = []

        for matched in matches {
            let contribution = matched.pack.contribute(understanding: understanding, candidate: candidate)
            dependencies = stableUnique(dependencies + contribution.dependencyHints)
            branches = stableUnique(branches + contribution.branchAdditions)
            risks = stableUnique(risks + contribution.riskHints)
            requirementHints = stableUnique(requirementHints + contribution.requirementHints)
            readinessCriteria = stableUnique(readinessCriteria + contribution.readinessCriteria)
            resourceHooks = stableUnique(resourceHooks + contribution.resourceHooks)
            packAuditEntries = stableUnique(packAuditEntries + contribution.auditEntries)
            appliedPacks.append(
                GoalCompiledPathAppliedPack(
                    packID: matched.match.packID,
                    displayName: matched.pack.descriptor.displayName,
                    matchConfidence: matched.match.confidenceScore,
                    matchedDomains: matched.match.matchedDomains.sorted { $0.rawValue < $1.rawValue },
                    matchReasons: matched.match.reasons.sorted(),
                    provisional: matched.match.provisional
                )
            )
        }

        return EnrichedCandidateResult(
            candidate: GoalCompiledPathCandidate(
                id: candidate.id,
                title: candidate.title,
                summary: candidate.summary,
                isPrimary: candidate.isPrimary,
                posture: candidate.posture,
                safeForStarterPlanning: candidate.safeForStarterPlanning,
                stages: candidate.stages,
                dependencies: dependencies,
                branches: branches,
                assumptions: candidate.assumptions,
                risks: risks,
                appliedPacks: stableUnique(appliedPacks),
                requirementHints: requirementHints,
                readinessCriteria: readinessCriteria,
                resourceHooks: resourceHooks,
                blockingReasons: candidate.blockingReasons,
                confidence: candidate.confidence
            ),
            packAuditEntries: packAuditEntries
        )
    }

    func stableUnique<Value: Identifiable & Hashable>(_ values: [Value]) -> [Value] where Value.ID == String {
        let ordered = values.sorted { $0.id < $1.id }
        var result: [Value] = []
        var seen: Set<String> = []

        for value in ordered where seen.insert(value.id).inserted {
            result.append(value)
        }

        return result
    }

    func stableUnique(_ values: [GoalCompiledPathAppliedPack]) -> [GoalCompiledPathAppliedPack] {
        let ordered = values.sorted { lhs, rhs in
            if lhs.matchConfidence != rhs.matchConfidence {
                return lhs.matchConfidence > rhs.matchConfidence
            }
            return lhs.packID < rhs.packID
        }
        var result: [GoalCompiledPathAppliedPack] = []
        var seen: Set<String> = []

        for value in ordered where seen.insert(value.packID).inserted {
            result.append(value)
        }

        return result
    }
}
