import Foundation

protocol PathIntelligenceProjecting: Sendable {
    func project(
        compiledPath: GoalCompiledPath,
        resourceGraph: GoalResourceGraph?
    ) -> PathIntelligenceProjection
}

struct DefaultPathIntelligenceProjector: PathIntelligenceProjecting {
    func project(
        compiledPath: GoalCompiledPath,
        resourceGraph: GoalResourceGraph? = nil
    ) -> PathIntelligenceProjection {
        let primary = compiledPath.candidates.first(where: \.isPrimary) ?? compiledPath.candidates.first
        let boundaries = sourceBoundaries(
            compiledPath: compiledPath,
            primary: primary,
            resourceGraph: resourceGraph
        )
        let proofRequirements = proofRequirements(for: primary)
        let fallbackPaths = fallbackPaths(for: primary)

        return PathIntelligenceProjection(
            schemaVersion: pathIntelligenceSchemaVersion,
            sourceCompiledPathSchemaVersion: compiledPath.schemaVersion,
            primaryCandidateID: primary?.id,
            overallPosture: compiledPath.overallPosture,
            families: familySignals(for: primary),
            stages: stageProjections(for: primary),
            assumptions: assumptionProjections(for: primary),
            proofRequirements: proofRequirements,
            fallbackPaths: fallbackPaths,
            sourceBoundaries: boundaries,
            futureSelfScenarios: futureSelfScenarios(
                primary: primary,
                proofRequirements: proofRequirements,
                fallbackPaths: fallbackPaths
            ),
            dailyConnection: dailyConnection(
                primary: primary,
                proofRequirements: proofRequirements,
                fallbackPaths: fallbackPaths
            )
        )
    }
}

private extension DefaultPathIntelligenceProjector {
    func familySignals(for primary: GoalCompiledPathCandidate?) -> [PathIntelligenceFamilySignal] {
        guard let primary else {
            return [
                PathIntelligenceFamilySignal(
                    id: "family-general",
                    family: .generalProject,
                    summary: "Use a general path until the goal has enough shape.",
                    sourceKind: .userOwnedGoal,
                    freshnessLabel: .mayNeedReview
                )
            ]
        }

        let packSignals = primary.appliedPacks.flatMap { pack in
            pack.matchedDomains.map { domain in
                PathIntelligenceFamilySignal(
                    id: "family-\(pack.packID)-\(domain.rawValue)",
                    family: family(for: domain),
                    summary: "\(pack.displayName) supports this as a qualitative path family.",
                    sourceKind: .domainPack,
                    freshnessLabel: pack.provisional ? .mayNeedReview : .current
                )
            }
        }

        if packSignals.isEmpty == false {
            return stableUnique(packSignals)
        }

        return [
            PathIntelligenceFamilySignal(
                id: "family-general",
                family: .generalProject,
                summary: "Use a general project path until a more specific family is confirmed.",
                sourceKind: .userOwnedGoal,
                freshnessLabel: primary.posture == .stronger ? .current : .mayNeedReview
            )
        ]
    }

    func family(for domain: LifeDomainKey) -> PathIntelligenceFamily {
        switch domain {
        case .career: return .career
        case .education: return .learning
        case .health: return .health
        case .finance: return .finance
        case .home: return .homeAndLifeAdmin
        case .relationships: return .relationship
        case .creativity: return .creativeProject
        case .personalGrowth: return .personalGrowth
        }
    }

    func stageProjections(for primary: GoalCompiledPathCandidate?) -> [PathIntelligenceStageProjection] {
        guard let primary else { return [] }
        let dependenciesByID = Dictionary(uniqueKeysWithValues: primary.dependencies.map { ($0.id, $0) })

        return primary.stages
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { stage in
                let dependencies = stage.dependencyIDs.compactMap { dependenciesByID[$0] }
                let blockingDependency = dependencies.first(where: \.blocking)
                let blockingRequirement = primary.requirementHints.first {
                    $0.relatedStageID == stage.id && $0.blocking
                }

                return PathIntelligenceStageProjection(
                    id: stage.id,
                    title: stage.title,
                    summary: stage.summary,
                    orderIndex: stage.orderIndex,
                    kind: stage.kind,
                    prerequisiteHints: stage.prerequisiteHints,
                    dependencySummaries: dependencies.map(\.summary),
                    readinessHints: stage.readinessHints,
                    waitingStateSummary: blockingDependency?.summary ?? blockingRequirement?.summary
                )
            }
    }

