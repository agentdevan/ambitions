import Foundation

extension FirstRunActivationRuntime {
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
