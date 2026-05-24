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
                lifeContextProjection: lifeContextProjection
            )
        let effectiveSeedTraces = seedTraces.isEmpty
            ? [makeFallbackSeedTrace(
                composition: composition,
                pack: pack,
                sourcePath: sourcePath,
                lifeContextProjection: lifeContextProjection
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
            lifeContextProjection: lifeContextProjection
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
            lifeContextProjection: lifeContextProjection
        )

        return rebuildField(
            generated,
            sourceAtlasExpansionTrace: finalTrace
        )
    }
}

private extension SourceAtlasStepCandidateFieldBridge {
    func shouldUseFallbackOnlyExpansion(
        sourcePath: SourceAtlasCapabilityPath,
        pack: SourceAtlasPack
    ) -> Bool {
        if sourcePath.capabilityGraphID == "source-atlas.graph.fallback" {
            return true
        }
        return pack.sources.isEmpty &&
            pack.claims.isEmpty &&
            pack.requirements.isEmpty &&
            pack.starterItems.isEmpty &&
            pack.proofMap.isEmpty &&
            pack.capabilityGraphs.isEmpty
    }

    func makeCompilerOutput(
        goalID: String,
        composition: PersonalPathComposition,
        generatedAt: String,
        compiledSteps: [CompiledStep]
    ) -> GoalIntentDayCompilerOutput {
        let intent = GoalIntent(
            id: stableIdentifier(prefix: "source-atlas.intent", components: [goalID, composition.selectedPath.id]),
            rawStatement: composition.explanationProjection.summary,
            createdAt: generatedAt,
            sourceSurface: .path,
            userKnownContext: [],
            privacyClass: .localOnly,
            sourceState: .path
        )
        return GoalIntentDayCompilerOutput(
            intent: intent,
            compiledAt: generatedAt,
            status: compiledSteps.isEmpty ? .blocked : .clear,
            clarification: GoalIntentClarification(
                status: compiledSteps.isEmpty ? .blocked : .clear,
                readiness: compiledSteps.isEmpty ? .needsClarification : .canPlanWithDefaults
            ),
            capacityEnvelope: nil,
            compiledSteps: compiledSteps,
            receipts: [],
            localOnly: true
        )
    }

