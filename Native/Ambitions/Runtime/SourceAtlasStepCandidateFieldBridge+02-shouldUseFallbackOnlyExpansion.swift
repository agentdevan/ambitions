import Foundation

extension SourceAtlasStepCandidateFieldBridge {
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
}
