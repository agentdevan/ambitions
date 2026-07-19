import Foundation

extension GoalCompiledPathCompilerCore {
    func compile(understanding: GoalUnderstanding) -> GoalCompiledPath {
        let overallPosture = posture(for: understanding)
        let starterSafe = understanding.readiness.safeToCompile
        let assumptions = understanding.assumptions.map {
            GoalCompiledPathAssumption(
                id: $0.id,
                summary: $0.summary,
                rationale: $0.rationale,
                confidence: $0.confidence,
                source: $0.source,
                relatedField: $0.relatedField,
                safeForCompilation: $0.safeForCompilation
            )
        }
        let risks = understanding.risks.map {
            GoalCompiledPathRisk(
                id: $0.id,
                summary: $0.summary,
                kind: $0.kind,
                severity: $0.severity
            )
        }
        let uncertainty = GoalCompiledPathUncertainty(
            ambiguityActive: ambiguityActive(in: understanding),
            missingContextFields: Array(Set(understanding.clarification.missingContext.compactMap(\.field))).sorted { $0.rawValue < $1.rawValue },
            unresolvedQuestionIDs: understanding.clarification.unresolvedQuestions.map(\.id),
            alternateInterpretationsActive: understanding.clarification.alternateInterpretationsActive,
            knowledgeContextAttached: understanding.audit.evidence.contains(where: { $0.origin == .knowledgeContext }),
            knowledgeContextRequired: false
        )
        let candidateInputs = [understanding.primaryInterpretation] + understanding.alternateInterpretations
        let candidates = candidateInputs.enumerated().map { index, interpretation in
            let isPrimary = index == 0
            let candidatePosture = candidatePosture(
                overallPosture: overallPosture,
                understanding: understanding,
                interpretation: interpretation,
                isPrimary: isPrimary
            )
            let stages = makeStages(
                understanding: understanding,
                interpretation: interpretation,
                posture: candidatePosture
            )
            let dependencies = makeDependencies(
                understanding: understanding,
                stages: stages
            )
            let branches = makeBranches(
                understanding: understanding,
                interpretation: interpretation,
                isPrimary: isPrimary,
                posture: candidatePosture,
                candidateID: candidateID(for: interpretation, isPrimary: isPrimary)
            )

            return GoalCompiledPathCandidate(
                id: candidateID(for: interpretation, isPrimary: isPrimary),
                title: isPrimary ? "Primary path" : "Alternate path",
                summary: candidateSummary(
                    understanding: understanding,
                    interpretation: interpretation,
                    isPrimary: isPrimary
                ),
                isPrimary: isPrimary,
                posture: candidatePosture,
                safeForStarterPlanning: starterSafe && candidatePosture != .blocked,
                stages: stages,
                dependencies: dependencies,
                branches: branches,
                assumptions: assumptions,
                risks: risks,
                appliedPacks: [],
                requirementHints: [],
                readinessCriteria: [],
                resourceHooks: [],
                blockingReasons: blockingReasons(from: understanding, posture: candidatePosture),
                confidence: GoalCompiledPathConfidence(
                    overall: understanding.confidence.overall,
                    score: confidenceScore(
                        understanding: understanding,
                        isPrimary: isPrimary
                    ),
                    uncertaintyTags: understanding.confidence.uncertaintyTags
                )
            )
        }

        let audit = GoalCompiledPathAuditMetadata(
            entries: makeAuditEntries(
                understanding: understanding,
                candidates: candidates
            ),
            packEntries: []
        )

        return GoalCompiledPath(
            schemaVersion: goalPathCompilerSchemaVersion,
            sourceUnderstandingSchemaVersion: understanding.schemaVersion,
            overallPosture: overallPosture,
            safeForStarterPlanning: starterSafe && overallPosture != .blocked,
            candidates: candidates,
            uncertainty: uncertainty,
            audit: audit
        )
    }


    func posture(for understanding: GoalUnderstanding) -> GoalPathCompilePosture {
        guard understanding.readiness.safeToCompile else {
            return .blocked
        }
        if ambiguityActive(in: understanding) ||
            understanding.assumptions.isEmpty == false ||
            understanding.risks.isEmpty == false {
            return .provisional
        }
        return .stronger
    }


    func ambiguityActive(in understanding: GoalUnderstanding) -> Bool {
        understanding.clarification.alternateInterpretationsActive ||
            understanding.timeline.unresolvedAmbiguity ||
            understanding.domains.isAmbiguous ||
            understanding.clarification.unresolvedQuestions.isEmpty == false ||
            understanding.clarification.missingContext.isEmpty == false ||
            understanding.confidence.uncertaintyTags.isEmpty == false
    }