    func makeSeedTraces(
        composition: PersonalPathComposition,
        pack: SourceAtlasPack,
        sourcePath: SourceAtlasCapabilityPath,
        lifeContextProjection: LifeContextRuntimeProjection?
    ) -> [SourceAtlasStepCandidateSeedTrace] {
        let sourcePackID = pack.id
        let sourcePathID = sourcePath.id
        let sourcePathOverlayIDs = sourcePath.selectedPathOverlayIDs
        let sourceRecordIDs = pack.sources.map(\.id)
        let sourceClaimIDs = pack.claims.map(\.id)
        let freshnessWarnings = sourceFreshnessWarnings(
            path: sourcePath,
            projection: lifeContextProjection
        )
        let redactions: [String] = [
            sourcePath.pathSummary,
            composition.explanationProjection.summary
        ]
        .compactMap(redactIfSensitive(_:))

        var traces: [SourceAtlasStepCandidateSeedTrace] = []

        for node in pathNodes(for: sourcePath, pack: pack) {
            traces.append(
                SourceAtlasStepCandidateSeedTrace(
                    id: stableIdentifier(prefix: "source-atlas.seed.node", components: [sourcePathID, node.id]),
                    sourcePackID: sourcePackID,
                    sourcePathID: sourcePathID,
                    sourcePathOverlayIDs: sourcePathOverlayIDs,
                    sourceNodeIDs: [node.id],
                    sourceRequirementIDs: requirementIDs(for: node, in: sourcePath, pack: pack),
                    sourceProofRequirementIDs: proofRequirementIDs(for: node, in: sourcePath, pack: pack),
                    sourceStarterItemIDs: [],
                    seedKind: nodeSeedKind(for: node, sourcePath: sourcePath),
                    seedText: redactIfSensitive(node.title + " " + node.summary) ?? node.title,
                    sourceRecordIDs: node.sourceRecordIDs.isEmpty ? sourceRecordIDs : node.sourceRecordIDs,
                    sourceClaimIDs: sourceClaimIDs,
                    freshnessWarnings: freshnessWarnings,
                    sensitiveContextRedactions: redactions
                )
            )
        }

        for requirement in sourcePath.requirementProjection.allRequirements {
            traces.append(
                SourceAtlasStepCandidateSeedTrace(
                    id: stableIdentifier(prefix: "source-atlas.seed.requirement", components: [sourcePathID, requirement.id]),
                    sourcePackID: sourcePackID,
                    sourcePathID: sourcePathID,
                    sourcePathOverlayIDs: sourcePathOverlayIDs,
                    sourceNodeIDs: [],
                    sourceRequirementIDs: [requirement.id],
                    sourceProofRequirementIDs: requirement.kind == .proof ? [requirement.id] : [],
                    sourceStarterItemIDs: [],
                    seedKind: requirementSeedKind(for: requirement),
                    seedText: redactIfSensitive(requirement.title) ?? requirement.title,
                    sourceRecordIDs: sourceRecordIDs,
                    sourceClaimIDs: sourceClaimIDs,
                    freshnessWarnings: freshnessWarnings,
                    sensitiveContextRedactions: redactions
                )
            )
        }

        for proof in pack.proofMap.filter({ sourcePath.requirementProjection.proofNeeds.map(\.id).contains($0.requirementID) || $0.capabilityNodeID.map({ sourcePath.selectedNodeIDs.contains($0) }) == true }) {
            traces.append(
                SourceAtlasStepCandidateSeedTrace(
                    id: stableIdentifier(prefix: "source-atlas.seed.proof", components: [sourcePathID, proof.id]),
                    sourcePackID: sourcePackID,
                    sourcePathID: sourcePathID,
                    sourcePathOverlayIDs: sourcePathOverlayIDs,
                    sourceNodeIDs: proof.capabilityNodeID.map { [$0] } ?? [],
                    sourceRequirementIDs: [proof.requirementID],
                    sourceProofRequirementIDs: [proof.requirementID],
                    sourceStarterItemIDs: [],
                    seedKind: "proof",
                    seedText: redactIfSensitive(proof.proofDescription) ?? proof.proofDescription,
                    sourceRecordIDs: proof.sourceRecordIDs.isEmpty ? sourceRecordIDs : proof.sourceRecordIDs,
                    sourceClaimIDs: proof.sourceClaimIDs.isEmpty ? sourceClaimIDs : proof.sourceClaimIDs,
                    freshnessWarnings: freshnessWarnings,
                    sensitiveContextRedactions: redactions
                )
            )
        }

        for starter in pack.starterItems {
            traces.append(
                SourceAtlasStepCandidateSeedTrace(
                    id: stableIdentifier(prefix: "source-atlas.seed.starter", components: [sourcePathID, starter.id]),
                    sourcePackID: sourcePackID,
                    sourcePathID: sourcePathID,
                    sourcePathOverlayIDs: sourcePathOverlayIDs,
                    sourceNodeIDs: [],
                    sourceRequirementIDs: [],
                    sourceProofRequirementIDs: [],
                    sourceStarterItemIDs: [starter.id],
                    seedKind: "starter",
                    seedText: redactIfSensitive(starter.stepCandidateSeed) ?? starter.stepCandidateSeed,
                    sourceRecordIDs: sourceRecordIDs,
                    sourceClaimIDs: sourceClaimIDs,
                    freshnessWarnings: freshnessWarnings,
                    sensitiveContextRedactions: redactions
                )
            )
        }

        for milestone in sourcePath.planSkeleton.milestones {
            traces.append(
                SourceAtlasStepCandidateSeedTrace(
                    id: stableIdentifier(prefix: "source-atlas.seed.milestone", components: [sourcePathID, milestone.id]),
                    sourcePackID: sourcePackID,
                    sourcePathID: sourcePathID,
                    sourcePathOverlayIDs: sourcePathOverlayIDs,
                    sourceNodeIDs: milestone.nodeIDs,
                    sourceRequirementIDs: milestone.requirementIDs,
                    sourceProofRequirementIDs: milestone.proofRequired ? milestone.requirementIDs : [],
                    sourceStarterItemIDs: [],
                    seedKind: milestone.kind.rawValue,
                    seedText: redactIfSensitive(milestone.title + " " + milestone.detail) ?? milestone.title,
                    sourceRecordIDs: sourceRecordIDs,
                    sourceClaimIDs: sourceClaimIDs,
                    freshnessWarnings: freshnessWarnings,
                    sensitiveContextRedactions: redactions
                )
            )
        }

        return traces.sorted { lhs, rhs in
            if lhs.seedKind != rhs.seedKind { return lhs.seedKind < rhs.seedKind }
            return lhs.id < rhs.id
        }
    }

