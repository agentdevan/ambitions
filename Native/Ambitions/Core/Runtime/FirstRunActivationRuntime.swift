import Foundation

enum FirstRunActivationState: String, Sendable, Equatable, Hashable {
    case ready
    case blocked
}

enum FirstRunActivationIssue: String, Sendable, Equatable, Hashable, CaseIterable {
    case goldenProgramNotReady = "golden_program_not_ready"
    case goldenSliceMissing = "golden_slice_missing"
    case firstGoalFlowMissing = "first_goal_flow_missing"
    case firstGoalMissing = "first_goal_missing"
    case firstGoalNotFromGoldenSlice = "first_goal_not_from_golden_slice"
    case recommendedStepMissing = "recommended_step_missing"
    case recommendedStepNotVisible = "recommended_step_not_visible"
    case recommendedStepNotFromGoldenSlice = "recommended_step_not_from_golden_slice"
    case recoveryOptionMissing = "recovery_option_missing"
    case recoveryOptionNotTiedToGoldenSlice = "recovery_option_not_tied_to_golden_slice"
    case recoveryOptionNotSafe = "recovery_option_not_safe"
    case activationReceiptMissing = "activation_receipt_missing"
    case activationReplayMissing = "activation_replay_missing"
    case activationInspectionRouteMissing = "activation_inspection_route_missing"
    case calmContinuityMissing = "calm_continuity_missing"
    case genericOnboardingTheater = "generic_onboarding_theater"
    case nonLocalRuntimeBoundary = "non_local_runtime_boundary"
}

struct FirstRunActivationInput: Sendable, Equatable {
    let goldenProgram: GoldenVerticalSliceProgramRecord
    let selectedSliceID: String?
    let onboardingChoice: OnboardingEntryChoice
    let activatedAt: String
    let continuitySummaryOverride: String?
    let localOnly: Bool

    init(
        goldenProgram: GoldenVerticalSliceProgramRecord,
        selectedSliceID: String? = nil,
        onboardingChoice: OnboardingEntryChoice = .createFirstGoal,
        activatedAt: String,
        continuitySummaryOverride: String? = nil,
        localOnly: Bool = true
    ) {
        self.goldenProgram = goldenProgram
        self.selectedSliceID = Self.normalizedOptional(selectedSliceID)
        self.onboardingChoice = onboardingChoice
        self.activatedAt = activatedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        self.continuitySummaryOverride = Self.normalizedOptional(continuitySummaryOverride)
        self.localOnly = localOnly
    }

    private static func normalizedOptional(_ value: String?) -> String? {
        guard let normalized = value?.trimmingCharacters(in: .whitespacesAndNewlines), normalized.isEmpty == false else {
            return nil
        }
        return normalized
    }
}

struct FirstRunActivationGoal: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let whatAmbitionsKnowsRoute: String?

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceIDs.isEmpty == false &&
            whatAmbitionsKnowsRoute != nil
    }
}

struct FirstRunActivationRecommendedStep: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let title: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let canShow: Bool

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            canShow
    }
}

struct FirstRunActivationRecoveryOption: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let kind: StepElasticityActionKind
    let title: String
    let summary: String
    let reason: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceID: String?
    let whatAmbitionsKnowsRoute: String?
    let sourceNodeID: String
    let recoverySafe: Bool
    let preservesProof: Bool
    let localOnly: Bool
    let silentlyMutatesPlan: Bool

    var isInspectable: Bool {
        id.isEmpty == false &&
            title.isEmpty == false &&
            summary.isEmpty == false &&
            reason.isEmpty == false &&
            sourceNodeID.isEmpty == false &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceID != nil &&
            whatAmbitionsKnowsRoute != nil &&
            recoverySafe &&
            preservesProof &&
            localOnly &&
            silentlyMutatesPlan == false
    }
}