    func candidatePosture(
        overallPosture: GoalPathCompilePosture,
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        isPrimary: Bool
    ) -> GoalPathCompilePosture {
        if overallPosture == .blocked {
            return .blocked
        }
        if isPrimary == false || understanding.alternateInterpretations.contains(interpretation) {
            return .provisional
        }
        return overallPosture
    }


    func candidateID(for interpretation: GoalUnderstandingInterpretation, isPrimary: Bool) -> String {
        isPrimary ? "candidate-\(interpretation.id)" : "candidate-alternate-\(interpretation.id)"
    }


    func candidateSummary(
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        isPrimary: Bool
    ) -> String {
        if isPrimary {
            return "Compile a conservative path from the primary interpretation without hiding remaining uncertainty."
        }
        return "Preserve an alternate structural path while ambiguity remains active: \(interpretation.summary)"
    }


    func makeStages(
        understanding: GoalUnderstanding,
        interpretation: GoalUnderstandingInterpretation,
        posture: GoalPathCompilePosture
    ) -> [GoalCompiledPathStage] {
        let subject = understanding.subject.normalizedTitle
        let stageKinds: [GoalCompiledPathStageKind] = [
            .setup,
            .readiness,
            .firstProof,
            .advancement,
            .reviewFinish
        ]
        let uncertaintyReasons = stageUncertaintyReasons(
            understanding: understanding,
            posture: posture
        )

        return stageKinds.enumerated().map { index, kind in
            let previousStageID = index > 0 ? stageID(for: interpretation, kind: stageKinds[index - 1]) : nil
            return GoalCompiledPathStage(
                id: stageID(for: interpretation, kind: kind),
                title: stageTitle(for: kind),
                summary: stageSummary(for: kind, subject: subject),
                orderIndex: index,
                kind: kind,
                dependencyIDs: previousStageID.map { [stageOrderingDependencyID(previousStageID: $0, nextStageID: stageID(for: interpretation, kind: kind))] } ?? [],
                prerequisiteHints: stagePrerequisiteHints(for: kind, understanding: understanding),
                readinessHints: stageReadinessHints(for: kind, understanding: understanding),
                uncertainBecause: uncertaintyReasons
            )
        }
    }


    func stageID(
        for interpretation: GoalUnderstandingInterpretation,
        kind: GoalCompiledPathStageKind
    ) -> String {
        "stage-\(interpretation.id)-\(kind.rawValue)"
    }


    func stageOrderingDependencyID(
        previousStageID: String,
        nextStageID: String
    ) -> String {
        "stage-order-\(previousStageID)-\(nextStageID)"
    }


    func stageTitle(for kind: GoalCompiledPathStageKind) -> String {
        switch kind {
        case .setup: return "Set up"
        case .readiness: return "Establish readiness"
        case .firstProof: return "Reach first proof"
        case .advancement: return "Advance"
        case .reviewFinish: return "Review and finish"
        }
    }


    func stageSummary(for kind: GoalCompiledPathStageKind, subject: String) -> String {
        switch kind {
        case .setup:
            return "Frame the goal and clarify what \(subject.lowercased()) is trying to achieve."
        case .readiness:
            return "Reduce the main readiness gaps before deeper commitment."
        case .firstProof:
            return "Produce the first visible proof that the path is working."
        case .advancement:
            return "Build on the first proof without pretending the path is final."
        case .reviewFinish:
            return "Review what changed and decide whether the path is strong enough to finish or should branch."
        }
    }


    func stagePrerequisiteHints(
        for kind: GoalCompiledPathStageKind,
        understanding: GoalUnderstanding
    ) -> [String] {
        switch kind {
        case .setup:
            return understanding.constraints.map(\.summary)
        case .readiness:
            return understanding.dependencies.map(\.summary)
        case .firstProof, .advancement, .reviewFinish:
            return []
        }
    }


    func stageReadinessHints(
        for kind: GoalCompiledPathStageKind,
        understanding: GoalUnderstanding
    ) -> [String] {
        switch kind {
        case .setup:
            return understanding.assumptions.map(\.summary)
        case .readiness:
            return understanding.risks.map(\.summary)
        case .firstProof:
            return understanding.successDefinition.summary.map { [$0] } ?? []
        case .advancement, .reviewFinish:
            return []
        }
    }
}