    func makeFallbackSeedTrace(
        composition: PersonalPathComposition,
        pack: SourceAtlasPack,
        sourcePath: SourceAtlasCapabilityPath,
        lifeContextProjection: LifeContextRuntimeProjection?
    ) -> SourceAtlasStepCandidateSeedTrace {
        let warnings = sourceFreshnessWarnings(path: sourcePath, projection: lifeContextProjection)
        return SourceAtlasStepCandidateSeedTrace(
            id: stableIdentifier(prefix: "source-atlas.seed.fallback", components: [composition.goalID, pack.id, sourcePath.id]),
            sourcePackID: pack.id,
            sourcePathID: sourcePath.id,
            sourcePathOverlayIDs: sourcePath.selectedPathOverlayIDs,
            sourceNodeIDs: sourcePath.selectedNodeIDs,
            sourceRequirementIDs: sourcePath.requirementProjection.allRequirements.map(\.id),
            sourceProofRequirementIDs: sourcePath.requirementProjection.proofNeeds.map(\.id),
            sourceStarterItemIDs: [],
            seedKind: "fallback",
            seedText: "Keep the goal open and review the next step.",
            sourceRecordIDs: pack.sources.map(\.id),
            sourceClaimIDs: pack.claims.map(\.id),
            freshnessWarnings: warnings,
            sensitiveContextRedactions: ["[redacted]"]
        )
    }

    func makeCompiledSteps(
        seedTraces: [SourceAtlasStepCandidateSeedTrace],
        composition: PersonalPathComposition,
        pack: SourceAtlasPack,
        generatedAt: String,
        deadlineTargetDate: String?
    ) -> [CompiledStep] {
        var steps: [CompiledStep] = []
        let selectedPath = composition.selectedPath

        for (index, seed) in seedTraces.enumerated() {
            guard let step = compiledStep(
                for: seed,
                selectedPath: selectedPath,
                pack: pack,
                generatedAt: generatedAt,
                deadlineTargetDate: deadlineTargetDate,
                orderIndex: index
            ) else {
                continue
            }
            steps.append(step)
        }

        if steps.isEmpty {
            steps.append(
                CompiledStep(
                    id: stableIdentifier(prefix: "source-atlas.compiled-step", components: [selectedPath.id, "fallback"]),
                    intentID: composition.goalID,
                    sourceCandidateID: nil,
                    sourceStageID: nil,
                    title: "Keep the goal open and review the next step.",
                    summary: "The Source Atlas path did not yield a safe source-backed step.",
                    orderIndex: 0,
                    stepType: .reflectionPrompt,
                    pace: .untimed,
                    evidenceHint: "The runtime is missing enough source detail to expand this path.",
                    contextRequirements: ["Review the source path before taking action."],
                    isOptional: true,
                    isRepeatable: false,
                    isExecutable: false
                )
            )
        }

        return steps
    }