    func assumptionProjections(for primary: GoalCompiledPathCandidate?) -> [PathIntelligenceAssumptionProjection] {
        (primary?.assumptions ?? []).map {
            PathIntelligenceAssumptionProjection(
                id: $0.id,
                summary: $0.summary,
                rationale: $0.rationale,
                correctionPrompt: "Update this assumption before Ambitions treats the path as stronger.",
                freshnessLabel: $0.safeForCompilation ? .mayNeedReview : .basedOnOlderContext
            )
        }
        .sorted { $0.id < $1.id }
    }

    func proofRequirements(for primary: GoalCompiledPathCandidate?) -> [PathIntelligenceProofRequirement] {
        guard let primary else { return [] }
        var requirements: [PathIntelligenceProofRequirement] = []

        for stage in primary.stages where stage.kind == .firstProof || stage.kind == .reviewFinish {
            requirements.append(
                PathIntelligenceProofRequirement(
                    id: "proof-\(stage.id)",
                    stageID: stage.id,
                    summary: stage.kind == .firstProof
                        ? "Save one visible proof that this path is working."
                        : "Save what changed before deciding whether to finish or branch.",
                    proofKind: stage.kind == .firstProof ? .milestoneEvidence : .reflection,
                    handoffSurface: .proof
                )
            )
        }

        for criterion in primary.readinessCriteria where criterion.blocking {
            requirements.append(
                PathIntelligenceProofRequirement(
                    id: "proof-\(criterion.id)",
                    stageID: criterion.targetStageID ?? primary.stages.first?.id ?? "stage-unknown",
                    summary: "Confirm readiness before treating this path as stronger: \(criterion.summary).",
                    proofKind: .decision,
                    handoffSurface: .goalDetail
                )
            )
        }

        return stableUnique(requirements)
    }

    func fallbackPaths(for primary: GoalCompiledPathCandidate?) -> [PathIntelligenceFallbackPath] {
        (primary?.branches ?? [])
            .filter { $0.branchType == .fallback || $0.branchType == .blocked || $0.branchType == .alternateInterpretation }
            .map {
                PathIntelligenceFallbackPath(
                    id: $0.id,
                    summary: $0.summary,
                    condition: $0.condition,
                    targetStageID: $0.targetStageID,
                    posture: $0.posture
                )
            }
            .sorted { $0.id < $1.id }
    }

    func sourceBoundaries(
        compiledPath: GoalCompiledPath,
        primary: GoalCompiledPathCandidate?,
        resourceGraph: GoalResourceGraph?
    ) -> [PathIntelligenceSourceBoundary] {
        var boundaries: [PathIntelligenceSourceBoundary] = [
            PathIntelligenceSourceBoundary(
                id: "source-compiled-path",
                sourceKind: .userOwnedGoal,
                freshnessLabel: compiledPath.overallPosture == .stronger ? .current : .mayNeedReview,
                summary: "Built from the current local goal understanding and path compiler.",
                sourceIDs: compiledPath.audit.entries.map(\.id).sorted()
            )
        ]

        boundaries += (primary?.assumptions ?? []).map {
            PathIntelligenceSourceBoundary(
                id: "source-assumption-\($0.id)",
                sourceKind: .assumption,
                freshnessLabel: $0.safeForCompilation ? .mayNeedReview : .basedOnOlderContext,
                summary: $0.summary,
                sourceIDs: [$0.id]
            )
        }

        boundaries += (primary?.appliedPacks ?? []).map {
            PathIntelligenceSourceBoundary(
                id: "source-pack-\($0.packID)",
                sourceKind: .domainPack,
                freshnessLabel: $0.provisional ? .mayNeedReview : .current,
                summary: "\($0.displayName) is a broad path-family hint, not professional advice.",
                sourceIDs: [$0.packID]
            )
        }

        if let resourceGraph {
            boundaries.append(
                PathIntelligenceSourceBoundary(
                    id: "source-external-knowledge",
                    sourceKind: .externalKnowledge,
                    freshnessLabel: freshnessLabel(for: resourceGraph.freshness.overallPosture),
                    summary: "External or static knowledge must stay source-labeled and reviewable before it shapes advice.",
                    sourceIDs: resourceGraph.sources.map(\.sourceRecordID).sorted()
                )
            )
        }

        return stableUnique(boundaries)
    }

