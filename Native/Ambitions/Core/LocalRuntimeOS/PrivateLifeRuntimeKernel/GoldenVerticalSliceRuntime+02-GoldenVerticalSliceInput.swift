import Foundation

struct GoldenVerticalSliceInput: Sendable, Equatable, Identifiable {
    let id: String
    let endUserBackground: GoldenSliceEndUserBackground
    let intake: GoldenSliceGoalIntake
    let anyGoalInput: AnyGoalCoverageInput
    let stepQualityInput: StepQualityInput
    let latticeInput: MultiPathLatticeInput
    let compiledPath: GoalCompiledPath
    let selectedCompiledCandidateID: String?
    let graphReceiptID: String?
    let graphCompiledAt: String?
    let partialProgressProof: StepElasticityPartialProgressProof?
    let originalDurationMinutes: Int
    let availableMinutes: Int
    let elasticityCopyOverrides: [StepElasticityActionKind: StepElasticityActionCopy]
    let elasticityEvaluatedAt: String
    let selectedVariantID: String?
    let candidateWindows: [ScheduleInstallTimeWindow]
    let scheduleDecision: ScheduleInstallDecision?
    let rollbackPlan: ScheduleInstallRollbackPlan?
    let protectedTimeProof: ScheduleInstallProtectedTimeProof?
    let scheduleEvaluatedAt: String
    let consequenceImpacts: [LifeConsequenceImpact]
    let treaties: [LifeConsequenceGoalTreaty]
    let visibilityPreference: LifeConsequenceVisibilityPreference
    let consequenceEvaluatedAt: String
    let sourceAuthorityInspection: SourceAtlasAuthorityInspectionRecord?
    let safetyContext: HighRiskJurisdictionContext
    let safetyEvaluatedAt: String
    let completionProof: GoldenSliceCompletionProof
    let optionalShareProof: GoldenSliceOptionalShareProof?
    let replayOutput: GoldenSliceReplayOutput
    let localOnly: Bool

    init(
        id: String,
        endUserBackground: GoldenSliceEndUserBackground,
        intake: GoldenSliceGoalIntake,
        anyGoalInput: AnyGoalCoverageInput,
        stepQualityInput: StepQualityInput,
        latticeInput: MultiPathLatticeInput,
        compiledPath: GoalCompiledPath,
        selectedCompiledCandidateID: String?,
        graphReceiptID: String?,
        graphCompiledAt: String?,
        partialProgressProof: StepElasticityPartialProgressProof?,
        originalDurationMinutes: Int,
        availableMinutes: Int,
        elasticityCopyOverrides: [StepElasticityActionKind: StepElasticityActionCopy] = [:],
        elasticityEvaluatedAt: String,
        selectedVariantID: String?,
        candidateWindows: [ScheduleInstallTimeWindow],
        scheduleDecision: ScheduleInstallDecision?,
        rollbackPlan: ScheduleInstallRollbackPlan?,
        protectedTimeProof: ScheduleInstallProtectedTimeProof?,
        scheduleEvaluatedAt: String,
        consequenceImpacts: [LifeConsequenceImpact],
        treaties: [LifeConsequenceGoalTreaty],
        visibilityPreference: LifeConsequenceVisibilityPreference,
        consequenceEvaluatedAt: String,
        sourceAuthorityInspection: SourceAtlasAuthorityInspectionRecord? = nil,
        safetyContext: HighRiskJurisdictionContext,
        safetyEvaluatedAt: String,
        completionProof: GoldenSliceCompletionProof,
        optionalShareProof: GoldenSliceOptionalShareProof? = nil,
        replayOutput: GoldenSliceReplayOutput,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.endUserBackground = endUserBackground
        self.intake = intake
        self.anyGoalInput = anyGoalInput
        self.stepQualityInput = stepQualityInput
        self.latticeInput = latticeInput
        self.compiledPath = compiledPath
        self.selectedCompiledCandidateID = GoldenSliceEndUserBackground.normalizedOptional(selectedCompiledCandidateID)
        self.graphReceiptID = GoldenSliceEndUserBackground.normalizedOptional(graphReceiptID)
        self.graphCompiledAt = GoldenSliceEndUserBackground.normalizedOptional(graphCompiledAt)
        self.partialProgressProof = partialProgressProof
        self.originalDurationMinutes = max(0, originalDurationMinutes)
        self.availableMinutes = max(0, availableMinutes)
        self.elasticityCopyOverrides = elasticityCopyOverrides
        self.elasticityEvaluatedAt = elasticityEvaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedVariantID = GoldenSliceEndUserBackground.normalizedOptional(selectedVariantID)
        self.candidateWindows = candidateWindows
        self.scheduleDecision = scheduleDecision
        self.rollbackPlan = rollbackPlan
        self.protectedTimeProof = protectedTimeProof
        self.scheduleEvaluatedAt = scheduleEvaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.consequenceImpacts = consequenceImpacts
        self.treaties = treaties
        self.visibilityPreference = visibilityPreference
        self.consequenceEvaluatedAt = consequenceEvaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceAuthorityInspection = sourceAuthorityInspection
        self.safetyContext = safetyContext
        self.safetyEvaluatedAt = safetyEvaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.completionProof = completionProof
        self.optionalShareProof = optionalShareProof
        self.replayOutput = replayOutput
        self.localOnly = localOnly
    }
}