    func compiledStep(
        for seed: SourceAtlasStepCandidateSeedTrace,
        selectedPath: SourceAtlasCapabilityPath,
        pack: SourceAtlasPack,
        generatedAt: String,
        deadlineTargetDate: String?,
        orderIndex: Int
    ) -> CompiledStep? {
        let stepKind = stepKind(for: seed)
        let stepType = stepType(for: seed)
        let pace = pace(for: seed, path: selectedPath)
        let title = title(for: seed, selectedPath: selectedPath)
        let summary = summary(for: seed, selectedPath: selectedPath)
        let contextRequirements = contextRequirements(for: seed, selectedPath: selectedPath, pack: pack)
        let evidenceHint = evidenceHint(for: seed, selectedPath: selectedPath)
        let repeatEveryDays = repeatEveryDays(for: seed, path: selectedPath)
        let sourceCandidateID = seed.id
        let sourceStageID = stableIdentifier(prefix: "source-atlas.stage", components: [seed.id, seed.seedKind, stepKind.rawValue])

        return CompiledStep(
            id: stableIdentifier(prefix: "source-atlas.compiled-step", components: [seed.id, stepKind.rawValue, title, summary]),
            intentID: selectedPath.id,
            sourceCandidateID: sourceCandidateID,
            sourceStageID: sourceStageID,
            title: title,
            summary: summary,
            orderIndex: orderIndex,
            stepType: stepType,
            pace: pace,
            targetDate: deadlineTargetDate,
            repeatEveryDays: repeatEveryDays,
            evidenceHint: evidenceHint,
            contextRequirements: contextRequirements,
            isOptional: seed.seedKind == "starter" || seed.seedKind == "recovery",
            isRepeatable: repeatEveryDays != nil,
            isExecutable: seed.seedKind != "blocked" && seed.seedText.isEmpty == false,
            blockingReasonIDs: seed.freshnessWarnings,
            assumptionIDs: seed.sourceProofRequirementIDs,
            clarificationQuestionIDs: seed.sensitiveContextRedactions
        )
    }

    func makeExpandedCandidateTraces(
        field: StepCandidateField,
        seedTraces: [SourceAtlasStepCandidateSeedTrace],
        composition: PersonalPathComposition,
        pack: SourceAtlasPack
    ) -> [SourceAtlasStepExpansionCandidateTrace] {
        let seedByID = Dictionary(uniqueKeysWithValues: seedTraces.map { ($0.id, $0) })
        return field.candidates.compactMap { candidate in
            guard let seed = seedByID[candidate.sourceCandidateID ?? candidate.sourceStepID] ?? seedByID[candidate.sourceStepID] else {
                return nil
            }

            return SourceAtlasStepExpansionCandidateTrace(
                id: candidate.id,
                sourceSeedID: seed.id,
                candidateID: candidate.id,
                sourcePackID: seed.sourcePackID,
                sourcePathID: seed.sourcePathID,
                sourcePathOverlayIDs: seed.sourcePathOverlayIDs,
                sourceNodeIDs: seed.sourceNodeIDs,
                sourceRequirementIDs: seed.sourceRequirementIDs,
                sourceProofRequirementIDs: seed.sourceProofRequirementIDs,
                sourceStarterItemIDs: seed.sourceStarterItemIDs,
                candidateKindRawValue: candidate.kind.rawValue,
                candidateSourceRawValue: candidate.source.rawValue,
                title: candidate.title,
                summary: candidate.summary,
                deadlineProtecting: candidate.impactSimulation.goalTimeline.planRisk.deadlinePressureDelta != .delayed &&
                    candidate.impactSimulation.goalTimeline.planRisk.deadlinePressureDelta != .threatensProtectedTime &&
                    candidate.impactSimulation.goalTimeline.planRisk.deadlinePressureDelta != .impossible,
                sourceRecordIDs: seed.sourceRecordIDs,
                sourceClaimIDs: seed.sourceClaimIDs
            )
        }
    }

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