struct FirstRunActivationReceipt: Sendable, Equatable, Hashable, Identifiable {
    let id: String
    let activatedAt: String
    let firstGoalID: String
    let recommendedStepID: String
    let recoveryOptionID: String
    let continuitySummary: String
    let topLevelTabs: [String]
    let captureRole: String
    let sourceRecordIDs: [String]
    let receiptIDs: [String]
    let replayTraceIDs: [String]
    let whatAmbitionsKnowsRoute: String?
    let localOnly: Bool

    var isInspectable: Bool {
        id.isEmpty == false &&
            activatedAt.isEmpty == false &&
            firstGoalID.isEmpty == false &&
            recommendedStepID.isEmpty == false &&
            recoveryOptionID.isEmpty == false &&
            continuitySummary.isEmpty == false &&
            topLevelTabs == ["Today", "Goals", "Time", "Motion", "You"] &&
            captureRole == "global action" &&
            sourceRecordIDs.isEmpty == false &&
            receiptIDs.isEmpty == false &&
            replayTraceIDs.isEmpty == false &&
            whatAmbitionsKnowsRoute != nil &&
            localOnly
    }
}

struct FirstRunActivationRecord: Sendable, Equatable, Identifiable {
    let id: String
    let state: FirstRunActivationState
    let selectedSliceID: String?
    let firstGoal: FirstRunActivationGoal?
    let recommendedStep: FirstRunActivationRecommendedStep?
    let recoveryOption: FirstRunActivationRecoveryOption?
    let receipt: FirstRunActivationReceipt?
    let issues: [FirstRunActivationIssue]

    var canActivateFirstRun: Bool {
        state == .ready &&
            issues.isEmpty &&
            firstGoal?.isInspectable == true &&
            recommendedStep?.isInspectable == true &&
            recoveryOption?.isInspectable == true &&
            receipt?.isInspectable == true
    }
}

struct FirstRunActivationRuntime: Sendable, Equatable {
    func evaluate(_ input: FirstRunActivationInput) -> FirstRunActivationRecord {
        let selectedSlice = selectSlice(from: input)
        let firstGoal = selectedSlice.map(firstGoal(from:))
        let recommendedStep = selectedSlice.map(recommendedStep(from:))
        let recoveryOption = selectedSlice.flatMap(recoveryOption(from:))
        let receipt = makeReceipt(
            input: input,
            slice: selectedSlice,
            firstGoal: firstGoal,
            recommendedStep: recommendedStep,
            recoveryOption: recoveryOption
        )
        let issues = sortedIssues(
            issues(
                input: input,
                slice: selectedSlice,
                firstGoal: firstGoal,
                recommendedStep: recommendedStep,
                recoveryOption: recoveryOption,
                receipt: receipt
            )
        )
        return FirstRunActivationRecord(
            id: stableIdentifier(
                prefix: "first-run-activation.record",
                components: [
                    input.activatedAt,
                    selectedSlice?.id ?? "missing-slice",
                    issues.map(\.rawValue).joined(separator: ",")
                ]
            ),
            state: issues.isEmpty ? .ready : .blocked,
            selectedSliceID: selectedSlice?.id,
            firstGoal: firstGoal,
            recommendedStep: recommendedStep,
            recoveryOption: recoveryOption,
            receipt: receipt,
            issues: issues
        )
    }
}

private extension FirstRunActivationRuntime {
    func selectSlice(from input: FirstRunActivationInput) -> GoldenVerticalSliceRecord? {
        let readySlices = input.goldenProgram.slices
            .filter(\.canProveCompleteFlow)
            .sorted { $0.id < $1.id }
        guard let selectedSliceID = input.selectedSliceID else {
            return readySlices.first
        }
        return readySlices.first {
            $0.id == selectedSliceID ||
                $0.endUserBackground.id == selectedSliceID ||
                $0.anyGoalRecord.goalReferenceID == selectedSliceID
        }
    }