struct GoldenVerticalSliceRecord: Sendable, Equatable, Identifiable {
    let id: String
    let state: GoldenVerticalSliceState
    let endUserBackground: GoldenSliceEndUserBackground
    let intake: GoldenSliceGoalIntake
    let anyGoalRecord: AnyGoalCoverageRecord
    let recommendedStep: RecommendedStepEligibility
    let latticeRecord: MultiPathLatticeRecord
    let graphRecord: StepGraphCompilerRecord
    let elasticityRecord: StepElasticityRecord
    let scheduleRecord: ScheduleInstallRecord
    let consequenceRecord: LifeConsequenceRecord
    let safetyRecord: HighRiskSafetyGateRecord
    let runtimeCoreRecord: RuntimeCoreUmbrellaGateRecord
    let completionProof: GoldenSliceCompletionProof
    let optionalShareProof: GoldenSliceOptionalShareProof?
    let replayOutput: GoldenSliceReplayOutput
    let issues: [GoldenVerticalSliceIssue]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let personalizationFingerprint: String

    var canProveCompleteFlow: Bool {
        state == .ready && issues.isEmpty
    }
}

struct GoldenVerticalSliceProgramInput: Sendable, Equatable {
    let slices: [GoldenVerticalSliceInput]
    let evaluatedAt: String

