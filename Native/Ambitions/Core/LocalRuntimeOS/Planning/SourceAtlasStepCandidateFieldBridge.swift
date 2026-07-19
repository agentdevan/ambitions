import Foundation

struct SourceAtlasStepCandidateFieldBridge: Sendable {
    private let generator = StepCandidateFieldGenerator()

    func expand(
        goalID: String? = nil,
        composition: PersonalPathComposition,
        pack: SourceAtlasPack,
        generatedAt: String,
        deadlineTargetDate: String? = nil,
        factorLedger: PersonalizationFactorLedger? = nil,
        lifeContextProjection: LifeContextRuntimeProjection? = nil,
        publicPlanningContext: SourceAtlasPublicPlanningContext? = nil,
        candidateLimit: Int = 24,
        localOnly: Bool = true
    ) -> StepCandidateField {
        let sourcePath = composition.selectedPath
        let fallbackOnly = shouldUseFallbackOnlyExpansion(sourcePath: sourcePath, pack: pack)
        let seedTraces = fallbackOnly
            ? []
            : makeSeedTraces(
                composition: composition,
                pack: pack,
                sourcePath: sourcePath,
                lifeContextProjection: lifeContextProjection,
                publicPlanningContext: publicPlanningContext
            )
        let effectiveSeedTraces = seedTraces.isEmpty
            ? [makeFallbackSeedTrace(
                composition: composition,
                pack: pack,
                sourcePath: sourcePath,
                lifeContextProjection: lifeContextProjection,
                publicPlanningContext: publicPlanningContext
            )]
            : seedTraces
        let compiledSteps = fallbackOnly
            ? []
            : makeCompiledSteps(
                seedTraces: seedTraces,
                composition: composition,
                pack: pack,
                generatedAt: generatedAt,
                deadlineTargetDate: deadlineTargetDate
            )
        let preliminaryTrace = makeExpansionTrace(
            seedTraces: effectiveSeedTraces,
            expandedCandidates: [],
            rejectedSeedTraces: [],
            composition: composition,
            pack: pack,
            factorLedger: factorLedger,
            lifeContextProjection: lifeContextProjection,
            publicPlanningContext: publicPlanningContext
        )

        let compilerOutput = compiledSteps.isEmpty
            ? nil
            : makeCompilerOutput(
                goalID: goalID ?? composition.goalID,
                composition: composition,
                generatedAt: generatedAt,
                compiledSteps: compiledSteps
            )

        let context = CandidateGenerationContext(
            goalID: goalID ?? composition.goalID,
            deadlineTargetDate: deadlineTargetDate,
            compilerOutput: compilerOutput,
            factorLedger: factorLedger,
            lifeContextProjection: lifeContextProjection,
            sourceAtlasExpansionTrace: preliminaryTrace,
            generatedAt: generatedAt,
            candidateLimit: candidateLimit,
            localOnly: localOnly
        )

        let generated = generator.generate(context)
        let expandedCandidateTraces = makeExpandedCandidateTraces(
            field: generated,
            seedTraces: effectiveSeedTraces,
            composition: composition,
            pack: pack
        )
        let rejectedSeedTraces = makeRejectedSeedTraces(
            seedTraces: effectiveSeedTraces,
            expandedCandidateTraces: expandedCandidateTraces,
            composition: composition,
            pack: pack
        )
        let finalTrace = makeExpansionTrace(
            seedTraces: effectiveSeedTraces,
            expandedCandidates: expandedCandidateTraces,
            rejectedSeedTraces: rejectedSeedTraces,
            composition: composition,
            pack: pack,
            factorLedger: factorLedger,
            lifeContextProjection: lifeContextProjection,
            publicPlanningContext: publicPlanningContext
        )

        return rebuildField(
            generated,
            sourceAtlasExpansionTrace: finalTrace
        )
    }
}