    func firstGoal(from slice: GoldenVerticalSliceRecord) -> FirstRunActivationGoal {
        FirstRunActivationGoal(
            id: slice.anyGoalRecord.goalReferenceID,
            title: slice.intake.normalizedGoal.isEmpty ? slice.intake.rawGoalText : slice.intake.normalizedGoal,
            sourceRecordIDs: normalizedIDs(
                slice.endUserBackground.sourceRecordIDs +
                    slice.intake.sourceRecordIDs +
                    slice.anyGoalRecord.recoveryReceipt.sourceRecordIDs
            ),
            receiptIDs: normalizedIDs(
                slice.endUserBackground.receiptIDs +
                    slice.intake.receiptIDs +
                    [slice.anyGoalRecord.recoveryReceipt.receiptID]
            ),
            replayTraceIDs: normalizedIDs(
                [
                    slice.endUserBackground.replayTraceID,
                    slice.intake.replayTraceID,
                    slice.anyGoalRecord.recoveryReceipt.replayTraceID
                ].compactMap { $0 }
            ),
            whatAmbitionsKnowsRoute: slice.intake.whatAmbitionsKnowsRoute ?? slice.endUserBackground.whatAmbitionsKnowsRoute
        )
    }

    func recommendedStep(from slice: GoldenVerticalSliceRecord) -> FirstRunActivationRecommendedStep {
        FirstRunActivationRecommendedStep(
            id: slice.recommendedStep.candidateId,
            title: slice.recommendedStep.visibleStepText,
            sourceRecordIDs: slice.recommendedStep.sourceRecordIDs,
            receiptIDs: slice.recommendedStep.receiptIDs,
            replayTraceID: slice.recommendedStep.replayTraceID,
            whatAmbitionsKnowsRoute: slice.recommendedStep.whatAmbitionsKnowsRoute,
            canShow: slice.recommendedStep.canShow
        )
    }

    func recoveryOption(from slice: GoldenVerticalSliceRecord) -> FirstRunActivationRecoveryOption? {
        guard let variant = slice.elasticityRecord.variants
            .sorted(by: variantSort)
            .first(where: { $0.kind == .shrink && $0.recoverySafe }) ??
            slice.elasticityRecord.variants.sorted(by: variantSort).first(where: \.recoverySafe) else {
            return nil
        }
        let matchingReceipt = slice.elasticityRecord.receipts.first { $0.variantID == variant.id }
        return FirstRunActivationRecoveryOption(
            id: variant.id,
            kind: variant.kind,
            title: variant.title,
            summary: variant.summary,
            reason: variant.reason,
            sourceRecordIDs: normalizedIDs(variant.sourceRecordIDs + (matchingReceipt?.sourceRecordIDs ?? [])),
            receiptIDs: normalizedIDs(variant.receiptIDs + (matchingReceipt?.receiptIDs ?? []) + [matchingReceipt?.id].compactMap { $0 }),
            replayTraceID: matchingReceipt?.replayTraceID ?? variant.replayTraceID,
            whatAmbitionsKnowsRoute: matchingReceipt?.whatAmbitionsKnowsRoute ?? variant.whatAmbitionsKnowsRoute,
            sourceNodeID: variant.sourceNodeID,
            recoverySafe: variant.recoverySafe,
            preservesProof: variant.preservesProof,
            localOnly: variant.localOnly && (matchingReceipt?.localOnly ?? true),
            silentlyMutatesPlan: variant.silentlyMutatesPlan
        )
    }

