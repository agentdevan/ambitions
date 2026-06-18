import Foundation

enum GoldenVerticalSliceState: String, Sendable, Equatable, Hashable {
    case ready
    case blocked
}

enum GoldenVerticalSliceIssue: String, Sendable, Equatable, Hashable, CaseIterable {
    case requiresExactlyTwoSlices = "requires_exactly_two_slices"
    case duplicateEndUserBackground = "duplicate_end_user_background"
    case duplicateGoalReference = "duplicate_goal_reference"
    case intakeMissing = "intake_missing"
    case backgroundMissing = "background_missing"
    case notMusicReleaseGoal = "not_music_release_goal"
    case anyGoalBlocked = "any_goal_blocked"
    case stepQualityBlocked = "step_quality_blocked"
    case pathSelectionBlocked = "path_selection_blocked"
    case graphCompilerBlocked = "graph_compiler_blocked"
    case elasticityBlocked = "elasticity_blocked"
    case scheduleInstallBlocked = "schedule_install_blocked"
    case consequenceReflowBlocked = "consequence_reflow_blocked"
    case highRiskSafetyBlocked = "high_risk_safety_blocked"
    case runtimeCoreBlocked = "runtime_core_blocked"
    case completionProofMissing = "completion_proof_missing"
    case completionDoesNotMatchRecommendedStep = "completion_does_not_match_recommended_step"
    case replayOutputMissing = "replay_output_missing"
    case replayOutputDoesNotMatchRuntime = "replay_output_does_not_match_runtime"
    case optionalShareProofBlocked = "optional_share_proof_blocked"
    case backgroundNotCarriedIntoReplay = "background_not_carried_into_replay"
    case personalizationNotDistinct = "personalization_not_distinct"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
}

struct GoldenSliceEndUserBackground: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let displayName: String
    let lifeContextSummary: String
    let capacityProfile: String
    let creativeConstraint: String
    let supportPreference: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    init(
        id: String,
        displayName: String,
        lifeContextSummary: String,
        capacityProfile: String,
        creativeConstraint: String,
        supportPreference: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?
    ) {
        self.id = Self.normalizedID(id)
        self.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.lifeContextSummary = lifeContextSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capacityProfile = capacityProfile.trimmingCharacters(in: .whitespacesAndNewlines)
        self.creativeConstraint = creativeConstraint.trimmingCharacters(in: .whitespacesAndNewlines)
        self.supportPreference = supportPreference.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = Self.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = Self.normalizedIDs(receiptIDs)
        self.replayTraceID = Self.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = Self.normalizedOptional(whatAmbitionsKnowsRoute)
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            displayName.isEmpty == false &&
            lifeContextSummary.isEmpty == false &&
            capacityProfile.isEmpty == false &&
            creativeConstraint.isEmpty == false &&
            supportPreference.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil
    }

    fileprivate var personalizationFingerprint: String {
        Self.stableIdentifier(
            prefix: "golden-slice.background",
            components: [id, lifeContextSummary, capacityProfile, creativeConstraint, supportPreference]
        )
    }

    private static func normalizedID(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    fileprivate static func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map(normalizedID).filter { $0.isEmpty == false })).sorted()
    }

    fileprivate static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }

    fileprivate static func stableIdentifier(prefix: String, components: [String]) -> String {
        let payload = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
            .filter { $0.isEmpty == false }
            .joined(separator: "|")
        let normalized = payload
            .replacingOccurrences(of: "://", with: "-")
            .replacingOccurrences(of: "/", with: "-")
            .replacingOccurrences(of: " ", with: "-")
            .replacingOccurrences(of: "_", with: "-")
            .components(separatedBy: CharacterSet.alphanumerics.union(CharacterSet(charactersIn: ".-")).inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
        return "\(prefix).\(normalized)"
    }
}