    init(slices: [GoldenVerticalSliceInput], evaluatedAt: String) {
        self.slices = slices
        self.evaluatedAt = evaluatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

struct GoldenVerticalSliceProgramRecord: Sendable, Equatable, Identifiable {
    let id: String
    let evaluatedAt: String
    let slices: [GoldenVerticalSliceRecord]
    let issues: [GoldenVerticalSliceIssue]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let reflowTraceIDs: [String]

    var canProveBothPersonalizedSlices: Bool {
        issues.isEmpty &&
            slices.count == 2 &&
            slices.allSatisfy(\.canProveCompleteFlow)
    }
}

struct GoldenVerticalSliceRuntime: Sendable, Equatable {
    func evaluate(_ input: GoldenVerticalSliceProgramInput) -> GoldenVerticalSliceProgramRecord {
        let sliceRecords = input.slices
            .map(evaluateSlice)
            .sorted { $0.id < $1.id }
        var issues: Set<GoldenVerticalSliceIssue> = []

        if sliceRecords.count != 2 {
            issues.insert(.requiresExactlyTwoSlices)
        }
        if Set(sliceRecords.map { $0.endUserBackground.id }).count != sliceRecords.count {
            issues.insert(.duplicateEndUserBackground)
        }
        if Set(sliceRecords.map { $0.anyGoalRecord.goalReferenceID }).count != sliceRecords.count {
            issues.insert(.duplicateGoalReference)
        }
        if Set(sliceRecords.map(\.personalizationFingerprint)).count != sliceRecords.count {
            issues.insert(.personalizationNotDistinct)
        }
        if sliceRecords.contains(where: { $0.canProveCompleteFlow == false }) {
            issues.formUnion(sliceRecords.flatMap(\.issues))
        }

        let sortedIssues = sortedIssues(issues)
        let receiptIDs = normalizedIDs(sliceRecords.flatMap(\.receiptIDs))
        let replayTraceIDs = normalizedIDs(sliceRecords.flatMap(\.replayTraceIDs))
        let reflowTraceIDs = normalizedIDs(sliceRecords.map(\.consequenceRecord.trace.id))
        return GoldenVerticalSliceProgramRecord(
            id: stableIdentifier(
                prefix: "golden-slice.program",
                components: [input.evaluatedAt, sliceRecords.map(\.id).joined(separator: ","), sortedIssues.map(\.rawValue).joined(separator: ",")]
            ),
            evaluatedAt: input.evaluatedAt,
            slices: sliceRecords,
            issues: sortedIssues,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            reflowTraceIDs: reflowTraceIDs
        )
    }

    func evaluateSlice(_ input: GoldenVerticalSliceInput) -> GoldenVerticalSliceRecord {
        let anyGoalRecord = AnyGoalRuntimeCoverageEngine().evaluate(input.anyGoalInput)
        let recommendedStep = StepQualityFirewall().evaluate(input.stepQualityInput)
        let latticeRecord = MultiPathLatticeEngine().evaluate(input.latticeInput)
        let graphRecord = StepGraphCompiler().compile(
            StepGraphCompilerInput(
                goalReferenceID: input.anyGoalInput.id,
                latticeRecord: latticeRecord,
                compiledPath: input.compiledPath,
                selectedCompiledCandidateID: input.selectedCompiledCandidateID,
                graphReceiptID: input.graphReceiptID,
                compiledAt: input.graphCompiledAt
            )
        )
        let elasticityRecord = StepElasticityEngine().evaluate(
            StepElasticityEngineInput(
                graphRecord: graphRecord,
                partialProgressProof: input.partialProgressProof,
                originalDurationMinutes: input.originalDurationMinutes,
                availableMinutes: input.availableMinutes,
                copyOverrides: input.elasticityCopyOverrides,
                evaluatedAt: input.elasticityEvaluatedAt,
                localOnly: input.localOnly,
                silentlyMutatesPlan: false
            )
        )
        let scheduleRecord = ScheduleInstallKernel().evaluate(
            ScheduleInstallInput(
                elasticityRecord: elasticityRecord,
                selectedVariantID: input.selectedVariantID,
                candidateWindows: input.candidateWindows,
                decision: input.scheduleDecision,
                rollbackPlan: input.rollbackPlan,
                protectedTimeProof: input.protectedTimeProof,
                evaluatedAt: input.scheduleEvaluatedAt,
                localOnly: input.localOnly
            )
        )
        let consequenceRecord = LifeConsequenceEngine().evaluate(
            LifeConsequenceEngineInput(
                scheduleInstallRecord: scheduleRecord,
                impacts: input.consequenceImpacts,
                treaties: input.treaties,
                visibilityPreference: input.visibilityPreference,
                evaluatedAt: input.consequenceEvaluatedAt,
                localOnly: input.localOnly
            )
        )
        let safetyRecord = HighRiskSafetyJurisdictionGate().evaluate(
            HighRiskSafetyGateInput(
                anyGoalRecord: anyGoalRecord,
                sourceAuthorityInspection: input.sourceAuthorityInspection,
                lifeConsequenceRecord: consequenceRecord,
                context: input.safetyContext,
                evaluatedAt: input.safetyEvaluatedAt,
                localOnly: input.localOnly
            )
        )
        let runtimeCoreRecord = RuntimeCoreUmbrellaGate().evaluate(
            RuntimeCoreUmbrellaGateInput(
                segments: [
                    latticeRecord.runtimeCoreSegment,
                    qualityFirewallSegment(from: recommendedStep),
                    graphRecord.runtimeCoreSegment,
                    elasticityRecord.runtimeCoreSegment,
                    scheduleRecord.runtimeCoreSegment,
                    consequenceRecord.runtimeCoreSegment,
                    safetyRecord.runtimeCoreSegment
                ]
            )
        )
        let issues = sliceIssues(
            input: input,
            anyGoalRecord: anyGoalRecord,
            recommendedStep: recommendedStep,
            latticeRecord: latticeRecord,
            graphRecord: graphRecord,
            elasticityRecord: elasticityRecord,
            scheduleRecord: scheduleRecord,
            consequenceRecord: consequenceRecord,
            safetyRecord: safetyRecord,
            runtimeCoreRecord: runtimeCoreRecord
        )
        let sortedIssues = sortedIssues(issues)
        let receiptIDs = allReceiptIDs(
            input: input,
            anyGoalRecord: anyGoalRecord,
            recommendedStep: recommendedStep,
            latticeRecord: latticeRecord,
            graphRecord: graphRecord,
            elasticityRecord: elasticityRecord,
            scheduleRecord: scheduleRecord,
            consequenceRecord: consequenceRecord,
            safetyRecord: safetyRecord
        )
        let replayTraceIDs = allReplayTraceIDs(
            input: input,
            anyGoalRecord: anyGoalRecord,
            recommendedStep: recommendedStep,
            latticeRecord: latticeRecord,
            graphRecord: graphRecord,
            elasticityRecord: elasticityRecord,
            scheduleRecord: scheduleRecord,
            consequenceRecord: consequenceRecord,
            safetyRecord: safetyRecord
        )
        let personalizationFingerprint = stableIdentifier(
            prefix: "golden-slice.personalization",
            components: [
                input.endUserBackground.personalizationFingerprint,
                input.anyGoalInput.rawGoalText,
                input.stepQualityInput.stepText,
                latticeRecord.selectedPathID ?? "no-path",
                scheduleRecord.installReceipt?.selectedWindowID ?? "no-window"
            ]
        )

        return GoldenVerticalSliceRecord(
            id: stableIdentifier(prefix: "golden-slice.record", components: [input.id, personalizationFingerprint, sortedIssues.map(\.rawValue).joined(separator: ",")]),
            state: sortedIssues.isEmpty ? .ready : .blocked,
            endUserBackground: input.endUserBackground,
            intake: input.intake,
            anyGoalRecord: anyGoalRecord,
            recommendedStep: recommendedStep,
            latticeRecord: latticeRecord,
            graphRecord: graphRecord,
            elasticityRecord: elasticityRecord,
            scheduleRecord: scheduleRecord,
            consequenceRecord: consequenceRecord,
            safetyRecord: safetyRecord,
            runtimeCoreRecord: runtimeCoreRecord,
            completionProof: input.completionProof,
            optionalShareProof: input.optionalShareProof,
            replayOutput: input.replayOutput,
            issues: sortedIssues,
            receiptIDs: receiptIDs,
            replayTraceIDs: replayTraceIDs,
            personalizationFingerprint: personalizationFingerprint
        )
    }
}