    func makeReceipt(
        input: FirstRunActivationInput,
        slice: GoldenVerticalSliceRecord?,
        firstGoal: FirstRunActivationGoal?,
        recommendedStep: FirstRunActivationRecommendedStep?,
        recoveryOption: FirstRunActivationRecoveryOption?
    ) -> FirstRunActivationReceipt? {
        guard let slice, let firstGoal, let recommendedStep, let recoveryOption else {
            return nil
        }
        let continuitySummary = input.continuitySummaryOverride ?? defaultContinuitySummary(
            slice: slice,
            firstGoal: firstGoal,
            recommendedStep: recommendedStep,
            recoveryOption: recoveryOption
        )
        let route = "you://what-ambitions-knows/first-run-activation/\(firstGoal.id)"
        return FirstRunActivationReceipt(
            id: stableIdentifier(
                prefix: "first-run-activation.receipt",
                components: [
                    input.activatedAt,
                    firstGoal.id,
                    recommendedStep.id,
                    recoveryOption.id
                ]
            ),
            activatedAt: input.activatedAt,
            firstGoalID: firstGoal.id,
            recommendedStepID: recommendedStep.id,
            recoveryOptionID: recoveryOption.id,
            continuitySummary: continuitySummary,
            topLevelTabs: AmbitionsSurface.allCases.map(\.title),
            captureRole: "global action",
            sourceRecordIDs: normalizedIDs(
                firstGoal.sourceRecordIDs +
                    recommendedStep.sourceRecordIDs +
                    recoveryOption.sourceRecordIDs +
                    slice.replayOutput.sourceRecordIDs
            ),
            receiptIDs: normalizedIDs(
                firstGoal.receiptIDs +
                    recommendedStep.receiptIDs +
                    recoveryOption.receiptIDs +
                    slice.replayOutput.receiptIDs
            ),
            replayTraceIDs: normalizedIDs(
                firstGoal.replayTraceIDs +
                    [recommendedStep.replayTraceID].compactMap { $0 } +
                    [recoveryOption.replayTraceID].compactMap { $0 } +
                    slice.replayOutput.replayTraceIDs
            ),
            whatAmbitionsKnowsRoute: route,
            localOnly: input.localOnly && slice.replayOutput.localOnly && recoveryOption.localOnly
        )
    }

    func issues(
        input: FirstRunActivationInput,
        slice: GoldenVerticalSliceRecord?,
        firstGoal: FirstRunActivationGoal?,
        recommendedStep: FirstRunActivationRecommendedStep?,
        recoveryOption: FirstRunActivationRecoveryOption?,
        receipt: FirstRunActivationReceipt?
    ) -> Set<FirstRunActivationIssue> {
        var issues: Set<FirstRunActivationIssue> = []
        if input.goldenProgram.canProveBothPersonalizedSlices == false {
            issues.insert(.goldenProgramNotReady)
        }
        guard let slice else {
            issues.insert(.goldenSliceMissing)
            issues.insert(.firstGoalMissing)
            issues.insert(.recommendedStepMissing)
            issues.insert(.recoveryOptionMissing)
            issues.insert(.activationReceiptMissing)
            return issues
        }
        if input.onboardingChoice != .createFirstGoal {
            issues.insert(.firstGoalFlowMissing)
        }
        if input.localOnly == false || slice.replayOutput.localOnly == false {
            issues.insert(.nonLocalRuntimeBoundary)
        }
        if firstGoal?.isInspectable != true {
            issues.insert(.firstGoalMissing)
        }
        if firstGoal?.id != slice.anyGoalRecord.goalReferenceID {
            issues.insert(.firstGoalNotFromGoldenSlice)
        }
        if recommendedStep == nil {
            issues.insert(.recommendedStepMissing)
        }
        if recommendedStep?.canShow != true {
            issues.insert(.recommendedStepNotVisible)
        }
        if recommendedStep?.id != slice.recommendedStep.candidateId {
            issues.insert(.recommendedStepNotFromGoldenSlice)
        }
        if recoveryOption == nil {
            issues.insert(.recoveryOptionMissing)
        }
        if recoveryOption?.isInspectable != true {
            issues.insert(.recoveryOptionNotSafe)
        }
        if let recoveryOption, slice.elasticityRecord.variants.contains(where: { $0.id == recoveryOption.id }) == false {
            issues.insert(.recoveryOptionNotTiedToGoldenSlice)
        }
        if receipt?.isInspectable != true {
            issues.insert(.activationReceiptMissing)
        }
        if receipt?.replayTraceIDs.isEmpty != false {
            issues.insert(.activationReplayMissing)
        }
        if receipt?.whatAmbitionsKnowsRoute == nil {
            issues.insert(.activationInspectionRouteMissing)
        }
        if let receipt {
            if continuityIsCalm(receipt.continuitySummary, firstGoal: firstGoal, recommendedStep: recommendedStep, recoveryOption: recoveryOption) == false {
                issues.insert(.calmContinuityMissing)
            }
            if isGenericOnboardingTheater(receipt.continuitySummary) {
                issues.insert(.genericOnboardingTheater)
            }
        }
        return issues
    }