struct GoldenSliceGoalIntake: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let rawGoalText: String
    let normalizedGoal: String
    let intakeSurface: String
    let capturedAt: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?

    init(
        id: String,
        rawGoalText: String,
        normalizedGoal: String,
        intakeSurface: String,
        capturedAt: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.rawGoalText = rawGoalText.trimmingCharacters(in: .whitespacesAndNewlines)
        self.normalizedGoal = normalizedGoal.trimmingCharacters(in: .whitespacesAndNewlines)
        self.intakeSurface = intakeSurface.trimmingCharacters(in: .whitespacesAndNewlines)
        self.capturedAt = capturedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceID = GoldenSliceEndUserBackground.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            rawGoalText.isEmpty == false &&
            normalizedGoal.isEmpty == false &&
            intakeSurface.isEmpty == false &&
            capturedAt.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil
    }

    var isMusicReleaseGoal: Bool {
        let normalized = "\(rawGoalText) \(normalizedGoal)"
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
        let terms = Set(normalized)
        return terms.contains("release") &&
            (terms.contains("music") || terms.contains("song") || terms.contains("single") || terms.contains("album") || terms.contains("track"))
    }
}

struct GoldenSliceCompletionProof: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let completedStepID: String
    let completedAt: String
    let proofSummary: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    init(
        id: String,
        completedStepID: String,
        completedAt: String,
        proofSummary: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.completedStepID = completedStepID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.completedAt = completedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.proofSummary = proofSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceID = GoldenSliceEndUserBackground.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            completedStepID.isEmpty == false &&
            completedAt.isEmpty == false &&
            proofSummary.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }
}

struct GoldenSliceOptionalShareProof: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let audienceSummary: String
    let redactionSummary: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let userApproved: Bool
    let localOnly: Bool

    init(
        id: String,
        audienceSummary: String,
        redactionSummary: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceID: String?,
        whatAmbitionsKnowsRoute: String?,
        userApproved: Bool,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.audienceSummary = audienceSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.redactionSummary = redactionSummary.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceID = GoldenSliceEndUserBackground.normalizedOptional(replayTraceID)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
        self.userApproved = userApproved
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            audienceSummary.isEmpty == false &&
            redactionSummary.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            userApproved &&
            localOnly
    }
}