    func freshnessLabel(for posture: GoalFreshnessPosture) -> PathIntelligenceFreshnessLabel {
        switch posture {
        case .currentEnough, .aging:
            return .current
        case .stale, .unknownFreshness:
            return .mayNeedReview
        case .expired, .blockedMissingEvidence, .providerUnavailable:
            return .basedOnOlderContext
        }
    }

    func futureSelfScenarios(
        primary: GoalCompiledPathCandidate?,
        proofRequirements: [PathIntelligenceProofRequirement],
        fallbackPaths: [PathIntelligenceFallbackPath]
    ) -> [FutureSelfScenario] {
        guard let primary else { return [] }
        let assumptions = primary.assumptions.map(\.id).sorted()
        var scenarios: [FutureSelfScenario] = [
            FutureSelfScenario(
                id: "scenario-continue-\(primary.id)",
                kind: .continueCurrentPath,
                title: "If this path holds",
                summary: proofRequirements.first?.summary ?? "Keep the current path as a scenario to review after the next proof.",
                assumptionIDs: assumptions,
                notPredictionLabel: "Scenario, not prediction",
                handoffSurface: .goalDetail
            ),
            FutureSelfScenario(
                id: "scenario-smaller-\(primary.id)",
                kind: .smallerFirstMove,
                title: "If the next move feels too large",
                summary: "Use the smallest readiness move before deeper commitment.",
                assumptionIDs: assumptions,
                notPredictionLabel: "Scenario, not prediction",
                handoffSurface: .today
            )
        ]

        if let fallback = fallbackPaths.first {
            scenarios.append(
                FutureSelfScenario(
                    id: "scenario-fallback-\(fallback.id)",
                    kind: .fallbackPath,
                    title: "If the path needs to change",
                    summary: fallback.condition,
                    assumptionIDs: assumptions,
                    notPredictionLabel: "Scenario, not prediction",
                    handoffSurface: .plan
                )
            )
        }

        if primary.blockingReasons.isEmpty == false {
            scenarios.append(
                FutureSelfScenario(
                    id: "scenario-waiting-\(primary.id)",
                    kind: .waitingReview,
                    title: "If this stays blocked",
                    summary: "Review the blocking question before asking Today to protect a next move.",
                    assumptionIDs: assumptions,
                    notPredictionLabel: "Scenario, not prediction",
                    handoffSurface: .plan
                )
            )
        }

        return scenarios
    }

    func dailyConnection(
        primary: GoalCompiledPathCandidate?,
        proofRequirements: [PathIntelligenceProofRequirement],
        fallbackPaths: [PathIntelligenceFallbackPath]
    ) -> PathIntelligenceDailyConnection {
        guard let primary else {
            return PathIntelligenceDailyConnection(
                stageID: nil,
                nextStepTitle: "Clarify the path before choosing a next step.",
                owningSurface: .plan,
                proofHint: nil,
                fallbackHint: nil
            )
        }

        let nextStage = primary.stages.sorted { $0.orderIndex < $1.orderIndex }.first
        return PathIntelligenceDailyConnection(
            stageID: nextStage?.id,
            nextStepTitle: nextStage.map { "Start with \(displayTitle($0.title))." } ?? "Clarify the path before choosing a next step.",
            owningSurface: primary.safeForStarterPlanning ? .today : .plan,
            proofHint: proofRequirements.first?.summary,
            fallbackHint: fallbackPaths.first?.condition
        )
    }

    func displayTitle(_ title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return "the smallest visible move" }
        return trimmed.prefix(1).lowercased() + trimmed.dropFirst()
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
}