    func defaultContinuitySummary(
        slice: GoldenVerticalSliceRecord,
        firstGoal: FirstRunActivationGoal,
        recommendedStep: FirstRunActivationRecommendedStep,
        recoveryOption: FirstRunActivationRecoveryOption
    ) -> String {
        "\(slice.endUserBackground.displayName)'s first-run activation keeps \(firstGoal.title) connected to the Recommended step \(recommendedStep.title), the recovery option \(recoveryOption.title), and local receipt replay."
    }

    func continuityIsCalm(
        _ summary: String,
        firstGoal: FirstRunActivationGoal?,
        recommendedStep: FirstRunActivationRecommendedStep?,
        recoveryOption: FirstRunActivationRecoveryOption?
    ) -> Bool {
        let normalized = normalizedCopy(summary)
        guard normalized.contains("local"),
              normalized.contains("receipt"),
              normalized.contains("recovery"),
              normalized.contains("recommended step") else {
            return false
        }
        let goalTokens = requiredTokens(from: firstGoal?.title ?? "", minimumCount: 2)
        let stepTokens = requiredTokens(from: recommendedStep?.title ?? "", minimumCount: 2)
        let recoveryTokens = requiredTokens(from: recoveryOption?.title ?? "", minimumCount: 1)
        return goalTokens.allSatisfy { normalized.contains($0) } &&
            stepTokens.allSatisfy { normalized.contains($0) } &&
            recoveryTokens.allSatisfy { normalized.contains($0) }
    }

    func isGenericOnboardingTheater(_ summary: String) -> Bool {
        let normalized = normalizedCopy(summary)
        let genericPhrases = [
            "finish setup",
            "tour the app",
            "learn the app",
            "set up everything",
            "configure preferences",
            "generic onboarding",
            "watch intro"
        ]
        return genericPhrases.contains { normalized.contains($0) }
    }

    func requiredTokens(from value: String, minimumCount: Int) -> [String] {
        normalizedCopy(value)
            .split(separator: " ")
            .map(String.init)
            .filter { $0.count > 3 }
            .prefix(minimumCount)
            .map { $0 }
    }

    func variantSort(_ lhs: StepElasticityVariant, _ rhs: StepElasticityVariant) -> Bool {
        if lhs.kind.orderIndex == rhs.kind.orderIndex {
            return lhs.id < rhs.id
        }
        return lhs.kind.orderIndex < rhs.kind.orderIndex
    }

    func sortedIssues(_ issues: Set<FirstRunActivationIssue>) -> [FirstRunActivationIssue] {
        issues.sorted { $0.rawValue < $1.rawValue }
    }

    func stableIdentifier(prefix: String, components: [String]) -> String {
        ([prefix] + components.map(normalizedToken))
            .filter { $0.isEmpty == false }
            .joined(separator: ".")
    }

    func normalizedToken(_ value: String) -> String {
        value
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: "-")
    }

    func normalizedCopy(_ value: String) -> String {
        value
            .lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.isEmpty == false }
            .joined(separator: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func normalizedIDs(_ values: [String]) -> [String] {
        Array(Set(values.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { $0.isEmpty == false })).sorted()
    }
}