struct GoldenSliceReplayOutput: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let replayedAt: String
    let intakeReceiptID: String
    let selectedPathReceiptID: String
    let scheduleReceiptID: String
    let completionReceiptID: String
    let reflowTraceID: String
    let safetyReceiptID: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    init(
        id: String,
        replayedAt: String,
        intakeReceiptID: String,
        selectedPathReceiptID: String,
        scheduleReceiptID: String,
        completionReceiptID: String,
        reflowTraceID: String,
        safetyReceiptID: String,
        sourceRecordIDs: [String],
        receiptIDs: [String],
        replayTraceIDs: [String],
        whatAmbitionsKnowsRoute: String?,
        localOnly: Bool = true
    ) {
        self.id = id.trimmingCharacters(in: .whitespacesAndNewlines)
        self.replayedAt = replayedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.intakeReceiptID = intakeReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.selectedPathReceiptID = selectedPathReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.scheduleReceiptID = scheduleReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.completionReceiptID = completionReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.reflowTraceID = reflowTraceID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.safetyReceiptID = safetyReceiptID.trimmingCharacters(in: .whitespacesAndNewlines)
        self.sourceRecordIDs = GoldenSliceEndUserBackground.normalizedIDs(sourceRecordIDs)
        self.receiptIDs = GoldenSliceEndUserBackground.normalizedIDs(receiptIDs)
        self.replayTraceIDs = GoldenSliceEndUserBackground.normalizedIDs(replayTraceIDs)
        self.whatAmbitionsKnowsRoute = GoldenSliceEndUserBackground.normalizedOptional(whatAmbitionsKnowsRoute)
        self.localOnly = localOnly
    }

    var isInspectable: Bool {
        id.isEmpty == false &&
            replayedAt.isEmpty == false &&
            intakeReceiptID.isEmpty == false &&
            selectedPathReceiptID.isEmpty == false &&
            scheduleReceiptID.isEmpty == false &&
            completionReceiptID.isEmpty == false &&
            reflowTraceID.isEmpty == false &&
            safetyReceiptID.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceIDs.isEmpty == false &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }
}

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

    private func evaluateSlice(_ input: GoldenVerticalSliceInput) -> GoldenVerticalSliceRecord {
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

private extension GoldenVerticalSliceRuntime {
    func qualityFirewallSegment(from recommendedStep: RecommendedStepEligibility) -> RuntimeCoreChainSegment {
        RuntimeCoreChainSegment(
            kind: .qualityFirewall,
            state: recommendedStep.canShow ? .ready : .blocked,
            sourceRecordIDs: recommendedStep.sourceRecordIDs,
            receiptIDs: recommendedStep.receiptIDs,
            replayTraceID: recommendedStep.replayTraceID,
            whatAmbitionsKnowsRoute: recommendedStep.whatAmbitionsKnowsRoute,
            isReversible: true,
            canDriveVisibleExecution: recommendedStep.canShow,
            blocksDownstream: recommendedStep.canShow == false
        )
    }

    func sliceIssues(
        input: GoldenVerticalSliceInput,
        anyGoalRecord: AnyGoalCoverageRecord,
        recommendedStep: RecommendedStepEligibility,
        latticeRecord: MultiPathLatticeRecord,
        graphRecord: StepGraphCompilerRecord,
        elasticityRecord: StepElasticityRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord,
        runtimeCoreRecord: RuntimeCoreUmbrellaGateRecord
    ) -> Set<GoldenVerticalSliceIssue> {
        var issues: Set<GoldenVerticalSliceIssue> = []
        if input.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if input.endUserBackground.isInspectable == false {
            issues.insert(.backgroundMissing)
        }
        if input.intake.isInspectable == false {
            issues.insert(.intakeMissing)
        }
        if input.intake.isMusicReleaseGoal == false {
            issues.insert(.notMusicReleaseGoal)
        }
        if anyGoalRecord.canContinueToStepQualityFirewall == false || anyGoalRecord.canGenerateVisibleStep == false {
            issues.insert(.anyGoalBlocked)
        }
        if recommendedStep.canShow == false {
            issues.insert(.stepQualityBlocked)
        }
        if latticeRecord.canDrivePathSelectionSegment == false {
            issues.insert(.pathSelectionBlocked)
        }
        if graphRecord.canDriveGraphCompilerSegment == false {
            issues.insert(.graphCompilerBlocked)
        }
        if elasticityRecord.canDriveElasticitySegment == false {
            issues.insert(.elasticityBlocked)
        }
        if scheduleRecord.canDriveScheduleInstallSegment == false {
            issues.insert(.scheduleInstallBlocked)
        }
        if consequenceRecord.canDriveConsequenceReflowSegment == false {
            issues.insert(.consequenceReflowBlocked)
        }
        if safetyRecord.canContinueToRuntimeCore == false || safetyRecord.canGenerateVisibleStep == false || safetyRecord.canInstallSchedule == false {
            issues.insert(.highRiskSafetyBlocked)
        }
        if runtimeCoreRecord.canOpenRuntimeCore == false {
            issues.insert(.runtimeCoreBlocked)
        }
        if input.completionProof.isInspectable == false {
            issues.insert(.completionProofMissing)
        }
        if input.completionProof.completedStepID != recommendedStep.candidateId {
            issues.insert(.completionDoesNotMatchRecommendedStep)
        }
        if input.replayOutput.isInspectable == false {
            issues.insert(.replayOutputMissing)
        }
        if replayMatchesRuntime(input: input, latticeRecord: latticeRecord, scheduleRecord: scheduleRecord, consequenceRecord: consequenceRecord, safetyRecord: safetyRecord) == false {
            issues.insert(.replayOutputDoesNotMatchRuntime)
        }
        if let shareProof = input.optionalShareProof, shareProof.isInspectable == false {
            issues.insert(.optionalShareProofBlocked)
        }
        if Set(input.endUserBackground.sourceRecordIDs).isSubset(of: Set(input.replayOutput.sourceRecordIDs)) == false {
            issues.insert(.backgroundNotCarriedIntoReplay)
        }
        return issues
    }

    func replayMatchesRuntime(
        input: GoldenVerticalSliceInput,
        latticeRecord: MultiPathLatticeRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord
    ) -> Bool {
        input.replayOutput.intakeReceiptID == input.intake.receiptIDs.first &&
            input.replayOutput.selectedPathReceiptID == latticeRecord.selectionReceipt?.id &&
            input.replayOutput.scheduleReceiptID == scheduleRecord.installReceipt?.id &&
            input.replayOutput.completionReceiptID == input.completionProof.receiptIDs.first &&
            input.replayOutput.reflowTraceID == consequenceRecord.trace.id &&
            input.replayOutput.safetyReceiptID == safetyRecord.receipt.id &&
            input.replayOutput.replayTraceIDs.contains(consequenceRecord.trace.id) &&
            input.replayOutput.replayTraceIDs.contains(safetyRecord.trace.id)
    }

    func allReceiptIDs(
        input: GoldenVerticalSliceInput,
        anyGoalRecord: AnyGoalCoverageRecord,
        recommendedStep: RecommendedStepEligibility,
        latticeRecord: MultiPathLatticeRecord,
        graphRecord: StepGraphCompilerRecord,
        elasticityRecord: StepElasticityRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord
    ) -> [String] {
        var receiptIDs = input.endUserBackground.receiptIDs
        receiptIDs.append(contentsOf: input.intake.receiptIDs)
        receiptIDs.append(contentsOf: anyGoalRecord.recoveryReceipt.receiptID.asArray)
        receiptIDs.append(contentsOf: recommendedStep.receiptIDs)
        if let latticeReceiptID = latticeRecord.selectionReceipt?.id {
            receiptIDs.append(latticeReceiptID)
        }
        receiptIDs.append(contentsOf: graphRecord.receipt?.receiptIDs ?? [])
        receiptIDs.append(contentsOf: elasticityRecord.receipts.flatMap(\.receiptIDs))
        receiptIDs.append(contentsOf: scheduleRecord.installReceipt?.receiptIDs ?? [])
        receiptIDs.append(contentsOf: consequenceRecord.receipts.flatMap(\.receiptIDs))
        receiptIDs.append(safetyRecord.receipt.id)
        receiptIDs.append(contentsOf: safetyRecord.receipt.receiptIDs)
        receiptIDs.append(contentsOf: input.completionProof.receiptIDs)
        receiptIDs.append(contentsOf: input.optionalShareProof?.receiptIDs ?? [])
        receiptIDs.append(contentsOf: input.replayOutput.receiptIDs)
        return normalizedIDs(receiptIDs)
    }

    func allReplayTraceIDs(
        input: GoldenVerticalSliceInput,
        anyGoalRecord: AnyGoalCoverageRecord,
        recommendedStep: RecommendedStepEligibility,
        latticeRecord: MultiPathLatticeRecord,
        graphRecord: StepGraphCompilerRecord,
        elasticityRecord: StepElasticityRecord,
        scheduleRecord: ScheduleInstallRecord,
        consequenceRecord: LifeConsequenceRecord,
        safetyRecord: HighRiskSafetyGateRecord
    ) -> [String] {
        var replayTraceIDs: [String] = []
        if let backgroundReplayTraceID = input.endUserBackground.replayTraceID {
            replayTraceIDs.append(backgroundReplayTraceID)
        }
        if let intakeReplayTraceID = input.intake.replayTraceID {
            replayTraceIDs.append(intakeReplayTraceID)
        }
        replayTraceIDs.append(anyGoalRecord.recoveryReceipt.replayTraceID)
        if let recommendedStepReplayTraceID = recommendedStep.replayTraceID {
            replayTraceIDs.append(recommendedStepReplayTraceID)
        }
        if let latticeReplayTraceID = latticeRecord.selectionReceipt?.replayTraceID {
            replayTraceIDs.append(latticeReplayTraceID)
        }
        replayTraceIDs.append(graphRecord.trace.id)
        replayTraceIDs.append(elasticityRecord.trace.id)
        replayTraceIDs.append(scheduleRecord.trace.id)
        replayTraceIDs.append(consequenceRecord.trace.id)
        replayTraceIDs.append(safetyRecord.trace.id)
        if let completionReplayTraceID = input.completionProof.replayTraceID {
            replayTraceIDs.append(completionReplayTraceID)
        }
        if let shareReplayTraceID = input.optionalShareProof?.replayTraceID {
            replayTraceIDs.append(shareReplayTraceID)
        }
        replayTraceIDs.append(contentsOf: input.replayOutput.replayTraceIDs)
        return normalizedIDs(replayTraceIDs)
    }

    func normalizedIDs(_ values: [String]) -> [String] {
        GoldenSliceEndUserBackground.normalizedIDs(values)
    }

    func sortedIssues(_ issues: Set<GoldenVerticalSliceIssue>) -> [GoldenVerticalSliceIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }

    func stableIdentifier(prefix: String, components: [String]) -> String {
        GoldenSliceEndUserBackground.stableIdentifier(prefix: prefix, components: components)
    }
}

private extension String {
    var asArray: [String] {
        isEmpty ? [] : [self]
    }
}
